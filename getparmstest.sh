#!/usr/bin/env bash
#############################################################################
#_TEST_INFO_BGN # Document page delimiters; output via: getparmstest.sh --help|-help
#
# getparmstest is the utility to test getparms, the command-line parser;
# all the tests can be run sequentially or they can be by sub-test type;
# all of the getparms debug & config flags can be passed directly to it.
# NB: getparmstest also generates help files for getparms (via -x option)
#
# Tests are divided into the following sub-groups: -t{acdefhimoprs}
# - TestConfigs (-tc): checks that all configuration flags (-c) are working correctly -  40
# - TestDataTyp (-td): checks that all data types (but str|var) are working correctly -  81
# - TestErrored (-te): checks for sources for each getparms err to see if it's caught - 113
# - TestFeature (-tf): checks each feature in isolation (good for regression testing) -  99
# - TestInterns (-ti): checks internal functions for proper operation and/or display  -  05
# - TestHelpOut (-th): checks that all the varied help responses are working rightly  -  49
# - TestMatches (-tm): checks that plain+regex string matchings are working correctly -  95
# - TestOutputs (-to): checks that output display is as getparms.sh last expected it  -  14
# - TestPrefers (-tp): checks that symbols can be changed via prefs. (-p[bgamertpx])  -  17
# - TestReqOpts (-tr): checks required versus optional for all delimiters (-o[nspac]) -  10
# - TestStrType (-ts): checks that the string|vars data types are working correctly   -  84
# - TestTimings (-tt): clocks average time to run certain (non-file based) executions -  07
# - TestVariety (-tv): checks that variety & order of required & optional parms+opts  -  45
#-------------------------------------------------------------------------------------- 649
# - TestAllTest (-ta): runs the specified range of tests above, except: Test Timings  - 642
# - TestAllTest (-a):  runs the specified range of tests above, include Test Timings  - 642
#                      Note: Test Timings are run, but are not counted in the total
# - TestExample (-x) : runs the tests useful for examples and generates a text file
# - Redo_Failed (-r) : redoes test failures (copy failed output line to test input)
#
#   Where '?' is 1 of test sub-groups:
#   To show all test descriptions use: -a
#   To show all subgroup descriptions: -t?
#   To run all of the tests available: -a0
#   To run all the tests in sub-group: -t?0
#   To run range of tests in subgroup: -t?3-5
#   To run specific tests in subgroup: -t?1,3,5
#   To rerun a list of subgroup tests: -r -t? 1 3 5
#
# The following are temp files created by getparmstest [often to capture
# failures|extra output: PID = procID, USR = username, FCN = function]:
# -----------------------------------------------------------------------
# - .getparms.all.PID      : temp file captures number run tests & failed
# - .getparms.help.PID     : temp file captures test summaries
# - .getparms.quit.PID     : temp file captures capture quit flag
# - .getparms.srch.PID     : temp file captures capture help output
# - .getparms.temp.PID     : temp file captures capture test errors
# - .getparms.time.txt     : temp file captures timing tests output
# - .getparms.PID.dis.txt  : temp file captures tracing disable calls
# - .getparms.PID.ena.txt  : temp file captures tracing enable calls
# - .getparms.hist         : temp file captures test execution # not per process
#                            [output appended to file so > 1 copy of getparmstest
#                            can be run at the time, though output will be mixed]
#
#_TEST_INFO_END # Document page delimiters
#############################################################################

TEST_VERS="1.3.0"; # present version of this utility

#############################################################################
# Coding Notes
# NB: All tests are 1-based in order to accommodate 0 being the do-all case
# NB: getparms changes SELF, NAME, ROAD so we shouldn't use those varnames
# NB: be careful to avoid name collision with functions & vars in getparms.sh
# NB: getparmstest is very dependent on getparms, reusing not only some of
# Required funcs. from getparms: GetRange, GetText, Indent
# Required arrays from getparms: Symbl, IOptn, ICmnt, Items, Ex_Files, ErrTest
# Required values from getparms: Reinit, CF_ALLS, CF_ITEM, ROAD, SELF, BADOPT,
#   UCAS, LCAS, NMBR, ITEM_START, ITEM_MAXIM, ITEM_NOLMT, ITEM_SQARE, ITEM_PARAN,
#   ITEM_ANGLE, ITEM_CURLY, ITEM_SDASH, ITEM_WORDS, ITEM_DDASH, ITEM_QUOTE,
#   ITEM_PIPES, ITEM_COMNT, DLMTGRP, OIND, MATHGRP, PUNCGRP, SYMSGRP, UNDRSCR,
#   SAMP_OPTS, SPACGRP, SYMB_SPEC, SYM_GRUP, SYM_ALTN, SYM_MORE, SYM_ECMT,
#   SYM_RANG, SYM_TYP, SYM_PLAN, SYM_REGX, RSLT, DT_MNG, RTNHDG, SPCLIN,
#   ErrText[BERR], GETPARMS_VERS
#############################################################################

#############################################################################
# File Use by getparmstest.sh
#############################################################################
TEST_SELF="$0";                     # who am i:  /user/bin/getparmstest.sh
TEST_NAME=${TEST_SELF##*/};         # my script: getparmstest.sh
TEST_FUNC=${TEST_NAME%.*}           # function:  getparmstest
TEST_ROAD="${TEST_SELF%/*}";        # road/path: /user/bin
TEST_LEAD="$TEST_ROAD/$TEST_FUNC";  # leading:   /user/bin/getparmstest
TPID=$PPID;                         # processId: xxx

TEST_BASE="getparms";               # file: being tested
TEST_FILE="$TEST_BASE.sh";          # file: getparms.sh
TEST_EXAM="$TEST_BASE.x???.txt";    # file: getparms.x???.txt   [display only]
TEST_VIEW="$TEST_ROAD/$TEST_BASE";  # view: /user/bin/getparms
TEST_TEST="$TEST_ROAD/$TEST_FILE";  # whol: /user/bin/getparms.sh

# hidden files for private use
TEST_HIDN="$TEST_ROAD/.$TEST_BASE"; # hidn: /user/bin/.getparms
TIME_FILE=".$TEST_BASE.time.txt";   # time: .getparms.time.txt
TEST_TIME="$TEST_ROAD/$TIME_FILE";  # time: /user/bin/.getparms.time.txt
TEST_ALLE="$TEST_HIDN.all.$TPID";   # file: /user/bin/.getparms.all.pid
TEST_HELP="$TEST_HIDN.help.$TPID";  # file: /user/bin/.getparms.help.pid
TEST_QUIT="$TEST_HIDN.quit.$TPID";  # file: /user/bin/.getparms.quit.pid
TEST_SRCH="$TEST_HIDN.srch.$TPID";  # file: /user/bin/.getparms.srch.pid
TEST_FTMP="$TEST_HIDN.temp.$TPID";  # file: /user/bin/.getparms.temp.pid
TEST_HIST="$TEST_HIDN.hist";        # hist: /user/bin/.getparms.hist
                                    # Note: last file not per process

#############################################################################
# source getparms so that we have access to all of it's pre-defined items
# but only do it if not already done (getparms -t => getparmstest => getparms)
#############################################################################
if [[ ! "$GETPARMS_VERS" ]]; then       # if not sourced, silently
. "$TEST_TEST" 2>/dev/null >/dev/null;  # source $TEST_ROAD/getparms.sh
fi

# generic global defines
Divider='#----------------------------------------------------------------------------';
NmRun=0; NUM_TST=0;  # number tests run & max test number (set in Test...)
PASS="Passed:"; FAIL="FAILED!"; # strings used to find passed|failed tests
NOFIL="file doesn't exist:";    UNDEF="undefined test";
DoAll=""; # doing all tests flag

#############################################################################
# TestConfigs : -tc# (0 is all, "" is show descriptions) : abcehlnqrsuwdiomy
# Here are all the verification tests to test all the config flags (-c.) work
# ConfigsRslt is set when we need to call result to get the status in text
# (primarily used only for those cases where func=? is not output). Config
# Tests need a special explanation field since the Description is used to
# contain the config string, even though it is being tested different ways.
#############################################################################
declare -a ConfigsOpts; declare -a ConfigsDesc; declare -a ConfigsDsc2;
declare -a ConfigsHelp; declare -a ConfigsIsEg; declare -a ConfigsFail;
declare -a ConfigsCmdl; declare -a ConfigsRslt; declare -a ConfigsFind;
declare -a ConfigsUMsg; declare -a ConfigsNone; i=1; # 1-based tests

# begin tests : display config flags ----------------------------------------

# Analyze only mode: only check specification not command-line items
# This we mark as failed because we won't get the func status
cfg=$CF_ANALYZ; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -ca
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i # no error';   ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='ANALYZE=0';
ConfigsDsc2[$i]=" - Analysis Mode with no error"; ((i++)); # -tc01|-tc1

cfg=$CF_ANALYZ; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -ca
ConfigsOpts[$i]="${opt}n"; ConfigsDesc[$i]="$opt : $cstr";  # disable errorss
ConfigsHelp[$i]='func -. # w/ error';   ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=1;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='ANALYZE=9';
ConfigsDsc2[$i]=" - Analysis Mode with an error"; ((i++)); # -tc02|-tc2

# Beginning processing result to be shown for all specification rows
cfg=$CF_BGNSPC; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cb
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func # verify hdr';    ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]="$SPCLIN func";
ConfigsDsc2[$i]=" - Begin Spec display a header"; ((i++)); # -tc03|-tc3

cfg=$CF_BGNSPC; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cb
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func # verify func';   ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='optn[00]: func';
ConfigsDsc2[$i]=" - Begin Spec display function"; ((i++)); # -tc04|-tc4

cfg=$CF_BGNSPC; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cb
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {parm} # optn parm'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='optn[01]: parm';
ConfigsDsc2[$i]=" - Begin Spec display optional"; ((i++)); # -tc05|-tc5

cfg=$CF_BGNSPC; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cb
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func  parm  # reqd parm'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='parm'; ConfigsFind[$i]='reqd[01]: parm';
ConfigsDsc2[$i]=" - Begin Spec display required"; ((i++)); # -tc06|-tc6

# Capture statuses of command-line items even if item is not changed
cfg=$CF_CAPALL; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cc
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {parm} # unchanged param'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='parm=""';
ConfigsDsc2[$i]=" - Unchanged parm status shown"; ((i++)); # -tc07|-tc7

cfg=$CF_CAPALL; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cc
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i} # unchanged option'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='_i=0';
ConfigsDsc2[$i]=" - Unchanged optn status shown"; ((i++)); # -tc08|-tc8

cfg=$CF_CAPALL; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cc
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i=} # unchanged SHIP'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='_i=""';
ConfigsDsc2[$i]=" - Unchanged SHIP status shown"; ((i++)); # -tc09|-tc9

cfg=$CF_CAPALL; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cc
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i=prm} # unchanged indp parm'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='prm=""';
ConfigsDsc2[$i]=" - Unchanged indp parm capture"; ((i++)); # -tc10

cfg=$CF_CAPALL; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cc
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i=prm} # unchanged indp optn'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='_i=0';
ConfigsDsc2[$i]=" - Unchanged indp optn capture"; ((i++)); # -tc11

# Suppress all extra empty lines added just for beautifying display
cfg=$CF_ECHONO; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -ce
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i} # no extra returns'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='';
ConfigsDsc2[$i]=" - Verify are no extra returns"; ((i++)); # -tc12

cfg=$CF_ECHONO; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -ce
ConfigsOpts[$i]=""; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i} # w/ extra returns (not shown)'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='';
ConfigsDsc2[$i]=" - Verify the carriage returns"; ((i++)); # -tc13

# Note: there is also an help test using Test Help Out bad opt (see test: -th2)
cfg=$CF_HELPNO; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -ch
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]=''; ConfigsNone[$i]='getparms is';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=1;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='';
ConfigsDsc2[$i]=" - Show no Help w/ empty lines"; ((i++)); # -tc14

cfg=$CF_HELPNO; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -ch
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]=''; ConfigsNone[$i]='getparms is';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=1;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='-h'; ConfigsFind[$i]='';
ConfigsDsc2[$i]=" - Show no Help w/ help option"; ((i++)); # -tc15

# Leading underscores from any dashed item's output name are removed
cfg=$CF_LDUSNO; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cl
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i # pure optn';  ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='-i'; ConfigsFind[$i]='i=1';
ConfigsDsc2[$i]=" - Remove leading _ with optns"; ((i++)); # -tc16

# NB: this also verifies that -i= can be input
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i= # SHIP opt';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='-i='; ConfigsFind[$i]='i=""';
ConfigsDsc2[$i]=" - Remove leading _ with SHIPs"; ((i++)); # -tc17

ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i=parm # ind parm'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='-i parm'; ConfigsFind[$i]='i=1';
ConfigsDsc2[$i]=" - Remove leading _ ind option"; ((i++)); # -tc18

# No error messages will be outputted [i.e. operate in a quiet mode]
cfg=$CF_NO_ERR; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cn
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i # more info';  ConfigsNone[$i]=''; # or: ErrorMsgs
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=1;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='UNFOUND';
ConfigsDsc2[$i]=" - No error message req option"; ((i++)); # -tc19

# Suppress output messages except for result (fnam=0) [a quiet mode]
# all received items are no longer printed and thus can't be known
cfg=$CF_NO_OUT; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cq
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func parm # more info'; ConfigsNone[$i]='parm';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='valu'; ConfigsFind[$i]='';
ConfigsDsc2[$i]=" - Hide output all rcvd. items"; ((i++)); # -tc20

# Row numbers (0-based) are to be prefixed to each row that's output
cfg=$CF_ROWNUM; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cr
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i # more info';  ConfigsCmdl[$i]='-i';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsFind[$i]='1:0 _i=1';
ConfigsDsc2[$i]=" - Show row nums for all optns"; ((i++)); # -tc21

cfg=$CF_ROWNUM; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cr
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i -j parm # more info';  ConfigsCmdl[$i]='5 -j -i';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsFind[$i]='1:2 _i=1';
ConfigsDsc2[$i]=" - Show row options diff order"; ((i++)); # -tc22

# Status of displayed command-line items to be prefixed for each row
cfg=$CF_STATUS; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cs
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func parm # received = valid'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='valu'; ConfigsFind[$i]='valid[1]';
ConfigsDsc2[$i]=" - Item's status rcvd is valid"; ((i++)); # -tc23

# empty : item unreceived (if optl.) # NB: without -cc won't be displayed (suppressed)
cfg=$CF_STATUS; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cs
ConfigsOpts[$i]="$opt -cc"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i} # not rcvd = empty'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='empty[0]';
ConfigsDsc2[$i]=" - Item's status rcvd is empty"; ((i++)); # -tc24

# misin : item unreceived (if reqd.) # NB: without -cc won't be displayed (suppressed)
cfg=$CF_STATUS; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cs
ConfigsOpts[$i]="$opt -cc"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i # not rcvd = misin'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=1;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='misin[0]';
ConfigsDsc2[$i]=" - Item's status item missing "; ((i++)); # -tc25

# invld : item received invalid value
cfg=$CF_STATUS; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cs
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i= # received = bad value'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=1;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='-ia'; ConfigsFind[$i]='invld[1]'; # purposeful err
ConfigsDsc2[$i]=" - Item's status rcvd invalids"; ((i++)); # -tc26

# multi : item was received multiple times
cfg=$CF_STATUS; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cs
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i parm # received = too many'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=1;     ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='-i valu -i'; ConfigsFind[$i]='multi[2]: _i=2';
ConfigsDsc2[$i]=" - Item's status rcvd multiple"; ((i++)); # -tc27

# User message text is added to output: -cu{=| }"user supplied text"
cfg=$CF_USRMSG; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cu
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i} parm # quoted user message'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;      ConfigsFail[$i]=0;
ConfigsUMsg[$i]="\"quoted user message\""; ConfigsRslt[$i]=0;
ConfigsCmdl[$i]='valu'; ConfigsFind[$i]='"quoted user message"';
ConfigsDsc2[$i]=" - Show user message as quoted"; ((i++)); # -tc28

cfg=$CF_USRMSG; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cu
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i} parm # unquoted user message'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;      ConfigsFail[$i]=0;
ConfigsUMsg[$i]="unquoted user message";   ConfigsRslt[$i]=0;
ConfigsCmdl[$i]='valu'; ConfigsFind[$i]='unquoted user message';
ConfigsDsc2[$i]=" - Show user message unquoted "; ((i++)); # -tc29

# NB: ConfigsOpts is "" & -cu is put with ConfigsUMsg with '='
cfg=$CF_USRMSG; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cu
ConfigsOpts[$i]=""; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i} parm # equals before msg'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;
ConfigsUMsg[$i]="$opt='a user message'"; ConfigsRslt[$i]=0;
ConfigsCmdl[$i]='valu'; ConfigsFind[$i]='a user message';
ConfigsDsc2[$i]=" - Show user message w/ equals"; ((i++)); # -tc30

# NB: ConfigsOpts is "" & -cu is put with ConfigsUMsg w/o '='
cfg=$CF_USRMSG; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cu
ConfigsOpts[$i]=""; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i} parm # option abuts msg'; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;
ConfigsUMsg[$i]="$opt'a user message'";  ConfigsRslt[$i]=0;
ConfigsCmdl[$i]='valu'; ConfigsFind[$i]='a user message';
ConfigsDsc2[$i]=" - Show user message abuts opt"; ((i++)); # -tc31

# verify with wrapping that it can't find whole help string
cfg=$CF_USRMSG; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cw
ConfigsOpts[$i]="-cbrs -on $opt"; ConfigsDesc[$i]="$opt : $cstr"; # no opt
ConfigsHelp[$i]='func <file_txt~sj+-%~.Txt> -v:verb|m~h|--verb {-in} {-io} -i {-j} [-m=ind_parm] -e <-f|--files ifile tfile ofile> {--} <param1~ip> [param2 param3~sw-]';
ConfigsCmdl[$i]='file.txt 0x3A  -ji -ion -e --files in.txt tmp.txt out.txt 12 "all In" "all on"';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=1; ConfigsNone[$i]="$SPCLIN: ${ConfigsHelp[$i]}";
ConfigsUMsg[$i]="Wrap Enabled (default)"; ConfigsRslt[$i]=0; ConfigsFind[$i]="";
ConfigsDsc2[$i]=" - Show effect of wrapped line"; ((i++));  # -tc32

# disable auto-Wrapping of long lines (e.g.: SpecLine or HELP lines)
# NB: quote marks will disappear, so don't include in search string,
# also any comment is discarded, so dont include that either
cfg=$CF_NOWRAP; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cw
ConfigsOpts[$i]="-cbrs -on $opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func <file_txt~sj+-%~.Txt> -v:verb|m~h|--verb {-in} {-io} -i {-j} [-m=ind_parm] -e <-f|--files ifile tfile ofile> {--} <param1~ip> [param2 param3~sw-]';
ConfigsCmdl[$i]='file.txt 0x3A  -ji -ion -e --files in.txt tmp.txt out.txt 12 "all In" "all on"';
ConfigsUMsg[$i]=""; ConfigsRslt[$i]=0; ConfigsFind[$i]="${ConfigsHelp[$i]}";
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0; ConfigsNone[$i]='';
ConfigsDsc2[$i]=" - Show effect no wrapped line"; ((i++));  # -tc33

# parsing configuration flags ----------------------------------------------

# disable errors on duplicates of same: opt, ind parm, SHIP received
cfg=$CF_DUPOPT; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cd
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr"; # now not a failure
ConfigsHelp[$i]='func -i # received = multiple pure'; ConfigsNone[$i]='';
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='-i -i -i'; ConfigsFind[$i]='_i=3';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsDsc2[$i]=" - Suppress duplicate err pure"; ((i++));  # -tc34

cfg=$CF_DUPOPT; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cd
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr"; # now not a failure
ConfigsHelp[$i]='func -i=parm # received = multiple indp'; ConfigsNone[$i]='';
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='-i prm1 -i prm2'; ConfigsFind[$i]='parm="prm1=prm2"';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsDsc2[$i]=" - Suppress duplicate err indp"; ((i++));  # -tc35

cfg=$CF_DUPOPT; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cd
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr"; # now not a failure
ConfigsHelp[$i]='func -i= # received = multiple SHIP'; ConfigsNone[$i]='';
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='-i5 -i6'; ConfigsFind[$i]='_i=5=6';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsDsc2[$i]=" - Suppress duplicate err SHIP"; ((i++));  # -tc36

# Note: N/A for pos. parms => UNKI : Unknown parameter was received

# disable old style Ind Parm assignments, warn if -i=val in cmd-line
cfg=$CF_INDEQL; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -ci
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func {-i=parm} # more info'; ConfigsNone[$i]='';
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]='-i=val'; ConfigsFind[$i]="${ErrText[$OIND]}";
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=1;  ConfigsUMsg[$i]="";
ConfigsDsc2[$i]=" - Disable old style indp cmdl"; ((i++)); # -tc37

# MULTOP : disable combining of multiple One [1] letter pure options into one
# these are done in Test Feature : Option Combinations: Single Letter Combos) # -co

# MULT2O : disable combining of Multiple two [2] letter pure options into one
# these are done in Test Feature : Option Combinations: Double Letter Combos) # -cm

# Disable the use of location symbols for regex matching|extractions
# Note: without this config set, we couldn't match a '~' in a string
cfg=$CF_RGXLOC; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cx
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func parm~s%%.txt~ # more info';  ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsCmdl[$i]='file.txt~';
ConfigsRslt[$i]=0;  ConfigsUMsg[$i]=""; ConfigsFind[$i]='.txt~';
ConfigsDsc2[$i]=" - Put last status into a file"; ((i++)); # -tc38

# save result of running getparms into file for later retrieval (-r)
cfg=$CF_RESULT; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cy
ConfigsOpts[$i]="$opt"; ConfigsDesc[$i]="$opt : $cstr";
ConfigsHelp[$i]='func -i # more info';  ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsCmdl[$i]='-i';
ConfigsRslt[$i]=0;  ConfigsUMsg[$i]=""; ConfigsFind[$i]='';
ConfigsDsc2[$i]=" - Put last status into a file"; ((i++)); # -tc39

# NB: following test is dependent on previous test running first
cfg=$CF_RESULT; opt=${CfgOptn[$cfg]}; cstr=${CfgMsg[$cfg]}; # -cy
ConfigsOpts[$i]="$CF_RSLT func"; ConfigsDesc[$i]="$opt : $cstr"; # -r
ConfigsHelp[$i]=''; ConfigsNone[$i]='';
ConfigsIsEg[$i]=1;  ConfigsFail[$i]=0;  ConfigsUMsg[$i]="";
ConfigsRslt[$i]=0;  ConfigsCmdl[$i]=''; ConfigsFind[$i]='func=0';
ConfigsDsc2[$i]=" - Get last status from a file"; ((i++)); # -tc40

SizeConfigs=$((i-1)); # End of All the Tests : keep as the last line

#############################################################################
# TestFeature : -tf# (0 is all, "" is show descriptions)
# Here are the verification tests to test all the supported features
# starting with the simplest features and working to more complicated
#############################################################################
declare -a FeatureDesc; declare -a FeatureHelp; declare -a FeatureCmdl;
declare -a FeatureFail; declare -a FeatureOpts; declare -a FeatureIsEg;
declare -a FeatureFind; i=1; # 1-based tests

# begin tests : Option Ordering Independence --------------------------------

FeatureDesc[$i]="Pure option in any order";
FeatureHelp[$i]='func -i -j -k # more info'; FeatureIsEg[$i]=1;
FeatureFind[$i]=''; FeatureCmdl[$i]='-k -i -j'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccs'; ((i++)); # -tf01|-tf1

FeatureDesc[$i]="Option any order req|opt";
FeatureHelp[$i]="func -j {-i}"; FeatureIsEg[$i]=1;
FeatureFind[$i]=''; FeatureCmdl[$i]='-j'; FeatureFail[$i]=0;
FeatureOpts[$i]=''; ((i++));     # -tf02|-tf2

FeatureDesc[$i]="Ind parm be in any order";
FeatureHelp[$i]='func -i=iprm -j=jprm -k=kprm # more info';
FeatureIsEg[$i]=1;  FeatureFind[$i]=''; FeatureCmdl[$i]='-k kval -i ival -j jval';
FeatureFail[$i]=0;  FeatureOpts[$i]='-ccs'; ((i++)); # -tf03|-tf3

# Output Name Collisions ---------------------------------------------------

FeatureDesc[$i]="O/P names collide: -a _a"; # old test 15
FeatureHelp[$i]='func -d-m# -a _a a --arg-parse parm'; FeatureIsEg[$i]=1;
FeatureFind[$i]=''; FeatureCmdl[$i]='-a -d-m-0.03 "got it";'; # HLPN
FeatureFail[$i]=1;  FeatureOpts[$i]='-crs -on'; ((i++));  # -tf04|-tf4
# above must fail due to collision of option -a & parm _a w/ leading _

FeatureDesc[$i]="O/P names collide: -a  a";  # old test 16
FeatureHelp[$i]='func -d-m# -a _a a --arg-parse parm'; FeatureIsEg[$i]=1;
FeatureFind[$i]=''; FeatureCmdl[$i]='-a -d-m-0.03 "got it"'; # HLPN
FeatureFail[$i]=1;  FeatureOpts[$i]='-crs -on'; ((i++));  # -tf05|-tf5
# above must fail due to collision of parm a option -a with no leading _

# User Messages [done in TestConfigs: -tc26-29] ----------------------------

# Beginning and Ending Parms ----------------------------------------------

FeatureDesc[$i]="Check begprm opt & req";
FeatureHelp[$i]='func {prm1} prm2 -i -j -k # more info'; FeatureFail[$i]=0;
FeatureFind[$i]='prm2="val1"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='val1 -k -i -j';
FeatureOpts[$i]='-ccs'; ((i++)); # -tf06|-tf6

FeatureDesc[$i]="Check endprm opt & req";
FeatureHelp[$i]='func -i -j -k {prm1} prm2 # more info'; FeatureFail[$i]=0;
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-k -i -j val1';
FeatureOpts[$i]='-ccs'; ((i++)); # -tf07|-tf7

FeatureDesc[$i]="Check endprm opt & req"; FeatureFail[$i]=0;
FeatureHelp[$i]='func -i -j -k {prm1} prm2 # more info';
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='val1 -k -i -j';
FeatureOpts[$i]='-ccs'; ((i++)); # -tf08|-tf8
# previously failed:  05 [REQD]: Required item was not received: prm2

# Optional Positional Parms ------------------------------------------------

FeatureDesc[$i]="Check begprm req & opt"; FeatureFail[$i]=0;
FeatureHelp[$i]='func prm1 {prm2} -i -j -k # more info';
FeatureFind[$i]='prm1="val1"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='val1 -k -i -j';
FeatureOpts[$i]='-ccs'; ((i++)); # -tf09|-tf9

FeatureDesc[$i]="Check begprm opt & req"; FeatureFail[$i]=0;
FeatureHelp[$i]='func {prm1} prm2 -i -j -k # more info';
FeatureFind[$i]='prm2="val2"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='val1 val2 -k -i -j';
FeatureOpts[$i]='-ccs'; ((i++)); # -tf10

FeatureDesc[$i]="Check endprm opt & req"; # actually become endparm
FeatureHelp[$i]='func {prm1} prm2 # more info'; # prm1=""; prm2="val1";
FeatureFind[$i]='prm2="val1"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='val1';
FeatureFail[$i]=0;  FeatureOpts[$i]='-ccs'; ((i++)); # -tf11

FeatureDesc[$i]="Check endprm opt & req"; # actually become endparm
FeatureHelp[$i]='func -i {-j} {prm1} prm2 # more info'; # prm1=""; prm2="val1";
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-i val1';
FeatureFail[$i]=0;  FeatureOpts[$i]='-ccs'; ((i++)); # -tf12

# Short Hand Ind Parms (SHIP) ----------------------------------------------
# NB: a few of these use the old-stype ('=') in the command-line, marked with **

FeatureDesc[$i]="ShortHandIndParm: bare";  FeatureHelp[$i]="func -d= "; # no SIPI error
FeatureFind[$i]='_d=""'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d=';     # ** (old-style)
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf13

FeatureDesc[$i]="ShortHandIndParm: plus";  FeatureHelp[$i]="func -d= "; # no SIPI error
FeatureFind[$i]='_d=+'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d+';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf14

FeatureDesc[$i]="ShortHandIndParm: less"; FeatureHelp[$i]="func -d= "; # no SIPI error
FeatureFind[$i]='_d=-'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d-';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf15

FeatureDesc[$i]="ShortHandIndParm: +num";  FeatureHelp[$i]="func -d= "; # no SIPI error
FeatureFind[$i]='_d=+10'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d=+10'; # ** (old-style)
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf16

FeatureDesc[$i]="ShortHandIndParm: -num";  FeatureHelp[$i]="func -d= "; # no SIPI error
FeatureFind[$i]='_d=-2'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d-2';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf17

FeatureDesc[$i]="ShortHandIndParm: ints";  FeatureHelp[$i]="func -d= "; # no SIPI error
FeatureFind[$i]='_d=8,10,12'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d8,10,12';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf18

FeatureDesc[$i]="ShortHandIndParm: nums,"; FeatureHelp[$i]="func -d= "; # no SIPI error
FeatureFind[$i]='_d=8.5,10.1'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d=8.5,10.1'; # ** (old-style)
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf19

FeatureDesc[$i]="ShortHandIndParm: range"; FeatureHelp[$i]="func -d= "; # no SIPI error
FeatureFind[$i]='_d=1-100'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d1-100';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf20

FeatureDesc[$i]="ShortHandIndParm: -rang"; FeatureHelp[$i]="func -d= "; # no SIPI error
FeatureFind[$i]='_d=-10--1'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d=-10--1'; # ** (old-style)
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf21

# SHIP Illegal Values in Error Tests ---------------------------------------
# Datatype Testing in Test Datatypes ---------------------------------------
# SHIP Short|Long Opts Complex Tests ---------------------------------------
# SHIP Options Tests in Test Variety ---------------------------------------

# Normal Indirect Parms ----------------------------------------------------

FeatureDesc[$i]="Ind Parm: single parm.";
FeatureHelp[$i]="func <-f file>"; FeatureFind[$i]='file="val1"';
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f=val1';  FeatureFail[$i]=0;
FeatureOpts[$i]=''; ((i++)); # -tf22

FeatureDesc[$i]="Ind Parm: value spaces";
FeatureHelp[$i]="func <-f|--file file1 file2>"; FeatureFind[$i]='file2="val2"';
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f="val 1" val2'; FeatureFail[$i]=0;
FeatureOpts[$i]=''; ((i++)); # -tf23

FeatureDesc[$i]="Multi-indp vals spaces";       FeatureFind[$i]='';
FeatureHelp[$i]='func <-f parm1 parm2 parm3> # more info';  FeatureIsEg[$i]=1;
FeatureCmdl[$i]='-f "all 1" "all 2" "all 3"';   FeatureFail[$i]=0;
FeatureOpts[$i]='-ccs'; ((i++)); # -tf24

FeatureDesc[$i]="Multi-indp with dtype";
FeatureHelp[$i]='func <-f parm1 parm2 parm3~sw-> # more info'; FeatureFind[$i]='';
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f "All In" "" "all on"'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccs'; ((i++)); # -tf25

FeatureDesc[$i]="Multi-indp & mid-dtype";
FeatureHelp[$i]='func <-f parm1 parm2~sw- parm3> # more info';
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f "" "all in" "All On"';
FeatureFail[$i]=0;  FeatureOpts[$i]='-ccs'; ((i++)); # -tf26

FeatureDesc[$i]="OR'ed indp: 1st option";
FeatureHelp[$i]='func <-f|--files ifile tfile ofile> # more info';
FeatureFind[$i]='ifile="in.txt"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f in.txt tmp.txt out.txt';
FeatureFail[$i]=0;  FeatureOpts[$i]='-ccs'; ((i++)); # -tf27

FeatureDesc[$i]="OR'ed indp: 2nd option";  FeatureFind[$i]='ifile="in.txt"';
FeatureHelp[$i]='func <-f|--files ifile tfile ofile> # more info';
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='--files in.txt tmp.txt out.txt';
FeatureFail[$i]=0;  FeatureOpts[$i]='-ccs'; ((i++)); # -tf28

# Old-Style Ind Parms (OSIP) -----------------------------------------------

FeatureDesc[$i]="OSIP with a parameter"; FeatureHelp[$i]="func -f=file";
FeatureFind[$i]='file="val1"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f=val1';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++));     # -tf29

FeatureDesc[$i]="OSIP spaces in value"; FeatureHelp[$i]="func <-f|--file=file parm>";
FeatureFind[$i]='parm="val2"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f="val 1" val2';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++));     # -tf30

FeatureDesc[$i]="OSIP Spec, Indp Cmdl"; FeatureHelp[$i]="func <-i|n|-f=file>";
FeatureFind[$i]='file="val2"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f val2'; # OSIP disabled
FeatureFail[$i]=0;  FeatureOpts[$i]='-ci'; ((i++));  # -tf31 (-ci required)

FeatureDesc[$i]="Multi-ind parm value"; FeatureHelp[$i]='func -f=file # more info';
FeatureFind[$i]='file="f1=f2"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f f1 -f f2';
FeatureFail[$i]=1;  FeatureOpts[$i]='-ccs'; ((i++)); # -tf32
# above must fail due to multiple parms received

FeatureDesc[$i]="Mulitiple OR'ed OSIP"; FeatureHelp[$i]="func <-f=in1|-g=in2>";
FeatureFind[$i]='in2="val2"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-g=val2';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++));     # -tf33

# Endless (More) Parameters ------------------------------------------------
# Note: SHIP items are not allowed to have More (checked in Errors)

FeatureDesc[$i]="'more' parms spaces"; FeatureHelp[$i]='func parm ... # more info';
FeatureFind[$i]='parm_3="val 3"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='"val 1" "val 2" "val 3"';
FeatureFail[$i]=0;  FeatureOpts[$i]='-ccrs'; ((i++)); # -tf34

FeatureDesc[$i]="'more' parms with 1"; FeatureHelp[$i]='func parm ... # more info';
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='val1'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccs'; ((i++));  # -tf35

FeatureDesc[$i]="'more' parms with 3"; FeatureHelp[$i]='func parm ... # more info';
FeatureFind[$i]='parm_3="val3"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='val1 val2 val3';
FeatureFail[$i]=0;  FeatureOpts[$i]='-ccrs'; ((i++)); # -tf36

FeatureDesc[$i]="'more' ind prm with 1"; FeatureHelp[$i]='func [-f parm ...] # more info';
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f val1'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccs'; ((i++));  # -tf37

FeatureDesc[$i]="'more' ind prm with 3"; FeatureFind[$i]='parm_3="val3"';
FeatureHelp[$i]='func <-f parm ...> # more info'; # ensure we don't skip a position
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f val1 val2 val3'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccrs'; ((i++)); # -tf38

FeatureDesc[$i]="multi-indp with dtype"; FeatureFind[$i]='parm3="c"';
FeatureHelp[$i]='func (-f parm1 parm2 parm3) # more info'; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='-f a b c'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccs'; ((i++));  # -tf39

# Alternate Naming ---------------------------------------------------------
# Following case also catches a special failure case occurring when:
# -cl with alt name with no leading '_', resulted in no output name!
FeatureDesc[$i]="Alt. name Pure Option"; FeatureHelp[$i]="func -a:arg-parse ";
FeatureFind[$i]='arg_parse=1'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-a';
FeatureFail[$i]=0;  FeatureOpts[$i]='-cl'; ((i++)); # -tf40

FeatureDesc[$i]="Alt. name OR Pure Opt"; FeatureHelp[$i]="func {--num=:alt|-n:num=} ";
FeatureFind[$i]='num=3'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-n3';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++));    # -tf41
FeatureDesc[$i]="Alt. name OR Pure Opt"; FeatureHelp[$i]="func {--num=:alt|-n:num=} ";
FeatureFind[$i]='alt=5'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='--num=5';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++));    # -tf42

FeatureDesc[$i]="Alt. name SHIP before"; FeatureHelp[$i]='func -d:name=';
FeatureFind[$i]='name=4-5'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d4-5';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++));    # -tf43
# Note: next test also shows SHIP can be double dash options
FeatureDesc[$i]="Alt. name SHIP after"; FeatureHelp[$i]='func --d=:name';
FeatureFind[$i]='name=6-'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='--d6-';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++));    # -tf44

FeatureDesc[$i]="Alt. name Indp Option"; FeatureHelp[$i]="func {-f:altname miles}";
FeatureFind[$i]='altname=1'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f 5';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++));    # -tf45

FeatureDesc[$i]="Alt. name OSIP Option"; FeatureHelp[$i]="func {-f:altname=miles}";
FeatureFind[$i]='altname=1'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f 5';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++));    # -tf46
# Note: alt name can't be after parm (generates PALT error)

# Future Cases -------------------------------------------------------------
FeatureDesc[$i]=""; FeatureHelp[$i]=""; FeatureFind[$i]=''; FeatureIsEg[$i]=0;  FeatureOpts[$i]='';
FeatureCmdl[$i]=''; FeatureFail[$i]=1;  ((i++));    # -tf47

# Plain OR'ed Groups -------------------------------------------------------

FeatureDesc[$i]="OR'ed group & req parm";        FeatureFind[$i]='';
FeatureHelp[$i]="func m|-i|--input post # more info";   FeatureFail[$i]=0;
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-i val';
FeatureOpts[$i]='-crs'; ((i++)); # -tf48

FeatureDesc[$i]="OR'ed group & opt parm";  FeatureFind[$i]='m="mval"';
FeatureHelp[$i]="func m|-i|--input {post} # more info"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='mval'; FeatureFail[$i]=0;
FeatureOpts[$i]='-crs'; ((i++)); # -tf49

FeatureDesc[$i]="OR'ed group opt & parm";  FeatureFind[$i]='';
FeatureHelp[$i]="func m|-i|--input {post} # more info"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='-i pval'; FeatureFail[$i]=0;
FeatureOpts[$i]='-crs'; ((i++)); # -tf50

FeatureDesc[$i]="OR'ed group parm+parm";  FeatureFind[$i]='';
FeatureHelp[$i]="func m|-i|--input {post} # more info"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='mval pval'; FeatureFail[$i]=0;
FeatureOpts[$i]='-crs'; ((i++)); # -tf51

FeatureDesc[$i]="OR'ed group & another";  FeatureFind[$i]='_j=1';
FeatureHelp[$i]="func m|-i|--input n|-j|--junk post # more info";
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-i -j val'; FeatureFail[$i]=0;
FeatureOpts[$i]='-crs'; ((i++)); # -tf52

FeatureDesc[$i]="OR'ed group with OSIP";   FeatureFind[$i]='';
FeatureHelp[$i]='func -f=parm1|m|-a # more info'; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='-f "val1"'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccs'; ((i++)); # -tf53

# Delimited OR'ed Groups ---------------------------------------------------

FeatureDesc[$i]="Mixed group & pos. parm"; FeatureFind[$i]='';
FeatureHelp[$i]="func {n|-f|--file=prm1}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='nval'; FeatureFail[$i]=0; # pos. parm 1st
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf54

FeatureDesc[$i]="Mixed group & pos. parm"; FeatureFind[$i]='';
FeatureHelp[$i]="func {-f|--file=prm1|n}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='nval'; FeatureFail[$i]=0; # pos. parm last
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf55

FeatureDesc[$i]="Mixed group & long indp"; FeatureFind[$i]='';
FeatureHelp[$i]="func {n|-f|--file=prm1}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='--file=val1'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf56

FeatureDesc[$i]="Mixed group & long OSIP"; FeatureFind[$i]='';
FeatureHelp[$i]="func {n|-f|--file=prm1}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='--file val1'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf57

