
                        Fourmilab Tesseract User Guide

Fourmilab Tesseract allows you to view four-dimensional objects such as
the tesseract (hypercube, 4-cube, four-dimensional analogue of the
three dimensional cube) by projecting them from four-dimensional space
into the three-dimensional Second Life world as a wire frame model.
You can project the object in either a perspective or an orthographic
(parallel) projection and, for perspective views, set the viewpoint and
angle of view.  Commands allow you to scale and rotate the object in
four dimensional space around any of the pairs of planes defined by the
four orthogonal axes and smoothly animate rotations in any combination
of planes and speeds.  The object is fully scriptable with commands
supplied in notecards in its inventory and scripts may define pop-up
menus through which an avatar may interact with the model.

REZZING TESSERACT IN-WORLD

To use Fourmilab Tesseract, simply rez the object in-world on land
where you are allowed to create objects (land you own or have permission
to use, or in a public sandbox that supports scripted objects).  The
land impact is 33, consisting of the controller object and the up to 32
edges of the four-dimensional object.  You can create as many models as
you wish, limited only by your parcel's prim capacity.  If you create
multiple objects in proximity to one another, you may want to assign
them different chat channels (see the Channel command below) so you can
control each independently.

An alternative version of Tesseract, called “Mega Tesseract”, is 
included in the distribution.  This is identical to the regular version 
but can display models with as many as 96 edges, which allows it to 
display the 24-cell polytope (“icositetrachoron” or “octaplex”) in 
addition to the three simpler models of the standard version.  This 
comes at the cost of a land impact of 97, so you should only use this 
version if you can spare the land impact and wish to display the 
24-cell model.

WEARING TESSERACT AS A HAT

To wear Fourmilab Tesseract as a hat, just right click “Fourmilab
Tesseract Hat” in your inventory and select Add to your current outfit.
If it shows up attached to something other than your head, detach it
and use the Attach selection specifying Skull as the attachment point.
Depending upon the size and shape of your avatar, you may need to
select the hat and Edit its position to move it up or down on your
head.  Wearing Tesseract can be done anywhere on the Second Life grid
and has no land impact—it does not require permission to create
objects.  The object only requires that the parcel allows scripts to
run, and it is rare to find one that doesn't.

CHAT COMMANDS

