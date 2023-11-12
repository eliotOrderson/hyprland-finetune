#!/usr/bin/env python3
import argparse
import os

def exec_command(cmd):
    os.system(cmd)
    print('Done!')


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--set-alacritty-font-size",default=None, type=int, help="set all theme alacritty font size" )
    parser.add_argument("--fix-polybar-click-event", default=None, type=bool, help="fix polybar click event bug in bspwm")
    parser.add_argument("--set-24hours",default=None ,type=int, help="set polybar date to 24 hours")

    args = parser.parse_args()
    if args.set_alacritty_font_size:
        exec_command(f"find $HOME/.config/bspwm -type f -name Theme.sh -exec sed -i 's/size: [0-9]\+/size: {args.set_alacritty_font_size}/g' {{}} \;")

    if args.fix_polybar_click_event:
        exec_command("find $HOME/.config/bspwm -type f -name config.ini -exec sed -i '/wm-restack = bspwm/d' {} \;")

    if args.set_24hours is not None:
        if args.set_24hours >= 1:
            exec_command("find $HOME/.config/bspwm -type f -name modules.ini -exec sed -i 's/time =.*/time = \"%H:%M %P\"/g' {} \;")
        else:
            exec_command("find $HOME/.config/bspwm -type f -name modules.ini -exec sed -i 's/time =.*/time = \"%I:%M %P\"/g' {} \;")