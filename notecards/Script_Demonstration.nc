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
@echo for a ride.  We'll start in ten seconds.
script pause 10
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

script pause 5

@echo Tesseract includes a programmable menu system that allows
@echo you to define menus that allow users to interact with the model.
@echo The standard Commander menu lets you manipulate the model
@echo in a variety of ways just by pressing buttons, with no need to
@echo enter commands in chat.  You can launch Commander at any
@echo time with the chat comand:
@echo     /1888 script run Commander
@echo Give it a try!

script run Commander

script pause 1
rotate reset

@echo This concludes the demonstration.  To explore further and learn
@echo how to create your own scripts and menus, see the User Guide
@echo by typing:
@echo       /1888 help
@echo in chat.
