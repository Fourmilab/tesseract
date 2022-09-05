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

    //  Command processor messages

    integer LM_CP_COMMAND = 223;        // Process command

    //  Menu Processor messages
//  integer LM_MP_INIT = 270;           // Initialise
    integer LM_MP_RESET = 271;          // Reset script
    integer LM_MP_STAT = 272;           // Print status
    integer LM_MP_SETTINGS = 273;       // Set operating modes
    integer LM_MP_RESUME = 274;         // Resume script after menu selection

    //  Model messages
    integer LM_MO_SELECT = 301;         // Get model definition
    integer LM_MO_STAT = 302;           // Print status
//  integer LM_MO_DEFINITION = 303;     // Report model definition to requester
    integer LM_MO_CUSTOM = 304;         // Define custom model

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
                llMessageLinked(LINK_THIS, LM_PR_MTXRESET, "2", whoDat);
            } else if (abbrP(sparam, "re")) {
                llMessageLinked(LINK_THIS, LM_PR_MTXRESET, "3", whoDat);
                llMessageLinked(LINK_THIS, LM_PR_UPDPROJ, "", whoDat);
            } else {
                list planes = [ "xy", 1, 2, "xz", 1, 3, "xw", 1, 4,
                                "yz", 2, 3, "yw", 2, 4,
                                "zw", 3, 4 ];
                integer pindex = llListFindList(planes, [ sparam ]);
                if (pindex >= 0) {
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

                //  Set diameter n
                } else if (abbrP(sparam, "di")) {
                    edgeDiam = (float) svalue;
                    sendProjSettings(2);

                //  Set echo on/off

                } else if (abbrP(sparam, "ec")) {
                    echo = onOff(svalue);
                    sendSettings();

                //  Set hide on/off/auto

                } else if (abbrP(sparam, "hi")) {
                    if (abbrP(svalue, "au")) {
                        hide = 2;
                    } else {
                        hide = onOff(svalue);
                    }
                    sendProjSettings(0);

                //  Set mega off

                } else if (abbrP(sparam, "me") && (argn >= 3) &&
                           abbrP(svalue, "of")) {
                    llRequestPermissions(owner, PERMISSION_CHANGE_LINKS);

                //  Set model 5/pentachoron/8/tesseract/16/hexadecachoron
                //  Set model custom begin/edge/vertex/colours/end params...

                } else if (abbrP(sparam, "mo")) {
                    if (abbrP(svalue, "cu")) {
                        llMessageLinked(LINK_THIS, LM_CP_COMMAND,
                            llList2Json(JSON_ARRAY, [ message, lmessage ] + args), whoDat);
                    } else {
                        integer mod;
                        if (abbrP(svalue, "5") || abbrP(svalue, "pe")) {
                            mod = 5;
                        } else if (abbrP(svalue, "8") || abbrP(svalue, "te")) {
                            mod = 8;
                        } else if (abbrP(svalue, "16") || abbrP(svalue, "he")) {
                            mod = 16;
                        } else if (abbrP(svalue, "24") || abbrP(svalue, "ic")) {
                            if (llGetNumberOfPrims() >= 97) {
                                mod = 24;
                            } else {
                                tawk("Not configured for objects this complicated.  Use \"Mega\" version.");
                                return FALSE;
                            }
                        } else {
                            tawk("Unknown model.");
                            return FALSE;
                        }
                        llMessageLinked(LINK_THIS, LM_MO_SELECT, (string) mod, whoDat);
                    }

                //  Set name Object name

                } else if (abbrP(sparam, "na")) {
                    integer naPos = llSubStringIndex(lmessage, "na");
                    string t1 = llGetSubString(message, naPos + 2, -1);
                    llSetObjectName(llStringTrim(llGetSubString(t1, llSubStringIndex(t1, " ") + 1, -1),
                        STRING_TRIM_HEAD));

                //  Set position <x, y, z>

                } else if (abbrP(sparam, "po")) {
                    globalPos = (vector) svalue;
                    sendProjSettings(1);

                //  Set projection parallel=orthographic/perspective

                } else if (abbrP(sparam, "pr")) {
                    perspective = abbrP(svalue, "pe");
                    sendProjSettings(1);

                //  Set scale n

                } else if (abbrP(sparam, "sc")) {
                    globalScale = (float) svalue;
                    sendProjSettings(1);

                //  Set tick n

                } else if (abbrP(sparam, "ti")) {
                    timerTick = (float) svalue;
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

        /*  The run_time_permissions event is used by
            Set mega off to prune extra edges beyond those
            required (32) for the tesseract.  */

        run_time_permissions(integer which) {
            if (which & PERMISSION_CHANGE_LINKS) {
                integer n;
                integer np = llGetNumberOfPrims();

                for (n = 1; n < np; n++) {
                    string lname = llGetLinkName(n);
                    if ((llGetSubString(lname, 0, 4) == "Edge ") &&
                        (((integer) llGetSubString(lname, 5, -1)) > 32)) {
                            llSetLinkAlpha(n, 1, ALL_SIDES);
                            llBreakLink(n);
                            n--;
                    }
                }
                llResetScript();
            }
        }
     }
