
#  Main

menu begin Main "Choose command family menu"
menu button Model "menu show Model"
menu button Rotate "menu show Rotate"
menu button Spin "menu show Spin"
menu button View "menu show View"
menu button Exit
menu button "*Timeout*" "echo Menu timed out."
menu end

#   Rotate

script set ang "30"
script set sign "+"

menu begin Rotate "Rotations in all six planes"
menu button "xy" "rotate xy {sign}{ang}" "menu show Rotate"
menu button "xz" "rotate xz {sign}{ang}" "menu show Rotate"
menu button "xw" "rotate xw {sign}{ang}" "menu show Rotate"
menu button "yz" "rotate yz {sign}{ang}" "menu show Rotate"
menu button "yw" "rotate yw {sign}{ang}" "menu show Rotate"
menu button "zw" "rotate zw {sign}{ang}" "menu show Rotate"
menu button "15°" "script set ang 15" "menu show Rotate"
menu button "30°" "script set ang 30" "menu show Rotate"
menu button "+" "script set sign +" "menu show Rotate"
menu button "−" "script set sign -" "menu show Rotate"
menu button Reset "rotate reset" "Menu show Rotate "
menu button Main "Menu show Main"
menu button "*Timeout*" "echo Menu timed out."
menu end

#   Spin

script set rate 5

menu begin Spin "Spins around one or more planes"
menu button "xy" "rotate xy {sign}{rate} animate" "menu show Spin"
menu button "xz" "rotate xz {sign}{rate} animate" "menu show Spin"
menu button "xw" "rotate xw {sign}{rate} animate" "menu show Spin"
menu button "yz" "rotate yz {sign}{rate} animate" "menu show Spin"
menu button "yw" "rotate yw {sign}{rate} animate" "menu show Spin"
menu button "zw" "rotate zw {sign}{rate} animate" "menu show Spin"
menu button "Spin once" "run 72 steps" "menu show Spin"
menu button "Spin 5×" "run 360 steps" "menu show Spin"
menu button "+" "script set sign +" "menu show Spin"
menu button "−" "script set sign -" "menu show Spin"
menu button Reset "rotate reset" "Menu show Spin "
menu button Main "Menu show Main"
menu button "*Timeout*" "echo Menu timed out."
menu end

#   Model

menu begin Model "Select four-dimensional model"
menu button "5-cell" "set model 5-cell" "menu show Model"
menu button "8-cell" "set model 8-cell" "menu show Model"
menu button "16-cell" "set model 16-cell" "menu show Model"
menu button "24-cell" "set model 24-cell" "menu show Model"
menu button Main "Menu show Main"
menu end

#   View

menu begin View "Set viewing parameters"
menu button Perspective "set projection perspective" "menu show View "
menu button Parallel "set projection parallel" "menu show View "
menu button "Smaller" "set scale 0.8x auto" "menu show View "
menu button "Scale 1" "set scale 1 auto" "menu show View "
menu button "Bigger" "set scale 1.25x auto" "menu show View "
menu button "Spin on" "spin 30"  "menu show View "
menu button "Spin off" "spin 0"  "menu show View "
menu button Reset "rotate reset" "set projection perspective" "set scale 1" "spin 0" "menu show View "
menu button Main "menu show Main"
menu button "*Timeout*" "echo Menu timed out."
menu end

menu show Main

script set *
set scale 1

@echo Exiting Commander