FeatureDesc[$i]="Mixed group & bad option"; FeatureFind[$i]='';
FeatureHelp[$i]="func {-f|--file=prm1|n}"; FeatureIsEg[$i]=1;  # error
FeatureCmdl[$i]='-f'; FeatureFail[$i]=1;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf58

FeatureDesc[$i]="Mixed group & short indp"; FeatureFind[$i]='';
FeatureHelp[$i]="func {n|-f|--file=prm1}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='-f val1'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf59

FeatureDesc[$i]="Mixed group & short OSIP"; FeatureFind[$i]='';
FeatureHelp[$i]="func {n|-f|--file=prm1}";    FeatureIsEg[$i]=1;
FeatureCmdl[$i]='-f=val1'; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf60

FeatureDesc[$i]="Mixed group & short OSIP end pos prm";
FeatureHelp[$i]="func {-f|--file=prm1|n}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='-f=val1'; FeatureFind[$i]=''; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf61

FeatureDesc[$i]="Mixed group & short indp end pos prm";
FeatureHelp[$i]="func {-f|--file=prm1|n}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='-f val1'; FeatureFind[$i]=''; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf62

FeatureDesc[$i]="Mixed group & long OSIP  end pos prm";
FeatureHelp[$i]="func {-f|--file=prm1|n}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='--file=val1'; FeatureFind[$i]=''; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf63

FeatureDesc[$i]="Mixed group & long indp  end pos prm";
FeatureHelp[$i]="func {-f|--file=prm1|n}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='--file val1'; FeatureFind[$i]=''; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf64

FeatureDesc[$i]="Mixed group & long OSIP  mid pos prm";
FeatureHelp[$i]="func {-f|n|--file=prm1}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='--file=val1'; FeatureFind[$i]=''; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf65

FeatureDesc[$i]="Mixed group & long indp  mid pos prm";
FeatureHelp[$i]="func {-f|n|--file=prm1}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='--file val1'; FeatureFind[$i]=''; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf66

FeatureDesc[$i]="Mixed group & pure opts  mid pos prm";
FeatureHelp[$i]="func {-f|n|--file=prm1}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='-f'; FeatureFind[$i]=''; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf67

FeatureDesc[$i]="Mixed group & pos. parm  mid pos prm";
FeatureHelp[$i]="func {-f|n|--file=prm1}"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='nval'; FeatureFind[$i]=''; FeatureFail[$i]=0;
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf68

# Option Combinations: Single Letter Combos) -------------------------------

FeatureDesc[$i]="Option Combos: ignore single letters"; FeatureFind[$i]='_in=1';
FeatureHelp[$i]="func {-i -n -in} # ignore single letters"; FeatureIsEg[$i]=1;
FeatureCmdl[$i]='-in'; FeatureFail[$i]=0;
FeatureOpts[$i]=''; ((i++)); # -tf69

FeatureDesc[$i]="Option Combos: disable 1 letter combo"; FeatureFind[$i]='';
FeatureHelp[$i]="func {-i -n} # disable 1 letter combo"; FeatureFail[$i]=1;
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-in';
FeatureOpts[$i]='-co'; ((i++)); # -tf70

FeatureDesc[$i]="Option Combos: single letter all opts";
FeatureHelp[$i]="func -i {-j} -k # single letter combos all"; FeatureOpts[$i]='';
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-kij'; # kji|ijk|jki|jik|ikj|kij
FeatureFail[$i]=0;  ((i++)); # -tf71

FeatureDesc[$i]="Option Combos: single letter reqd|opt";
FeatureHelp[$i]="func -i -j {-k} # single letter combos reqd";
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-ji'; FeatureOpts[$i]='';
FeatureFail[$i]=0;  ((i++)); # -tf72

FeatureDesc[$i]="Option Combos: single letter part|all";
FeatureHelp[$i]="func {-i -ij -n} # single letter combos part";
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-in'; FeatureOpts[$i]='';
FeatureFail[$i]=0;  ((i++)); # -tf73

# NB: previously this gave ="" for a third specified item
FeatureDesc[$i]="Option Combos: single letter end space";
FeatureHelp[$i]="func <-i -n > # trailing space"; FeatureFind[$i]='_n=1';
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-in'; FeatureFail[$i]=0;
FeatureOpts[$i]=''; ((i++)); # -tf74

# check error with 2 extra unknown options: single & double letter combos
FeatureDesc[$i]="Option Combos: extra single unknown opts";
FeatureHelp[$i]="func {-i -j} # unknown single opts"; FeatureFind[$i]='unfound: nk';
FeatureCmdl[$i]='-jink';  FeatureFail[$i]=2;     # find in error file if 2
FeatureIsEg[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf75 [not an e.g.]
FeatureDesc[$i]="Option Combos: extra double unknown opts";
FeatureHelp[$i]="func {-io -in} # unknown double opts"; FeatureFind[$i]='unfound: st';
FeatureCmdl[$i]='-ionst'; FeatureFail[$i]=2;     # find in error file if 2
FeatureIsEg[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf76 [not an e.g.]

# Option Combinations: Double Letter Combos) -------------------------------

FeatureDesc[$i]="Option Combos: double letter combo"; FeatureHelp[$i]="func -oa {-ob}";
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-oba';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf77

FeatureDesc[$i]="Option Combos: double letter both"; FeatureHelp[$i]="func -oa {-ob}";
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-ob -oa';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf78

FeatureDesc[$i]="Option Combos: double letter one"; FeatureHelp[$i]="func -oa {-ob}";
FeatureFind[$i]='_oa=1'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-oa';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf79

FeatureDesc[$i]="Option Combos: ignores 2 letters"; FeatureFind[$i]='_int=1';
FeatureHelp[$i]="func {-in -it -int} # ignore double letters";
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-int'; FeatureFail[$i]=0;
FeatureOpts[$i]=''; ((i++)); # -tf80

FeatureDesc[$i]="Option Combos: disable 2 letters"; FeatureFail[$i]=1;
FeatureHelp[$i]="func {-in -it} # disable 2 letter combos";
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-int';
FeatureOpts[$i]='-cm'; ((i++)); # -tf81

# Spacing Tests ------------------------------------------------------------

# previously this test produced a 3rd unnamed item: =""
FeatureDesc[$i]="Check Spaces:  normal indp";
FeatureHelp[$i]="func <  -i -n  > # check end spaces"; FeatureFail[$i]=0;
FeatureFind[$i]='_n=1'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-in';
FeatureOpts[$i]='-ccbhrs'; ((i++)); # -tf82

# Dequoting Test -----------------------------------------------------------
# NB: the resultant SHIP values & pure option values are not quoted

FeatureDesc[$i]="Dequote input: pos. parm"; FeatureFail[$i]=0;
FeatureHelp[$i]='func parm # more info'; FeatureFind[$i]='parm="val1"';
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='"val1"';
FeatureOpts[$i]='-ccs -on'; ((i++)); # -tf83

FeatureDesc[$i]="Dequote input: ind. parm"; FeatureFail[$i]=0;
FeatureHelp[$i]='func {-f indp} # more info'; FeatureFind[$i]='indp="val1"';
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f "val1"';
FeatureOpts[$i]='-ccs -on'; ((i++)); # -tf84

FeatureDesc[$i]="Dequote input: OSIP type"; FeatureFail[$i]=0;
FeatureHelp[$i]='func -f=indp # more info'; FeatureFind[$i]='indp="val1"';
FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-f="val1"';
FeatureOpts[$i]='-ccs -on'; ((i++)); # -tf85

# End of Options -----------------------------------------------------------
FeatureDesc[$i]="End Options ends options";
FeatureHelp[$i]='func -a -- parm # more info';   FeatureFail[$i]=0;
FeatureFind[$i]='parm="-a"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-- -a';
FeatureOpts[$i]='-ccs -on'; ((i++)); # -tf86

FeatureDesc[$i]="End Options ends options";
FeatureHelp[$i]='func {-f indp} -- prm1 prm2 # more'; FeatureFail[$i]=0;
FeatureFind[$i]='prm2="val1"'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-- -f val1';
FeatureOpts[$i]='-ccs -on'; ((i++)); # -tf87

# Note: EQAL|RANG|SRND Exact & Partial Matching tests are in MatchDesc

# Complex Cases ------------------------------------------------------------

FeatureDesc[$i]="Option & SHIP: get optn"; FeatureHelp[$i]="func --m-p-h=|-d ";
FeatureFind[$i]='_d=1'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='-d'; FeatureFail[$i]=0;
FeatureOpts[$i]=''; ((i++)); # -tf88

FeatureDesc[$i]="Option & SHIP: get SHIP"; FeatureHelp[$i]="func -d=|--m-p-h= ";
FeatureFind[$i]='__m_p_h=0-100'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='--m-p-h0-100';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf89

FeatureDesc[$i]="Short+Long SHIP: get long"; FeatureHelp[$i]="func -d=|--m-p-h= ";
FeatureFind[$i]='__m_p_h=-10.5--1.8'; FeatureIsEg[$i]=1;  FeatureCmdl[$i]='--m-p-h-10.5--1.8';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf90

FeatureDesc[$i]="Short+Long SHIP: get short"; FeatureHelp[$i]="func -d=|--m-p-h= ";
FeatureFind[$i]='_d=0-100'; FeatureIsEg[$i]=1; FeatureCmdl[$i]='-d0-100';
FeatureFail[$i]=0;  FeatureOpts[$i]=''; ((i++)); # -tf91

FeatureDesc[$i]="Combined case: singlecombo";
FeatureHelp[$i]='func <file_txt~sj-@~".txt"> -v:vrb|m~s-|--verb -i {-j} (-m ind_parm) -e <-f|--files ifile tfile ofile> {--} <param1~i+> [param2~sw- param3] # more info';
FeatureCmdl[$i]='file.txt happy -ji --files in.txt tmp.txt out.txt 12 "lower" "miXed"';
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureFail[$i]=0;
FeatureOpts[$i]='-on -ccs'; ((i++));  # -tf92

FeatureDesc[$i]="Combined case: multi-combo"; # with parms with spaces
FeatureHelp[$i]='func <file_txt~sj+-%~".Txt"> -v:verb|m~h|--verb {-in} {-io} -i {-j} [-m=ind_parm] -e <-f|--files ifile tfile ofile> {--} <param1~ip> [param2 param3~sw-] # info';
FeatureCmdl[$i]='file.txt 0x3A  -ji -ion -e --files in.txt tmp.txt out.txt 12 "all In" "all on"';
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureFail[$i]=0;
FeatureOpts[$i]='-crs -on'; ((i++));  # -tf93

FeatureDesc[$i]="Combined case: hex OR parm";
FeatureHelp[$i]='func <file_txt~s%~\.txt> -v:verb|m~h|--verb {-in} {-io} -i {-j} [-m ind_parm] -e <-f|--files ifile tfile ofile> {--} <param1~ip> [param2 param3~sw-] '; # HLPD
FeatureCmdl[$i]='file.txt 0x48 -ion -j -e --files in.txt tmp.txt out.txt -i 12 "all in"';
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureFail[$i]=0;
FeatureOpts[$i]='-chrsw'; ((i++));    # -tf94

# line continuation support
HLPGS='func <file_txt~s@~.txt> -v:verb|m~v-|--verb -i {-j} [-m=ind_parm] \
-e <-f|--files ifile tfile ofile> {--} <param1~ip> [param2~sw~ param3] # more info'
FeatureDesc[$i]="Long Help & line continued"; FeatureHelp[$i]="$HLPGS"; # HLPGS
FeatureCmdl[$i]='file.txt --verb -ij -e --files in.txt tmp.txt out.txt 12 "all In" "all on"';
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureFail[$i]=0;
FeatureOpts[$i]='-crs -on'; ((i++));  # -tf95

# an example of printing multi-line help with returns
HLPL='func <file_txt~s@~.txt> -v:verb|m~h|--verb {-in} {-io} -i {-j} [-m=ind_parm] -e <-f|--files ifile tfile ofile> <param1~ip> [param2 param3~vu-] #\ninfo line1\ninfo line2\ninfo line3'
FeatureDesc[$i]="Long Help carriage returns"; FeatureHelp[$i]="$HLPL"; # HLPL
FeatureCmdl[$i]='file.txt 0x48 -ji -e --files in.txt tmp.txt out.txt 12 "all In" "all_on"'; # ILLSPEC
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureFail[$i]=0;
FeatureOpts[$i]='-crs -on'; ((i++));  # -tf96

# ensure defined option ending in + is accepted but named with _plus
FeatureDesc[$i]="Support for option ending +";
FeatureHelp[$i]='func {-o+} # option ending in +'; FeatureFail[$i]=0;
FeatureFind[$i]='_o_plus=1';  FeatureIsEg[$i]=1;   FeatureCmdl[$i]='-o+';
FeatureOpts[$i]='-ccs -on'; ((i++));  # -tf97

# ensure defined option ending in + is accepted but named with _plus
FeatureDesc[$i]="Support for option ending +";
FeatureHelp[$i]='func {-o+} # option ending in +'; FeatureFail[$i]=0;
FeatureFind[$i]=' o_plus=1';  FeatureIsEg[$i]=1;   FeatureCmdl[$i]='-o+';
FeatureOpts[$i]='-ccsl -on'; ((i++)); # -tf98

# Following causes an error & a warning:
# 17 [BNAM]: Item's name contains bad chars: 'param3~sw-' - s/b: [_a-zA-Z][_a-zA-Z0-9]*
FeatureDesc[$i]="Negative specification test"; # MISORDR : wrong ordering cmd-line item [ 8]
FeatureHelp[$i]='func filein {-v|m|--verb|n}{-i:input~i} {-m=ind_parm~s-} {--} {--} <-o outfile> param1 [param2]'; # ILLSRUN
FeatureCmdl[$i]='file.txt happy -ji -e --files in.txt tmp.txt out.txt 12 "all In" "all on"';   # ILLSPEC
FeatureFind[$i]=''; FeatureIsEg[$i]=1;  FeatureFail[$i]=1;
FeatureOpts[$i]='-crs -on'; ((i++));  # -tf99

SizeFeature=$((i-1)); # End of All the Tests : keep as the last line

#############################################################################
# TestVariety : -tv# (0 is all, "" is show descriptions)
# checks that variety & order of required & optional parms+opts
#############################################################################
declare -a VarietyDesc; declare -a VarietyHelp; declare -a VarietyCmdl;
declare -a VarietyFail; declare -a VarietyOpts; declare -a VarietyIsEg;
declare -a VarietySrc1; declare -a VarietySrc2; i=1; # 1-based tests

# begin tests : Variations in ordering of items -----------------------------
VarietyDesc[$i]="OptParm-ReqOptn-OptParm and no EOBPM no EOOM";
VarietyHelp[$i]="func {prm1}      -i      {prm2}"; VarietyCmdl[$i]='val1 -i';
VarietySrc1[$i]='prm1="val1"'; VarietySrc2[$i]='_i=1'; # prm2="";
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv1|-tv01

VarietyDesc[$i]="OptParm-ReqOptn-OptParm and no EOBPM w/ EOOM";
VarietyHelp[$i]="func {prm1}      -i {--} {prm2}"; VarietyCmdl[$i]='val1 -i';
VarietySrc1[$i]='prm1="val1"'; VarietySrc2[$i]='_i=1'; # prm2="";
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv2|-tv02

VarietyDesc[$i]="OptParm-ReqOptn-OptParm and w/ EOBPM w/ EOOM";
VarietyHelp[$i]="func {prm1} {-+} -i {--} {prm2}"; VarietyCmdl[$i]='val1 -i';
VarietySrc1[$i]='prm1="val1"'; VarietySrc2[$i]='_i=1'; # prm2="";
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv3|-tv03

VarietyDesc[$i]="OptParm-ReqOptn-OptParm and rx EOBPM no EOOM";
VarietyHelp[$i]="func {prm1}      -i      {prm2}"; VarietyCmdl[$i]='val1 -+ -i';
VarietySrc1[$i]='prm1="val1"'; VarietySrc2[$i]='_i=1'; # prm2="";
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv4|-tv04

VarietyDesc[$i]="OptParm-ReqOptn-OptParm and w/ EOBPM rx EBPM";
VarietyHelp[$i]="func {prm1} {-+} -i {--} {prm2}"; VarietyCmdl[$i]='-+ val1 -i --';
VarietySrc1[$i]='prm2="val1"'; VarietySrc2[$i]='_i=1'; # prm1="";
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv5|-tv05

VarietyDesc[$i]="When all items after bgn parm required pt. a";
VarietyHelp[$i]="func {prm1} prm2 -i prm3"; VarietyCmdl[$i]='val1 -i val2';
VarietySrc1[$i]='prm2="val1"'; VarietySrc2[$i]='_i=1'; # prm1="";
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv6|-tv06
# Note: same as previous test, but checking for other item values
VarietyDesc[$i]="When all items after bgn parm required pt. b";
VarietyHelp[$i]="func {prm1} prm2 -i prm3"; VarietyCmdl[$i]='val1 -i val2';
VarietySrc1[$i]='prm1=""'; VarietySrc2[$i]='prm3="val2"';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv7|-tv07

# in this case prm2 should pickup -i as a parm value
VarietyDesc[$i]="When any optional items after bgn parm pt. a";
VarietyHelp[$i]="func {prm1} prm2 {-i} {prm3}"; VarietyCmdl[$i]='val1 -i val2';
VarietySrc1[$i]='prm1="val1"'; VarietySrc2[$i]='prm2="-i"';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv8|-tv08
# Note: same as previous test, but checking for other item values
VarietyDesc[$i]="When any optional items after bgn parm pt. b";
VarietyHelp[$i]="func {prm1} prm2 {-i} {prm3}"; VarietyCmdl[$i]='val1 -i val2';
VarietySrc1[$i]='prm3="val2"'; VarietySrc2[$i]='_i=0';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv9|-tv09

VarietyDesc[$i]="Solved with an end of bgn parms marker pt. a";  # optional -i
VarietyHelp[$i]="func {prm1} prm2 {-i} {prm3}"; VarietyCmdl[$i]='val1 -+ -i val2';
VarietySrc1[$i]='prm1=""'; VarietySrc2[$i]='prm2="val1"';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv10
# Note: same as previous test, but checking for other item values
VarietyDesc[$i]="Solved with an end of bgn parms marker pt. b";  # optional -i
VarietyHelp[$i]="func {prm1} prm2 {-i} {prm3}"; VarietyCmdl[$i]='val1 -+ -i val2';
VarietySrc1[$i]='prm3="val2"'; VarietySrc2[$i]='_i=1';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv11

VarietyDesc[$i]="Solved with an end of bgn parms marker pt. a";  # required -i
VarietyHelp[$i]="func {prm1} prm2  -i  {prm3}"; VarietyCmdl[$i]='val1 -+ -i val2';
VarietySrc1[$i]='prm1=""'; VarietySrc2[$i]='prm2="val1"';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv12
# Note: same as previous test, but checking for other item values
VarietyDesc[$i]="Solved with an end of bgn parms marker pt. b";  # required -i
VarietyHelp[$i]="func {prm1} prm2  -i  {prm3}"; VarietyCmdl[$i]='val1 -+ -i val2';
VarietySrc1[$i]='prm3="val2"'; VarietySrc2[$i]='_i=1';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv13

VarietyDesc[$i]="Spec'ed & rcvd end of bgn parms marker pt. a";  # required -i
VarietyHelp[$i]="func {prm1} -+ prm2  -i  {prm3}"; VarietyCmdl[$i]='val1 -+ -i val2';
VarietySrc1[$i]='prm1="val1"'; VarietySrc2[$i]='prm2="val2"';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv14
# Note: same as previous test, but checking for other item values
VarietyDesc[$i]="Spec'ed & rcvd end of bgn parms marker pt. b";  # required -i
VarietyHelp[$i]="func {prm1} -+ prm2  -i  {prm3}"; VarietyCmdl[$i]='val1 -+ -i val2';
VarietySrc1[$i]='prm3=""'; VarietySrc2[$i]='_i=1';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv15

# same results even if final parm required
VarietyDesc[$i]="Spec'ed & rcvd end of bgn w/ reqd prm3 pt. a";  # required -i
VarietyHelp[$i]="func {prm1} -+ prm2  -i  {prm3}"; VarietyCmdl[$i]='val1 -+ -i val2';
VarietySrc1[$i]='prm1="val1"'; VarietySrc2[$i]='prm2="val2"';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv16
# Note: same as previous test, but checking for other item values
VarietyDesc[$i]="Spec'ed & rcvd end of bgn w/ reqd prm3 pt. b";  # required -i
VarietyHelp[$i]="func {prm1} -+ prm2  -i  {prm3}"; VarietyCmdl[$i]='val1 -+ -i val2';
VarietySrc1[$i]='prm3=""'; VarietySrc2[$i]='_i=1';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv17

VarietyDesc[$i]="Only rcvd end of bgn parms & reqd prm3 pt. a";  # required -i
VarietyHelp[$i]="func {prm1}    prm2  -i  {prm3}"; VarietyCmdl[$i]='val0 val1 -+ -i val2';
VarietySrc1[$i]='prm1="val0"'; VarietySrc2[$i]='prm2="val1"';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv18
# Note: same as previous test, but checking for other item values
VarietyDesc[$i]="Only rcvd end of bgn parms & reqd prm3 pt. b";  # required -i
VarietyHelp[$i]="func {prm1}    prm2  -i  {prm3}"; VarietyCmdl[$i]='val0 val1 -+ -i val2';
VarietySrc1[$i]='prm3="val2"'; VarietySrc2[$i]='_i=1';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv19

VarietyDesc[$i]="OR'ed mixed parm unfilled w/ option received";
VarietyHelp[$i]="func -j m|-i|--input {post}"; VarietyCmdl[$i]='-j val -i';
VarietySrc1[$i]='m=""'; VarietySrc2[$i]='post="val"'; # _i=1; _j=1;
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-ccs'; ((i++)); # -tv20

# --------------------------------------------------------------------------
# Following tests are to test SHIP optional flags
# Note main tests for SHIPs are in Test Feature: Short Hand Ind Parms (SHIP)
# First the setting of the individual option flag
# --------------------------------------------------------------------------
#           end_plus: -d=+     =>     -d+
VarietyDesc[$i]="SHIP item with only plus-sign option allowed";
VarietyHelp[$i]="func {-d=+}"; VarietyCmdl[$i]='-d+';
VarietySrc1[$i]='d=+'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv21

#           endminus: -d=-     =>          -d-
VarietyDesc[$i]="SHIP item with only minussign option allowed";
VarietyHelp[$i]="func {-d=-}"; VarietyCmdl[$i]='-d-';
VarietySrc1[$i]='d=-'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv22

#           endplmin: -d=+-    =>     -d+  -d-
VarietyDesc[$i]="SHIP item with only plusminus option allowed";
VarietyHelp[$i]="func {-d=+-}"; VarietyCmdl[$i]='-d+';
VarietySrc1[$i]='d=+'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv23
VarietyDesc[$i]="SHIP item with only minussign option allowed";
VarietyHelp[$i]="func {-d=+-}"; VarietyCmdl[$i]='-d-';
VarietySrc1[$i]='d=-'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv24

#           enumer8d: -d=,     =>                                -d#,#
VarietyDesc[$i]="SHIP item with the enumerated option allowed";
VarietyHelp[$i]="func {-d=,}"; VarietyCmdl[$i]='-d5,7';
VarietySrc1[$i]='d=5,7'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv25

#           havempty: -d=0     => -d
VarietyDesc[$i]="SHIP item with only the empty option allowed";
VarietyHelp[$i]="func {-d=0}"; VarietyCmdl[$i]='-d';
VarietySrc1[$i]='d=""'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv26

#           auto-num: -d=.     =>               -d#
# Note: '1' is implied when '.' is without any digits (,12)
VarietyDesc[$i]="SHIP item with only fractions option allowed";
VarietyHelp[$i]="func {-d=.}"; VarietyCmdl[$i]='-d5.5';
VarietySrc1[$i]='d=5.5'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv27

#           numbered: -d=1     =>               -d#
VarietyDesc[$i]="SHIP item with only integers options allowed";
VarietyHelp[$i]="func {-d=1}"; VarietyCmdl[$i]='-d5';
VarietySrc1[$i]='d=5'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv28

#           isranged: -d=2     =>                                       -d#-#
VarietyDesc[$i]="SHIP item with the num ranges option allowed";
VarietyHelp[$i]="func {-d=2}"; VarietyCmdl[$i]='-d5-7';
VarietySrc1[$i]='d=5-7'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv29

# --------------------------------------------------------------------------
# Then setting of +- signs before following digits
# --------------------------------------------------------------------------
#           auto-num: -d=1.    =>               -d#
VarietyDesc[$i]="SHIP item with 1 num fraction option allowed";
VarietyHelp[$i]="func {-d=1.}"; VarietyCmdl[$i]='-d2.5';
VarietySrc1[$i]='d=2.5'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv30

#                     -d=+-0   => -d  -d+  -d- # since no digits, acts same as -d+- w/ -d0
VarietyDesc[$i]="SHIP item with the empty & +- option = empty";
VarietyHelp[$i]="func {-d=+-0}"; VarietyCmdl[$i]='-d';
VarietySrc1[$i]='d=""'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv31
VarietyDesc[$i]="SHIP item with the empty & +- option = minus";
VarietyHelp[$i]="func {-d=+-0}"; VarietyCmdl[$i]='-d-';
VarietySrc1[$i]='d=-'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv32
VarietyDesc[$i]="SHIP item with the empty & +- option = a plus";
VarietyHelp[$i]="func {-d=+-0}"; VarietyCmdl[$i]='-d+';
VarietySrc1[$i]='d=+'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv33

#                     -d=+-1   =>               -d#
VarietyDesc[$i]="SHIP item with a single & +- options = single";
VarietyHelp[$i]="func {-d=+-1}"; VarietyCmdl[$i]='-d4';
VarietySrc1[$i]='d=4';  VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv34
VarietyDesc[$i]="SHIP item with a single & +- options = a plus";
VarietyHelp[$i]="func {-d=+-1}"; VarietyCmdl[$i]='-d+4';
VarietySrc1[$i]='d=+4'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv35
VarietyDesc[$i]="SHIP item with a single & +- options = minus";
VarietyHelp[$i]="func {-d=+-1}"; VarietyCmdl[$i]='-d-4';
VarietySrc1[$i]='d=-4'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv36

#                     -d=+-2   =>                                       -d#-#
VarietyDesc[$i]="SHIP item with a range & a +- option = single";
VarietyHelp[$i]="func {-d=+-2}"; VarietyCmdl[$i]='-d-5-6';
VarietySrc1[$i]='d=-5-6';  VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv37
VarietyDesc[$i]="SHIP item with a range & a +- option = a plus";
VarietyHelp[$i]="func {-d=+-2}"; VarietyCmdl[$i]='-d-5-+6';
VarietySrc1[$i]='d=-5-+6'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv38
VarietyDesc[$i]="SHIP item with a range & a +- options = minus";
VarietyHelp[$i]="func {-d=+-2}"; VarietyCmdl[$i]='-d-5--2';
VarietySrc1[$i]='d=-5--2'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv39

# --------------------------------------------------------------------------
# Then setting of 2 of the option flags at a time
# --------------------------------------------------------------------------
#                     -d=,1    =>               -d#              -d#,#
VarietyDesc[$i]="SHIP item with single & enumerated opt = bare";
VarietyHelp[$i]="func {-d=,1}"; VarietyCmdl[$i]='-d6';
VarietySrc1[$i]='d=6'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv40
VarietyDesc[$i]="SHIP item with single & enumerated opt = rang";
VarietyHelp[$i]="func {-d=,1}"; VarietyCmdl[$i]='-d6,8';
VarietySrc1[$i]='d=6,8'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]='-cl'; ((i++));  # -tv41

# --------------------------------------------------------------------------
# Test cases skipped:
#                     -d=,+-   =>     -d+  -d-                   -d#,#
#                     -d=2+-   =>     -d+  -d-                          -d#-#
#                     -d=,2    =>                                -d#,#  -d#-#
#                     -d=12    =>               -d#                     -d#-#
#                     -d=12,   =>               -d#              -d#,#  -d#-#
# --------------------------------------------------------------------------

# --------------------------------------------------------------------------
# Verify pure option w/ num grabbed before SHIP w/ same letters for name
# --------------------------------------------------------------------------
VarietyDesc[$i]="Pure opt w/ num w/ same letters as SHIP name 1";
VarietyHelp[$i]="func {-d5} {-d=}"; VarietyCmdl[$i]='-d5';
VarietySrc1[$i]='_d5=1'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]=''; ((i++));  # -tv42
VarietyDesc[$i]="Pure opt w/ num w/ same letters as SHIP name 2";
VarietyHelp[$i]="func {-d=} {-d5}"; VarietyCmdl[$i]='-d5';
VarietySrc1[$i]='_d5=1'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]=''; ((i++));  # -tv43

# --------------------------------------------------------------------------
# Verify SHIP w/ same letters as pure option grabbed when old style used
# --------------------------------------------------------------------------
VarietyDesc[$i]="Pure opt w/ num w/ same letters as SHIP use = 1";
VarietyHelp[$i]="func {-d5} {-d=}"; VarietyCmdl[$i]='-d=5';
VarietySrc1[$i]='_d=5'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]=''; ((i++));  # -tv44
VarietyDesc[$i]="Pure opt w/ num w/ same letters as SHIP use = 2";
VarietyHelp[$i]="func {-d=} {-d5}"; VarietyCmdl[$i]='-d=5';
VarietySrc1[$i]='_d=5'; VarietySrc2[$i]='';
VarietyIsEg[$i]=1; VarietyFail[$i]=0; VarietyOpts[$i]=''; ((i++));  # -tv45

SizeVariety=$((i-1)); # End of All the Tests : keep as the last line

#############################################################################
# TestDataTyp : -td# (0 is all, "" is show descriptions) - Test Datatypes
# NB: in this section we have several repeated tests with varying formats
#############################################################################
declare -a DTData; declare -a DTHelp; declare -a DTDesc;
declare -a DTQuot; declare -a DTIsEg; dtndx=1; # 1-based tests

# begin tests : Special Datatypes Checking ----------------------------------

# following are IP addresses: ip4d, ip4h, ip6d, ip6h, ip4, ip6, ipd, iph, ipg
DTDesc[$dtndx]="Test IP4 decimal";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="190.170.150.1";
DTHelp[$dtndx]="func <item~ip4d>";  ((dtndx++)); # -td01: DATA_IP4_DEC IP4 decimal value

DTDesc[$dtndx]="Test IP4 hexadec";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="BE.AA.96.1";                     # NB: leading 0's not allowed
DTHelp[$dtndx]="func <item~ip4h>";  ((dtndx++)); # -td02: DATA_IP4_HEX IP4 hexadec value

DTDesc[$dtndx]="Test IP6 decimal";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="32.1.219.8.10.11.18.240.0.0.0.0.0.0.0.1"; # = "2001:0db8:0a0b:12f0:0000:0000:0000:0001"
DTHelp[$dtndx]="func <item~ip6d>";  ((dtndx++)); # -td03: DATA_IP6_DEC IP6 decimal value

DTDesc[$dtndx]="Test IP6 hexadec";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;  # NB: only lower case hex addresses allowed
DTData[$dtndx]="2001:0db8:85a3:0000:0000:8a2e:0370:7334";
DTHelp[$dtndx]="func <item~ip6h>";  ((dtndx++)); # -td04: DATA_IP6_HEX IP6 hexadec value

DTDesc[$dtndx]="Test IP4 numeral";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="190.170.150.1";
DTHelp[$dtndx]="func <item~ip4>";   ((dtndx++)); # -td05: DATA_IP4_NUM IP4 numeral value

DTDesc[$dtndx]="Test IP6 numeral";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="32.1.219.8.10.11.18.240.0.0.0.0.0.0.0.1"; # = "2001:0db8:0a0b:12f0:0000:0000:0000:0001"
DTHelp[$dtndx]="func <item~ip6>";   ((dtndx++)); # -td06: DATA_IP6_NUM IP6 numeral value

DTDesc[$dtndx]="Test IPn decimal";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="32.1.219.8.10.11.18.240.0.0.0.0.0.0.0.1";
DTHelp[$dtndx]="func <item~ipd>";   ((dtndx++)); # -td07: DATA_IPN_DEC IPn decimal value

DTDesc[$dtndx]="Test IPn hexadec";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="2001:0db8:85a3:0000:0000:8a2e:0370:7334";
DTHelp[$dtndx]="func <item~iph>";   ((dtndx++)); # -td08: DATA_IPN_HEX IPn hexadec value

DTDesc[$dtndx]="Test IPn generic";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="32.1.219.8.10.11.18.240.0.0.0.0.0.0.0.1";
DTHelp[$dtndx]="func <item~ipg>";   ((dtndx++)); # -td09: DATA_IPN_NUM IPn generic value

DTDesc[$dtndx]="Test Mac hexadec";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="70:07:81:18:92:29";
DTHelp[$dtndx]="func <item~mac>";   ((dtndx++)); # -td10: DATA_MAC_HEX a Mac hex address

DTDesc[$dtndx]="Test Email address"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="My.Name@google.com";
DTHelp[$dtndx]="func <item~e>";     ((dtndx++)); # -td11: DATA_E_MAILS an E-mail address

DTDesc[$dtndx]="Test url or website"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="www.url-with-querystring.com/?url=has-querystring";
DTHelp[$dtndx]="func <item~u>";     ((dtndx++)); # -td12: DATA_ANY_URL an URL or website

# Numeric Datatypes Checking -----------------------------------------------

# following are numbers|integers for parms
DTDesc[$dtndx]="Test Parm pos number";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="+5901.36";  DTHelp[$dtndx]="func <item~np>";    ((dtndx++)); # -td13: DATA_NUM_POS positive number
DTDesc[$dtndx]="Test Parm neg number";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-278.0";    DTHelp[$dtndx]="func <item~nn>";    ((dtndx++)); # -td14: DATA_NUM_NEG neg num (no ldg 0)
DTDesc[$dtndx]="Test Parm any number";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="+5901.36";  DTHelp[$dtndx]="func <item~n>";     ((dtndx++)); # -td15: DATA_ANUMBER pos/neg. number
DTDesc[$dtndx]="Test Parm pos integer";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="+35";       DTHelp[$dtndx]="func <item~ip>";    ((dtndx++)); # -td16: DATA_INT_POS positive integer
DTDesc[$dtndx]="Test Parm neg integer";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-27";       DTHelp[$dtndx]="func <item~in>";    ((dtndx++)); # -td17: DATA_INT_NEG negative integer
DTDesc[$dtndx]="Test Parm any integer";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="+35";       DTHelp[$dtndx]="func <item~i>";     ((dtndx++)); # -td18: DATA_INTEGER pos/neg. integer
DTDesc[$dtndx]="Test Parm unsignedint";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="160";       DTHelp[$dtndx]="func <item~#>";     ((dtndx++)); # -td19: DATA_UNS_INT unsigned integer
DTDesc[$dtndx]="Test Parm zero in 0|1";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="0";         DTHelp[$dtndx]="func <item~B>";     ((dtndx++)); # -td20: DATA_ZEROONE zero or one (0|1)
DTDesc[$dtndx]="Test Parm ones in 0|1";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="1";         DTHelp[$dtndx]="func <item~B>";     ((dtndx++)); # -td21: DATA_ZEROONE zero or one (0|1)
DTDesc[$dtndx]="Test Parm boolean int";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="01101";     DTHelp[$dtndx]="func <item~b>";     ((dtndx++)); # -td22: DATA_BOOLNUM boolean int (0110)
DTDesc[$dtndx]="Test Parm percentage";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="50.5";      DTHelp[$dtndx]="func <item~%>";     ((dtndx++)); # -td23: DATA_PERCENT num percent (0-100)
DTDesc[$dtndx]="Test Parm 0xHex integer"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="0xFE";      DTHelp[$dtndx]="func <item~h>";     ((dtndx++)); # -td24: DATA_HEX_NUM hexadecimal num(s)
DTDesc[$dtndx]="Test Parm  xHex integer"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="xDC";       DTHelp[$dtndx]="func <item~h>";     ((dtndx++)); # -td25: DATA_HEX_NUM hexadecimal num(s)
DTDesc[$dtndx]="Test Parm a hex integer"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="ab";        DTHelp[$dtndx]="func <item~h>";     ((dtndx++)); # -td26: DATA_HEX_NUM hexadecimal num(s)

# following are numbers|integers for normal indp
DTDesc[$dtndx]="Test Indp pos number";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f +5901.36";  DTHelp[$dtndx]="func <-f item~np>"; ((dtndx++)); # -td27: DATA_NUM_POS positive number
DTDesc[$dtndx]="Test Indp neg number";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f -278.0";    DTHelp[$dtndx]="func <-f item~nn>"; ((dtndx++)); # -td28: DATA_NUM_NEG neg num (no ldg 0)
DTDesc[$dtndx]="Test Indp any number";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f +5901.36";  DTHelp[$dtndx]="func <-f item~n>";  ((dtndx++)); # -td29: DATA_ANUMBER pos/neg. number
DTDesc[$dtndx]="Test Indp pos integer";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f +35";       DTHelp[$dtndx]="func <-f item~ip>"; ((dtndx++)); # -td30: DATA_INT_POS positive integer
DTDesc[$dtndx]="Test Indp neg integer";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f -27";       DTHelp[$dtndx]="func <-f item~in>"; ((dtndx++)); # -td31: DATA_INT_NEG negative integer
DTDesc[$dtndx]="Test Indp any integer";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f +35";       DTHelp[$dtndx]="func <-f item~i>";  ((dtndx++)); # -td32: DATA_INTEGER pos/neg. integer
DTDesc[$dtndx]="Test Indp unsignedint";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f 160";       DTHelp[$dtndx]="func <-f item~#>";  ((dtndx++)); # -td33: DATA_UNS_INT unsigned integer
DTDesc[$dtndx]="Test Indp zero in 0|1";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f 0";         DTHelp[$dtndx]="func <-f item~B>";  ((dtndx++)); # -td34: DATA_ZEROONE zero or one (0|1)
DTDesc[$dtndx]="Test Indp ones in 0|1";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f 1";         DTHelp[$dtndx]="func <-f item~B>";  ((dtndx++)); # -td35: DATA_ZEROONE zero or one (0|1)
DTDesc[$dtndx]="Test Indp boolean int";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f 01101";     DTHelp[$dtndx]="func <-f item~b>";  ((dtndx++)); # -td36: DATA_BOOLNUM boolean int (0110)
DTDesc[$dtndx]="Test Indp percentage";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f 50.5";      DTHelp[$dtndx]="func <-f item~%>";  ((dtndx++)); # -td37: DATA_PERCENT num percent
DTDesc[$dtndx]="Test Indp 0xHex integer"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f 0xFE";      DTHelp[$dtndx]="func <-f item~h>";  ((dtndx++)); # -td38: DATA_HEX_NUM hexadecimal num(s)
DTDesc[$dtndx]="Test Indp  xHex integer"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f xDC";       DTHelp[$dtndx]="func <-f item~h>";  ((dtndx++)); # -td39: DATA_HEX_NUM hexadecimal num(s)
DTDesc[$dtndx]="Test Indp a hex integer"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f ab";        DTHelp[$dtndx]="func <-f item~h>";  ((dtndx++)); # -td40: DATA_HEX_NUM hexadecimal num(s)

