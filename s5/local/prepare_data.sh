#!/usr/bin/env bash
# Copyright 2015-2016  Sarah Flora Juan
# Copyright 2016  Johns Hopkins University (Author: Yenda Trmal)
# Copyright 2018  Yuan-Fu Liao, National Taipei University of Technology
#                 AsusTek Computer Inc. (Author: Alex Hung)

# Apache 2.0

set -e -o pipefail

# train_dir=condenser/wav
train_dir=/share/corpus/TAT-Vol1-train-lavalier/wav
test_dir=/share/corpus/TAT-Vol1-dryrun-lavalier/wav
train_txt=/share/corpus/TAT-Vol1-train-lavalier/json
test_txt=/share/corpus/TAT-Vol1-dryrun-lavalier/json


. ./path.sh
. parse_options.sh

for x in $train_dir; do
  if [ ! -d "$x" ] ; then
    echo >&2 "The directory $x does not exist"
  fi
done

if [ -z "$(command -v dos2unix 2>/dev/null)" ]; then
    echo "dos2unix not found on PATH. Please install it manually."
    exit 1;
fi

# have to remove previous files to avoid filtering speakers according to cmvn.scp and feats.scp
# rm -rf   data/all data/all1 data/train data/test data/eval data/local/train
# mkdir -p data/all data/all1 data/train data/test data/eval data/local/train


# make utt2spk, wav.scp and text
echo "prepare text"
# python3 text_prepare_tailo.py
# mv text data/all/text
# cp train_text data/train/text
echo "prepare utt2spk"
find -L $train_dir -name *.wav -exec sh -c 'x={}; y=$(basename -s .wav $x); z=$(echo "$x" |cut -d / -f 6); printf "%s_%s %s\n" $z $y $z' \; | sed 's/\xe3\x80\x80\|\xc2\xa0//g' | dos2unix > data/train/utt2spk
echo "prepare wav.scp"
find -L $train_dir -name *.wav -exec sh -c 'x={}; y=$(basename -s .wav $x); z=$(echo "$x" |cut -d / -f 6); printf "%s_%s %s\n" $z $y $x' \; | sed 's/\xe3\x80\x80\|\xc2\xa0//g' | dos2unix > data/train/wav.scp

# fix_data_dir.sh fixes common mistakes (unsorted entries in wav.scp, duplicate entries and so on). 
# Also, it regenerates the spk2utt from utt2spk
# utils/fix_data_dir.sh data/all
utils/fix_data_dir.sh data/train


echo "prepare text"
#python3 text_prepare_pilot.py $test_txt
# cp test_text data/test/text
echo "prepare utt2spk"
find -L $test_dir -name *.wav -exec sh -c 'x={}; y=$(basename -s .wav $x); z=$(echo "$x" |cut -d / -f 6); printf "%s %s\n" $y $y' \; | sed 's/\xe3\x80x80\|\xc2\xa0//g' | dos2unix > data/test/utt2spk
echo "prepare wav.scp"
find -L $test_dir -name *.wav -exec sh -c 'x={}; y=$(basename -s .wav $x); z=$(echo "$x" |cut -d / -f 6); printf "%s %s\n" $y $x' \; | sed 's/\xe3\x80\x80\|\xc2\xa0//g' | dos2unix > data/test/wav.scp
utils/fix_data_dir.sh data/test



# echo "Preparing train,eval and test data"
# # eval set:IU_IUF0008 IU_IUM0012 KK_KKM0001 KH_KHF0008 IU_IUF0005 TS_TSF0017 IU_IUM0009 KK_KKM0006
# grep -E "(IU_IUF0008|IU_IUM0012|KK_KKM0001|KH_KHF0008|IU_IUF0005|TS_TSF0017|IU_IUM0009|KK_KKM0006)" data/all/utt2spk | awk '{print $2}' > data/all/cv1.spk
# utils/subset_data_dir_tr_cv.sh --cv-spk-list data/all/cv1.spk data/all data/all1 data/eval
# # test set:TA_TAM0001 IU_IUF0013 KH_KHF0003 IU_IUM0014 TH_THF0021 TH_THM0011 TH_THF0005 KK_KKF0013
# grep -E "(TA_TAM0001|IU_IUF0013|KH_KHF0003|IU_IUM0014|TH_THF0021|TH_THM0011|TH_THF0005|KK_KKF0013)" data/all/utt2spk | awk '{print $2}' > data/all/cv2.spk
# utils/subset_data_dir_tr_cv.sh --cv-spk-list data/all/cv2.spk data/all1 data/train data/test

if [ ! -d data/local/train ]; then
  mkdir -p data/local/train
fi

# for LM training
echo "cp data/train/text data/local/train/text for language model training"
cat data/train/text | awk '{$1=""}1;' | awk '{$1=$1}1;' > data/local/train/text

echo "Data preparation completed."
exit 0;
