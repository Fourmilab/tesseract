    /*

                        Fourmilab Tesseract

                  Four-Dimensional Model Definitions

    */

    string modelName;                   // Model name
    list vertex;                        // Unit tesseract vertex array
    integer nVertex;                    // Number of vertices
    integer nEdges;                     // Number of edges in current model
    list edgePath;                      // Edges defined as pairs of vertex indices
    list edgeAxis;                      // Local axis along which this 4D edge runs

    //  Model messages
    integer LM_MO_SELECT = 301;         // Get model definition
    integer LM_MO_STAT = 302;           // Print status
    integer LM_MO_DEFINITION = 303;     // Report model definition to requester

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
            edgePath = [
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
            edgeAxis = [    // Local axis along which this 4D edge runs
                3, 2, 3, 1, 0, 1, 2, 3, 2, 0, 1, 0, 3, 2, 3, 1, // 0 X, 1 Y, 2 Z, 3 W
                0, 1, 2, 3, 2, 0, 1, 0, 1, 3, 0, 2, 1, 3, 0, 2 ];
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
            edgePath = [
                  2,   3,   4,   5,   6,   7,
                102, 103, 104, 105, 106, 107,
                          204, 205, 206, 207,
                          304, 305, 306, 307,
                          406, 407,
                          506, 507
                 ];
            edgeAxis = [    // Local axis along which this 4D edge runs
                0, 0, 0, 0, 0, 0,
                1, 1, 1, 1, 1, 1,
                2, 2, 2, 2, 2, 2,
                3, 3, 3, 3, 3, 3
            ];
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
                < -2, 0, 0, 0 >,
                < 0, -2, 0, 0 >,
                < 0, 0 -2, 0 >,
                < 0, 0, 0, -2 >,
                < 2, 0, 0, 0 >,
                < 0, 2, 0, 0 >,
                < 0, 0, 2, 0 >,
                < 0, 0, 0, 2 >,
                < -1, -1, -1, -1 >,
                < -1, -1, -1, 1 >,
                < -1, -1, 1 -1 >,
                < -1, -1, 1, 1 >,
                < -1, 1, -1, -1 >,
                < -1, 1, -1, 1 >,
                < -1, 1, 1, -1 >,
                < -1, 1, 1, 1 >,
                < 1, -1, -1, -1 >,
                < 1, -1, -1, 1 >,
                < 1, -1, 1, -1 >,
                < 1, -1, 1, 1 >,
                < 1, 1, -1, -1 >,
                < 1, 1, -1, 1 >,
                < 1, 1, 1, -1 >,
                < 1, 1, 1, 1 >
            ];

            edgePath = [
                8, 809, 900, 810, 1000, 108, 901, 1001, 1011, 1100,
                911, 1101, 812, 1200, 208, 902, 1202, 1213, 1300, 913,
                1302, 308, 1003, 1203, 1214, 1400, 1014, 1403, 816,
                1601, 1602, 917, 1701, 1702, 1617, 1603, 1018, 1801,
                1618, 1803, 1620, 2002, 2003, 1220, 1415, 1500, 1315,
                512, 1305, 1405, 1505, 1115, 610, 1106, 1406, 1506,
                709, 1107, 1307, 1507, 1119, 1901, 1819, 1806, 1906,
                1707, 1719, 1907, 1721, 2102, 1321, 2107, 416, 1704,
                1804, 1904, 2004, 2021, 2104, 2022, 2203, 1822, 2204,
                2005, 2105, 1422, 2205, 2206, 2223, 2304, 2123, 2305,
                1923, 2306, 2307, 1523
            ];

            edgeAxis = [
                0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 0, 0, 0, 1, 1, 1,
                2, 2, 2, 3, 3, 3, 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3,
                0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 0, 0, 0, 1, 1, 1,
                2, 2, 2, 3, 3, 3, 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3,
                0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 0, 0, 0, 1, 1, 1,
                2, 2, 2, 3, 3, 3
            ];
        }

        nVertex = llGetListLength(vertex);      // Number of vertices
        nEdges = llGetListLength(edgePath);     // Number of edges
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
            }
        }

    }
