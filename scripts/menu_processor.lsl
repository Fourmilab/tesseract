    /*

                Fourmilab Menu Processor

                    by John Walker

    */

    //  Menu Processor messages
    integer LM_MP_INIT = 270;       // Initialise
    integer LM_MP_RESET = 271;      // Reset menu
    integer LM_MP_STAT = 272;       // Print status
    integer LM_MP_SETTINGS = 273;   // Set operating modes
    integer LM_MP_RESUME = 274;     // Resume script after menu selection
    integer LM_MP_SELECTION = 277;  // Declare commands for selected button

    //  Command processor messages
    integer LM_CP_COMMAND = 223;    // Process command

    key whoDat;                     // User (UUID) who requested script

    key owner;                      // Owner of the object
    key agent = NULL_KEY;           // User, if any
    integer trace = FALSE;          // Generate trace output ?
    integer echo = FALSE;           // Echo menu commands ?

    integer menuChannel;            // Base channel for dialogue communication
    integer menuListen;             // Handle of dialogue listener
    string activeMenuName;          // Name of active menu
    list activeMenuButtons;         // Buttons and commands for displayed menu
    integer menuCommandUnique = 1;  // Uniqueness number for menu-submitted commands
    integer continueMode;           // Does current menu suspend script ?
    integer timeoutButton;          // Does this menu have a "*Timeout*" button ?

    list menuName;                  // Names of defined menus
    list menuContent;               // JSON-encoded content of menus

    //  Under construction menu components
    string mName = "";              // Current menu name
    string mTitle;                  // Menu title
    list mButtons;                  // List of buttons

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

    /*  saneButtons  --  Re-order buttons in a list so they display
                         in a sane manner.  */

    list saneButtons(list buttons) {
        return llList2List(buttons, -3, -1) +
               llList2List(buttons, -6, -4) +
               llList2List(buttons, -9, -7) +
               llList2List(buttons, -12, -10);
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  findMenu  --  Find menu from name.  Returns -1 for no find

    integer findMenu(string mname) {
        integer l = llGetListLength(menuName);
        integer i;
        for (i = 0; i < l; i++) {
            if (mname == llList2String(menuName, i)) {
                return i;
            }
        }
        return -1;
    }

    /*  parseQuotedArgs  --  Parse a command line which may contain
                             quoted strings.  A list of arguments is
                             returned, preserving upper and lower case,
                             with spaces preserved within quoted strings
                             and two consecutive quotes used to force a
                             quote within a string.  */

    list parseQuotedArgs(string message) {
        list qargs;

        while ((message = llStringTrim(message, STRING_TRIM_HEAD)) != "") {
            if (llGetSubString(message, 0, 0) == "\"") {
                string os = "";

                message = llGetSubString(message, 1, -1);
                integer l = llStringLength(message);
                integer e = llSubStringIndex(message, "\"");
                //  Accumulate pieces containing forced quotes
                while ((e >= 0) && (e < l) &&
                       (llGetSubString(message, e + 1, e + 1) == "\"")) {
                    os += llGetSubString(message, 0, e);
                    message = llDeleteSubString(message, 0, e + 1);
                    e = llSubStringIndex(message, "\"");
                }
                if (e > 0) {
                    qargs += os + llGetSubString(message, 0, e - 1);
                    message = llDeleteSubString(message, 0, e);
                } else {
                    tawk("Missing closing quote.");
                    qargs += os + message;
                    message = "";
                }
            } else {
                integer e = llSubStringIndex(message, " ");
                if (e < 0) {
                    qargs += llGetSubString(message, 0, -1);
                    message = "";
                } else {
                    qargs += llGetSubString(message, 0, e - 1);
                    message = llGetSubString(message, e, -1);
                }
            }
        }
        return qargs;
    }

    /*  processButtonPress  --  Process a button press in the active
                                menu.  The button label is passed as
                                message.  */

    processButtonPress(string message, key id) {
        llListenRemove(menuListen);
        menuListen = 0;
        llSetTimerEvent(0);
        integer b;
        integer bn = llGetListLength(activeMenuButtons);
        //  Iterate over buttons in active menu to find button clicked
        for (b = 0; b < bn; b++) {
            /*  Retrieve and decode JSON for this
                button's label and commands.  */
            string bitems = llList2String(activeMenuButtons, b);
            list biteml = llJson2List(bitems);
            //  If button label matches, execute commands
            if (message == llList2String(biteml, 0)) {
                if (llGetListLength(biteml) > 1) {
                    /*  The bcont parameter set to the Script Processor
                        contains the button number, the continue flag,
                        and a unique number to distinguish multiple
                        presses of the same button in the menu in a
                        nested series of menu invocations.  These
                        items are packed into bit fields by the following
                        code.  Three bits in the 0xF00 field remain
                        available for flags to be added in the future.  */
                    integer bcont = b | (menuCommandUnique << 12);
                    menuCommandUnique++;
                    if (continueMode) {
                        bcont = bcont | 0x100;
                    }
                    //  Send the commands to the Script processor for execution
                    llMessageLinked(LINK_THIS, LM_MP_SELECTION,
                        llList2Json(JSON_ARRAY, [ activeMenuName, bcont ] +
                            llList2List(biteml, 1, -1)), id);
                } else {
                    //  Send resume to client after null action button
                    if (!continueMode) {
                        llMessageLinked(LINK_THIS, LM_MP_RESUME, "", id);
                    }
                }
                continueMode = FALSE;
                jump foundButton;
            }
        }
        if (trace) {
            tawk("Clicked button \"" + message + "\" not found in active menu.");
        }
@foundButton;
        activeMenuButtons = [ ];
    }

    /*  processAuxCommand  --  Process a command.  These commands
                               are used by the client to control
                               menus.  They may appear either
                               in the client's interactive input or
                               in menus or scripts.  */

    integer processAuxCommand(key id, list args) {

        agent = whoDat = id;            // Direct chat output to sender of command

        string message = llList2String(args, 0);
        args = llDeleteSubList(args, 0, 1);
        integer argn = llGetListLength(args);       // Number of arguments
        string command = llList2String(args, 0);    // The command
        string sparam = llList2String(args, 1);     // First argument, for convenience

        //  Menu                        Menu commands

        if (abbrP(command, "me") && (argn >= 2)) {

            //  Menu begin name "Menu text"

            if (abbrP(sparam, "be")) {
                if (mName != "") {
                    tawk("Menu " + mName + " still being defined.");
                    return FALSE;
                }
                list qa = parseQuotedArgs(message);
                if (llGetListLength(qa) < 4) {
                    tawk("Menu name and/or title missing.");
                    return FALSE;
                }
                mName = llList2String(qa, 2);
                integer n = findMenu(mName);
                if (n >= 0) {
                    //  Menu is already defined.  Delete previous definition
                    menuName = llDeleteSubList(menuName, n, n);
                    menuContent = llDeleteSubList(menuContent, n, n);
                    if (trace) {
                        tawk("Redefined menu " + mName);
                    }
                }
                mTitle = llList2String(qa, 3);
                mButtons = [ ];

            //  Menu button "Label" "Command; Command; Command..."

            } else if (abbrP(sparam, "bu")) {
                if (mName == "") {
                    tawk("No menu being defined.");
                    return FALSE;
                }
                list qa = parseQuotedArgs(message);
                if (llGetListLength(qa) < 3) {
                    tawk("Button must have label.");
                    return FALSE;
                }
                mButtons += llList2Json(JSON_ARRAY, llList2List(qa, 2, -1));

            //  Menu delete name

            } else if (abbrP(sparam, "de")) {
                if (argn > 2) {
                    string mname = llList2String(parseQuotedArgs(message), 2);
                    integer n = findMenu(mname);
                    if (n >= 0) {
                        menuName = llDeleteSubList(menuName, n, n);
                        menuContent = llDeleteSubList(menuContent, n, n);
                    } else {
                        tawk("No such menu.");
                        return FALSE;
                    }
                }

            //  Menu end

            } else if (abbrP(sparam, "en")) {
                if (mName == "") {
                    tawk("No menu being defined.");
                    return FALSE;
                }
                menuName += mName;
                menuContent += llList2Json(JSON_ARRAY,
                    [ mTitle, llList2Json(JSON_ARRAY, mButtons) ]);
                mName = "";
                mButtons = [ ];

            //  Menu kill

            } else if (abbrP(sparam, "ki")) {
                /*  Stop listening to current menu.  There is, of
                    course, no way to close its display on the screen.  */
                if (menuListen != 0) {
                    llListenRemove(menuListen);
                    menuListen = 0;
                    llSetTimerEvent(0);
                    if (!continueMode) {
                        llMessageLinked(LINK_THIS, LM_MP_RESUME, "Kill", whoDat);
                    }
                    continueMode = FALSE;
                }

            //  Menu list [ name ]

            } else if (abbrP(sparam, "li")) {
                list qa = parseQuotedArgs(message);
                if (llGetListLength(qa) < 3) {
                    integer l = llGetListLength(menuName);
                    integer i;
                    for (i = 0; i < l; i++) {
                        string title = llList2String(llJson2List(
                            llList2String(menuContent, i)), 0);
                        tawk("  " + llList2String(menuName, i) + "  " + title);
                    }
                } else {
                    string mname = llList2String(qa, 2);
                    //  Look up menu and get its index
                    integer n = findMenu(mname);
                    if (n >= 0) {
                        //  Retrieve and decode menu content JSON
                        string mcs = llList2String(menuContent, n);
                        list mcl = llJson2List(mcs);
                        tawk(mname + "  \"" + llList2String(mcl, 0) + "\"");
                        //  Extract button definitions JSON from content
                        string buts = llList2String(mcl, 1);
                        list butl = llJson2List(buts);
                        integer b;
                        integer bn = llGetListLength(butl);
                        //  Iterate over buttons in menu
                        for (b = 0; b < bn; b++) {
                            /*  Retrieve and decode JSON for this
                                button's label and commands.  */
                            string bitems = llList2String(butl, b);
                            list biteml = llJson2List(bitems);
                            //  List button label
                            tawk("  " + llList2String(biteml, 0));
                            integer c;
                            integer cl = llGetListLength(biteml);
                            //  Iterate over commands and list them
                            for (c = 1; c < cl; c++) {
                                tawk("    " + llList2String(biteml, c));
                            }
                        }
                    } else {
                        tawk("No such menu.");
                        return FALSE;
                    }
                }

            //  Menu reset

            } else if (abbrP(sparam, "re")) {
                mName = "";
                menuName = [ ];
                menuContent = [ ];

                if (menuListen != 0) {
                    llListenRemove(menuListen);
                    menuListen = 0;
                    llSetTimerEvent(0);
                }

            //  Menu show name [ continue ]

            } else if (abbrP(sparam, "sh")) {
                if (argn > 2) {
                    list buttons;

                    list qa = parseQuotedArgs(message);
                    string mname = llList2String(qa, 2);
                    //  Look up menu and get its index
                    integer n = findMenu(mname);
                    if (n >= 0) {
                        //  Retrieve and decode menu content JSON
                        string mcs = llList2String(menuContent, n);
                        list mcl = llJson2List(mcs);
                        //  Extract button definitions JSON from content
                        string buts = llList2String(mcl, 1);
                        list butl = llJson2List(buts);
                        integer b;
                        integer bn = llGetListLength(butl);
                        timeoutButton = FALSE;
                        //  Iterate over buttons in menu
                        for (b = 0; b < bn; b++) {
                            /*  Retrieve and decode JSON for this
                                button's label and commands.  */
                            string bitems = llList2String(butl, b);
                            list biteml = llJson2List(bitems);
                            //  Add button label to list
                            string blabel = llList2String(biteml, 0);
                            if (blabel != "*Timeout*") {
                                timeoutButton = TRUE;
                                buttons += llList2String(biteml, 0);
                            }
                        }

                        continueMode = (llGetListLength(qa) > 4) &&
                            abbrP(llList2String(qa, 3), "co");

                        if (menuListen != 0) {
                            llListenRemove(menuListen);
                            menuListen = 0;
                        }
                        menuListen = llListen(menuChannel, "", id, "");
                        activeMenuName = mname;
                        activeMenuButtons = butl;
                        llSetTimerEvent(60);
                        llDialog(id, llList2String(mcl, 0),
                            saneButtons(buttons), menuChannel);
                    } else {
                        tawk("No such menu.");
                        return FALSE;
                    }
                }
            } else {
                tawk("Unknown menu command.");
            }
        }
        return TRUE;
    }

    default {

        on_rez(integer start_param) {
            llResetScript();
        }

        state_entry() {
            owner = llGetOwner();
            menuChannel = -982449844 ^ ((integer) ("0x" + (string) llGetKey()) & 0xFFFF);
        }

        /*  The link_message() event receives commands from the client
            script and passes them on to the script processing functions
            within this script.  */

        link_message(integer sender, integer num, string str, key id) {
            whoDat = id;

            //  LM_MP_INIT (270): Initialise script processor

            if (num == LM_MP_INIT) {

            //  LM_MP_RESET (271): Reset script

            } else if (num == LM_MP_RESET) {
                llResetScript();

            //  LM_MP_STAT (272): Report status

            } else if (num == LM_MP_STAT) {
                string stat = "Menu processor:";
                stat += "\n";
                if (menuName != [ ]) {
                    stat += "    Menus: " + llList2CSV(menuName) + "\n";
                }
                integer mFree = llGetFreeMemory();
                integer mUsed = llGetUsedMemory();
                stat += "    Script memory.  Free: " + (string) mFree +
                        "  Used: " + (string) mUsed + " (" +
                        (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)";

                llRegionSayTo(id, PUBLIC_CHANNEL, stat);

            //  LM_MP_SETTINGS (273): Set processing modes

            } else if (num == LM_MP_SETTINGS) {
                list args = llCSV2List(str);
                trace = llList2Integer(args, 0);
                echo = llList2Integer(args, 1);

            //  LM_CP_COMMAND (223): Process auxiliary command

            } else if (num == LM_CP_COMMAND) {
                processAuxCommand(id, llJson2List(str));
            }
        }

        //  The listen event receives click messages from the menu

        listen(integer channel, string name, key id, string message) {
            if (channel == menuChannel) {
                if (trace) {
                    tawk("User clicked menu button \"" + message + "\"");
                }
                processButtonPress(message, id);
            }
        }

        /*  The timer event is used to remove the listener if the
            user does not click on the menu in a decent interval.  */

        timer() {
            if (menuListen != 0) {
                if (trace) {
                    tawk("Menu timed out");
                }
                if (timeoutButton) {
                    processButtonPress("*Timeout*", whoDat);
                } else {
                    llListenRemove(menuListen);
                    menuListen = 0;
                    llSetTimerEvent(0);
                    //  Resume script after menu times out
                    if (!continueMode) {
                        llMessageLinked(LINK_THIS, LM_MP_RESUME, "Timeout", whoDat);
                    }
                    continueMode = FALSE;
                }
            }
        }
    }
