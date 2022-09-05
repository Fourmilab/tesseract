    /*

                        Fourmilab Tesseract

                    Generate Projections of Object

    */

    key owner;                          // Owner UUID

    key whoDat = NULL_KEY;              // Avatar who sent command
    integer hide = FALSE;               // Hide deployer while running ?
    integer running = FALSE;            // Are we running an animation ?
    float runEndTime = 0;               // Time to complete current run
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

    integer whichModel = 8;             // Initial model to display
    string modelName;                   // Model name
    list edgeLink;                      // Edge link numbers
    integer nLinks;                     // Number of edges in inventory
    list vertex;                        // Unit tesseract vertex array
    integer nVertex;                    // Number of vertices
    integer nEdges;                     // Number of edges in current model
    list edgePath;                      // Edges defined as pairs of vertex indices
    list edgeAxis;                      // Local axis along which this 4D edge runs
    list axisColour = [                 // Colours for edges based on axis
        < 1, 0, 0 >,                    //      0   X   Red
        < 0, 0.75, 0 >,                 //      1   Y   Green
        < 0, 0, 1 >,                    //      2   Z   Blue
        < 1, 0.64706, 0 >               //      3   W   Orange
    ];

    list projMatrix;                    // Current projection matrix
    list animMatrix;                    // Matrix applied on each animation step

    //  Edge messages
    integer LM_ED_POS = 91;             // Set endpoint positions
    integer LM_ED_PROP = 92;            // Set display properties

    //  Model messages
    integer LM_MO_SELECT = 301;         // Get model definition
//  integer LM_MO_STAT = 302;           // Print status
    integer LM_MO_DEFINITION = 303;     // Report model definition to requester'

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

    //  Export messages
    integer LM_EX_EXMODEL = 331;        // Export current model from Projections
    integer LM_EX_EXVIEW = 332;         // Export current view from Projections
    integer LM_EX_DATA = 333;           // Export data from Projections

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

    /*  Find a linked prim from its name.  Avoids having to slavishly
        link prims in order in complex builds to reference them later
        by link number.  You should only call this once, in state_entry(),
        and then save the link numbers in global variables.  Returns the
        prim number or -1 if no such prim was found.  Caution: if there
        are more than one prim with the given name, the first will be
        returned without warning of the duplication.  */

    integer findLinkNumber(string pname) {
        integer i = llGetLinkNumber() != 0;
        integer n = llGetNumberOfPrims() + i;

        for (; i < n; i++) {
            if (llGetLinkName(i) == pname) {
                return i;
            }
        }
        return -1;
    }

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

