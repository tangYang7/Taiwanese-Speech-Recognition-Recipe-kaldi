# TO export the final kaldi ASR model folder
# setting dir
stage=1

ori_model_dir=exp/chain/tdnn_1d_sp
ori_extractor_dir=exp/nnet3/extractor
ori_data_dict=data/local/dict
ori_data_lang=data/lang
ori_data_config=conf


big_dir=models/TAT-MOE_tdnn_1d_sp
model_dir=$big_dir

# stage 0: copy model files
if [ $stage -le 0 ]; then
    echo "$0: make model_dir and copy model files"

    mkdir -p $model_dir
    cp -r $ori_model_dir $model_dir/model
    cp -r $ori_extractor_dir $model_dir/extractor
    cp -r $ori_data_dict $model_dir/data/local/dict
    cp -r $ori_data_lang $model_dir/data/lang
    cp -r $ori_data_config $model_dir/conf
    echo "$0: model files are copied to $model_dir"
fi

# tidy up the dir
if [ $stage -le 1 ]; then
    echo "$0: tidy up the model dir"

    unnecessary_files=(
        *0.mdl
        *0.raw
        accuracy.report
        cache.*
        decode_test
        egs 
        log
        0.trans_mdl
        1925.mdl
        1926.mdl
    )
    # remove unnecessary files to reduce size
    for file_pattern in "${unnecessary_files[@]}"; do
        find $model_dir -name "$file_pattern" -exec rm -rf {} +
    done

    echo "$0: tidy up the extractor dir"

    unnecessary_extractor_files=(
        backup*
        log
    )
    for file_pattern in "${unnecessary_extractor_files[@]}"; do
        find $model_dir/extractor -name "$file_pattern" -exec rm -rf {} +
    done

    echo "$0: model dir is tidied up"
fi
