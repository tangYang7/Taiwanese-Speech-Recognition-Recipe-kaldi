# Taiwanese-Speech-Recognition-Recipe-kaldi
# run Kaldi

## 1. Clone and Install

- Clone the Kaldi repository from GitHub:
  ```bash
  git clone https://github.com/kaldi-asr/kaldi.git
  ```
- Follow the official installation instructions in kaldi/INSTALL


- To enable GPU support, navigate to the src directory and configure with CUDA:
    ```bash
    cd kaldi/src
    ./configure --use-cuda=yes
    ```

- Make sure that CUDA is successfully detected during configuration. GPU acceleration in Kaldi requires CUDA support.

## 2. (optional) Check and Update the lexicon in s5/language
- Prepare dataset to generate kaldi-sytle data, and set your `audio_root`, `json_root`, and `out_dir` in main.py
    ```bash
    cd s5
    python main.py
    ```

- run `gen_lexicon.sh` or `update_lexicon.sh` for dataset lexicon, `out_dir = "../test_data"` in `main.py` for example
    ```bash
    cd s5
    # Usage: $0 <source_dir> <dict_dir> <file1> [file2 ...] 
    ./local/data_preprocessing/update_lexicon.sh language <new_lexicon_root> ../test_data/train ../test_data/test
    ```

- Use the new_lexicon_root for lexicon
    ```bash
    cd s5
    ./update_lexicon.sh language <new_lexicon_root> ../test_data/train ../test_data/test
    mv language ori_language
    mv <new_lexicon_root> language 
    ```

## 3. Run
    ```bash
    # Run from stage -2 to final stage
    ./run.sh
    ```
