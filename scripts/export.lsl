    /*

                        Fourmilab Tesseract

                   Export Model (Original or View)

    */

    key whoDat;                         // User (UUID) who requested script

    key owner;                          // Owner of the object

    string modelName;                   // Model name
    list vertex;                        // Model vertex array
    list edgePath;                      // Edges defined as pairs of vertex indices
    list edgeAxis;                      // Local axis along which this 4D edge runs
    integer nVertex;                    // Number of vertices
    integer nEdges;                     // Number of edges in current model

    //  Export messages
//  integer LM_EX_EXMODEL = 331;        // Export current model from Projections
//  integer LM_EX_EXVIEW = 332;         // Export current view from Projections
    integer LM_EX_DATA = 333;           // Export data from Projections
    integer LM_EX_STAT = 334;           // Print status

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

    //  ef  --  Edit floats in string to parsimonious representation

    string efr(rotation r) {        // Helper that takes a rotation argument
        return ef((string) r);
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

    //  exportModel  --  Output model definition to local chat

    exportModel() {
        string s = "\n#   " + modelName + "\nSet model custom begin\n";

        //  Vertices
        string prefix = "Set model custom vertices";
        string l = prefix;
        integer i;
        for (i = 0; i < nVertex; i++) {
            string vs = " " + efr(llList2Rot(vertex, i));
            if ((llStringLength(l) + llStringLength(vs)) > 80) {
                s += l + "\n";
                if (llStringLength(s) > 940) {
                    tawk(llGetSubString(s, 0, -2));
                    s = "(continued)\n";
                }
                l = prefix;
            }
            l += vs;
        }
        s += l + "\n";

        //  Edges
        prefix = "Set model custom edges";
        l = prefix;
        for (i = 0; i < nEdges; i++) {
            integer e = llList2Integer(edgePath, i);
            string es = " " + (string) ((integer) (e / 100)) +
                        " " + (string) (e % 100) + " ";
            if ((llStringLength(l) + llStringLength(es)) > 80) {
                s += llGetSubString(l, 0, -2) + "\n";
                if (llStringLength(s) > 940) {
                    tawk(llGetSubString(s, 0, -2));
                    s = "(continued)\n";
                }
                l = prefix;
            }
            l += es;
        }
        s += llGetSubString(l, 0, -2) + "\n";
        if (llStringLength(s) > 940) {
            tawk(llGetSubString(s, 0, -2));
            s = "(continued)\n";
        }

        //  Edge colours
        prefix = "Set model custom colours";
        l = prefix;
        integer nc = llGetListLength(edgeAxis);
        for (i = 0; i < nc; i++) {
            string cs = " " + (string) llList2Integer(edgeAxis, i);
            if ((llStringLength(l) + llStringLength(cs)) > 80) {
                s += l + "\n";
                if (llStringLength(s) > 940) {
                    tawk(llGetSubString(s, 0, -2));
                    s = "(continued)\n";
                }
                l = prefix;
            }
            l += cs;
        }
        s += l + "\n";
        if (llStringLength(s) > 940) {
            tawk(llGetSubString(s, 0, -2));
            s = "(continued)\n";
        }

        s += "Set model custom end";
        tawk(s);
    }

    default {

        state_entry() {
            whoDat = owner = llGetOwner();
        }

        /*  The link_message() event receives commands from other scripts
            script and passes them on to the script processing functions
            within this script.  */

        link_message(integer sender, integer num, string str, key id) {

            //  LM_EX_DATA (333): Export data for model

            if (num == LM_EX_DATA) {
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

                exportModel();

            //  LM_EX_STAT (334): Report status

            } else if (num == LM_EX_STAT) {
                string stat = "Model export:";
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
