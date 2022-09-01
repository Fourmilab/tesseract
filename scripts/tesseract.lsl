    /*

                        Fourmilab Tesseract

               Three dimensions aren't enough any more.

        While reading this code, it is important to note that we
        use the LSL "rotation" data type as a general 4-vector
        or co-ordinates of a point in four-dimensional space, not
        as a quaternion representing a rotation in three-dimensional
        space as it is interpreted by the Second Life API and LSL
        library functions.  We simple use the rotation's .x, .y.,
        .z., and .s elements to represent the four co-ordinates in
        4D space, with .s containing the W axis co-ordinate.  As it
        happens, we can add and subtract these values with the
        expected results, but using them with operators like * and
        / will produce meangless results.  Thus, when you see
        something declared as a rotation, interpret that to mean
        four_vector or four_point.

        Four dimensional transformations are represented as 4x4
        matrices, which we define as lists in of rotations, with
        the rotations representing the rows of the matrix and the
        list elements the columns.  The matload() and matstore()
        functions provide access to individual elements of such
        matrices.

        To understand the projection of objects in 4D space to the
        3D world of Second Life, see Steven Richard Hollasch's 1991
        thesis, "Four-Space Visualization of 4D Objects", which is
        available at:
            https://hollasch.github.io/ray4/Four-Space_Visualization_of_4D_Objects.html

    */

    key owner;                          // Owner UUID

    integer commandChannel = 1888;      /* Command channel in chat
                                           First reference to the word "tesseract" in
                                           Charles Hinton's "A New Era of Thought" */
    integer commandH;                   // Handle for command channel
    key whoDat = NULL_KEY;              // Avatar who sent command
    integer restrictAccess = 0;         // Access restriction: 0 none, 1 group, 2 owner
    integer echo = TRUE;                // Echo chat and script commands ?
    integer trace = FALSE;              // Trace operation ?
    integer hide = FALSE;               // Hide deployer while running ?
    integer running = FALSE;            // Are we running an animation ?
//    float runEndTime = 0;               // Time to complete current run
    float timerTick = 0.05;             // Spin animation timer interval

    float globalScale = 1;              // Scale of projected object
    vector globalPos = ZERO_VECTOR;     // Offset of projected object from deployer
    vector edgeColour = < -1, 0, 0 >;   // Colour of wireframe edges
    float edgeAlpha = 1;                // Alpha of wireframe edges
    float edgeDiam = 0.03;              // Wire frame edge diameter

    integer perspective = TRUE;         // Perspective (TRUE) or orthographic (FALSE)
    float viewAngle = PI_BY_TWO;        // Viewing angle (PI / 2)
    rotation viewFrom = < 0, 0, 0, 3 >; // View from location

    vector spinAxis = < 0, 0, 1 >;      // Omega spin axis
    float spinRate = 0;                 // Omega spin rate, radians/second

    string helpFileName = "Fourmilab Tesseract User Guide";

    integer whichModel = 8;             // Initial model to display
//    string modelName;                   // Model name
//    list edgeLink;                      // Edge link numbers
//    integer nLinks;                     // Number of edges in inventory
//    list vertex;                        // Unit tesseract vertex array
//    integer nVertex;                    // Number of vertices
//    integer nEdges;                     // Number of edges in current model
//    list edgePath;                      // Edges defined as pairs of vertex indices
//    list edgeAxis;                      // Local axis along which this 4D edge runs
//    list axisColour = [                 // Colours for edges based on axis
//        < 1, 0, 0 >,                    //      0   X   Red
//        < 0, 0.75, 0 >,                 //      1   Y   Green
//        < 0, 0, 1 >,                    //      2   Z   Blue
//        < 1, 0.64706, 0 >               //      3   W   Orange
//    ];

//    list projMatrix;                    // Current projection matrix
//    list animMatrix;                    // Matrix applied on each animation step

    //  Script processing

    integer scriptActive = FALSE;       // Are we reading from a script ?
    integer scriptSuspend = FALSE;      // Suspend script execution for asynchronous event
    string configScript = "Script: Configuration";

    //  Script Processor messages
    integer LM_SP_INIT = 50;            // Initialise
    integer LM_SP_RESET = 51;           // Reset script
    integer LM_SP_STAT = 52;            // Print status
    integer LM_SP_RUN = 53;             // Add script to queue
    integer LM_SP_GET = 54;             // Request next line from script
    integer LM_SP_INPUT = 55;           // Input line from script
    integer LM_SP_EOF = 56;             // Script input at end of file
    integer LM_SP_READY = 57;           // New script ready
    integer LM_SP_ERROR = 58;           // Requested operation failed
    integer LM_SP_SETTINGS = 59;        // Set operating modes

//    //  Edge messages
//    integer LM_ED_POS = 91;             // Set endpoint positions
//    integer LM_ED_PROP = 92;            // Set display properties

    //  Command processor messages

    integer LM_CP_COMMAND = 223;        // Process command

    //  Menu Processor messages