# following are numbers|integers for OSIP
DTDesc[$dtndx]="Test OSIP pos number";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=+5901.36";  DTHelp[$dtndx]="func <-f=item~np>";   ((dtndx++)); # -td41: DATA_NUM_POS positive number
DTDesc[$dtndx]="Test OSIP neg number";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=-278.0";    DTHelp[$dtndx]="func <-f=item~nn>";   ((dtndx++)); # -td42: DATA_NUM_NEG neg num no ldg 0
DTDesc[$dtndx]="Test OSIP any number";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=+5901.36";  DTHelp[$dtndx]="func <-f=item~n>";    ((dtndx++)); # -td43: DATA_ANUMBER pos/neg. number
DTDesc[$dtndx]="Test OSIP pos integer";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=+35";       DTHelp[$dtndx]="func <-f=item~ip>";   ((dtndx++)); # -td44: DATA_INT_POS positive integer
DTDesc[$dtndx]="Test OSIP neg integer";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=-27";       DTHelp[$dtndx]="func <-f=item~in>";   ((dtndx++)); # -td45: DATA_INT_NEG negative integer
DTDesc[$dtndx]="Test OSIP any integer";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=+35";       DTHelp[$dtndx]="func <-f=item~i>";    ((dtndx++)); # -td46: DATA_INTEGER pos/neg. integer
DTDesc[$dtndx]="Test OSIP unsignedint";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=160";       DTHelp[$dtndx]="func <-f=item~#>";    ((dtndx++)); # -td47: DATA_UNS_INT unsigned integer
DTDesc[$dtndx]="Test OSIP zero in 0|1";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=0";         DTHelp[$dtndx]="func <-f=item~B>";    ((dtndx++)); # -td48: DATA_ZEROONE zero or one
DTDesc[$dtndx]="Test OSIP ones in 0|1";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=1";         DTHelp[$dtndx]="func <-f=item~B>";    ((dtndx++)); # -td49: DATA_ZEROONE zero or one
DTDesc[$dtndx]="Test OSIP boolean int";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=01101";     DTHelp[$dtndx]="func <-f=item~b>";    ((dtndx++)); # -td50: DATA_BOOLNUM boolean int
DTDesc[$dtndx]="Test OSIP 0xHex integer"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=0xFE";      DTHelp[$dtndx]="func <-f=item~h>";    ((dtndx++)); # -td51: DATA_HEX_NUM hexadecimal
DTDesc[$dtndx]="Test OSIP  xHex integer"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=xDC";       DTHelp[$dtndx]="func <-f=item~h>";    ((dtndx++)); # -td52: DATA_HEX_NUM hexadecimal
DTDesc[$dtndx]="Test OSIP a hex integer"; DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=ab";        DTHelp[$dtndx]="func <-f=item~h>";    ((dtndx++)); # -td53: DATA_HEX_NUM hexadecimal
DTDesc[$dtndx]="Test OSIP percentage";   DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=50.5";      DTHelp[$dtndx]="func <-f=item~%>";    ((dtndx++)); # -td54: DATA_PERCENT num percent
DTDesc[$dtndx]="Test OSIP percent +50";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=50";        DTHelp[$dtndx]="func <-f=item~%+50>"; ((dtndx++)); # -td55: DATA_PERCENT num percent
DTDesc[$dtndx]="Test OSIP percent -50";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=-25";       DTHelp[$dtndx]="func <-f=item~%-50>"; ((dtndx++)); # -td56: DATA_PERCENT num percent
DTDesc[$dtndx]="Test OSIP hid percent";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=7";         DTHelp[$dtndx]="func <-f=item~10>";   ((dtndx++)); # -td57: DATA_PERCENT w/o percent
DTDesc[$dtndx]="Test OSIP num percent";  DTIsEg[$dtndx]=1;  DTQuot[$dtndx]=0;
DTData[$dtndx]="-f=2.5";       DTHelp[$dtndx]="func <-f=item~5.0>";  ((dtndx++)); # -td58: DATA_PERCENT num percent
# Note: negative cases are tested in Errors

# Future: following are future datatypes
DTDesc[$dtndx]=""; DTIsEg[$dtndx]=0; DTQuot[$dtndx]=0; DTData[$dtndx]=""; DTHelp[$dtndx]=""; ((dtndx++)); # -td59

# File/Dir Datatypes Checking ----------------------------------------------

NOFL="__asldkfjlsdkj__"; NOPT="$NOFL/$NOFL"; # not a file & not a path
chkbgn=$dtndx;  chkend=$dtndx; # use to debug a specific routine, move to any index

DTDesc[$dtndx]="Test dir|file rw";  DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~prw>";   ((dtndx++)); # -td60: DATA_PATH_RW dir|file rd & wr
DTDesc[$dtndx]="Test dir|file wr";  DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~pw>";    ((dtndx++)); # -td61: DATA_PATH_WR dir|file writable
DTDesc[$dtndx]="Test dir|file rd";  DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~pr>";    ((dtndx++)); # -td62: DATA_PATH_RD dir|file readable
DTDesc[$dtndx]="Test is a parent";    DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~pu>";    ((dtndx++)); # -td63: DATA_PATH_UP dir|file parent is
DTDesc[$dtndx]="Test dir|file not"; DTData[$dtndx]="$NOPT"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~pn>";    ((dtndx++)); # -td64: DATA_PATH_NO dir|file not exist
DTDesc[$dtndx]="Test dir|file is";  DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~p>";     ((dtndx++)); # -td65: DATA_PATH_IS dir|file exist
DTDesc[$dtndx]="Test dir is rw";    DTData[$dtndx]="$ROAD"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~drw>";   ((dtndx++)); # -td66: DATA_DIRS_RW dir read & write
DTDesc[$dtndx]="Test dir is wr";    DTData[$dtndx]="$ROAD"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~dw>";    ((dtndx++)); # -td67: DATA_DIRS_WR dir writable
DTDesc[$dtndx]="Test dir is rd";    DTData[$dtndx]="$ROAD"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~dr>";    ((dtndx++)); # -td68: DATA_DIRS_RD dir readable
DTDesc[$dtndx]="Test dir path is";  DTData[$dtndx]="$ROAD"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~du>";    ((dtndx++)); # -td69: DATA_DIRS_UP dir parent exists
DTDesc[$dtndx]="Test dir not is";   DTData[$dtndx]="$NOPT"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~dn>";    ((dtndx++)); # -td70: DATA_DIRS_NO dir not exist
DTDesc[$dtndx]="Test dir exists";   DTData[$dtndx]="$ROAD"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~d>";     ((dtndx++)); # -td71: DATA_DIRS_IS does dir exist
DTDesc[$dtndx]="Test file is wx";   DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~fwx>";   ((dtndx++)); # -td73: DATA_FILE_WX file write & exe
DTDesc[$dtndx]="Test file is rx";   DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~frx>";   ((dtndx++)); # -td74: DATA_FILE_RX file read and exe
DTDesc[$dtndx]="Test file is ex";   DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~fx>";    ((dtndx++)); # -td75: DATA_FILE_EX file isexecutable
DTDesc[$dtndx]="Test file is rw";   DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~frw>";   ((dtndx++)); # -td76: DATA_FILE_RW file read & write
DTDesc[$dtndx]="Test file is wr";   DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~fw>";    ((dtndx++)); # -td77: DATA_FILE_WR file writable
DTDesc[$dtndx]="Test file is rd";   DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~fr>";    ((dtndx++)); # -td78: DATA_FILE_RD file readable
DTDesc[$dtndx]="Test file is rwx";  DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~frwx>";  ((dtndx++)); # -td72: DATA_FIL_RWX file rd+write+exe
DTDesc[$dtndx]="Test path exists";  DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~fu>";    ((dtndx++)); # -td79: DATA_FILE_UP file path exists
DTDesc[$dtndx]="Test file not is";  DTData[$dtndx]="$NOFL"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~fn>";    ((dtndx++)); # -td80: DATA_FILE_NO file not exist
DTDesc[$dtndx]="Test file exists";  DTData[$dtndx]="$SELF"; DTIsEg[$dtndx]=1; DTQuot[$dtndx]=0;
DTHelp[$dtndx]="func <item~f>";     ((dtndx++)); # -td81: DATA_FILE_IS file exists

# Note: unsupported Datatype cases are in TestErrored (defined above)
((dtndx--)); # back up to last test : end of TestDataTyp : -td#

#############################################################################
# TestStrType : -ts# (0 is all, "" is show descriptions) - String|Var Datatypes
# NB: in this section we have several repeated tests with varying formats
#############################################################################
declare -a STData; declare -a STHelp; declare -a STDesc;
declare -a STQuot; declare -a STIsEg; stndx=1; # 1-based tests

# begin tests : String/Var Datatypes Checking -------------------------------

# following are variable types: Note ~vn (numbers by itself is not allowed)
STDesc[$stndx]="Test varname any";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_$UCAS$LCAS$NMBR";
STHelp[$stndx]="func <item~v>";     ((stndx++)); # -ts1|-ts01
STDesc[$stndx]="Test underscores";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="__";
STHelp[$stndx]="func <item~vu>";    ((stndx++)); # -ts2|-ts02
STDesc[$stndx]="Test var uppers";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$UCAS";
STHelp[$stndx]="func <item~v+>";    ((stndx++)); # -ts3|-ts03
STDesc[$stndx]="Test var lowers";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$LCAS";
STHelp[$stndx]="func <item~v->";    ((stndx++)); # -ts4|-ts04
STDesc[$stndx]="Test var upr+low";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$UCAS$LCAS";
STHelp[$stndx]="func <item~v+->";   ((stndx++)); # -ts5|-ts05
STDesc[$stndx]="Test var upr+num";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$UCAS$NMBR";
STHelp[$stndx]="func <item~v+n>";   ((stndx++)); # -ts6|-ts06
STDesc[$stndx]="Test var upr+und";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_$UCAS";
STHelp[$stndx]="func <item~v+u>";   ((stndx++)); # -ts7|-ts07
STDesc[$stndx]="Test var low+num";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$LCAS$NMBR";
STHelp[$stndx]="func <item~v-n>";   ((stndx++)); # -ts8|-ts08
STDesc[$stndx]="Test var low+und";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_$LCAS";
STHelp[$stndx]="func <item~v-u>";   ((stndx++)); # -ts9|-ts09
STDesc[$stndx]="Test var und+num";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_$NMBR";
STHelp[$stndx]="func <item~vun>";   ((stndx++)); # -ts10
STDesc[$stndx]="Test var u|l+num";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$UCAS$LCAS$NMBR";
STHelp[$stndx]="func <item~v+-n>";  ((stndx++)); # -ts11
STDesc[$stndx]="Test var u|l+und";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_${UCAS}_${LCAS}_";
STHelp[$stndx]="func <item~v+-u>";  ((stndx++)); # -ts12
STDesc[$stndx]="Test var upr_num";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_${UCAS}_$NMBR";
STHelp[$stndx]="func <item~v+un>";  ((stndx++)); # -ts13
STDesc[$stndx]="Test var low_num";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_${LCAS}_$NMBR";
STHelp[$stndx]="func <item~v-un>";  ((stndx++)); # -ts14
STDesc[$stndx]="Test var u|l_num";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_$UCAS${LCAS}_$NMBR";
STHelp[$stndx]="func <item~v+-un>"; ((stndx++)); # -ts15

# following are future datatypes
STDesc[$stndx]=""; STIsEg[$stndx]=0; STQuot[$stndx]=0; STData[$stndx]=""; STHelp[$stndx]=""; ((stndx++)); # -ts16: Future
STDesc[$stndx]=""; STIsEg[$stndx]=0; STQuot[$stndx]=0; STData[$stndx]=""; STHelp[$stndx]=""; ((stndx++)); # -ts17: Future
STDesc[$stndx]=""; STIsEg[$stndx]=0; STQuot[$stndx]=0; STData[$stndx]=""; STHelp[$stndx]=""; ((stndx++)); # -ts18: Future
STDesc[$stndx]=""; STIsEg[$stndx]=0; STQuot[$stndx]=0; STData[$stndx]=""; STHelp[$stndx]=""; ((stndx++)); # -ts19: Future

# following are string types: bare 's' unneeded (no checks) unless a range|value(s) supplied
# first group of string tests are repeated from the var tests : un~+-
# no var. restriction & adds: s (space), d (delimiter), m (math), p (punctuation), y (symbol) = `@#$\\/
STDesc[$stndx]="Test str numbers";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$NMBR";
STHelp[$stndx]="func <item~sn>";    ((stndx++)); # -ts20: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str unders";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="__";
STHelp[$stndx]="func <item~su>";    ((stndx++)); # -ts21: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str uppers";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$UCAS";
STHelp[$stndx]="func <item~s+>";    ((stndx++)); # -ts22: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str lowers";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$LCAS";
STHelp[$stndx]="func <item~s->";    ((stndx++)); # -ts23: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str upr+low";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$UCAS$LCAS";
STHelp[$stndx]="func <item~s+->";   ((stndx++)); # -ts24: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str upr+num";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$NMBR$UCAS";
STHelp[$stndx]="func <item~sn+>";   ((stndx++)); # -ts25: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str upr+und";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_$UCAS";
STHelp[$stndx]="func <item~su+>";   ((stndx++)); # -ts26: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str low+num";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$NMBR$LCAS";
STHelp[$stndx]="func <item~sn->";   ((stndx++)); # -ts27: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str low+und";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_$LCAS";
STHelp[$stndx]="func <item~su->";   ((stndx++)); # -ts28: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str num+und";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="${NMBR}_";
STHelp[$stndx]="func <item~snu>";   ((stndx++)); # -ts29: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str num+u|l";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$NMBR$UCAS$LCAS";
STHelp[$stndx]="func <item~s~n>";   ((stndx++)); # -ts30: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str low+und";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="_$UCAS${LCAS}_";
STHelp[$stndx]="func <item~s~u>";   ((stndx++)); # -ts31: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str num_upr";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="${NMBR}_$UCAS";
STHelp[$stndx]="func <item~s+un>";  ((stndx++)); # -ts32: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str num_low";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="${NMBR}_$LCAS";
STHelp[$stndx]="func <item~s-un>";  ((stndx++)); # -ts33: DATA_STR_GEN any variable name
STDesc[$stndx]="Test str num_u|l";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="${NMBR}_$UCAS$LCAS";
STHelp[$stndx]="func <item~s~un>";  ((stndx++)); # -ts34: DATA_STR_GEN any variable name
# so at this point we checked the combinations of: un+-~

# 2nd group of string tests are those symbol groups disallowed by vars : dlgy
STDesc[$stndx]="Test str delimit";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$DLMTGRP";
STHelp[$stndx]="func <item~sd>";    ((stndx++)); # -ts35: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str logics";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$MATHGRP"; # called: logic (l)
STHelp[$stndx]="func <item~sl>";    ((stndx++)); # -ts36: DATA_STR_GEN any varname
STDesc[$stndx]="Test str punct.";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$PUNCGRP"; # called: grammar (g)
STHelp[$stndx]="func <item~sg>";    ((stndx++)); # -ts37: DATA_STR_GEN any varname
STDesc[$stndx]="Test str symbol";
STIsEg[$stndx]=1;  STQuot[$stndx]=1; STData[$stndx]="$SYMSGRP";
STHelp[$stndx]="func <item~sy>";    ((stndx++)); # -ts38: DATA_STR_GEN any varname

# following are future datatypes
STDesc[$stndx]=""; STIsEg[$stndx]=0; STQuot[$stndx]=0; STData[$stndx]=""; STHelp[$stndx]=""; ((stndx++)); # -ts39: Future
STDesc[$stndx]=""; STIsEg[$stndx]=0; STQuot[$stndx]=0; STData[$stndx]=""; STHelp[$stndx]=""; ((stndx++)); # -ts40: Future
STDesc[$stndx]=""; STIsEg[$stndx]=0; STQuot[$stndx]=0; STData[$stndx]=""; STHelp[$stndx]=""; ((stndx++)); # -ts41: Future

# 3rd group of string tests remaining new string typs : abcefhijkmopqrstvwxz [not un+-~dlgy]
# since double-quoted tests are printed any differently mark them all with a comment
STDesc[$stndx]="Test str at (@)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="@@";
STHelp[$stndx]="func <items~sa>";   ((stndx++)); # -ts42: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str backsl (\\)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="\\";
STHelp[$stndx]="func <item~sb>";    ((stndx++)); # -ts43: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str colons (:;)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]=":;";
STHelp[$stndx]="func <item~sc>";    ((stndx++)); # -ts44: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str equalsign (=)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="==";
STHelp[$stndx]="func <item~se>";    ((stndx++)); # -ts45: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str fwd slash (/)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="//";
STHelp[$stndx]="func <item~sf>";    ((stndx++)); # -ts46: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str hash mark (#)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="##";
STHelp[$stndx]="func <item~sh>";    ((stndx++)); # -ts47: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str inquiries (?)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="??";
STHelp[$stndx]="func <item~si>";    ((stndx++)); # -ts48: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str jot|period (.)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="..";
STHelp[$stndx]="func <item~sj>";    ((stndx++)); # -ts49: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str caret|hats (^)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="^^";
STHelp[$stndx]="func <item~sk>";    ((stndx++)); # -ts50: DATA_STR_GEN delimiters
# NB: '--' will fail as it is becomes -- & interpreted as the end of options marker
STDesc[$stndx]="Test str minus|dash (-)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="-";
STHelp[$stndx]="func <item~sm>";    ((stndx++)); # -ts51: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str an or sign (|)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]='||';
STHelp[$stndx]="func <item~so>";    ((stndx++)); # -ts52: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str plus sign (+)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="++";
STHelp[$stndx]="func <item~sp>";    ((stndx++)); # -ts53: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str quotes (\"')";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="\"'";
STHelp[$stndx]="func <item~sq>";    ((stndx++)); # -ts54: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str rests (,)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]=",,";
STHelp[$stndx]="func <item~sr>";    ((stndx++)); # -ts55: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str stars (*)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="**";
STHelp[$stndx]="func <item~ss>";    ((stndx++)); # -ts56: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str tilda (~)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="~~";
STHelp[$stndx]="func <item~st>";    ((stndx++)); # -ts57: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str percent (%)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="%%";
STHelp[$stndx]="func <item~sv>";    ((stndx++)); # -ts58: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str whitesp ( )";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]=" ";
STHelp[$stndx]="func <item~sw>";    ((stndx++)); # -ts59: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str exclam. (!)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="!";
STHelp[$stndx]="func <item~sx>";    ((stndx++)); # -ts60: DATA_STR_GEN delimiters
STDesc[$stndx]="Test str dollars ($)";
STIsEg[$stndx]=1;  STQuot[$stndx]=2; STData[$stndx]="\$";
STHelp[$stndx]="func <item~sz>";    ((stndx++)); # -ts61: DATA_STR_GEN delimiters

# 4th we combine all the individual types to ensure same as 's' (i.e. the whole)
STDesc[$stndx]="Test str generic";  STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$LCAS$UNSCGRP$NMBR$SPACGRP$DLMTGRP$MATHGRP$PUNCGRP$SYMSGRP";
STHelp[$stndx]="func <item~s>";     ((stndx++)); # -ts62: DATA_STR_GEN all
STDesc[$stndx]="Test str all +&-";  STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$LCAS$UNSCGRP$NMBR$SPACGRP$DLMTGRP$MATHGRP$PUNCGRP$SYMSGRP";
STHelp[$stndx]="func <item~s+-unwdlgy>"; ((stndx++)); # -ts63: DATA_STR_GEN all
STDesc[$stndx]="Test str all w/~";  STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$LCAS$UNSCGRP$NMBR$SPACGRP$DLMTGRP$MATHGRP$PUNCGRP$SYMSGRP";
STHelp[$stndx]="func <item~s~unwdlgy>";  ((stndx++)); # -ts64: DATA_STR_GEN all

# 5th group of string tests combine all the types except 1 group: ~+-udwdlgy
STDesc[$stndx]="Test str no upper";   STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$LCAS$UNSCGRP$NMBR$SPACGRP$DLMTGRP$MATHGRP$PUNCGRP$SYMSGRP";
STHelp[$stndx]="func <item~s-unwdlgy>";  ((stndx++)); # -ts65: DATA_STR_GEN no: ~

STDesc[$stndx]="Test str no lower";   STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$UNSCGRP$NMBR$SPACGRP$DLMTGRP$MATHGRP$PUNCGRP$SYMSGRP";
STHelp[$stndx]="func <item~s+unwdlgy>";  ((stndx++)); # -ts66: DATA_STR_GEN no: -

STDesc[$stndx]="Test str no under";   STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$LCAS$NMBR$SPACGRP$DLMTGRP$MATHGRP$PUNCGRP$SYMSGRP";
STHelp[$stndx]="func <item~s~nwdlgy>";   ((stndx++)); # -ts67: DATA_STR_GEN no: u

STDesc[$stndx]="Test str no number";  STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$LCAS$UNSCGRP$SPACGRP$DLMTGRP$MATHGRP$PUNCGRP$SYMSGRP";
STHelp[$stndx]="func <item~s~uwdlgy>";   ((stndx++)); # -ts68: DATA_STR_GEN no: n

STDesc[$stndx]="Test str no spaces";  STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$LCAS$UNSCGRP$NMBR$DLMTGRP$MATHGRP$PUNCGRP$SYMSGRP";
STHelp[$stndx]="func <item~s~undlgy>";   ((stndx++)); # -ts69: DATA_STR_GEN no: w

STDesc[$stndx]="Test str no delimit"; STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$LCAS$UNSCGRP$NMBR$SPACGRP$MATHGRP$PUNCGRP$SYMSGRP";
STHelp[$stndx]="func <item~s~unwlgy>";   ((stndx++)); # -ts70: DATA_STR_GEN no: d

STDesc[$stndx]="Test str no logics";  STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$LCAS$UNSCGRP$NMBR$SPACGRP$DLMTGRP$PUNCGRP$SYMSGRP";
STHelp[$stndx]="func <item~s~unwdgy>";   ((stndx++)); # -ts71: DATA_STR_GEN no: l

STDesc[$stndx]="Test str no punct.";  STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$LCAS$UNSCGRP$NMBR$SPACGRP$DLMTGRP$MATHGRP$SYMSGRP";
STHelp[$stndx]="func <item~s~unwdly>";   ((stndx++)); # -ts72: DATA_STR_GEN no: g

STDesc[$stndx]="Test str no symbol";  STIsEg[$stndx]=1;  STQuot[$stndx]=1;
STData[$stndx]="$UCAS$LCAS$UNSCGRP$NMBR$SPACGRP$DLMTGRP$MATHGRP$PUNCGRP";
STHelp[$stndx]="func <item~s~unwdlg>";   ((stndx++)); # -ts73: DATA_STR_GEN no: y

# Extended Datatype Checking -----------------------------------------------

STDesc[$stndx]="Parm match enum bgn";
STHelp[$stndx]='func <dow~s%Mon%Tue%Wed>'; STIsEg[$stndx]=1;  STQuot[$stndx]=0;
STData[$stndx]='Mon'; ((stndx++)); # -ts74

STDesc[$stndx]="Parm match enum mid";
STHelp[$stndx]='func <dow~s%Mon%Tue%Wed>'; STIsEg[$stndx]=1;  STQuot[$stndx]=0;
STData[$stndx]='Tue'; ((stndx++)); # -ts75

STDesc[$stndx]="Parm match enum end";
STHelp[$stndx]='func <dow~s%Mon%Tue%Wed>'; STIsEg[$stndx]=1;  STQuot[$stndx]=0;
STData[$stndx]='Wed'; ((stndx++)); # -ts76

STDesc[$stndx]="Enum with hyphen in"; # verify '-' in enum doesn't interfere with enum
STHelp[$stndx]='func  num~s@1@1-3@3 ';     STIsEg[$stndx]=1;  STQuot[$stndx]=0;
STData[$stndx]='1-3'; ((stndx++)); # -ts77

STDesc[$stndx]="Enum with plus sign"; # verify '+' in enum doesn't interfere with enum
STHelp[$stndx]='func  num~s@1@1+3@3 ';     STIsEg[$stndx]=1;  STQuot[$stndx]=0;
STData[$stndx]='1+3'; ((stndx++)); # -ts78

STDesc[$stndx]="Enum with hyphen in"; # verify '-' in enum doesn't interfere with enum
STHelp[$stndx]='func  num~s%1%1-3%3 ';     STIsEg[$stndx]=1;  STQuot[$stndx]=0;
STData[$stndx]='1-3'; ((stndx++)); # -ts79

STDesc[$stndx]="Enum with plus sign"; # verify '+' in enum doesn't interfere with enum
STHelp[$stndx]='func  num~s%1%1+3%3 ';     STIsEg[$stndx]=1;  STQuot[$stndx]=0;
STData[$stndx]='1+3'; ((stndx++)); # -ts80

STDesc[$stndx]="Parm bgn str escape .";
STHelp[$stndx]='func <file_txt~s%file\.~>';       STIsEg[$stndx]=1; STQuot[$stndx]=0; # or: ~sj+-%"file."~
STData[$stndx]='file.txt'; ((stndx++));    # -ts81

STDesc[$stndx]="Parm ins end quoted .";
STHelp[$stndx]='func <file_txt~sj~%~".txt">';     STIsEg[$stndx]=1; STQuot[$stndx]=0; # or: ~sj+-%~\.txt
STData[$stndx]='file.txt'; ((stndx++));    # -ts82

STDesc[$stndx]="Indp bgn str escape .";
STHelp[$stndx]='func <-f file_txt~s%file\.~>';    STIsEg[$stndx]=1; STQuot[$stndx]=0; # or: ~sj+-%"file."~
STData[$stndx]='-f file.txt'; ((stndx++)); # -ts83

STDesc[$stndx]="Indp ins end quoted .";
STHelp[$stndx]='func <-f=file_txt~sj~%~".Txt">';  STIsEg[$stndx]=1; STQuot[$stndx]=0;  # or: ~sj+-%~\.txt
STData[$stndx]='-f=file.txt'; ((stndx++)); # -ts84

# Note: unsupported Datatype cases are in TestErrored (defined above)
((stndx--)); # back up to last test : end of TestStrType : -ts#

#############################################################################
# TestReqOpts : -tr{n{-{m}}} checks prefs (-p) for required|optional meaning
#############################################################################
declare -a ReqOptEnum; declare -a ReqEg; i=1; # 1-based tests

# begin tests
enum=$ITEM_NOLMT;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr01: 'n';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr02: 'n';
enum=$ITEM_SQARE;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr03: 's';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr04: 's';
enum=$ITEM_PARAN;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr05: 'p';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr06: 'p';
enum=$ITEM_ANGLE;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr07: 'a';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr08: 'a';
enum=$ITEM_CURLY;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr09: 'c';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr10: 'c';
enum=$ITEM_SDASH;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr11: '';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr12: '';
enum=$ITEM_WORDS;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr13: '';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr14: '';
enum=$ITEM_DDASH;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr15: '';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr16: '';
enum=$ITEM_QUOTE;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr17: '';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr18: '';
enum=$ITEM_PIPES;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr19: '';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr20: '';
enum=$ITEM_COMNT;   ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr21: '';
                    ReqOptEnum[$i]=$enum; ReqEg[$i]=1; ((i++)); # -tr22: '';

SizeReqOpt=$((i-1)); # End of All the Tests : keep as the last line

#############################################################################
# TestMatches : -tm# (0 is all, "" is show descriptions)
# NB: for testing purposes only, the parm name is defaulted to 'name'
# All Failure cases are put at the end
#############################################################################
declare -a MatchDesc; declare -a MatchData; declare -a MatchRcvd;
declare -a MatchFail; declare -a MatchIsEg; i=1; # 1-based tests
MatchWhole="bgn.mid.end"; # standard data used for these tests

# begin tests
# Exact Match Tests --------------------------------------------------------
MatchDesc[$i]="func <name~s@$MatchWhole>    # Exact Matches";   # SRCH_ALL # -tm1|-tm01
MatchData[$i]="$MatchWhole"; MatchRcvd[$i]="$MatchWhole";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++));
# Part. Match Tests --------------------------------------------------------
MatchDesc[$i]="func <name~s%$MatchWhole>    # Partial Match";   # SRCH_ALL # -tm2|-tm02
MatchData[$i]="$MatchWhole"; MatchRcvd[$i]="$MatchWhole";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++));
MatchDesc[$i]="func <name~s%~mid~>          # Partial Match";   # SRCH_ANY # -tm3|-tm03
MatchData[$i]="$MatchWhole"; MatchRcvd[$i]="$MatchWhole";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++));
MatchDesc[$i]="func <name~s%bgn~>           # Partial Match";   # SRCH_BGN # -tm4|-tm04
MatchData[$i]="$MatchWhole"; MatchRcvd[$i]="$MatchWhole";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++));
MatchDesc[$i]="func <name~s%~end>           # Partial Match";   # SRCH_END # -tm5|-tm05
MatchData[$i]="$MatchWhole"; MatchRcvd[$i]="$MatchWhole";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++));
# Extraction Tests ---------------------------------------------------------
MatchDesc[$i]="func <name~s%%$MatchWhole>   # Extract Tests";   # SRCH_ALL # -tm6|-tm06
MatchData[$i]="$MatchWhole"; MatchRcvd[$i]="$MatchWhole";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++));
MatchDesc[$i]="func <name~s%%~mid~>         # Extract Tests";   # SRCH_ANY # -tm7|-tm07
MatchData[$i]="$MatchWhole"; MatchRcvd[$i]="mid";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++));
MatchDesc[$i]="func <name~s%%bgn~>          # Extract Tests";   # SRCH_BGN # -tm8|-tm08
MatchData[$i]="$MatchWhole"; MatchRcvd[$i]="bgn";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++));
MatchDesc[$i]="func <name~s%%~end>          # Extract Tests";   # SRCH_END # -tm9|-tm09
MatchData[$i]="$MatchWhole"; MatchRcvd[$i]="end";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++));
# Enumerate Tests (can only be exact match) --------------------------------
MatchDesc[$i]="func <name~s@bgn@mid@end>    # Enumerate Test";
MatchData[$i]="bgn"; MatchRcvd[$i]="bgn";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # SRCH_ALL # -tm10
MatchDesc[$i]="func <name~s@bgn@mid@end>    # Enumerate Test";
MatchData[$i]="mid"; MatchRcvd[$i]="mid";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # SRCH_ALL # -tm11
MatchDesc[$i]="func <name~s@bgn@mid@end>    # Enumerate Test";
MatchData[$i]="end"; MatchRcvd[$i]="end";
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # SRCH_ALL # -tm12

# EQAL Num Exact Cases -----------------------------------------------------
MatchDesc[$i]='func name~i@5                # num exact matches all';
MatchRcvd[$i]="5";   MatchData[$i]='5';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm13
MatchDesc[$i]='func name~i@5~               # num exact matches bgn';
MatchRcvd[$i]="56";  MatchData[$i]='56';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm14
MatchDesc[$i]='func name~i@~5~              # num exact matches mid';
MatchRcvd[$i]="456"; MatchData[$i]='456';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm15
MatchDesc[$i]='func name~i@~5               # num exact matches end';
MatchRcvd[$i]="45";  MatchData[$i]='45';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm16

# EQAL Num Part. Cases -----------------------------------------------------
MatchDesc[$i]='func name~i%5                # num part. matches all';
MatchRcvd[$i]="5";   MatchData[$i]='5';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm17
MatchDesc[$i]='func name~i%5~               # num part. matches bgn';
MatchRcvd[$i]="56";  MatchData[$i]='56';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm18
MatchDesc[$i]='func name~i%~5~              # num part. matches mid';
MatchRcvd[$i]="456"; MatchData[$i]='456';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm19
MatchDesc[$i]='func name~i%~5               # num part. matches end';
MatchRcvd[$i]="45";  MatchData[$i]='45';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm20

# EQAL Num Exact Extract ---------------------------------------------------
MatchDesc[$i]='func name~i@@9876543210      # num exact extract all';
MatchRcvd[$i]="9876543210"; MatchData[$i]='9876543210';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm21
MatchDesc[$i]='func name~i@@987~            # num exact extract bgn';
MatchRcvd[$i]="6543210";    MatchData[$i]='9876543210';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm22
MatchDesc[$i]='func name~i@@~654~           # num exact extract mid';
MatchRcvd[$i]="987 3210";   MatchData[$i]='9876543210';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm23
MatchDesc[$i]='func name~i@@~3210           # num exact extract end';
MatchRcvd[$i]="987654";     MatchData[$i]='9876543210';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm24
MatchDesc[$i]='func name~i@@~23~            # num exact get multi-mid';
MatchRcvd[$i]="1 41 51";    MatchData[$i]='12341235123';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm25

# EQAL Num Part. Extract ---------------------------------------------------
MatchDesc[$i]='func name~i%%9876543210      # num part. extract all';
MatchRcvd[$i]="9876543210"; MatchData[$i]='9876543210';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm26
MatchDesc[$i]='func name~i%%98.~            # num part. extract bgn';
MatchRcvd[$i]="6543210";    MatchData[$i]='9876543210';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm27
MatchDesc[$i]='func name~i%%~65.~           # num part. extract mid';
MatchRcvd[$i]="654";        MatchData[$i]='9876543210';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm28
MatchDesc[$i]='func name~i%%~3210.          # num part. extract end';
MatchRcvd[$i]="987654";     MatchData[$i]='98765432105';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm29
MatchDesc[$i]='func name~i%%~.23.~          # num part. get multi-mid';
MatchRcvd[$i]="1234";       MatchData[$i]='12341235123';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm30

# EQAL Str Exact Cases -----------------------------------------------------
MatchDesc[$i]='func name~s@prebookend       # str exact matches all';
MatchRcvd[$i]="prebookend"; MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm31
MatchDesc[$i]='func name~s@pre~             # str exact matches bgn';
MatchRcvd[$i]="prebookend"; MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm32
MatchDesc[$i]='func name~s@~book~           # str exact matches mid';
MatchRcvd[$i]="prebookend"; MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm33
MatchDesc[$i]='func name~s@~end             # str exact matches end';
MatchRcvd[$i]="prebookend"; MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm34

# EQAL Str Part. Cases -----------------------------------------------------
MatchDesc[$i]='func name~s%prebookend       # str part. matches all';
MatchRcvd[$i]="prebookend"; MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm35
MatchDesc[$i]='func name~s%pre~             # str part. matches bgn';
MatchRcvd[$i]="prebookend"; MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm36
MatchDesc[$i]='func name~s%~book~           # str part. matches mid';
MatchRcvd[$i]="prebookend"; MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm37
MatchDesc[$i]='func name~s%~end             # str part. matches end';
MatchRcvd[$i]="prebookend"; MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm38

# EQAL Str Exact Extract ---------------------------------------------------
MatchDesc[$i]='func name~s@@prebookend      # str exact extract all';
MatchRcvd[$i]="prebookend"; MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm39
MatchDesc[$i]='func name~s@@pre~            # str exact extract bgn';
MatchRcvd[$i]="bookend";    MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm40
MatchDesc[$i]='func name~s@@~book~          # str exact extract mid';
MatchRcvd[$i]="pre end";    MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm41
MatchDesc[$i]='func name~s@@~end            # str exact extract end';
MatchRcvd[$i]="prebook";    MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm42
MatchDesc[$i]='func name~s@@~to~            # str exact get multi-mid';
MatchRcvd[$i]="1 many 1";   MatchData[$i]='1tomanyto1';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm43

# EQAL Str Part. Extract ---------------------------------------------------
MatchDesc[$i]='func name~s%%prebookend      # str exact extract all';
MatchRcvd[$i]="prebookend"; MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm44
MatchDesc[$i]='func name~s%%pr.~            # str exact extract bgn';
MatchRcvd[$i]="pre";        MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm45
MatchDesc[$i]='func name~s%%~boo.~          # str exact extract mid';
MatchRcvd[$i]="book";       MatchData[$i]='prebookend';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm46
MatchDesc[$i]='func name~s%%~end.           # str exact extract end';
MatchRcvd[$i]="end5";       MatchData[$i]='prebookend5';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm47
MatchDesc[$i]='func name~s%%~to.~           # str exact get multi-mid';
MatchRcvd[$i]="tom";        MatchData[$i]='1tomanyto1';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm48
MatchDesc[$i]='func name~s%%~ma[l-n][x-z]~  # extract letter ranges';
MatchRcvd[$i]="many";       MatchData[$i]='1tomanyto1';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm49

# RANG Num Exact Cases -----------------------------------------------------
MatchDesc[$i]='func name~i@5-7              # pos range num exact all';
MatchRcvd[$i]="6";   MatchData[$i]='6';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm50
MatchDesc[$i]='func name~i@-7--5            # neg range num exact bgn';
MatchRcvd[$i]="-6";  MatchData[$i]='-6';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm51
MatchDesc[$i]='func name~i@-3-2             # +/- range num exact mid';
MatchRcvd[$i]="1";   MatchData[$i]='1';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm52
MatchDesc[$i]='func name~i@5-7              # pos range num exact all';
MatchRcvd[$i]="6";   MatchData[$i]='6';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm53
MatchDesc[$i]='';
MatchRcvd[$i]="";  MatchData[$i]='';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm54 [Future]
MatchDesc[$i]='func name~i@-3-2             # +/- range num exact mid';
MatchRcvd[$i]="1";   MatchData[$i]='1';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm55
MatchDesc[$i]='func name~n@~5               # uns range num exact end';
MatchRcvd[$i]="45";  MatchData[$i]='45';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm56

# RANG Num Part. Cases -----------------------------------------------------
MatchDesc[$i]='func name~i%5-7              # pos range num part. all';
MatchRcvd[$i]="6";   MatchData[$i]='6';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm57
MatchDesc[$i]='func name~i%-7--5            # neg range num part. bgn';
MatchRcvd[$i]="-6";  MatchData[$i]='-6';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm58
MatchDesc[$i]='func name~i%-3-2             # +/- range num part. mid';
MatchRcvd[$i]="1";   MatchData[$i]='1';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm59
MatchDesc[$i]='func name~i%5-7              # pos range num part. all';
MatchRcvd[$i]="6";   MatchData[$i]='6';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm60
MatchDesc[$i]='';
MatchRcvd[$i]="";  MatchData[$i]='';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm61 [Future]
MatchDesc[$i]='func name~i%-3-2             # +/- range num part. mid';
MatchRcvd[$i]="1";   MatchData[$i]='1';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm62
MatchDesc[$i]='func name~n%~5               # uns range num part. end';
MatchRcvd[$i]="45";  MatchData[$i]='45';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm63

# RANG Num Exact Extract - Unsupported -------------------------------------
MatchDesc[$i]='func name~i@@5-7             # pos range num exact all';
MatchRcvd[$i]="";    MatchData[$i]='6';
MatchIsEg[$i]=0;  MatchFail[$i]=1; ((i++)); # -tm64

# RANG Num Part. Extract - Unsupported -------------------------------------
MatchDesc[$i]='func name~i%%5-7             # pos range num part. all';
MatchRcvd[$i]="";    MatchData[$i]='6';
MatchIsEg[$i]=0;  MatchFail[$i]=1; ((i++)); # -tm65

# RANG Str Exact Cases -----------------------------------------------------
MatchDesc[$i]='func name~s-@baby-cars       # str range num exact low bgn';
MatchRcvd[$i]='baby';   MatchData[$i]='baby';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm66
MatchDesc[$i]='func name~s-@baby-cars       # str range num exact low end';
MatchRcvd[$i]='cars';   MatchData[$i]='cars';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm67
MatchDesc[$i]='func name~s-@baby-cars       # str range num exact low mid';
MatchRcvd[$i]='bear';   MatchData[$i]='bear';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm68
MatchDesc[$i]='func name~s~@baby-cars       # str range num exact ins mid';
MatchRcvd[$i]='Bear';   MatchData[$i]='Bear';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm69
MatchDesc[$i]='func name~s~@baby-cars       # str range num exact low bgn';
MatchRcvd[$i]='baby';   MatchData[$i]='baby';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm70
MatchDesc[$i]='func name~s~@baby-cars       # str range num exact low end';
MatchRcvd[$i]='Cars';   MatchData[$i]='Cars';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm71

