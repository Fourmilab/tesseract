#
#               Demonstration script
#
rotate reset
set scale 1
set model 8
@echo Fourmilab Tesseract shows three of the regular
@echo four-dimensional polytopes.  The first is the
@echo tesseract, also called hypercube and 8-cell.
script pause 2
rotate xw 5 animate
run 10
rotate reset
@echo The second is the pentachoron or 5-cell, the
@echo four-dimensional analogue of the tetrahedron
@echo in three dimensions.
set model 5
set scale 1.5
script pause 2
rotate xw 5 animate
run 10
rotate reset
@echo The third is the hexadecachoron or 16-cell, the
@echo four-dimensional analogue of the octahedron in
@echo three dimensions.
set model 16
set scale 2
script pause 2
rotate xw 5 animate
rotate zw 5 animate
run 10
rotate reset
set scale 1

set model 8
rotate reset

@echo You can rotate the 4D model around any of the
@echo six planes of rotation in four dimensions.  The
@echo four axes are called X, Y, Z, and W, and a plane
@echo is defined by two axes, for example X-Y or Z-W.
@echo
@echo    X-Y plane
rotate xy 5 animate
run 10
rotate reset
@echo
@echo    X-Z plane
rotate xz 5 animate
run 10
rotate reset
@echo
@echo    X-W plane
rotate xw 5 animate
run 10
rotate reset
@echo
@echo    Y-Z plane
rotate yz 5 animate
run 10
rotate reset
@echo
@echo    Y-W plane
rotate yw 5 animate
run 10
rotate reset
@echo
@echo    Z-W plane
rotate zw 5 animate
run 10
rotate reset

@echo You can combine rotations around multiple
@echo planes and different speeds to create
@echo tumbling effects.
rotate xw 5 animate
rotate yw -5 animate
rotate zw 5 animate
rotate xz 5 animate
run 10
rotate reset

@echo You can project the model from four dimensions
@echo to three dimensions in either perspective or
@echo orthographic (parallel) projection.  Here is the
@echo tumbling hypercube we've just seen in perspective
@echo shown in orthographic projection.
set projection orthographic
set scale 0.5
rotate xw 5 animate
rotate yw -5 animate
rotate zw 5 animate
rotate xz 5 animate
run 10
rotate reset
set projection perspective
set scale 1

@echo Avatars may sit on any of the edges of the model
@echo and ride it as the model rotates in four dimensions.
@echo Multiple avatars can ride simultaneously, one per
@echo edge.  Try sitting on one of the edges and we'll go
@echo for a ride.  We'll start in five seconds.
script pause 5
@echo And here we go!
rotate xw 5 animate
rotate yw 5 animate
rotate zw 5 animate
rotate xy 5 animate
rotate xz 5 animate
run 25
rotate reset
@echo Wasn't that fun?  Stand up now and back up from the
@echo model to see it better.

script pause 2

@echo Tesseract includes a programmable menu system that allows
@echo you to define menus that allow users to interact with the model.
@echo For example, this menu allows you to rotate the model by 30
@echo degrees around any of the four-dimensional planes.  Press
@echo Exit to leave the menu.

menu begin Rotations "Click to rotate the model around 4D planes"
menu button XY+ "rotate xy 30" "Menu show Rotations"
menu button XZ+ "rotate xz 30" "Menu show Rotations"
menu button XW+ "rotate xw 30" "Menu show Rotations"
menu button YZ+ "rotate yz 30" "Menu show Rotations"
menu button YW+ "rotate yw 30" "Menu show Rotations "
menu button ZW+ "rotate zw 30" "Menu show Rotations "
menu button Reset "rotate reset" "Menu show Rotations "
menu button Exit
menu button "*Timeout*" "echo Menu timed out."
menu end

menu show Rotations

script pause 1
rotate reset

@echo This concludes the demonstration.  To explore further and learn
@echo how to create your own scripts and menus, see the User Guide
@echo by typing:
@echo       /1888 help
@echo in chat.
