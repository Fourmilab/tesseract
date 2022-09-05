    /*

                        Fourmilab Tesseract

                  Four-Dimensional Model Definitions

    */

    string modelName;                   // Model name
    list vertex;                        // Unit tesseract vertex array
    list edgePath;                      // Edges defined as pairs of vertex indices
    list edgeAxis;                      // Local axis along which this 4D edge runs

    key whoDat;                         // User (UUID) who requested script

    key owner;                          // Owner of the object
    key agent = NULL_KEY;               // User, if any

    //  Model messages
    integer LM_MO_SELECT = 301;         // Get model definition
    integer LM_MO_STAT = 302;           // Print status
    integer LM_MO_DEFINITION = 303;     // Report model definition to requester

    //  Command processor messages
    integer LM_CP_COMMAND = 223;        // Process command

    /*  tawk  --  Send a message to the interacting user in chat.
                  The recipient of the message is defined as
                  follows.  If an agent has provoked the message,
                  that avatar receives the message.  Otherwise,
                  the message goes to the owner of the object.
                  In either case, if the message is being sent to
                  the owner, it is sent with llOwnerSay(), which isn't
                  subject to the region rate gag, rather than
                  llRegionSayTo().  */

    tawk(string msg) {
        key whom = owner;
        if (agent != NULL_KEY) {
            whom = agent;
        }
        if (whom == owner) {
            llOwnerSay(msg);
        } else {
            llRegionSayTo(whom, PUBLIC_CHANNEL, msg);
        }
    }

    //  vsign  --  Get sign of tesseract vertex based upon its index

    integer vsign(integer idx) {
        if (idx == 0) {
            return -1;
        }
        return 1;
    }

    //  selectModel  --  Choose model to display

    selectModel(integer cells) {
        integer i;

        if (cells == 5) {           // 5-cell, pentachoron
            modelName = "Pentachoron (5-cell)";
            edgePath = [   // Edges defined as pairs of vertex indices
                400,   1, 102, 203, 300,
                  2, 204, 401, 103, 304
            ];
            edgeAxis = [
                0, 0, 0, 0, 1, 1, 1, 1, 2, 2   // 0 X, 1 Y, 2 Z, 3 W
            ];
            float sqrt5 = llSqrt(5);
            vertex = [
                < 1, 1, 1, -1 / sqrt5 >,
                < 1, -1, -1, -1 / sqrt5 >,
                < -1, 1, -1, -1 / sqrt5 >,
                < -1, -1, 1, -1 / sqrt5>,
                < 0, 0, 0, 4 / sqrt5 >
            ];

        } else if (cells == 8) {           // 8-cell, tesseract
            modelName = "Tesseract (8-cell)";
            edgePath = [    // Edges defined as pairs of vertex indices
                  1, 103, 302, 206, 614, 1410, 1008, 809, 911, 1103, 307,
                  715, 1514, 1412, 1213, 1309, 901, 105, 507, 706, 604,
                  412, 1208, 800,   4, 405, 513, 1315, 1511, 1110, 1002, 200
            ];
            edgeAxis = [ ];                 // Use automatic edge colours
            vertex = [ ];
            for (i = 0; i <= 15; i++) {
                vertex += < vsign(i & 8),
                            vsign(i & 4),
                            vsign(i & 2),
                            vsign(i & 1)
                        >;
            }

        } else if (cells == 16) {       // 16-cell, hexadecachoron
            modelName = "Hexadecachoron (16-cell)";
            edgePath = [   // Edges defined as pairs of vertex indices
                  2,   3,   4,   5,   6,   7,
                102, 103, 104, 105, 106, 107,
                          204, 205, 206, 207,
                          304, 305, 306, 307,
                          406, 407,
                          506, 507
                 ];
            edgeAxis = [ ];             // Use automatic edge colouring
            vertex = [ ];
            for (i = 1; i <= 8; i *= 2) {
                vertex += < ((i & 8) != 0),
                            ((i & 4) != 0),
                            ((i & 2) != 0),
                            ((i & 1) != 0)
                          >;
                vertex += < -((i & 8) != 0),
                            -((i & 4) != 0),
                            -((i & 2) != 0),
                            -((i & 1) != 0)
                        >;
            }

        } else if (cells == 24) {       // 24-cell, icositetrachoron
            vertex = [
                < 1.0, 0.0, 0.0, 0.0 >, < -1.0, 0.0, 0.0, 0.0 >,
                < 0.0, 1.0, 0.0, 0.0 >, < 0.0, -1.0, 0.0, 0.0 >,
                < 0.0, 0.0, 1.0, 0.0 >, < 0.0, 0.0, -1.0, 0.0 >,
                < 0.0, 0.0, 0.0, 1.0 >, < 0.0, 0.0, 0.0, -1.0 >,
                < 0.5, 0.5, 0.5, 0.5 >, < -0.5, 0.5, 0.5, 0.5 >,
                < 0.5, -0.5, 0.5, 0.5 >, < -0.5, -0.5, 0.5, 0.5 >,
                < 0.5, 0.5, -0.5, 0.5 >, < -0.5, 0.5, -0.5, 0.5 >,
                < 0.5, -0.5, -0.5, 0.5 >, < -0.5, -0.5, -0.5, 0.5 >,
                < 0.5, 0.5, 0.5, -0.5 >, < -0.5, 0.5, 0.5, -0.5 >,
                < 0.5, -0.5, 0.5, -0.5 >, < -0.5, -0.5, 0.5, -0.5 >,
                < 0.5, 0.5, -0.5, -0.5 >, < -0.5, 0.5, -0.5, -0.5 >,
                < 0.5, -0.5, -0.5, -0.5 >, < -0.5, -0.5, -0.5, -0.5 >
            ];

            edgePath = [   // Edges defined as pairs of vertex indices
                 8, 10, 12, 14, 16, 18, 20, 22, 109, 111, 113, 115,
                 117, 119, 121, 123, 208, 209, 212, 213, 216, 217, 220,
                 221, 310, 311, 314, 315, 318, 319, 322, 323, 408, 409,
                 410, 411, 416, 417, 418, 419, 512, 513, 514, 515, 520,
                 521, 522, 523, 809, 810, 911, 1011, 1213, 1214, 1315,
                 1415, 812, 913, 1014, 1115, 1617, 1618, 1719, 1819,
                 2021, 2022, 2123, 2223, 1620, 1721, 1822, 1923, 608,
                 609, 610, 611, 612, 613, 614, 615, 716, 717, 718, 719,
                 720, 721, 722, 723, 816, 917, 1018, 1119, 1220, 1321,
                 1422, 1523
            ];

            edgeAxis = [ ];         // Use automatic assignment
        }
        autoColour();
    }

    //  autoColour  --  Assign edge colours automatically if not specified

    autoColour() {
        if (llGetListLength(edgeAxis) == 0) {
            integer nedge = llGetListLength(edgePath);
            integer i;

            for (i = 0; i < nedge; i++) {
                integer edge = llList2Integer(edgePath, i);
                integer from = (integer) (edge / 100);
                integer to = edge % 100;
                rotation v1 = llList2Rot(vertex, from);
                rotation v2 = llList2Rot(vertex, to);
                /*  Colour the edge according to the axis in which
                    it has the greatest extent.  */
                integer colour = 0;
                float maxd = llFabs(v1.x - v2.x);
                float axd;
                if ((axd = llFabs(v1.y - v2.y)) > maxd) {
                    maxd = axd;
                    colour = 1;
                }
                if ((axd = llFabs(v1.z - v2.z)) > maxd) {
                    maxd = axd;
                    colour = 2;
                }
                if ((axd = llFabs(v1.s - v2.s)) > maxd) {
                    maxd = axd;
                    colour = 3;
                }
                edgeAxis += colour;
            }
        }
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    /*  processAuxCommand  --  Process a command.  These commands
                               are used by the client to control
                               menus.  They may appear either
                               in the client's interactive input or
                               in menus or scripts.  */

    integer processAuxCommand(key id, list args) {
        agent = whoDat = id;            // Direct chat output to sender of command

//        string message = llList2String(args, 0);
        args = llDeleteSubList(args, 0, 1);
        integer argn = llGetListLength(args);       // Number of arguments
        string command = llList2String(args, 0);    // The command
        string sparam = llList2String(args, 1);     // First argument, for convenience

        //  Model custom cmd        Custom model definition

        if (abbrP(command, "se") && abbrP(sparam, "mo") && (argn >= 4) &&
            abbrP(llList2String(args, 2), "cu")) {
            sparam = llList2String(args, 3);        // Sub-command
            integer i;

            //  Set model custom begin

            if (abbrP(sparam, "be")) {
                vertex = edgePath = edgeAxis = [ ];

            //  Set model custom colours c1 c2 ...

            } else if (abbrP(sparam, "co")) {
                for (i = 4; i < argn; i++) {
                    integer c = llList2Integer(args, i);
                    if ((c < 0) || (c > 4)) {
                        tawk("Colour " + (string) c + " out of range (0-3).");
                        return FALSE;
                    }
                    edgeAxis += c;
                }

            //  Set model custom edges e1v1 e1v2   e2v1 e2v2 ...

            } else if (abbrP(sparam, "ed")) {
                if ((argn - 4) & 1) {
                    tawk("Must specify even number of edge endpoints.");
                    return FALSE;
                }
                integer nvtx = llGetListLength(vertex);
                for (i = 4; i < argn; i += 2) {
                    integer v1 = llList2Integer(args, i);
                    integer v2 = llList2Integer(args, i + 1);
                    if ((v1 > nvtx) || (v2 > nvtx)) {
                        tawk("Edge vertex pair " + (string) v1 + " " +
                            (string) v2 + " out of range: only " + (string) nvtx +
                            " vertices defined.");
                        return FALSE;
                    }
                    edgePath += (v1 * 100) + v2;
                }

            //  Set model custom end

            } else if (abbrP(sparam, "en")) {
                integer nedge = llGetListLength(edgePath);
                integer nvtx = llGetListLength(vertex);

                //  Assign automatic edge colours if none specified

                autoColour();

                //  Do we have as many edge colours as edges ?
                if (llGetListLength(edgeAxis) != llGetListLength(edgePath)) {
                    tawk("Number of edge colours specified (" +
                        (string) llGetListLength(edgeAxis) + ") unequal to number of edges (" +
                        (string)  llGetListLength(edgePath) + ").");
                    return FALSE;
                }
                //  Verify that all vertices were specified as edge endpoints
                for (i = 0; i < nvtx; i++) {
                    integer j;
                    for (j = 0; j < nedge; j++) {
                        integer ed = llList2Integer(edgePath, j);
                        integer ed1 = (integer) ed / 100;
                        ed = ed % 100;
                        if ((ed == i) || (ed1 == i)) {
                            jump foundvtx;
                        }
                    }
                    tawk("Vertex " + (string) i + " not used in an edge.");
                    return FALSE;
@foundvtx;
                }
                /*  Verify no duplicates among edge specifications.
                    Note that we have to check for either order of
                    vertex specification for the edge.  */
                for (i = 0; i < nedge - 1; i++) {
                    integer j;
                    integer vtxi = llList2Integer(edgePath, i);
                    integer vtxir = ((integer) (vtxi / 100)) + ((vtxi % 100) * 100);
                    if ((vtxi % 100) == (vtxir % 100)) {
                        tawk("Null edge: vertices " + (string) (vtxi % 100) + " to " +
                             (string) (vtxi % 100));
                        return FALSE;
                    }
                    for (j = i + 1; j < nedge; j++) {
                        integer vtxj = llList2Integer(edgePath, j);
                        if ((vtxi == vtxj) || (vtxir == vtxj)) {
                            tawk("Duplicate edge specification for vertices " +
                                (string) ((integer) (vtxi / 100)) + " and " +
                                (string) (vtxi % 100) + ".");
                            return FALSE;
                        }
                    }
                }
                modelName = "Custom";
                llMessageLinked(LINK_THIS, LM_MO_DEFINITION,
                    llList2Json(JSON_ARRAY, [
                        modelName,                          // Model name
                        llList2Json(JSON_ARRAY, vertex),    // List of vertices
                        llList2Json(JSON_ARRAY, edgePath),  // List of edges
                        llList2Json(JSON_ARRAY, edgeAxis)   // Colour indices of edges
                    ]), id);
                    vertex = edgePath = edgeAxis = [ ];

            //  Model custom vertices <x,y,z,w> <x,y,z,w> ...

            } else if (abbrP(sparam, "ve")) {
                for (i = 4; i < argn; i++) {
                    vertex += (rotation) llList2String(args, i);
                }

            } else {
                tawk("Unknown Set model custom command: " + sparam + ".");
                return FALSE;
            }
        }
        return TRUE;
    }

    default {

        state_entry() {
        }

        /*  The link_message() event receives commands from other scripts
            script and passes them on to the script processing functions
            within this script.  */

        link_message(integer sender, integer num, string str, key id) {

            //  LM_MO_SELECT (301): Select model

            if (num == LM_MO_SELECT) {
                selectModel((integer) str);
                llMessageLinked(LINK_THIS, LM_MO_DEFINITION,
                    llList2Json(JSON_ARRAY, [
                        modelName,                          // Model name
                        llList2Json(JSON_ARRAY, vertex),    // List of vertices
                        llList2Json(JSON_ARRAY, edgePath),  // List of edges
                        llList2Json(JSON_ARRAY, edgeAxis)   // Colour indices of edges
                    ]), id);

            //  LM_MO_STAT (302): Report status

            } else if (num == LM_MO_STAT) {
                string stat = "Model generator:";
                stat += "\n";
                integer mFree = llGetFreeMemory();
                integer mUsed = llGetUsedMemory();
                stat += "    Script memory.  Free: " + (string) mFree +
                        "  Used: " + (string) mUsed + " (" +
                        (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)";

                llRegionSayTo(id, PUBLIC_CHANNEL, stat);

            //  LM_CP_COMMAND (223): Process auxiliary command

            } else if (num == LM_CP_COMMAND) {
                processAuxCommand(id, llJson2List(str));
            }
        }
    }