//    integer LM_MP_INIT = 270;       // Initialise
    integer LM_MP_RESET = 271;          // Reset script
    integer LM_MP_STAT = 272;           // Print status
    integer LM_MP_SETTINGS = 273;       // Set operating modes
    integer LM_MP_RESUME = 274;         // Resume script after menu selection

    //  Model messages
    integer LM_MO_SELECT = 301;         // Get model definition
    integer LM_MO_STAT = 302;           // Print status
//  integer LM_MO_DEFINITION = 303;     // Report model definition to requester

    //  Projection messages
    integer LM_PR_RESET = 310;          // Reset projection module
    integer LM_PR_UPDPROJ = 311;        // Update model to new projection
    integer LM_PR_UPDEDGE = 312;        // Update edge properties
    integer LM_PR_MTXRESET = 313;       // Reset matrix/ices to identity
    integer LM_PR_ROTATE = 314;         // Compose rotation with matrix
    integer LM_PR_SETTINGS = 315;       // Update projection settings
    integer LM_PR_RUN = 316;            // Start or stop animation
    integer LM_PR_STAT = 317;           // Print status
    integer LM_PR_RESUME = 318;         // Resume script after projection command

    //  tawk  --  Send a message to the interacting user in chat

    tawk(string msg) {
        if (whoDat == NULL_KEY) {
            //  No known sender.  Say in nearby chat.
            llSay(PUBLIC_CHANNEL, msg);
        } else {
            /*  While debugging, when speaking to the owner, use llOwnerSay()
                rather than llRegionSayTo() to avoid the risk of a runaway
                blithering loop triggering the gag which can only be removed
                by a region restart.  */
            if (owner == whoDat) {
                llOwnerSay(msg);
            } else {
                llRegionSayTo(whoDat, PUBLIC_CHANNEL, msg);
            }
        }
    }

/*
    //  matident  --  Return a 4x4 identity matrix

    list matident() {
        return [ < 1, 0, 0, 0 >,
                 < 0, 1, 0, 0 >,
                 < 0, 0, 1, 0 >,
                 < 0, 0, 0, 1 > ];
    }

    //  matload  --  Extract an element from a matrix

    float matload(list m, integer i, integer k) {
        rotation r = llList2Rot(m, i);
        if (k == 0) {
            return r.x;
        } else if (k == 1) {
            return r.y;
        } else if (k == 2) {
            return r.z;
        } else {
            return r.s;
        }
    }

    //  matstore  -- Update an element in a matrix

    list matstore(list m, integer i, integer k, float v) {
        rotation r = llList2Rot(m, i);

        if (k == 0) {
            r.x = v;
        } else if (k == 1) {
            r.y = v;
        } else if (k == 2) {
            r.z = v;
        } else {
            r.s = v;
        }

        return llListReplaceList(m, [ r ], i, i);
    }

    //  matmul  --  Multiply two 4x4 matrices

    list matmul(list a, list b) {
        integer i;
        integer j;
        integer k;
        list o = matident();

        for (i = 0; i < 4; i++) {
            for (k = 0; k < 4; k++) {
                float sum = 0;
                for (j = 0; j < 4; j++) {
                    sum += matload(a, i, j) * matload(b, j, k);
                }
                o = matstore(o, i, k, sum);
            }
        }
        return o;
    }

    //  matprint  --  Convert a matrix to a printable string

    string matprint(list m) {
        string s = "\n" +
            "| " + ((string) llList2Rot(m, 0)) + " |\n" +
            "| " + ((string) llList2Rot(m, 1)) + " |\n" +
            "| " + ((string) llList2Rot(m, 2)) + " |\n" +
            "| " + ((string) llList2Rot(m, 3)) + " |\n";

        return s;
    }
*/

    /*  MATROT4D  --  Build four dimensional rotation matrix.  theta is the
                      rotation angle, in radians.  i is the selector for
                      the first plane being rotated about, and j selects
                      the second plane of rotation.  i and j are in the
                      range from 1 to 3, and only the following combinations
                      are permitted:

                        I     J
                       ---   ---
                        1     2
                        1     3
                        1     4
                        2     3
                        2     4
                        3     4
    */
/*
    list matrot4d(float theta, integer i, integer j) {
            float a;
            float b;
            list m;

            if ((i < 1) || (i > 3) ||
                (j <= i) || (j > 4)) {
               tawk("Invalid rotation plane arguments (I, J) passed\n" +
                    "to matrot4d.  I = " + (string) i +
                    ", J = " + (string) j);
            }

            b = llSin(theta);
            a = llCos(theta);

            m = matident();
            m = matstore(m, i - 1, i - 1, a);
            m = matstore(m, j - 1, j - 1, a);
            m = matstore(m, j - 1, i - 1, -b);
            m = matstore(m, i - 1, j - 1, b);
            return m;
    }

    //  vecscal4d  --  Scale a 4D vector by a constant

    rotation vecscal4d(rotation v, float s) {
        return <v.x * s, v.y * s, v.z * s, v.s * s>;
    }

    //  vecxmat  --  Multiply a vector by a matrix

    rotation vecxmat(rotation v, list m) {
        integer i;
        float sum;
        rotation vo;

        for (i = 0; i < 4; i++) {
            sum = v.x * matload(m, 0, i) +
                  v.y * matload(m, 1, i) +
                  v.z * matload(m, 2, i) +
                  v.s * matload(m, 3, i);
            if (i == 0) {
                vo.x = sum;
            } else if (i == 1) {
                vo.y = sum;
            } else if (i == 2) {
                vo.z = sum;
            } else {
                vo.s = sum;
            }
        }
        return vo;
    }
*/

    //  updateEdgeProps  -- Update properties of wireframe edges