# RANG Str Part. Cases -----------------------------------------------------
MatchDesc[$i]='func name~s-%baby-cars       # str range num part. low bgn';
MatchRcvd[$i]='baby';   MatchData[$i]='baby';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm72
MatchDesc[$i]='func name~s-%baby-cars       # str range num part. low end';
MatchRcvd[$i]='cars';   MatchData[$i]='cars';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm73
MatchDesc[$i]='func name~s-%baby-cars       # str range num part. low mid';
MatchRcvd[$i]='bear';   MatchData[$i]='bear';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm74
MatchDesc[$i]='func name~s~%baby-cars       # str range num part. ins mid';
MatchRcvd[$i]='Bear';   MatchData[$i]='Bear';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm75
MatchDesc[$i]='func name~s~%baby-cars       # str range num part. low bgn';
MatchRcvd[$i]='baby';   MatchData[$i]='baby';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm76
MatchDesc[$i]='func name~s~%baby-cars       # str range num part. low end';
MatchRcvd[$i]='Cars';   MatchData[$i]='Cars';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm77

# RANG Str Exact Extract - Unsupported -------------------------------------
MatchDesc[$i]='func name~s-@@baby-cars      # str range num exact low bgn';
MatchRcvd[$i]='';       MatchData[$i]='';
MatchIsEg[$i]=0;  MatchFail[$i]=1; ((i++)); # -tm78

# RANG Str Part. Extract - Unsupported -------------------------------------
MatchDesc[$i]='func name~s-%%baby-cars      # str range num part. low bgn';
MatchRcvd[$i]='';       MatchData[$i]='';
MatchIsEg[$i]=0;  MatchFail[$i]=1; ((i++)); # -tm79

# Extension Tests (Enum) ---------------------------------------------------
# generic string, just match extension at end
MatchDesc[$i]='func {name~s@~.txt}          # end string no subtype';
MatchRcvd[$i]="file.txt"; MatchData[$i]='file.txt';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm80
# as soon as we add lowercase we must add period also using punctuation (p)
MatchDesc[$i]='func {name~sj-@~.txt}        # end string w/ subtype';
MatchRcvd[$i]="file.txt"; MatchData[$i]='file.txt';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm81
# allow any case with jot [period] (j)
MatchDesc[$i]='func {name~sj~@~.C}          # end string exact case';
MatchRcvd[$i]="file.C";   MatchData[$i]='file.C';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm82
# lower case with jot [period] (j)
MatchDesc[$i]='func {name~sj-@~".txt"}      # end string lower case';
MatchRcvd[$i]="file.txt"; MatchData[$i]='file.txt';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm83
# allow any case: match exact extension at end with punctuation (p)
MatchDesc[$i]='func {name~sj~@~.C}          # end string any case 1';
MatchRcvd[$i]="File.C";   MatchData[$i]='File.C';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm84
# allow any case: match different case exten. at end with punctuation (p)
MatchDesc[$i]='func {name~sj~@~.C}          # end string any case 2';
MatchRcvd[$i]="File.c";   MatchData[$i]='File.c';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm85
# proper extn with old pre-subtype (unneeded now) with punctuation (p)
MatchDesc[$i]='func {name~sj~@~.C}          # end string any case 3';
MatchRcvd[$i]="File.C";   MatchData[$i]='File.C';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm86
# allow any case with old pre-subtype (overrides lower) with punctuation (p)
MatchDesc[$i]='func {name~sj~@~.c}          # end string any case 4';
MatchRcvd[$i]="File.C";   MatchData[$i]='File.C';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm87
# allow any case with jot [period] (j)
MatchDesc[$i]='func {name~sj~@~".TXT"}      # end any case same rxd';
MatchRcvd[$i]="file.TXT"; MatchData[$i]='file.TXT';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm88
MatchDesc[$i]='func {name~sj~@~".TXT"}      # end any case diff rxd';
MatchRcvd[$i]="file.txt"; MatchData[$i]='file.txt';
MatchIsEg[$i]=1;  MatchFail[$i]=0; ((i++)); # -tm89

# match is forced to conform to specified case
MatchDesc[$i]='func {name~sj-@~".TXT"}      # end low case diff rxd';
MatchRcvd[$i]="file.txt"; MatchData[$i]='file.txt';
MatchIsEg[$i]=1; MatchFail[$i]=0; ((i++));  # -tm90
MatchDesc[$i]='func {name~sj-@~".Txt"}      # end of string any case';
MatchRcvd[$i]="file.txt"; MatchData[$i]='file.txt';
MatchIsEg[$i]=1; MatchFail[$i]=0; ((i++));  # -tm91

# Failure cases [don't include in examples] --------------------------------
# ensure that '.' isn't matching any char
MatchDesc[$i]='func {name~sj~@~".TXT"}      # !match any ch. quoted';
MatchRcvd[$i]="filesTXT"; MatchData[$i]='filesTXT';
MatchIsEg[$i]=0; MatchFail[$i]=1;  ((i++)); # -tm92
MatchDesc[$i]='func {name~sj~@~.TXT}        # !match any ch. !quote';
MatchRcvd[$i]="filesTXT"; MatchData[$i]='filesTXT';
MatchIsEg[$i]=0; MatchFail[$i]=1;  ((i++)); # -tm93

# Surrounding Number Tests -------------------------------------------------
# surrounding number not numbers
MatchDesc[$i]='func name~i%~5~              # num part. mid non-#s';
MatchRcvd[$i]="a5b"; MatchData[$i]='a5b';
MatchIsEg[$i]=1; MatchFail[$i]=0; ((i++));  # -tm94
# surrounding text are not all numbers
MatchDesc[$i]='func name~i@~5~              # num exact mid non-#s';
MatchRcvd[$i]="a5b"; MatchData[$i]='a5b';
MatchIsEg[$i]=1; MatchFail[$i]=0; ((i++));  # -tm95

# Negation Class Tests -----------------------------------------------------
MatchDesc[$i]='func {name~s%%[[:digit:]]+}  # num class extraction';
MatchRcvd[$i]="7803"; MatchData[$i]='ab7803cd';
MatchIsEg[$i]=1; MatchFail[$i]=0; ((i++));  # -tm96

MatchDesc[$i]='func {name~s%%%[[:digit:]]+} # number class negation';
MatchRcvd[$i]="abcd"; MatchData[$i]='ab7803cd';
MatchIsEg[$i]=1; MatchFail[$i]=0; ((i++));  # -tm97

((Match=i-1)); # back up to last test

#############################################################################
# Error Tests (TestErrored): -te# (0 is all, "" is show descriptions)
# Here are all the error generation tests to test all of the supported errors
# Error Tests need a special explanation fields since the Description is used
# the same for the same error, even though it is being tested different ways.
# Notes: BERR, UNDF, CMDL are not real errors, just placeholders (so no test);
# the other commented out tests still need a scenario in order to test them,
# see TestsNeededin getparms.sh: RHLP; Future tests here should keep original
# enum=$VALU; but should set: ErrTestEnum[$i]=$FUTR;
#############################################################################
declare -a ErrTestDesc; declare -a ErrTestHelp; declare -a ErrTestCmdl;
declare -a ErrTestOpts; declare -a ErrTestEnum; declare -a ErrTestFail;
declare -a ErrTestDsc2; i=1; FUTR=0; # 1-based tests; estr used to make 2 digit #

# begin tests: BERR & UNDF N/A ----------------------------------------------

# BFCN test bad function name [also see XNAM for exported var]
enum=$BFCN; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Bad|absent function name found
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BFCN
ErrTestDsc2[$i]=" due to the missing function name";
ErrTestHelp[$i]="-i # error ${ErrName[$enum]} (func name missing)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te1|-te01
enum=$BFCN; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Bad|absent function name found
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BFCN
ErrTestDsc2[$i]=" due to an invalid char pipe: '|'";
ErrTestHelp[$i]="hi|bye {-i} # error ${ErrName[$enum]} (func bad char)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te2|-te02

# BNAM test bad names caught for parms, indparm, & altname
enum=$BNAM; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Item's name contains bad chars
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BNAM
ErrTestDsc2[$i]=" due to bad parm name with hyphen";
ErrTestHelp[$i]="func {nam-end} # error ${ErrName[$enum]} bad parm name: hyphen";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te3|-te03
enum=$BNAM; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Item's name contains bad chars
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BNAM
ErrTestDsc2[$i]=" due to bad indp name with period";
ErrTestHelp[$i]="func {-f=file.txt} # error ${ErrName[$enum]} bad indp name: dot";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te4|-te04
enum=$BNAM; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Item's name contains bad chars
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BNAM
ErrTestDsc2[$i]=" due to bad optn name leading num";
ErrTestHelp[$i]="func {-o:3opt} # error ${ErrName[$enum]} bad altn name: lead num";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te5|-te05
enum=$BNAM; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Item's name contains bad chars
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BNAM
ErrTestDsc2[$i]=" due to bad enum contains a space";
ErrTestHelp[$i]="func {dow~s%a one%two} # error ${ErrName[$enum]} (enum with space)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te6|-te06
enum=$BNAM; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Item's name contains bad chars
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BNAM
ErrTestDsc2[$i]=" due to bad optn with middle plus";
ErrTestHelp[$i]="func {-o+o} # error ${ErrName[$enum]} (optn with middle plus)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te7|-te07
enum=$BNAM; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Item's name contains bad chars
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BNAM
ErrTestDsc2[$i]=" due to bad parm with middle plus";
ErrTestHelp[$i]="func {o+o}  # error ${ErrName[$enum]} (parm with middle plus)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te8|-te08

# BPVR happens for bad optional (-o) or bad preference (-p) or 1x for bad option (-o)
enum=$BPVR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Bad parsing letter is received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BPVR
ErrTestDsc2[$i]=" due to a pref letter 'z' unknown";
ErrTestHelp[$i]="func  # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-pz=@'; ((i++));    # -te9|-te09 [not: g|a|r|m|e|n|t|v|x]
enum=$BPVR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Bad parsing letter is received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BPVR
ErrTestDsc2[$i]=" due to an opt letter 'z' unknown";
ErrTestHelp[$i]="func  # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-oz'; ((i++));      # -te10|-te10 [not: n|s|p|a|c]
enum=$BPVR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Bad parsing value was received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BPVR
ErrTestDsc2[$i]=" due to pref symbol ';' is banned";
ErrTestHelp[$i]="func  # error ${ErrName[$enum]} [banned symbol]";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-pt;'; ((i++));     # -te11|-te11 [banned symbol]
enum=$BPVR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Bad parsing value was received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BPVR
ErrTestDsc2[$i]=" due to pref. val can't be number";
ErrTestHelp[$i]="func  # error ${ErrName[$enum]} [alpha-numeric]";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-pt1'; ((i++));     # -te12 [alpha-numeric]
enum=$BPVR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Bad parsing value was received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # BPVR
ErrTestDsc2[$i]=" due to pref would be a duplicate";
ErrTestHelp[$i]="func  # error ${ErrName[$enum]} [existing set]";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-ch -pt$'; ((i++)); # -te13 [in existing set]

enum=$CFUN; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Unknown -c Config was received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # CFUN
ErrTestDsc2[$i]=" due to config, 'z' being unknown";
ErrTestHelp[$i]="func  # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-cz'; ((i++));      # -te14 [SetCfg]

enum=$DFCN; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Collides with the scripts name
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # CFUN
ErrTestDsc2[$i]=" due to parm is same as function ";
ErrTestHelp[$i]="func func -i # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-on'; ((i++));      # -te15

enum=$DTOP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Options don't support Datatype
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # DTOP
ErrTestDsc2[$i]=" due to optns can't have datatype";
ErrTestHelp[$i]="func {-o~ni} # error ${ErrName[$enum]}"; # NB: shouldn't get UNKI error
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te16 [Warnings so make optional]

enum=$DTPV; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Datatype requires a parm value
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # DTPV
ErrTestDsc2[$i]=" due to dtype missing val after @";
ErrTestHelp[$i]="func {file~f@} # error ${ErrName[$enum]} - no value";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te17

# DTSH can fail 3 ways
enum=$DTSH; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Datatype unsupported for SHIPs
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # DTSH
ErrTestDsc2[$i]=" due to SHIP can't have datatypes";
ErrTestHelp[$i]="func {-d=~s+} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te18
enum=$DTSH; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Datatype unsupported for SHIPs
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # DTSH
ErrTestDsc2[$i]=" due to SHIP dtype after alt name";
ErrTestHelp[$i]="func {--m-p-h=:miles~np} # SHIP altname & datatype (N/A) afters";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te19
enum=$DTSH; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Datatype unsupported for SHIPs
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # DTSH
ErrTestDsc2[$i]=" due to SHIP dtype before altname";
ErrTestHelp[$i]="func {--m-p-h~np:miles} # SHIP altname & datatype (N/A) before";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te20

# Note: ~ by itself is ignored, but ~ followed by any unrecognized value will error
enum=$DTUD; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Unrecognized Datatype received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # DTUD
ErrTestDsc2[$i]=" due to unknown datatype was rcvd";
ErrTestHelp[$i]="func {parm~z} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te21

enum=$DVUN; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # DataValu unsupported for dtype
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # DVUN
ErrTestDsc2[$i]=" due to an unsupported data value";
ErrTestHelp[$i]="func {file~f@1-2}  # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te22

# ENDL can fail 2 ways
enum=$ENDL; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Item after endless parm. found
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # ENDL
ErrTestDsc2[$i]=" due to endless parm was not last";
ErrTestHelp[$i]="func {a ...} {pastend} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te23
enum=$ENDL; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Item after endless parm. found
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # ENDL
ErrTestDsc2[$i]=" due to endless indp was not last";
ErrTestHelp[$i]="func {-f=a ...} {-a} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te24

enum=$INVN; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Invalid received number format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # INVN
ErrTestDsc2[$i]=" due to enum range not an hex (g)";
ErrTestHelp[$i]="func {hex~h@10-1g} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te25 [Warnings so make optional]
enum=$INVN; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Invalid received number format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # INVN
ErrTestDsc2[$i]=" due to enum range not an hex (h)";
ErrTestHelp[$i]="func hex~h # error ${ErrName[$enum]} (bad hex int)";
ErrTestCmdl[$i]='0xabh'; ErrTestOpts[$i]=''; ((i++));    # -te26
enum=$INVN; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Invalid received number format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # INVN
ErrTestDsc2[$i]=" due to percent int was a decimal";
ErrTestHelp[$i]="func -f=item~%50 # error ${ErrName[$enum]}  (%: positive num)";
ErrTestCmdl[$i]='-f +5.5'; ErrTestOpts[$i]=''; ((i++));  # -te27 [Note: ~%50.0 would work]
enum=$INVN; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Invalid received number format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # INVN
ErrTestDsc2[$i]=" due to neg int percent was a pos";
ErrTestHelp[$i]="func -f=item~%-50 # error ${ErrName[$enum]} (%: pos s/b neg)";
ErrTestCmdl[$i]='-f 5'; ErrTestOpts[$i]=''; ((i++));     # -te28

# MIPC can fail 2 ways (comma separated items no longer supported)
enum=$MIPC; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple IndirectParm w/commas
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MIPC
ErrTestDsc2[$i]=" due to multiple OSIPs with comma";
ErrTestHelp[$i]="func {-f=parm1,parm2,parm3} # error ${ErrName[$enum]} due to OSIP";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te29
enum=$MIPC; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple IndirectParm w/commas
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MIPC
ErrTestDsc2[$i]=" due to multiple indps with comma";
ErrTestHelp[$i]="func {-f parm1,parm2,parm3} # error ${ErrName[$enum]} due to Norm Indp";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te30

# MIPP that occur in specification
enum=$MIPP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Missing IndirectParameter parm
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MIPP
ErrTestDsc2[$i]=" due to indp w/ no leading option";
ErrTestHelp[$i]="func {=parm} # error ${ErrName[$enum]} (begin with '=')";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te31
enum=$MIPP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Missing IndirectParameter parm
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MIPP
ErrTestDsc2[$i]=" due to indp w/ no trailing parms";
ErrTestHelp[$i]="func {parm=} # error ${ErrName[$enum]} (ended with '=')";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te32
enum=$MIPP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Missing IndirectParameter parm
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MIPP
ErrTestDsc2[$i]=" due to isolated equals ch. ('=')";
ErrTestHelp[$i]="func   {=}   # error ${ErrName[$enum]} (only with '=')";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te33

# MIPP that occur in the command-line
# NB: {-f prm1 prm2 prm3} not the same as {-f=prm1 prm2 prm3}
enum=$MIPP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Missing IndirectParameter parm
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MIPP
ErrTestDsc2[$i]=" due to too few of multi-ind parm";
ErrTestHelp[$i]="func {-f prm1 prm2 prm3} # error ${ErrName[$enum]} (multi-indp)";
ErrTestCmdl[$i]='-f val1 val2'; ErrTestOpts[$i]='-ccs'; ((i++)); # -te34
enum=$MIPP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Missing IndirectParameter parm
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # REQD
ErrTestDsc2[$i]=" due to the missing rcvd ind parm";
ErrTestHelp[$i]="func <-i in> # error ${ErrName[$enum]} (miss required ind parm)";
ErrTestCmdl[$i]='-i'; ErrTestOpts[$i]=''; ((i++));       # -te35

enum=$MORP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple parm in a Mixed group
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MORP
ErrTestDsc2[$i]=" due to multiple mixed spec parms";
ErrTestHelp[$i]="func {-v|m1|m2} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te36

# MRPP can fail several ways
enum=$MRPP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # More requires a preceding parm
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MRPP
ErrTestDsc2[$i]=" due to endless but no first parm";
ErrTestHelp[$i]="func {...} # error ${ErrName[$enum]} (more at beginning)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te37
enum=$MRPP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Item's name contains bad chars
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MRPP
ErrTestDsc2[$i]=" due to endless after ungroup opt";
ErrTestHelp[$i]="func  -d ...  # error ${ErrName[$enum]} missing previous parm name with optn";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-on'; ((i++));      # -te38
enum=$MRPP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # More requires a preceding parm
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MRPP
ErrTestDsc2[$i]=" due to endless after grouped opt";
ErrTestHelp[$i]="func {-d ...} # error ${ErrName[$enum]} (more after opt)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te39
enum=$MRPP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # More requires a preceding parm
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MRPP
ErrTestDsc2[$i]=" due to endless indp w/o 1st parm";
ErrTestHelp[$i]="func {-d=...} # error ${ErrName[$enum]} (more in indprm)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te40

enum=$MTHS; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Empty HELP Option string given
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MTHS
ErrTestDsc2[$i]=" due to a absent spec help string";
ErrTestHelp[$i]=""; # Note: this is why we can't check for empty HELP string to run test
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te41

# MTPI can fail 2 ways
enum=$MTPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Parsing item empty | has space
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MTPI
ErrTestDsc2[$i]=" due to the missing pref's value ";
ErrTestHelp[$i]="func  # error ${ErrName[$enum]} (SetSym)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-pg'; ((i++));      # -te42
enum=$MTPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Parsing item empty | has space
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MTPI
ErrTestDsc2[$i]=" due to the missing options value";
ErrTestHelp[$i]="func  # error ${ErrName[$enum]} (SetItem)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-o'; ((i++));       # -te43

# MULO Optn names can collide several different ways
enum=$MULO; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple end bgn markers found
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MULO
ErrTestDsc2[$i]=" due to multiple end bgnp markers";
ErrTestHelp[$i]="func {-+} {prm1} {-+} {-i} {prm2} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]='1 2'; ErrTestOpts[$i]=''; ((i++));      # -te44 [Warnings so make optional]
enum=$MULO; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple end opt markers found
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MULO
ErrTestDsc2[$i]=" due to multiple end opts markers";
ErrTestHelp[$i]="func {-i} {--} {prm1} {--} {prm2} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]='1 2'; ErrTestOpts[$i]=''; ((i++));      # -te45 [Warnings so make optional]
enum=$MULO; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple option with same name
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MULO
ErrTestDsc2[$i]=" due to options w/ identical name";
ErrTestHelp[$i]="func -i -i # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te46
enum=$MULO; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Option name collides with help
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # OHLP => MULO
ErrTestDsc2[$i]=" due to option collides with help";
ErrTestHelp[$i]="func -h # error ${ErrName[$enum]}";     # collides with help
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te47
enum=$MULO; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple end bgn markers found
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MULO
ErrTestDsc2[$i]=" due to pure & ship opt collision";
ErrTestHelp[$i]="func {-b}  {-b=} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]='-b5'; ErrTestOpts[$i]='-cb'; ((i++));   # -te48
enum=$MULO; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple end bgn markers found
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MULO
ErrTestDsc2[$i]=" due to pure & ship opt collision";
ErrTestHelp[$i]="func {-b=} {-b}  # error ${ErrName[$enum]}";
ErrTestCmdl[$i]='-b5'; ErrTestOpts[$i]='-cb'; ((i++));   # -te49

# MULP Parm names can collide several different ways
enum=$MULP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple output names are same
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MULP
ErrTestDsc2[$i]=" due to duplicate parameter names";
ErrTestHelp[$i]="func {name} {name} # error ${ErrName[$enum]} (collide with parm)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te50 [Warnings so make optional]
enum=$MULP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple output names are same
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MULP
ErrTestDsc2[$i]=" due to parm name & opt name same";
ErrTestHelp[$i]="func {-n} {_n} # error ${ErrName[$enum]} (collide with option)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te51 [Warnings so make optional]
enum=$MULP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Multiple output names are same
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MULP
ErrTestDsc2[$i]=" due to bgn & end parm names same";
ErrTestHelp[$i]="func {prm1} {-+} {-i} {prm1} # error ${ErrName[$enum]} (bgn & end parm collide)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te52

# OADD can fail with pure option, indp, OSIP, & SHIP after --
enum=$OADD; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # No Options after a double dash
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # OADD
ErrTestDsc2[$i]=" due to pure optn after end optns";
ErrTestHelp[$i]="func -- -i # error ${ErrName[$enum]} (pure opt)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-on'; ((i++));      # -te53
enum=$OADD; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # No Options after a double dash
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # OADD
ErrTestDsc2[$i]=" due to indp opt after end of opt";
ErrTestHelp[$i]="func {--} {-f file} # error ${ErrName[$enum]} (indp)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te54
enum=$OADD; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # No Options after a double dash
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # OADD
ErrTestDsc2[$i]=" due to OSIP being after end opts";
ErrTestHelp[$i]="func {-- -f=file} # error ${ErrName[$enum]} (OSIP)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te55
enum=$OADD; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # No Options after a double dash
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # OADD
ErrTestDsc2[$i]=" due to SHIP being after end opts";
ErrTestHelp[$i]="func {-- -f=} # error ${ErrName[$enum]} (SHIP)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te56

# PALT fails with alternate name and positional parm
enum=$PALT; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Params can't have an alt. name
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # PALT
ErrTestDsc2[$i]=" due to param having an alt. name";
ErrTestHelp[$i]="func {parm:altname} # error ${ErrName[$enum]} (Parm with altname)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te57
enum=$PALT; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Params can't have an alt. name
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # PALT
ErrTestDsc2[$i]=" due to OSIP prm having alt. name";
ErrTestHelp[$i]="func {-f=miles:altname} # error ${ErrName[$enum]} (Indp with altname)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));         # -te58

enum=$QUNF; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;    # Quoted string was not finished
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # QUNF
ErrTestDsc2[$i]=" due to a quote that's unfinished";
ErrTestHelp[$i]='func <-f=file_txt~np@num~"> # error QUNF (in GetQuote)';
ErrTestCmdl[$i]='-f=file.txt'; ErrTestOpts[$i]=''; ((i++)); # -te59

# RHLP (specification errors) option collides with defined help opt
enum=$RHLP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # Collides with defined help opt
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # RHLP
ErrTestDsc2[$i]=" option defined as '-h' collides";
ErrTestHelp[$i]="func {-h} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));       # -te60
enum=$RHLP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # Collides with defined help opt
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # RHLP
ErrTestDsc2[$i]=" opt defined as '--help' collides";
ErrTestHelp[$i]="func {--help} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));       # -te61

# RNAE (specification error)
enum=$RNAE; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # Range not allowed with extract
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # RNAE
ErrTestDsc2[$i]=" due to a extract exact N/A range";
ErrTestHelp[$i]='func <name~i@@5-7> # exact extract';
ErrTestCmdl[$i]='6'; ErrTestOpts[$i]=''; ((i++));      # -te62
enum=$RNAE; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # Range not allowed with extract
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # RNAE
ErrTestDsc2[$i]=" due to extract part is N/A range";
ErrTestHelp[$i]='func <name~i%%5-7> # part. extract';
ErrTestCmdl[$i]='6'; ErrTestOpts[$i]=''; ((i++));      # -te63

# SHOP (specification error)
enum=$SHOP; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # Unrecognized SHIP option found
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # SHOP
ErrTestDsc2[$i]=" due to unrecognized SHIP options";
ErrTestHelp[$i]='func {-d=.wx} # wrong SHIP options';
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));       # -te64

# TOSA verifies the internal counts match up (don't try to cause this)
# e.g.: 01 [TOSA]: Total Optimized size != to all: s/b=1, is=0 \
# [HvFcnNm=0, Empty=0, BgnPrm=0, Opts=0, EndPrm=0, HidPrm=0 (Indp=0)]
enum=$TOSA; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$FUTR; ErrTestFail[$i]=1;  # Total Optimized size != to all
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # TOSA
ErrTestDsc2[$i]=" due to array sizes are unmatched";
ErrTestHelp[$i]="-i  # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));       # -te65 [Reserved]

# CMDL N/A

# INDO test to show indparm option can't be combined with regular option combo
enum=$INDO; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # IndOptions can't be p/o combos
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # INDO
ErrTestDsc2[$i]=" pure & ind optn cannot be combos";
ErrTestHelp[$i]="func {-i}{-f indp} # error ${ErrName[$enum]}";
ErrTestCmdl[$i]='-if'; ErrTestOpts[$i]=''; ((i++));    # -te66

# OIND test failure case & success case
enum=$OIND; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # Old Style IndParam is disabled
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # OIND
ErrTestDsc2[$i]=" due to cmd-line OSIP is disabled";
ErrTestHelp[$i]="func {-i|n|-f=file} # error ${ErrName[$enum]} (OSIP p/o OR group cmdline fail)";
ErrTestCmdl[$i]='-f=valu'; ErrTestOpts[$i]='-ci'; ((i++));  # -te67

# MIOG can fail with multiple options and with a parm and order can matter also
# Note following no longer fails: "func -j m|-i|--input {post}" -j val -i
enum=$MIOG; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # More than 1 item in ORed group
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MIOG
ErrTestDsc2[$i]=" due to multiple mixed optns rcvd";
ErrTestHelp[$i]="func -i|m|--inp # error ${ErrName[$enum]} (multiple opts)";
ErrTestCmdl[$i]='-i --inp'; ErrTestOpts[$i]=''; ((i++));    # -te68
enum=$MIOG; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # More than 1 item in ORed group
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MIOG
ErrTestDsc2[$i]=" due to parm & optn in mixed rcvd";
ErrTestHelp[$i]="func m|-i|--input # error ${ErrName[$enum]} (bgn parm & opt)";
ErrTestCmdl[$i]='val -i'; ErrTestOpts[$i]=''; ((i++));      # -te69
enum=$MIOG; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # More than 1 item in ORed group
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MIOG
ErrTestDsc2[$i]=" due to parm & optn in mixed rcvd";
ErrTestHelp[$i]="func -j m|-i|--input # error ${ErrName[$enum]} (bgn parm & opts)";
ErrTestCmdl[$i]='val -j -i'; ErrTestOpts[$i]=''; ((i++));   # -te70
enum=$MIOG; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # More than 1 item in ORed group
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}";  # MIOG
ErrTestDsc2[$i]=" due to multiple indp are receive";
ErrTestHelp[$i]='func <-f|--files ifile tfile ofile> # more info'; ErrTestOpts[$i]='-ccs';
ErrTestCmdl[$i]='-f 1.txt 2.txt 3.txt --files in.txt tmp.txt out.txt'; ((i++));       # -te71
enum=$MIOG; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # More than 1 item in ORed group
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}";  # MIOG
ErrTestDsc2[$i]=" due to multiple opt in ORed rcvd";
ErrTestHelp[$i]="func <-f|--files ifile tfile ofile> # error ${ErrName[$enum]} (indp & indp)";
ErrTestCmdl[$i]='--files in.txt tmp.txt out.txt -f'; ErrTestOpts[$i]='-cs'; ((i++));  # -te72
enum=$MIOG; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;  # More than 1 item in ORed group
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}";  # MIOG
ErrTestDsc2[$i]=" due to multiple opt in ORed rcvd";
ErrTestHelp[$i]='func <-f|--files ifile tfile ofile> # more info';
ErrTestCmdl[$i]='-f in.txt tmp.txt out.txt --files'; ErrTestOpts[$i]='-ccs'; ((i++)); # -te73

# MSOR can occur 6 different ways
enum=$MSOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;        # Multiple same options received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MSOR
ErrTestDsc2[$i]=" due to same opt rcvd but not all";
ErrTestHelp[$i]="func {-j} {-i} # error ${ErrName[$enum]} (same opt not all)";
ErrTestCmdl[$i]='-i -i'; ErrTestOpts[$i]=''; ((i++));        # -te74
enum=$MSOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;        # Multiple same options received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MSOR
ErrTestDsc2[$i]=" due to same option but no others";
ErrTestHelp[$i]="func {-i} m # error ${ErrName[$enum]} (same opt no other opts)";
ErrTestCmdl[$i]='-i m -i'; ErrTestOpts[$i]=''; ((i++));      # -te75
enum=$MSOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;        # Multiple same options received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MSOR
ErrTestDsc2[$i]=" due to same indp item rcvd twice";
ErrTestHelp[$i]="func -f=file # error ${ErrName[$enum]} (multiple ind. parms)";
ErrTestCmdl[$i]='-f f1 -f f2'; ErrTestOpts[$i]=''; ((i++));  # -te76
enum=$MSOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;        # Multiple same options received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MSOR
ErrTestDsc2[$i]=" due to multiple end options rcvd";
ErrTestHelp[$i]="func {-i} m n # error ${ErrName[$enum]} (multiple end of opts)";
ErrTestCmdl[$i]='-i -- m -- n'; ErrTestOpts[$i]=''; ((i++)); # -te77
enum=$MSOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;        # Multiple same options received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MSOR
ErrTestDsc2[$i]=" due to combo & single optns rcvd";
ErrTestHelp[$i]="func {-i}{-j} # error ${ErrName[$enum]} (same combo opt repeated)";
ErrTestCmdl[$i]='-i -ji'; ErrTestOpts[$i]=''; ((i++));       # -te78
# Note this is correct for this case: 01 [MSOR]: Multiple same options received: -i @ 0 0
enum=$MSOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;        # Multiple same options received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MSOR
ErrTestDsc2[$i]=" due to repeated single combo opt";
ErrTestHelp[$i]="func {-i}{-j} # error ${ErrName[$enum]} (same single combo opt repeated)";
ErrTestCmdl[$i]='-iji'; ErrTestOpts[$i]=''; ((i++));         # -te79
enum=$MSOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;        # Multiple same options received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # MSOR
ErrTestDsc2[$i]=" due to repeated double combo opt";
ErrTestHelp[$i]="func -oa {-ob} # error ${ErrName[$enum]} (same double combo opt repeated)";
ErrTestCmdl[$i]='-oaba'; ErrTestOpts[$i]=''; ((i++));        # -te80

# PFER can happen many different ways
enum=$PFER; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Parameter format doesn't match
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # PFER
ErrTestDsc2[$i]=" due to bgn parm format not lower";
ErrTestHelp[$i]="func bgn~s- -o|lnk~s- end~s- # error ${ErrName[$enum]} (begin parm [1c])";
ErrTestCmdl[$i]='Bgn lnk end'; ErrTestOpts[$i]=''; ((i++));  # -te81
enum=$PFER; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Parameter format doesn't match
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # PFER
ErrTestDsc2[$i]=" due to mix parm format not upper";
ErrTestHelp[$i]="func bgn~s- -o|lnk~s+ end~s- # error ${ErrName[$enum]} (links parm [2f])";
ErrTestCmdl[$i]='bgn Lnk end'; ErrTestOpts[$i]=''; ((i++));  # -te82
enum=$PFER; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Parameter format doesn't match
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # PFER
ErrTestDsc2[$i]=" due to end parm format not lower";
ErrTestHelp[$i]="func bgn~s- -o|lnk~s- end~s- # error ${ErrName[$enum]} (trail parm [3c])";
ErrTestCmdl[$i]='bgn lnk End'; ErrTestOpts[$i]=''; ((i++));  # -te83
enum=$PFER; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Parameter format doesn't match
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # PFER
ErrTestDsc2[$i]=" due to ind parm format not lower";
ErrTestHelp[$i]="func -i=parm~s- # error ${ErrName[$enum]} (not all lowercase)";
ErrTestCmdl[$i]='-i Mixed'; ErrTestOpts[$i]=''; ((i++));     # -te84

# REQD can happen in 4 different ways
enum=$REQD; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Required item was not received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # REQD
ErrTestDsc2[$i]=" due to a missing required param.";
ErrTestHelp[$i]="func parm # error ${ErrName[$enum]} (miss required parm)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));        # -te85
enum=$REQD; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Required item was not received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # REQD
ErrTestDsc2[$i]=" due to a missing required option";
ErrTestHelp[$i]="func --long # error ${ErrName[$enum]} (miss required opts)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));        # -te86
enum=$REQD; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Required item was not received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # REQD
ErrTestDsc2[$i]=" due to a missing required indprm";
ErrTestHelp[$i]="func <-i in> # error ${ErrName[$enum]} (miss required ind optn)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));        # -te87
enum=$REQD; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Required item was not received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # REQD
ErrTestDsc2[$i]=" due to a missing required mixed ";
ErrTestHelp[$i]="func -a|-b|n # error ${ErrName[$enum]} (missing required mixed)";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));        # -te88

# RVOR can happen in several different ways
enum=$RVOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Received Value is Out of Range
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # RVOR
ErrTestDsc2[$i]=" due to an int parm out of range ";
ErrTestHelp[$i]="func parm~i@5-7 # error ${ErrName[$enum]} (out of range)";
ErrTestCmdl[$i]='4'; ErrTestOpts[$i]=''; ((i++));       # -te89
enum=$RVOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Received Value is Out of Range
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # RVOR
ErrTestDsc2[$i]=" due to positive percent rcvd neg";
ErrTestHelp[$i]="func -f=item~%+50 # error ${ErrName[$enum]} (invalid percent: neg s/b pos)";
ErrTestCmdl[$i]='-f -1'; ErrTestOpts[$i]=''; ((i++));   # -te90
enum=$RVOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Received Value is Out of Range
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # RVOR
ErrTestDsc2[$i]=" due to percent rcvd out of range";
ErrTestHelp[$i]="func -f=item~% # error ${ErrName[$enum]}   (invalid percent: out of range)";
ErrTestCmdl[$i]='-f 101'; ErrTestOpts[$i]=''; ((i++));  # -te91
enum=$RVOR; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Received Value is Out of Range
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # RVOR
ErrTestDsc2[$i]=" due to indparm percent range err";
ErrTestHelp[$i]="func -f=item~%10-50 # error ${ErrName[$enum]} (inv. percent: out of range)";
ErrTestCmdl[$i]='-f 5'; ErrTestOpts[$i]=''; ((i++));    # -te92

enum=$RWEV; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Received Wrong Enumerate Value
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # RWEV
ErrTestDsc2[$i]=" due to a bad received enum value";
ErrTestHelp[$i]="func parm~s@Mon@Tue@Thu # error ${ErrName[$enum]} (bad enum)";
ErrTestCmdl[$i]='Wed'; ErrTestOpts[$i]=''; ((i++));     # -te93
enum=$RWEV; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Received Wrong Enumerate Value
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # RWEV
ErrTestDsc2[$i]=" due to enums are N/A for partial";
ErrTestHelp[$i]="func <name~s%bgn@mid@end> # error ${ErrName[$enum]} (ENUM N/A for Partial)";
ErrTestCmdl[$i]='mid'; ErrTestOpts[$i]=''; ((i++));     # -te94

# SIPI has multiple failures points
enum=$SIPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Short Hand Ind Parm bad format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # SIPI
ErrTestDsc2[$i]=" due to received SHIP had letters";
ErrTestHelp[$i]="func -d= # error ${ErrName[$enum]} (letters)"; # SHIP item
ErrTestCmdl[$i]='-das'; ErrTestOpts[$i]=''; ((i++));    # -te95
enum=$SIPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Short Hand Ind Parm bad format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # SIPI
ErrTestDsc2[$i]=" due to rcvd SHIP w/ no lead zero";
ErrTestHelp[$i]="func -d= # error ${ErrName[$enum]} (non-int, no lead 0)";
ErrTestCmdl[$i]='-d.2'; ErrTestOpts[$i]=''; ((i++));    # -te96
enum=$SIPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Short Hand Ind Parm bad format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # SIPI
ErrTestDsc2[$i]=" due to SHIP combo is not allowed";
ErrTestHelp[$i]="func (-d= -e=) # error ${ErrName[$enum]} (SHIP combo N/A)";
ErrTestCmdl[$i]='-de5'; ErrTestOpts[$i]=''; ((i++));    # -te97
enum=$SIPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Short Hand Ind Parm bad format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # SIPI
ErrTestDsc2[$i]=" due to received SHIP double zero";
ErrTestHelp[$i]="func -d= # error ${ErrName[$enum]} (double 0)";
ErrTestCmdl[$i]='-d00'; ErrTestOpts[$i]=''; ((i++));    # -te98
enum=$SIPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Short Hand Ind Parm bad format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # SIPI
ErrTestDsc2[$i]=" due to received SHIP w/ 2 ranges";
ErrTestHelp[$i]="func -d= # error ${ErrName[$enum]} (2 ranges)";
ErrTestCmdl[$i]='-d1-3-5'; ErrTestOpts[$i]=''; ((i++)); # -te98
enum=$SIPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Short Hand Ind Parm bad format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # SIPI
ErrTestDsc2[$i]=" due to rcvd SHIP range w/ lead 0";
ErrTestHelp[$i]="func -d= # error ${ErrName[$enum]} (ranges lead 0)";
ErrTestCmdl[$i]='-d1-03'; ErrTestOpts[$i]=''; ((i++));  # -te99
enum=$SIPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Short Hand Ind Parm bad format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # SIPI
ErrTestDsc2[$i]=" due to rcvd SHIP enums w/ lead 0";
ErrTestHelp[$i]="func -d= # error ${ErrName[$enum]} (enums lead 0)";
ErrTestCmdl[$i]='-d1,03'; ErrTestOpts[$i]=''; ((i++));  # -te100
enum=$SIPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Short Hand Ind Parm bad format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # SIPI
ErrTestDsc2[$i]=" due to rcvd SHIP with doubledash";
ErrTestHelp[$i]="func -d= # error ${ErrName[$enum]} (-d=--)";
ErrTestCmdl[$i]='-d--'; ErrTestOpts[$i]=''; ((i++));    # -te101
enum=$SIPI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Short Hand Ind Parm bad format
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # SIPI
ErrTestDsc2[$i]=" due to rcvd SHIP with minus plus";
ErrTestHelp[$i]="func -d= # error ${ErrName[$enum]} (-d=-+)";
ErrTestCmdl[$i]='-d-+'; ErrTestOpts[$i]=''; ((i++));    # -te102

