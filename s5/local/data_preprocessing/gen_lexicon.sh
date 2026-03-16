#!/bin/bash

# Check for minimum arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <dict_dir> <file1> [file2 ...]"
    exit 1
fi

dict_dir=$1
shift
input_files=$@

mkdir -p "$dict_dir"

echo "Filtering files: $input_files"

# 1. Extraction and Strict Filtering
# - awk '{$1=""; print $0}': Remove Utterance ID
# - tr ' ' '\n': One word per line
# - grep -E '^[a-z]+[1-9]$': 
#     ^     : Start of string
#     [a-z]+: One or more LOWERCASE letters (Filters out 'Keyboard', 'A092')
#     [1-9] : Exactly one digit at the end
#     $     : End of string
cat $input_files | \
    awk '{$1=""; print $0}' | \
    tr ' ' '\n' | \
    sed '/^$/d' | \
    grep -E '^[a-z]+[1-9]$' | \
    sed 's/[0-9]$//g' | \
    sort -u > "$dict_dir/base_syllables.tmp"

# 2. Generate tones 1-9 and splitting rules
awk '
BEGIN {
    split("a e i o u", v, " ");
    for (i in v) is_vowel[v[i]] = 1;
    split("ts kh ph th ng", d, " ");
    for (i in d) is_double_cons[d[i]] = 1;
}
{
    base = $1;
    for (i=1; i<=9; i++) {
        syllable = base i;
        char1 = substr(base, 1, 1);
        char2 = substr(base, 1, 2);

        if (is_vowel[char1]) {
            printf("%s\t%s\n", syllable, syllable);
        } else if (is_double_cons[char2]) {
            printf("%s\t%s %s\n", syllable, char2, substr(syllable, 3));
        } else {
            printf("%s\t%s %s\n", syllable, char1, substr(syllable, 2));
        }
    }
}' "$dict_dir/base_syllables.tmp" > "$dict_dir/lexicon.txt"

rm "$dict_dir/base_syllables.tmp"

echo "Success! Cleaned lexicon saved to $dict_dir/lexicon.txt"