//    updateEdgeProps() {
//        integer edgeIndex;
//        for (edgeIndex = 0; edgeIndex < nEdges; edgeIndex++) {
//            vector ec = edgeColour;
//            if (ec.x == -1) {
//            /*  If using "axes" colour, individually set the edges
//                to the color associated with that axis in the
//                un-rotated 4D model.  The XYZ axes are coloured as
//                in Second Life, and the W axis is orange.  */
//                ec = llList2Vector(axisColour, llList2Integer(edgeAxis, edgeIndex));
//            }
//            integer linkno = llList2Integer(edgeLink, edgeIndex);
//            llMessageLinked(linkno,
//                    LM_ED_PROP,
//                    llList2Json(JSON_ARRAY, [ edgeIndex + 1,
//                        ec, edgeAlpha,
//                        edgeDiam ]), whoDat);
//        }
//
//        //  If there are unused edges, hide them.
//        for (edgeIndex = nEdges; edgeIndex < nLinks; edgeIndex++) {
//             llSetLinkAlpha(llList2Integer(edgeLink, edgeIndex), 0, ALL_SIDES);
//        }
//    }

/*
    //  dot4d  --  Compute dot product of two 4D vectors

    float dot4d(rotation v1, rotation v2) {
        return (v1.x * v2.x) + (v1.y * v2.y) +
               (v1.z * v2.z) + (v1.s * v2.s);
    }
*/

    /*  cross4d  --  Compute cross-product analogue of two
                     4D vectors.  This computation is unrelated
                     to the cross product of vectors in 2D and
                     3D but is used for the same purpose:
                     finding the 4D vector which is orthogonal
                     to three linearly independent 4-vectors
                     U, V, and W.  */
/*
    rotation cross4d(rotation U, rotation V, rotation W) {
        rotation cx;

        float A = (V.x * W.y) - (V.y * W.x);
        float B = (V.x * W.z) - (V.z * W.x);
        float C = (V.x * W.s) - (V.s * W.x);
        float D = (V.y * W.z) - (V.z * W.y);
        float E = (V.y * W.s) - (V.s * W.y);
        float F = (V.z * W.s) - (V.s * W.z);

        cx.x =   (U.y * F) - (U.z * E) + (U.s * D);
        cx.y = - (U.x * F) + (U.z * C) - (U.s * B);
        cx.z =   (U.x * E) + (U.y * C) + (U.s * A);
        cx.s = - (U.x * D) + (U.y * B) - (U.z * A);

        return cx;
    }
*/

    /*  viewMatrix4Dto3D  --  Compute 4D to 3D viewing matrix.
                              This function takes a 4D viewpoint,
                              from, and a look-at point, to, and
                              two orthogonal 4-vectors, up and over,
                              which define the orientation of the
                              viewer in four-dimensional space.
                              The result is a 4x4 transformation
                              matrix to viewing co-ordinates.  */