enum=$UMSG; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # User message is missing or bad
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # UMSG
ErrTestDsc2[$i]=" due to missing reqd User message";
ErrTestHelp[$i]="func   # error ${ErrName[$enum]}";
ErrTestCmdl[$i]=''; ErrTestOpts[$i]='-cu'; ((i++));     # -te103

enum=$UNKC; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Unknown combo opt was received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # UNKC
ErrTestDsc2[$i]=" due to rcvd unknown combo option";
ErrTestHelp[$i]="func {-i -j} # error ${ErrName[$enum]} (extra opt)";
ErrTestCmdl[$i]='-jin'; ErrTestOpts[$i]=''; ((i++));    # -te104

enum=$UNKI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Unknown parameter was received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # UNKI
ErrTestDsc2[$i]=" due to unknown option (w/o optn)";
ErrTestHelp[$i]="func  # error ${ErrName[$enum]} (without opt)";
ErrTestCmdl[$i]='-u'; ErrTestOpts[$i]=''; ((i++));      # -te105
enum=$UNKI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Unknown parameter was received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # UNKI
ErrTestDsc2[$i]=" due to unknown option (with opt)";
ErrTestHelp[$i]="func {-i} # error ${ErrName[$enum]} (with opt)";
ErrTestCmdl[$i]='-u'; ErrTestOpts[$i]=''; ((i++));      # -te106
enum=$UNKI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Unknown parameter was received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # UNKI
ErrTestDsc2[$i]=" due receiving unknown parameters";
ErrTestHelp[$i]="func   # error ${ErrName[$enum]}";
ErrTestCmdl[$i]='unkn'; ErrTestOpts[$i]=''; ((i++));    # -te107
enum=$UNKI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Unknown parameter was received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # UNKI
ErrTestDsc2[$i]=" due bad characters in opt's name";
ErrTestHelp[$i]="func -v # error ${ErrName[$enum]}";
ErrTestCmdl[$i]='-v:alt'; ErrTestOpts[$i]='-on'; ((i++)); # -te108
enum=$UNKI; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Unknown parameter was received
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # UNKI
ErrTestDsc2[$i]=" due string begin with opt's name";
ErrTestHelp[$i]="func -v # error ${ErrName[$enum]}"; # shouldn't be UNKC
ErrTestCmdl[$i]='-valt'; ErrTestOpts[$i]='-on'; ((i++));  # -te109

enum=$XNAM; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Exported Help var. name is bad
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # XNAM
ErrTestDsc2[$i]=" due to an undefined exported var";
ErrTestHelp[$i]=".";         # no varname was given
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));        # -te110
enum=$XNAM; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Exported Help var. name is bad
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # XNAM
ErrTestDsc2[$i]=" due to an undefined exported var";
ErrTestHelp[$i]=".HELP.VAR";  # not a valid varname
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));        # -te111
enum=$XNAM; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Exported Help var. name is bad
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # XNAM
ErrTestDsc2[$i]=" due to an undefined exported var";
ErrTestHelp[$i]=".__HELP__"; # collides with int. var: __HELP__
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));        # -te112
enum=$XNAM; printf -v estr "%02d" "$enum"; ErrTestEnum[$i]=$enum; ErrTestFail[$i]=1;   # Exported Help var. name is bad
ErrTestDesc[$i]="Error ${ErrName[$enum]} [$estr] : ${ErrText[$enum]}"; # XNAM
ErrTestDsc2[$i]=" due to an undefined exported var";
ErrTestHelp[$i]=".HELPVAR";  # not an exported var
ErrTestCmdl[$i]=''; ErrTestOpts[$i]=''; ((i++));        # -te113

# ZERR N/A (last error marker)
SizeErrTest=$((i-1)); # End of All the Tests : keep as the last line

#############################################################################
# TestOutputs : -to# (0 is all, "" is show descriptions)
# Here are all the basic test variations showing different levels of output
# going from most verbose to least verbose, showing without and with errors.
# Help HLPB has purposeful errors, while HLPG and HLPE are both good helps.
# NB: to do a comparison of getparms with a standard run (getparms.run0.txt),
# we must use the -cw config flag inorder to turn off wrapping of long lines.
# OutTestTst flag tells test routine if status must be checked & printed.
#
# Ensure DisplaySamples handles all configs: -c[abcehlnqrswt]
# verified following are all displayed opts: -c[abc  ln rswt]
# but specifically ignore following configs: -ce -ch
#############################################################################
t=1; # make all tests 1 based to match user input
HLPB='func <f_txt~s%~.txt> -v:verb|m~s-|--verb  -i {-j} [-m=indp] -e <-f|--files ifil tfil ofil> {--} {-l} <prm1~ip> [prm2~s- prm3]';
HLPE='func <f_txt~s%~.txt> -v:verb|m~s-|--verb  -i {-j} [-m=indp] -e <-f|--files ifil tfil ofil> {--} <prm1~ip> [prm2~sw- prm3]';
HLPG='func <f_txt~s%~.txt> -v:verb|m~sw-|--verb -i {-j} [-m=indp] -e <-f|--files ifil tfil ofil> {--} <prm1~ip> [prm2~sw- prm3]';
HLPM='func -i <-f=parm> multi ... # more info';

# begin tests
OutTestLin='#----------------------------------------------------------------------------';
declare -a OutTestLnA; declare -a OutTestLnB; declare -a OutTestLnC; declare -a OutTestBad;
declare -a OutTestHlp; declare -a OutHelpNam; declare -a OutTestCmd; declare -a OutTestTst;

OutTestLnA[$t]="# Test 01. Show the most verbose output with all debugging outputs enabled";
OutTestLnB[$t]="# then we will decrease output more and more concisely by changing configs";
OutTestLnC[$t]="";  OutTestHlp[$t]=$HLPE; OutHelpNam[$t]="HLPE"; OutTestTst[$t]=0; OutTestBad[$t]=0;
OutTestCmd[$t]='-d -on -cbcrsw -~ "$HLPE" file.txt happy -ji --files "in.txt" tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 01
OutTestLnA[$t]="# Test 02. Remove debug flag & see the intermediate debug info was removed";
OutTestLnB[$t]="# & also removal of the process ID at the end (used for temporary file us)";
OutTestLnB[$t]=""; # & also the total running time in seconds.ms (Tim2Adddn: .xxx) is removed";
OutTestLnC[$t]=""; OutTestHlp[$t]=$HLPG; OutHelpNam[$t]="HLPG"; OutTestTst[$t]=0; OutTestBad[$t]=0;
OutTestCmd[$t]='-on -cbcrsw -~ "$HLPG" file.txt happy -ji --files in.txt tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 02
OutTestLnA[$t]="# Test 03. Remove include row nums option (-cr) to drop leading row number";
OutTestLnB[$t]="# also any Leading underscores from dashed items' output names are dropped";
OutTestLnC[$t]="# & see the collision of the alt. name for -v with default name for --verb";
OutTestHlp[$t]=$HLPG; OutHelpNam[$t]="HLPG"; OutTestTst[$t]=0; OutTestBad[$t]=1;
OutTestCmd[$t]='-on -cbclsw -~ "$HLPG" file.txt happy -ji --files in.txt tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 03
OutTestLnA[$t]="# Test 04. Remove show starting processing (-cb) & Specified block is gone";
OutTestLnB[$t]="# Restore Leading underscores in option output names to remove a collision";
OutTestLnC[$t]=""; OutTestHlp[$t]=$HLPG; OutHelpNam[$t]="HLPG"; OutTestTst[$t]=0;  OutTestBad[$t]=0;
OutTestCmd[$t]='-on -ccsw -~ "$HLPG" file.txt happy -ji --files in.txt tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 04
OutTestLnA[$t]="# Test 05. Remove show output status of received command-line items (-cs)";
OutTestLnB[$t]="# causes leading status of each output row (e.g.: valid[1]: ) to be removed";
OutTestLnC[$t]=""; OutTestHlp[$t]=$HLPG; OutHelpNam[$t]="HLPG"; OutTestTst[$t]=0; OutTestBad[$t]=0;
OutTestCmd[$t]='-ccw -on -~ "$HLPG" file.txt happy -ji --files in.txt tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 05
OutTestLnA[$t]="# Test 06. Remove capture all command-line items, even if unchanged (-cc)";
OutTestLnB[$t]="# causes all the rows that have not been received to be removed (e.g.: __)";
OutTestLnC[$t]="# this without any errors is the least verbose mode available ('-co'|none)";
OutTestHlp[$t]=$HLPG; OutHelpNam[$t]="HLPG"; OutTestTst[$t]=0; OutTestBad[$t]=0;
OutTestCmd[$t]='-on -~ "$HLPG" file.txt happy -ji --files in.txt tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 06
OutTestLnA[$t]="# Test 07. Remove all received output status (-cq) only show func return";
OutTestLnB[$t]="# Note: all received items are no longer printed and thus can't be known";
OutTestLnC[$t]=""; OutTestHlp[$t]=$HLPG; OutHelpNam[$t]="HLPG"; OutTestTst[$t]=0; OutTestBad[$t]=0;
OutTestCmd[$t]='-cq -on -~ "$HLPG" file.txt happy -ji --files in.txt tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 07

# Conflicting display options
OutTestLnA[$t]="# Test 08. Add show output even if unchanged (-cc) overriding -cq option";
OutTestLnB[$t]="# Note: all received items are now printed, ignoring the quiet config opt";
OutTestLnC[$t]=""; OutTestHlp[$t]=$HLPG; OutHelpNam[$t]="HLPG"; OutTestTst[$t]=0; OutTestBad[$t]=0;
OutTestCmd[$t]='-ccq -on -~ "$HLPG" file.txt happy -ji --files in.txt tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 08

# Unique output with mult. indparm (file="f1=f2) and many parms" (allowed)
OutTestLnA[$t]="# Test 09. Unique output with multiple ind parms in same output variable";
OutTestLnB[$t]="# Notice _i & parm both show their statuses as 'multi' & parm='f1=f2=f3'";
OutTestLnC[$t]="# Not flagged as errors only because suppress errors on duplicates (-cd)";
OutTestHlp[$t]=$HLPM; OutHelpNam[$t]="HLPM"; OutTestTst[$t]=0; OutTestBad[$t]=0;
OutTestCmd[$t]='-crswd -on -~ "$HLPM" -i -f f1 -i -f f2 -f f3 val1 val2;';
((t++)); # 09

# Purposely an error (no -e) but shown with errors suppressed
OutTestLnA[$t]="# Test 10. Remove the make items without delimiters be optional (no: -on)";
OutTestLnB[$t]="# i.e. -v|m|--verb are now required, causing an error [return FAILURE=$UNFOUND]";
OutTestLnC[$t]=""; OutTestHlp[$t]=$HLPG; OutHelpNam[$t]="HLPG"; OutTestTst[$t]=0; OutTestBad[$t]=1;
OutTestCmd[$t]='-cw -~ "$HLPG" file.txt happy -ji --files in.txt tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 10
# Purposely an error (no -e) but shown with errors suppressed
OutTestLnA[$t]="# Test 11. Added suppress individual error messages (-cn) to remove error";
OutTestLnB[$t]="# messages so that only the function's result != 0 shows processing failed";
OutTestLnC[$t]=""; OutTestHlp[$t]=$HLPG; OutHelpNam[$t]="HLPG"; OutTestTst[$t]=0; OutTestBad[$t]=1;
OutTestCmd[$t]='-cnw -~ "$HLPG" file.txt happy -ji --files in.txt tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 11

OutTestLnA[$t]="# Test 12. Following is Analysis output with no errors: SUCCESS=0 [no out]";
OutTestLnB[$t]=""; OutTestLnC[$t]=""; OutTestHlp[$t]=$HLPG; OutHelpNam[$t]="HLPG";
OutTestTst[$t]=0;  OutTestBad[$t]=0;
OutTestCmd[$t]='-caw -~ "$HLPG" file.txt happy -ji -e --files in.txt tmp.txt out.txt 12 "all in" "all On";'
((t++)); # 12
OutTestLnA[$t]="# Test 13. Analysis with spec error [FAILURE=$MISORDR] & suppress all empty lines";
OutTestLnB[$t]=""; OutTestLnC[$t]=""; OutTestHlp[$t]=$HLPB; OutHelpNam[$t]="HLPB";
OutTestTst[$t]=0;  OutTestBad[$t]=1;
OutTestCmd[$t]='-ceaw -on -~ "$HLPB" file.txt happy -ji --files in.txt tmp.txt out.txt -- 12 "all in" "all On";'
((t++)); # 13
OutTestLnA[$t]="# Test 14. Analysis with spec error & errors suppressed [return FAILURE=$MISORDR]";
OutTestLnB[$t]=""; #"# Note: output line [FAILURE=$MISORDR] isn't output by getparms in this testcase";
OutTestLnC[$t]=""; OutTestHlp[$t]=$HLPB; OutHelpNam[$t]="HLPB"; OutTestTst[$t]=0; OutTestBad[$t]=1;
OutTestCmd[$t]='-canw -on -~ "$HLPB" file.txt happy -ji --files in.txt tmp.txt out.txt -- 12 "all in" "all On";'
((t++)); # 14 # previously had: OutTestTst[$t]=1; # for this, but no longer needed

OutTestNum=$((t-1)); # back up to last test [NB: getparms.sh can't see this value]

#############################################################################
# TestPrefers : -tp{n{-{m}}} checks prefs (-p) for the setting of symbols
# Use -ch to not show getparms help
#############################################################################
declare -a PreferDesc; declare -a PreferHelp; declare -a PreferFind; #SymNam;
declare -a PreferCmdl; declare -a PreferOpts; i=1; # 1-based tests (don't include ITEM_INVAL)

# begin tests
enum=$SYM_EOBP;    PreferEnum[$i]=$enum;  NUSYM="-:"; # EOBP="b" '-+'
printf -v SymNam "%-6s" "${SymExp[$enum]}"; # set spaced symbol name for new enum
PreferDesc[$i]="$SymNam (${SymCfg[$enum]}) dashcolon ($NUSYM) spec bgnprm";
PreferHelp[$i]="func prm1 {prm2} {-i}";
PreferFind[$i]='_i=1'; PreferCmdl[$i]='val $NUSYM -i';
PreferOpts[$i]="-pb$NUSYM -on -cbhrsw"; ((i++));      # -tp01|-tp1
enum=$SYM_EOBP;    PreferEnum[$i]=$enum;              # EOBP="b" '-+'
PreferDesc[$i]="$SymNam (${SymCfg[$enum]}) dashcolon ($NUSYM) cmdl bgnprm";
PreferHelp[$i]="func {$NUSYM}{prm} -- {i}";
PreferFind[$i]=''; PreferCmdl[$i]='-i';
PreferOpts[$i]="-pb$NUSYM -on -cbhrsw"; ((i++));      # -tp02|-tp2
# verify it also works even if it doesn't start with '-'
enum=$SYM_EOBP;    PreferEnum[$i]=$enum;  NUSYM="++"; # EOBP="b" '-+'
PreferDesc[$i]="$SymNam (${SymCfg[$enum]}) dbl. plus ($NUSYM) spec bgnprm";
PreferHelp[$i]="func prm1 {prm2} {-i}";
PreferFind[$i]='_i=1'; PreferCmdl[$i]='val $NUSYM -i';
PreferOpts[$i]="-pb$NUSYM -on -cbhrsw"; ((i++));      # -tp03|-tp3
enum=$SYM_EOBP;    PreferEnum[$i]=$enum;              # EOBP="b" '-+'
PreferDesc[$i]="$SymNam (${SymCfg[$enum]}) dbl. plus ($NUSYM) cmdl bgnprm";
PreferHelp[$i]="func {$NUSYM}{prm} -- {i}";
PreferFind[$i]=''; PreferCmdl[$i]='-i';
PreferOpts[$i]="-pb$NUSYM -on -cbhrsw"; ((i++));      # -tp04|-tp4

enum=$SYM_GRUP;    PreferEnum[$i]=$enum;     # GRUP="g" '|'
printf -v SymNam "%-6s" "${SymExp[$enum]}";  # set spaced symbol name for new enum
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to caret (^)  mixed & parm";
PreferHelp[$i]='func {-i^n^-j}';             # def: {-i|n|-j}
PreferFind[$i]=''; PreferCmdl[$i]='val';
PreferOpts[$i]='-pg^ -on -cbhrsw'; ((i++));  # -tp05|-tp5
enum=$SYM_GRUP;    PreferEnum[$i]=$enum;     # GRUP="g" '|'
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to caret (^)  mixed & optn";
PreferHelp[$i]='func {-i^n^-j}';             # def: {-i|n|-j}
PreferFind[$i]=''; PreferCmdl[$i]='-i';
PreferOpts[$i]='-pg^ -on -cbhrsw'; ((i++));  # -tp06|-tp6

enum=$SYM_ALTN;    PreferEnum[$i]=$enum;     # ALTN="a" ':'
printf -v SymNam "%-6s" "${SymExp[$enum]}";  # set spaced symbol name for new enum
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to caret (^) for pure optn";
PreferHelp[$i]='func {-i^altname|n|-j}';     # def: {-i:altname|n|-j}
PreferFind[$i]=''; PreferCmdl[$i]='-i';      # -tp07|-tp7
PreferOpts[$i]='-pa^ -on -cbhrsw'; ((i++));
enum=$SYM_ALTN;    PreferEnum[$i]=$enum;     # ALTN="a" ':'
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to caret (^) for SHIP optn";
PreferHelp[$i]='func {-d=^digit}';           # def: {-d=:digit}
PreferFind[$i]=''; PreferCmdl[$i]='-d4';
PreferOpts[$i]='-pa^ -on -cbhrsw'; ((i++));  # -tp08|-tp8

enum=$SYM_MORE;    PreferEnum[$i]=$enum;     # MORE="m" ...
printf -v SymNam "%-6s" "${SymExp[$enum]}";  # set spaced symbol name for new enum
PreferDesc[$i]="$SymNam ${SymCfg[$enum]}  to caret (^) for pos. parm";
PreferHelp[$i]='func {files ^}';             # def: {files ...}
PreferFind[$i]=''; PreferCmdl[$i]='file1 file2'; # -tp09|-tp9
PreferOpts[$i]='-pm^ -on -cbhrsw'; ((i++)); # -tp0|-tp
enum=$SYM_MORE;    PreferEnum[$i]=$enum;     # MORE="m" ...
PreferDesc[$i]="$SymNam ${SymCfg[$enum]}  to caret (^) for ind. parm";
PreferHelp[$i]='func {-f files ^}';          # def: {-f files ...}
PreferFind[$i]=''; PreferCmdl[$i]='-f file1 file2'; # -tp10
PreferOpts[$i]='-pm^ -on -cbhrsw'; ((i++));

enum=$SYM_ECMT;    PreferEnum[$i]=$enum;     # ECMT="e" '#'
printf -v SymNam "%-6s" "${SymExp[$enum]}";  # set spaced symbol name for new enum
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to C++  (//) w/end comment";
PreferHelp[$i]='func {-i} // more info';     # def.: {-i} # more info
PreferFind[$i]=''; PreferCmdl[$i]='-i';
PreferOpts[$i]='-pe// -on -cbhrsw'; ((i++)); # -tp11

# Note: added back MTCH since below would fail if '+' selected
enum=$SYM_RANG;    PreferEnum[$i]=$enum;     # RANG="r" '-'
printf -v SymNam "%-6s" "${SymExp[$enum]}";  # set spaced symbol name for new enum
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to comma (,) for pos. parm";
PreferHelp[$i]='func {int~i%0,3}';           # def: {int~i%0-3}
PreferFind[$i]=''; PreferCmdl[$i]='0';
PreferOpts[$i]='-pr, -on -cbhrsw'; ((i++));  # -tp12
enum=$SYM_RANG;    PreferEnum[$i]=$enum;     # RANG="r" '-'
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to comma (,) for ind. parm";
PreferHelp[$i]='func {-f int~i%0,3}';        # def: {-f int~i%0-3}
PreferFind[$i]=''; PreferCmdl[$i]='-f 3';
PreferOpts[$i]='-pr, -on -cbhrsw'; ((i++));  # -tp13

enum=$SYM_TYPE;    PreferEnum[$i]=$enum;     # TYPE="t" '~'
printf -v SymNam "%-6s" "${SymExp[$enum]}";  # set spaced symbol name for new enum
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to caret (^) for pos. parm";
PreferHelp[$i]='func {file_txt^s%^\.txt%pre\.^}'; # def. {file_txt~s%~\.txt%pre\.~}
PreferFind[$i]=''; PreferCmdl[$i]='pre.file';
PreferOpts[$i]='-pt^ -on -cbhrsw'; ((i++));  # -tp14
enum=$SYM_TYPE;    PreferEnum[$i]=$enum;     # TYPE="t" '~'
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to caret (^) for ind. parm";
PreferHelp[$i]='func {-f file_txt^s%^\.txt%pre\.^}'; # def. {-f file_txt~s%~\.txt%pre\.~}
PreferFind[$i]=''; PreferCmdl[$i]='-f pre.file';
PreferOpts[$i]='-pt^ -on -cbhrsw'; ((i++));  # -tp15

enum=$SYM_PLAN;    PreferEnum[$i]=$enum;     # XACT="p" '@'
printf -v SymNam "%-6s" "${SymExp[$enum]}";  # set spaced symbol name for new enum
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to period(.) for pos. parm";
PreferHelp[$i]='func {file_txt~s.~\.txt.pre\.~}'; # def.: {file_txt~s@~\.txt@pre\.~}
PreferFind[$i]=''; PreferCmdl[$i]='pre.file';
PreferOpts[$i]='-pp. -on -cbhrsw'; ((i++));  # -tp16

enum=$SYM_REGX;    PreferEnum[$i]=$enum;     # VALU="x" '%'
printf -v SymNam "%-6s" "${SymExp[$enum]}";  # set spaced symbol name for new enum
PreferDesc[$i]="$SymNam (${SymCfg[$enum]})  to caret (^) for pos. parm";
PreferHelp[$i]='func {file_txt~s^~\.txt^pre\.~}'; # def.: {file_txt~s%~\.txt%pre\.~}
PreferFind[$i]=''; PreferCmdl[$i]='pre.file';
PreferOpts[$i]='-px^ -on -cbhrsw'; ((i++));  # -tp17

SizePrefer=$((i-1)); # End of All the Tests : keep as the last line

#############################################################################
# TestInterns : -th# (0 is all, "" is show descriptions)
# As these are all internals, they are all prefixed with: getparms -x
# Following are special tests that don't call getparms.sh directly
# but some sub-function of it, in order to verify displayed output
#############################################################################
declare -a InternsDesc; declare -a InternsSrc1; declare -a InternsSrc2;
declare -a InternsFail; declare -a InternsOpts; declare -a InternsCmdl;
declare -a InternsNoEr; i=1; # 1-based tests

# begin tests
# verify warnings generated for sample file version mismatch
InternsDesc[$i]="Single test message for sample version mismatch";
InternsCmdl[$i]="getsample"; InternsOpts[$i]="-v 0.9.0 -sr";  # -s{c|o|d|e|v|f|a|r|m|s}
InternsSrc1[$i]="getparmstest.sh -x -sr"; InternsSrc2[$i]=""; # => getparms.sh -x -sr
InternsFail[$i]=1;  InternsNoEr[$i]=0; ((i++));  # -ti01|-ti1

InternsDesc[$i]="All of test message for sample version mismatch";
InternsCmdl[$i]="getsample"; InternsOpts[$i]="-v 0.9.0 -sa";  # -s{c|o|d|e|v|f|a|r|m|s}
InternsSrc1[$i]="getparmstest.sh -x -sa"; InternsSrc2[$i]=""; # => getparms.sh -x -sa
InternsFail[$i]=1;  InternsNoEr[$i]=0; ((i++));  # -ti02|-ti2

# verify no warnings generated for sample file version match
InternsDesc[$i]="Single test message for sample version matched";
InternsCmdl[$i]="getsample"; InternsOpts[$i]="-v $GETPARMS_VERS -sr";
InternsSrc1[$i]=""; InternsSrc2[$i]="";          # => getparms.sh -x -sr
InternsFail[$i]=0;  InternsNoEr[$i]=0; ((i++));  # -ti03|-ti3

InternsDesc[$i]="All of test message for sample version matched";
InternsCmdl[$i]="getsample"; InternsOpts[$i]="-v $GETPARMS_VERS -sa";
InternsSrc1[$i]=""; InternsSrc2[$i]="";          # => getparms.sh -x -sa
InternsFail[$i]=0;  InternsNoEr[$i]=0; ((i++));  # -ti04|-ti4

InternsDesc[$i]="Verify all debug codepoints are equally matched";
InternsCmdl[$i]="dbgenum"; InternsOpts[$i]="-v"; # getparms -x dbgenum -v;
InternsSrc1[$i]="success"; InternsSrc2[$i]="";
InternsFail[$i]=0;  InternsNoEr[$i]=0; ((i++));  # -ti05|-ti5

SizeInterns=$((i-1)); # End of All the Tests : keep as the last line

#############################################################################
# TestHelpOut : -th# (0 is all, "" is show descriptions)
# since no HelpOutHelp, have to make entire input line: $SYMB_SPEC "$help"
#############################################################################
declare -a HelpOutDesc; declare -a HelpOutSrc1; declare -a HelpOutSrc2;
declare -a HelpOutFail; declare -a HelpOutOpts; declare -a HelpOutHelp;
declare -a HelpOutNoFn; declare -a HelpOutNoEr; declare -a HelpOutExtl;
i=1; # 1-based tests

# begin tests
HelpOutDesc[$i]="Verify ignored optn";
HelpOutSrc1[$i]=""; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=0; HelpOutNoEr[$i]=0;
HelpOutHelp[$i]="func {-k}"; HelpOutOpts[$i]="";
HelpOutExtl[$i]=0; ((i++)); # -th1|-th01

# NB: put unknown option before -ch as this is the harder case
# and also catches to ensure we aren't breaking on first error
HelpOutDesc[$i]="Verify invalid optn";
HelpOutSrc1[$i]="Unknown item: -k"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=0;
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-k -ch";
HelpOutExtl[$i]=0; ((i++)); # -th2|-th02

HelpOutDesc[$i]="Verify version help";
HelpOutSrc1[$i]="$GETPARMS_VERS"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=0;
HelpOutHelp[$i]=""; HelpOutOpts[$i]="--version";
HelpOutExtl[$i]=0; ((i++)); # -th3|-th03

# Future
HelpOutDesc[$i]=""; HelpOutSrc1[$i]=""; HelpOutSrc2[$i]=""; # Future
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1;  HelpOutNoEr[$i]=1;  # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="";
HelpOutExtl[$i]=0; ((i++)); # -th4|-th04

HelpOutDesc[$i]="Verify feature help";
HelpOutSrc1[$i]="Advanced User Capabilities"; HelpOutSrc2[$i]="Why another bash";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=0;
HelpOutHelp[$i]=""; HelpOutOpts[$i]="--feature";
HelpOutExtl[$i]=0; ((i++)); # -th5|-th05

HelpOutDesc[$i]="Verify history help";
HelpOutSrc1[$i]="Functionality Added"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=0;
HelpOutHelp[$i]=""; HelpOutOpts[$i]="--history";
HelpOutExtl[$i]=0; ((i++)); # -th6|-th06

HelpOutDesc[$i]="Verify shorten help";
HelpOutSrc1[$i]="$TEST_BASE is "; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-help";
HelpOutExtl[$i]=0; ((i++)); # -th7|-th07

HelpOutDesc[$i]="Verify extendedhelp";
HelpOutSrc1[$i]="Overview: "; HelpOutSrc2[$i]="Escaping: ";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="--help";
HelpOutExtl[$i]=0; ((i++)); # -th8|-th08

HelpOutDesc[$i]="Verify ext function (-x)"; # NB: if is_number, "e.g. ..." still matchdata
HelpOutSrc1[$i]="matchdata";  HelpOutSrc2[$i]="e.g. call : $TEST_FILE -x matchdata";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-x";
HelpOutExtl[$i]=0; ((i++)); # -th9|-th09

HelpOutDesc[$i]="Verify help details (-d)";
HelpOutSrc1[$i]="debugging features";  HelpOutSrc2[$i]="Trace Init";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-d --help";
HelpOutExtl[$i]=0; ((i++)); # -th10

# handle variations of: PrintAllTypes  # no options
HelpOutDesc[$i]="Verify help datatyp (-ht)";
HelpOutSrc1[$i]="$DT_MNG"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-ht";
HelpOutExtl[$i]=0; ((i++)); # -th11

HelpOutDesc[$i]="Verify help datatyp (-h -t)";
HelpOutSrc1[$i]="$DT_MNG"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -t";
HelpOutExtl[$i]=0; ((i++)); # -th12

# handle variations of: PrintAllOption # no options
HelpOutDesc[$i]="Verify help opt|req (-ho)";
HelpOutSrc1[$i]="$OPTREQ"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1;
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-ho";
HelpOutExtl[$i]=0; ((i++)); # -th13

HelpOutDesc[$i]="Verify help opt|req (-h -o)";
HelpOutSrc1[$i]="$OPTREQ"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -o";
HelpOutExtl[$i]=0; ((i++)); # -th14

# handle variations of: PrintAllRtnErr & PrintAllErrMsg {-b|-r|-m}
HelpOutDesc[$i]="Verify help errored (-he)";
HelpOutSrc1[$i]="$RTNHDG";
HelpOutSrc2[$i]="${ErrText[$BERR]}";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-he";
HelpOutExtl[$i]=0; ((i++)); # -th15

HelpOutDesc[$i]="Verify help errored (-h -e)";
HelpOutSrc1[$i]="$RTNHDG";
HelpOutSrc2[$i]="${ErrText[$BERR]}";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1;
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -e";
HelpOutExtl[$i]=0; ((i++)); # -th16

HelpOutDesc[$i]="Verify help returns (-heb)";
HelpOutSrc1[$i]="$RTNHDG"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-heb";
HelpOutExtl[$i]=0; ((i++)); # -th17

HelpOutDesc[$i]="Verify help returns (-he -b)";
HelpOutSrc1[$i]="$RTNHDG"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1;
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-he -b";
HelpOutExtl[$i]=0; ((i++)); # -th18

HelpOutDesc[$i]="Verify help returns (-h -e -b)";
HelpOutSrc1[$i]="$RTNHDG"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -e -b";
HelpOutExtl[$i]=0; ((i++)); # -th19

HelpOutDesc[$i]="Verify help rev err (-her)";
HelpOutSrc1[$i]="${ErrText[$BERR]}"; HelpOutSrc2[$i]="<=";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-her";
HelpOutExtl[$i]=0; ((i++)); # -th20

HelpOutDesc[$i]="Verify help rev err (-he -r)";
HelpOutSrc1[$i]="${ErrText[$BERR]}"; HelpOutSrc2[$i]="<=";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-he -r";
HelpOutExtl[$i]=0; ((i++)); # -th21

HelpOutDesc[$i]="Verify help rev err (-h -e -r)";
HelpOutSrc1[$i]="${ErrText[$BERR]}"; HelpOutSrc2[$i]="<=";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -e -r";
HelpOutExtl[$i]=0; ((i++)); # -th22

HelpOutDesc[$i]="Verify help map err (-hem)";
HelpOutSrc1[$i]="$SPCMDL"; HelpOutSrc2[$i]="<=";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hem";
HelpOutExtl[$i]=0; ((i++)); # -th23

HelpOutDesc[$i]="Verify help map err (-he -m)";
HelpOutSrc1[$i]="$SPCMDL"; HelpOutSrc2[$i]="<=";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-he -m";
HelpOutExtl[$i]=0; ((i++)); # -th24

HelpOutDesc[$i]="Verify help map err (-h -e -m)";
HelpOutSrc1[$i]="$SPCMDL"; HelpOutSrc2[$i]="<=";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -e -m";
HelpOutExtl[$i]=0; ((i++)); # -th25

# handle variations of: PrintAllDebug -d {-s|-n}
# print debug enums: -n|-s num|headings only
HelpOutDesc[$i]="Verify help w/debug (-hd)";
HelpOutSrc1[$i]="Trace Analyzing the Spec"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hd";
HelpOutExtl[$i]=0; ((i++)); # -th26

HelpOutDesc[$i]="Verify help w/debug (-h -d)";
HelpOutSrc1[$i]="Trace Analyzing the Spec"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -d";
HelpOutExtl[$i]=0; ((i++)); # -th27

HelpOutDesc[$i]="Verify help w/debug (-hds)";
HelpOutSrc1[$i]="Groups of Tracing Enums"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hds";
HelpOutExtl[$i]=0; ((i++)); # -th28

HelpOutDesc[$i]="Verify help w/debug (-hd -s)";
HelpOutSrc1[$i]="Groups of Tracing Enums"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hd -s";
HelpOutExtl[$i]=0; ((i++)); # -th29

HelpOutDesc[$i]="Verify help w/debug (-h -d -s)";
HelpOutSrc1[$i]="Groups of Tracing Enums"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -d -s";
HelpOutExtl[$i]=0; ((i++)); # -th30

HelpOutDesc[$i]="Verify help w/debug (-hdn)";
HelpOutSrc1[$i]="99"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hdn";
HelpOutExtl[$i]=0; ((i++)); # -th31

HelpOutDesc[$i]="Verify help w/debug (-hd -n)";
HelpOutSrc1[$i]="99"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hd -n";
HelpOutExtl[$i]=0; ((i++)); # -th32

HelpOutDesc[$i]="Verify help w/debug (-h -d -n)";
HelpOutSrc1[$i]="99"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -d -n";
HelpOutExtl[$i]=0; ((i++)); # -th33

# handle variations of: PrintAllDebug -da # set enum range
HelpOutDesc[$i]="Verify help w/debug (-hda)";
HelpOutSrc1[$i]="Trace Analyzing"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hda";
HelpOutExtl[$i]=0; ((i++)); # -th34

HelpOutDesc[$i]="Verify help w/debug (-h -da)";
HelpOutSrc1[$i]="Trace Analyzing"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -da";
HelpOutExtl[$i]=0; ((i++)); # -th35

# handle variations of: PrintAllDebug -db # set enum range
HelpOutDesc[$i]="Verify help w/debug (-hdb)";
HelpOutSrc1[$i]="Trace Boxing"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hdb";
HelpOutExtl[$i]=0; ((i++)); # -th36

HelpOutDesc[$i]="Verify help w/debug (-h -db)";
HelpOutSrc1[$i]="Trace Boxing"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -db";
HelpOutExtl[$i]=0; ((i++)); # -th37

# handle variations of: PrintAllDebug -dc # set enum range
HelpOutDesc[$i]="Verify help w/debug (-hdc)";
HelpOutSrc1[$i]="Trace Command Line"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hdc";
HelpOutExtl[$i]=0; ((i++)); # -th38

HelpOutDesc[$i]="Verify help w/debug (-h -dc)";
HelpOutSrc1[$i]="Trace Command Line"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -dc";
HelpOutExtl[$i]=0; ((i++)); # -th39

# handle variations of: PrintAllDebug -dd # set enum range
HelpOutDesc[$i]="Verify help w/debug (-hdd)";
HelpOutSrc1[$i]="Trace Delivery"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hdd";
HelpOutExtl[$i]=0; ((i++)); # -th40

HelpOutDesc[$i]="Verify help w/debug (-h -dd)";
HelpOutSrc1[$i]="Trace Delivery"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -dd";
HelpOutExtl[$i]=0; ((i++)); # -th41

# handle variations of: PrintAllDebug -d_ # set enum range
HelpOutDesc[$i]="Verify help w/debug (-hd_)";
HelpOutSrc1[$i]="Trace Init"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-hd_";
HelpOutExtl[$i]=0; ((i++)); # -th42

HelpOutDesc[$i]="Verify help w/debug (-h -d_)";
HelpOutSrc1[$i]="Trace Init"; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="-h -d_";
HelpOutExtl[$i]=0; ((i++)); # -th43

# Test variations of setting Help options

# help option setting normal: -? "-g|--info"
HelpOutDesc[$i]='Help option normal  -? "-g|--info"';
HelpOutSrc1[$i]='"-g|--info"';  HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]="func"; HelpOutOpts[$i]='-cb -? "-g|--info"';
HelpOutExtl[$i]=0; ((i++)); # -th44

# help option setting abuts:  -?"-g|--info"
HelpOutDesc[$i]='Help option abutted -?"-g|--info"';
HelpOutSrc1[$i]='"-g|--info"';  HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]="func"; HelpOutOpts[$i]='-cb -?"-g|--info"';
HelpOutExtl[$i]=0; ((i++)); # -th45

# help option setting second: -?"--info"
HelpOutDesc[$i]='Help option w/ 2nd  -?"--info"';
HelpOutSrc1[$i]='"--info"';  HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]="func"; HelpOutOpts[$i]='-cb -?"--info"';
HelpOutExtl[$i]=0; ((i++)); # -th46

# help option setting first: -?"-g"
HelpOutDesc[$i]='Help option w/ 1st  -?"-g"';
HelpOutSrc1[$i]='"-g"';  HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]="func"; HelpOutOpts[$i]='-cb -?"-g"';
HelpOutExtl[$i]=0; ((i++)); # -th47

# -?"" -~ # empty help
HelpOutDesc[$i]='Help option empty1  -?""';
HelpOutSrc1[$i]='""';  HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]="func"; HelpOutOpts[$i]='-cb -?""';
HelpOutExtl[$i]=0; ((i++)); # -th48

# -? -~ # no help
HelpOutDesc[$i]='Help option empty2  -?';
HelpOutSrc1[$i]='""';  HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]="func"; HelpOutOpts[$i]='-cb -?';
HelpOutExtl[$i]=0; ((i++)); # -th49

# Note: this test is taking 12.25 seconds [keep last]
HelpOutDesc[$i]="Verify sample help";
HelpOutSrc1[$i]="# Test 01."; HelpOutSrc2[$i]="";
HelpOutFail[$i]=0;  HelpOutNoFn[$i]=1; HelpOutNoEr[$i]=1; # skip
HelpOutHelp[$i]=""; HelpOutOpts[$i]="--examples";
HelpOutExtl[$i]=1; ((i++)); # -th50

SizeHelpOut=$((i-1)); # End of All the Tests : keep as the last line

#############################################################################
# TestTimings : -tt# (0 is all, "" is show descriptions)
# Tests are approximately arranged in order of speed: fastest first
# NB: for testing purposes only, the parm name is defaulted to 'name'
# NB: based on experimentation it takes 90+ runs to see a <= +|-10 ms
# difference in execution times (but takes too long)
#############################################################################
declare -a TimedDesc; declare -a TimedParm; declare -a TimedOpts;
TimedRuns=20; i=1; # 1-based tests

# begin tests # getparms -~ 'func p1 # Parms ' a => 0.322
# Parm Timed Tests --------------------------------------------------------
TimedDesc[$i]="func p1 p2 p3 p4 p5      # Parms ";
TimedOpts[$i]=""; TimedParm[$i]="a b c d e";
((i++)); # -tt1|-tt01 => 0.386

# SHIP Timed Tests --------------------------------------------------------
TimedDesc[$i]="func -i= -j= -k= -l= -m= # SHIPs ";
TimedOpts[$i]=""; TimedParm[$i]="-m=5 -l=4 -k=3 -j=2 -i1";
((i++)); # -tt2|-tt02 => 0.411

# Combo Timed Tests --------------------------------------------------------
TimedDesc[$i]="func -i -j -k -l -m      # Combo ";
TimedOpts[$i]=""; TimedParm[$i]="-ji -lmk";
((i++)); # -tt3|-tt03 => 0.412

# Optn Timed Tests --------------------------------------------------------
TimedDesc[$i]="func -i -j -k -l -m      # Optns ";
TimedOpts[$i]=""; TimedParm[$i]="-m -l -k -j -i";
((i++)); # -tt4|-tt04 => 0.427

