"Craverly Heights by Ryan Veeder - A ZIL exercise by Henrik Åsman"

<CONSTANT GAME-TITLE "Craverly Heights">
<CONSTANT GAME-DESCRIPTION 
"An Interactive Fiction by Ryan Veeder|
Ported to ZIL by Henrik Åsman, with kind permission of the author.">

;"-----------------------------------------------------------------------------"
;" Volume - Boring"
;"-----------------------------------------------------------------------------"

;"*******************************************************
  * XZIP (z5) compiles to a Z5 game. The code also can  *
  * compile to ZIP (z3), EZIP (z4) or 8 (z8) but XZIP   *
  * recommended.                                        *
  *                                                     *
  * <VERSION ...> is in an external file to enable the  *
  * bat-script to generate all z-machine versions.      *
  * Otherwise you would have <VERSION XZIP> here.       *
  *                                                     *
  * The original has                                    *
  *     IFID = D3C6DFB8-3327-4181-886A-64ABA4512F8C     *
  *******************************************************"
  
<INSERT-FILE "version">

<VERSION? (ZIP <VERSION ZIP TIME>)>		;"Change to time presentation if z3"
<CONSTANT RELEASEID 2>
<CONSTANT IFID-ARRAY <PTABLE (STRING) "UUID://C2586C17-0345-47D0-BD9E-9B738628F425//">>

;"******************************************************* 
  * Define game specific flags that indicates states of *
  * rooms and objects. These flags are added to the     *
  * predefined in the ZILF standard library.            *
  *******************************************************"

<SETG EXTRA-FLAGS
    (
    BACKSTAGE               ;"Room is a backstage room, default rooms are onstage."
    DEADBIT                 ;"Indicates if the person is dead (or alive)."
    GREETBIT                ;"Flag to handle greet words like HI and HELLO."
    )>

;"*******************************************************
  * This is the ZIL programs entry point. Perform basic *
  * initialisation and conclude with a call to the      *
  * parsers main loop in the standard library.          *
  *******************************************************"

<ROUTINE GO ()
	;"Init clock to 12:00 if it is compiled to z3 <VERSION ZIP TIME>"
	<VERSION? (ZIP
		<SETG SCORE 12>
		<SETG MOVES 0>)>
    <CRLF>
    <INIT-STATUS-LINE>
    <V-VERSION>
    <CRLF>
    <PUTP PLAYER ,P?CAPACITY 50> ;"Default SIZE of an object is 5. This limits the inventory to 10 objects." 
    <SETG HERE ,HOSPITAL>
    <MOVE ,PLAYER ,HERE>
    <SETG MODE ,VERBOSE>         ;"Start game in VERBOSE, just like Inform7."
    <SETG SUSPECT ,PAULINE>
    <V-LOOK>
    <MAIN-LOOP>>

;"*******************************************************
  * Include ZILF standard library. Many routines will   *
  * be rewritten later on. See the end of the file.     *
  *                                                     *
  * The main loop iterates through these steps and then *
  * repeats:                                            *
  * 1. Parse input                                      *
  * 2. If parsing is succesful, call routines in this   *
  *    order:                                           *
  *     ACTION prop of WINNER (with M-WINNER)           *
  *     ACTION prop of WINNER's location (with M-BEG)   *
  *     Verb preaction                                  *
  *     CONTFCN prop of PRSI's location                 *
  *     ACTION prop of PRSI                             *
  *     CONTFCN prop of PRSO's location                 *
  *     ACTION prop of PRSO                             *
  *     Verb action                                     *
  *     ACTION prop of WINNER's location (with M-END)   *
  *     Queued interrupts                               *
  *******************************************************"

<INSERT-FILE "zillib/parser">

;"*******************************************************
  * Define some short routines that will make life      *
  * easier later on and reduce the typing a bit.        *
  *******************************************************"

;"*******************************************************
  * This routine returns true if a container or surface *
  * is empty. This is used to mimic the look and feel   *
  * of Inform7, where these only appears in room        *
  * descriptions when they contain something.           *
  *******************************************************"

<ROUTINE CONTAINER-EMPTY? (O "AUX" (N 0))
    <MAP-CONTENTS (F .O)
        <SET N <+ .N 1>>>
    <COND (<==? .N 0> <RTRUE>)
          (ELSE <RFALSE>)>>

;"*******************************************************
  * This routine pick items from a LTABLE in order and  *
  * returns it. When end is reached the last item is    *
  * returned indefinitely. The table, which should be   *
  * an LTABLE with word elements. The first element of  *
  * the table (after the length word) is used as a      *
  * counter and must be 2 initially.                    *
  * See also, for example, PICK-ONE and PICK-ONE-R.     *
  *******************************************************"

<ROUTINE PICK-IN-ORDER (TABL "AUX" (LENGTH <GET .TABL 0>) (CNT <GET .TABL 1>) MSG)
    <SET MSG <GET .TABL .CNT>>
    <COND (<L? .CNT .LENGTH> 
           <SET CNT <+ 1 .CNT>>
           <PUT .TABL 1 .CNT>)>
    <RETURN .MSG>>

<ROUTINE SID? () <RETURN <FSET? ,SUNGLASSES ,WORNBIT>>>     ;"Am I Sid or Dr. Langridge?"
<ROUTINE DEAD? (O) <RETURN <FSET? .O ,DEADBIT>>>            ;"Is actor dead?"
<ROUTINE ALIVE? (O) <RETURN <NOT <DEAD? .O>>>>              ;"Is actor alive?"

;"*******************************************************
  * INPUT doesn't work for z3-files. With VERSION? it   *
  * is possible to compile different snippets depending *
  * on which version we target.                         *
  *******************************************************"
  
<VERSION?
	(ZIP
		<ROUTINE WAIT-FOR-KEY ("AUX" (BUF1 <ITABLE NONE 10 (BYTE)>)
									 (BUF2 <ITABLE NONE 10 (BYTE)>))
			<READ .BUF1 .BUF2>>)
	(ELSE <ROUTINE WAIT-FOR-KEY () <INPUT 1>>)>

;"*******************************************************
  * Support for fixed font.                             *
  *******************************************************"
  
<ROUTINE FIXED-FONT-ON () <PUT 0 8 <BOR <GET 0 8> 2>>>
<ROUTINE FIXED-FONT-OFF() <PUT 0 8 <BAND <GET 0 8> -3>>>

;"*******************************************************
  * Add a TELL-TOKEN that checks if the unicode-char    *
  * em-dash can be printed by the interpreter. If not,  *
  * print '-' instead. ZIP & EZIP doesn't support       *
  * UNICODE characters.                                 *
  *******************************************************"

<ADD-TELL-TOKENS
    EM-DASH               <PRINT-EM-DASH>>

<VERSION?
	(ZIP <ROUTINE  PRINT-EM-DASH () <PRINT "-">>)
	(EZIP <ROUTINE  PRINT-EM-DASH () <PRINT "-">>)
	(ELSE
		<ROUTINE PRINT-EM-DASH ()
			<COND (<==? <CHECKU 8212> 0 2> <PRINT "-">)(ELSE <PRINTU 8212>)>>)>

;"*******************************************************
  * This adds a new property to OBJECTs, SDESCFCN and a *
  * global variabel for current name of pseudo-object.  *
  * If a SDESCFCN is defined the specified routine will *
  * be called to print the short name instead of DESC.  *
  * If the pseudo-object name is set and the object is  *
  * a pseudo-object, that name is printed.              *
  * This is to support the different incarnations of    *
  * the sheets of paper and print the names of          *
  * pseudo-objects.                                     *
  *******************************************************"

<PROPDEF SDESCFCN <>>

<GLOBAL PSEUDO-OBJECT-NAME <>>

;"This replaces calls to the builtin PRINTD to this macro instead."
<DEFMAC PRINTD ("ARGS" OBJ)
<FORM DESC-PRINTD !.OBJ>>

;"Check if SDESCFCN is defined. If so call it. 
  If the object is a pseudo-object and a name is defined, 
  print that name, otherwise use default PRINTD."
<ROUTINE DESC-PRINTD (OBJ)
    <COND (<GETP .OBJ ,P?SDESCFCN> <APPLY <GETP .OBJ ,P?SDESCFCN>>)
          (<AND <==? .OBJ ,PSEUDO-OBJECT> ,PSEUDO-OBJECT-NAME> <PRINT ,PSEUDO-OBJECT-NAME>)
          (ELSE <PRINTD!-SOME-NEW-OBLIST-NAME .OBJ>)>>

;"-----------------------------------------------------------------------------"
;" Volume - The World"
;" Book - Generalities"
;" Section - Establishing Rooms And Regions"
;"-----------------------------------------------------------------------------"

;"*******************************************************
  * Define some short routines to quickly determine if  *
  * we're onstage or backstage                          *
  *******************************************************"

<ROUTINE ONSTAGE? () <RETURN <NOT <BACKSTAGE?>>>>
<ROUTINE BACKSTAGE? () <RETURN <FSET? ,HERE ,BACKSTAGE>>>

;"*******************************************************
  * ZILF defines rooms and their connections in one     *
  * swoop. The individual room definitions is done in   *
  * the rooms part.                                     *
  *******************************************************"
  
;"-----------------------------------------------------------------------------"
;" Section - The Boring Verbs"
;"-----------------------------------------------------------------------------"

;"*******************************************************
  * ZIL normally blocks redefinition of previously      *
  * defined routines. By setting REDEFINE to true ZILF  *
  * will allow routines from the earlier included       *
  * standard library to be replaced by newer versions.  *
  *******************************************************"

<SET REDEFINE T>

<SYNTAX LOOK UNDER OBJECT = V-LOOK-UNDER PRE-REQUIRES-LIGHT>

<ROUTINE V-LOOK-UNDER ()
    <COND (<BACKSTAGE?> 
           <TELL "There's nothing under " T ,PRSO "." CR>)
          (ELSE 
           <TELL "You are unable to find anything beneath " T ,PRSO "." CR>)>>

<ROUTINE V-WAIT ()
    <COND (<ONSTAGE?>
           <TELL "You glance around ">
           <COND (<SID?> <TELL "menacingly." CR>)
                 (ELSE <TELL "meaningfully." CR>)>)
          (ELSE <TELL "Time passes." CR>)>>

<SYNTAX TOUCH OBJECT = V-TOUCH>
<SYNONYM TOUCH FEEL>

<ROUTINE V-TOUCH ()
    <COND (<PRSO? ,WINNER>
           <COND (<BACKSTAGE?> <TELL "You feel fine." CR>)
                 (ELSE <TELL "You press a finger against your skin. You are as real as anything else." CR>)>)
          (<FSET? ,PRSO ,PERSONBIT> 
           <COND (<BACKSTAGE?> <TELL "You touch " T ,PRSO ", who tries to shoo you away." CR>)
                 (ELSE <TELL "You put your hand against " T ,PRSO "'s face. " T ,PRSO " looks meaningfully back at you." CR>)>)
          (ELSE 
           <COND (<BACKSTAGE?> <TELL T ,PRSO " feels normal." CR>)
                 (ELSE <TELL "You pause to consider the texture of " T ,PRSO "." CR>)>)>>

;"*******************************************************
  * The KLUDGEBIT is a bit that's always present on the *
  * room object. Using it this way have the effect that *
  * the OBJECT part of the syntax is optional and the   *
  * parser won't prompt for the object if it's missing. *
  * Both 'WAKE UP' and "WAKE UP PAULINE" are valid for  *
  * example.                                            *  
  *******************************************************"

<SYNTAX WAKE OBJECT (FIND KLUDGEBIT) = V-WAKE>
<SYNTAX WAKE UP OBJECT (FIND KLUDGEBIT) = V-WAKE>

<ROUTINE V-WAKE ()
    <COND (<OR <PRSO? ,WINNER> <FSET? ,PRSO ,KLUDGEBIT>>
           <COND (<ONSTAGE?> <TELL "\"Maybe this is all a dream,\" you say, gazing into the distance, but no answer comes." CR>)
                 (ELSE <TELL "This is too stupid to be a dream." CR>)>)
          (<FSET? ,PRSO ,PERSONBIT> <TELL "That seems unnecessary." CR>)
          (ELSE <TELL "You can only do that to something animate." CR>)>>

<SYNTAX THINK = V-THINK>
<SYNTAX CONTEMPLATE = V-THINK>

