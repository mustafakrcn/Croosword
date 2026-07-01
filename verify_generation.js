import { wordPoolEnglish } from './src/word_pool_english.js';
import { wordPool } from './src/word_pool.js';

function checkDuplicates(pool, name) {
    console.log(`Checking ${name} (${pool.length} items)...`);
    const seen = new Map();
    let dups = 0;
    pool.forEach((item, index) => {
        if (seen.has(item.word)) {
            console.log(`[${name}] Duplicate found: "${item.word}" at indices ${seen.get(item.word)} and ${index}`);
            dups++;
        } else {
            seen.set(item.word, index);
        }
    });
    console.log(`[${name}] Total duplications: ${dups}`);
    return pool.length / 8; // Approx levels
}

const engLevels = checkDuplicates(wordPoolEnglish, "English Pool");
const mixedLevels = checkDuplicates(wordPool, "Mixed Pool");

console.log(`\nEstimated Max Levels (English): ~${Math.floor(engLevels)}`);
console.log(`Estimated Max Levels (Mixed): ~${Math.floor(mixedLevels)}`);