/*
    list viewMatrix4Dto3D(rotation from, rotation to,
                          rotation up, rotation over) {
        rotation Wd = to - from;
        float norm = norm4d(Wd);
        if (norm == 0) {
            tawk("View from and to points are coincident.");
            return [ ];
        }
        Wd = vecscal4d(Wd, 1 / norm);

        rotation Wa = cross4d(up, over, Wd);
        norm = norm4d(Wa);
        if (norm == 0) {
            tawk("Invalid up vector");
            return [ ];
        }
        Wa = vecscal4d(Wa, 1 / norm);

        rotation Wb = cross4d(over, Wd, Wa);
        norm = norm4d(Wb);
        if (norm == 0) {
            tawk("Invalid over vector");
            return [ ];
        }
        Wb = vecscal4d(Wb, norm);

        rotation Wc = cross4d(Wd, Wa, Wb);

        return [ Wa, Wb, Wc, Wd ];
    }

    //  project4Dto3D  --  Project 4D vertex to 3D space

    vector project4Dto3D(rotation v, integer persp,
        float radius, rotation from, float vangle, list vmat) {
        float s;
        float t;

        if (persp) {
            t = 1 / llTan(vangle / 2);
        } else {            // Parallel
            s = 1 / radius;
        }
        v -= from;

        if (persp) {
            s = t / dot4d(v, llList2Rot(vmat, 3));
        }
        vector v3d = <
                        s * dot4d(v, llList2Rot(vmat, 0)),
                        s * dot4d(v, llList2Rot(vmat, 1)),
                        s * dot4d(v, llList2Rot(vmat, 2))
                     >;
        return v3d;
    }
    //  norm4d  -- Compute norm of 4d vector

    float norm4d(rotation v) {
        return llSqrt(dot4d(v, v));
    }

    //  updateProj  --  Update projection of 4D object to 3D model

    updateProj() {
        list pvertex;
        integer i;
        integer j;
        integer k;

        list projTo3d = viewMatrix4Dto3D(
                            viewFrom,                   // From
                            < 0, 0, 0, 0 >,             // To
                            < 0, 1, 0, 0 >,             // Up
                            < 0, 0, 1, 0 >);            // Over
        for (i = 0; i < nVertex; i++) {

            //  Position of transformed vertex in 4D space
            rotation vtx = vecxmat(llList2Rot(vertex, i), projMatrix);

            vector prv = project4Dto3D(vtx,
                perspective,
                1.0,                // Radius
                viewFrom,           // From 4D point
                viewAngle,          // View angle
                projTo3d);          // Projection matrix 4D to 3D
            pvertex += < prv.x, prv.y, prv.z, 0 >;
        }

        //  Draw wire frame representation of object

        for (i = 0; i < nEdges; i++) {
            j = llList2Integer(edgePath, i);
            k = j / 100;
            j = j % 100;
            if (i < nLinks) {
                /*  You might think that sending link messages to
                    each individual edge and having them separately
                    move themselves is inefficient compared to
                    batching everything up into one
                    llSetLinkPrimitiveParamsFast() call using the
                    PRIM_LINK_TARGET trick to address the links.

                    But you'd be wrong.  That runs much slower and
                    results in herky-jerky motion of the edges.  Making
                    separate calls for each edge here is no better.
                    My guess is that having the edges update themselves
                    allows the updates to run in parallel while doing
                    all the updates within the main script forces them
                    to be executed serially.

                llMessageLinked(llList2Integer(edgeLink, i), LM_ED_POS,
                llList2Json(JSON_ARRAY, [ i + 1,
                    (< matload(pvertex, j, 0),
                       matload(pvertex, j, 1),
                       matload(pvertex, j, 2) > * globalScale) + globalPos,
                    (< matload(pvertex, k, 0),
                       matload(pvertex, k, 1),
                       matload(pvertex, k, 2) > * globalScale) + globalPos ]),
                    whoDat);
            }
        }
    }

    //  updateOrientation  --  Update orientation for one animation step
    updateOrientation() {
        projMatrix = matmul(projMatrix, animMatrix);
    }
*/

    //  sendSettings  --  Send settings to other scripts

    sendSettings() {
        llMessageLinked(LINK_THIS, LM_SP_SETTINGS,
            llList2CSV([ trace, echo ]), whoDat);
        llMessageLinked(LINK_THIS, LM_MP_SETTINGS,
            llList2CSV([ trace, echo ]), whoDat);
    }

    /* sendProjSettings  --  Send projection settings to projection
                             script.  Bits in the upd parameter
                             perform updates of the projection and
                             edge properties:
                                1   Update projection
                                2   Update edge properties  */

    sendProjSettings(integer upd) {
        llMessageLinked(LINK_THIS, LM_PR_SETTINGS,
            llList2Json(JSON_ARRAY,
            [ globalScale, globalPos,
              edgeColour, edgeAlpha, edgeDiam,
              perspective, viewAngle, viewFrom,
              spinAxis, spinRate,
              hide, timerTick
            ]), whoDat);
        if (upd & 1) {
            llMessageLinked(LINK_THIS, LM_PR_UPDPROJ, "", whoDat);
        }
        if (upd & 2) {
            llMessageLinked(LINK_THIS, LM_PR_UPDEDGE, "", whoDat);
        }
    }

    //  checkAccess  --  Check if user has permission to send commands

    integer checkAccess(key id) {
        return (restrictAccess == 0) ||
               ((restrictAccess == 1) && llSameGroup(id)) ||
               (id == llGetOwner());
    }

    /*  fixArgs  --  Transform command arguments into canonical form.
                     All white space within vector and rotation brackets
                     is elided so they will be parsed as single arguments.  */

    string fixArgs(string cmd) {
        cmd = llStringTrim(cmd, STRING_TRIM);
        integer l = llStringLength(cmd);
        integer inbrack = FALSE;
        integer i;
        string fcmd = "";

        for (i = 0; i < l; i++) {
            string c = llGetSubString(cmd, i, i);
            if (inbrack && (c == ">")) {
                inbrack = FALSE;
            }
            if (c == "<") {
                inbrack = TRUE;
            }
            if (!((c == " ") && inbrack)) {
                fcmd += c;
            }
        }
        return fcmd;
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  onOff  --  Parse an on/off parameter

    integer onOff(string param) {
        if (abbrP(param, "on")) {
            return TRUE;
        } else if (abbrP(param, "of")) {
            return FALSE;
        } else {
            tawk("Error: please specify on or off.");
            return -1;
        }
    }

    //  eOnOff  -- Edit an on/off parameter

    string eOnOff(integer p) {
        if (p) {
            return "on";
        }
        return "off";
    }

    //  ef  --  Edit floats in string to parsimonious representation

    string eff(float f) {
        return ef((string) f);
    }

    string efv(vector v) {          // Helper that takes a vector argument
        return ef((string) v);
    }

    //  Static constants to avoid costly allocation
    string efkdig = "0123456789";
    string efkdifdec = "0123456789.";

    string ef(string s) {
        integer p = llStringLength(s) - 1;

        while (p >= 0) {
            //  Ignore non-digits after numbers
            while ((p >= 0) &&
                   (llSubStringIndex(efkdig, llGetSubString(s, p, p)) < 0)) {
                p--;
            }
            //  Verify we have a sequence of digits and one decimal point
            integer o = p - 1;
            integer digits = 1;
            integer decimals = 0;
            string c;
            while ((o >= 0) &&
                   (llSubStringIndex(efkdifdec, (c = llGetSubString(s, o, o))) >= 0)) {
                o--;
                if (c == ".") {
                    decimals++;
                } else {
                    digits++;
                }
            }
            if ((digits > 1) && (decimals == 1)) {
                //  Elide trailing zeroes
                integer b = p;
                while ((b >= 0) && (llGetSubString(s, b, b) == "0")) {
                    b--;
                }
                //  If we've deleted all the way to the decimal point, remove it
                if ((b >= 0) && (llGetSubString(s, b, b) == ".")) {
                    b--;
                }
                //  Remove everything we've trimmed from the number
                if (b < p) {
                    s = llDeleteSubString(s, b + 1, p);
                    p = b;
                }
                //  Done with this number.  Skip to next non digit or decimal
                while ((p >= 0) &&
                       (llSubStringIndex(efkdifdec, llGetSubString(s, p, p)) >= 0)) {
                    p--;
                }
            } else {
                //  This is not a floating point number
                p = o;
            }
        }
        return s;
    }

    /*  scriptResume  --  Resume script execution when asynchronous
                          command completes.  */

    scriptResume() {
        if (scriptActive) {
            if (scriptSuspend) {
                scriptSuspend = FALSE;
                llMessageLinked(LINK_THIS, LM_SP_GET, "", NULL_KEY);
                if (trace) {
                    tawk("Script resumed.");
                }
            }
        }
    }

    //  processCommand  --  Process a command

    list args;              // Argument list
    integer argn;           // Argument list length

    integer processCommand(key id, string message, integer fromScript) {

        if (!checkAccess(id)) {
            llRegionSayTo(id, PUBLIC_CHANNEL,
                "You do not have permission to control this object.");
            return FALSE;
        }

        whoDat = id;            // Direct chat output to sender of command

        /*  If echo is enabled, echo command to sender unless
            prefixed with "@".  The command is prefixed with ">>"
            if entered from chat or "++" if from a script.  */

        integer echoCmd = TRUE;
        if (llGetSubString(llStringTrim(message, STRING_TRIM_HEAD), 0, 0) == "@") {
            echoCmd = FALSE;
            message = llGetSubString(llStringTrim(message, STRING_TRIM_HEAD), 1, -1);
        }
        if (echo && echoCmd) {
            string prefix = ">> /" + (string) commandChannel + " ";
            if (fromScript == TRUE) {
                prefix = "++ ";
            } else if (fromScript == 2) {
                prefix = "== ";
            } else if (fromScript == 3) {
                prefix = "<< ";
            }
            tawk(prefix + message);                 // Echo command to sender
        }

        string lmessage = fixArgs(llToLower(message));
        args = llParseString2List(lmessage, [ " " ], []);    // Command and arguments
        argn = llGetListLength(args);               // Number of arguments
        string command = llList2String(args, 0);    // The command
        string sparam = llList2String(args, 1);     // First argument, for convenience

        //  Access who                  Restrict chat command access to public/group/owner

        if (abbrP(command, "ac")) {
            string who = sparam;

            if (abbrP(who, "p")) {          // Public
                restrictAccess = 0;
            } else if (abbrP(who, "g")) {   // Group
                restrictAccess = 1;
            } else if (abbrP(who, "o")) {   // Owner
                restrictAccess = 2;
            } else {
                tawk("Unknown access restriction \"" + who +
                    "\".  Valid: public, group, owner.\n");
                return FALSE;
            }

        //  Boot                    Reset the script to initial settings

        } else if (abbrP(command, "bo")) {
            llMessageLinked(LINK_THIS, LM_MP_RESET, "", whoDat);
            llMessageLinked(LINK_THIS, LM_SP_RESET, "", whoDat);
            llSleep(0.25);
            llResetScript();

        /*  Channel n               Change command channel.  Note that
                                    the channel change is lost on a
                                    script reset.  */
        } else if (abbrP(command, "ch")) {
            integer newch = (integer) sparam;
            if ((newch < 2)) {
                tawk("Invalid channel " + (string) newch + ".");
                return FALSE;
            } else {
                llListenRemove(commandH);
                commandChannel = newch;
                commandH = llListen(commandChannel, "", NULL_KEY, "");
                tawk("Listening on /" + (string) commandChannel);
            }

        //  Clear                   Clear chat for debugging

        } else if (abbrP(command, "cl")) {
            tawk("\n\n\n\n\n\n\n\n\n\n\n\n\n");

        //  Echo text               Send text to sender

        } else if (abbrP(command, "ec")) {
            integer dindex = llSubStringIndex(lmessage, command);
            integer doff = llSubStringIndex(llGetSubString(lmessage, dindex, -1), " ");
            string emsg = " ";
            if (doff >= 0) {
                emsg = llStringTrim(llGetSubString(message, dindex + doff + 1, -1),
                            STRING_TRIM_TAIL);
            }
            tawk(emsg);

        //  Help                    Give help information

        } else if (abbrP(command, "he")) {
            llGiveInventory(id, helpFileName);      // Give requester the User Guide notecard

        //  Rotate planes angle [ animate ]  Rotate 4D model in planes, optionally spin at rate
        //  Rotate clear            Resets animation transform to identity
        //  Rotate reset            Resets rotation, clears animation transform

        } else if (abbrP(command, "ro")) {
            if (abbrP(sparam, "cl")) {
//                animMatrix = matident();
                llMessageLinked(LINK_THIS, LM_PR_MTXRESET, "2", whoDat);
            } else if (abbrP(sparam, "re")) {
//                projMatrix = matident();
//                animMatrix = matident();
//                updateProj();
                llMessageLinked(LINK_THIS, LM_PR_MTXRESET, "3", whoDat);
                llMessageLinked(LINK_THIS, LM_PR_UPDPROJ, "", whoDat);
            } else {
                list planes = [ "xy", 1, 2, "xz", 1, 3, "xw", 1, 4,
                                "yz", 2, 3, "yw", 2, 4,
                                "zw", 3, 4 ];
                integer pindex = llListFindList(planes, [ sparam ]);
                if (pindex >= 0) {
/*
                    list rotmat = matrot4d(llList2Float(args, 2) * DEG_TO_RAD,
                        llList2Integer(planes, pindex + 1),
                        llList2Integer(planes, pindex + 2));
                    if ((argn > 3) && abbrP(llList2String(args, 3), "an")) {
                        animMatrix = matmul(animMatrix, rotmat);
                    } else {
                        projMatrix = matmul(projMatrix, rotmat);
                        updateProj();
                    }
*/
                    integer isAnim = (argn > 3) &&
                            abbrP(llList2String(args, 3), "an");
                    llMessageLinked(LINK_THIS, LM_PR_ROTATE,
                        llList2Json(JSON_ARRAY,
                        [ llList2Float(args, 2) * DEG_TO_RAD,
                          llList2Integer(planes, pindex + 1),
                          llList2Integer(planes, pindex + 2),
                          isAnim ]), whoDat);
                        if (!isAnim) {
                            llMessageLinked(LINK_THIS, LM_PR_UPDPROJ, "", whoDat);
                        }
                } else {
                    tawk("Unknown plane.  Use XY, XZ, XW, YZ, YW, ZW.");
                    return FALSE;
                }
            }

        //  Run on/off/time         Start or stop model animation

        } else if (abbrP(command, "ru")) {
            float runDuration = 0;
            if (llSubStringIndex("0123456789.", llGetSubString(sparam, 0, 0)) >= 0) {
                runDuration = ((float) sparam);
                sparam = "on";
            }
            running = onOff(sparam);
/*
            if (running) {
                llSetTimerEvent(timerTick);
                scriptSuspend = TRUE;
            } else {
                llSetTimerEvent(0);
                scriptResume();
            }
            if (hide == 2) {
                llSetAlpha(1 - running, ALL_SIDES);
            }
*/
            if (running) {
                scriptSuspend = TRUE;
            }
            llMessageLinked(LINK_THIS, LM_PR_RUN,
                llList2Json(JSON_ARRAY,
                [ running,
                  runDuration,
                  hide ]), whoDat);

        //  Set                     Set parameter

        } else if (abbrP(command, "se")) {
            string svalue = llList2String(args, 2);

                //  Set colour <r, g, b> [ alpha ]
                //  Set colour axes [ alpha ]

                if (abbrP(sparam, "co")) {
                    if (abbrP(svalue, "ax")) {
                        edgeColour = < -1, 0, 0 >;
                    } else {
                        edgeColour = (vector) svalue;
                    }
                    edgeAlpha = 1;
                    if (argn > 3) {
                        edgeAlpha = llList2Float(args, 3);
                    }
                    sendProjSettings(2);
//                    updateEdgeProps();

                //  Set diameter n
                } else if (abbrP(sparam, "di")) {
                    edgeDiam = (float) svalue;
                    sendProjSettings(2);
//                    updateEdgeProps();

                //  Set echo on/off

                } else if (abbrP(sparam, "ec")) {
                    echo = onOff(svalue);
                    sendSettings();

                //  Set hide on/off/auto

                } else if (abbrP(sparam, "hi")) {
                    if (abbrP(svalue, "au")) {
                        hide = 2;
//                        llSetAlpha(1 - running, ALL_SIDES);
                    } else {
                        hide = onOff(svalue);
//                        llSetAlpha(1 - hide, ALL_SIDES);
                    }
                    sendProjSettings(0);

                //  Set model 5/pentachoron/8/tesseract/16/hexadecachoron

                } else if (abbrP(sparam, "mo")) {
                    integer mod;
                    if (abbrP(svalue, "5") || abbrP(svalue, "pe")) {
                        mod = 5;
                    } else if (abbrP(svalue, "8") || abbrP(svalue, "te")) {
                        mod = 8;
                    } else if (abbrP(svalue, "16") || abbrP(svalue, "he")) {
                        mod = 16;
                    } else if (abbrP(svalue, "24") || abbrP(svalue, "ic")) {
                        mod = 24;
                    } else {
                        tawk("Unknown model.");
                        return FALSE;
                    }
                    llMessageLinked(LINK_THIS, LM_MO_SELECT, (string) mod, whoDat);

                //  Set name Object name

                } else if (abbrP(sparam, "na")) {
                    integer naPos = llSubStringIndex(lmessage, "na");
                    string t1 = llGetSubString(message, naPos + 2, -1);
                    llSetObjectName(llStringTrim(llGetSubString(t1, llSubStringIndex(t1, " ") + 1, -1),
                        STRING_TRIM_HEAD));

                //  Set position <x, y, z>

                } else if (abbrP(sparam, "po")) {
                    globalPos = (vector) svalue;
//                    updateProj();
                    sendProjSettings(1);

                //  Set projection parallel=orthographic/perspective

                } else if (abbrP(sparam, "pr")) {
                    perspective = abbrP(svalue, "pe");
//                    updateProj();
                    sendProjSettings(1);

                //  Set scale n

                } else if (abbrP(sparam, "sc")) {
                    globalScale = (float) svalue;
//                    updateProj();
                    sendProjSettings(1);

                //  Set tick n

                } else if (abbrP(sparam, "ti")) {
                    timerTick = (float) svalue;
//                    if (running) {
//                        llSetTimerEvent(timerTick);
//                    }
                    sendProjSettings(0);

                //  Set trace on/off

                } else if (abbrP(sparam, "tr")) {
                    trace = onOff(svalue);
                    sendSettings();

                //  Set view angle degrees
                //  Set view from <x, y, z, w>

                } else if (abbrP(sparam, "vi")) {
                    if (abbrP(svalue, "an")) {
                        viewAngle = llList2Float(args, 3) * DEG_TO_RAD;
                    } else if (abbrP(svalue, "fr")) {
                        viewFrom = (rotation) llList2String(args, 3);
                    } else {
                        tawk("Use Set from or Set angle");
                        return FALSE;
                    }
//                    updateProj();
                    sendProjSettings(1);

                } else {
                    tawk("Setting unknown.");
                    return FALSE;
                }

        //    Commands processed by other scripts
        //  Script                  Script commands
        //  Menu                    Menu commands

        } else if (abbrP(command, "sc") || abbrP(command, "me")) {
            if ((abbrP(command, "me") && abbrP(sparam, "sh")) &&
                ((argn < 4) || (!abbrP(llList2String(args, -1), "co")))) {
                scriptSuspend = TRUE;
            }
            llMessageLinked(LINK_THIS, LM_CP_COMMAND,
                llList2Json(JSON_ARRAY, [ message, lmessage ] + args), whoDat);

        //  Spin rate [ <axis> ]    Spin 3D projection in space

        } else if (abbrP(command, "sp")) {
            spinAxis = < 0, 0, 1 >;
            spinRate = 0;
            if (argn > 1) {
                spinRate = ((float) sparam) * DEG_TO_RAD;
                if (argn > 2) {
                    spinAxis = (vector) llList2String(args, 2);
                }
            }
            float gain = 1;
            if (spinRate == 0) {
                gain = 0;
            }
            llTargetOmega(spinAxis, spinRate, gain);
            if (gain == 0) {
                /*  What's all this, you ask?  Well, you see, when you
                    Omega rotate a non-physical prim, the operation is
                    performed entirely locally, in the viewer.
                    Apparently, then, after stopping the rotation, if
                    you want to explicitly rotate the prim (or in this
                    case, a linked object) to a fixed location, such as
                    the starting point, the rotation is ignored (my
                    guess is because the server doesn't know the prim
                    has been rotated by the viewer).  So, what we have
                    to do is a little jiggle of a local rotation to
                    persuade the server that it has moved, and then do
                    the actual rotation to put it where we want it.  Oh,
                    and one more thing: that little jiggle can't be a
                    llSetLinkPrimitiveParamsFast()--it has to use the full
                    one that waits 200 milliseconds because apparently
                    the fast variant is too fast for the server to twig
                    to the fact that you've rotated it with Omega.  */
                llSetLinkPrimitiveParams(LINK_THIS,
                    [ PRIM_ROTATION, llEuler2Rot(<0, 0, 0.001>) ]);
                llSetLinkPrimitiveParamsFast(LINK_THIS,
                    [ PRIM_ROTATION, ZERO_ROTATION ]);
            }

        //  Status                  Print status

        } else if (abbrP(command, "st")) {
            integer mFree = llGetFreeMemory();
            integer mUsed = llGetUsedMemory();
            string s;
            string ec = "Axes";
            if (edgeColour.x >= 0) {
                ec = efv(edgeColour);
            }
            s += "Trace: " + eOnOff(trace) + "  Echo: " + eOnOff(echo) +
                 "  Hide: " + eOnOff(hide) + "  Run: " + eOnOff(running) +
                 "  Tick: " + eff(timerTick) + "\n";
            s += "Scale: " + eff(globalScale) + "  Position: " + efv(globalPos) + "\n";
            s += "Projection: ";
            if (perspective) {
                s += "perspective";
                s += "  Viewpoint: " + ef((string) viewFrom) +
                     "  Angle: " + eff(viewAngle * RAD_TO_DEG) + "°";
            } else {
                s += "orthographic";
            }
            s += "\n";
            s += "Spin rate: " + eff(spinRate * RAD_TO_DEG) + " °/sec  Axis: " +
                 efv(spinAxis) + "\n";
            s += "Edge Colour: " + ec + "  Alpha: " + eff(edgeAlpha) +
                  "  Diameter: " + eff(edgeDiam) + "\n";
            s += "Script memory.  Free: " + (string) mFree +
                    "  Used: " + (string) mUsed + " (" +
                    (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)";
            tawk(s);
            //  Request status of Model Definitions
            llMessageLinked(LINK_THIS, LM_MO_STAT, "", id);
            //  Request status of Projection
            llMessageLinked(LINK_THIS, LM_PR_STAT, "", id);
            //  Request status of Script Processor
            llMessageLinked(LINK_THIS, LM_SP_STAT, "", id);
            //  Request status of Menu Processor
            llMessageLinked(LINK_THIS, LM_MP_STAT, "", id);
        } else {
            tawk("Huh?  \"" + message + "\" undefined.  Chat /" +
                (string) commandChannel + " help for instructions.");
            return FALSE;
        }
        return TRUE;
    }

    default {

        state_entry() {
            whoDat = owner = llGetOwner();

//            projMatrix = matident();
//            animMatrix = matident();
//            llMessageLinked(LINK_THIS, LM_PR_MTXRESET, "3", whoDat);
            //  Reset projections module
            llMessageLinked(LINK_THIS, LM_PR_RESET, "", whoDat);

            //  Select initial model

            llMessageLinked(LINK_THIS, LM_MO_SELECT, (string) whichModel, whoDat);

            //  Stop any Omega rotation
            llTargetOmega(<0, 0, 1>, 0, 0);

            //  Start listening on the command chat channel
            commandH = llListen(commandChannel, "", NULL_KEY, "");
            tawk("Listening on /" + (string) commandChannel);

            //  Reset the script and menu processors
            llMessageLinked(LINK_THIS, LM_SP_RESET, "", whoDat);
            llMessageLinked(LINK_THIS, LM_MP_RESET, "", whoDat);
            llSleep(0.1);           // Allow script process to finish reset
            sendSettings();
            sendProjSettings(0);

            //  If a configuration script exists, run it
            if (llGetInventoryType(configScript) == INVENTORY_NOTECARD) {
                llMessageLinked(LINK_THIS, LM_SP_RUN, configScript, whoDat);
            }
        }

        /*  The listen event handler processes messages from
            our chat control channel.  */

        listen(integer channel, string name, key id, string message) {
            if (channel == commandChannel) {
                processCommand(id, message, FALSE);
            }
        }

        /*  The link_message() event receives commands from other scripts
            script and passes them on to the script processing functions
            within this script.  */

        link_message(integer sender, integer num, string str, key id) {

            //  Script Processor messages

            //  LM_SP_READY (57): Script ready to read

            if (num == LM_SP_READY) {
                scriptActive = TRUE;
                llMessageLinked(LINK_THIS, LM_SP_GET, "", id);  // Get the first line

            //  LM_SP_INPUT (55): Next executable line from script

            } else if (num == LM_SP_INPUT) {
                if (str != "") {                // Process only if not hard EOF
                    scriptSuspend = FALSE;
                    integer stat = processCommand(id, str, TRUE); // Some commands set scriptSuspend
                    if (stat) {
                        if (!scriptSuspend) {
                            llMessageLinked(LINK_THIS, LM_SP_GET, "", id);
                        }
                    } else {
                        //  Error in script command.  Abort script input.
                        scriptActive = scriptSuspend = FALSE;
                        llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);
                        tawk("Script terminated.");
                    }
                }

            //  LM_SP_EOF (56): End of file reading from script

            } else if (num == LM_SP_EOF) {
                scriptActive = FALSE;           // Mark script input complete

            //  LM_SP_ERROR (58): Error processing script request

            } else if (num == LM_SP_ERROR) {
                llRegionSayTo(id, PUBLIC_CHANNEL, "Script error: " + str);
                scriptActive = scriptSuspend = FALSE;
                llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);

            //  LM_MP_RESUME (274): Resume script after menu selection or timeout
            //  LM_PR_RESUME (318): Resume script after projection command

            } else if ((num == LM_MP_RESUME) || (num == LM_PR_RESUME)) {
                scriptResume();
            }
        }

        //  The touch event is a short-cut to run the Touch script

        touch_start(integer howmany) {
            if (llGetInventoryKey("Script: Touch") != NULL_KEY) {
                processCommand(llDetectedKey(0), "Script run Touch", TRUE);
            }
        }
     }