Fourmilab Tessseract accepts commands submitted on local chat channel
1888 (the year Charles Hinton coined the word “tesseract” for a
four-dimensional cube in his book “A New Era of Thought”) and responds
in local chat. Commands are as follows.  (Most chat commands and
parameters, except those specifying names from the inventory, may be
abbreviated to as few as two characters and are insensitive to upper
and lower case.)

    Access public/group/owner
        Specifies who can send commands to the object.  You can
        restrict it to the owner only, members of the owner's group, or
        open to the general public.  Default access is by owner.

    Boot
        Reset the script.  All settings will be restored to their
        defaults.  If you have changed the chat command channel, this
        will restore it to the default of 1888.

    Channel n
        Set the channel on which the object listens for commands in
        local chat to channel n.  If you subsequently reset the script
        with the “Boot” command or manually, the chat channel will
        revert to the default of 1888.

    Clear
        Send vertical white space to local chat to separate output when
        debugging.

    Echo text
        Echo the text in local chat.  This allows scripts to send
        messages to those running them to let them know what they're
        doing.

    Help
        Send this notecard to the requester.

    Menu
        These commands allow displaying a custom menu dialogue with
        buttons which, when clicked, cause commands to be executed
        as if entered from chat or a notecard script.

        Menu begin name "Menu text"
            Begins the definition of a menu with the given name.  When
            the menu is displayed, the quoted Menu text will appear at
            the top of the dialogue box.

        Menu button "Label" "Command 1" "Command 2" ...
            Defines a button with the specified label which, when
            clicked, causes the listed commands to be run as if entered
            from chat or submitted by a script.  If the label or
            commands contain spaces, they should be quoted.  Two
            consecutive quote marks may be used to include a quote in
            the label or command.  Due to limitations in Second Life's
            dialogue system, a maximum of 12 buttons may be defined in
            a menu and button labels can contain no more than 24
            characters.  A button with the label "*Timeout*" will not
            be displayed in the menu but its commands will be run if
            the menu times out after one minute without user response.
            The commands defined for a button may include those
            described below as being used only with scripts, such as
            “Script pause” and “Script loop”.

        Menu delete name
            Deletes a previously defined menu with the specified name.

        Menu end
            Completes the definition of a menu started with “Menu
            begin” and subsequent “Menu button” commands.  You may
            define as many menus as you wish, limited only by available
            memory for the script.

        Menu kill
            Terminates listening for clicks in the currently displayed
            menu.  Second Life provides no way to remove a displayed
            menu from the screen, so it continues to be shown until the
            user closes its window.

        Menu list [ name ]
            If no name is specified, lists the names of defined menu.
            If a name is given, lists the buttons of that menu and
            the commands they run when clicked.

        Menu reset
            Resets the menu system, terminating any active menu and
            deleting all previously-defined menus.

        Menu show name [ continue ]
            Display the named menu and begin listening for clicks on
            the buttons it contains.  Normally, displaying a menu from
            a script causes script execution to pause until the user
            clicks a button in the menu or it times out.  If “continue”
            is specified, script execution will continue while the menu
            is displayed.  The “Menu show” command may be used within
            menu button command lists, allowing complex chaining of
            menus and construction of hierarchical menu systems.

    Rotate plane angle [ animate ]
    Rotate clear
    Rotate reset
        Rotate the four dimensional model about one of the orthogonal
        planes of four dimensional space by the specified angle in
        degrees, optionally animating the rotation in steps of the
        specified angle.  The “reset” option restores the model to its
        original alignment with the axes.

        As many Second Life users and developers have discovered,
        rotations in three dimensions can be confusing and take some
        time and experience before they become intuitive.  (Fourmilab's
        Orientation Cube:
            https://marketplace.secondlife.com/p/Fourmilab-Orientation-Cube/19823081
        may help you in learning how they work.)  In four dimensions,
        however, rotations can be positively bewildering until you wrap
        your mind around it.  One of the best ways is to proceed by
        analogy.  In two dimensions, on a flat surface, you rotate
        around a POINT, which can be anywhere on the surface.  In three
        dimensions, you rotate around a LINE, which can be defined by
        any two non-coincident points in the three dimensional space.
        In four dimensions, you rotate around a PLANE, which is defined
        by three points anywhere in the four-dimensional space.  To
        simplify things, Fourmilab Tesseract only rotates around the
        six planes defined by the four orthogonal axes, which are
        labeled X, Y, Z, and W, with “W” denoting the fourth axis that
        is orthogonal to the familiar three from 3D space.  If we
        consider X as representing East-West, Y as North-South, and Z
        as Up-Down, W is an additional direction orthogonal to each of
        X, Y, and Z, with directions we'll call, after Charles Hinton,
        Ana and Kata.  With these definitions, the six planes about
        which you can rotate the object are named:
            XY      East-West North-South
            XZ      East-West Up-Down
            XW      East-West Ana-Kata
            YZ      North-South Up-Down
            YW      North-South Ana-Kata
            ZW      Up-Down Ana-Kata
        The angle you wish to rotate is specified in degrees.  If you
        do not specify “animate”, the rotation will occur immediately
        and you will see its effect on the projection of the object
        into the 3D Second Life space.  If “animate” is specified, the
        rotation will be added to a list of rotations performed on each
        step when the “Run” command is active.

        The “Rotate reset” command clears the list of animation
        rotations and restores the object to its original orientation
        aligned with the axes.  “Rotate clear” removes animation
        rotations while leaving the orientation of the object
        unchanged.

    Run on/off/time
        Starts or stops an animation in which the object is rotated
        every time tick (see “Set tick” below) by the previously
        specified “Rotate ... animate” commands.  If a number is
        specified instead of “on” or “off”, the animation will run for
        that number of seconds and stop automatically.  Execution of
        commands from a script is suspended while an animation is in
        progress, so you can use timed Run commands in a script to
        demonstrate different rotations.

    Script
        These commands control the running of scripts stored in
        notecards in the inventory of the object.  Commands in scripts
        are identical to those entered in local chat (but, of course,
        are not preceded by a slash and channel number).  Blank lines
        and those beginning with a “#” character are treated as
        comments and ignored.

        Script list
            Print a list of scripts in the inventory.  Only notecards
            whose names begin with “Script: ” are listed and may be
            run.

        Script resume
            Resumes a paused script, whether due to an unexpired timed
            pause or a pause until touched or resumed.

        Script run [ Script Name ]
            Run the specified Script Name.  The name must be specified
            exactly as in the inventory, without the leading “Script: ”.
            Scripts may be nested, so the “Script run” command may
            appear within a script.  Entering “Script run” with no
            script name terminates any running script(s).

            The following commands may be used only within scripts or
            commands defined for Menu buttons.

            Script loop [ n ]
                Begin a loop within the script which will be executed n
                times, or forever if n is omitted.  Loops may be
                nested, and scripts may run other scripts within loops.
                An infinite loop can be terminated by “Script run” with
                no script name or by the “Boot” command.

            Script end
                Marks the end of a “Script loop”.  If the number of
                iterations has been reached, proceeds to the next
                command.  Otherwise, repeats, starting at the top of
                the loop.

            Script pause [ n/touch/region ]
                Pauses execution of the script for n seconds.  If the
                argument is omitted, the script is paused for one
                second.  If “touch” is specified, the script will be
                paused until the object is touched or a “Script resume”
                command is entered from chat.  If “region” is
                specified, the script will be paused until the the user
                wearing the tesseract hat enters a new region.

            Script wait n[unit] [ offset[unit] ]
                Pause the script until the start of the next n units of
                time, where unit may be “s”=seconds, “m”=minutes,
                “h“=hours, or ”d”=days, plus the offset time, similarly
                specified.  This can be used in loops to periodically
                run shows at specified intervals.  For example, the
                following script runs a five minute show once an hour
                at 15 minutes after the hour.
                    Script loop
                        Script wait 1h 15m
                        Run 300
                    Script end

    Set
        Set a variety of parameters.

        Set colour <R, G, B> [ alpha ]
        Set colour axes [ alpha ]
            If an explicit colour is specified as red, green, and blue
            values between 0 and one, with an optional transparency
            value (0 transparent, 1 solid), all edges of the model will
            be that colour.  If “axes” is specified, edges which align
            with the four axes in 4D space are coloured as follows:
                X   Red
                Y   Green
                Z   Blue
                W   Orange
            and edges which do not align with one of the axes will be
            yellow.

        Set diameter
            The edges of the object will be shown as cylinders with the
            specified diameter in metres.

        Set echo on/off
            Controls whether commands entered from local chat or a
            script are echoed to local chat as they are executed.

        Set hide on/off/auto
            Hides or shows the controller box at the centre of the
            model.  If “auto” is specified, the controller will be
            hidden while a Run command is active and reappear when it
            is complete.

        Set model which
            Fourmilab Tesseract can display any of for of the simple
            four-dimensional regular polytopes, not just the tesseract.
            The Set model command selects the model displayed, using
            the names below, with synonyms listed on each line.
                5-cell pentachoron
                8-cell tesseract
                16-cell hexadecachoron
                24-cell icositetrachoron  (“Mega” version only)
            The cells of the 5-cell and 16-cells are tetrahedrons, the
            cells of the 8-cell are cubes, and the cells of the 24-cell
            are octahedrons.  (These are the four simplest 4D regular
            polytopes, the remaining two have, respectively, 720 and
            1300 edges and would have an unacceptably high land impact
            in Second Life and take so long to update in the world and
            display in the viewer that it is impractical to support
            them.  Further, they are so complicated and their
            projections so intricate that there is little insight to be
            had from viewing them.)  The 24-cell model, which has 96
            edges, can only be displayed by the “Mega” version of
            Tesseract.  This version is included, but since it has a
            land impact of 97, can only be used on land with the
            capacity for such complex objects.

        Set name Name of object
            Sets the name of the object to the specified text, which
            may contain upper and lower case letters and spaces.  This
            allows configuration scripts to rename the generic object
            to a specific name for that configuration.

        Set position <X, Y, Z>
            Specifies the offset of the model in 3D Second Life space
            from the controller box.  By default, this is zero, but
            since the controller is what is attached to an avatar, when
            you're wearing Tesseract as a hat, you can set the position
            so the model is shown at the distance you wish above your
            head.

        Set projection parallel/perspective
            Sets the type of projection used from the four-dimensional
            model to Second Life three-dimensional space.  If
            “perspective” (the default), objects will appear smaller
            as their distance from the “Set view from” point increases.
            In a parallel projection, objects appear the same size
            regardless of their distance from the view point.  Usually,
            perspective projection provides a better intuitive view of
            the structure of a 4D object, as it corresponds to the way
            three-dimensional objects are represented on the printed
            page and computer screens.

        Set scale n
            Set the scale factor used when projecting the 4D model to
            3D space.  The default scale factor is 1; adjust the scale
            to make the 3D projection the size you wish.  The scale
            factor only affects the length of the edges, not their
            diameter; adjust “Set diameter” appropriately to get the
            effect you wish.

        Set tick n
            Sets the time in seconds between animation steps when the
            Run command is active.  For smooth animation, try a setting
            of 0.1 (a tenth of a second) or a little smaller.  If you
            have specified animated rotations of 5 degrees, this will
            result in the rotation proceeding at a rate of 50 degrees
            per second, or about 8 revolutions per minute.

        Set trace on/off
            Enable or disable output, sent to the owner on local chat,
            describing operations as they occur.  This is generally
            only of interest to developers.

        Set view angle degrees
        Set view from <X, Y, Z, W>
            In a perspective projection, the “Set view” commands
            specify the viewpoint (eye position) in four dimensional
            space from which the projection is made and the view angle.
            By default, the view from point is <0, 0, 0, 3>, looking
            toward the origin from 3 Ana along the W axis with a view
            angle of 90°.

    Spin rate [ <X, Y, Z> ]
        Locally spin the 3D projection around the specified axis in
        Second Life space, by default, the <0, 0, 1> vertical axis, at
        the rate specified in degrees per second.  A rate of 0 cancels
        the spin and restores the model to the default orientation.
        Simultaneously rotating the model with the Run command and
        spinning its 3D projection can be confusing, but if you want to
        do it for artistic effect, go right ahead.

    Status
        Show status of the model, including settings and memory usage.

