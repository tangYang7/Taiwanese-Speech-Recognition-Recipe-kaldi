#!/bin/bash

# Check for minimum arguments
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <source_dir> <dict_dir> <file1> [file2 ...]"
    exit 1
fi

source_dir=$1
dict_dir=$2
shift 2
input_files=$@

mkdir -p "$dict_dir"
target_lexicon="$dict_dir/lexicon.txt"
source_lexicon="$source_dir/lexicon.txt"

# 1. Initialize target from source
if [ -f "$source_lexicon" ]; then
    cp "$source_lexicon" "$target_lexicon"
    echo "Using existing lexicon from $source_dir as base."
else
    touch "$target_lexicon"
    echo "No existing lexicon found. Starting fresh."
fi

# 2. Extract current syllables from text files
cat $input_files | \
    awk '{$1=""; print $0}' | tr ' ' '\n' | sed '/^$/d' | \
    grep -E '^[a-z]+[1-9]$' | sed 's/[0-9]$//g' | \
    sort -u > "$dict_dir/current_syllables.tmp"

# 3. Identify ONLY NEW syllables
awk '{print $1}' "$target_lexicon" | sed 's/[0-9]$//g' | sort -u > "$dict_dir/existing_bases.tmp"

# comm -13 picks lines only in the second file (the new ones)
comm -13 "$dict_dir/existing_bases.tmp" "$dict_dir/current_syllables.tmp" > "$dict_dir/new_unique_bases.tmp"

# 4. Print and Process new syllables
if [ -s "$dict_dir/new_unique_bases.tmp" ]; then
    new_count=$(wc -l < "$dict_dir/new_unique_bases.tmp")
    echo "--------------------------------------------------"
    echo "Found $new_count new base syllables:"
    
    # 印出新增的音節 (加上一點縮排方便閱讀)
    cat "$dict_dir/new_unique_bases.tmp" | sed 's/^/  - /'
    
    echo "Generating entries for tones 1-9..."
    echo "--------------------------------------------------"
    
    awk '
    BEGIN {
        split("a e i o u", v, " "); for (i in v) is_vowel[v[i]] = 1;
        split("ts kh ph th ng", d, " "); for (i in d) is_double_cons[d[i]] = 1;
    }
    {
        base = $1;
        for (i=1; i<=9; i++) {
            syllable = base i;
            c1 = substr(base, 1, 1); c2 = substr(base, 1, 2);
            if (is_vowel[c1]) {
                printf("%s %s\n", syllable, syllable);
            } else if (is_double_cons[c2]) {
                printf("%s %s %s\n", syllable, c2, substr(syllable, 3));
            } else {
                printf("%s %s %s\n", syllable, c1, substr(syllable, 2));
            }
        }
    }' "$dict_dir/new_unique_bases.tmp" >> "$target_lexicon"
else
    echo "No new syllables found. Lexicon is already up to date."
fi

# 5. Final Sort and Cleanup
sort -u "$target_lexicon" -o "$target_lexicon"
rm "$dict_dir"/*.tmp

echo "Update complete. Final lexicon: $target_lexicon"