# OSIP Timed Tests --------------------------------------------------------
TimedDesc[$i]="func -i=p1 -j=p2 -k=p3 -l=p4 -m=p5 # OSIPs ";
TimedOpts[$i]=""; TimedParm[$i]="-m=e -l=d -k=c -j=b -i=a";
((i++)); # -tt5|-tt05 => 0.453

# Indp Timed Tests --------------------------------------------------------
TimedDesc[$i]="func -i=p1 -j=p2 -k=p3 -l=p4 -m=p5 # Indps ";
TimedOpts[$i]=""; TimedParm[$i]="-m e -l d -k c -j b -i a";
((i++)); # -tt6|-tt06 => 0.453

# Complexity Tests --------------------------------------------------------
TimedDesc[$i]='func <file_txt~sj+-%~".Txt"> -v:verb|m~h|--verb {-in} {-io} -i {-j} [-m=ind_parm] -e <-f|--files ifile tfile ofile> {--} <param1~ip> [param2 param3~sw-] # Combined case: multi-combo';
TimedParm[$i]='file.txt 0x3A  -ji -ion -e --files in.txt tmp.txt out.txt 12 "all In" "all on"';
TimedOpts[$i]='-crs -on'; ((i++)); # -tt7|-tt07 => 0.644

((Timed=i-1)); # back up to last test

#############################################################################
# End Test Arrays - begin Code: start functions
#############################################################################

#############################################################################
# Catching intermittent bugs in Test All is difficult as the loops cannot be
# broken out of, in that case when failure occurs add: FailAll "msg"; break;
#############################################################################
function  FailAll() { # FailAll {"msg"}
    local msg="*****CAUGHT BUG!!!!*********"; if [[ "$1" ]]; then msg="$@"; fi
    printf "%s\n" "$msg" >&2; touch "$TEST_QUIT";
}

###########################################################################
# Helper Functions
# result prints out in number form or in string form the results of last
# command & forwards this status, so next user can also grab status if needed
# NB: in agreement with getparms, using ErrDetail instead of ErrorMsg
###########################################################################
function avgtime() { local HELP="avgtime {-t}{-v}{-#}{-s|-u|-a} cmd opts # def. real time, -s=system, -u=user, -a=all; -t trace, -v verbose";
    local trc=0;  if [[ "$1" == -t ]]; then trc=1; shift; fi
    local vrb=0;  if [[ "$1" == -v ]]; then vrb=1; shift; fi
    local max=10; if [[ "$1" == -* ]] && [[ "$1" =~ ^-[0-9]*$ ]]; then max=${1:1}; shift; fi
    local flag; local opt="real";
    if [[ "$1" == -* ]]; then flag="$1"; shift; case "$flag" in
        -s) opt="sys ";;
        -r) opt="real";;
        -u) opt="user";;
        -a) opt="all ";;
        -h) echo "$HELP" >&2; return $FAILURE;;
        -*) echo "$HELP: bad opt=$flag" >&2; return $FAILURE;;
    esac; fi;  if  ((max == 0)) || (($# == 0)) || [[ "$1" == -* ]];
    then  echo "$HELP: bad opt=$flag" >&2;   return $FAILURE; fi

    local prt=""; if ((vrb == 1)); then prt="$opt: "; fi
    local name; local real; local user; local sys; # order of time outputs
    cdebug on "$trc";
    { read name real; read name user; read name sys; } < <(
        { time -p while ((max--)); do { "$@" &>/dev/null; }; done; } 2>&1
    )
    case "$opt" in # Note: for all we must print labels to know what's what (ignore -v in this case)
    "all ") printf "real: %.3f\nuser: %.3f\nsys : %.3f\n" $(bc -l <<<"$real/$max;$user/$max;$sys/$max;" );;
    "real") printf "%s%.3f\n" "$prt"                      $(bc -l <<<"$real/$max;" );;
    "user") printf "%s%.3f\n" "$prt"                      $(bc -l <<<"$user/$max;" );;
    "sys ") printf "%s%.3f\n" "$prt"                      $(bc -l <<<"$sys/$max;"  );;
    esac; cdebug no "$trc";
} # NB: accuracy for this is method limited to 10ms
#export -f avgtime

function  result()  { # result $?  {-n}{-#|-a|-d} # -a all, -d detail, -n no c/r, -# prints no. (vs. msg.)"
    local sts=$1; shift; # first, get last command status b4 you do anything else!
    local         HELP="result sts {-n}{-#|-a|-d} # -a all, -d detail, -n no c/r, -# prints no. (vs. msg.)"
    local cr="$CR"; local all=0; local det=0; local num=0; # set defaults
    while [ $# -gt 0 ]; do local opt="$1"; shift; # get all inputs
    case "$opt" in
    -a)   all=1;;  # show all errors
    -d)   det=1;;  # show err detail (overrides -n)
    -n)   cr=" ";; # suppress <c/r>
    "-#") num=1;;  # show number only
    *)    echo "$HELP" >&2; return $sts;; # preserve original status
    esac; done

    if  ((all == 1)); then # ignore if -# and/or -n also rcvd
    for ((ic=SUCCESS; ic <= UNKNOWN; ic++)); do if ((det == 1));
        then printf "${ErrorStr[$ic]} : ${ErrDetail[$ic]}$CR";
        else printf "${ErrorStr[$ic]}=$ic$CR"; fi
    done
    elif ((det == 1)); then if ((sts <= UNKNOWN));
        then printf "${ErrorStr[$sts]} : ${ErrDetail[$sts]}$cr";
        else printf "${ErrorStr[$UNKNOWN]}=$sts$cr"; fi
    elif ((num == 1)); then printf "%d$cr" "$sts"; # prints status num only
    elif ((sts <= UNKNOWN));
        then printf "${ErrorStr[$sts]}$cr";
        else printf "${ErrorStr[$UNKNOWN]}=$sts$cr";
    fi; return $sts; # give same status as original command
} # end result