CONFIGURATION NOTECARD

When Tesseract is initially rezzed or reset with the Boot command, if
there is a notecard in its inventory named “Script: Configuration”, the
commands it contains will be executed as if entered via local chat (do
not specify the chat channel on the script lines).  This allows you to
automatically preset preferences as you like.

TOUCH NOTECARD

If a notecard named “Script: Touch” is present in the inventory of the
Tesseract object, the script will be run when the object is touched.
If you use this feature (for example, to make it easy for visitors to
run a demonstration script), don't use the “Script pause touch”
command in any of your scripts, as the two uses of touch will conflict
and result in confusion.

PERMISSIONS AND THE DEVELOPMENT KIT

Fourmilab Tesseract is delivered with “full permissions”.  Every part
of the object, including the script, may be copied, modified, and
transferred subject only to the license below.  If you find a bug and
fix it, or add a feature, please let me know so I can include it for
others to use.  The distribution includes a “Development Kit”
directory, which includes all of the components of the model (for
example, textures and the tools used to build the edges of the 3D
projection).

The Development Kit directory contains a Logs subdirectory which
includes the development narratives for the project.  If you wonder
“Why does it work that way?” the answer may be there.

Source code for this project is maintained on and available from the
GitHub repository:
    https://github.com/Fourmilab/tesseract

LICENSE

This product (software, documents, and models) is licensed under a
Creative Commons Attribution-ShareAlike 4.0 International License.
    http://creativecommons.org/licenses/by-sa/4.0/
    https://creativecommons.org/licenses/by-sa/4.0/legalcode
You are free to copy and redistribute this material in any medium or
format, and to remix, transform, and build upon the material for any
purpose, including commercially.  You must give credit, provide a link
to the license, and indicate if changes were made.  If you remix,
transform, or build upon this material, you must distribute your
contributions under the same license as the original.