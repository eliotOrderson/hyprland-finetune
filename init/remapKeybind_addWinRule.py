#!/usr/bin/env python
import os

windowoperation='~/.config/hypr/scripts/windowoperation.sh'

remap={
    '$browser = firefox'                             : '$browser = google-chrome-stable',
    '$mainMod, T, exec, $term'                       : '$mainMod, Return, exec, $term',
    '$mainMod, A, exec, pkill rofi'                  : '$mainMod, D, exec, pkill rofi',
    'bind = $mainMod, C, exec, $editor # open vscode': '',
    '$mainMod, F, exec, $browser'                    : f'$mainMod, C, exec, {windowoperation} -c Google-chrome -e $browser -w 8 -m "goto"',
    'ALT, return, fullscreen'                        : '$mainMod, F, fullscreen',
}

custom_keys = f"""
# swap window
bind = $mainMod CTRL,right,exec, hyprctl dispatch swapwindow r
bind = $mainMod CTRL,left,exec, hyprctl dispatch swapwindow l
bind = $mainMod CTRL,up,exec, hyprctl dispatch swapwindow u
bind = $mainMod CTRL,down,exec, hyprctl dispatch swapwindow d

# mainMod + \ open float kitty terminal on center
bind = $mainMod,code:51,exec,[centerwindow 1] {windowoperation} -c 'floatkitty' -e "kitty --class floatkitty" -w 66

# hide window
bind = $mainMod,H,exec,{windowoperation} h

# show hide window
bind = $mainMod,I,exec,{windowoperation} s

exec-once = ~/.config/hypr/scripts/autostart.sh # auto start app
"""

home = os.environ['HOME']
with open(f'{home}/.config/hypr/keybindings.conf','r+') as file:
    text = file.read()
    for k,v in remap.items():
        text = text.replace(k,v)

    if custom_keys  not in text:
        text += custom_keys
    file.seek(0)
    file.write(text)
    file.close()


custom_rules = """

windowrulev2 = float,class:^(floatkitty)$

windowrulev2 = opacity 0.70 0.70,class:^(floatkitty)$
windowrulev2 = opacity 0.70 0.70,class:^(Google-chrome)$

windowrulev2 = size 80% 80%,class:^(floatkitty)$
windowrulev2 = workspace 8,class:^(Google-chrome)$

"""

with open(f'{home}/.config/hypr/windowrules.conf','r+') as file:
     text = file.read()
     if custom_rules  not in text:
        text += custom_rules
        file.write(text)
     file.close()