/*
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
        return < v.x * s, v.y * s, v.z * s, v.s * s >;
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

    //  dot4d  --  Compute dot product of two 4D vectors

    float dot4d(rotation v1, rotation v2) {
        return (v1.x * v2.x) + (v1.y * v2.y) +
               (v1.z * v2.z) + (v1.s * v2.s);
    }

    /*  cross4d  --  Compute cross-product analogue of two
                     4D vectors.  This computation is unrelated
                     to the cross product of vectors in 2D and
                     3D but is used for the same purpose:
                     finding the 4D vector which is orthogonal
                     to three linearly independent 4-vectors
                     U, V, and W.  */

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

    /*  viewMatrix4Dto3D  --  Compute 4D to 3D viewing matrix.
                              This function takes a 4D viewpoint,
                              from, and a look-at point, to, and
                              two orthogonal 4-vectors, up and over,
                              which define the orientation of the
                              viewer in four-dimensional space.
                              The result is a 4x4 transformation
                              matrix to viewing co-ordinates.  */

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
                    to be executed serially.  */

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

    //  updateEdgeProps  -- Update properties of wireframe edges

    updateEdgeProps() {
        integer edgeIndex;
        for (edgeIndex = 0; edgeIndex < nEdges; edgeIndex++) {
            vector ec = edgeColour;
            if (ec.x == -1) {
            /*  If using "axes" colour, individually set the edges
                to the color associated with that axis in the
                un-rotated 4D model.  The XYZ axes are coloured as
                in Second Life, and the W axis is orange.  */
                ec = llList2Vector(axisColour, llList2Integer(edgeAxis, edgeIndex));
            }
            integer linkno = llList2Integer(edgeLink, edgeIndex);
            llMessageLinked(linkno,
                    LM_ED_PROP,
                    llList2Json(JSON_ARRAY, [ edgeIndex + 1,
                        ec, edgeAlpha,
                        edgeDiam ]), whoDat);
        }

        //  If there are unused edges, hide them.
        for (edgeIndex = nEdges; edgeIndex < nLinks; edgeIndex++) {
             llSetLinkAlpha(llList2Integer(edgeLink, edgeIndex), 0, ALL_SIDES);
        }
    }

    //  updateHide  --  Update visibility of controller

    updateHide() {
        if ((hide == 0) || (hide == 1)) {
            llSetAlpha(1 - hide, ALL_SIDES);
        } else if (hide == 2) {
            llSetAlpha(1 - running, ALL_SIDES);
        }
    }

    default {

        state_entry() {
            whoDat = owner = llGetOwner();

            //  Find all of the links for edges
            integer i = 1;
            integer l;
            do {
                l = findLinkNumber("Edge " + (string) i);
                if (l > 0) {
                    edgeLink += [ l ];
                    i++;
                }
            } while (l > 0);
            nLinks = llGetListLength(edgeLink);

            //  Select initial model

            llMessageLinked(LINK_THIS, LM_MO_SELECT, (string) whichModel, whoDat);

            projMatrix = matident();
            animMatrix = matident();

            //  Stop any Omega rotation
            llTargetOmega(<0, 0, 1>, 0, 0);
        }

        /*  The link_message() event receives commands from other scripts
            script and passes them on to the script processing functions
            within this script.  */

        link_message(integer sender, integer num, string str, key id) {

            //  LM_PR_RESET (320): Reset projection module

            if (num == LM_PR_RESET) {
                llResetScript();

            //  LM_PR_UPDPROJ (311): Update model to new projection

            } else if (num == LM_PR_UPDPROJ) {
                updateProj();

            //  LM_PR_UPDEDGE (312): Edge properties

            } else if (num == LM_PR_UPDEDGE) {
                updateEdgeProps();

            //  LM_PR_MTXRESET (313): Reset matrix/ices to identity

            } else if (num == LM_PR_MTXRESET) {
                integer which = (integer) str;
                if (which & 1) {
                    projMatrix = matident();
                }
                if (which & 2) {
                    animMatrix = matident();
                }

            //  LM_PR_ROTATE (314): Compose rotation with transformation matrix

            } else if (num == LM_PR_ROTATE) {
                list l = llJson2List(str);
                float angle = llList2Float(l, 0);
                integer pindex1 = llList2Integer(l, 1);
                integer pindex2 = llList2Integer(l, 2);
                integer isAnim = llList2Integer(l, 3);
                list rotmat = matrot4d(angle, pindex1, pindex2);
                if (isAnim) {
                    animMatrix = matmul(animMatrix, rotmat);
                } else {
                    projMatrix = matmul(projMatrix, rotmat);
                }

            //  LM_PR_SETTINGS (315): Update projection settings

            } else if (num == LM_PR_SETTINGS) {
                list l = llJson2List(str);
                globalScale = llList2Float(l, 0);
                globalPos = (vector) llList2String(l, 1);
                edgeColour = (vector) llList2String(l, 2);
                edgeAlpha = llList2Float(l, 3);
                edgeDiam = llList2Float(l, 4);
                perspective = llList2Integer(l, 5);
                viewAngle = llList2Float(l, 6);
                viewFrom = (rotation) llList2String(l, 7);
                spinAxis = (vector) llList2String(l, 8);
                spinRate = llList2Float(l, 9);
                hide = llList2Integer(l, 10);
                timerTick = llList2Float(l, 11);
                updateHide();

            //  LM_PR_RUN (316): Start or stop animation

            } else if (num == LM_PR_RUN) {
                list l = llJson2List(str);
                running = llList2Integer(l, 0);
                runEndTime = llList2Float(l, 1);
                hide = llList2Integer(l, 2);
                if (running) {
                    if (runEndTime > 0) {
                        runEndTime += llGetTime();
                    }
                    llSetTimerEvent(timerTick);
                } else {
                    llSetTimerEvent(0);
                    llMessageLinked(LINK_THIS, LM_PR_RESUME, "", whoDat);
                }
                updateHide();

            //  LM_PR_STAT (317): Print script status

            } else if (num == LM_PR_STAT) {
                string stat = "Projections:";
                stat += "\n";
                stat += "Model: " + modelName + "  Vertices: " + (string) nVertex +
                        "  Edges: " + (string) nEdges + "\n";
                integer mFree = llGetFreeMemory();
                integer mUsed = llGetUsedMemory();
                stat += "    Script memory.  Free: " + (string) mFree +
                        "  Used: " + (string) mUsed + " (" +
                        (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)";

                llRegionSayTo(id, PUBLIC_CHANNEL, stat);

            //  LM_MO_DEFINITION (302): Define vertices and edges of new model

            } else if (num == LM_MO_DEFINITION) {
                list ml = llJson2List(str);
                modelName = llList2String(ml, 0);
                list vtxs = llJson2List(llList2String(ml, 1));
                edgePath = llJson2List(llList2String(ml, 2));
                edgeAxis = llJson2List(llList2String(ml, 3));
                nVertex = llGetListLength(vtxs);        // Number of vertices
                nEdges = llGetListLength(edgePath);     // Number of edges

                integer i;
                vertex = [ ];
                for (i = 0; i < nVertex; i++) {
                    vertex += (rotation) llList2String(vtxs, i);
                }
                updateProj();
                updateEdgeProps();

            //  LM_EX_EXMODEL (331): Export model as defined
            //  LM_EX_EXVIEW  (332): Export model as currently projected

            } else if ((num == LM_EX_EXMODEL) || (num == LM_EX_EXVIEW)) {
                string vtxs;
                if (num == LM_EX_EXVIEW) {
                    //  Build list of vertices transformed by current projection
                    list tvtx;
                    integer i;

                    for (i = 0; i < nVertex; i++) {
                        tvtx += vecxmat(llList2Rot(vertex, i), projMatrix);
                    }
                    vtxs = llList2Json(JSON_ARRAY, tvtx);
                } else {
                    vtxs = llList2Json(JSON_ARRAY, vertex);
                }
                llMessageLinked(LINK_THIS, LM_EX_DATA,
                    llList2Json(JSON_ARRAY, [
                        modelName,                          // Model name
                        vtxs,                               // List of vertices
                        llList2Json(JSON_ARRAY, edgePath),  // List of edges
                        llList2Json(JSON_ARRAY, edgeAxis)   // Colour indices of edges
                    ]), id);
            }

        }

        //  The timer updates the model while running

        timer() {
            if (running) {
                updateOrientation();
                updateProj();
                if ((runEndTime > 0) && (llGetTime() > runEndTime)) {
                    running = FALSE;
                    runEndTime = 0;
                    llSetTimerEvent(0);
                    if (hide == 2) {
                        llSetAlpha(1, ALL_SIDES);
                    }
                    llMessageLinked(LINK_THIS, LM_PR_RESUME, "", whoDat);
                }
            } else {
                llSetTimerEvent(0);
            }
        }
    }
