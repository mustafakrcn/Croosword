# TCP Listener Server (No Admin Required)
$path = Get-Location
$port = 8080

try {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)
    $listener.Start()
} catch {
    Write-Host "Hata: Port $port kullanilamiyor. Portu 12345 yapiyorum..."
    $port = 12345
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)
    $listener.Start()
}

# Find IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like "*Ethernet*" -or $_.InterfaceAlias -like "*Wi-Fi*" } | Select-Object -First 1).IPAddress

Write-Host "============================================="
Write-Host ">>> SUNUCU BASLADI (Yonetici izni gerekmez)"
Write-Host "    Mobil Cihaz Adresi: http://$($ip):$port"
Write-Host "    Yerel Adres:        http://localhost:$port"
Write-Host "    Durdurmak icin pencereyi kapatin"
Write-Host "============================================="

$buffer = New-Object byte[] 65536

while ($true) {
    if ($listener.Pending()) {
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        
        # Read Request (Basic)
        $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
        $requestData = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $bytesRead)
        
        # Parse GET /path
        if ($requestData -match "GET (.*?) HTTP") {
            $urlPath = $matches[1]
            
            # Simple manual split
            $idx = $urlPath.IndexOf("?")
            if ($idx -ge 0) {
                $urlPath = $urlPath.Substring(0, $idx)
            }
            
            if ($urlPath -eq "/") { $urlPath = "/index.html" }
            
            # Sanitize path
            $urlPath = $urlPath -replace "/", "\"
            $localPath = "$path$urlPath"
            
            if (Test-Path $localPath -PathType Leaf) {
                $content = [System.IO.File]::ReadAllBytes($localPath)
                $ext = [System.IO.Path]::GetExtension($localPath).ToLower()
                
                $contentType = switch ($ext) {
                    ".html" { "text/html; charset=utf-8" }
                    ".js"   { "application/javascript" }
                    ".css"  { "text/css" }
                    ".json" { "application/json" }
                    ".svg"  { "image/svg+xml" }
                    ".ico"  { "image/x-icon" }
                    Default { "application/octet-stream" }
                }
                
                $header = "HTTP/1.1 200 OK`r`n" +
                          "Content-Type: $contentType`r`n" +
                          "Content-Length: $($content.Length)`r`n" +
                          "Connection: close`r`n`r`n"
                          
                $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
                $stream.Write($headerBytes, 0, $headerBytes.Length)
                $stream.Write($content, 0, $content.Length)
            } else {
                $header = "HTTP/1.1 404 Not Found`r`nContent-Length: 0`r`nConnection: close`r`n`r`n"
                $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
                $stream.Write($headerBytes, 0, $headerBytes.Length)
            }
        }
        $stream.Close()
        $client.Close()
    } else {
        Start-Sleep -Milliseconds 10
    }
}