###########################################################################
# Print Descrips prints the summary for the specified tests using its arrays
# -ta uses -a in order to only print the Group test summaries, while
#  -a prints the Group summary & then all test summaries in each group.
# This function is N/A for -tr as those helps strings are built on-the-fly.
# Note: -d before array1 indicates a second description line
# Passed a 0-based array, but looking at 1+ when:
# -ta should start with TestFeature (so need ic-1)
# -a & one=0 start with TestFeature (so need ic-1)
# Note: presently no one is using -d, only -ds, but functionality remains
###########################################################################
function  PrintDescrips() { # PrintDescrips {-a|-ta} opt min max array0 {-d{s} array1} array2} # show test descriptions
    local lead="Test ";  local all=0; local ndx; local ic;
    local d2=0; local got=0; local opt; local optn; local skp=0;
    if   [[ "$1" ==  -a ]]; then all=1; lead="Group"; opt=$1; shift; got=1;
    elif [[ "$1" == -ta ]]; then all=2; lead="Group"; opt=$1; shift; got=1; echo;
    elif [[ "$1" == -to ]]; then skp=1; fi
    if   ((got == 0)); then opt=$1; shift; fi
    local min=$1; local max=$2; shift 2;
    local one=0;  if ((max == min)); then one=1; fi
    local ArrNam0=$1[@]; local Array0=("${!ArrNam0}"); shift;
   #echo "ArrNam=$ArrNam0: one=$one, min|max: $min|$max, all:$all"
    local maxNum=${#Array0[@]}; local dig=2; if ((maxNum > 99)); then dig=3; fi

    local ArrNam1=""; local ArrNam2=""; local Array1; local Array2;
    if [[ "$1" == -d* ]]; then d2=$1; shift;  ArrNam1=$1[@]; Array1=("${!ArrNam1}"); shift; fi
    local desc; local dsc2; local numXtra=$#; # record if any more
    if  ((numXtra != 0)); then ArrNam2=$1[@]; Array2=("${!ArrNam2}"); fi

    # NB: divider lines here for -a are before & after Group #
    local lldr; local ldr; # following works for: -a
    if  ((one != 0)); then printf "%s\n" "$Divider"; fi
    local off=0;  if ((one == 0)) && ((all != 2)); then off=1; fi
    for ((ic=min; ic <= max; ic++)); do ndx=$((ic-off)); desc="${Array0[$ndx]}";
        if  [[ !  "$desc" ]] || ( ((numXtra == 1)) && [[ "${Array2[$ndx]}" == 0 ]] );
        then continue; fi; dsc2="${Array1[$ndx]}";  # undef. enum
        printf -v ldr "%s %${dig}d: " "$lead" "$ic";
        if  [[ "$dsc2" ]] && [[ "$d2" == -d ]]; then
             printf "%s%s (%s)\n" "$ldr" "$desc" "$opt"; # -ds only prints this line
             lldr="${#ldr}"; printf "%"$lldr"s%s\n" " " "$dsc2";
        elif ((got == 1)); then optn="${AllOptns[$ic]}";
             if [[ "$optn" == -to ]]; then skp=1; else skp=0; fi
             printf "%s%s (%s)\n" "$ldr" "$desc" "$optn";
        else printf "%s%s%s\n" "$ldr" "$desc" "$dsc2"; fi # -ds only prints this line
    done; if ((one == 0)); then echo; elif ((skp == 0)); then printf "%s\n" "$Divider"; fi
} # end Print Descrips

###########################################################################
# Print Headers for examples is done by Test Example (not here)
# Note: these must not print to error & shouldn't print if doeg == 1
###########################################################################
function  PrintHeaders() { # PrintHeaders name optn numb doeg
    local name="$1"; local optn=$2; local numb=$3; local doeg=$4; shift 4;
    if  [[ "$doeg" != 1 ]]; then printf "%s\n" "$Divider";
        printf "# Rerun %s ($optn): run %d tests\n" "$name" "$numb";
    fi
}

###########################################################################
# Print Failures is the summary output after all the subtests are done
# Note: Print Failures not used for examples
###########################################################################
function  PrintFailures() {  # PrintFailures "name" opt nbfail tests failitems
    local name="$1";  local opt=$2; local fail="$3";
    local tests="$4"; local failed="$5";  shift 5;
    if  ((fail == 0)); # failitems starts with a space (if not empty), align w/: "Running "
    then printf "$PASS %s ($opt$run): tests run %3d\n\n" "$name" "$tests" >&2; return $SUCCESS;
    else printf "$FAIL %s ($opt$run): tests run %3d"     "$name" "$tests" >&2;
         printf " and %-2d failed: %s\n\n" "$fail" "$failed" >&2; return $FAILURE; fi
}

###########################################################################
# Print Results  uses the failure file & can change passed to failed
#                if the proper error is not found, hence it must return
#                this case an an error=1; -n is don't find
###########################################################################
function  PrintResults() { # {-x}{-v}{-s}{-p prefix}{-f find}{-r{res}} ic fail failed "itm1" {-i|-n "itm2"} hvit prtdbg array # -prints by item (1 item/line), -v verbose cats file, -s skip output if err
    # cdebug on; # NB: ic presently not used but may be useful in future, so keep
    local exam=0;  if [[ "$1" == -x  ]]; then exam=1;    shift 1; fi
    local verb=0;  if [[ "$1" == -v  ]]; then verb=1;    shift 1; fi
    local skip=0;  if [[ "$1" == -s  ]]; then skip=1;    shift 1; fi
    local pref=""; if [[ "$1" == -p  ]]; then pref="$2"; shift 2; else pref="result:"; fi
    local find=""; if [[ "$1" == -f  ]]; then find="$2"; shift 2; fi
    local rslt=""; if [[ "$1" == -r* ]]; then rslt="${1:2}"; shift;
          if [[ "$rslt" ]]; then rslt="[$rslt]"; fi
    fi
    local ic=$1;   local fail=$2; local failed=$3; local itm1="$4"; shift 4;
    local is_fail=$((fail != 0));
    local itm2=""; if [[ "$1" == -i ]]; then itm2="$2"; shift 2; fi
    local none=""; if [[ "$1" == -n ]]; then none="$2"; shift 2; fi
    local hvit=$1; local prtdbg=$2; shift 2;
    local errd=$((failed == 0 ? 0 : 1)); # errd = 0|1
    local exp="";  if ((fail == 0)); then exp="pass"; else exp="fail"; fi
    local rstr="rcvd status"; local fstr="$failed"; local need=0;
    local sstr=""; local sts=0; local nodt=0; local unfd=0; local line;

    # check for find strings in tmp file if a failure case & we haven't found it
    if    [[ "$itm1" ]] && [[ "$itm2" ]]; then need=3;
    elif  [[ "$itm2" ]]; then need=2;
    elif  [[ "$itm1" ]]; then need=1; fi

    if  ((failed != 0)) && ((need != hvit)) && [[ "$find" ]]; then unfd=1;
        if [ -s "$TEST_FTMP" ]; then # previously had at start: [0-9][0-9]
            if grep -q "$find" "$TEST_FTMP"; then unfd=0; fi # was: -E -m 1
        fi; if ((unfd == 1)); then rstr="err unfound"; fstr="$find";
        else   hvit=$((hvit | 1)); fi # found it in error file
    fi

    # check if failure due to unfound value
    if  [[ "$itm1" ]] && (((hvit & 1) == 0));
    then nodt=1; fstr="";  rstr="unfound";  sstr="$itm1 "; fi
    if  [[ "$itm2" ]] && (((hvit & 2) == 0));
    then nodt=1; fstr="";  rstr="unfound"; sstr+="$itm2 "; fi
    if  [[ "$none" ]] && (((hvit & 4) == 1));
    then nodt=1; fstr=""; rstr+="rxd val";  sstr+="$none "; fi

    # catch all cases where it looks like it passed but didn't
    local err=$(( (is_fail != errd) || (unfd == 1) || (nodt == 1) ? 1 : 0 ));
    if  ((err == 1)); then sts=$FAILURE;
         if ((exam == 0)); then printf "$pref FAILED Expected $exp [%s=%s] %s!\n" "$rstr" "$fstr$sstr" "$rslt"; fi
    else if ((exam == 0)); then printf "$pref Passed Expected $exp [%s=%s] %s \n" "$rstr" "$fstr$sstr" "$rslt"; fi; fi

    if  ((skip == 0)); then  # sometimes we don't want to print long error files
        if  [[ ! "$prtdbg" =~ ^[0-1]$ ]]; then prtdbg=1; fi
        if  ( ((exam == 1)) || ((prtdbg == 1)) || ((is_fail != errd)) ); then # get rest of inputs into array
            declare -a arr=("${@}"); local i; # show the status: func=nn
            for ((i=0; i < ${#arr[@]}; i++)); do line="${arr[$i]}";
                printf -- "%s\n" "$line";
            done
        fi  # conditionally cat temporary file if debug or error or verbose mode
        if  ((exam == 0)) && ( ((prtdbg == 1)) || ((err == 1)) || ((verb == 1)) ); then # only cat if exists & nonzero
            # no need to print empty lines when showing errors
            # don't know if caller used -ce or not, so must grep out
            if  [ -s "$TEST_FTMP" ]; then grep -E -v '^[[:space:]]*$' "$TEST_FTMP"; fi
        fi
    fi; # cdebug no
    return $sts;
} # end Print Results

#############################################################################
# Start of Sub-Tests: getparms examples per Ex_Tests: TestConfigs, TestFeature,
# TestVariety, TestDataTyp, TestStrType, TestReqOpts, TestMatches, TestOutputs
#############################################################################

###########################################################################
# Test Configs: -tc{n{-{m}}} where n=0 is all, "" description, else test no. n
# Test Descrip prints out the list of tests for those with descriptions
# Added rslt flag & empt+optn (to check no echo) & none+need
###########################################################################
function TestConfigs() { local HELP="TestConfigs {-x}{-v}{-d*} -tf{n{-{m}}} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range # Self-Test of Configs";
    local opt=""; local dbg=""; local prtdbg=0; local nohlp=0; local vrb="";
    local bgn=1;  local end=$SizeConfigs; declare -a args; declare -a cmds;
    local doeg=0; local iseg; local lead="test"; local exm=""; local num;
    if     [[ "$1" == -x  ]]; then doeg=1; exm=$1; shift; lead="# example "; fi
    if     [[ "$1" == -v  ]]; then vrb="$1"; shift; fi
    if     [[ "$1" == -d  ]]; then dbg="$1 "; prtdbg=1; shift; fi
    while  [[ "$1" == -[doc]* ]];
    do  if [[ "$1" == -c* ]] && [[ "$1" == *h* ]]; then nohlp=1; fi;
        dbg+="$1 "; shift;
    done

    local tst=$1; shift; # keep a record of it
    if [[ "$1"   ==  -* ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    # Note: when only printing descriptions Dsc2 goes after Desc
    if [[ "$tst" == -tc ]]; then PrintDescrips "$tst" 1 $SizeConfigs "ConfigsDesc" -ds "ConfigsDsc2"; return; fi
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else return $FAILURE; fi # can't go on

    local sts=$SUCCESS; rm -f "$TEST_FTMP";  # remove old temp test file (where we write errors)
    local fails=0;  local failures=""; local ic; local tests=0;
    local fail; local opts; local find; local hvit; local umsg;
    local cmdl; local help; local errd; local dsc2;
    local empt; local rslt; local none; local need; local lldr;
    local ldr;  local restore; local nohelp;
   #if  ((nohlp == 0)); then opt+="-ch"; fi # suppress HELP output

    PrintHeaders "TestConfigs" "$tst" "$num" "$doeg";
    for ((ic=bgn; ic <= end; ic++)); do restore=0; nohelp=0; cdebug on "$vrb";
        help="${ConfigsHelp[$ic]}";  opts="${ConfigsOpts[$ic]}";
        if [[ "$opts" == *"$CF_RSLT"* ]]; then restore=1; fi
        if [[ "$opts" == "$HELPNO"* ]];   then nohelp=1; fi
        if [[ ! "$help" ]] && ((restore == 0)) && ((nohelp == 0));
        then continue; else ((tests++)); fi # skip future tests
        iseg="${ConfigsIsEg[$ic]}";  if ((doeg == 1)) && ((iseg == 0)); then continue; fi
        desc="${ConfigsDesc[$ic]}";  dsc2="${ConfigsDsc2[$ic]}";
        cmdl="${ConfigsCmdl[$ic]}";  fail="${ConfigsFail[$ic]}";
        find="${ConfigsFind[$ic]}";  umsg="${ConfigsUMsg[$ic]}";
        rslt="${ConfigsRslt[$ic]}";  none="${ConfigsNone[$ic]}";
       #item=${find/=*/}; # get item name
        # needs "# example n ", not "# example  n" for ease of finding
        printf -v num "%-2s"   "$ic";  printf "%s\n" "$Divider";
        printf -v ldr "%s%s: " "$lead" "$num"; lldr="${#ldr}";
        # we'd like to move Dsc2 after help, but we don't always have 1, so leave here
        printf "%s%s%s\n" "$ldr" "$desc" "$dsc2"; local tmpc="";
       #if ((doeg == 1)); then printf "%s\n" "$Divider"; fi
        if ((doeg == 0)); then tmpc="cmdl$num: "; fi
        if   [[ "$umsg" ]]; then
        if   [[ "$opts" == *$USRMSG* ]];   # [1] -cu "message"; else: [2a] -cu="message" | [2b] -cu"message"
        then printf "%s$TEST_FILE %s '%s' $SYMB_SPEC '%s' %s\n" "$tmpc" "$dbg$opt$opts" "$umsg" "$help" "$cmdl" | \
             Indent -a -c1 -i 0 -m 112;    # NB: no indent, single continuation char.
        else printf "%s$TEST_FILE %s%s $SYMB_SPEC '%s' %s\n"    "$tmpc" "$dbg$opt$opts" "$umsg" "$help" "$cmdl" | \
             Indent -a -c1 -i 0 -m 112; fi # NB: no indent, single continuation char.
        elif ((restore == 1)) || ((nohelp == 1));               # special cases: restore & nohelp
        then printf "%s$TEST_FILE %s %s\n"                      "$tmpc" "$dbg$opt$opts"                 "$cmdl";
        else printf "%s$TEST_FILE %s $SYMB_SPEC '%s' %s\n"      "$tmpc" "$dbg$opt$opts"         "$help" "$cmdl" | \
             Indent -a -c1 -i 0 -m 112; fi # NB: no indent, single continuation char. # ! umsg
        if   ((doeg == 0)) && ( [[ "$find" ]] || [[ "$none" ]] ); then
             printf "search: '%s' ! '%s'\n" "$find" "$none" | \
             Indent -a -c1 -i 0 -m 112;
        fi

        ############################################################
        # to preserve quoted fields in the HELP string with spaces,
        # we must add it to an array quoted so that it is one item;
        # to ensure commandline items are seen as separate, we must
        # give them as unquoted; then we grab the results in an array
        # Note that errors will go to the screen & not to the array.
        ############################################################
        failed=-1; empt=0; need=0; errd=$fail; hvit=0; # set defaults
        if   [[ "$find" ]]; then ((need+=1)); fi
        if   [[ "$none" ]]; then ((need+=4)); fi
        if   [[ "$umsg" ]];
        then args=($dbg$opt$opts "$umsg" $SYMB_SPEC "$help"  $cmdl); # -cu "message"|-cu="message"|-cu"message"
        elif ((restore == 1)) || ((nohelp == 1));
        then args=($dbg$opt$opts $cmdl); # special cases: restore & nohelp
        else args=($dbg$opt$opts $SYMB_SPEC "$help"  $cmdl); fi      # ! umsg
       #if [[ "$vrb" ]]; then cdebug no; fi
        local line; declare -a result=(); while IFS= read -r line;
        do  result+=("$line");                          # for printing later
            # Note: in restore case, func=status is echoed
            if   [[ "$line" =~ "func="([0-9]+) ]];      # works even if tracing
            then failed=${BASH_REMATCH[1]};             # extract result
                 errd=$((failed == 0 ? 0 : 1));         # convert to 0|1
            elif [[ ! "$line" ]]; then empt=1; fi
            if   [[ "$find" ]] && [[ "$line" == *"$find"* ]]; then hvit=$((hvit | 1));
                 if [[ "$find" == "ANALYZE="* ]]; then  local code="${line/*=/}";
                     failed=${code/ */}; # orig.: ANALYZE=n : string [n]
                     errd=$((failed == 0 ? 0 : 1));
                 fi
            fi
            if   [[ "$none" ]] && [[ "$line" == *"$none"* ]]; then hvit=$((hvit | 4)); fi
        done < <($TEST_FILE "${args[@]}" 2>"$TEST_FTMP");
        if [[ "$vrb" ]]; then #cdebug on;
            local YYY=" fail|failed=$fail|$failed, errd=$errd, opts=$opts ";
            local YYY=" need|hvit=$need|$hvit, empt|rslt=$empt|$rslt, find=$find ";
        fi  # following can't be done for RESULT testing [-cy]
        if  ((rslt == 1)) && [[ "$opts" != *$RESULT* ]]; then
            local st8=$failed; if ((failed == -1));
            then $($TEST_FILE "${args[@]}" &>/dev/null); st8=$?; fi # rerun to get status
            line=$(result $st8); result+=("$line");    # add result to printed o/p if err
        fi
        failed=$((failed == 0 ? 0 : 1)); # failed if -1 or non-zero
        if  ( [[ "$opts" == *$USRMSG* ]] || [[ "$umsg" == $USRMSG* ]] ) &&
            ((hvit != need)); then failed=1; errd=$failed;
        fi
        if  ((failed != fail)) || ((errd != fail)); then ((fails++)); failures+="$ic "; fi
        # need -f find whenever find string is found in errors|warnings sent to TEST_FTMP
        if ! PrintResults $vrb $exm -f "$find" $ic $fail $failed "$find" -n "$none" $hvit $prtdbg "${result[@]}";
        then if [[ "$failures" != *"$ic "* ]]; then ((fails++)); failures+="$ic "; fi; fi

        if   [[ "$opts" == *$RESULT* ]]; then # following is only for RESULT testing [-cy]
             local file="$RSLT.func";  local bad=0; local str="";
             if  [ ! -f "$file" ]; then bad=1; str="file was not created: $RSLT"; # problem if result file not created
             else local  oldsts=$(cat "$file"); oldsts=${oldsts/*=/}; # discard '=' & all before
                  if  [[ "$failed" != "$oldsts" ]]; then bad=1; str="rtncode didn't match (exp|was): $failed|$oldsts"; fi
             fi;  if  ((bad == 1)) && [[ "$failures" != *"$ic "* ]]; then
                  ((fails++)); failures+="$ic "; printf "%s%s: %s\n" "errs" "$num" "$str";
             fi
        fi;  cdebug no "$vrb";
    done; NUM_TST=$tests; printf "%s\n" "$Divider";
    if ((doeg == 0)); then PrintFailures "TestConfigs" "$tst" $fails $tests "$failures"; sts=$?; fi
    return $sts;
} # end TestConfigs (-tc) result

###########################################################################
# Test Feature: -tf{n{-{m}}} where n=0 is all, "" description, else test no. n
# Test Descrip prints out the list of tests for those with descriptions
###########################################################################
function TestFeature() { local HELP="TestFeature {-x}{-v}{-d*} -tf{n{-{m}}} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range # Self-Test of Features";
    local opt=""; local dbg=""; local prtdbg=0; local nohlp=0; local vrb="";
    local bgn=1; local end=$SizeFeature; declare -a args; declare -a cmds;
    local doeg=0; local iseg; local lead="test"; local exm=""; local num;
    if     [[ "$1" == -x  ]]; then doeg=1;   exm=$1;   shift; lead="# example "; fi
    if     [[ "$1" == -v  ]]; then vrb="$1"; shift; fi
    if     [[ "$1" == -d  ]]; then dbg="$1 "; prtdbg=1; shift; fi
    while  [[ "$1" == -[doc]* ]];
    do  if [[ "$1" == -c* ]] && [[ "$1" == *h* ]]; then nohlp=1; fi;
        dbg+="$1 "; shift;
    done

    local tst=$1; shift; # keep a record of it
    if [[ "$1"   ==  -*  ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    if [[ "$tst" == -tf  ]]; then PrintDescrips "$tst" 1 $SizeFeature "FeatureDesc"; return; fi # show descriptions
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else return $FAILURE; fi # can't go on

    local sts=$SUCCESS; rm -f "$TEST_FTMP";  # remove old temp test file (where we write errors)
    local fails=0;  local failures=""; local ic; local tests=0;
    local fail; local opts; local find; local hvit; local fopt;
    local cmdl; local help; local errd; local fstr;
   #if  ((nohlp == 0)); then opt+="-ch"; fi # suppress HELP output

    PrintHeaders "TestFeature" "$tst" "$num" "$doeg"; cdebug on "$vrb";
    for ((ic=bgn; ic <= end; ic++)); do help="${FeatureHelp[$ic]}";
        if [[ ! "$help" ]]; then continue; else ((tests++)); fi # skip future tests
        iseg="${FeatureIsEg[$ic]}";  if ((doeg == 1)) && ((iseg == 0)); then continue; fi
        desc="${FeatureDesc[$ic]}";  fail="${FeatureFail[$ic]}"; fopt="";
        opts="${FeatureOpts[$ic]}";  cmdl="${FeatureCmdl[$ic]}"; fstr="";
        find="${FeatureFind[$ic]}"; #item=${find/=*/}; # get item name
        # needs "# example n ", not "# example  n" for ease of finding
        printf -v num "%-2s" "$ic";  printf "%s\n" "$Divider";
        printf "%s%s: %s\n" "$lead" "$num" "$desc";
       #if ((doeg == 1)); then printf "%s\n" "$Divider"; fi
        local tmpc=""; if ((doeg == 0)); then tmpc="cmdl$num: "; fi
        printf "%s$TEST_FILE %s $SYMB_SPEC '%s' %s\n" "$tmpc" "$dbg$opt$opts" "$help" "$cmdl";
        if [[ "$find" ]] && ((doeg == 0)); then printf "search: [$find]\n"; fi
        if [[ "$find" ]] && ((fail == 2)); then fopt="-f"; fstr="$find"; fi

        ############################################################
        # to preserve quoted fields in the HELP string with spaces,
        # we must add it to an array quoted so that it is one item;
        # to ensure commandline items are seen as separate, we must
        # give them as unquoted; then we grab the results in an array
        # Note that errors will go to the screen & not to the array.
        ############################################################
        local is_fail=$((fail != 0));
        failed=-1; errd=$is_fail; hvit=0;              # set defaults
        args=($dbg$opt$opts $SYMB_SPEC "$help"  $cmdl);
        local line; declare -a result=(); while IFS= read -r line;
        do  result+=("$line"); # for printing later
            if  [[ "$line" =~ "func="([0-9]+) ]]; then # works even if tracing
                failed=${BASH_REMATCH[1]};             # extract result
                errd=$((failed == 0 ? 0 : 1));         # convert to 0|1
            fi
            if  [[ "$find" ]] && [[ "$line" == *"$find"* ]]; then hvit=1; fi
        done < <($TEST_FILE "${args[@]}" 2>"$TEST_FTMP");
        failed=$((failed == 0 ? 0 : 1)); # failed if -1 or non-zero
        if   ((failed != is_fail)) || ((errd != is_fail)); then ((fails++)); failures+="$ic "; fi
        if  [[ "$fopt" && "$fstr" ]];
        then if ! PrintResults $exm $fopt "$fstr" $ic $fail $failed "$find" $hvit $prtdbg "${result[@]}";
             then if [[ "$failures" != *"$ic "* ]]; then ((fails++)); failures+="$ic "; fi; fi
        else if ! PrintResults $exm               $ic $fail $failed "$find" $hvit $prtdbg "${result[@]}";
             then if [[ "$failures" != *"$ic "* ]]; then ((fails++)); failures+="$ic "; fi; fi
        fi
    done; NUM_TST=$tests; cdebug no "$vrb";
    printf "%s\n" "$Divider"; # no extra empty line and no error printing if for examples
    if ((doeg == 0)); then PrintFailures "TestFeature" "$tst" $fails $tests "$failures"; sts=$?; fi
    return $sts;
} # end Test Feature (-tf)

###########################################################################
# Test Variety: -tf{n{-{m}}} where n=0 is all, "" description, else test no. n
# Test Descrip prints out the list of tests for those with descriptions
###########################################################################
function TestVariety() { local HELP="TestVariety {-x}{-v}{-d*} -tv{n{-{m}}} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range # Self-Test of Variety Parsing";
    local opt=""; local dbg=""; local prtdbg=0; local nohlp=0; local vrb="";
    local bgn=1; local end=$SizeVariety; declare -a args; declare -a cmds;
    local doeg=0; local iseg; local lead="test"; local exm=""; local num;
    if     [[ "$1" == -x  ]]; then doeg=1;   exm=$1;   shift; lead="# example "; fi
    if     [[ "$1" == -v  ]]; then vrb="$1"; shift; fi
    if     [[ "$1" == -d  ]]; then dbg="$1 "; prtdbg=1; shift; fi
    while  [[ "$1" == -[doc]* ]];
    do  if [[ "$1" == -c* ]] && [[ "$1" == *h* ]]; then nohlp=1; fi;
        dbg+="$1 "; shift;
    done

    local tst=$1; shift; # keep a record of it
    if [[ "$1"   ==  -*  ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    if [[ "$tst" == -tv  ]]; then PrintDescrips "$tst" 1 $SizeVariety "VarietyDesc"; return; fi # show descriptions
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else return $FAILURE; fi # can't go on

    local sts=$SUCESS; rm -f "$TEST_FTMP";  # remove old temp test file (where we write errors)
    local fails=0;  local failures=""; local ic;    local tests=0;
    local fail; local opts; local hvit; local src1; local src2;
    local cmdl; local help; local errd;
   #if  ((nohlp == 0)); then opt+="-ch"; fi # suppress HELP output

    PrintHeaders "TestVariety" "$tst" "$num" "$doeg"; cdebug on "$vrb";
    for ((ic=bgn; ic <= end; ic++)); do help="${VarietyHelp[$ic]}";
        if [[ ! "$help" ]]; then continue; else ((tests++)); fi # skip future tests
        iseg="${VarietyIsEg[$ic]}";  if ((doeg == 1)) && ((iseg == 0)); then continue; fi
        desc="${VarietyDesc[$ic]}";  fail="${VarietyFail[$ic]}";
        opts="${VarietyOpts[$ic]}";  cmdl="${VarietyCmdl[$ic]}";
        src1="${VarietySrc1[$ic]}";  src2="${VarietySrc2[$ic]}";
        # needs "# example n ", not "# example  n" for ease of finding
        printf -v num "%-2s" "$ic";  printf "%s\n" "$Divider";
        printf "%s%s: %s\n" "$lead" "$num" "$desc";
       #if ((doeg == 1)); then printf "%s\n" "$Divider"; fi
        local tmpc=""; if ((doeg == 0)); then tmpc="cmdl$num: "; fi
        printf "%s$TEST_FILE %s $SYMB_SPEC '%s' %s\n" "$tmpc" "$dbg$opt$opts" "$help" "$cmdl";
        local need1=0; local need2=0; local need=0;
        if   [[ "$src1" ]] &&
             [[ "$src2" ]]; then need=3; need1=1; need2=1;
          if ((doeg == 0)); then printf "search: '$src1' & '$src2' [$need]\n"; fi
        elif [[ "$src2" ]]; then need=2; need2=1;
          if ((doeg == 0)); then printf "search: src2='$src2' [$need]\n"; fi
        elif [[ "$src1" ]]; then need=1; need1=1;
          if ((doeg == 0)); then printf "search: src1='$src1' [$need]\n"; fi; fi

        ############################################################
        # to preserve quoted fields in the HELP string with spaces,
        # we must add it to an array quoted so that it is one item;
        # to ensure commandline items are seen as separate, we must
        # give them as unquoted; then we grab the results in an array
        # Note that errors will go to the screen & not to the array.
        ############################################################
        failed=-1; errd=$fail; hvit=0; # set defaults
        args=($dbg$opt$opts $SYMB_SPEC "$help" $cmdl); cdebug no "$vrb";
        local line; declare -a result=(); while IFS= read -r line;
        do  result+=("$line"); # for printing later
            if  [[ "$line" =~ "func="([0-9]+) ]]; then # works even if tracing
                failed=${BASH_REMATCH[1]};             # extract result
                errd=$((failed == 0 ? 0 : 1));         # convert to 0|1
            fi
            # But only capture 1st of each of these, so we don't keep on searching
            if  ((need1 == 1)) && [[ "$line" == *"$src1"* ]]; then need1=0; hvit=$((hvit | 1)); fi
            if  ((need2 == 1)) && [[ "$line" == *"$src2"* ]]; then need2=0; hvit=$((hvit | 2)); fi
        done < <($TEST_FILE "${args[@]}" 2>"$TEST_FTMP");
        if cdebug on "$vrb"; then local TMP=" rslt=$rslt"; fi
        failed=$((failed == 0 ? 0 : 1)); # failed if -1 or non-zero
        if   ((need == 0)) && ( ((failed != fail)) || ((errd != fail)) ); then ((fails++)); failures+="$ic "; fi
        if ! PrintResults $exm -r$rslt $ic $fail $failed "$src1" -i "$src2" $hvit $prtdbg "${result[@]}";
        then if [[ "$failures" != *"$ic "* ]];     then ((fails++)); failures+="$ic "; fi; fi
    done; NUM_TST=$tests; cdebug no "$vrb"; printf "%s\n" "$Divider";
    if ((doeg == 0)); then PrintFailures "TestVariety" "$tst" $fails $tests "$failures"; sts=$?; fi
    return $sts;
} # end Test Variety (-tv)

#############################################################################
# Test DataTyp: -td{n{-{m}}} where n=0 is all, "" description, else test n
# Note: same as Test Str Type except for array names and option
#############################################################################
function  TestDataTyp() { local HELP="TestDataTyp {-x}{-v}{-d*} -td{n{-{m}}} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range # Self-Test of Datatypes";
    local ic; local res=$FAILURE;  local fails=0; local vrb=0; local tests=0;
    local bgn=1; local end=$dtndx; local opt="-cces"; local dbg=""; local prtdbg=0;
    local doeg=0; local iseg; local cmd="command: "; local lead="Test "; local num;
    if     [[ "$1" == -x  ]]; then doeg=1; shift; cmd="";  lead="# example "; fi
    if     [[ "$1" == -v  ]]; then vrb=1; shift; fi
    if     [[ "$1" == -d  ]]; then dbg="$1 "; prtdbg=1; shift; fi
    while  [[ "$1" == -[doc]* ]];  do  dbg+="$1 "; shift; done;
    local tst=$1; shift; # keep a record of it
    if [[ "$1"   ==  -* ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    if [[ "$tst" == -td ]]; then PrintDescrips "$tst" 1 $dtndx "DTDesc"; return; fi # show descriptions
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else return $FAILURE; fi # can't go on

    local sts=$SUCCESS; cdebug on "$vrb"; # Note: no TEST_FTMP here
    PrintHeaders "TestDataTyp" "$tst" "$num" "$doeg"; # loop thru all tests & capture failures
    for ((ic=bgn; ic <= end; ic++)); do Reinit=1; # clear out old data
        local desc="${DTDesc[$ic]}"; ((tests++)); if [[ ! "$desc" ]]; then continue; fi
        local help="${DTHelp[$ic]}"; local data="${DTData[$ic]}"; local quot="${DTQuot[$ic]}";
        iseg="${DTIsEg[$ic]}"; if ((doeg == 1)) && ((iseg == 0)); then continue; fi
        # needs "# example n ", not "# example  n" for ease of finding
        printf "%s\n%s%-2s: %s\n" "$Divider" "$lead" "$ic" "$desc";
       #if ((doeg == 1)); then printf "%s\n" "$Divider"; fi
        if [[ ! "$help" ]] || [[ ! "$desc" ]]; then continue; fi # skip future tests
        local qmsg=""; if [[ "$quot" == 2 ]]; then qmsg=" # dbl-quoted"; fi
        if   [[ "$quot" == 2 ]] || [[ "$quot" == 1 ]];
        # skip trailing c/r on this line as getparms always adds extra c/r at start
        then printf "%s$TEST_FILE $dbg$opt $SYMB_SPEC '%s' '%s'\n" "$cmd" "$help$qmsg" "$data";
        else printf "%s$TEST_FILE $dbg$opt $SYMB_SPEC '%s' %s\n"   "$cmd" "$help"      "$data"; fi
        cdebug no "$vrb"; # don't trace getparms with -v
        if   [[ "$quot" == 2 ]]; # NB: data can't be quoted if "-f val" but must be for matching str w/ spaces
        then  if ! $TEST_FILE $dbg$opt $SYMB_SPEC "$help" "'$data'"; then ((fails++)); failed+="$ic "; fi
        elif [[ "$quot" == 1 ]]; # NB: data can't be quoted if "-f val" but must be for matching str w/ spaces
        then  if ! $TEST_FILE $dbg$opt $SYMB_SPEC "$help"   "$data"; then ((fails++)); failed+="$ic "; fi
        else  if ! $TEST_FILE $dbg$opt $SYMB_SPEC "$help"    $data ; then ((fails++)); failed+="$ic "; fi; fi
        cdebug on "$vrb";  # don't trace getparms with -v
    done; NUM_TST=$tests; cdebug no "$vrb"; printf "%s\n" "$Divider";
    if ((doeg == 0)); then PrintFailures "TestDataTyp" "$tst" $fails $tests "$failed"; sts=$?; fi
    return $sts;
} # end Test DataTyp (-td)

#############################################################################
# Test StrType: -ts{n{-{m}}} where n=0 is all, "" description, else test n
# Note: same as Test DataTyp except for array names & option (keep in sync)
#############################################################################
function  TestStrType() { local HELP="TestStrType {-x}{-v}{-d*} -ts{n{-{m}}} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range # Self-Test of Datatypes";
    local ic; local res=$FAILURE;  local fails=0; local vrb=0; local tests=0;
    local bgn=1; local end=$stndx; local opt="-cces"; local dbg=""; local prtdbg=0;
    local doeg=0; local iseg; local cmd="command: "; local lead="Test "; local num;
    if     [[ "$1" == -x  ]]; then doeg=1; shift; cmd="";  lead="# example "; fi
    if     [[ "$1" == -v  ]]; then vrb=1; shift; fi
    if     [[ "$1" == -d  ]]; then dbg="$1 "; prtdbg=1; shift; fi
    while  [[ "$1" == -[doc]* ]];  do  dbg+="$1 "; shift; done;
    local tst=$1; shift; # keep a record of it
    if [[ "$1"   ==  -* ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    if [[ "$tst" == -ts ]]; then PrintDescrips "$tst" 1 $stndx "STDesc"; return; fi # show descriptions
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else return $FAILURE; fi # can't go on

    local sts=$SUCCESS; cdebug on "$vrb"; # Note: no TEST_FTMP here
    PrintHeaders "TestStrType" "$tst" "$num" "$doeg"; # loop thru all tests & capture failures
    for ((ic=bgn; ic <= end; ic++)); do Reinit=1; # clear out old data
        local desc="${STDesc[$ic]}"; ((tests++)); if [[ ! "$desc" ]]; then continue; fi
        local help="${STHelp[$ic]}"; local data="${STData[$ic]}"; local quot="${STQuot[$ic]}";
        iseg="${STIsEg[$ic]}"; if ((doeg == 1)) && ((iseg == 0)); then continue; fi
        # needs "# example n ", not "# example  n" for ease of finding
        printf "%s\n%s%-2s: %s\n" "$Divider" "$lead" "$ic" "$desc";
       #if ((doeg == 1)); then printf "%s\n" "$Divider"; fi
        if [[ ! "$help" ]] || [[ ! "$desc" ]]; then continue; fi # skip future tests
        local qmsg=""; if [[ "$quot" == 2 ]]; then qmsg=" # dbl-quoted"; fi
        if   [[ "$quot" == 2 ]] || [[ "$quot" == 1 ]];
        # skip trailing c/r on this line as getparms always adds extra c/r at start
        then printf "%s$TEST_FILE $dbg$opt $SYMB_SPEC '%s' '%s'\n" "$cmd" "$help$qmsg" "$data";
        else printf "%s$TEST_FILE $dbg$opt $SYMB_SPEC '%s' %s\n"   "$cmd" "$help"      "$data"; fi
        cdebug no "$vrb"; # don't trace getparms with -v
        if   [[ "$quot" == 2 ]]; # NB: data can't be quoted if "-f val" but must be for matching str w/ spaces
        then  if ! $TEST_FILE $dbg$opt $SYMB_SPEC "$help" "'$data'"; then ((fails++)); failed+="$ic "; fi
        elif [[ "$quot" == 1 ]]; # NB: data can't be quoted if "-f val" but must be for matching str w/ spaces
        then  if ! $TEST_FILE $dbg$opt $SYMB_SPEC "$help"   "$data"; then ((fails++)); failed+="$ic "; fi
        else  if ! $TEST_FILE $dbg$opt $SYMB_SPEC "$help"    $data ; then ((fails++)); failed+="$ic "; fi; fi
        cdebug on "$vrb"; # don't trace getparms with -v
    done; NUM_TST=$tests; cdebug no "$vrb"; printf "%s\n" "$Divider";
    if ((doeg == 0)); then PrintFailures "TestStrType" "$tst" $fails $tests "$failed"; sts=$?; fi
    return $sts;
} # end Test StrType (-ts)

###########################################################################
# Test Errored: -te{n{-{m}} where n=0 is all, "" description, else test no. n
# Errs Descrip prints out the list of tests for those with descriptions
###########################################################################
function TestErrored() { local HELP="TestErrored {-x}{-v}{-d*} -te{n{-{m}}} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range # Self-Test of Errors";
    local opt=""; local exm=""; local dbg=""; local prtdbg=0; local nohlp=0;
    declare -a args; declare -a cmds; local enum; local estr; local failed;
    local bgn=1; local end=$SizeErrTest; local vrb=""; local num;
    local doeg=0; local iseg; local cmd="inputs: "; local lead="Test ";
    if     [[ "$1" == -x  ]]; then exm=$1; doeg=1; shift; cmd=""; lead="# example "; fi
    if     [[ "$1" == -v  ]]; then vrb="$1"; shift; fi
    if     [[ "$1" == -d  ]]; then dbg="$1 "; prtdbg=1; shift; fi
    while  [[ "$1" == -[doc]* ]];
    do  if [[ "$1" == -c*h* ]]; then nohlp=1; fi; dbg+="$1 "; shift; done
    if     ((nohlp ==  0)); then opt+="-ch "; fi # suppress HELP output

    local tst=$1; shift; # keep a record of it
    if [[ "$1"   ==  -*  ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    if [[ "$tst" == -te  ]]; then PrintDescrips "$tst" 1 $SizeErrTest "ErrTestDesc" -ds "ErrTestDsc2" "ErrTestEnum"; return; fi # show descriptions
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else return $FAILURE; fi # can't go on

    local sts=$SUCCESS; rm -f "$TEST_FTMP";  # remove old temp test file (where we write errors)
    local fails=0; local failures=""; local tests=0; local ic;
    local fail; local opts; local cmdl;  local help;
    local dsc2; local lldr; local ldr;   local errd; # $((end-bgn+1));

    PrintHeaders "TestErrored" "$tst" "$num" "$doeg"; cdebug on "$vrb";
    for ((ic=bgn; ic <= end; ic++)); do Reinit=1; # clear out old data
        enum="${ErrTestEnum[$ic]}";  estr="${ErrName[$enum]}";
        # NB: count Future as tests run, just to keep numbers matching
        # NB: for errors the description is always set to a default str
        ((tests++)); if ((enum == FUTR)); then continue; fi
        help="${ErrTestHelp[$ic]}";  fail="${ErrTestFail[$ic]}";
        desc="${ErrTestDesc[$ic]}";  dsc2="${ErrTestDsc2[$ic]}";
        cmdl="${ErrTestCmdl[$ic]}";  opts="$opt${ErrTestOpts[$ic]}";
        # needs "# example n ", not "# example  n" for ease of finding
        printf "%s\n" "$Divider";
        printf -v ldr "%s%-3s: " "$lead" "$ic"; lldr="${#ldr}";
        printf "%s%s%s\n" "$ldr" "$desc" "$dsc2";
       #if ((doeg == 1)); then printf "%s\n" "$Divider"; fi
        printf "%s$TEST_BASE %s $SYMB_SPEC '%s' %s\n" "$cmd" "$dbg$opts" "$help" "$cmdl";

        ############################################################
        # to preserve quoted fields in the HELP string with spaces,
        # we must add it to an array quoted so that it is one item;
        # to ensure commandline items are seen as separate, we must
        # give them as unquoted; then grab the results in an array
        # Note that errors will go to the file & not to the array
        # normally, but for examples we need them in array also.
        ############################################################
        failed=-1; errd=$fail; # set defaults
        args=($dbg $opts $SYMB_SPEC "$help"  $cmdl);
        local line; declare -a result=();
        if ((doeg == 1)); then while IFS= read -r line;
            do  result+=("$line"); # for printing later
                if  [[ "$line" =~ "func="([0-9]+) ]]; then # works even if tracing
                    failed=${BASH_REMATCH[1]};             # get number into failed
                    errd=$((failed == 0 ? 0 : 1));         # convert to 0|1
                fi
            done < <($TEST_FILE "${args[@]}" 2>&1);
        else while IFS= read -r line;
            do  result+=("$line"); # for printing later
                if  [[ "$line" =~ "func="([0-9]+) ]]; then # works even if tracing
                    failed=${BASH_REMATCH[1]};             # get number into failed
                    errd=$((failed == 0 ? 0 : 1));         # convert to 0|1
                fi
            done < <($TEST_FILE "${args[@]}" 2>"$TEST_FTMP");
        fi #  # Following test is to catch cases where we don't get: func=...
        failed=$((failed == 0 ? 0 : 1)); # failed if -1 or non-zero
        if ((failed != fail)) || ((errd != fail)); then ((fails++)); failures+="$ic "; fi
        if ! PrintResults $exm $vrb -f $estr  $ic $fail $failed "" 0 $prtdbg "${result[@]}";
        then if [[ "$failures" != *"$ic "* ]]; then ((fails++)); failures+="$ic "; fi; fi
    done; printf "%s\n" "$Divider"; NUM_TST=$tests; cdebug no "$vrb";
    if ((doeg == 0)); then PrintFailures "TestErrored" "$tst" $fails $tests "$failures"; sts=$?; fi
    return $sts;
} # end Test Errored (-te)

#############################################################################
# Test Matching: -tm{n{-m}}} where n=0 is all, "" description, else test n
# Matching tests include plain & regex matching. For these tests the description
# is actually the help string, so to get just the description we must extract it
#############################################################################
function  TestMatches() { local HELP="TestMatches {-x}{-v}{-d*} -tm{n{-{m}} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range # Self-Test of Plain & Regex Matching";
    local prtdbg=0; local recv="receive: "; local tests=0;
    local bgn=1;  local end=$Match;  local opt="-ccs"; local desc;
    local doeg=0; local  iseg;  local exm=""; local lead="Test "; local num;
    if [[ "$1" == -x ]]; then doeg=1; exm=$1; lead="# example "; recv=""; shift; fi
    declare -a dbg;      local dopt=; local rxl=${#recv};  # length of recv string
    local vrb=""; if [[ "$1" == -v ]]; then vrb=$1; shift; fi
    if     [[ "$1" == -d  ]]; then dbg=($1); prtdbg=1; shift; fi
    while  [[ "$1" == -[doc]* ]];  do  dbg+=($1); shift; done
    local tst=$1; shift; # keep a record of it
    if [[ "$1" ==  -* ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    local failed=""; local fails=0; declare -a result;
    if [[ "$tst" == -tm ]]; then PrintDescrips "$tst" $bgn $end "MatchDesc"; return; fi # show descriptions
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else return $FAILURE; fi # can't go on
    local help; local line; local fail; local name; local parm; local errd;
    local ic;   local oifs=$IFS; IFS=$CR; local find; local hvit; local fstr; # $'\n';

    rm -f "$TEST_FTMP";  # remove old file & loop thru all tests & capture failures
    PrintHeaders "TestMatches" "$tst" "$num" "$doeg"; local sts=$SUCCESS; cdebug no "$vrb";
    for ((ic=bgn; ic <= end; ic++)); do help="${MatchDesc[$ic]}"; # local IC=$ic;
        if [[ ! "$help" ]]; then continue; else ((tests++)); fi # skip future tests
        iseg="${MatchIsEg[$ic]}"; if ((doeg == 1)) && ((iseg == 0)); then continue; fi
        parm="${MatchData[$ic]}"; find="${MatchRcvd[$ic]}"; errd=$fail; hvit=0;
        fail="${MatchFail[$ic]}"; if ((fail == 0)); then fstr=""; else fstr="to fail"; fi
        printf "%s\n" "$Divider"; Reinit=1; # clear out the old data
        # discard all before first '#' and after last "'", next line: $CR => $CR$Divider$CR
        if ((doeg == 1)); then desc="${help#*# }"; desc="${desc%\'*}$CR"; else desc=""; fi
        cdebug no "$vrb"; # needs "# example n ", not "# example  n" for ease of finding
        printf "%s%-2s: %s$TEST_BASE ${dbg[@]} $opt $SYMB_SPEC '%s' %s\n" "$lead" $ic "$desc" "$help" "$parm";
        result=( $($TEST_FILE ${dbg[@]} $opt $SYMB_SPEC "$help" "$parm" 2>&1) ); # store result in array
        cdebug on "$vrb"; local jc; local res=0; name=""; local lines=${#result[@]};
        # have to account for: "*[n]: name=*" | "name=*"
        for ((jc=0; jc < lines; jc++)); do line=${result[$jc]};
            if   [[ "$line" == *"func="* ]]; then
                line="${line/*func=/}"; res="${line/ */}";
                errd=$((res == 0 ? 0 : 1)); # convert to 0|1
            elif [[ "$line" == *"name="* ]]; then name="${line/*name=/}"; # value only
                # value may|may not be quoted, so match a quoted|unquoted value if value to find
                # have to allow * before value in case tracing is turned on
                if  [[ "$find" ]] && ( [[ "$find" == *"$name" ]] ||
                   [[ "'$find'" == *"$name" ]] || [[ "\"$find\"" == *"$name" ]] ); then hvit=1; fi
                if ((doeg == 0)); then # Note: 105 allows following line to be broken up as shown -
                # receive: 01 [PFER]: Parameter format doesn't match: wrong values, s/b: ~sj~@+.TXT
                #          [24:string: s[a-z~+-]] was: name='filesTXT' [expected='filesTXT'to fail]
                printf "%s%s [expected='%s'%s]\n" "$recv" "$line" "$find" "$fstr" | Indent -a -i $rxl -m 90; fi
            elif ! ( [[ "$line" == "Warn_Msgs:"* ]] || [[ "$line" == "ErrorMsgs:"* ]] );
            then printf "%s\n" "$line"; fi # probably an error (but skip titles)
        done; if ((errd != fail)) || ( [[ "$find" ]] && ((hvit == 0)) && [[ "$failed" != *"$ic "* ]] );
        then ((fails++)); failed+="$ic "; fi
        if ! PrintResults $exm $vrb -p "results:" $ic "$fail" "$res" "$find" $hvit $prtdbg "${result[@]}"; # don't use failed
        then if [[ "$failed" != *"$ic "* ]]; then ((fails++)); failed+="$ic "; fi; fi
    done; IFS=$oifs; NUM_TST=$tests; cdebug no "$vrb"; printf "%s\n" "$Divider";
    if ((doeg == 0)); then PrintFailures "TestMatches" "$tst" $fails $tests "$failed"; sts=$?; fi
    return $sts;
} # end Test Matches (-tm)

#############################################################################
# Test Required: -tr{n{-{m}}} where n=0 is all, "" description, else test n
# Note: to inject a message add the debug message
# tstm="-cu '$hdg reqd=$nureq enum=$enum'"; # e.g.: of user injected msg
#############################################################################
function  TestReqOpts() { local HELP="TestReqOpts {-x}{-v{1|2|3}}{-d*} -tr{n{-m}}} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range # Self-Test of Required Options";
    local desc; local val; local cmd; local nureq; local dbg=""; local ic;
    local vnam="item"; local HLP; local optn; local ostr; local num;
    local save="${Symbl[$ITEM_NOLMT]}"; Symbl[$ITEM_NOLMT]="  ";  # temp change
    local sym;  local sym1;     local sym2;  local tests=0; local rstr;
    local reqd; local fails=0;  local flip;  local disp=0;  local stat;
    local hdg="TestInfo:";      local tstm="";   local doeg=0; local iseg;
    local cmdl="cmd-line: "; local exm=""; local lead="Test "; local vrb=0;
    if  [[ "$1" == -x  ]]; then doeg=1; exm=$1;  lead="# example "; cmdl=""; shift; fi
    if  [[ "$1" == -v* ]]; then vrb=${1:2}; shift;
        if [[ ! "$vrb" ]]; then vrb=3; fi # do both
    fi
    while [[ "$1" == -[doc]* ]]; do dbg+="$1 "; shift; done

    # Note: here we have to make descriptions on the fly, so can't return
    local tst=$1; shift; local bgn=1; local end=$SizeReqOpt; local enum;
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else disp=1; fi # get descriptions
    if  [[ "$1" == -v* ]]; then vrb=${1:2}; shift;
        if [[ ! "$vrb" ]]; then vrb=3; fi # do both
    fi
    if [[ "$1"  == -*  ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi

    ########################################################################
    # NB: for most tests we check if the description (in this case ICmnt) is
    # empty, but here that doesn't work, for there are comments for items we
    # don't want to process. So in this case we use IOptn and check if empty
    # now loop thru nspac to change each delimiter setting & verify reqd|optl
    ########################################################################
    local sts=$SUCCESS; rm -f "$TEST_FTMP"; # remove old file
    PrintHeaders "TestReqOpts" "$tst" "$num" "$doeg"; if ((vrb & 1)); then cdebug on; fi
    for ((ic=bgn; ic <= end; ic++)); do enum=${ReqOptEnum[$ic]}; # get enum for test
        optn="${IOptn[$enum]}";  if [[ ! "$optn" ]]; then continue; else ((tests++)); fi
        iseg="${ReqEg[$ic]}";    if ((doeg == 1)) && ((iseg == 0)); then continue; fi
        desc="${ICmnt[$enum]}";  sym="${Symbl[$enum]}"; nureq=0; # letter|empty: skip if empty
        reqd="${IReqd[$enum]}";  sym1=${sym:0:1}; sym2=${sym:1:1};
        if [[ "$sym" == "  " ]]; then sym="''"; fi               # but leave sym1 & sym2 as is
        desc+=" for ${Items[$enum]} = $sym"; flip=$(( (ic & 1) == 0 ? 1 : 0));
        if   ((reqd == 1));    then
             if ((flip == 1)); then rstr="optn"; else nureq=1; rstr="reqd"; fi
        else if ((flip == 1)); then rstr="reqd"; nureq=1; else rstr="optn"; fi; fi
        if  [[ "$rstr" == "reqd" ]]; then stat="valid";  else stat="empty"; fi
        # NB: 3 spaces in next line just for alignment in printing, no echos
        ostr="-ccensw    "; if ((flip == 1)); then ostr="-ccensw $CF_ITEM$optn"; fi # e.g.: -on
        HLP="func $sym1$vnam$sym2 # $sym test $rstr";
        # show bgn & o/p w/status, no errs, no wrap, include debug message (hdg)
        local msg=""; local cmd=""; if ((doeg == 0)); then
              msg="$hdg ic=$ic rstr=$rstr stat=$stat";
              cmd="$TEST_FILE -cu='$msg' $dbg$ostr $SYMB_SPEC \"$HLP\"";
        else  cmd="$TEST_FILE $dbg$ostr $SYMB_SPEC \"$HLP\""; fi
        val=""; if ((nureq == 1)); then val=": $enum"; cmd+=" $enum"; fi  # include required item
        # re-init needed to clear out old data for each run
        if ((disp == 0)); then printf "%s\n" "$Divider"; Reinit=1; fi
        # needs "# example n ", not "# example  n" for ease of finding
        printf "%s%-2s: $desc with %s$val\n" "$lead" "$ic" "$rstr"; # print description
       #if ((doeg == 1)); then printf "%s\n" "$Divider"; fi
        if ((disp == 1)); then continue; fi  # NB: no Print Results
        printf "%s%s\n" "$cmdl" "$cmd";      # prints command
        # discard  unneeded & empty lines & write to temporary file for post-processing
        # NB: following won't discard empty lines if tracing enabled since it's sent to &2
        # result: reqd[01]: item  "" [bgn][prm] || valid[1]: func=0 || valid[1]: item="1"
        eval  $cmd 2>&1 | grep -E -v "$SPCLIN:|help" | tee -a "$TEST_FTMP";
    done;  NUM_TST=$tests; if ((vrb & 1)); then cdebug no; fi
    if   ((tests == 0)); then return; elif ((disp == 1)); then echo;
    else printf "%s\n" "$Divider"; fi; Symbl[$ITEM_NOLMT]="$save"; # restore orig value

    # verify func overall status & req|optn status of parm
    local stat; local item; local itm2; local itm3; reqd="";
    local rest; local failed=" "; ic=0; enum=""; rstr="";
    if ((vrb & 2)); then cdebug on; fi # NB: following won't work if tracing!
    if [ -s "$TEST_FTMP" ]; then cat "$TEST_FTMP" | ( while read stat item itm2 itm3 rest; do
        if   [[ "$stat" == *"$hdg" ]]; then # find if parm req|optn
             if [[ "$item" ==   "ic="* ]]; then eval "$item"; fi # set: ic=n
             if [[ "$itm2" == "rstr="* ]]; then eval "$itm2"; fi # set: reqd=reqd|optn
             if [[ "$itm3" == "stat="* ]]; then eval "$itm3"; fi # set: stat=valid|empty
        elif [[ "$item" == *"$vnam="* ]];  then # line with status of 'item'
          if [[ "$stat" != "$stat"*  ]] && [[ "$failed" != *" $ic "* ]];
             then ((fails++)); failed+="$ic "; fi # else: passed
        elif [[ "$item" == *"func="* ]] && [[ "$item" != *"func=0"* ]] &&
             [[ "$failed" != *" $ic "* ]]; then ((fails++)); failed+="$ic ";
        fi
    done; if ((doeg == 0)); then PrintFailures "TestReqOpts" "$tst" $fails $tests "$failed"; sts=$?; fi
    if ((vrb & 2)); then cdebug no; fi # was: echo;
    return $sts; )
    fi # else echo "$NOFIL $TEST_FTMP [$tests]" >&2; return $FAILURE; fi
    return $sts;
} # end Test ReqOpts (-tr)

#############################################################################
# Test Outputs: -to{n{-{m}}} where n=0 is all, "" description, else test n
# [ Previously this function was: DisplaySamples {-d*}{-c*} -do{#{-{#}}} ]
# Since getparms.sh can't see OutTestNum, but it needs this value, we must
# pass it to getparms by writing it in the output file.
#############################################################################
function  TestOutputs() { local HELP="TestOutputs {-x}{-v}{-d*} -to{n{-{m}}{-#} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range, -# is the no. times to run (def.=100) # Tests to verify display outputs";
    local doh=0;   local dbg=0; local opts=""; local last=""; local tests=0;
    local run=1;   local bgn=1; local end=$OutTestNum; local sts=$SUCCESS;
    local doeg=0;  if [[ "$1" == -x ]]; then doeg=1; shift; fi
    local vrb="";  if [[ "$1" == -v ]]; then vrb=$1; shift; fi
    while [[ "$1" == -c* ]] || [[ "$1" == -p* ]] || ( [[ "$1" == -d* ]] && [[ "$1" != -do* ]] );
    do    if [[ "$1" == -d ]]; then dbg=1; fi; opts+="$1 "; shift; done

    local opt="${1/-do/}"; opt="${opt/$SYMB_INDP/}"; shift; # discard -do & = if present, no longer needed
    local tst="$opt"; # 1 based numbering on tests, so 0 means do all
    if   [[ "$1" == -* ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    local bgn=1;  local end=$OutTestNum; local num; local ic; local lsti=-1;
    if  GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else doh=1; fi # get descriptions

    PrintHeaders "TestOutputs" "$tst" "$num" "$doeg"; cdebug on "$dbg"; # Note: no TEST_FTMP here
    for ((ic=bgn; ic <= end; ic++)); do
        if  [ -f "$TEST_QUIT" ]; then echo "Quitting: Test Failure [$lsti]" >&2; sts=$FAILURE; break; fi
        local cmd="${OutTestCmd[$ic]}"; local lnA="${OutTestLnA[$ic]}";
        local lnB="${OutTestLnB[$ic]}"; local lnC="${OutTestLnC[$ic]}";
        local hlp="${OutTestHlp[$ic]}"; local nam="${OutHelpNam[$ic]}";
        local dot="${OutTestTst[$ic]}"; local bad="${OutTestBad[$ic]}";
        local this="$nam"; ((tests++)); # test result of command (1|0)
        if [[ "$this" == "$last" ]]; then this=""; else last="$this"; fi
        if ((doeg == 1)); then printf "#_XMPL${ic}_BGN\n"; fi  # write bgn hdr
        printf "%s\n" "$OutTestLin"; lsti=$ic; # header line for text
        if [[ "$lnA" ]]; then printf "%s\n" "$lnA"; fi
        if ((doh == 1)); then # can't copy, paste, run when end with: | Indent -a -i 6 -m 100
             if [[ "$this" ]]; then printf "%s='%s'\n" "$nam" "$hlp"; fi # only print new help if different than last
             printf "%s\n" "getparms $opts$cmd";
        else if [[ "$lnB"  ]]; then printf "%s\n" "$lnB"; fi
             if [[ "$lnC"  ]]; then printf "%s\n" "$lnC"; fi
             printf "%s\n%s\n" "$OutTestLin" "$nam='$hlp'";
             printf "%s\n"  "getparms $opts$cmd";
             Reinit=1; eval "getparms $opts$cmd"; # not user input, so eval safe here
             local rslt=$?; local fail=$((rslt != 0));
             if  ((dot == 1)); then if ((rslt == SUCCESS)); # need to o/p test result
                 then printf "SUCCESS\n"; else printf "FAILURE=$rslt\n"; fi
             fi
             if  ((bad != fail)); then printf  "%s\n" "$OutTestLin"; sts=$FAILURE; # header line top
                 FailAll "ERROR: expected fail=$bad, got fail=$fail => FIX Problems & then Rerun All Tests!";
                #printf "%s\n" "$OutTestLin";  # header line bot
                 break;  # go ahead and stop all these tests
             fi
        fi;  if  ((doeg == 1)); then printf "#_XMPL${ic}_END\n"; fi # write end hdr
    done; printf "%s\n" "$OutTestLin"; # header line at end
   #if ((doh == 1)); then echo; elif # Note: next line needs "Examples End" to show end of tests for GetTest in getparms
    if ((doh == 0)) && [[ "$sts" == $SUCCESS ]] && ((bgn != end));
    then printf "# TestOutputs Examples End Overall SUCCESS\n";
         printf "%s\n\n" "$OutTestLin"; # header line at end
    elif ((tests != 0)) && ((doh == 1)); then echo; fi
    cdebug no "$dbg"; return $sts;
} # end Test Outputs (Display Samples)

#############################################################################
# Ending of all the test used for getparms examples
# Start of Sub-Tests not used for getparms examples
#############################################################################

#############################################################################
# Test Prefers: -tp{n{-{m}}} where n=0 is all, "" description, else test n
# This checks that symbols can be changed via prefs (-p[bgamertpx])
# Note: not used in test examples
#############################################################################
function  TestPrefers() { local HELP="TestPrefers {-v}{-d*} -tp{n{-m}}} # if no n show tests, 0 run all, else test n # Self-Test of Prefs (via: -tp)";
    local bgn=1; local end=$SizePrefer; local opt=""; local dbg="";
    local vrb=""; if [[ "$1" == -v  ]]; then  vrb="$1"; shift; fi
    local num; local doeg=0; local prtdbg=0;
    if     [[ "$1" == -d  ]]; then dbg="$1 "; prtdbg=1; shift; fi
    while  [[ "$1" == -[doc]* ]];  do dbg+="$1 "; shift;
    done; local tst=$1; shift; # keep a record of it
    if [[ "$1" == -* ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    if [[ "$tst" == -tp ]]; then PrintDescrips "$tst" $bgn $end  "PreferDesc";  return; fi # show descriptions
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN;  end=$END;  num=$NUM; else return $FAILURE; fi # can't go on

    local sts=$SUCCESS;  rm -f "$TEST_FTMP"; # rm old
    local fails=0; local desc; local item; local ic;
    local tests=0; local opts; local find; local hvit;
    local fails=0; local cmdl; local help; local errd;
    declare -a result;  local failures=""; local failed=""; cdebug on "$vrb";

    PrintHeaders "TestPrefers" "$tst" "$num" "$doeg"; cdebug on "$dbg"; # Note: no TEST_FTMP here
    for ((ic=bgn; ic <= end; ic++));  do Reinit=1; fail=0;
        desc="${PreferDesc[$ic]}"; enum="${PreferEnum[$ic]}";
        ((tests++)); if [[ ! "$desc" ]] || ((enum == 0)); then continue; fi
        help="${PreferHelp[$ic]}";  opts="${PreferOpts[$ic]}";
        cmdl="${PreferCmdl[$ic]}";  find="${PreferFind[$ic]}";
        item=${find/=*/}; # get item name
       #iseg="${PreferIsEg[$ic]}";  if ((doeg == 1)) && ((iseg == 0)); then continue; fi
        printf -v num "%02d" "$ic"; printf "%s\n" "$Divider";
        printf "test%s: %s\n" "$num" "$desc";
       #if ((doeg == 1)); then printf "%s\n" "$Divider"; fi
        printf "inputs: $TEST_BASE %s $SYMB_SPEC '%s' %s\n" "$dbg$opts" "$help" "$cmdl";
        if [[ "$find" ]]; then printf "search: $find\n"; fi

        ############################################################
        # to preserve quoted fields in the HELP string with spaces,
        # we must add it to an array quoted so that it is one item;
        # to ensure commandline items are seen as separate, we must
        # give them as unquoted; then we grab the results in an array
        # Note that errors will go to the screen & not to the array.
        ############################################################
        failed=-1; errd=$fail; hvit=0;  Reinit=1;      # set defaults
        args=($dbg$opt $opts $SYMB_SPEC "$help"  $cmdl);
        local line; declare -a result=(); while IFS= read -r line;
        do  result+=("$line"); # for printing later
            if  [[ "$line" =~ "func="([0-9]+) ]]; then # works even if tracing
                failed=${BASH_REMATCH[1]};             # get number into failed
                errd=$((failed == 0 ? 0 : 1));         # convert to 0|1
            fi  # leading '*' needed in case we are tracing
            if  [[ "$find" ]] && [[ "$line" == *"${item}="* ]]; then
                if [[ "$line" == *"$find" ]]; then hvit=1; fi
            fi
        done < <($TEST_FILE "${args[@]}" 2>"$TEST_FTMP");
        # Following catches unexpected failures where we don't get: func=...
        failed=$((failed == 0 ? 0 : 1)); # failed if -1 or non-zero
        if   ((failed != fail)) || ((errd != fail)); then ((fails++)); failures+="$ic "; fi
        # next line is done in Print Results by returning FAILURE
       #elif [[ "$item" ]] && ((hvit == 0)); then ((fails++)); failures+="$ic "; fi
        if ! PrintResults $ic $fail $failed "$item" $hvit $prtdbg "${result[@]}"; # was: find
        then if [[ "$failures" != *"$ic "* ]]; then ((fails++)); failures+="$ic "; fi; fi
    done; NUM_TST=$tests; cdebug no "$vrb"; printf "%s\n" "$Divider";
    PrintFailures "TestPrefers" "$tst" $fails $tests "$failures"; sts=$?;
    return $sts;
} # end Test Prefers (-tp)

#############################################################################
# Test Interns: -ti{n{-{m}}} where n=0 is all, "" description, else test n
# This checks that internal functions that generate output to the user are as
# expected. These tests differ from other tests in that they don't call
# getparms itself but some internal sub-function of it.
#############################################################################
function  TestInterns() { local HELP="TestInterns {-v}{-d*} -ti{n{-{m}}{-#} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range, -# is the no. times to run (def.=100) # Tests to verify internal functions";
    local dbg=""; declare -a args; local prtdbg=0; local bgn=1; #local doh=0;
    local vrb=""; declare -a cmds; local end=$SizeInterns; local num;
    if    [[ "$1" == -v  ]]; then vrb="$1";  shift; fi; local doeg=0;
    if    [[ "$1" == -d  ]]; then dbg="$1 "; prtdbg=1; shift; fi
    while [[ "$1" == -[doc]* ]]; do  dbg+="$1 "; shift; done

    local tst=$1; shift; # keep a record of it
    if [[ "$1"   == -t   ]]; then vrb="$1";  shift; fi
    if [[ "$1"   ==  -*  ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    if [[ "$tst" == -ti  ]]; then PrintDescrips "$tst" 1 $SizeInterns "InternsDesc"; return; fi # show descriptions
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else return $FAILURE; fi # can't go on

    local sts=$SUCCESS; rm -f "$TEST_FTMP";  # remove old temp test file (where we write errors)
    local fails=0;  local failures="";  local cmdl=""; local tests=0;
    local fail; local src1; local src2; local opts=""; local noer;
    local skip; local errd; local hvit;    local rslt; local ic;

    PrintHeaders "TestInterns" "$tst" "$num" "$doeg"; cdebug on "$vrb";
    for ((ic=bgn; ic <= end; ic++)); do desc="${InternsDesc[$ic]}";
        if   [[ ! "$desc" ]]; then continue; else ((tests++)); fi # skip future tests
        src1="${InternsSrc1[$ic]}"; src2="${InternsSrc2[$ic]}";
        fail="${InternsFail[$ic]}"; cmdl="${InternsCmdl[$ic]}";
        noer="${InternsNoEr[$ic]}"; opts="${InternsOpts[$ic]}";
        cmdl="$TEST_FILE -x $cmdl"; # prefix: getparms.sh -x
        if   [[ "$opts" ]]; then opts+=" "; fi
        if   ((noer == 1)); then skip=-s; else skip=""; fi

        printf -v num "%02d" "$ic";  printf "%s\n" "$Divider";
        printf "test%s: %s\n" "$num" "$desc"; hvit=0;
        printf "cmdl%s: %s %s%s\n" "$num" "$cmdl" "$dbg$opts";
        local need1=0; local need2=0; local need=0;
        if   [[ "$src1" ]] && [[ "$src2" ]]; then need=3; need1=1; need2=1;
        printf "search: '$src1' & '$src2' [$need]\n";
        elif [[ "$src2" ]]; then need=2; need2=1;
        printf "search: src2='$src2' [$need]\n";
        elif [[ "$src1" ]]; then need=1; need1=1;
        printf "search: src1='$src1' [$need]\n"; fi
        #if ((doh == 1)); then continue; fi

        ############################################################
        # to preserve quoted fields in the HELP string with spaces,
        # we must add it to an array quoted so that it is one item;
        # to ensure commandline items are seen as separate, we must
        # give them as unquoted; then we grab the results in an array
        # Note that errors will go to the screen & not to the array.
        ############################################################
        local failed=-1;  errd=$fail;  rslt=-1; args=($dbg$opts); #cdebug no "$vrb";
        local line; declare -a result=(); while IFS= read -r line;
        do  if  [[ "$line" == *"rslt="* ]]; then failed=${line/*rslt=/};
            else result+=("$line"); fi # for printing later (don't print rslt)
            # Note: these next two could be on the same line so check for both
            # only capture 1st of each of these, so we don't keep on searching
            if  ((need1 == 1)) && [[ "$line" == *"$src1"* ]]; then need1=0; hvit=$((hvit | 1)); fi
            if  ((need2 == 1)) && [[ "$line" == *"$src2"* ]]; then need2=0; hvit=$((hvit | 2)); fi
        done < <($cmdl "${args[@]}" 2>&1; echo "rslt=$?"); # NB: need errored o/p & save result
        # NB: can't put " | grep -E -v '^[[:space:]]*$'" before 'echo "rslt=$?"', gets wrong status
        #if  cdebug on "$vrb"; then local TMP=" failed=$failed "; fi
        # NB: for most of these cases, func is not printed, which we expect
        failed=$((failed == 0 ? 0 : 1)); # failed if -1 or non-zero
        if   ((need == 0)) && ( ((failed != fail)) || ((errd != fail)) );
        then ((fails++)); failures+="$ic "; break; fi # had FailAll b4 break
        if ! PrintResults $skip -r$rslt $ic $fail $failed "$src1" -i "$src2" $hvit $prtdbg "${result[@]}";
        then if [[ "$failures" != *"$ic "* ]]; then ((fails++)); failures+="$ic "; fi; fi
    done; NUM_TST=$tests; cdebug no "$vrb"; printf "%s\n" "$Divider";
    PrintFailures "TestInterns" "$tst" $fails $tests "$failures"; sts=$?;
    return $sts;
} # end Test Interns (-ti)

#############################################################################
# Test HelpOut: -th{n{-{m}}} where n=0 is all, "" description, else test n
# Checks all help output are as expected. These tests differ from others as
# the spec & cmd-line are passed together since we don't always have a spec.
#############################################################################
function  TestHelpOut() { local HELP="TestHelpOut {-v}{-d*} -th{n{-{m}}{-#} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range, -# is the no. times to run (def.=100) # Tests to verify help";
    local dbg=""; declare -a args; local prtdbg=0; local bgn=1;
    local vrb=""; declare -a cmds; local end=$SizeHelpOut; local num;
    if    [[ "$1" == -v  ]]; then vrb="$1";  shift; fi
    if    [[ "$1" == -d  ]]; then dbg="$1 "; prtdbg=1; shift; fi
    while [[ "$1" == -[doc]* ]]; do  dbg+="$1 "; shift; done

    local tst=$1; shift; # keep a record of it
    if [[ "$1"   == -t  ]]; then vrb="$1";  shift; fi
    if [[ "$1"   ==  -* ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    if [[ "$tst" == -th ]]; then PrintDescrips "$tst" 1 $SizeHelpOut "HelpOutDesc"; return; fi # show descriptions
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM;  else return $FAILURE; fi # can't go on

    local sts=$SUCCESS; rm -f "$TEST_FTMP";  # remove old temp test file (where we write errors)
    local fails=0;  local failures="";  local cmdl=""; local tests=0;
    local fail; local src1; local src2; local opts=""; local noer;
    local help; local errd; local hvit; local doeg=0;  local nofn=0;
    local rslt; local skip; local ic;   local extl; # $((end-bgn+1));

    PrintHeaders "TestHelpOut" "$tst" "$num" $doeg; cdebug on "$vrb";
    for ((ic=bgn; ic <= end; ic++)); do desc="${HelpOutDesc[$ic]}";
        if   [[ ! "$desc" ]]; then continue; else ((tests++)); fi # skip future tests
        src1="${HelpOutSrc1[$ic]}"; src2="${HelpOutSrc2[$ic]}";
        help="${HelpOutHelp[$ic]}"; fail="${HelpOutFail[$ic]}";
        nofn="${HelpOutNoFn[$ic]}"; noer="${HelpOutNoEr[$ic]}";
        extl="${HelpOutExtl[$ic]}"; opts="${HelpOutOpts[$ic]}";
        if   [[ "$opts" ]]; then opts+=" "; fi
        if   ((noer == 1)); then skip=-s; else skip=""; fi

        printf -v num "%02d" "$ic";  printf "%s\n" "$Divider";
        printf "test%s: %s\n" "$num" "$desc"; hvit=0; if [[ "$help" ]];
        then printf "cmdl%s: $TEST_BASE %s$SYMB_SPEC '%s' %s\n" "$num" "$dbg$opts" "$help" "$cmdl";
        else printf "cmdl%s: $TEST_BASE %s%s\n"                 "$num" "$dbg$opts"         "$cmdl"; fi
        local need1=0; local need2=0; local need=0;
        if   [[ "$src1" ]] &&
             [[ "$src2" ]]; then need=3; need1=1; need2=1;
                            printf "search: '$src1' & '$src2' [$need]\n";
        elif [[ "$src2" ]]; then need=2; need2=1;
                            printf "search: src2='$src2' [$need]\n";
        elif [[ "$src1" ]]; then need=1; need1=1;
                            printf "search: src1='$src1' [$need]\n"; fi

        ############################################################
        # to preserve quoted fields in the HELP string with spaces,
        # we must add it to an array quoted so that it is one item;
        # to ensure commandline items are seen as separate, we must
        # give them as unquoted; then we grab the results in an array
        # Note that errors will go to the screen & not to the array.
        ############################################################
        if [[ ! "$help" ]]; then args=($dbg$opts $cmdl);
        else  args=($dbg$opts $SYMB_SPEC "$help" $cmdl); fi
        local failed=-1;   errd=$fail;
        if  ((nofn == 1)); then failed=0; errd=0; fi  # don't force error if func not found

        cdebug no "$vrb";  # NB: ext'l method takes same time as looping, so most of time is generating help
        if  ((extl == 1)); then $TEST_FILE "${args[@]}" 2>&1 >"$TEST_SRCH"; failed=$?;
            if  ((need1 == 1)); then if grep -q "$src1" "$TEST_SRCH"; then need1=0; hvit=$((hvit | 1)); fi; fi
            if  ((need2 == 1)); then if grep -q "$src2" "$TEST_SRCH"; then need2=0; hvit=$((hvit | 2)); fi; fi
            errd=$((failed == 0 ? 0 : 1)); # convert errcode to 0|1
        else local line; declare -a result=(); while IFS= read -r line;
            do  if [[ "$line" == *"rslt=" ]]; then rslt="${line/*rslt=/}";
                else result+=("$line"); fi # for printing later
                if  ((nofn == 0)); then
                    if  [[ "$line" =~ "func="([0-9]+) ]]; then # works even if tracing
                        failed=${BASH_REMATCH[1]};        # extract function result
                        errd=$((failed == 0 ? 0 : 1));    # convert errcode to 0|1
                    fi
                fi; # Note: these next two could be on the same line so check for both
                # But only capture 1st of each of these, so we don't keep on searching
                if  ((need1 == 1)) && [[ "$line" == *"$src1"* ]]; then need1=0; hvit=$((hvit | 1)); fi
                if  ((need2 == 1)) && [[ "$line" == *"$src2"* ]]; then need2=0; hvit=$((hvit | 2)); fi
            done < <($TEST_FILE     "${args[@]}" 2>&1; echo "rslt=$?"); # NB: need errored o/p & save result
        fi
        # Don't need to run 2nd time to get result, just echo it, but could have been done ...
       #done < <($TEST_FILE -cy "${args[@]}" 2>&1);   # NB: need errored o/p & save result
       #local rslt=$($TEST_FILE -r func);             # retrieve saved result
        if  cdebug on "$vrb"; then local TMP=" rslt=$rslt"; fi
        # NB: for most of these cases, func is not printed, which we expect
        failed=$((failed == 0 ? 0 : 1)); # failed if -1 or non-zero
        if   ((need == 0)) && ( ((failed != fail)) || ((errd != fail)) );
        then ((fails++)); failures+="$ic "; break; fi # had FailAll b4 break
        # next line is done in Print Results by returning FAILURE
       #elif ((need >  0)) && ((need != hvit)); then failures+="$ic "; fi
        if ! PrintResults $skip -r$rslt $ic $fail $failed "$src1" -i "$src2" $hvit $prtdbg "${result[@]}";
        then if [[ "$failures" != *"$ic "* ]]; then ((fails++)); failures+="$ic "; fi; fi
    done; NUM_TST=$tests; printf "%s\n" "$Divider"; cdebug no "$vrb";
    PrintFailures "TestHelpOut" "$tst" $fails $tests "$failures"; sts=$?;
    return $sts;
} # end Test HelpOut (-th)

#############################################################################
# Test Timings: -tm{n{-m}}}{-#} where n=0 is all, "" description, else test n
# The description is the help string, to get just description we must extract it
#############################################################################
function  TestTimings() { local HELP="TestTimings {-v}{-d*} -tt{n{-{m}}{-#} # if no n show tests, n=0 run all, else test n, n- from n to end, n-m range, -# is the no. times to run (def.=100) # Tests to calculate avg. test times";
    local prtdbg=0; local dbg=""; local recv="receive: ";
    local bgn=1;  local end=$Timed;  local opts=""; local num;
    local lead="Test "; local led2="CmdLine"; local tests=0;
    local vrb=""; if [[ "$1" == -v ]]; then vrb=$1; shift; fi
    if     [[ "$1" == -d  ]]; then dbg="$1 "; prtdbg=1; shift; fi
    while  [[ "$1" == -[doc]* ]]; do dbg+="$1 "; shift; done
    local tst=$1; shift; local run="-$TimedRuns"; # keep a record of it & set def.
    if [[ "$1" =~ ^-[0-9]*$ ]]; then run=$1; shift; fi # keep '-' to send to avgtime
    if [[ "$1" ==  -* ]]; then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    local failed=""; local fails=0; declare -a result; local sts=$SUCCESS; local doeg=0;
    if [[ "$tst" == -tt ]]; then PrintDescrips "$tst" $bgn $end "TimedDesc"; return; fi # show descriptions
    if GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; num=$NUM; else return $FAILURE; fi # can't go on

    # remove old file & loop thru all tests & capture failures
    rm -f "$TEST_FTMP";  PrintHeaders "TestTimings" "$tst" "$num" $doeg;
    local ic; local help; local parm; local time;                 # no tracing here
    for ((ic=bgn; ic <= end; ic++)); do help="${TimedDesc[$ic]}"; # local IC=$ic;
        if [[ ! "$help" ]]; then continue; else ((tests++)); fi   # skip futures
        parm="${TimedParm[$ic]}"; opts="${TimedOpts[$ic]}";
        printf "%s\n" "$Divider"; Reinit=1; # clear out the old data
        if [ ${#help} -lt 60 ]; # show in 1 line, else show cmdline items separately
        then printf "%s%-2d: $TEST_BASE $dbg$opts $SYMB_SPEC '%s' %s\n" "$lead" $ic "$help" "$parm";
        else printf "%s%-2d: $TEST_BASE $dbg$opts $SYMB_SPEC '%s\n"     "$lead" $ic "$help";
             printf "%s: %s\n" "$led2" "$parm"; #Test 6 :
        fi;  time=$(avgtime $run $TEST_FILE $dbg$opts $SYMB_SPEC "$help" "$parm");
        printf "time=%s\n" "$time";
    done; NUM_TST=$tests; printf "%s\n" "$Divider"; # no tracing here
    PrintFailures "TestTimings" "$tst" $fails $tests "$failed"; sts=$?;
    return $sts;
} # end Test Timings (-tt)

#############################################################################
# End of Sub-Tests
#############################################################################

#############################################################################
# Get Help Functions
#############################################################################
function  TestText() { # TestText {-p} key # prints out '_KEY' delimited text, -p preserve leading '# '
    local keep=0; if [[ "$1" == -p ]]; then keep=1; shift; fi
    local BGN="#_${1}_BGN"; local END="#_$1_END";
    local skip=1; local oifs="$IFS"; IFS=""; # preserve leading spaces
    cat "$TEST_SELF" | while read line; do
        if   ((skip == 1)); then
          if [[ "$line" == "$BGN"* ]]; then skip=0; fi # don't print skips
        elif [[ "$line" == "$END"* ]]; then skip=1;
        elif ((keep == 0)) && [[ "$line" == "#"* ]];
        then printf "%s\n" "${line:2}"; # discard lead "# "
        else printf "%s\n" "$line"; fi  # print until end
    done; IFS="$oifs"; # restore original IFS
}

function  GetTestTime()  { less    "$TEST_HIST"; }        # GetTime # prints exectimes: --time
function  GetTestVers()  { echo    "$TEST_VERS"; }        # GetVers # prints  version : --vers
function  GetTestInfo()  { TestText "TEST_INFO"; }        # GetInfo # prints  'manual': --help
function  GetTestHist()  { TestText "TEST_HIST" | less; } # GetHist # prints 'history': --history
#function GetTestFeat()  { TestText "TEST_FEAT"; }        # GetFeat # prints 'feature': --feature

###########################################################################
# All Tests and All Options arrays are used for both Test AllTest & Redo Failed
# Notice here we purposely skip Test Outputs (-td0) as these are display examples.
# Notice here we purposely skip Test AllTest (-ta0) to not be in an endless loop.
# Included tests: configs, features, variety, datatypes, string types,
# required|optional, matching, preferences, help, & internal tests
# Note: the order here determines the order that the tests in TestAllTest run.
# Similarly Example Tests runs only those tests which we will use as examples,
# which further excludes TestPrefers, TestErrored, & TestHelpOut.
# NB: keep Ex_Tests array in sync with TestExample function here.
# NB: keep Ex_Files (in getparms.sh) in sync with Ex_Tests here.
# NB: keep TestHelpOut as last test as it is most CPU intensive.
###########################################################################
declare -a Ex_Tests=("TestAllTest" "TestConfigs" "TestFeature" "TestVariety" "TestDataTyp" "TestStrType" "TestReqOpts" "TestMatches" "TestErrored" "TestOutputs"); # size
# numbers and sizes:       0             1             2             3             4             5             6             7             8             9             10            11            12            13
declare -a AllTests=("TestAllTest" "TestConfigs" "TestFeature" "TestVariety" "TestDataTyp" "TestStrType" "TestReqOpts" "TestMatches" "TestErrored" "TestOutputs" "TestPrefers" "TestInterns" "TestHelpOut" "TestTimings");
declare -a AllOptns=(    "-ta"         "-tc"         "-tf"         "-tv"         "-td"         "-ts"         "-tr"         "-tm"         "-te"         "-to"         "-tp"         "-ti"         "-th"         "-tt"    );
declare -a Ex_Maxim=(      0       $SizeConfigs  $SizeFeature  $SizeVariety      $dtndx        $stndx     $SizeReqOpt     $Match     $SizeErrTest   $OutTestNum  $SizePrefer   $SizeInterns  $SizeHelpOut      $Timed   );
AllTestOpts="a|c|d|e|f|i|m|o|r|p|h|s|t|v"; # Note: not in same order as above
AllExamOpts="$SAMP_OPTS"; # c|o|d|e|v|f|a|r|m|s"; # 10: "a|c|d|e|f|m|o|r|s|v"

function  GetTestSize()  {
    local ic;  local num=${#AllTests[@]}; local sum=0; local siz; local cr="$CR";
    for ((ic=1; ic < num; ic++)); do siz=${Ex_Maxim[$ic]};
        printf "$cr%s %s : %3s\n" "${AllTests[$ic]}" "${AllOptns[$ic]}" $siz; ((sum+=siz)); cr="";
    done; ic=0; printf "%s\n" "---------------------"
        printf   "%s %s : %s\n\n" "${AllTests[$ic]}" "${AllOptns[$ic]}" $sum;
}

###########################################################################
# Redo Past Test Failures using string from previous output
# called via -r option followed by message string, for e.g.:
# FAILED! TestPrefers (-tp): tests run 13 & 3 failed: 8 13 14 | -tp 8 13 26
###########################################################################
function  Redo_Failed() { local HELP="Redo_Failed dbg opt"; # via -r
    local line="$@"; local name=""; local test; local failed; local dbg="";
    local got=0;  local optn=""; local nums; local testnm; local op;

    while [[ "$1" == -[doc]* ]]; do  dbg+="$1 "; shift; done
    if [[ "$1" == -* ]] && [[ "$1" != -t* ]];
    then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi

    # Check if it's a real fail or just a list of tests
    if  [[ "$line" == -t* ]];  then optn="$1"; shift; nums="$@";
         if [[ "$optn" == *','* ]]; then optn="${optn//,/ }";
            if [[ "$optn" =~ ^-t.([0-9 ]+)$ ]]; then local tst=${BASH_REMATCH[1]};
               optn=${optn/$tst}; nums="$tst $nums";
            fi
         fi
    else local S_LEAD="$FAIL ";  local S_RUNS=": tests run "; local S_FAIL="failed:";
         local EMPT="input string bad format, e.g.: ${S_LEAD}TestPrefers: tests run  13 and 3 $S_FAILED: 8 13 14";
         local INVD="not a genuine failure, failed: 0";
         if [[ "$line" != "$S_LEAD"* ]];  then echo "redo leading = $EMPT" >&2; return $FAILURE; fi
         line="${line/$S_LEAD/}";         # discard leading string  : TestPrefers (-tp): tests run  13 and 3 failed: 8 13 14

         # Get name of the test run
         if [[ "$line" != *"$S_RUNS"* ]]; then echo "redo testrun = $EMPT" >&2; return $FAILURE; fi
         name="${line/$S_RUNS*/}";        # discard all after colon : TestPrefers (-tp)

         # Get test option run: extract from within parens
         if [[ "$name" =~ [(](.*)[)] ]];  then optn="${BASH_REMATCH[1]}"; fi # optn="-tp"
         name="${name/ */}";              # discard all after space : TestPrefers
         if [[ ! "$name" ]];              then echo "redo testnam = $EMPT" >&2; return $FAILURE; fi

         # Get numbers of failed tests
         if [[ "$line" != *"$S_FAIL"* ]]; then echo "redo failure = $EMPT" >&2; return $FAILURE; fi
         nums="${line/*$S_FAIL/}";        # discard all b4 failed : : 8 13 14
         if [[ "$nums" == "0" ]];         then echo "redo failure = $INVD" >&2; return $FAILURE; fi
    fi   # end processing redoing string

    local max=${#AllTests[@]}; # array size : search which of the tests it is
    for ((ic=0; ic < max; ic++)); do
        testnm=${AllTests[$ic]}; op=${AllOptns[$ic]};
        if ( [[ "$optn" ]] && [[ "$optn" == "$op" ]] ) || [[ "$testnm" == "$name" ]];
        then local num; got=1; # found test
             for num in ${nums[@]}; do getparmstest $dbg$op$num;
             done; break; # we're done
        fi
    done; if ((got == 0)); then if [[ "$name" ]];
        then printf "$UNDEF: $name\nvalid tests:\n" >&2;
        else printf "$UNDEF: $optn\nvalid tests:\n" >&2; fi
        for ((ic=0; ic < max; ic++)); do
             printf "%s = %s\n" "${AllOptns[$ic]}" "${AllTests[$ic]}" >&2;
        done; return $FAILURE;
    fi  # ensure we did a test
} # end redo tests

###########################################################################
# Main Functions : getparmstest is the main distributor of test requests
# TestAllTest runs all tests
###########################################################################
function  TestAllTest() { local HELP="TestAllTest dbg opt -a{n}|-ta{n}"; # via -a | -ta
    local tst; local opt=""; local ran=0; local name;  local cnt=0; local ic;
    local exm; local dbg=""; local bgn=1; local vrb=0; local all=0; local test;
    if    [[ "$1" == -x  ]]; # check if we're doing examples
    then exm=1; end=${#Ex_Tests[@]}; name="Ex_Tests"; dbg+="$1 "; shift; # keep -x ???
    else exm=0; end=${#AllTests[@]}; name="AllTests"; fi
    if    [[ "$1" == -v  ]]; then  dbg+="$1 "; shift; vrb=1; fi
    while [[ "$1" == -[doc]* ]]; do
       if [[ "$1" == -d  ]]; then  vrb=1; fi; dbg+="$1 "; shift;
    done; local tst=$1; shift; DoAll=""; # keep a record of tst; let -a do all tests (shorthand)
    if   [[ "$tst" == -ta ]]; then PrintDescrips "$tst" 1 $end "$name"; return; fi # show descriptions
    if   [[ "$tst" == -a* ]]; then all=1; fi # some tests only run if -a0|-a, not -ta0|-ta
    if   [[ "$tst" != -a  ]] && [[ "$tst" == -a* ]]; then tst="${tst/a/ta}"; fi # map: -a* => -ta*
    if   [[ "$1"   == -*  ]];  then echo "$BADOPT $1" >&2; echo "$HELP" >&2; return $FAILURE; fi
    if   [[ "$tst" == -ta0 ]]; then DoAll=0; fi # includes -a0

    # Note: not sure what to do here if get range fails since -a & -ta are ok
    if  GetRange "$tst" "$bgn" "$end"; then bgn=$BGN; end=$END; fi # get descriptions
    rm -f "$TEST_QUIT" "$TEST_ALLE"; # silently remove files
    for ((ic=bgn; ic < end; ic++)); do
        if  [ -f "$TEST_QUIT" ]; then echo "Quitting: Test Failure [$ic]" >&2; break; fi
        opt="${AllOptns[$ic]}$DoAll"; NUM_TST=0;
        if   ((exm == 0)); then test=${AllTests[$ic]};
             if [[ "$tst" == -a ]]; then PrintDescrips "$tst" $ic $ic "$name" "AllOptns"; fi
        else test=${Ex_Tests[$ic]}; printf "%s\n" "$Divider"; fi
        if   [[ "$test" == "TestTimings" ]]; then if ((all == 1)); # ignore doing Timing Test if not -a0
        then $test $dbg$opt 2>&1 | tee -a "$TEST_TIME"; fi
        else $test $dbg$opt 2>&1 | tee >(grep "tests run" >>"$TEST_ALLE");
             if [[ "$tst" == -to* ]]; then echo; fi
        fi
    done
    if  [[ "$tst" != -a ]] && [[ "$tst" != -ta ]]; then   # allow -a0, -ta0, ...
        cnt=$(grep -c -E "$FAIL .*: tests run" "$TEST_ALLE");  # grab following lines
        if ((exm == 0)); then # e.g.: FAILED! TestFeature (-tf): tests run  88 and 1 failed: 69
            printf "%s\n" "$Divider"; #  1       2         3      4    5    6  7  8   9     10
            local col=6; ran=$(awk "{sum+=\$$col} END {print sum}" "$TEST_ALLE"); # do sumcol
            if   ((cnt > 0)); then col=8; NmRun=$ran;
                 if ((vrb == 1)); then cat "$TEST_ALLE";
                 else  grep "failed:" "$TEST_ALLE"; fi # only show failed lines
                 local errs=$(awk "{sum+=\$$col} END {print sum}" "$TEST_ALLE");  # do sumcol
                 printf "$FAIL TestAllTest ($tst): tests run %3d and %-2d failed\n" "$ran" "$errs";
            elif [[ "$DoAll" ]]; then NmRun=$ran;
                 printf "$PASS TestAllTest ($tst): tests run $ran [$(date)]\n" | tee -a "$TEST_HIST";
            else printf "$PASS TestAllTest ($tst): tests run $ran\n"; fi
        fi
    fi; return $cnt; # 0 => SUCCESS, 1+ => FAILURE
} # end Test All Test

###########################################################################
# Test Example runs all tests suitable for examples & discard all empty lines
# in order to generate the example files for use by the getparms.sh utility.
# The exception is Test Outputs where the display needs to be exact, so there
# (only) we don't discard any empty lines.
# NB: when calling Test AllTest -x we don't want to do DoAll (reserved
# for normal tests) so we can't send it the 'all' options (-a{0}|-ta{0})
###########################################################################
function  TestExample() { local HELP="TestExample {-t<$AllExamOpts>} # def. do all supported";
    if [[ "$1" == -x ]]; then shift; fi;  local optn=$1; shift;
    if [[ "$opt" ]] && [[ "$opt" != *0 ]]; then optn+="0"; fi  # e.g.: -tm => -tm0
    local fail=0; local test; local file; local optn;
    local bgn=-1; local end=${#Ex_Tests[@]}; # size
    # getparms uses '-s*', but getparmstest uses '-t*', so map
    if [[ "$optn" == -s* ]]; then optn=${optn/s/t}; fi
    case  "$optn" in    # find a requested test
    -ta*|-a*)  bgn=1;;  # end = max here # test all of test types
    -tc*)      bgn=1;   end=$((bgn+1));; # test data type values
    -tf*)      bgn=2;   end=$((bgn+1));; # test specific features
    -tv*)      bgn=3;   end=$((bgn+1));; # test variety features
    -td*)      bgn=4;   end=$((bgn+1));; # test data type values
    -ts*)      bgn=5;   end=$((bgn+1));; # test data type strings
    -tr*)      bgn=6;   end=$((bgn+1));; # test required|optional
    -tm*)      bgn=7;   end=$((bgn+1));; # test matches & extract
    -te*)      bgn=8;   end=$((bgn+1));; # test individual errors
    -to*)      bgn=9;   end=$((bgn+1));; # test all of the output
    "")        bgn=1;;  # end = max here # test all of test types
    *)    if ((bgn == -1)); then echo "$HELP : bad opt=$optn" >&2; return $FAILURE; fi;;
    esac;      rm -f "$TEST_QUIT";
    local ic;  local lsti=-1; local strt; local ends; local lead; local disp; local maxm;

    for ((ic=bgn; ic < end; ic++)); do NUM_TST=0;
        if   [ -f "$TEST_QUIT" ]; then echo "Quitting: Test Failure [$lsti]" >&2; break; fi
        optn="${AllOptns[$ic]}0"; # form do all tests opt: -t?0
        if [[ "$optn" == -to* ]]; then disp=1; else disp=0; fi
        file="${Ex_Files[$ic]}";  rm -f "$file"; # get file & rm existing copy
        test="${Ex_Tests[$ic]}";  strt="# $test Examples";
        maxm="${Ex_Maxim[$ic]}";  ends="$strt End"; # test Examples End
        lead="$strt Bgn [file: ${file##*/}] [$TEST_BASE ver. $GETPARMS_VERS] [Max:$maxm]"; # don't show path
        # now write to the destination file
        printf "%s\n" "$Divider"  >>"$file";    # write header
        printf "%s\n" "$lead" | tee -a "$file"; # show on screen also
        if ((disp == 1)); # NB: capture errors but only TestOutput, need o/p as is
        then if ! $test -x  $optn >>"$file" 2>&1; then fail=1; fi
        else if ! $test -x  $optn | grep -E -v ^$ >>"$file"; then fail=1; fi; fi
        printf "%s\n" "$ends" | tee -a "$file"; # show on screen also
        printf "%s\n" "$Divider"  >>"$file"; lsti=$ic;
        if ((fail == 1)); then FailAll "Fix problems & Rerun!"; fi # indicate to stop all tests
    done # do for 1/all subtests specified
} # Test Example

#############################################################################
# Help Routines
#############################################################################
function  GetTestHelp() { # GetTestHelp {badopt}
    declare -a HELP; local ndx=-1;
    ((ndx++)); HELP[$ndx]="getparmstest is the utility that fully tests the functionality of the $TEST_FILE command-line parser";
    ((ndx++)); HELP[$ndx]="getparmstest --help|--vers|--hist|--time|--size # show getparmstest.sh long help|version|history|time";
    ((ndx++)); HELP[$ndx]="             {-c.}{-d{n}|-da|-dc} <-a|-do{n}|-t.{n}}> # .=$AllTestOpts (subtest type):";
    ((ndx++)); HELP[$ndx]="                                      # c=config, d=datatype, e=errs, a=all, f=feature, r=req'd|opt'l";
    ((ndx++)); HELP[$ndx]="                                      # m=match, o=output, p=part, h=help, s=string, t=timing, v=vars";
    ((ndx++)); HELP[$ndx]="             {-c.}                    # optional $TEST_BASE config (put near start): .=$CF_ALLS";
    ((ndx++)); HELP[$ndx]="             {-d{n}|-da|-dc}          # optional $TEST_BASE debugs (near start): -da|-dc trace spec|cmdl";
    ((ndx++)); HELP[$ndx]="             {-do{n}}                 # alternate option specifier for the -to{n} output display tests";
    ((ndx++)); HELP[$ndx]="                                      # [output tests are unique and not part of all tests (-a0|-ta0)]";
    ((ndx++)); HELP[$ndx]="                                      # [timing tests (-tt0) are unique & not part of -ta0 (only -a0)]";
    ((ndx++)); HELP[$ndx]="                                      # [timing result times are saved in the file: $TIME_FILE]";
    ((ndx++)); HELP[$ndx]="             -t.{n}|-a{n}             # n='' descriptions, n=0 do all, else test 'n'; -a or -ta do all";
    ((ndx++)); HELP[$ndx]="                                      # [-ta shows all groups names, -a shows all tests of all groups]";
    ((ndx++)); HELP[$ndx]="             -r -t. m n ...           # redo specific test type of specified tests, e.g.: -r -tp 18 26";
    ((ndx++)); HELP[$ndx]="             -r 'fail_msg'            # redo specific test failure, copy failed string as quoted input";
    ((ndx++)); HELP[$ndx]="                                      # e.g.: '$FAIL TestPrefers (-tp): tests run 8 & 2 failed: 5 8'";
    ((ndx++)); HELP[$ndx]="         -x {-t<$SAMP_OPTS>} # makes the $TEST_FILE examples files, i.e.: $TEST_EXAM";
    if [[ "$@" ]] && [[ "$1" != -h ]]; then printf "\nUnknown item: %s\n" "$@" >&2;
    else echo >&2; fi; printf "%s\n" "${HELP[@]}" >&2; echo >&2; # NB: can't combine above <c/r> with this line
    return $FAILURE;
}

function  TestingHelp() { # TestingHelp {--his*|--h*||-help|--ver*|--size}
    local opt="$1"; shift; local spcl="$@"; case "$opt" in
    --siz*)     GetTestSize;;           # --size
    --tim*)     GetTestTime;;           # --time
    --ver*)     GetTestVers;;           # --version
#   --feat*)    GetTestFeat;;           # --feature [FUTUR]
    --his*)     GetTestHist;;           # --history
    --h*|-help) GetTestInfo;;           # --help [detailed]|(mistyped)
    *)          GetTestHelp $opt "$@";; # -h [a short help]
    esac
}

function  getparmstest() { # getparmstest {-v} {-a}|{-t<d|e|a|f|m|o|r|p|h>{n}}}|-x # f=features, e=errors, d=datatype, m=matching, o=output, r=required, p=pattern, h=help, -ta|-a do all, -x make example files";
    local dbg=""; local opt; local test; local docb=0;
    if     [[ "$1" == -v  ]]; then dbg+="$1 ";  shift; fi
    if     [[ "$1" == -d  ]]; then dbg+="-d -cb "; docb=1; shift; fi
    while  [[ "$1" == -[oc]* ]] || ( [[ "$1" == -d* ]] && [[ "$1" != -do* ]] );
    do  if [[ "$1" != -cb ]] || ((docb == 0)); then dbg+="$1 "; fi; shift; done # already added above
    if  [ -f "$TEST_QUIT" ]; then rm -f "$TEST_QUIT"; fi # file created in All Test loop to stop
    local  cmd=$1;   if [[ "$@" == *','* ]]; then Redo_Failed $dbg "$@"; # redo tests shortcut
    else case "$cmd" in # find requested tests
    # handle long test summaries first so less is at this level, not in Test routines
    -td)        shift;  TestDataTyp $dbg $cmd "$@" | less; sts=$?;; # show data type values
    -te)        shift;  TestErrored $dbg $cmd "$@" | less; sts=$?;; # show individual errors
    -tf)        shift;  TestFeature $dbg $cmd "$@" | less; sts=$?;; # show specific features
    -tm)        shift;  TestMatches $dbg $cmd "$@" | less; sts=$?;; # show matches & extract
    -ts)        shift;  TestStrType $dbg $cmd "$@" | less; sts=$?;; # show str|var datatypes
    -a)         $TEST_TEST -x -q upd8_dev; # call update dev to update pregenerated files to speed execution
                shift;  TestAllTest $dbg $cmd "$@" >"$TEST_HELP"; less "$TEST_HELP";;
    # following are tests whose output needs to be saved
    -tt0)       shift;  TestTimings $dbg $cmd "$@" | tee -a "$TEST_TIME"; sts=$?;;

    # real tests and any short test summaries (-t{a|h|i|o|p|r|v})
    -ta*|-a*)   shift;  TestAllTest $dbg $cmd "$@";  sts=$?;; # test all test groups
    -tc*)       shift;  TestConfigs $dbg $cmd "$@";  sts=$?;; # test all config flags   [short]
    -td*)       shift;  TestDataTyp $dbg $cmd "$@";  sts=$?;; # test data type values   [short]
    -te*)       shift;  TestErrored $dbg $cmd "$@";  sts=$?;; # test individual errors
    -tf*)       shift;  TestFeature $dbg $cmd "$@";  sts=$?;; # test specific features
    -th*)       shift;  TestHelpOut $dbg $cmd "$@";  sts=$?;; # test help message outs  [short]
    -ti*)       shift;  TestInterns $dbg $cmd "$@";  sts=$?;; # test internal functions
    -tm*)       shift;  TestMatches $dbg $cmd "$@";  sts=$?;; # test matches & extract
    -tp*)       shift;  TestPrefers $dbg $cmd "$@";  sts=$?;; # test symbol preferences [short]
    -tr*)       shift;  TestReqOpts $dbg $cmd "$@";  sts=$?;; # test required|optional
    -ts*)       shift;  TestStrType $dbg $cmd "$@";  sts=$?;; # test str|var datatypes
    -tt*)       shift;  TestTimings $dbg $cmd "$@";  sts=$?;; # test execution times
    -tv*)       shift;  TestVariety $dbg $cmd "$@";  sts=$?;; # test parsing varieties  [short]

    # handle specialized functions (don't do less on -to|-do, else can't copy-paste-run)
    -to*|-do*)  shift;  TestOutputs $dbg $cmd "$@";  sts=$?;; # config flag vary output
    -x*)        shift;  TestExample      $cmd "$@";  sts=$?;; # generate example files
    -r)         shift;  Redo_Failed $dbg      "$@";  sts=$?;; # redo any test failures
    *)                  TestingHelp     "$cmd";      sts=$?;; # help (possible error)
    esac; fi; return $sts;
}

