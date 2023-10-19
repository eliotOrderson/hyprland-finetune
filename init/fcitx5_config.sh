#!/usr/bin/env bash
set -Eeuxo pipefail

# activate clover input method
if [[ ! -f  ~/.local/share/fcitx5/rime/default.custom.yaml ]]; then
cat >> ~/.local/share/fcitx5/rime/default.custom.yaml <<EOF
patch:
  "menu/page_size": 5
  schema_list:
    - schema: clover
EOF
fi

# add chinese dictionary
yay -S fcitx5-pinyin-custom-pinyin-dictionar --noconfirm 
# add theme with dark and light
rm -rf ~/.local/share/fcitx5/themes 
git clone https://github.com/tonyfettes/fcitx5-nord.git ~/.local/share/fcitx5/themes --depth 1 
# restart fcitx5
nohup fcitx5 -r > /dev/null 2>&1 & 
echo "[+] fcitx5 restart complated"