<ROUTINE V-THINK ()
    <COND (<ONSTAGE?> 
           <COND (<SID?> 
                  <TELL 
"You pause to think. But of course you, Sidney Langridge, can think only of yourself." CR>)
                 (ELSE 
                  <TELL 
"\"I need to think,\" you say, pressing your fingers against your temples. \"The answer is
staring me right in the face, I just know it.\" You squint deeply, the weight of all
Craverly Heights's problems upon your shoulders." CR>)>)
          (ELSE 
           <TELL "You pause to consider what choices have led to this situation." CR>)>>

;"*******************************************************
  * These verbs are not normally defined in ZILF        *
  * standard library. Defining them here requires       *
  * putting a parental guidance on this file, I guess.  *
  *******************************************************"
  
<SYNTAX BOTHER = V-CURSE>
<SYNONYM BOTHER CURSES DRAT DARN SHIT FUCK DAMN>

<ROUTINE V-CURSE ()
    <COND (<BACKSTAGE?> <TELL "If that's what it takes to get you to calm down." CR>)
          (ELSE <TELL "You better control yourself: This is daytime TV." CR>)>>

<ROUTINE V-SING ()
    <COND (<BACKSTAGE?> <TELL "Not one of your talents." CR>)
          (ELSE <TELL "They don't pay you enough." CR>)>>

<SYNTAX SLEEP = V-SLEEP>
<ROUTINE V-SLEEP ()
    <COND (<BACKSTAGE?> <TELL "There's a lot left to do today." CR>)
          (ELSE <TELL "Not on the job." CR>)>>

<SET REDEFINE <>>

;"-----------------------------------------------------------------------------"
;" Section - Miscellaneous Stuff"
;"-----------------------------------------------------------------------------"

<SET REDEFINE T>

;"*******************************************************
  * In order for the parser to recognise a noun it      *
  * needs to be defined as an object.                   *
  *******************************************************"

<OBJECT HELLO
    (IN GLOBAL-OBJECTS)
    (SYNONYM HELLO HI)
    (DESC "hello")
    (FLAGS NDESCBIT NARTICLEBIT GREETBIT)>

;"*******************************************************
  * Create generic objects with synonyms so the parser  *
  * recognises there words and so that the player can   *
  * ask [actor] about [something], where [something]    *
  * can be an object that's not in the room or a more   *
  * abstract concept that's not in the game, like the   *
  * dog Wendell. The response will almost always be     *
  * 'There is no reply.', except for the jewels that is *
  * its own object.                                     *
  * The parser will fail with unrecognised word if they *
  * are not defined and added to the lexicon.           *
  *******************************************************"

<OBJECT GENERIC-PAULINE
    (IN GENERIC-OBJECTS)
    (SYNONYM PAULINE JANINE)
    (DESC "generic")>

<OBJECT GENERIC-WENDELL
    (IN GENERIC-OBJECTS)
    (SYNONYM WENDELL)
    (DESC "generic")>

<OBJECT GENERIC-LEO
    (IN GENERIC-OBJECTS)
    (SYNONYM LEO LEOPOLD)
    (DESC "generic")>

<OBJECT GENERIC-GINA
    (IN GENERIC-OBJECTS)
    (SYNONYM GINA LANE)
    (DESC "generic")>

;"*******************************************************
  * SAY, GREET, TALK TO, TALK TO actor ABOUT and ASK    *
  * actor ABOUT are not standard verbs in the ZILF      *
  * parser and are defined here as TALKING-TO.          *
  * Expressions like FIND PERSONBIT is a instruction to *
  * the parser that, if the second OBJECT isn't         *
  * by the player the parser searches for an object in  *
  * the room that has this flag on iit and uses assumes *
  * the player means that object.                       *
  *******************************************************"

<SYNTAX SAY OBJECT TO OBJECT (FIND PERSONBIT) = V-TALKING-TO>
<SYNTAX GREET OBJECT (FIND PERSONBIT) = V-TALKING-TO>
<SYNTAX TALK TO OBJECT (FIND PERSONBIT) = V-TALKING-TO>
<SYNTAX TALK TO OBJECT (FIND PERSONBIT) ABOUT OBJECT = V-TALKING-TO>
<SYNTAX ASK OBJECT (FIND PERSONBIT) ABOUT OBJECT = V-TALKING-TO>

<ROUTINE V-TALKING-TO () 
    <COND (<FSET? ,PRSO ,GREETBIT> <PERFORM V?TALKING-TO ,PRSI>)
          (<==? ,PRSO ,WINNER> <TELL "Talking to yourself, huh?" CR>)
          (ELSE <TELL "There is no reply." CR>)>>

<ROUTINE V-PUSH ()
    <COND (<PRSO? ,WINNER> <TELL "No, you seem close to the edge." CR>)
          (<NOT <OR <FSET? ,PRSO ,TAKEBIT> <FSET? ,PRSO ,PERSONBIT>>> <PERFORM V?TAKE ,PRSO>)
          (<FSET? ,PRSO ,PERSONBIT> <TELL "That would be less than courteous." CR>)
          (ELSE <POINTLESS "Pushing">)>>

<ROUTINE V-TAKE ()
    <COND (<NOT <OR <FSET? ,PRSO ,TAKEBIT> <FSET? ,PRSO ,PERSONBIT>>> 
           <COND (<ONSTAGE?> <TELL "Moving that is someone else's job." CR>)
                 (ELSE <TELL "That belongs where it is." CR>)>)
          (ELSE <TRY-TAKE ,PRSO>)>>

<SYNTAX LISTEN = V-LISTEN>

<ROUTINE V-LISTEN () <TELL "It's pretty quiet." CR>>

<ROUTINE V-GIVE ()
    <PERFORM ,V?SSHOW ,PRSO ,PRSI>
    <RTRUE>>

;"*******************************************************
  * TAKE instructs parser to try an implicit take.      *
  * HAVE HELD CARRIED are hints to the parser that this *
  * OBJECT must be in the players inventory, otherwise  *
  * the parser issues an error message.                 *
  *******************************************************"

<SYNTAX SHOW OBJECT (TAKE HAVE HELD CARRIED) TO OBJECT (FIND PERSONBIT) = V-SSHOW>
<SYNTAX SHOW OBJECT (FIND PERSONBIT) OBJECT (TAKE HAVE HELD CARRIED) = V-SHOW>

<ROUTINE V-SHOW () 
    <COND (<FSET? ,PRSO ,PERSONBIT> <TELL T ,PRSO " is unimpressed." CR>)
          (ELSE <TELL "You can only do that to something animate." CR>)>>

<ROUTINE V-SSHOW ()
    <PERFORM ,V?SHOW ,PRSI ,PRSO>
    <RTRUE>>

<SET REDEFINE <>>

;"-----------------------------------------------------------------------------"
;" Section - Commonalities Of Onstage Locations"
;"-----------------------------------------------------------------------------"

;"*******************************************************
  * The camera is defined as an object in the local-    *
  * globals. You can then specify it in the GLOBAL      *
  * property on every room where you want it to appear. *
  *******************************************************"

<OBJECT CAMERA
    (SYNONYM CAMERA CAMERAS)
    (IN LOCAL-GLOBALS)
    (DESC "camera")
    (ACTION CAMERA-F)
    (FLAGS NDESCBIT)>
    
<ROUTINE CAMERA-F ()
    <COND (<VERB? EXAMINE> <TELL "You just accidentally glanced at a camera, but they can edit that out." CR>)
          (ELSE <TELL "You're not supposed to acknowledge it." CR>)>>

;"-----------------------------------------------------------------------------"
;" Book - The Rooms Themselves"
;" Part - Gina's Pizzeria"
;"-----------------------------------------------------------------------------"

<ROOM PIZZA
    (DESC "Gina's Pizzeria")
    (IN ROOMS)
    (SOUTH TO E-HALLWAY)
    (ACTION PIZZA-F)
    (FLAGS LIGHTBIT)
    (THINGS (ITALIAN) (FLAG TRICOLOR TRICOLORE) FLAG-F)
    (GLOBAL CAMERA)>

;"*******************************************************
  * THINGS are a type of lightweight objects that are   *
  * perfect to apply responeses to scenery objects      *
  * without having to define the full object.           *
  *******************************************************"
  
<ROUTINE FLAG-F ()
    <SETG PSEUDO-OBJECT-NAME "Italian flag">
    <COND (<VERB? EXAMINE> <TELL 
"The tricolor stands straight and proud and wide and true for all to see, a
symbol of the deep respect and affection that Gina feels toward her heritage." CR>)>>

;"*******************************************************
  * The tablecloth can't be a psuedo-object because it  *
  * is a surface that can hold other objects.           *
  *******************************************************"
  
<OBJECT TABLECLOTH
    (IN PIZZA)
    (SYNONYM TABLECLOTH TABLE TABLES)
    (ADJECTIVE WHITE)
    (DESC "white tablecloth")
    (LDESC 
"Like an expectant canvas is each tablecloth, ready to receive the masterpiece
that is every one of Gina's pizzas.")
    (ACTION TABLECLOTH-F)
    (FLAGS NDESCBIT SURFACEBIT CONTBIT)>

;"*******************************************************
  * To mimic Inform 7 the description of the surface is *
  * handled here instead of automatically. The object   *
  * only listed when it contains other objects.         *
  * About the RTRUE - Every action-routine must return  *
  * true = the action has been handled, or false = the  *
  * action has not been handled by this routine and the *
  * parser then calls the next action-routine in the    *
  * priority order. In this case the last condition     *
  * can be false so here we need to explicitly return   *
  * true to tell the parser that we are finished.       *
  *******************************************************"

<ROUTINE TABLECLOTH-F ()
    <COND (<VERB? EXAMINE> 
           <TELL <GETP ,TABLECLOTH ,P?LDESC> CR>
           <COND (<NOT <CONTAINER-EMPTY? ,TABLECLOTH>> <CRLF> <DESCRIBE-CONTENTS ,TABLECLOTH>)>
           <RTRUE>)>>

<ROUTINE PIZZA-F (RARG)
    <COND (<AND <VERB? LISTEN> <==? .RARG ,M-BEG>>
           <TELL 
"All you hear is the heavy silence of an oven that has not been turned on, the
anticipatory hush of a pizza cutter that lies motionless inside of an unopened drawer.
You hear nothing." CR>)
          (<==? .RARG ,M-LOOK>
           <TELL 
"The tender light of the morning" EM-DASH "or the very early
evening" EM-DASH "casts itself softly against the downy linen
of spotless white tablecloths and the Italian flag hanging from
the wall. The exit is south." CR>
           <COND (<NOT <CONTAINER-EMPTY? ,TABLECLOTH>> <CRLF> <DESCRIBE-CONTENTS ,TABLECLOTH>)>
           <COND (<NOT <LOC ,GINA>>
                  <COND (<NOT <FSET? ,HERE ,TOUCHBIT>>                                                     ;"Print this 1st time only"
                         <TELL CR "\"It looks like Gina's not here yet,\" you announce to the empty room. \"I wonder where she is.\"||The room is silent." CR>)
                        (ELSE
                         <TELL CR "You glance around ">
                         <COND (<SID?> <TELL "menacingly">) (ELSE <TELL "meaningfully">)>
                         <TELL ". Gina is nowhere to be seen." CR>)>)>)>>

;"-----------------------------------------------------------------------------"
;" Section - Gina"
;"-----------------------------------------------------------------------------"

;"*******************************************************
  * GINA starts with no location defined. This means    *
  * that a call to <LOC ,GINA> will return false.       *
  *******************************************************"
  
<OBJECT GINA
    (SYNONYM GINA WOMAN LANE LADY)
    (DESC "Gina")
    (DESCFCN GINA-DESC-F)
    (ACTION GINA-F)
    (FLAGS PERSONBIT FEMALEBIT NARTICLEBIT)>

;"*******************************************************
  * DESCFCN replaces the LDESC and are called a couple  *
  * of times during parsing with different RARG. If the *
  * routine returns false when RARG is M-OBJDESC?, no   *
  * description is printed, otherwise the description   *
  * should be printed when RARG is M-OBJDESC.           *
  *******************************************************"
  
<ROUTINE GINA-DESC-F (RARG)
    <COND (<==? .RARG M-OBJDESC?> <RTRUE>)
          (<==? .RARG M-OBJDESC>
           <COND (<DEAD? ,GINA> <TELL "Gina lies on the floor, dead." CR>)
                 (ELSE <TELL "Gina is here, resolutely straightening things out in anticipation of the day's business." CR>)>)>>

;"*******************************************************
  * ZIL don't have [one of]...[or]...[stopping]         *
  * predefined. Instead the conversation is defined in  *
  * a table that uses PICK-IN-ORDER from above to loop  *
  * through it once. Thereafter repeating the last item *
  * indefinitely.                                       *
  *******************************************************"
  
<GLOBAL TALK-GINA-SID
    <LTABLE 2
"\"Hello, Gina,\" you say, your teeth flashing impishly from between your wily lips.||Gina's face is
a stoic cliff, carved from stone. \"Sid. You're supposed to be in a federal prison.\"||Your cackling
is like an incoming thunderstorm. \"People seem to think so! But I figure, wherever I am is where
I'm supposed to be.\" You smirk."

"\"What are you still doing here?\" asks Gina.||\"Wouldn't you like to know?\" is your menacing reply.">>

<GLOBAL TALK-GINA-PROG-0
    <LTABLE 2
"\"Pauline's insurance has run out,\" you say. Gina's expression descends into concern.||\"She needs a
procedure, or she'll die,\" you continue. \"Is there any way you can pay for it?\"||\"This pizzeria is
barely paying for its own bills,\" says Gina. \"All the money I could have spent to save Pauline's
life, I spent on my dream of becoming a restauranteur.\"||\"We all have to live with our mistakes,\"
you say, \"but Pauline may not have long to live with yours.\"||Gina tries to hide her face."

"\"What about Pauline's father?\" you ask. \"Could he pay for the procedure?\"||\"Doc, Pauline's father
isn't in Antibes.\" Your jaw slackens at the sound of Gina's revelation. \"The fact is, I don't know
who Pauline's father is.\"||Your expression is one of shock.">>

<GLOBAL KISS-GINA
    <LTABLE 2
"\"What are you doing?\" Gina asks as you approach her.||\"Let me show you,\" you say, as you put
your arms around her body and tenderly meet her lips against yours. Gina yields passionately to your
embrace.||But then the moment is over. \"This can never happen again,\" Gina whispers."

"You kiss Gina again. Again you feel the warmth of bodily contact that you have been craving for so
long. Again Gina says that this can never happen again.">>

<ROUTINE GINA-F ()
    <COND (<AND <DEAD? ,GINA> <NOT <VERB? EXAMINE SHOOT>>> <ATTEMPT-TO ,GINA>)
          (<VERB? EXAMINE>
           <COND (<DEAD? ,GINA> <TELL 
"Gina had so much love to give this world" EM-DASH "but now she's dead. Never again will man or woman
taste the delicious pizzas that Gina had to offer. This entepreneur has tossed her last crust." CR>)
                 (ELSE <TELL 
"Gina is clearly in the midst of a valiant attempt to radiate her usual cheer, but her mien is
marred by the looming knowledge of her beloved daughter's ill condition. Her pink blouse is wrinkled,
belying the distraction that bedevils even the most meticulous of worried mothers." CR>)>)
          (<AND <VERB? TALKING-TO> <NOT ,PRSI>>
           <COND (<SID?> <TELL <PICK-IN-ORDER ,TALK-GINA-SID> CR>)
                 (<==? ,PROG 0> <TELL <PICK-IN-ORDER ,TALK-GINA-PROG-0> CR>)
                 (<==? ,PROG 1> <TELL 
"\"Please let me know if there's any news from the hospital,\" Gina says, trying her best not
to break down into an avalanche of motherly tears." CR>)
                 (ELSE <TELL 
"\"What are you still doing here?\" Gina cries. \"Pauline needs to know about her real
father! And so does...her father.\"" CR>)
           >)
          (<VERB? KISS>
           <COND (<SID?> <TELL 
"Gina rebuffs your amorous advance. \"Sidney, I wouldn't kiss you with my dead husband's mouth.\"" CR>)
                 (ELSE <TELL <PICK-IN-ORDER ,KISS-GINA> CR>)>)
          (<AND <VERB? POINT> <==? ,PRSO ,HANDGUN> <==? ,PRSI ,GINA>>

;"*******************************************************
  * ZILF standard library don't have a mechanism for    *
  * calling the objects action-routine after the verbs  *
  * action-routine. Instead we make an explicit call    *
  * to the verbs action-routine.                        *
  *******************************************************"

           <V-POINT>
           <CRLF>
           <COND (<SID?>
                  <COND (<==? ,SUSPECT ,GINA>
                         <COND (<NOT <LOC ,SATCHEL>>
                                <TELL 
"\"I want those jewels, Gina!\" you say, threatening the matronly entepreneur with the shining steel
of your lethal accessory. \"Or do you want your blood all over these nice white tablecloths?\"||
\"Don't shoot, Sid! Here!\" She reveals a satchel, which she throws across the dining room and into
your hand. \"Please, don't shoot me.\"||\"Of course not. I wouldn't hurt you, as long as you played
nice.\" You shake the satchel full of jewels with a satisfied air. \"And you sure did play real nice,\"
you say, smugly." CR>
                                <MOVE ,SATCHEL ,WINNER>)
                               (ELSE <TELL 
"\"There are no more jewels, Sid,\" Gina cries. \"They're all in that bag.\"||\"I was just making
sure,\" you say." CR>)>)
                        (ELSE <TELL 
"Gina reels in shock at the sight of the gun that is pointed her way. She cringes audibly.
You cackle ominously." CR>)>)
                 (ELSE <TELL 
"Gina stares down the barrel of your pistol with a face twisted by incredible shock.||\"Doc!\" she
gasps. \"Put the gun down! You're not thinking straight!\"||\"Or am I?\" you retort." CR>)>)
          (<VERB? SHOOT>
           <COND (<ALIVE? ,PRSO>
            <FSET ,PRSO ,DEADBIT>
            <TELL 
"Your gun screams as if in anger as it ejects its bullet straight into Gina's mortal coil.
If she had any last words, it is too late for them now.||She falls to the floor with a
horrible slump, as dead as her Italian role model, Julius Caesar." CR>
            <COND (<AND <DEAD? ,LEO> <DEAD? ,PAULINE>> <BLOODBATH-ENDING>)>)
           (ELSE <TELL 
"You fire another bullet into Gina's dead body. \"I don't know why I did that,\" you announce." CR>)>)
          (<AND <VERB? SHOW> <==? ,PRSI ,HANDGUN>>
           <COND (<SID?>
            <TELL 
"\"Is that the gun you used to shoot the mayor?\" Gina asks.||\"Nah, this gun is innocent,\" you
say, quickly adding: \"And so am I!\"" CR>)
           (ELSE <TELL 
"Gina regards your gun with a skeptic's pair of eyes. \"Why would a doctor need a gun?\" she asks.||
\"We doctors need a lot of things,\" you answer meaningfully." CR>)>)
          (<AND <VERB? SHOW> <==? ,PRSI ,MAGNIFYING-GLASS>>
           <TELL "\"Are you on the trail of a mystery?\" Gina asks.||\"In my own way, I suppose, I am,\" you say, ">
           <COND (<SID?> <TELL "menacingly">) (ELSE <TELL "meaningfully">)>
           <TELL "." CR>)
          (<AND <VERB? SHOW> <==? ,PRSI ,PHOTO>>
           <COND (<SID?>
                  <COND (<LOC ,SATCHEL> 
                         <TELL "\"That dog's death was as meaningless as your life,\" Gina eloquently states." CR>)
                        (<N==? ,SUSPECT ,LEO>
                         <GINASPEECH>
                         <SETG SUSPECT ,GINA>)
                        (ELSE <TELL 
"\"Where did you get that photo of my daughter's beloved golden retriever Wendell?\" Gina asks indignantly and
accusingly. You lick your lips menacingly.||\"So it's a crime to have a photo of a dog now?\" you ask. \"What
is this world coming to?\"||Gina glares at you." CR>)>)
                 (ELSE <TELL 
"Gina regards the photo sadly. \"Oh, Wendell, you big lug. Why'd you have to leave us?\" she asks.||\"You don't
have any clues to the mystery of his death?\" you ask.||Gina regards you angrily. \"Are you accusing me of
something?\" she asks.||\"Of course not,\" you answer." CR>)>)

;"*******************************************************
  * That you can trigger the GINASPEECH response when   *
  * you are Dr. Langridge in the original is most       *
  * likely an oversight by the author. This version     *
  * first checks if you're the evil twin.               *
  *******************************************************"

          (<AND <VERB? TALKING-TO> <==? ,PRSI ,JEWELS> <SID?>>
           <COND (<LOC ,SATCHEL>
                  <TELL 
"\"You got your jewels. Now, go,\" Gina pouts, her pride hurt by your actions as much as her heart
is hurt by her daughter's illness." CR>)
                 (ELSE 
                  <GINASPEECH>
                  <SETG SUSPECT ,GINA>)>)>>

<ROUTINE GINASPEECH () 
    <TELL <PICK-IN-ORDER ,GINASPEECH-TEXT>>
    <COND (<==? <GET ,GINASPEECH-TEXT 1> 3>
           <TELL EM-DASH>
           <TELL <PICK-IN-ORDER ,GINASPEECH-TEXT>>)>
    <CRLF>>

<GLOBAL GINASPEECH-TEXT
    <LTABLE 2
"\"You can cut the act, Gina. I know that you know that me and Janine killed Wendell the dog because he knew where
we buried the jewels"

"the jewels that you dug up in the train yard while I was in prison,\" you say, holding up the photo of Wendell as
if it were Exhibit A in a courtroom of crime.||\"Maybe that's all true, or maybe not,\" Gina says, \"but I'm not
handing over those jewels.\"||You grimace."

"\"The jewels are mine, Sid!\" Gina says haughtily, her pink blouse rippling with satisfaction.">>

;"-----------------------------------------------------------------------------"
;" Part - Roland Memorial Hospital"
;"-----------------------------------------------------------------------------"

;"*******************************************************
  * Redefining responses for the player. The players    *
  * starting location is specified in the GO-routine.   *
  *******************************************************"
  
<SET REDEFINE T>

<ROUTINE PLAYER-F ()
    <COND (<N==? ,PLAYER ,PRSO>
           <RFALSE>)
          (<VERB? EXAMINE>
           <COND (<BACKSTAGE?> <TELL "You have no idea what you're doing." CR>) 
                 (<SID?> <TELL 
"You are Sidney Langridge, feared and hated in the town of Craverly Heights and beyond. Only in appearance are
you identical to Doctor Langridge, for in words and deeds you are the polar opposite of your do-gooder twin." CR>)
                 (ELSE <TELL 
"You are Doctor Langridge, mentor to some, friend to many, and healer to all of the citizens of Craverly Heights.
Everyone in town knows your name. It is Doctor Langridge." CR>)>)>>

<SET REDEFINE <>>
           
<ROOM HOSPITAL
    (DESC "Roland Memorial Hospital")
    (IN ROOMS)
    (EAST TO N-HALLWAY)
    (ACTION HOSPITAL-F)
    (FLAGS LIGHTBIT)
    (THINGS (<>) (BED) BED-F)
    (GLOBAL CAMERA)>

<ROUTINE HOSPITAL-F (RARG)
    <COND (<AND <VERB? LISTEN> <==? .RARG ,M-BEG>>
           <TELL 
"The whirring and chirping of medical instruments is all around. A worrying commotion">
           <COND (<NOT <SID?>> <TELL 
", to some. But to your ears it is as regular as a heartbeat. As usual as business">)>
           <TELL "." CR> <RTRUE>)
          (<==? .RARG ,M-LOOK>
        <TELL 
"The whirring and chirping of medical instruments is all around" EM-DASH "a worrying commotion">
        <COND (<NOT <SID?>> <TELL 
", to some, but to your ears it is as regular as a heartbeat, as usual as business.
While you walk these sterile halls, you are in your element: the element of health">)>
        <TELL 
". The exit is east." CR>)>>

<ROUTINE BED-F ()
    <SETG PSEUDO-OBJECT-NAME "bed">
    <COND (<VERB? EXAMINE> <TELL 
"For all its convenience-enhancing technological features, this bed is still
a detestable prison in the doe-eyes of its tenant, the invalid Pauline." CR>)>>

;"-----------------------------------------------------------------------------"
;" Section - Pauline"
;"-----------------------------------------------------------------------------"

<OBJECT PAULINE
    (IN HOSPITAL)
    (SYNONYM PAULINE JANINE GIRL WOMAN)
    (DESC "Pauline")
    (DESCFCN PAULINE-DESC-F)
    (ACTION PAULINE-F)
    (FLAGS PERSONBIT FEMALEBIT NARTICLEBIT)>

<ROUTINE PAULINE-DESC-F (RARG)
    <COND (<==? .RARG M-OBJDESC?> <RTRUE>)
          (<==? .RARG M-OBJDESC>
           <COND (<DEAD? ,GINA> <TELL "Pauline's dead body lies motionless in her hospital bed." CR>)
                 (ELSE 
                  <TELL "Pauline, pale and frail, looks up at you ">
                  <COND (<SID?> <TELL "confusedly">) (ELSE <TELL "pleadingly">)>
                  <TELL " from her supine position aboard her hospital bed." CR>)>)>>

<ROUTINE PAULINE-F ()
    <COND (<AND <DEAD? ,PAULINE> <NOT <VERB? EXAMINE SHOOT>>> <ATTEMPT-TO ,PAULINE>)
          (<VERB? EXAMINE>
           <COND (<DEAD? ,GINA> <TELL 
"No longer do Pauline's tender lips draw breath; no longer do her eyes plead for release from
the life of infirmity that had entrapped her." CR>)
                 (ELSE 
                  <TELL "You gaze down ">
                  <COND (<SID?> <TELL "menacingly">) (ELSE <TELL "meaningfully">)>
                  <TELL 
" at Pauline, at her once-soft features cast into sharp relief by the mysterious illness that
wracks her youthful form." CR>
                  <COND (<AND <NOT <FSET? ,PAULINE ,TOUCHBIT>> <ALIVE? ,PAULINE>>
                         <CRLF>
                         <PAULINESPEAK>

;"*******************************************************
  * The TOUCHBIT is normally set the first time an      *
  * is picked up. Here it is used to indicate if        *
  * Pauline already has been examined.                  *
  *******************************************************"
  
                         <FSET ,PAULINE ,TOUCHBIT>)
                        (ELSE <RTRUE>)>)>)
          (<AND <VERB? TALKING-TO> <NOT ,PRSI>> <PAULINESPEAK>)
          (<VERB? KISS>
           <COND (<SID?> <TELL <PICK-IN-ORDER ,KISS-PAULINE-AS-SID> CR>)
                 (ELSE <TELL <PICK-IN-ORDER ,KISS-PAULINE-AS-DR> CR>)>)       
          (<AND <VERB? POINT> <==? ,PRSO ,HANDGUN> <==? ,PRSI ,PAULINE>>
           ;"There is no 'after'-rule in ZILF standard library. We need to call standard-rule before explicit"
           <V-POINT>
           <TELL CR "\"What are you doing?\" Pauline shrieks.||\"You'll see soon enough,\" you say, ">
           <COND (<SID?> <TELL "menacingly">) (ELSE <TELL "meaningfully">)>
           <TELL "." CR>)
          (<VERB? SHOOT>
           <COND (<ALIVE? ,PRSO>
            <FSET ,PRSO ,DEADBIT>
            <TELL 
"You fire into Pauline's chest. The crack of the gunshot is drowned out by her desperate
scream" EM-DASH "but, an instant later, her screaming ends. She's dead." CR>
            <COND (<AND <DEAD? ,LEO> <DEAD? ,GINA>> <BLOODBATH-ENDING>)>)
           (ELSE <TELL 
"You fire another bullet into Pauline's dead body. \"Now she's dead for sure,\" you announce." CR>)>)
          (<AND <VERB? SHOW> <==? ,PRSI ,HANDGUN>>
           <COND (<SID?>
            <TELL "\"Nice gun,\" Pauline says.||\"Thanks,\" you say, menacingly." CR>)
           (ELSE <TELL 
"\"Why would a doctor need a gun?\" Pauline asks, her eyes clouded with innocence.||\"That's a
good question, Pauline. But I can't tell you,\" you say. And then you add: \"Yet.\"" CR>)>)
          (<AND <VERB? SHOW> <==? ,PRSI ,MAGNIFYING-GLASS>>
           <TELL 
"As Pauline looks through the magnifying glass, an expression of befuddlement overtakes her
face. \"Everything is distorted and strange,\" she says.||\"That's ">
           <COND (<SID?> 
                  <TELL "because magnifying glasses are for sucks">) 
                 (ELSE 
                  <TELL 
"in the nature of a lens,\" you respond. \"They can reveal to us the world's secret truths,
or they can show us a bizarre parody of our lives, as if reflected in a funhouse mirror. We
must always be mindful of this, when we gaze through a glass">)>
           <TELL ",\" you say." CR>)
          (<AND <VERB? SHOW> <==? ,PRSI ,PHOTO>>
           <COND (<SID?> <TELL <PICK-IN-ORDER ,SHOW-PAULINE-PHOTO-AS-SID> CR>)
                 (ELSE <TELL <PICK-IN-ORDER ,SHOW-PAULINE-PHOTO-AS-DR> CR>)>)>>

;"*******************************************************
  * Can't initiate the variable here. It's done in GO.  *
  *******************************************************"

<GLOBAL SUSPECT <>>

<ROUTINE PAULINESPEAK ()
    <COND (<SID?> <TELL <PICK-IN-ORDER ,PAULINESPEAK-TO-SID> CR>)
          (<==? ,PROG 0> <TELL <PICK-IN-ORDER ,PAULINESPEAK-PROG-0> CR>)
          (<==? ,PROG 1> <TELL "\"Please let me know if you find out about those test results,\" Pauline pleads." CR>)
          (ELSE <TELL 
"Pauline looks up at you, beautiful tears welling in her still more beautiful eyes. \"Please,
Doctor Langridge! Talk to my father! He might be able to help!\"" CR>)>>

<GLOBAL PAULINESPEAK-TO-SID
    <LTABLE 2
"\"Sidney!\" Pauline's eyes widen as they detect your identity. \"You shouldn't be here! What if the doctor,
your twin, sees you?\"||\"You leave the nerd to me, sugarbabe. I've been dealing with that clamshell since
the day we were both born.\""

"\"You came back for me, Sidney,\" Pauline says, her chest working double-time to force the words out
of her lungs.||\"I sure did, sugarbabe.\"">>

<GLOBAL PAULINESPEAK-PROG-0
    <LTABLE 2
"\"Oh, Doctor Langridge,\" Pauline rasps, \"Tell me some good news.\"||\"I wish I could,\" you say,
\"but the truth is that your condition is getting worse. And the even worse news is that your insurance
won't pay for your procedure.\"||Pauline's lip quivers."

"\"Can't anything be done, Doctor Langridge?\" Pauline asks pitifully.||\"I'll talk to your mother,\"
you say, though your countenance does not indicate confidence.">>

<GLOBAL KISS-PAULINE-AS-SID
    <LTABLE 2
"You plant a long, meaningful kiss on Pauline's quivering lips. \"It's been so long,\" she sighs."

"You kiss Pauline again, for fun. Nobody tells Sidney Langridge not to kiss sick people.">>

<GLOBAL KISS-PAULINE-AS-DR
    <LTABLE 2
"You lean down until your face almost meets Pauline's. \"The Hippocratic Oath warns a doctor not
to give into his or her feelings for a patient,\" you say, \"but an oath can only be kept for so
long.\" Pauline rises weakly to kiss you passionately. The moment is perfect, but it does not
last forever.||\"No one can know about this,\" you say. Pauline nods weakly."

"You kiss Pauline again. She responds with enthusiasm despite her bedridden condition.">>

<GLOBAL SHOW-PAULINE-PHOTO-AS-SID
    <LTABLE 2
"Salty, unhappy tears well up in Pauline's eyes as she regards the image of her beloved dog. \"I miss
him so much,\" she says.||\"But you remember why we killed him, don't you?\" you ask.||\"Of course.
Wendell kept trying to dig up the place where we buried the jewels.\"||\"Yeah, well, right after I
got out of prison I went back to that place, where we buried the jewels. But someone got there first.
Someone dug them up.\"||Pauline gasps. \"But who else knew about the jewels?\"||\"Only one person,\"
you menacingly say."

"\"Have you talked to the one other person who knew about the jewels yet?\" Pauline asks.">>

<GLOBAL SHOW-PAULINE-PHOTO-AS-DR
    <LTABLE 2
"At the sight of her beloved departed dog, Pauline's expression sinks still further into the mire of
melancholy.||\"Oh, Wendell,\" she mourns, on the verge of weeping. \"If only you were here, I wouldn't
feel nearly so awful. If I ever find out who took you from me...\"||\"But Wendell's death was ruled an
accident,\" you say.||Pauline fixes you with as steely a glare as she can muster in her depleted state.
\"You don't believe that, do you?\" she asks.||\"No,\" you say."

"You offer the photo to Pauline again, but she refuses to look at it.">>

;"-----------------------------------------------------------------------------"
;" Part - Craverly Manor"
;"-----------------------------------------------------------------------------"

<ROOM MANOR
    (DESC "Craverly Manor")
    (IN ROOMS)
    (LDESC 
"A gargantuan portrait of the hawk-eyed and hawk-nosed Leopold Craverly
stares down at you from its perch on the mahogany-panelled wall.
The exit is north.")
    (NORTH TO W-HALLWAY)
    (ACTION MANOR-F)
    (FLAGS LIGHTBIT)
    (THINGS (GARGANTUAN) (PORTRAIT PAINTING PICTURE) PORTRAIT-F
            (MAGHOGANY MAGHOGANY-PANELLED WOOD) (WALL PANEL) WALL-F
            (SNAKE HEAD SNAKE-HEADED) (CANE) CANE-F)
    (GLOBAL CAMERA)>

<ROUTINE MANOR-F (RARG)
    <COND (<AND <VERB? LISTEN> <==? .RARG ,M-BEG>>
           <TELL 
"The manor is eerily quiet. The other Craverlies have left; only Leopold lives here now." CR>)>>

<ROUTINE PORTRAIT-F ()
    <SETG PSEUDO-OBJECT-NAME "gargantuan portrait">
    <COND (<VERB? EXAMINE> <TELL 
"The portrait may resemble Craverly even more than does Craverly himself.
Art imitates life, yes: but life is messy, and inaccurate; art is perfect,
and reflects the real world as it really is." CR>)>>

<ROUTINE WALL-F ()
    <SETG PSEUDO-OBJECT-NAME "mahogany-panelled wall">
    <COND (<VERB? EXAMINE> <TELL 
"These stoic walls have enclosed the Craverly clan for generations, ever
since Aloysius Craverly built Craverly Manor and founded Craverly Heights
in the early nineteenth century." CR>)>>

;"-----------------------------------------------------------------------------"
;" Section - Leopold Craverly"
;"-----------------------------------------------------------------------------"

<OBJECT LEO
    (IN MANOR)
    (SYNONYM CRAVERLY MAN)
    (ADJECTIVE LEOPOLD LEO)
    (DESC "Leopold Craverly")
    (DESCFCN LEO-DESC-F)
    (ACTION LEO-F)
    (FLAGS PERSONBIT NARTICLEBIT)>

<ROUTINE LEO-DESC-F (RARG)
    <COND (<==? .RARG M-OBJDESC?> <RTRUE>)>
    <COND (<==? .RARG M-OBJDESC>
           <COND (<DEAD? ,LEO> 
                  <TELL 
"Leopold lies dead on the floor, his stiffening hand still clutching at
the place in his chest where you shot him through the heart." CR>)
                 (ELSE 
                  <TELL 
"Standing beneath the portrait is Leopold Craverly himself, identical
to his own image in every way. He eyes you sternly from his perch atop
his snake-headed cane." CR>)>
        <RTRUE>)>>

<ROUTINE CANE-F ()
    <SETG PSEUDO-OBJECT-NAME "snake-headed cane">
    <COND (<VERB? EXAMINE> 
           <TELL 
"A mystery: Does Leopold carry this sinister cane because of a physical infirmity,
or is its purpose merely to inspire apprehension and respect in those who behold
it? Even you,">
           <COND (<SID?> <TELL "a master criminal">)
                 (ELSE <TELL "the finest doctor in Craverly Heights">)>
           <TELL ", cannot be sure." CR>)
          (<VERB? TAKE> <TELL "That seems to belong to Leopold Craverly." CR>)>>

<GLOBAL SID-SHOT-LEO <>>

<ROUTINE LEO-F ()
    <COND (<AND <DEAD? ,LEO> <NOT <VERB? EXAMINE SHOOT>>> <ATTEMPT-TO ,LEO>)
          (<VERB? EXAMINE>
           <COND (<DEAD? ,LEO> <TELL 
"Leopold thought he would live long enough to see all of his dreams come
true. Now you know that his belief was false." CR>)
                 (ELSE <TELL 
"Though his hair is silver-white, and his eyes have been furrowed by a
lifetime of avarice and cynicism, Leopold still has many years left in
his life, and many goals left to achieve in those years, no matter what
or who stands in his way." CR>
                  <COND (<AND <NOT <FSET? ,LEO ,TOUCHBIT>> <ALIVE? ,LEO>>
                         <CRLF>
                         <LEOSPEAK>
                         <FSET ,LEO ,TOUCHBIT>)
                        (ELSE <RTRUE>)>)>)
          (<AND <VERB? TALKING-TO> <NOT ,PRSI>>
           <LEOSPEAK>)
          (<VERB? KISS>
           <COND (<SID?> <TELL 
"Leopold pushes you away. \"Forget it, Sid. I'm not one of those young people
who melts in half when a criminal comes on to him.\"" CR>)
                 (ELSE 
                  <TELL <PICK-IN-ORDER ,KISS-LEO-AS-DR>>
                  <COND (<==? <GET ,KISS-LEO-AS-DR 1> 3>
                         <TELL EM-DASH>
                         <TELL <PICK-IN-ORDER ,KISS-LEO-AS-DR>>)>
                  <CRLF>)>)
          (<AND <VERB? POINT> <==? ,PRSO ,HANDGUN> <==? ,PRSI ,LEO>>
           <V-POINT>
           <CRLF>
           <COND (<AND <SID?> <==? ,SUSPECT ,LEO>> 
                  <COND (<NOT <LOC ,SATCHEL>> 
                   <TELL 
"\"I want those jewels, old man!\" you say, menacing the silver-haired millionaire with the gleaming barrel
of your murderous weapon. \"Are you going to play along, or are you going to die?\"||\"All right, all right!
Here!\" Leopold draws a satchel out of his pocket and tosses it to you. \"They're all there. Just leave
me be!\"||You feel the heft of the satchel in your hand and smile a smug smile." CR>
                         <MOVE ,SATCHEL ,WINNER>)
                        (ELSE <TELL 
"\"I've already given you the jewels, Sidney,\" Leopold chides.||\"That's right, you did,\" you respond.
\"And don't you forget it!\"" CR>)>)
                 (ELSE 
                  <TELL "Leopold regards the handgun with a cool indifference. \"Put that thing down, ">
                  <COND (<SID?> <TELL "Sidney">) (ELSE <TELL "Langridge">)>
                  <TELL ". You're liable to hurt yourself.\"" CR>)>)
          (<VERB? SHOOT>
           <COND (<ALIVE? ,PRSO>
            <SETG ,SID-SHOT-LEO <SID?>>
            <FSET ,PRSO ,DEADBIT>
            <TELL "\"Come now, ">
            <COND (<SID?> <TELL "Sidney">) (ELSE <TELL "Langridge">)>
            <TELL 
", calm yourself!\" the old man cries, but it is too late for him. You fire the gun into his heart,
the heart that could never bring itself to feel love. It will never feel anything again">
            <COND (<AND <==? ,SUSPECT ,LEO> <SID?> <NOT <LOC ,SATCHEL>>>
                   <TELL ", and you will never find the jewels">)>
            <TELL "||Craverly falls to the floor, dead." CR>
            <COND (<AND <DEAD? ,PAULINE> <DEAD? ,GINA>> <BLOODBATH-ENDING>)>)
           (ELSE <TELL 
"You fire another bullet into Leopold Craverly's dead body. \"That one was for Wendell,\" you say." CR>)>)
          (<AND <VERB? SHOW> <==? ,PRSI ,HANDGUN>>
           <TELL 
"\"A cute toy,\" Craverly says, clearly unimpressed by the instrument of death you present to him.
\"Be careful with it; you might break a window!\" He guffaws enthusiastically at his own flimsy joke." CR>)
          (<AND <VERB? SHOW> <==? ,PRSI ,MAGNIFYING-GLASS>>
           <TELL 
"Leopold scoffs at your proffered magnifying glass. \"I'm afraid I don't have time for your ">
           <COND (<SID?> 
                  <TELL "Nancy Drew nincompoopery, Sidney">) 
                 (ELSE 
                  <TELL "Hardy Boys shenanigans, Langridge">)>
           <TELL ".\"" CR>)
          (<AND <VERB? SHOW> <==? ,PRSI ,PHOTO>>
           <COND (<SID?> 
                  <COND (<LOC ,SATCHEL>
                         <TELL "Leopold sneers. \"You wouldn't stay in prison, but at least that dog will stay in the ground.\"" CR>)
                        (<N==? ,SUSPECT ,GINA> 
                         <TELL <PICK-IN-ORDER ,SHOW-LEO-PHOTO-AS-SID> CR>
                         <SETG SUSPECT ,LEO>)
                        (ELSE <TELL 
"\"Why are you showing me this dog?\" Craverly asks, his question as pointed as the tip of his
snake-headed cane.||\"This dog is dead,\" you say, \"and I'm going to get the jewels it
found.\"||\"Does this concern me in any way?\" asks Craverly, his question as tentative as his
grasp of the concept of empathy.||\"Not for now, it doesn't,\" you reply, menacingly." CR>)>)
                 (ELSE <TELL 
"\"What's that there?\" Craverly asks.||\"It's Wendell,\" you say. \"Pauline's dog.\"||\"Ah, I see,
I see. And how has he been doing?\"||\"He died three years ago,\" you answer meaningfully, \"Under
mysterious circumstances.\"||Craverly stares meaningfully back at you." CR>)>)

;"*******************************************************
  * In the original Leopold taunts you about never      *
  * giving you the jewels, even if you already got      *
  * them. Here we give the standard reply when he       *
  * already given you the satchel.                      *
  *******************************************************"

          (<AND <VERB? TALKING-TO> <==? ,PRSI ,JEWELS> <SID?> <N==? ,SUSPECT ,GINA> <NOT <LOC ,SATCHEL>>> 
           <TELL <PICK-IN-ORDER ,ASK-LEO-ABOUT-JEWELS> CR>
           <SETG SUSPECT ,LEO>)>>

<ROUTINE LEOSPEAK ()
    <COND (<SID?> <TELL <PICK-IN-ORDER ,LEOSPEAK-TO-SID> CR>)
          (<G? <GET ,LEOSPEAK-TO-DR 1> 2>

;"*******************************************************
  * It's not possible to change style inside a string   *
  * escape-characters. Therefore this solution to       *
  * print Pauline in italic.                            *
  *******************************************************"

           <TELL "\"I beg you to reconsider Janine's plight, Mister Craverly,\" you say.||\"I think you mean ">
           <ITALICIZE "Pauline">
           <TELL ". And I beg you to leave off the subject, Langridge!\" answers Leopold in a mocking tone." CR>)
          (ELSE <TELL <PICK-IN-ORDER ,LEOSPEAK-TO-DR> CR>)>>

<GLOBAL LEOSPEAK-TO-SID
    <LTABLE 2
"\"Hello, there, Leo!\" you say.||\"Out of prison again,\" Leopold begins, and you say \"Naturally!\"
as he says \"I see.\" You both stop talking, and Leopold coughs, waiting for you to talk to him again."

"\"Hello, there, Leo!\" you say.||\"Out of prison again,\" Leopold says, and then he is quiet for
a moment.||\"Naturally!\" you say, too late, and Leopold shakes his head. \"Sorry. Let's try it one
more time.\"||You shuffle your feet."

"\"Hello, there, Leo!\" you say.||\"Out of prison again,\" Leopold says, and you
say \"Naturally!\"||Leopold nods.">>

<GLOBAL LEOSPEAK-TO-DR
    <LTABLE 2
"\"What's new over at Roland Memorial, Langridge?\" Leopold asks.||\"It's Gina's daughter, Pauline.
They can't afford the only procedure that will keep her alive. But, Mister Craverly, I know you are
not an uncharitable man.\"||Leopold lets loose a torrent of guffaws. \"I think that sentence needs
one more negative, Langridge! Of what concern to me is the situation of a girl I wouldn't recognize
on the street?\"||Your response to this question is a glare like a polished silver dagger."

"\"I beg you to reconsider Janine's plight, Mister Craverly,\" you say.||\"I think you mean
Pauline. And I beg you to leave off the subject, Langridge!\" answers Leopold in a mocking tone.">>

<GLOBAL KISS-LEO-AS-DR
    <LTABLE 2
"You rush boldly up to Leopold and, before he can react, you softly grab his head and press your lips
against his lips. The meeting of your bodies is an explosive event, but it is not accompanied by a
meeting of hearts.||\"Oh, Langridge,\" Leopold mutters, still embraced by your arms, \"I left my
chances for love behind a long time ago. Don't turn out like me"

"don't hold out hope for something that can never be.\"||With an expression of tremendous emotion,
you step away from him."

"Leopold allows you to kiss him once more, but you come no closer to melting the diamond cage that
surrounds his paralytic soul.">>

<GLOBAL SHOW-LEO-PHOTO-AS-SID
    <LTABLE 2
"\"You remember Wendell, right?\"||\"Of course,\" Craverly sneers, \"That's Gina's dog. I seem to
recall it perished under mysterious circumstances?\"||\"Cut the bull, Leo. We both know that I made
Janine hit Wendell with her car after you saw him digging down at the train yard where we buried
the jewels. I mean, Pauline.\"||Craverly chortles. \"And now you think I have the jewels? Well,
even if I do, they're staying with me.\""

"Craverly laughs again. \"I won't give you the jewels, no matter how many times you show me that photograph.\"">>

<GLOBAL ASK-LEO-ABOUT-JEWELS
    <LTABLE 2
"\"All right, Leo. We both know that I made Janine hit Wendell with her car after he you saw him digging down
at the train yard where we buried the jewels. I mean, Pauline.\"||Craverly chortles. \"You think I have the
jewels? Well, even if I do, they're staying with me.\""

"Craverly laughs again. \"I won't give you the jewels, no matter how many times you ask me about them.\"">>

;"-----------------------------------------------------------------------------"
;" Part - The Hallways"
;" Chapter - North Hallway"
;"-----------------------------------------------------------------------------"

<ROOM N-HALLWAY
    (DESC "North Hallway")
    (IN ROOMS)
    (WEST TO HOSPITAL)
    (ACTION N-HALLWAY-F)
    (SOUTH TO INTERSECTION)
    (FLAGS LIGHTBIT BACKSTAGE)>

<GLOBAL N-HALLWAY-LOOK-CNT 0>

<ROUTINE N-HALLWAY-F (RARG)
    <COND (<==? .RARG ,M-LOOK>
           <COND (<=? ,N-HALLWAY-LOOK-CNT 2> <TELL "Janine's">)
                 (<L? ,N-HALLWAY-LOOK-CNT 4> <TELL "Pauline's">)
                 (<L=? <RANDOM 100> 50> <TELL "Pauline's">)
                 (ELSE <TELL "Janine's">)>
           <TELL " hospital room is west from here. The hallway continues south." CR>
           <SETG N-HALLWAY-LOOK-CNT <+ ,N-HALLWAY-LOOK-CNT 1>>)>>

<OBJECT SHELVES
    (IN N-HALLWAY)
    (SYNONYM SHELVES SHELF)
    (ADJECTIVE RACK OF)
    (DESC "rack of shelves")
    (LDESC "There's a rack of shelves standing against this end of the hall.")
    (ACTION SHELVES-F)
    (FLAGS SURFACEBIT CONTBIT)>

<ROUTINE SHELVES-F ()
    <COND (<VERB? EXAMINE>
           <COND (<CONTAINER-EMPTY? ,PRSO> <TELL "You see nothing special about the rack of shelves." CR>)
                 (ELSE 
                  <PERFORM V?SEARCH ,PRSO>)>
                  <RTRUE>)>>

;"-----------------------------------------------------------------------------"
;" Section - The Magnifying Glass"
;"-----------------------------------------------------------------------------"

<OBJECT MAGNIFYING-GLASS
    (IN SHELVES)
    (SYNONYM GLASS)
    (ADJECTIVE MAGNIFYING)
    (DESC "magnifying glass")
    (ACTION MAGNIFYING-GLASS-F)
    (FLAGS TAKEBIT)>
    
<ROUTINE MAGNIFYING-GLASS-F ()
    <COND (<VERB? EXAMINE>
           <COND (<BACKSTAGE?> 
                  <TELL "A cheap, beat-up magnifying glass." CR>)
                 (<SID?> 
                  <TELL 
"As a criminal mastermind, you have no need for magnifying glasses. What concerns you is the big picture." CR>)
                 (ELSE 
                  <TELL 
"Every doctor needs a magnifying glass, the better with which to see the minuscule problems that plague
humanity in such enormous ways." CR>)>)
          (<VERB? SEARCH>
           <COND (<BACKSTAGE?> 
                  <TELL "The glass fails to reveal any new information." CR>)
                 (ELSE 
                  <TELL "You lean in for a closer look at ">
                  <COND (<==? ,HERE ,HOSPITAL> <TELL <PICK-ONE-R <PLTABLE "nothing in particular" "the bed">>>)
                        (<==? ,HERE ,PIZZA> <TELL <PICK-ONE-R <PLTABLE "nothing in particular" "the white tablecloth" "the Italian flag">>>)
                        (<==? ,HERE ,MANOR> <TELL <PICK-ONE-R <PLTABLE "nothing in particular" "the gargantuan portrait" "the mahogany-panelled wall">>>)>
                  <TELL "." CR>)>)>>

;"-----------------------------------------------------------------------------"
;" Section - The Framed Photo"
;"-----------------------------------------------------------------------------"

<OBJECT PHOTO
    (IN SHELVES)
	
;"*******************************************************
  * Z3 only allows up to four synonyms                  *
  *******************************************************"
  
    <VERSION? (ZIP (SYNONYM PHOTO DOG PICTURE WENDELL))
		      (ELSE (SYNONYM PHOTO DOG PICTURE PHOTOGRAPH WENDELL))>
    (ADJECTIVE FRAMED)
    (DESC "framed photo")
    (ACTION PHOTO-F)
    (FLAGS TAKEBIT)>
    
<ROUTINE PHOTO-F ()
    <COND (<VERB? EXAMINE>
           <COND (<BACKSTAGE?> <TELL "In the frame is a photo of a dog." CR>)
                 (<SID?> <TELL 
"In this picture frame is a photo of Wendell the dog, Pauline's dog,
which she loved. But you know that Pauline has a secret, a secret
concerning Wendell." CR>)
                 (ELSE <TELL 
"A photo of Pauline's beloved golden retriever, Wendell. A faithful
companion to his owner, and beloved of all citizens of Craverly Heights,
Wendell was cut down before his time" EM-DASH "under mysterious circumstances." CR>)>)>>

;"Create jewels for the game to recognise them"
<OBJECT JEWELS
    (IN GLOBAL-OBJECTS)
    (SYNONYM JEWEL JEWELS GEM GEMS)
    (DESC "jewels")>

;"-----------------------------------------------------------------------------"
;" Section - The Pair of Sunglasses"
;"-----------------------------------------------------------------------------"

;"*******************************************************
  * The pronoun definition is default IT for objects    *
  * without PLURALBIT and THEM for objects with it.     *
  * For the sunglasses we need to change that.          *
  * (IF we set PLURALBIT the indefinite article would   *
  * be 'some', so that doesn't work.)                   *
  *******************************************************"

<OBJECT SUNGLASSES
    (IN SHELVES)
	<VERSION? (ZIP (SYNONYM SUNGLASSES GLASSES SHADES))
			  (ELSE (SYNONYM SUNGLASSES GLASSES SHADES GLASS SHADE))>
    (ADJECTIVE PAIR OF)
    (PRONOUN THEM)
    (DESC "pair of sunglasses")
    (ACTION SUNGLASSES-F)
    (FLAGS TAKEBIT WEARBIT)>

<ROUTINE SUNGLASSES-F ()
    ;"Verb: EXAMINE"
    <COND (<VERB? EXAMINE>
        <COND (<BACKSTAGE?> <TELL "Grossly out-of-fashion, and as flimsy." CR>)
              (<SID?> <TELL "Your sunglasses are what set you apart from your twin" EM-DASH "that, and the fact that you flunked out of medical school." CR>)
              (ELSE <TELL "With a pang of familial familiarity, these flat-topped shades remind you vividly of the sunglasses that your twin Sid used to wear." CR>)>)
    ;"Verb: WEAR, UNWEAR and DROP"
          (<AND <ONSTAGE?> 
                <OR <AND <VERB? WEAR> <NOT <SID?>>> 
                    <AND <VERB? DROP UNWEAR> <SID?>>>> 
                       <TELL "This is not a suitable venue for you to be altering your appearance so drastically and cavalierly." CR>)>>

;"-----------------------------------------------------------------------------"
;" Section - The Handgun"
;"-----------------------------------------------------------------------------"

<OBJECT HANDGUN
    (IN SHELVES)
	<VERSION? (ZIP (SYNONYM HANDGUN GUN PISTOL TRIGGER))
			  (ELSE (SYNONYM HANDGUN GUN PISTOL FIREARM TRIGGER))>
    (DESC "handgun")
    (ACTION HANDGUN-F)
    (FLAGS TAKEBIT WEAPONBIT)>
    
<ROUTINE HANDGUN-F ()
    <COND (<VERB? EXAMINE>
        <COND (<BACKSTAGE?> <TELL "Nickel-plated. Shiny." CR>)
              (<SID?> <TELL 
"The familiar weight of your gun in your hand is like a soft peck on the cheek from your
mother" EM-DASH "you assume. Mom always liked your twin better." CR>)
              (ELSE <TELL 
"How ironic that a healer and caregiver such as yourself should carry in your hands such
a monstrous implement of destruction. Or is it? Maybe it is not ironic at all. Maybe it
makes perfect sense for you to carry this gun: you, who so often hold the powers of life
and death in your hands." CR>)>)
          (<AND <VERB? TOUCH> <BACKSTAGE?>> <TELL "It feels a lot like plastic." CR>)
          (<AND <VERB? TOUCH> <ONSTAGE?>> <TELL "The steel of the gun feels cold. Cold like a broken promise." CR>)>>

<SYNTAX POINT OBJECT (HAVE HELD CARRIED) = V-POINT>
<SYNTAX POINT OBJECT (HAVE HELD CARRIED) AT OBJECT (FIND PERSONBIT) = V-POINT>
<SYNTAX POINT OBJECT (FIND PERSONBIT) WITH OBJECT (HAVE HELD CARRIED) = V-SPOINT>
<VERB-SYNONYM POINT AIM>

<ROUTINE V-SPOINT () <PERFORM V?POINT ,PRSI ,PRSO>>

<ROUTINE V-POINT ("AUX" (XT ""))
    <COND (<SID?> <SET XT "squarely ">)>
    <COND (<0? ,PRSI> <TELL "You point " T ,PRSO " " .XT "at nothing in particular." CR>)
          (<AND <==? ,PRSO ,HANDGUN> <==? ,PRSI ,WINNER>>
           <COND (<BACKSTAGE?> <TELL "You point the gun at yourself. Kind of scary. Not really." CR>)
                 (ELSE
                  <TELL "You raise the gun to your temple. ">
                  <COND (<==? <LOC ,PAULINE> ,HERE> <TELL "Pauline gasps." CR>)
                        (<==? <LOC ,GINA> ,HERE> <TELL "Gina gasps." CR>)
                        (<==? <LOC ,LEO> ,HERE> <TELL "Leopold squints at you." CR>)>
                  <SETG CURRENT-TARGET ,PRSI>
                  <QUEUE I-CLEAR-TARGET 2>)>)
          (ELSE 
           <TELL "You point " T ,PRSO " " .XT "at " T ,PRSI CR>
           <SETG CURRENT-TARGET ,PRSI>

;"*******************************************************
  * Queue an interrupt-routine that will run once in    *
  * two turns that will clear CURRENT-TARGET.           *
  *                                                     *
  * The game will remember what you're pointing at for  *
  * one turn, and then (unless you get on with it and   *
  * the thing) it won't care anymore.                   *
  *******************************************************"

           <QUEUE I-CLEAR-TARGET 2>)>>

<GLOBAL CURRENT-TARGET <>>

<ROUTINE I-CLEAR-TARGET ()
    <SETG CURRENT-TARGET <>>>

<SYNTAX SHOOT OBJECT (FIND KLUDGEBIT) = V-SHOOT>
<SYNTAX SHOOT OBJECT WITH OBJECT (FIND WEAPONBIT) (HAVE HELD CARRIED) = V-SHOOT>
<SYNTAX FIRE OBJECT (FIND WEAPONBIT) (HAVE HELD CARRIED) = V-FIRE>
<SYNTAX FIRE OBJECT (FIND WEAPONBIT) (HAVE HELD CARRIED) AT OBJECT = V-FIRE>

<ROUTINE V-FIRE () 
    <COND (<AND <==? ,PRSO ,HANDGUN> ,PRSI> <PERFORM V?SHOOT ,PRSI ,PRSO>)
          (<==? ,PRSO ,HANDGUN> <PERFORM V?SHOOT ,ROOMS>)   ;"ROOMS has KLUDGEBIT"
          (ELSE <PERFORM V?SHOOT ,PRSO>)>>

<ROUTINE V-SHOOT ()
    <COND (<FSET? ,PRSO ,KLUDGEBIT>
           <COND (<HELD? ,HANDGUN>
                  <PERFORM V?SHOOT ,HANDGUN>)
                 (ELSE <TELL "You don't have anything with which to shoot." CR>)>)
          (<NOT <HELD? ,HANDGUN>> <TELL "You don't have anything with which to shoot." CR>)
          (<==? ,PRSO ,HANDGUN> 
           <COND (<AND ,CURRENT-TARGET <N==? ,CURRENT-TARGET ,HANDGUN>> <PERFORM V?SHOOT ,CURRENT-TARGET>)
                 (<BACKSTAGE?> <TELL "You pull the trigger. Nothing. It doesn't even click." CR>)
                 (ELSE <TELL "With an expression of utter animalism on your face, you raise your gun and fire a shot into the air." CR>)>)
          (<NOT <FSET? ,PRSO ,PERSONBIT>>
           <COND (<BACKSTAGE?> <TELL 
"The gun has no effect on " T ,PRSO ". The trigger doesn't even click." CR>)
                 (<SID?> 
                  <TELL 
"You stop yourself. \"This " D ,PRSO " isn't worth my bullets,\" you say, menacingly. \"Bullets are
expensive.\"||You squint menacingly at " T ,PRSO "." CR>)
                 (ELSE 
                  <TELL 
"You stop yourself. \"This " D ,PRSO " isn't worth my bullets,\" you say, thoughtfully. \"It's done
nothing wrong. Some things in this world are still innocent. But some aren't. But even if they are,
is it my duty to mete out justice?\" You look down meaningfully at the gun." CR>)>)
          (<==? ,PRSO ,WINNER>
           <COND (<BACKSTAGE?> <TELL 
"On days like this, it's not the last thought that occurs to you." CR>)
                 (<SID?> 
                  <TELL 
"With the pistol aimed at your temple, you almost pull the deadly trigger that could free the world
from the scourge of the existence of the dastardly Sidney Langridge, but you pull the gun away from
your head, suddenly.||\"Sorry to disappoint,\" you announce, \"But Sid Langridge is gonna be around
for a while longer. I've got things to do.\"||You sneer menacingly." CR>)
                 (ELSE 
                  <TELL 
"\"I've had it,\" you announce. \"I can't go on. All the secrets. All the lies. I'm finished. This
is the end for your beloved Doctor Langridge. And little do you know: the secret of Wendell's death
dies with me!\"||BLAM||PRESS ANY KEY TO CONTINUE||">
                  <WAIT-FOR-KEY>
                  <SETG GAME-OVER-TEXT "We're bringing back your evil twin.">
                  <PRINT-3-FANCY-ASTERISKS>
                  <JIGS-UP 
"||\"Why. Why did you do that.\"||\"It's like I said! I can't go on. I quit. Craverly Heights
is a sinking ship, and this rat is jumping off.\"||\"First of all, that remark is offensive to rats.
Second, you can't quit. Your contract has you in this studio for the next three years.\"||\"Well,
what are you going to do? Doctor Langridge is dead.\"||\"Oh, that's not a problem...\"">)>)>>

;"*******************************************************
  * Check if the interpreter supports unicode-chars     *
  * before printing them.                               *
  *******************************************************"

<VERSION?
	(ZIP <ROUTINE PRINT-3-FANCY-ASTERISKS () <PRINT "-+-+-+-">>)
	(EZIP <ROUTINE PRINT-3-FANCY-ASTERISKS () <PRINT "-+-+-+-">>)
	(ELSE
		<ROUTINE PRINT-3-FANCY-ASTERISKS ()
			<COND (<==? <CHECKU 10020> 0 2> <PRINT "-+-+-+-">)
				  (ELSE <PRINTU 10020> <PRINTU 10020> <PRINTU 10020>)>>)>
          
<ROUTINE BLOODBATH-ENDING ()
    <TELL "|PRESS ANY KEY TO CONTINUE||">
    <WAIT-FOR-KEY>
    <SETG GAME-OVER-TEXT "Tune in next week!">
    <PRINT-3-FANCY-ASTERISKS>
    <TELL 
"||\"So what happens now?\"||\"First of all, none of that happened.\"||\"You mean like, we're
gonna say it was a dream?\"||\"No, I mean we're going to scrap all of it and start from scratch.
Nobody had a dream, nobody got shot, nothing. We're going to air a rerun. Then we're going to
hire a new writer, and we're going to do a ">
    <ITALICIZE "real">
    <TELL " episode, with a plot. And ">
    <ITALICIZE "you">
    <JIGS-UP " are forbidden from improvising. Never again.\"">>

;"*******************************************************
  * This routine prints the content of the readbuffer   *
  * back. It tries capitalize relevant words.           *
  * As it is used it doesn't always produces            *
  * gramatically correct sentences but mostly works.    *
  * Reminiscent of the echo room in Zork 1.             *
  *                                                     *
  * The actual call to this routine is done in each     *
  * seperate objects action-routine (Leo, Pauline &     *
  * Gina).                                              *
  *******************************************************"
  
<ROUTINE ATTEMPT-TO (OBJ)
    <TELL "\"I wish... I wish I could ">
    <DO (I 1 ,P-LEN)
        <COND (<==? <GETWORD? .I> W?PAULINE> <TELL "Pauline">)
              (<==? <GETWORD? .I> W?JANINE> <TELL "Janine">)
              (<==? <GETWORD? .I> W?LEOPOLD> <TELL "Leopold">)
              (<==? <GETWORD? .I> W?WENDELL> <TELL "Wendell">)
              (<==? <GETWORD? .I> W?GINA> <TELL "Gina">)
              (<==? <GETWORD? .I> W?CRAVERLY> <TELL "Craverly">)
              (<==? <GETWORD? .I> W?LANE> <TELL "Lane">)
              (<==? <GETWORD? .I> W?LEO> <TELL "Leo">)
              (ELSE <TELL WORD .I>)>
        <COND (<L? .I ,P-LEN> <TELL " ">)>>
    <TELL 
", but it's too late,\" you announce, your voice weighed by the burden of monstrous
regret brought on by the enormity of the fact that you have brought from the realm
of the unspeakable into the realm of the true: \"">
    <COND (<FSET? .OBJ ,FEMALEBIT> <TELL "She's">) (ELSE <TELL "He's">)>
    <TELL " dead.\"" CR>>

;"-----------------------------------------------------------------------------"
;" Chapter - East Hallway"
;"-----------------------------------------------------------------------------"

<ROOM E-HALLWAY
    (DESC "East Hallway")
    (IN ROOMS)
    (LDESC "Gina's Pizzeria is north from here. The hallway continues west.")
    (NORTH TO PIZZA)
    (WEST TO INTERSECTION)
    (FLAGS LIGHTBIT BACKSTAGE)>

;"-----------------------------------------------------------------------------"
;" Chapter - South Hallway"
;"-----------------------------------------------------------------------------"

<ROOM S-HALLWAY
    (DESC "South Hallway")
    (IN ROOMS)
    (LDESC "The break room is east from here. The hallway continues north.")
    (EAST TO BREAKROOM)
    (NORTH TO INTERSECTION)
    (FLAGS LIGHTBIT BACKSTAGE)>

;"-----------------------------------------------------------------------------"
;" Chapter - West Hallway"
;"-----------------------------------------------------------------------------"

<ROOM W-HALLWAY
    (DESC "West Hallway")
    (IN ROOMS)
    (LDESC "Craverly Manor is south from here. The hallway continues east.")
    (SOUTH TO MANOR)
    (EAST TO INTERSECTION)
    (FLAGS LIGHTBIT BACKSTAGE)>

;"-----------------------------------------------------------------------------"
;" Chapter - Hallway Intersection"
;"-----------------------------------------------------------------------------"

;"*******************************************************
  * Because the bulletin is defined as a pseudo-object  *
  * its description needs to be in the rooms            *
  * description.                                        *
  *******************************************************"
  
<ROOM INTERSECTION
    (DESC "Hallway Intersection")
    (IN ROOMS)
    (LDESC 
"Nobody's around.||
The hallway runs north, south, east, and west from here.||
A non-diegetic bulletin is posted on the wall.")
    (NORTH TO N-HALLWAY)
    (WEST TO W-HALLWAY)
    (SOUTH TO S-HALLWAY)
    (EAST TO E-HALLWAY)
    (FLAGS LIGHTBIT BACKSTAGE)
    (THINGS (NON-DIEGETIC DIEGETIC) (BULLETIN) BULLETIN-F)>

<ROUTINE BULLETIN-F ()
    <SETG PSEUDO-OBJECT-NAME "non-diegetic bulletin">
    <COND (<VERB? EXAMINE READ> 
           <TELL "The bulletin reads: ">
           <ITALICIZE 
"Hey! You, with the keyboard!
Let me know what you think of this game on Twitter
(\@rcveeder) or via email (rcveeder\@me.com).||
Here's a tip: To finish the game, you're going to have
to use the verb SHOW, as in \">show THING to PERSON\".
You might also have to \">point THING at PERSON\" at
some point.||Thanks for playing.">
           <CRLF>)
          (ELSE 
           <TELL "You're not supposed to pay too much attention to that." CR>)>>

;"-----------------------------------------------------------------------------"
;" Part - Break Room"
;"-----------------------------------------------------------------------------"

<ROOM BREAKROOM
    (DESC "Break Room")
    (IN ROOMS)
    (WEST TO S-HALLWAY)
    (ACTION BREAKROOM-F)
    (FLAGS LIGHTBIT BACKSTAGE)
    (THINGS (STICKY VENDING) (MACHINE NOTE NOTES) VENDING-MACHINE-F)>

<ROUTINE BREAKROOM-F (RARG)
    <COND (<==? .RARG ,M-LOOK>
           <TELL "An antique vending machine takes up most of the tiny room. The exit is west." CR>
           <COND (<NOT <CONTAINER-EMPTY? ,TABLE>> <CRLF> <DESCRIBE-CONTENTS ,TABLE>)>)>>     ;"List content on table if it's not empty"

<ROUTINE VENDING-MACHINE-F ()
    <SETG PSEUDO-OBJECT-NAME "vending machine">
    <COND (<VERB? EXAMINE> <TELL "There's one sticky note on the machine that says \"OUT OF ORDER\", and there's another sticky note that says \"THIS MACHINE OWES ME $7000\"." CR>)
          (<VERB? TAKE> <TELL "You can't lug this vending machine around. It's the real thing." CR>)>>

<OBJECT TABLE
    (IN BREAKROOM)
    (SYNONYM TABLE)
    (DESC "table")
    (LDESC "It's a piece of junk.")
    (ACTION TABLE-F)
    (FLAGS NDESCBIT SURFACEBIT CONTBIT)>

<ROUTINE TABLE-F ()
    <COND (<VERB? EXAMINE> 
           <TELL <GETP ,TABLE ,P?LDESC> CR>
           <COND (<NOT <CONTAINER-EMPTY? ,TABLE>> <CRLF> <DESCRIBE-CONTENTS ,TABLE>)>
           <RTRUE>)>>

;"-----------------------------------------------------------------------------"
;" Section - The Script"
;"-----------------------------------------------------------------------------"

;"*******************************************************
  * The script uses the new object property SDESCFCN    *
  * defined above to vary the short description         *
  * depending on the location and context.              *
  *******************************************************"
  
<OBJECT SCRIPT
    (IN TABLE)
	<VERSION? (ZIP (SYNONYM SCRIPT PAPER PAPERS RESULTS))
			  (ELSE (SYNONYM SCRIPT PAPER PAPERS RESULT RESULTS))>
    (ADJECTIVE SHEETS OF TEST COUPLE SET)
    (SDESCFCN SCRIPT-SDESC-F)
    (ACTION SCRIPT-F)
    (FLAGS TAKEBIT READBIT)>
    
<ROUTINE SCRIPT-SDESC-F () 
    <COND (<BACKSTAGE?> <TELL "script">)
          (<==? ,PROG 0> <TELL "couple sheets of paper">)
          (ELSE <TELL "set of test results">)>>

<GLOBAL PROG 0>

<ROUTINE SCRIPT-F () 
    <COND (<AND <VERB? EXAMINE READ> <BACKSTAGE?>>
           <TELL "Two pages. The first page reads:" CR CR>
           <FIXED-FONT-ON>
           <TELL 
"                          CRAVERLY HEIGHTS|
                           EPISODE # 6001||
If it's so easy, why don't you write it yourself?|" CR>
           <FIXED-FONT-OFF>
           <TELL "The second page is blank." CR>)
          (<AND <VERB? SHOW> <==? ,PRSO ,LANE>> 
           <TELL "Lane has already seen the script. She rolls her eyes. \"I know, right?\"" CR>)
          (<AND <VERB? SHOW> <==? ,PRSO ,PAULINE> <ALIVE? ,PAULINE>> 
           <COND (<SID?> 
                  <TELL 
"\"What's that?\" Pauline asks.||You shake the papers triumphantly. \"This is my certificate of
release! From prison! They give you a certificate that says you aren't supposed to be incarcerated
anymore, in case a cop tries to toss you back in the slammer.\"||\"I didn't know that,\" says Pauline." CR>)    
                 (<==? ,PROG 0> 
                  <TELL 
"You place the papers gingerly in Pauline's delicate hands.||\"Are these...the test results?\" Pauline
asks.||\"Yes, Janine,\" you say. Of course they are.||\"What do they say?\"||You bite your lip
thoughtfully. \"I still need to analyze them,\" you say. \"I'll let you know once I'm finished.\"" CR>
                  <SETG PROG 1>)     
                 (<==? ,PROG 1> 
                  <TELL 
"\"Have you finished analyzing the test results?\" Pauline asks. You frown.||\"I'm afraid not.
Soon, though.\" You hope.||\"Maybe my mother can help,\" says Pauline.||\"Very good idea, Janine.
I'll see what she has to say.\" You cough. \"I mean, Pauline.\"" CR>)
                 (ELSE <TELL <PICK-IN-ORDER ,SHOW-SCRIPT-TO-PAULINE-PROG-2> CR>)>)
          (<AND <VERB? SHOW> <==? ,PRSO ,GINA> <ALIVE? ,GINA>> 
           <COND (<SID?> 
                  <TELL 
"\"This is the deed to my new condo,\" you tell Gina. She cranes her head to get a better look at
the mysterious papers while maintaining a safe distance from your crime-ridden form.||\"I hope it's
far away from here,\" she says.||\"Nice try,\" you say, \"But I'll never tell the likes of you
where it is!\"" CR>)    
                 (<==? ,PROG 0> 
                  <TELL 
"Gina is utterly boggled by the papers you present to her. \"I have no idea what this is,\" she says.
\"Did you get this back at the hospital?\"||\"Yes, Gina,\" you say. Of course you did.||\"Then maybe
they'll hold some interest to Pauline. If she has the strength to read them,\" Gina adds bitterly." CR>)     
                 (<==? ,PROG 1>
                  <COND (<DEAD? ,LEO>
                         <TELL
"\"I wanted to show you these test results,\" you say, thrusting the papers in to Gina's motherly hands.
She looks them over with an expression that changes from skeptical, to interested, to astonished.||\"Doc!
This means...\"||You lean in closer.||\"This means...\" Gina stammers, \"Pauline's father is Leopold
Craverly!\"||Your eyes widen. \"But I just">
                         <COND (,SID-SHOT-LEO <TELL EM-DASH "I mean, Sidney, my twin, just">)>
                         <TELL " murdered him!\"||PRESS ANY KEY TO CONTINUE||">
                         <DEAD-CRAVERLY-ENDING>)
                        (ELSE 
                         <TELL 
"\"I wanted to show you these test results,\" you say, thrusting the papers in to Gina's motherly hands.
She looks them over with an expression that changes from skeptical, to interested, to astonished.||\"Doc!
This means...\"||You lean in closer.||\"This means...\" Gina stammers, \"Pauline's father is...\"||
Your eyes widen. Of course!" CR>
                         <SETG PROG 2>)>)
                 (ELSE <TELL 
"\"I don't need these!\" exclaims Gina. \"Pauline needs to find out who her real father is! And so
does...her father.\"" CR>)>)
          (<AND <VERB? SHOW> <==? ,PRSO ,LEO> <ALIVE? ,LEO>> 
           <COND (<SID?> 
                  <TELL 
"\"What's that you've got there?\" Leopold asks.||You smirk with unconscionable smugness. \"It's a script.
I'm gonna be a star,\" you say.||\"I imagine you must think so. But you're no star, Sidney. You're a black
hole.\"||You grimace at the disquieting veracity of Leopold's words." CR>)    
                 (<==? ,PROG 0> 
                  <TELL 
"\"What's this?\" Leopold says, eyeing the papers with inexplicable contempt. \"Some document you found
at the hospital?\"||\"Yes,\" you say.||\"Then I can safely assume that it does not concern me!\" Craverly
punctuates his statement with a triumphant guffaw." CR>)     
                 (<==? ,PROG 1> 
                  <TELL 
"\"What's this?\" Leopold asks, eyeing the papers with inexplicable contempt.||\"These are test results,\"
you say. \"Pauline's test results.\"||\"Ah! I will attempt an impersonation of someone who cares, then:
What do they say?\"||You glare at the old man, at his hateful face. \"I haven't figured that out. Yet.\"||
\"Of course! I expect nothing more from the greatest doctor in Craverly Heights.\" Leopold guffaws." CR>)
                 (ELSE 
                  <TELL 
"\"What's this?\" Leopold asks, eyeing the papers with inexplicable trepidation.||\"These are test results.
Pauline's test results,\" you say, extremely meaningfully. \"They constitute conclusive proof that you are
Pauline's father.\"||The weight of this revelation nearly knocks Leopold onto the floor. He grasps his cane
all the tighter, and mutters:||\"Nineteen years ago... The train tunnel collapse!\"||\"The underground gases
that seeped into the tunnel caused amnesia in all of the passengers,\" you explain. \"Nobody on the train
could remember what happened before the rescue team arrived. But now we know about one thing that definitely
did happen. You and Gina conceived a child, a child that desperately needs a medical procedure she can't
afford.\"||\"I'll pay every cent!\" Leopold is on the verge of tears. \"I have a daughter! The Craverly line
will go on!\"||PRESS ANY KEY TO CONTINUE||">
                  <FINISH-THE-EPISODE>)>)>>

<GLOBAL SHOW-SCRIPT-TO-PAULINE-PROG-2
    <LTABLE 2
"\"I've finished analyzing your results,\" you say, passing the papers to Pauline. She inspects them
closely.||\"As you can see, the tests don't apply to you specifically. They also have something to do
with the identity of your father.\"||Pauline looks up from the paper, her eyes wide with amazement.||
\"Now, I need those back, for reasons I think you can guess.\" You pull the test results out of her hands."

"Pauline frowns. \"I've seen the results, Doctor Langridge,\" she says, \"But have you shown them to...my
father?\"||\"I just wanted to make sure that's what you wanted,\" you reply.||\"It is,\" says Pauline.">>

<ROUTINE DEAD-CRAVERLY-ENDING ()
    <WAIT-FOR-KEY>
    <SETG GAME-OVER-TEXT "Tune in next week.">
    <PRINT-3-FANCY-ASTERISKS>
    <JIGS-UP 
"||\"And why did you do that?\"||\"I don't know! We had no script!\"||\"So you murdered your costar?
I thought the first rule of improv was 'Don't randomly kill your fellow characters'.\"||\"Actually,
the first rule of improv is, you're supposed to say 'Yes, and'.\"||\"Oh, I see. Let me try it out:
Yes, and, you're fired.\"">>

<ROUTINE FINISH-THE-EPISODE ()
    <WAIT-FOR-KEY>
    <SETG GAME-OVER-TEXT "We gotta hire a flippin' writer.">
    <PRINT-3-FANCY-ASTERISKS>
    <TELL "||\"And fade to black. See? Everything worked out fine.\"||">
    <COND (<AND <DEAD? ,PAULINE> <DEAD? ,GINA>> <TELL "\"But Pauline and Gina are dead.\"">)
          (<DEAD? ,GINA> <TELL "\"But Gina is dead.\"">)
          (<DEAD? ,PAULINE> <TELL "\"But Pauline is dead.\"">)>
    <COND (<OR <DEAD? ,PAULINE> <DEAD? ,GINA>> 
     <TELL 
"||\"Nah, we can edit that out. What the heck were you trying to accomplish there?\"||An answer
does not spring to mind.||">)>
    <JIGS-UP 
"\"So Pauline's gonna be okay?\"||\"Of course! We were never gonna kill her off. She has to stay
in that bed until Lisa has her baby, but we'll figure that out.\"||The director leans back and
sighs. \"Now, you guys did a good job out there today. I don't want to diminish the enormity of
your accomplishment. But before we get working on #6002, we gotta get one thing done.\"">>

;"-----------------------------------------------------------------------------"
;" Section - Lane"
;"-----------------------------------------------------------------------------"

<OBJECT LANE
    (IN BREAKROOM)
    (SYNONYM LANE WOMAN)
    (DESC "Lane")
    (LDESC "Lane is sitting around with a blank look on her face.")
    (ACTION LANE-F)
    (FLAGS PERSONBIT FEMALEBIT NARTICLEBIT)>

<OBJECT BLOUSE
    (IN BREAKROOM)
    (SYNONYM BLOUSE)
    (ADJECTIVE PINK)
    (DESC "pink blouse")
    (ACTION BLOUSE-F)
    (FLAGS NDESCBIT)>

<ROUTINE BLOUSE-F ()
    <COND (<AND <VERB? TAKE> <==? <LOC ,BLOUSE> ,BREAKROOM>> <TELL "That seems to belong to Lane." CR>)
          (<AND <VERB? TAKE> <==? <LOC ,BLOUSE> ,PIZZA>> <TELL "That seems to belong to Gina." CR>)
          (<AND <VERB? EXAMINE> <==? <LOC ,BLOUSE> ,BREAKROOM>> <TELL "The blouse looks just fine on Lane." CR>)
          (<AND <VERB? EXAMINE> <==? <LOC ,BLOUSE> ,PIZZA>> <TELL 
"Gina's favorite blouse brings out the rosiness of her complexion,
even as dulled as it has become by the tragedies that life has
delivered to her." CR>)>>

<ROUTINE LANE-F ()
    <COND (<VERB? EXAMINE>
           <TELL "Lane is wearing a pink blouse." CR>)
          (<VERB? TALKING-TO>
           <TELL 
"'Hey, Lane,' you say. 'Shouldn't you be down at the Pizzeria?'||
Lane's eyes widen. 'Oh, shoot, sorry! Sorry!'||She continues to
apologize as she rushes out into the hall." CR>
           <REMOVE ,LANE>
           <MOVE ,GINA ,PIZZA>
           <MOVE ,BLOUSE ,PIZZA>)
          (<VERB? KISS>
           <TELL "Lane pushes you away. \"Save it for later, all right?\"" CR>)
          (<AND <VERB? POINT> <==? ,PRSO ,HANDGUN> <==? ,PRSI ,LANE>>
           <TELL "She rolls her eyes." CR>)
          (<VERB? SHOOT>
           <TELL 
"With the gun pointed right at Lane, you pull the trigger. Nothing happens.||She sighs. \"Cut that out.\"" CR>)
          (<AND <VERB? SHOW> <==? ,PRSI ,HANDGUN>>
           <TELL "Lane shrugs. \"I've seen cooler.\"" CR>)
          (<AND <VERB? SHOW> <==? ,PRSI ,PHOTO>>
           <TELL "Lane squints at the photo of the dog. \"I'm pretty sure this came with the frame.\"" CR>)
          (<AND <VERB? SHOW> <==? ,PRSI ,MAGNIFYING-GLASS>>
           <TELL "Lane shakes her head. \"It's a piece of junk.\"" CR>)>>

;"-----------------------------------------------------------------------------"
;" Section - The Satchel"
;"-----------------------------------------------------------------------------"

<OBJECT SATCHEL
    (SYNONYM SATCHEL POUCH SACK BAG)
    (DESC "satchel")
    (ACTION SATCHEL-F)
    (FLAGS TAKEBIT)>
    
<ROUTINE SATCHEL-F ()
    <COND (<VERB? EXAMINE>
           <COND (<BACKSTAGE?> <TELL "This is not real suede." CR>)
                 (<SID?> <TELL "It's a small suede pouch, as luxurious as the prize it contains." CR>)

;"*******************************************************
  * The original gives an empty respones here when you  *
  * examine the satchel onstage as Dr Langridge. In     *
  * this version we default to parser standard message. *
  *******************************************************"

                 (ELSE <RFALSE>)>)
          (<VERB? SEARCH OPEN>
           <COND (<BACKSTAGE?> <TELL "Yeah, it's empty." CR>)
                 (<SID?> <TELL 
"Yes, they're all in here. The jewels that caused you so much trouble, trouble that caused you to
commit so many crimes, crimes that caused you to spend so long in prison." CR>)
                 (ELSE <TELL "What should be in here? It could be anything. But it ought to be something good." CR>)>)
          (<AND <VERB? SHOW> <==? ,PRSO ,LEO> <ALIVE? ,LEO>> 
           <COND (<SID?>
                  <COND (<==? ,SUSPECT ,LEO> 
                         <TELL "\"Don't rub it in, Sidney,\" Leopold grouses." CR>)
                        (ELSE
                         <TELL 
"\"What's that you've got there?\" asks Leopold, clearly curious about the contents of the mysterious pouch
that you've produced.||\"These are the jewels,\" you explain, \"the jewels that I spent so long in prison
for. I stole them on your orders! But you betrayed me. But now they're mine!\"||\"And what are you going to
do with them?\" asks Leopold, the shadows of confusion darting across his weathered brow.||\"I'm going to
buy Craverly Manor, and you're going to be my butler.\"||PRESS ANY KEY TO CONTINUE||">
                         <WAIT-FOR-KEY>
                         <SETG GAME-OVER-TEXT "...I'm gonna be busy looking for a writer.">
                         <PRINT-3-FANCY-ASTERISKS>
                         <JIGS-UP
"||\"That doesn't make a lot of sense.\"||\"Well, maybe Leopold could turn out to be in debt?\"||\"Sure, I
guess. But I would have liked it better if we spread out the whole saga of Sidney returning, Sidney getting
the jewels, and Sidney demanding to buy the manor over the course of twelve or twenty episodes.\"||\"Oh. Do
you want us to shoot it again?\"||\"There's no time. We'll just edit this one until it works. You go home and
get something to eat.\"||\"Yeah, we're all going down to the Gas Leak. You wanna join us?\"||\"No thanks...\"">)>)    
                 (ELSE <TELL
"\"Where did you get that?\" Leopold cries, shocked and aghast.||You raise your eyebrows. \"You mean, where
did I get this... bag of marbles?\"||Leopold regains his composure. \"Ah, yes. Never mind.\"" CR>)>)
          (<AND <VERB? SHOW> <==? ,PRSO ,PAULINE> <ALIVE? ,PAULINE>> 
           <COND (<SID?>
                  <TELL 
"\"The jewels!\" Pauline gasps, her breathlessness as much a factor of her surprise as a consequence of her
illness. \"Then you were able to convince...\"||\"">
                  <COND (<==? ,SUSPECT ,GINA> <TELL "Your mother">) (ELSE <TELL "Mister Craverly">)>
                  <TELL 
", yes. The jewels are mine" EM-DASH "ours, now.\"||\"Sidney, we can sell the jewels for the money for the medical
treatment that will save my life!\" Pauline's eyes are huge and wet beneath the hospital lights as they
plaintively gaze upward into your own.||\"Sugarbabe, those were my thoughts exactly.\"||PRESS ANY KEY
TO CONTINUE||">
                         <WAIT-FOR-KEY>
                         <SETG GAME-OVER-TEXT "Right after we hire a writer.">
                         <PRINT-3-FANCY-ASTERISKS>
                         <JIGS-UP
"||\"Why is Sidney nice all of a sudden?\"||\"Well, I thought about just abandoning Janine, but I
realized I had a chance to push things in a bold new direction.\"||\"It's Pauline. And that's not
gonna work. People love Sidney the evil twin; they're not going to respond well to Sidney the
altruist. Besides, Pauline has to stay sick until Lisa has her baby.\"||\"Oh. Do we need to shoot
the whole thing again?\"||\"There's no time. We'll figure something out.\"">)    
                 (ELSE <TELL
"\"What's in that bag, Doctor Langridge?\" asks sweet, innocent Janine.||You consider the question
with all the weight it merits.||\"I have here some medicine. But it won't help you. It's a special
medicine, for a different patient. I shouldn't tell you too much about it. Never mind.\"" CR>)>)
          (<AND <VERB? SHOW> <==? ,PRSO ,GINA> <ALIVE? ,GINA>> 
           <COND (<SID?>
                  <COND (<==? ,SUSPECT ,GINA> 
                         <TELL "\"Get that out of my face, Sid,\" Gina grouses." CR>)
                        (ELSE
                         <TELL 
"Gina cocks her head at the appearance of the suede pouch. \"Hey, scumbag! What's in the bag? Is it
scum?\"||\"It's a pile of jewels. They're worth a lot of money. And I'm giving them to you.\" Gina's
jaw drops, but you continue. \"Then you're going to sell them, and then you're going to use the money
to open a new Gina's Pizzeria location. And you're going to make me part owner. And we're going to
be rich.\"||Gina can't think of anything to say.||PRESS ANY KEY TO CONTINUE||">
                         <WAIT-FOR-KEY>
                         <SETG GAME-OVER-TEXT "We're definitely hiring a writer, though.">
                         <PRINT-3-FANCY-ASTERISKS>
                         <JIGS-UP
"||\"We definitely can't afford a second restaurant set, though.\"||\"We can work around that. Or, do
you want us to shoot it again?\"||\"No, there's no time. We're already editing this one. You can go
home.\"||\"So, does that mean...\"||\"Oh, right. No, you're not fired.\"">)>)    
                 (ELSE <TELL
"\"Gina, what do you think is in this bag?\" you ask.||\"I don't know, Doc. Is it doll hands?\"||\"Yes,
and,\" you say, \"if you see any other doll parts, make sure you let me know.\"" CR>)>)>>

;"-----------------------------------------------------------------------------"
;" Volume - Recreate and modify parser to be more like Inform 7"
;"-----------------------------------------------------------------------------"

<SET REDEFINE T>

;"*******************************************************
  * Adding and modifying verbs and their default        *
  * behaviour, responses and synonyms.                  *
  *******************************************************"
  
<SYNTAX LOOK THROUGH OBJECT (FIND CONTBIT) = V-SEARCH PRE-REQUIRES-LIGHT>

<VERB-SYNONYM UNWEAR REMOVE>

<VERB-SYNONYM TOUCH FEEL>

<VERB-SYNONYM PUSH MOVE>

<SYNTAX KISS OBJECT (FIND PERSONBIT) = V-KISS>
<VERB-SYNONYM KISS EMBRACE HUG>

<ROUTINE V-KISS () 
    <COND (<FSET? ,PRSO ,PERSONBIT> <TELL "If you think that'll help." CR>)
          (ELSE <TELL "You can only do that to something animate." CR>)>>

<ROUTINE V-ATTACK ()
    <TELL "Violence isn't the answer to this one." CR>
    <RTRUE>>

<SYNTAX SCORE = V-SCORE>

<ROUTINE V-SCORE () <TELL "There is no score in this story." CR>>

;"*******************************************************
  * ZILF standard library automatically wears wearable  *
  * objects when you pick them up. This changes that    *
  * behaviour so you explicitly have wear and remove    *
  * wearable objects.                                   *
  *******************************************************"

<ROUTINE V-WEAR ()
    <COND (<FSET? ,PRSO ,WEARBIT>
        <COND (<NOT <FSET? ,PRSO ,WORNBIT>>
            <FSET ,PRSO ,WORNBIT>
            <TELL "You wear " T ,PRSO "." CR>)
        (ELSE <TELL "You are already wearing that." CR>)>)
    (ELSE <NOT-POSSIBLE "wear">)>>

<ROUTINE V-UNWEAR ()
    <COND (<AND <IN? ,PRSO ,WINNER> <FSET? ,PRSO ,WORNBIT>>
        <FCLEAR ,PRSO ,WORNBIT>
        <TELL "You take off " T ,PRSO "." CR>)
    (ELSE <TELL "You aren't wearing that." CR>)>>

<ROUTINE TRY-TAKE (OBJ "OPT" SILENT "AUX" HOLDER)
    <COND
        (<AND ,PRSI <NOT <FSET? ,PRSI ,SURFACEBIT>>> <TELL "That can't contain things." CR> <RFALSE>) ;"Added message for 'take all from ..."
        (<=? .OBJ ,WINNER>
            <COND
                (.SILENT)
                (<=? ,P-V-WORD ,W?GET> <TELL "Not quite." CR>)
                (<=? ,P-V-WORD ,W?TAKE ,W?GRAB> <TSD>)
                (<=? ,P-V-WORD ,W?PICK> <TELL "You aren't my type." CR>)
                (ELSE <SILLY>)>
            <RFALSE>)
        (<FSET? .OBJ ,PERSONBIT>
            <OR .SILENT <YOU-MASHER>>
            <RFALSE>)
        (<NOT <FSET? .OBJ ,TAKEBIT>>
            <OR .SILENT <NOT-POSSIBLE "pick up">>
            <RFALSE>)
        (<IN? .OBJ ,WINNER>
            <OR .SILENT <TELL "You already have that." CR>>
            <RFALSE>)>
    ;"See if picked up object is being taken from a container"
    <COND (<SET HOLDER <TAKE-HOLDER .OBJ ,WINNER>>
        <COND
            (<FSET? .HOLDER ,PERSONBIT>
                <OR .SILENT <TELL "That seems to belong to " T .HOLDER "." CR>>
                <RFALSE>)
            (<BLOCKS-TAKE? .HOLDER>
                <THIS-IS-IT .HOLDER>
                <OR .SILENT <TELL CT .HOLDER " is in the way." CR>>
                <RFALSE>)
            (<NOT <TAKE-CAPACITY-CHECK .OBJ .SILENT>>)
            (<AND <FSET? .HOLDER ,CONTBIT> <HELD? .OBJ .HOLDER> <NOT <HELD? ,WINNER .HOLDER>>>
                <FSET .OBJ ,TOUCHBIT>
                <MOVE .OBJ ,WINNER>
                <COND
                    (.SILENT)
                    (<SHORT-REPORT?>
                        <TELL "Taken." CR>)
                    (ELSE
                        <TELL "You reach ">
                        <COND (<HELD? ,WINNER .HOLDER>
                            <TELL "out of ">)
                        (ELSE
                            <TELL "in ">)>
                        <TELL T .HOLDER " and ">
                        <TELL "take ">
                        <TELL T .OBJ "." CR>)>
                <RTRUE>)>)>
    <COND
        (<NOT <TAKE-CAPACITY-CHECK .OBJ .SILENT>>
            <RFALSE>)
        (ELSE
            <FSET .OBJ ,TOUCHBIT>
            <MOVE .OBJ ,WINNER>
            <COND
                (.SILENT)
                (<SHORT-REPORT?> <TELL "Taken." CR>)
                (ELSE <TELL "You pick up " T .OBJ "." CR>)>
            <RTRUE>)>>

;"*******************************************************
  * Enable syntax from taking all/object from surface.  *
  * There is also an added message in TRY-TAKE above to *
  * support this.                                       *
  *******************************************************"
  
<ROUTINE PERFORM (ACT "OPT" DOBJ IOBJ "AUX" PRTN RTN OA OD ODD OI WON CNT ORM)
    <TRACE 1 "[PERFORM: ACT=" N .ACT>
    <TRACE-DO 1
        <COND (.DOBJ <TELL " DOBJ=" D .DOBJ "(" N .DOBJ ")">)>
        <COND (.IOBJ <TELL " IOBJ=" D .IOBJ "(" N .IOBJ ")">)>
        <TELL "]" CR>>
    <SET PRTN <GET ,PREACTIONS .ACT>>
    <SET RTN <GET ,ACTIONS .ACT>>
    <SET OA ,PRSA>
    <SET OD ,PRSO>
    <SET ODD ,PRSO-DIR>
    <SET OI ,PRSI>
    <SET ORM ,REPORT-MODE>
    <SETG PRSA .ACT>
    <SETG PRSO .DOBJ>
    <OR <==? .ACT ,V?WALK> <SETG PRSO-DIR <>>>
    <SETG PRSI .IOBJ>
    <TRACE-IN>
    ;"Warn about improper number use, and handle multiple objects"
    <COND (<G? <COUNT-PRS-APPEARANCES ,NUMBER> 1>
           <TELL "You can't use more than one number in a command." CR>
           <SET WON <>>)
          (<AND <NOT ,PRSO-DIR> <PRSO? ,MANY-OBJECTS>>
           <COND (<PRSI? ,MANY-OBJECTS>
                  <TELL "You can't use multiple direct and indirect objects together." CR>
                  <SET WON <>>)
                 (ELSE
                  <SETG REPORT-MODE ,SHORT-REPORT>
                  <SET CNT <GETB ,P-PRSOS 0>>
                  <DO (I 1 .CNT)
                      <SETG PRSO <GET/B ,P-PRSOS .I>>
                      <COND (<STILL-IN-ALL-TAKE-CHECK? ,PRSO ,PRSI>
                             <TELL D ,PRSO ": ">
                             <SET WON <PERFORM-CALL-HANDLERS .PRTN .RTN>>)>>)>)
          (<PRSI? ,MANY-OBJECTS>
           <SETG REPORT-MODE ,SHORT-REPORT>
           <SET CNT <GETB ,P-PRSIS 0>>
           <DO (I 1 .CNT)
               <SETG PRSI <GET/B ,P-PRSIS .I>>
               <COND (<STILL-IN-ALL-TAKE-CHECK? ,PRSI ,PRSO>
                      <TELL D ,PRSI ": ">
                      <SET WON <PERFORM-CALL-HANDLERS .PRTN .RTN>>)>>)
          (ELSE <SET WON <PERFORM-CALL-HANDLERS .PRTN .RTN>>)>
    <TRACE-OUT>
    <SETG PRSA .OA>
    <SETG PRSO .OD>
    <SETG PRSO-DIR .ODD>
    <SETG PRSI .OI>
    <SETG REPORT-MODE .ORM>
    .WON>

<ROUTINE STILL-IN-ALL-TAKE-CHECK? (OBJ IOBJ)
    <COND (<OR <NOT <VERB? TAKE>> <NOT .IOBJ>> <RTRUE>)
          (<NOT <FSET? .IOBJ ,SURFACEBIT>> <RFALSE>)
          (<=? <LOC .OBJ> .IOBJ> <RTRUE>)
          (ELSE <RFALSE>)>>

<SYNTAX TAKE OBJECT (FIND TAKEBIT) (MANY ON-GROUND IN-ROOM) FROM OBJECT (FIND SURFACEBIT) (ON-GROUND IN-ROOM) = V-TAKE>
<SYNTAX PICK UP OBJECT (FIND TAKEBIT) (MANY ON-GROUND IN-ROOM) FROM OBJECT (FIND SURFACEBIT) (ON-GROUND IN-ROOM) = V-TAKE>
<SYNTAX GET OBJECT (FIND TAKEBIT) (MANY ON-GROUND IN-ROOM) FROM OBJECT (FIND SURFACEBIT) (ON-GROUND IN-ROOM) = V-TAKE>
<SYNTAX TAKE OBJECT (FIND TAKEBIT) (MANY ON-GROUND IN-ROOM) ON OBJECT (FIND SURFACEBIT) (ON-GROUND IN-ROOM) = V-TAKE>
<SYNTAX PICK UP OBJECT (FIND TAKEBIT) (MANY ON-GROUND IN-ROOM) ON OBJECT (FIND SURFACEBIT) (ON-GROUND IN-ROOM) = V-TAKE>
<SYNTAX GET OBJECT (FIND TAKEBIT) (MANY ON-GROUND IN-ROOM) ON OBJECT (FIND SURFACEBIT) (ON-GROUND IN-ROOM) = V-TAKE>

;"*******************************************************
  * ZILF standard library includes already taken object *
  * in 'take all' and not held objects in 'drop all'.   *
  * This adds checks so only held objects are dropped   *
  * and only not held objects are attempted to be       *
  * up.                                                 *
  *******************************************************"

<ROUTINE ALL-INCLUDES? (OBJ)
    <NOT <OR <FSET? .OBJ ,INVISIBLE>
             <AND <VERB? TAKE> <HELD? .OBJ>>
             <AND <VERB? DROP> <NOT <HELD? .OBJ>>>
             <=? .OBJ ,WINNER>
             <AND <VERB? TAKE DROP>
                  <NOT <OR <FSET? .OBJ ,TAKEBIT>
                           <FSET? .OBJ ,TRYTAKEBIT>>>>>>>
 
;"*******************************************************
  * Normally objects on surfaces are listed in room     *
  * description. To mimic Inform 7 this is turned of    *
  * the listing is done explicitly with the relevant    *
  * surfaces.                                           *
  *******************************************************"

<ROUTINE DESCRIBE-OBJECTS (RM "AUX" P N)
    <MAP-CONTENTS (I .RM)
        <COND
            (<FSET? .I ,NDESCBIT>)
            ;"objects with DESCFCNs"
            (<SET P <GETP .I ,P?DESCFCN>>
             <CRLF>
             ;"The DESCFCN is responsible for listing the object's contents"
             <APPLY .P ,M-OBJDESC>
             <THIS-IS-IT .I>)
            ;"objects with applicable FDESCs or LDESCs"
            (<OR <AND <NOT <FSET? .I ,TOUCHBIT>>
                      <SET P <GETP .I ,P?FDESC>>>
                 <SET P <GETP .I ,P?LDESC>>>
             <TELL CR .P CR>
             <THIS-IS-IT .I>
             ;"Describe contents if applicable"
             <COND (<AND <SEE-INSIDE-DESC? .I> <FIRST? .I>>
                    <DESCRIBE-CONTENTS .I>)>)>>
    ;"See if there are any non fdesc, ndescbit, personbit objects in room"
    <MAP-CONTENTS (I .RM)
        <COND (<GENERIC-DESC? .I>
               <SET N T>
               <RETURN>)>>
    ;"go through the N objects"
    <COND (.N
           <TELL CR "There ">
           <LIST-OBJECTS .RM GENERIC-DESC? ,L-ISMANY>
           <TELL " here." CR>
           <CONTENTS-ARE-IT .RM GENERIC-DESC?>)>
    ;"describe visible contents of generic-desc containers and surfaces"
    <MAP-CONTENTS (I .RM)
        <COND (<AND <SEE-INSIDE-DESC? .I>
                    <GENERIC-DESC? .I>
                    <FIRST? .I>>
               <DESCRIBE-CONTENTS .I>)>>
    ;"See if there are any NPCs"
    <SET N <>>
    <MAP-CONTENTS (I .RM)
        <COND (<NPC-DESC? .I>
               <SET N T>
               <RETURN>)>>
    ;"go through the N NPCs"
    <COND (.N
           <CRLF>
           <LIST-OBJECTS .RM NPC-DESC? <+ ,L-SUFFIX ,L-CAP>>
           <TELL " here." CR>
           <CONTENTS-ARE-IT .RM NPC-DESC?>)>>

<ROUTINE SEE-INSIDE-DESC? (OBJ)
    ;"The T? should be unnecessary, but ZILF generates ugly code without it"
    <T?     ;"We can see inside containers if they're open, transparent, or
              unopenable (= always-open)"
            <AND <NOT <FSET? .OBJ ,SURFACEBIT>>
                 <FSET? .OBJ ,CONTBIT>
                 <OR <FSET? .OBJ ,OPENBIT>
                     <FSET? .OBJ ,TRANSBIT>
                     <NOT <FSET? .OBJ ,OPENABLEBIT>>>>>>

;"*******************************************************
  * Default statusline shows score and moves. This      *
  * removes that. Z3 have a fixed statusline built into *
  * the interpreter.                                    *
  *******************************************************"

<VERSION?
	(ZIP)
	(ELSE
		<ROUTINE UPDATE-STATUS-LINE ()
			<SCREEN 1>
			<HLIGHT ,H-INVERSE>
			<FAKE-ERASE>
			<TELL !\ >
			<COND (,HERE-LIT <TELL D ,HERE>)
				(ELSE <TELL %,DARKNESS-STATUS-TEXT>)>
			<SCREEN 0>
			<HLIGHT ,H-NORMAL>>)>

;"*******************************************************
  * This is to change the end-of-game messages. Z3      *
  * doesn't support bold/normal.                        *
  *******************************************************"

<GLOBAL GAME-OVER-TEXT "The game is over">

<ROUTINE PRINT-GAME-OVER ()
    <VERSION? (ZIP) (ELSE <HLIGHT H-BOLD>)>
    <TELL CR CR "    *** " ,GAME-OVER-TEXT " ***" CR CR CR>
    <VERSION? (ZIP) (ELSE <HLIGHT H-NORMAL>)>>

<ROUTINE JIGS-UP (TEXT "AUX" W)
    <SETG P-CONT 0>
    <TELL .TEXT CR CR>
    <PRINT-GAME-OVER>
    <CRLF>
    <COND (<RESURRECT?> <RTRUE>)>
    <REPEAT PROMPT ()
        <IFFLAG (UNDO
                <PRINTI "Would you like to RESTART, RESTORE a saved game, QUIT, or UNDO the last command?| > ">)
                (ELSE
                <PRINTI "Would you like to RESTART, RESTORE a saved game or QUIT? > ">)>
        <REPEAT ()
            <READLINE>
            <SET W <AND <GETB ,LEXBUF 1> <GET ,LEXBUF 1>>>
            <COND (<EQUAL? .W ,W?RESTART>
                  <RESTART>)
                  (<EQUAL? .W ,W?RESTORE>
                  <RESTORE>  ;"only returns on failure"
                  <TELL "Restore failed." CR>
                  <AGAIN .PROMPT>)
                  (<EQUAL? .W ,W?QUIT>
                  <TELL CR "Thanks for playing." CR>
                  <QUIT>)
                  (<EQUAL? .W ,W?UNDO>
                  <V-UNDO>   ;"only returns on failure"
                  <TELL "Undo failed." CR>
                  <AGAIN .PROMPT>)
                  (T
                  <IFFLAG (UNDO
                            <TELL CR "(Please type RESTART, RESTORE, QUIT or UNDO) >">)
                          (ELSE
                            <TELL CR "(Please type RESTART, RESTORE or QUIT) > ">)>)>>>>

;"*******************************************************
  * Changes to parsers default fail-messages to make    *
  * more like in Inform 7.                              *
  *******************************************************"

;"*** 'You can't see that here.' --> 'You can't see any such thing.'"
<ROUTINE MATCH-NOUN-PHRASE (NP OUT BITS "AUX" F NY NN SPEC MODE NOUT OBITS ONOUT BEST Q)
    <SET NY <NP-YCNT .NP>>
    <SET NN <NP-NCNT .NP>>
    <SET MODE <NP-MODE .NP>>
    <SET OBITS .BITS>
    <COND (<0? .MODE>
           <SET .BITS <ORB .BITS ;"<ORB" ,SF-HELD ,SF-CARRIED ,SF-ON-GROUND ,SF-IN-ROOM ;">" >>)>
    <TRACE 3 "[MATCH-NOUN-PHRASE: NY=" N .NY " NN=" N .NN " MODE=" N .MODE
             " BITS=" N .BITS " OBITS=" N .OBITS "]" CR>
    <TRACE-IN>
    <PROG BITS-SET ()
        ;"Look for matching objects"
        <SET NOUT 0>
        <COND (<0? .NY>
               ;"ALL with no YSPECs matches all objects, or if the action is TAKE/DROP,
                 all objects with TAKEBIT/TRYTAKEBIT, skipping generic/global objects."
               <TRACE 4 "[applying ALL rules]" CR>
               <MAP-SCOPE (I [BITS .BITS])
                   <COND (<SCOPE-STAGE? GENERIC GLOBALS>)
                         (<NOT <ALL-INCLUDES? .I>>)
                         (<AND .NN <NP-EXCLUDES? .NP .I>>)
                         (<G=? .NOUT ,P-MAX-OBJECTS>
                          <TELL "[too many objects!]" CR>
                          <TRACE-OUT>
                          <RETURN>)
                         (ELSE
                          <SET NOUT <+ .NOUT 1>>
                          <PUT/B .OUT .NOUT .I>)>>)
              (ELSE
               ;"Go through all YSPECs and find matching objects for each one.
                 Give an error if any YSPEC has no matches, but it's OK if all
                 the matches for some YSPEC are excluded by NSPECs. Keep track of
                 the match quality and only select the best matches."
               <DO (J 1 .NY)
                   <SET SPEC <NP-YSPEC .NP .J>>
                   <TRACE 4 "[SPEC=" OBJSPEC .SPEC "]" CR>
                   <SET F <>>
                   <SET ONOUT .NOUT>
                   <SET BEST 1>
                   <MAP-SCOPE (I [BITS .BITS])
                       <TRACE 5 "[considering " T .I "]" CR>
                       <COND (<AND <NOT <FSET? .I ,INVISIBLE>>
                                   <SET Q <REFERS? .SPEC .I>>
                                   <G=? .Q .BEST>>
                              <TRACE 4 "[matches " T .I "(" N .I "), Q=" N .Q "]" CR>
                              <SET F T>
                              ;"Erase previous matches if this is better"
                              <COND (<G? .Q .BEST>
                                     <TRACE 4 "[clearing match list]" CR>
                                     <SET NOUT .ONOUT>
                                     <SET .BEST .Q>)>
                              <COND (<AND .NN <NP-EXCLUDES? .NP .I>>
                                     <TRACE 4 "[excluded]" CR>)
                                    (<G=? .NOUT ,P-MAX-OBJECTS>
                                     <TELL "[too many objects!]" CR>
                                     <TRACE-OUT>
                                     <RETURN>)
                                    (ELSE
                                     <TRACE 4 "[accepted]" CR>
                                     <SET NOUT <+ .NOUT 1>>
                                     <PUT/B .OUT .NOUT .I>)>)>>
                   ;"Look for a pseudo-object if we didn't find a real one."
                   <COND (<AND <NOT .F>
                               <BTST .BITS ,SF-ON-GROUND>
                               <SET Q <GETP ,HERE ,P?THINGS>>>
                          <TRACE 4 "[looking for pseudo]" CR>
                          <SET F <MATCH-PSEUDO .SPEC .Q>>
                          <COND (.F
                                 <COND (<AND .NN <NP-EXCLUDES-PSEUDO? .NP .F>>)
                                       (<G=? .NOUT ,P-MAX-OBJECTS>
                                        <TELL "[too many objects!]" CR>
                                        <TRACE-OUT>
                                        <RETURN>)
                                       (ELSE
                                        <SET NOUT <+ .NOUT 1>>
                                        <PUT/B .OUT .NOUT <MAKE-PSEUDO .F>>)>)>)>
                   <COND (<NOT .F>
                          ;"Try expanding the search if we can."
                          <COND (<N=? .BITS -1>
                                 <TRACE 4 "[expanding to ludicrous scope]" CR>
                                 <SET BITS -1>
                                 <SET OBITS -1>    ;"Avoid bouncing between <1 and >1 matches"
                                 <AGAIN .BITS-SET>)>
                          <COND (<=? ,MAP-SCOPE-STATUS ,MS-NO-LIGHT>
                                 <TELL "It's too dark to see anything here." CR>)
                                (ELSE
                                 <TELL "You can't see any such thing." CR>)>
                          <TRACE-OUT>
                          <RFALSE>)
                         (<G=? .NOUT ,P-MAX-OBJECTS>
                          <TRACE-OUT>
                          <RETURN>)>>)>
        ;"Check the number of objects"
        <PUTB .OUT 0 .NOUT>
        <COND (<0? .NOUT>
               ;"This means ALL matched nothing, or BUT excluded everything.
                 Try expanding the search if we can."
               <SET F <ORB .BITS ;"<ORB" ,SF-HELD ,SF-CARRIED ,SF-ON-GROUND ,SF-IN-ROOM ;">" >>
               <COND (<=? .BITS .F>
                      <TELL "There are none at all available!" CR>
                      <TRACE-OUT>
                      <RFALSE>)>
               <TRACE 4 "[expanding to reasonable scope]" CR>
               <SET BITS .F>
               <SET OBITS .F>    ;"Avoid bouncing between <1 and >1 matches"
               <AGAIN .BITS-SET>)
              (<1? .NOUT>
               <TRACE-OUT>
               <RETURN <GET/B .OUT 1>>)
              (<OR <=? .MODE ,MCM-ALL> <G? .NY 1>>
               <TRACE-OUT>
               <RETURN ,MANY-OBJECTS>)
              (<=? .MODE ,MCM-ANY>
               ;"Pick a random object"
               <PUT/B .OUT 1 <SET F <GET/B .OUT <RANDOM .NOUT>>>>
               <PUTB .OUT 0 1>
               <TELL "[" T .F "]" CR>
               <TRACE-OUT>
               <RETURN .F>)
              (ELSE
               ;"TODO: Do this check when we're matching YSPECs, so each YSPEC can be
                 disambiguated individually."
               ;"Try narrowing the search if we can."
               <COND (<N=? .BITS .OBITS>
                      <TRACE 4 "[narrowing scope to BITS=" N .OBITS "]" CR>
                      <SET BITS .OBITS>
                      <AGAIN .BITS-SET>)>
               <COND (<SET F <APPLY-GENERIC-FCN .OUT>>
                      <TRACE 4 "[GENERIC chose " T .F "]" CR>
                      <PUT/B .OUT 1 .F>
                      <PUTB .OUT 0 1>
                      <TRACE-OUT>
                      <RETURN .F>)>
               <WHICH-DO-YOU-MEAN .OUT>
               <COND (<=? .NP ,P-NP-DOBJ> <ORPHAN T AMBIGUOUS PRSO>)
                     (ELSE <ORPHAN T AMBIGUOUS PRSI>)>
               <TRACE-OUT>
               <RFALSE>)>>>

;"*** '...' --> 'I beg your pardon?'"
;"*** 'That sentence has no verb.' --> 'That's not a verb I recognize.'"
<ROUTINE PARSER ("AUX" NOBJ VAL DIR DIR-WN O-R KEEP OW OH OHL)
    ;"Need to (re)initialize locals here since we use AGAIN"
    <SET OW ,WINNER>
    <SET OH ,HERE>
    <SET OHL ,HERE-LIT>
    <SET NOBJ <>>
    <SET VAL <>>
    <SET DIR <>>
    <SET DIR-WN <>>
    ;"Fill READBUF and LEXBUF"
    <COND (<L? ,P-CONT 0> <SETG P-CONT 0>)>
    <COND (,P-CONT
          <TRACE 1 "[PARSER: continuing from word " N ,P-CONT "]" CR>
          <ACTIVATE-BUFS "CONT">
          <COND (<1? ,P-CONT> <SETG P-CONT 0>)
                (<N=? ,MODE ,SUPERBRIEF>
                  ;"Print a blank line between multiple commands"
                  <COND (<NOT <VERB? TELL>> <CRLF>)>)>)
          (ELSE
          <TRACE 1 "[PARSER: fresh input]" CR>
          <RESET-WINNER>
          <SETG HERE <LOC ,WINNER>>
          <SETG HERE-LIT <SEARCH-FOR-LIGHT>>
          <READLINE T>)>

    <IF-DEBUG <SETG TRACE-INDENT 0>>
    <TRACE-DO 1 <DUMPBUFS> ;<DUMPLINE>>
    <TRACE-IN>

    <SETG P-LEN <GETB ,LEXBUF 1>>
    <COND (<0? ,P-LEN>
          <TELL "I beg your pardon?" CR>
          <SETG P-CONT 0>
          <RFALSE>)>

    ;"Save undo state unless this looks like an undo command"
    <IF-UNDO
        <COND (<AND <G=? ,P-LEN 1>
                    <=? <GETWORD? 1> ,W?UNDO>
                    <OR <1? ,P-LEN>
                        <=? <GETWORD? 2> ,W?\. ,W?THEN>>>)
              (ELSE
              <TRACE 4 "[saving for UNDO]" CR>
              <BIND ((RES <ISAVE>))
                  <COND (<=? .RES 2>
                          <TELL "Previous turn undone." CR CR>
                          <SETG WINNER .OW>
                          <SETG HERE .OH>
                          <SETG HERE-LIT .OHL>
                          <V-LOOK>
                          <SETG P-CONT 0>
                          <AGAIN>)
                        (ELSE
                          <SETG USAVE .RES>)>>)>>

    <COND (<0? ,P-CONT>
          ;"Handle OOPS"
          <COND (<AND ,P-LEN <=? <GETWORD? 1> ,W?OOPS>>
                  <COND (<=? ,P-LEN 2>
                        <COND (<P-OOPS-WN>
                                <TRACE 2 "[handling OOPS]" CR>
                                <HANDLE-OOPS 2>
                                <SETG P-LEN <GETB ,LEXBUF 1>>
                                <TRACE-DO 1 <DUMPLINE>>)
                              (ELSE
                                <TELL "Nothing to correct." CR>
                                <RFALSE>)>)
                        (<=? ,P-LEN 1>
                        <TELL "It's OK." CR>
                        <RFALSE>)
                        (ELSE
                        <TELL "You can only correct one word at a time." CR>
                        <RFALSE>)>)>)>

    <SET KEEP 0>
    <P-OOPS-WN 0>
    <P-OOPS-CONT 0>
    <P-OOPS-O-REASON ,P-O-REASON>

    <COND (<0? ,P-CONT>
          ;"Save command in edit buffer for OOPS"
          <COND (<N=? ,READBUF ,EDIT-READBUF>
                  <COPY-TO-BUFS "EDIT">
                  <ACTIVATE-BUFS "EDIT">)>
          ;"Handle an orphan response, which may abort parsing or ask us to skip steps"
          <COND (<ORPHANING?>
                  <SET O-R <HANDLE-ORPHAN-RESPONSE>>
                  <COND (<N=? .O-R ,O-RES-NOT-HANDLED>
                        <SETG WINNER .OW>
                        <SETG HERE .OH>
                        <SETG HERE-LIT .OHL>)>
                  <COND (<=? .O-R ,O-RES-REORPHANED>
                        <TRACE-OUT>
                        <RFALSE>)
                        (<=? .O-R ,O-RES-FAILED>
                        <SETG P-O-REASON <>>
                        <TRACE-OUT>
                        <RFALSE>)
                        (<=? .O-R ,O-RES-SET-NP>
                        ;"TODO: Set the P-variables somewhere else? Shouldn't we fill in what
                          we know about the command-to-be when we ask the orphaning question, not
                          when we get the response?"
                        <SETG P-P1 <GETB ,P-SYNTAX ,SYN-PREP1>>
                        <COND (<ORPHANING-PRSI?>
                                <SETG P-P2 <GETB ,P-SYNTAX ,SYN-PREP2>>
                                <SETG P-NOBJ 2>
                                ;"Don't re-match P-NP-DOBJ when we've just orphaned PRSI. Use the saved
                                  match results. There won't be a NP to match if we GWIMmed PRSO."
                                <SET KEEP 1>)
                              (ELSE <SETG P-NOBJ 1>)>)
                        (<=? .O-R ,O-RES-SET-PRSTBL>
                        <COND (<ORPHANING-PRSI?> <SET KEEP 2>)
                              (ELSE <SET KEEP 1>)>)>
                  <SETG P-O-REASON <>>)>
          ;"If we aren't handling this command as an orphan response, convert it if needed
            and copy it to CONT bufs"
          <COND (<NOT .O-R>
                  ;"Translate order syntax (HAL, OPEN THE POD BAY DOOR or
                    TELL HAL TO OPEN THE POD BAY DOOR) into multi-command syntax
                    (\,TELL HAL THEN OPEN THE POD BAY DOOR)."
                  <COND (<CONVERT-ORDER-TO-TELL?>
                        <SETG P-LEN <GETB ,LEXBUF 1>>)>)>)>

    ;"Identify parts of speech, parse noun phrases"
    <COND (<N=? .O-R ,O-RES-SET-NP ,O-RES-SET-PRSTBL>
          <SETG P-V <>>
          <SETG P-NOBJ 0>
          <CLEAR-NOUN-PHRASE ,P-NP-DOBJ>
          <CLEAR-NOUN-PHRASE ,P-NP-IOBJ>
          <SETG P-P1 <>>
          <SETG P-P2 <>>
          ;"Identify the verb, prepositions, and noun phrases"
          <REPEAT ((I <OR ,P-CONT 1>) W V)
              <COND (<G? .I ,P-LEN>
                      ;"Reached the end of the command"
                      <SETG P-CONT 0>
                      <RETURN>)
                    (<NOT <OR <SET W <GETWORD? .I>>
                              <AND <PARSE-NUMBER? .I> <SET W ,W?\,NUMBER>>>>
                      ;"Word not in vocabulary"
                      <STORE-OOPS .I>
                      <SETG P-CONT 0>
                      <TELL "I don't know the word \"" WORD .I "\"." CR>
                      <RFALSE>)
                    (<=? .W ,W?THEN ,W?\.>
                      ;"End of command, maybe start of a new one"
                      <TRACE 3 "['then' word " N .I "]" CR>
                      <SETG P-CONT <+ .I 1>>
                      <COND (<G? ,P-CONT ,P-LEN> <SETG P-CONT 0>)
                            (ELSE <COPY-TO-BUFS "CONT">)>
                      <RETURN>)
                    (<AND <NOT ,P-V>
                          <SET V <WORD? .W VERB>>
                          <OR <NOT .DIR> <=? .V ,ACT?WALK>>>
                      ;"Found the verb"
                      <SETG P-V-WORD .W>
                      <SETG P-V-WORDN .I>
                      <SETG P-V .V>
                      <TRACE 3 "[verb word " N ,P-V-WORDN " '" B ,P-V-WORD "' = " N ,P-V "]" CR>)
                    (<AND <NOT .DIR>
                          <EQUAL? ,P-V <> ,ACT?WALK>
                          <SET VAL <WORD? .W DIRECTION>>>
                      ;"Found a direction"
                      <SET DIR .VAL>
                      <SET DIR-WN .I>
                      <TRACE 3 "[got a direction]" CR>)
                    (<SET VAL <CHKWORD? .W ,PS?PREPOSITION 0>>
                      ;"Found a preposition"
                      ;"Only keep the first preposition for each object"
                      <COND (<AND <==? .NOBJ 0> <NOT ,P-P1>>
                            <TRACE 3 "[P1 word " N .I " '" B .W "' = " N .VAL "]" CR>
                            <SETG P-P1 .VAL>)
                            (<AND <==? .NOBJ 1> <NOT ,P-P2>>
                            <TRACE 3 "[P2 word " N .I " '" B .W "' = " N .VAL "]" CR>
                            <SETG P-P2 .VAL>)>)
                    (<STARTS-NOUN-PHRASE? .W>
                      ;"Found a noun phrase"
                      <SET NOBJ <+ .NOBJ 1>>
                      <TRACE 3 "[NP start word " N .I ", now NOBJ=" N .NOBJ "]" CR>
                      <TRACE-IN>
                      <COND (<==? .NOBJ 1>
                            ;"If we found a direction earlier, try it as a preposition instead"
                            ;"This fixes GO IN BUILDING (vs. GO IN)"
                            <COND (<AND .DIR
                                        ,P-V
                                        <NOT ,P-P1>
                                        <SET V <GETWORD? .DIR-WN>>
                                        <SET VAL <CHKWORD? .V ,PS?PREPOSITION 0>>>
                                    <TRACE 3 "[revising direction word " N .DIR-WN
                                            " as P1: '" B .V "' = " N .VAL "]" CR>
                                    <SETG P-P1 .VAL>
                                    <SET DIR <>>
                                    <SET DIR-WN <>>)>
                            <SET VAL <PARSE-NOUN-PHRASE .I ,P-NP-DOBJ>>)
                            (<==? .NOBJ 2>
                            <SET VAL <PARSE-NOUN-PHRASE .I ,P-NP-IOBJ>>)
                            (ELSE
                            <SETG P-CONT 0>
                            <TELL "That sentence has too many objects." CR>
                            <RFALSE>)>
                      <TRACE 3 "[PARSE-NOUN-PHRASE returned " N .VAL "]" CR>
                      <TRACE-OUT>
                      <COND (.VAL
                            <SET I .VAL>
                            <AGAIN>)
                            (ELSE
                            <SETG P-CONT 0>
                            <RFALSE>)>)
                    (ELSE
                      ;"Unexpected word type"
                      <STORE-OOPS .I>
                      <SETG P-CONT 0>
                      <TELL "I didn't expect the word \"" WORD .I "\" there." CR>
                      <TRACE-OUT>
                      <RFALSE>)>
              <SET I <+ .I 1>>>

          <SETG P-NOBJ .NOBJ>

          <TRACE-OUT>
          <TRACE 1 "[sentence: V=" MATCHING-WORD ,P-V ,PS?VERB ,P1?VERB "(" N ,P-V ") NOBJ=" N ,P-NOBJ
                " P1=" MATCHING-WORD ,P-P1 ,PS?PREPOSITION 0 "(" N ,P-P1
                ") DOBJS=+" N <NP-YCNT ,P-NP-DOBJ> "-" N <NP-NCNT ,P-NP-DOBJ>
                " P2=" MATCHING-WORD ,P-P2 ,PS?PREPOSITION 0 "(" N ,P-P2
                ") IOBJS=+" N <NP-YCNT ,P-NP-IOBJ> "-" N <NP-NCNT ,P-NP-IOBJ> "]" CR>
          <TRACE-IN>

          ;"If we have a direction and nothing else except maybe a WALK verb, it's
            a movement command."
          <COND (<AND .DIR
                      <EQUAL? ,P-V <> ,ACT?WALK>
                      <0? .NOBJ>
                      <NOT ,P-P1>
                      <NOT ,P-P2>>
                  <SETG PRSO-DIR T>
                  <SETG PRSA ,V?WALK>
                  <SETG PRSO .DIR>
                  <SETG PRSI <>>
                  <COND (<NOT <VERB? AGAIN>>
                        <TRACE 4 "[saving for AGAIN]" CR>
                        <SAVE-PARSER-RESULT ,AGAIN-STORAGE>)>
                  <TRACE-OUT>
                  <RTRUE>)>
          ;"Otherwise, a verb is required and a direction is forbidden."
          <COND (<NOT ,P-V>
                  <SETG P-CONT 0>
                  <TELL "That's not a verb I recognize." CR>
                  <TRACE-OUT>
                  <RFALSE>)
                (.DIR
                  <STORE-OOPS .DIR-WN>
                  <SETG P-CONT 0>
                  <TELL "I don't understand what \"" WORD .DIR-WN "\" is doing in that sentence." CR>
                  <TRACE-OUT>
                  <RFALSE>)>
          <SETG PRSO-DIR <>>)>
    ;"Match syntax lines and objects"
    <COND (<NOT .O-R>
          <TRACE 2 "[matching syntax and finding objects, KEEP=" N .KEEP "]" CR>
          <COND (<NOT <AND <MATCH-SYNTAX> <FIND-OBJECTS .KEEP>>>
                  <TRACE-OUT>
                  <SETG P-CONT 0>
                  <RFALSE>)>)
          (<L? .KEEP 2>
          ;"We already found a syntax line last time, but we need FIND-OBJECTS to
            match at least one noun phrase."
          <TRACE 2 "[only finding objects, KEEP=" N .KEEP "]" CR>
          <COND (<NOT <FIND-OBJECTS .KEEP>>
                  <TRACE-OUT>
                  <SETG P-CONT 0>
                  <RFALSE>)>)>
    ;"Save command for AGAIN"
    <COND (<NOT <VERB? AGAIN>>
          <TRACE 4 "[saving for AGAIN]" CR>
          <SAVE-PARSER-RESULT ,AGAIN-STORAGE>)>
    ;"If successful PRSO, back up PRSO for IT"
    <SET-PRONOUNS ,PRSO ,P-PRSOS>
    <TRACE-OUT>
    <RTRUE>>

;"*** 'I don't think [actor] would appreciate that.' --> 'I don't suppose [actor] would care for that.'"
<ROUTINE YOU-MASHER ("OPT" WHOM)
    <TELL "I don't suppose " T <OR .WHOM ,PRSO> " would care for that." CR>>

;"*** 'You can't use multiple [in]direct objects with [noun].' --> 'You can't use multiple objects with that verb.'"
<ROUTINE MANY-CHECK (OBJ OPTS INDIRECT?)
    <COND (<AND <=? .OBJ ,MANY-OBJECTS>
                <NOT <BTST .OPTS ,SF-MANY>>>
           <COND (<VERB? TELL>
                  <TELL "You can only address one person at a time.">)
                 (ELSE
                  <TELL "You can't use multiple objects with that verb.">)>
           <CRLF>
           <SETG P-CONT 0>
           <RFALSE>)>
    <RTRUE>>

;"*** Remove all responses to numbers"
<ROUTINE NUMBER-F () <TELL "You can't see any such thing." CR>>

<SET REDEFINE <>>