#############################################################################
# Main Script execution - to debug function, set _DEBUG_func=on (via debug)
# Note: only calc time if successful (thus skips help) & ran tests
# (skips list of tests, e.g.: -ta)
#############################################################################
DBG_ME="_DEBUG_$TEST_FUNC"; DBG_ON=${!DBG_ME}; # get value of the debug flag
BgnTim=0; initsecs -o BgnTim;        # for doing overall timing calculation
{ cdebug on "$DBG_ON"; } 2>/dev/null # to enable cdebug
getparmstest "$@"; sts=$?;
{ cdebug no "$DBG_ON"; } 2>/dev/null # to disable cdebug

# calculate the time
if ((sts == 0)) && [[ "$DoAll" ]] && ((NmRun != 0)); then if [[ "$DoAll" ]];
    then _timeval=$(calcsecs "$BgnTim"); printf -v _timemin "%.0f" "$_timeval"; # make int
         _timemin=$((_timemin/60));      # e.g.: _timeval=178.512; _timemin=2
         _timeavg=$(bc -l <<< "scale=3; $_timeval/$NmRun"); # e.g.: 178.512/393 => .454
         printf "TimeToRun: %s [%s mins] for $NmRun => %s\n" "$_timeval" "$_timemin" "$_timeavg" | tee -a "$TEST_HIST";
    else calcsecs -p "TimeToRun: " "$BgnTim"; fi
fi; exit $sts;

#############################################################################
# Everything below this point is for documentation purposes only (not code)
# TODO:
#############################################################################

#############################################################################
#_TEST_HIST_BGN # Document page delimiters; output via: getparmstest.sh --history
#
# History and Development Notes
# Functionality Added: Version 1.3.0 (most recent first)
# - Added comma lists for tests, e.g.: getparmstest.sh -tf47,53
# - Added number of tests & test option as test group begins
# - Added MRPP error test for SHIP with an endless parm (-b=...)
# - Added tests to check optional '=' in received value of SHIP items and
#   pure option with SHIP string and number is grabbed before SHIP & value
# - Added SHIP option tests (+-.,012) to verify subset of all SHIP datatypes
#   added collision test (MULO) with pure and SHIP options (e.g.: -b= and -b)
# - Added tests to verify negate extraction on matching ('@@@'|'%%%')
#
# Functionality Added: Version 1.2.0 (most recent first)
# - Added test for CF_RGXLOC configuration: disable location symbols for regex
# - Removed changing location symbol (as now same as datatype symbol)
# - Added test to cover '-o+' and verify it is '_o_plus'
# - Fixed missing carriage return after -do (TestOutputs) finished in all tests
# - Added Variety tests to cover end of beginning parms & end of options markers
#   as well as variations of ordering of required & optional parms and options
# - Added indenting for long lines in TestConfigs & TestMatches routines
# - Display samples (-so) no longer scraped from getparms, but are generated by
#   getparmstest -x and individual examples (-s?) now support ranges: {n{-{m}}}
# - Added TestTimings functionality to get average execution test times
# - Additional description (...Dsc2), which is part of TestErrored and Test
#   Configs, are now put on the same line as the main description (...Desc)
# - Added per process ID file extensions so that running multiple copies at
#   the same time the temporary hidden files won't collide
# - Separated out Error Explanation text from Help string for each error in
#   TestErrored in order to aid description summaries which only show error
# - Added --time flag to display prior execution times for running all tests
# - Added Test Configs for all config flags or document where they are tested
# - Optimized TestReqOpts: added -ce option & removed grep out of empty lines
#
# Functionality Added: Version 1.1.0 (most recent first)
# - Split out strings datatype tests into separate group (TestStrTypes [-ts])
# - Added redo individual test numbers without the full fail string
# - Added Examples support (-x) for generating getparms example text files
# - Added extra tests for additional 's' flags (abcdefghijklmnopqrstuvwxyz)
# - Added surrounding text before and|or after a string|num for values|enums
# - Fixed error where debug flags were passed unrecognized to getparms script
# - Fixed problem where some failed tests were reported twice, instead of 1x
# - Fixed problem where only first failed test was reported of multiple tests
# - Added history file to keep track of overall execution times for all tests
# - Added support for doing ranges of sub-groups of all tests
# - Added support for passing -o* option to all sub-tests
# - Added dequoting test to ensure quoted input isn't double quoted
# - Added error tests for illegal more items: {-f ...}, -f=..., and -i ...
# - Added redo failed test capability using capture string from previous test
# - Added end of options marker ('--') positive & negative tests for options
# - Added the 'more' tests for positive parms and for normal indirect parms
# - Added test to ensure ind options can't be part of the option combinations
# - Added test to ensure all indparms are received for mind (-f parm1 parm2)
# - Added error test to check -i -f=indp => -if val doesn't think f is valid
#
# Functionality Added: Version 1.0.0 (most recent first)
# - Added capture of failed tests for summary of all tests run in TestAllTest
# - Added time measurements for each test run to compare with previous tests
# - Added a 'do all' tests option (-ta) & to capture which subtest failed
# - Added test for every feature (in order to do isolated feature testing)
# - Added test to get every getparm error to check that the error is caught
# - Added check for output name collisions between options and parameters
#   (e.g. collisions: option -a & parm _a; option -a & parm a when -cl)
# - Added all the help support and passing of the debug options to getparms
# - Consolidate all errors & results in 1 place: PrintFailures & PrintResults
# - Added descriptions for all tests & support -t. to show test descriptions
# - Added the ability to do a specific test number or all tests of that type
# - Caught all errors where cat'ing temporary file when it does not exist
# - Added test capability (-to) to verify display output is as expected
# - Added test capability (-tf) to verify all features work as expected
# - Added test capability (-te) to verify all error cases in fact occur
# - Added test capability (-tp) to verify all preferences setting works
# - Added test capability (-tr) to verify required option setting works
# - Moved test processing from getparms to this script to simplify getparms
# - Added test capability (-td) to match the various kinds of datatypes
# - Added test capability (-tm) to match the many kinds of string types
#
# Overall Testing History
# - Verified all characters in ~s & ~v (e.g.: *!"',.)
# - Verified datatype only allowed after default value
# - Verified optional parms after end marker '--' fail
# - Verified default with undefined $var, rightly gives ""
# - Verified default with nothing (""), correctly gives ""
# - Verified no specified --, after begin required parms;
#   and Verified an option after first required parameter
# - Verified hex with 0x, with only x, & without anything
# - Verified if -v:verb|-verb:lverb works where name=verb|longverb
# - Verified identically named positional parms & options are caught
# - Verified all datatypes correctly limit the appropriate data values
# - Verified -f|--flag=indparm=value will work, changing SYMB_DFLT to =
# - Swapped 2 parsing symbols & verified parsing still works: -pa'?',g':'
#   HELP='func <file_txt~s@+".txt"> -v?verb:m~h:--verb -i {-j} [-m=ind_parm] \
#   -e <-f:--files ifile tfile ofile> {--} <param1~ip> [param2 param3~s-] # info'
#   getparms -d -cbors -pa'?',g':' "$HELP" file.txt 0x86 -ji --files in.txt \
#   tmp.txt out.txt 12 "all in" "all on";
# - Verified internal functions calls: getparms -x; getparms -x matchdata;
#   getparms -x matchdata ~s~@"bgn "+" End" "bgn me end";
#
#   Note: no special testing is needed to cover getparms configs (-c*) as these
#   are all covered by other tests. Thus, all the display changing configs are
#   handled by the Test Outputs function (i.e.: -c[abcdehlnqrsw]) and all the
#   feature related configs (i.e. -c[youmi]) are all handled by Test Feature.
#   Tried to get getparmstest to be called from getparms, but can't get working.
#
#_TEST_HIST_END # Document page delimiters
#############################################################################

#############################################################################
# General Notes
#TEST_ERRS="$TEST_ROAD/.${TEST_FUNC}.errs.txt"; # errs:  /user/bin/.getparmstest.errs.txt
#local HELP='func <file_txt~s-@".txt"> -v:vrb|m~s-|--verb -i {-j} [-m=ind_parm] -e <-f|--files ifile tfile ofile> {--} <param1~i+> [param2~s- param3] # more info';
#
# following doesn't work, spaces are seen as new array lines
#declare -a result=($(IFS=""; getparms -on -?"-h|--help" "$HELP" file.txt happy -ji --files in.txt tmp.txt out.txt 12 "all in" "all On" 2>$TEST_ERRS)); # NB: lose result of SUCCESS|FAILURE this way, but have it in func=n
#
# Testing Support
# Note: to rerun just failed tests copy the failed tests and do following -
# for i in 9 12 18 19 24 25 37 41 42; do getparmstest.sh -d -tf$i; press; done
# Note: spaces are preserved when in quotes, even leading ones
# '--': the end of options marker, no options allowed after it (i.e. -v|--verb)
#
# Specification Failure using ILLSRUN: -t- [getparms -crs -t-]
# func filein {-v|m|--verb|n}{-i:input~i} {-m=ind_parm~s-} {--} {--} <-o outfile> param1 [param2=" str 1 "]
# 09 [MEOM] Multiple end opt markers found: -- @ 8 & 10
# 05 [MORP] Multiple parm in a Mixed group: orig|name:m|n [2]
# 06 [DTOP] Datatype illegal on a pure opt: input with dtyp=6 [a generic integer]
# 10 [OADD] Pure|ind.option after dbl.dash: -o after 8
#
# Command-Line Failures using ILLCRUN: -tc [getparms -crs -tc]
#
# ErrorMsgs: 4
# 01 [PFER] Parameter format doesn't match: file_txt="file.ini" s/b: ~s%.txt$ [44:str has insen src] [1c]
# 03 [PFER] Parameter format doesn't match: m="happy" s/b: ~h [23:a hexadecimal num] [3c]
# 02 [UNKN] Unknown parameter was received: "-k"
# 08 [REQD] Required item was not received: _e
#
#  0 valid[1]: func=1
#  1 invld[1]: file_txt="file.ini"
#  2 misin[0]: verb=0
#  3 invld[1]: m="happy"
#  4 misin[0]: __verb=0
#  5 valid[1]: _i=1
#  6 empty[0]: _j=0
#  7 deflt[0]: ind_parm="edit"
#  8 misin[0]: _e=0
#  9 valid[1]: ifile="in.txt"
# 10 valid[1]: tfile="out.txt"
# 11 valid[1]: ofile="12"
# 13 valid[1]: param1="13"
# 14 valid[1]: param2="all in"
# 15 valid[1]: param3="all On"
#
#############################################################################

#############################################################################
# Following Tests were verified manually to check naming consistencies
# Escape Testing: NB: following also works: <file_txt~s%+\.txt$>
#############################################################################
# func <file_txt~s%+\.txt>     -v:verb|m~h|--verb {-in} {-io} -i {-j} [-m=ind_parm] -e <-f|--files ifile tfile ofile> {--} <param1~ip> [param2 param3~ss-] # info
# func <file_txt~s+-j%+".Txt"> -v:verb|m~h|--verb {-in} {-io} -i {-j} [-m=ind_parm] -e <-f|--files ifile tfile ofile> {--} <param1~ip> [param2 param3~ss-] # info
# getparms -di -ccb -~ "func -i:iname n:pnam -f:felt=m:indp {-g:gain o:oral}" -i 5 -f 5
