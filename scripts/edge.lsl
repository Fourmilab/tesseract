    /*
                        Tesseract Edge

        An instance of this object is linked to the tesseract
        controller for each of its wireframe edges. The edges listen
        for commands from the controller and respond if the message is
        addressed to it.

    */

    integer edgeNumber;                 // Our edge number (from object name)
    float edgeDiam = 0.01;              // Edge diameter

    integer sit = FALSE;                // Is somebody sitting on this edge ?
    key seated = NULL_KEY;              // UUID of seated avatar
    vector sitPos = < 0.6, 0.09, -0.6 >;  // Initial sit position
    vector sitRot = < 0, 90, 0 >;       // Initial sit rotation
    vector camOffset = <0, 0, 2>;       // Offset of camera lens from sit position
    vector camAng = <0, 0, 0>;          // Camera look-at point relative to camOffset

    //  Edge messages
    integer LM_ED_POS = 91;             // Set endpoint positions
    integer LM_ED_PROP = 92;            // Set display properties

    /*  flMoveSittingAvatar  --  Move an avatar sitting on an edge
                                 (specified by its link number or
                                 LINK_THIS) to a new position and
                                 rotation relative to the edge.  */

    flMoveSittingAvatar(integer link, vector pos, rotation rot) {
        key user = llAvatarOnLinkSitTarget(link);
        if (user) {
            vector size = llGetAgentSize(user); // Make sure this is an avatar
            if (size != ZERO_VECTOR) {
                /*  Since there may be avatars sitting on more than one
                    link in an object, search through the link numbers
                    to find the avatar whose key matches the one sitting
                    on this link.  */
                integer linkNum = llGetNumberOfPrims();
                do {
                    if (user == llGetLinkKey(linkNum)) {
                        //  We need to make the position and rotation local to the current prim
                        list local;
                        if (llGetLinkKey(link) != llGetLinkKey(1)) {
                            local = llGetLinkPrimitiveParams(link, [ PRIM_POS_LOCAL, PRIM_ROT_LOCAL ]);
                        }
                        //  Magic numbers to correct for flakiness in sitting avatar position
                        float fAdjust = ((((0.008906 * size.z) + -0.049831) * size.z) + 0.088967) * size.z;
                        llSetLinkPrimitiveParamsFast(linkNum, [
                            PRIM_POS_LOCAL, ((pos + <0, 0, 0.4> - (llRot2Up(rot) * fAdjust)) *
                                llList2Rot(local, 1)) + llList2Vector(local, 0),
                            PRIM_ROT_LOCAL, rot * llList2Rot(local, 1)
                        ]);
                        return;
                    }
                 } while (--linkNum);
            } else {
                //  In case we cannot find the avatar, un-sit the user by key
                llUnSit(user);
            }
        }
    }

    default {

        on_rez(integer start_param) {
            //  If start_param is zero, this is a simple manual rez
            if (start_param > 0) {
                /*  This is a rez from the Edge Factory.  Set the
                    edge number from start_param.  */
                edgeNumber = start_param;
                llSetObjectName("Edge " + (string) edgeNumber);
            }
        }

        state_entry() {
            edgeNumber = (integer) llGetSubString(llGetObjectName(), 4, -1);
            llLinkSitTarget(LINK_THIS, sitPos, llEuler2Rot(sitRot * DEG_TO_RAD));
            llSetLinkCamera(LINK_THIS, camOffset, camAng);
        }

        link_message(integer sender, integer num, string str, key id) {
            list args = llJson2List(str);
            integer dest = llList2Integer(args, 0); // Edge number destination

            //  Only process if global or directed specifically to us
            if ((dest == 0) || (dest == edgeNumber)) {

                /*  LM_ED_POS: Set endpoints of edge, rotating and
                    adjusting the length as required.  If an avatar
                    is sitting on the edge, move it to the midpoint
                    position and orientation along the edge.  */

                if (num == LM_ED_POS) {
                    vector v1 = (vector) llList2String(args, 1);
                    vector v2 = (vector) llList2String(args, 2);
                    float length = llVecDist(v1, v2);
                    vector midPoint = (v1 + v2) / 2;

                    llSetLinkPrimitiveParamsFast(LINK_THIS,
                        [ PRIM_POS_LOCAL, midPoint,
                          PRIM_ROT_LOCAL, llRotBetween(<0, 0, 1>, llVecNorm(v2 - midPoint)),
                          PRIM_SIZE, <edgeDiam, edgeDiam, length> ]);

                    if (sit) {
                        flMoveSittingAvatar(LINK_THIS, sitPos, llEuler2Rot(sitRot * DEG_TO_RAD));
                    }

                /*  LM_ED_PROP: Set display properties
                        0   Edge number destination
                        1   Colour <r, g, b>
                        2   Alpha (0 transparent, 1 solid)
                        3   Diameter of wireframe bar  */

                } else if (num == LM_ED_PROP) {
                    vector csize = llGetScale();
                    edgeDiam = llList2Float(args, 3);
                    llSetLinkPrimitiveParamsFast(LINK_THIS,
                        [ PRIM_COLOR, ALL_SIDES, (vector)
                          llList2String(args, 1), llList2Float(args, 2),
                           PRIM_SIZE, < edgeDiam, edgeDiam, csize.z > ]);
                }
            }
        }

        /*  The changed event handler detects when an avatar
            sits on the edge or stands up and departs.  We need
            to know if somebody is sitting so that we
            can move the seated avatar with the edge while we're
            running the animation.  */

        changed(integer change) {
            seated = llAvatarOnLinkSitTarget(LINK_THIS);
            if (change & CHANGED_LINK) {
                if ((seated == NULL_KEY) && sit) {
                    //  Avatar has stood up, departing
                    sit = FALSE;
                } else if ((!sit) && (seated != NULL_KEY)) {
                    //  Avatar has sat on the edge
                    seated = llAvatarOnSitTarget();
                    sit = TRUE;
                }
            }
        }
    }
