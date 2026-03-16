# To generate kaldi data files (utt2spk, spk2utt, wav.scp, text) 
import os
import json
import re
from collections import defaultdict

def normalize_taiwanese(text: str) -> str:
    """
    將台羅數字調轉成 Kaldi-friendly text
    - 移除標點
    - 保留數字
    """
    # 1. Replace non-alphanumeric with space
    text = re.sub(r"[^a-zA-Z0-9]", " ", text)
    
    # 2. Split into individual tokens
    tokens = text.split()
    
    # 3. Filter tokens: Must be lowercase + end with digit 1-9
    # This regex ensures the word part is lowercase and the last char is a digit.
    valid_tokens = [
        t for t in tokens 
        if re.fullmatch(r"[a-z]+[1-9]", t)
    ]
    
    # 4. Join back with a single space
    return " ".join(valid_tokens)

def make_kaldi_files(audio_root, json_root, out_dir):
    os.makedirs(out_dir, exist_ok=True)

    utt2spk = {}
    text_dict = {}
    wav_scp = {}

    for fname in os.listdir(json_root):
        if not fname.endswith(".json"):
            continue

        utt_id = fname.replace(".json", "")
        spk_id = utt_id.rsplit("-", 1)[0]

        json_path = os.path.join(json_root, fname)
        wav_path = os.path.join(audio_root, f"{utt_id}.wav")

        if not os.path.exists(wav_path):
            print(f"[WARN] wav not found: {wav_path}")
            continue

        with open(json_path, "r", encoding="utf-8") as f:
            meta = json.load(f)

        raw_text = meta.get("台羅數字調", "")
        norm_text = normalize_taiwanese(raw_text)

        if not norm_text:
            continue

        utt2spk[utt_id] = spk_id
        text_dict[utt_id] = norm_text
        wav_scp[utt_id] = wav_path

    # === 寫 spk2utt ===
    spk2utt = defaultdict(list)
    for utt_id, spk_id in utt2spk.items():
        spk2utt[spk_id].append(utt_id)

    with open(os.path.join(out_dir, "spk2utt"), "w", encoding="utf-8") as f:
        for spk_id in sorted(spk2utt):
            utts = " ".join(sorted(spk2utt[spk_id]))
            f.write(f"{spk_id} {utts}\n")

    # === 寫 utt2spk, wav.scp, text ===
    for filename, data_dict in [("utt2spk", utt2spk), ("wav.scp", wav_scp), ("text", text_dict)]:
        with open(os.path.join(out_dir, filename), "w", encoding="utf-8") as f:
            for uid in sorted(data_dict):
                f.write(f"{uid} {data_dict[uid]}\n")


    print(f"Done. Files written to {out_dir}")
if __name__ == "__main__":
    audio_root = "../dataset/audio/TAT-MOE-selected"
    json_root = "../dataset/json/TAT-MOE-json-selected"
    # out_dir = "../s5-wtone_nonNULL/data"
    out_dir = "../test_data"

    dataset_type = ["train", "dev", "test"]

    for dtype in dataset_type:
        print(f"Processing {dtype} set...")
        tmp_audio_root = os.path.join(audio_root, dtype)
        tmp_json_root = os.path.join(json_root, dtype)
        tmp_out_dir = os.path.join(out_dir, dtype)

        make_kaldi_files(tmp_audio_root, tmp_json_root, tmp_out_dir)
    print("All done.")
