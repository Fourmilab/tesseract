    /*
                Tesseract Edge Factory
                    by John Walker

        The edge factory reduces the work required to create the
        32 wireframe edges for the Tesseract model.  It rezzes the
        required number of objects, passing each its edge number
        which they place in their object name.  The Edge script is
        replicated in each edge, so updating it only required
        changing the master Edge script in the Factory's inventory
        and generating a new set of edges.

    */

    key owner;                          //  Owner UUID
    string ownerName;                   //  Name of owner

    integer commandChannel = 1889;      // Command channel in chat
    integer commandH;                   // Handle for command channel
    key whoDat = NULL_KEY;              // Avatar who sent command
    integer restrictAccess = 2;         // Access restriction: 0 none, 1 group, 2 owner
    integer echo = TRUE;                // Echo chat and script commands ?

    integer siteIndex = 0;              // Index of last site deployed

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

    //  checkAccess  --  Check if user has permission to send commands

    integer checkAccess(key id) {
        return (restrictAccess == 0) ||
               ((restrictAccess == 1) && llSameGroup(id)) ||
               (id == llGetOwner());
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  arg  --  Extract an argument with a default

    string arg(list args, integer argn, integer narg, string def) {
        if (narg < argn) {
            return llList2String(args, narg);
        }
        return def;
    }

    //  processCommand  --  Process a command

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
            string prefix = ">> ";
            if (fromScript) {
                prefix = "++ ";
            }
            tawk(prefix + message);                 // Echo command to sender
        }

        string lmessage = llToLower(llStringTrim(message, STRING_TRIM));
        list args = llParseString2List(lmessage, [" "], []);    // Command and arguments
        integer argn = llGetListLength(args);       // Number of arguments
        string command = llList2String(args, 0);    // The command

        //  Access who                  Restrict chat command access to public/group/owner

        if (abbrP(command, "ac")) {
            string who = llList2String(args, 1);

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

        //  Build n                      Build n edges

        } else if (abbrP(command, "bu")) {
            if (argn < 2) {
                tawk("Usage: build n_edges");
            } else {
                integer nedges = (integer) arg(args, argn, 1, "32");
                integer i;

                siteIndex = 0;
                for (i = 0; i < nedges; i++) {
                    siteIndex++;
                    buildEdge(siteIndex);
                }
                if (nedges == 1) {
                    tawk("Built edge " + (string) siteIndex);
                } else {
                    tawk("Built edges " + (string) (siteIndex - (nedges - 1)) +
                         "–" + (string) siteIndex);
                }
            }

        /*  Channel n                   Change command channel.  Note that
                                        the channel change is lost on a
                                        script reset.  */
        } else if (abbrP(command, "ch")) {
            integer newch = (integer) llList2String(args, 1);
            if ((newch < 2)) {
                tawk("Invalid channel " + (string) newch + ".");
                return FALSE;
            } else {
                llListenRemove(commandH);
                commandChannel = newch;
                commandH = llListen(commandChannel, "", NULL_KEY, "");
                llSetText("Edge Factory\n/" + (string) commandChannel, < 0, 1, 0 >, 1);
                tawk("Listening on /" + (string) commandChannel);
            }

        //  Clear                       Clear chat for debugging

        } else if (abbrP(command, "cl")) {
            tawk("\n\n\n\n\n\n\n\n\n\n\n\n\n");

        //  Help                        Display help text

        } else if (abbrP(command, "he")) {
            tawk("Edge factor commands:\n" +
                 "  build n_edges\n" +
                 "    n_edges         Number of edges to build\n" +
                 "For additional information, see the Fourmilab Tesseract User Guide"
                );

        } else {
            tawk("Huh?  \"" + message + "\" undefined.  Chat /" +
                (string) commandChannel + " help for instructions.");
            return FALSE;
        }
        return TRUE;
    }

    //  buildEdge  --  Build an edge

    buildEdge(integer edgeno) {

        vector pos = llGetPos();
        vector where = < 1 + (((edgeno - 1) % 8) * 0.1), 0.1 * ((edgeno - 1) / 8), 1 >;

        llRezObject("Edge", pos + where, ZERO_VECTOR, ZERO_ROTATION, edgeno);
    }

    default {

        state_entry() {
            owner = llGetOwner();
            ownerName =  llKey2Name(owner);  //  Save name of owner

            siteIndex = 0;

            llSetText("Edge Factory\n/" + (string) commandChannel, < 0, 1, 0 >, 1);

            //  Start listening on the command chat channel
            commandH = llListen(commandChannel, "", NULL_KEY, "");
            llOwnerSay("Listening on /" + (string) commandChannel);
        }

        /*  The listen event handler processes messages from
            our chat control channel.  */

        listen(integer channel, string name, key id, string message) {
            processCommand(id, message, FALSE);
        }
    }
