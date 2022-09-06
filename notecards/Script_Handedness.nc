
#   Demonstration: changing handedness of a 3D object by
#   rotating in the fourth dimension.

@Set hide on
@Rotate reset
@Set model custom begin
@Set model custom vertices <0.4, 0.5, 0, 0> <-0.4, 0.5, 0, 0> <-0.6, -0.5, 0, 0>
@Set model custom vertices <0.6, -0.5, 0, 0> <0.375, -0.5, 0, 0>
@Set model custom vertices <0.375, -1.4, 0, 0> <0.125, -0.5, 0, 0>
@Set model custom vertices <0.125, -1.6, 0, 0> <-0.125, -0.5, 0, 0>
@Set model custom vertices <-0.125, -1.45, 0, 0> <-0.375, -0.5, 0, 0>
@Set model custom vertices <-0.375, -1.25, 0, 0> <0.43, 0.35, 0, 0>
@Set model custom vertices <0.7, -0.5, 0.25, 0>
@Set model custom edges 0 1  1 2  2 3  3 0  4 5  6 7  8 9  10 11  12 13
@Set model custom colours 0 1 0 1 1 1 1 1 1
@Set model custom end

@clear

@echo This script demonstrates how the "handedness" or "chirality" of
@echo a three-dimensional object may be changed by rotating it though
@echo the fourth dimension.  We start with a crude model of a human
@echo right hand.  The thumb, on the left side of the hand, points
@echo downward on a slant, while the body of the hand and other
@echo four fingers are in the X-Y plane.

@script pause 10

@echo
@echo As long as you are restricted to rotations within three-dimensional
@echo space, there is no way to transform this into a left hand, which
@echo would be its image reflected in a mirror in the X-Z plane.

@script pause 5

@echo
@echo Let's try some 3D rotations and see what happens.

@script pause 3

@echo
@echo Rotate around Z axis

rotate xy 5 animate
run 72 steps

@script pause 3

@echo
@echo Nope.  That just pointed the right hand in different directions.

@script pause 3

@echo
@echo Rotate around Y axis

rotate clear
rotate xz 5 animate
run 36 steps

@script pause 3

@echo
@echo Well, now the thumb is on the right and the fingers have the
@echo length pattern of a left hand, but the thumb points up and
@echo all we've done is turn the right hand over and look at
@echo its palm, not change it into a left hand.

@script pause 7

@rotate reset

@echo
@echo No matter what you try, in three dimensions, you can't
@echo change the handedness of a hand.

@script pause 3

@echo
@echo But what if you could "pick up" the hand into the fourth
@echo dimension, "turn it over", and put it back into the third
@echo dimension?

@script pause 3

@echo
@echo Let's rotate through hand through 180 degrees around
@echo the X-W plane in the fourth dimension, where W is the
@echo 4D axis orthogonal to the X, Y, and Z axes of 3D space.

@script pause 3

@echo
@echo Rotate around X-W plane

rotate clear
rotate xw 5 animate
run 36 steps

@script pause 3

@echo
@echo Success!  It's now a left hand.  But we could do that only by
@echo using the fourth dimension.

@script pause 5

@echo
@echo Now let's turn it back into a right hand by rotating 180
@echo degrees in the four dimensional Y-W plane.  This will
@echo leave the fingers pointing the other way, so we'll then
@echo rotate in 3D around the Z axis to restore the original
@echo orientation.

@script pause 5

@echo
@echo Rotate around YW plane in 4D

rotate clear
rotate yw 5 animate
run 36 steps

@script pause 3

@echo
@echo Rotate around Z axis in 3D

rotate clear
rotate xy 5 animate
run 36 steps

@script pause 3

@echo
@echo We now have the right hand back in its original orientation.

@script pause 5
@rotate reset

@echo
@echo Now try experimenting with rotations from the menu.
@echo Pressing Reset will restore the original orientation
@echo and Exit quits this script.

@menu begin Rotate "Click to rotate the model 30° around 4D planes"
@menu button XY+ "rotate xy 30" "Menu show Rotate"
@menu button XZ+ "rotate xz 30" "Menu show Rotate"
@menu button XW+ "rotate xw 30" "Menu show Rotate"
@menu button YZ+ "rotate yz 30" "Menu show Rotate"
@menu button YW+ "rotate yw 30" "Menu show Rotate "
@menu button ZW+ "rotate zw 30" "Menu show Rotate "
@menu button Reset "rotate reset" "Menu show Rotate "
@menu button Exit
@menu button "*Timeout*" "echo Menu timed out."
@menu end

@menu show Rotate

@menu delete Rotate

@rotate reset
@echo That's it.  Have fun in the fourth dimension!
