
                                Fourmilab Tesseract
                                      Edge Factory

                                       User Guide

The Fourmilab Tesseract model is linked with 32 edge sub-objects which
serve as the wire frame edges of the 4D object projected into 3-space.
(The Tesseract model uses all 32 edges; the other models use fewer,
hiding the unused edges.)  Each edge object contains an identical
script which identifies which edge it is from the name of the prim (for
example "Edge11").  If you want to make a change in the edge script, it
would be very tedious to have to edit all of the 32 edges and replace
the script in every one with the updated version.  To avoid this, the
Edge Factory allows updating the edge objects in bulk.

Let's assume you've made an update to the Edge script, tested it on one
or a few edges, and now wish to deploy it to all edges in the model.
Proceed as follows.

    1.  Rez a copy of the Edge Factory from your inventory into the
         world near the instance of Tesseract you want to update.

    2.  Edit the Edge Factory object and rez the Edge object from its
         inventory by dragging it to a location near the Edge Factory.
         It will appear as a narrow red cylinder named "Edge".

    3.  Edit the Edge object and replace the script in its inventory
         named Edge with your updated version.

    4.  Take the updated Edge object into inventory, then replace the
         Edge object in the Edge Factory with that new version.

Now we're ready to generate the edges to replace those in the Tesseract
model.

    5.  Send the chat command to Edge Factory to create the replacement
         edges:
             /1889 Build 32
         There are always 32 edges in the Tesseract object, to
         accommodate the maximum number of edges in 4D models it
         supports.  An array of 32 red vertical edges will be created
         in an array of four columns of eight rows.

Proceed with replacing the edges in the Tesseract model.

    6.  Edit the Tesseract model, select "Edit linked", and select the
        controller (small cube at the centre), which is link number 1.

    7.  Press "Unlink" to unlink the controller from the existing edges.
         Exit Edit mode.

    8.  Right click anywhere on the now-unlinked edges and delete them.
        Since they remain linked, "they'll all go together when they go".

    9.  Select the 32 new edges by editing one of them and then use a
         box selection to select them all.  Now hold down the shift key
         and add the controller to the selection and press "Link".  You
         now have an object with the 32 new edges linked to the
         controller as the root prim.

   10.  Reset the controller and tell it to find and initialise the new
         edges with:
             /1888 Boot

You should now be running with the new edges.

This may seem a fussy and intricate procedure, but it takes less time
to do than to read the instructions the first time, and it's much less
time consuming and error prone than individually updating a script in
32 links of an object.
