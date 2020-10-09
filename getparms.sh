#!/usr/bin/env bash
#############################################################################
# environment related defines needed at beginning that affect execution
#############################################################################
export LC_ALL=C;             # disable Unicode expansion for speed (saved ~4s)
                             # this also forces the C sorting order: A-Za-z
shopt -s extglob;            # enables: ?=0|1, *=0|+, +=1|+, !=except
set +H;                      # disables var. '!' expansion (cmd history search)
                             # otherwise can't do neg. look behind regex tests
GETPARMS_VERS="1.0.4";       # present version of this utility

#############################################################################
# Note: the welcome banner below is only output the first time a new user
# requests a bare help (i.e. getparms with no options) or with -w option.
#----------------------------------------------------------------------------
#_WELC_BGN # Document page delimiters; o/p via: getparms -w
#
# Welcome, new user to the getparms.sh script! As a new user it helps to
# to get to know the extent of the capabilities getparms provides. So the
# detailed help pages will be shown you, once only; but it can be seen any
# time by calling --help. [To show this banner again, run: getparms.sh -w]
#_WELC_END # Document page delimiters; o/p end: getparms -w
#############################################################################
#############################################################################
#_DESC_BGN # Document page delimiters; o/p via: getparms -help
#
# getparms is a generalized, configurable Bash command-line parsing utility
# with an extensive list of capabilities that outputs results to the caller
# in a printed-array format. It is highly configurable, both in its display
# output & in command-line processing. It is speed-optimized (as far as Bash
# scripts can be). It handles pure options, positional parms, indirect parms
# (new & old forms) with support for short and/or long options, & a new type:
# short-hand indirect parms. It handles beginning parms that come before any
# options, and adds a new end of begin parms marker (-+) where options begin
# as well as supporting the standard end of options (--) where options cease.
# It thoroughly checks for specification errors & command-line errors, giving
# individualized error messages per type that show the incorrect item & what
# position it occurred. Where an error causes cascading errors, the secondary
# errors are filtered out. Where any specification error does not prevent cmd-
# line processing it is downgraded to a warning and processing continues.
#
# It also supports datatype checking, value and range checking, limiting the
# received values to a set of enumerated values, alternate naming of options,
# and also endless parameters (when the number of parameters is variable).
# It supports item grouping where only 1 of the items can validly be received.
# It supports full & partial string matching with or without Bash ERE regex.
# [All features have been thoroughly tested via the script: getparmstest.sh]
# It runs on Linux in Bash and supports Apple's Darwin GNU bash 3.2.57(1).
# All this is with a simple help style syntax in the form of a HELP string
# (or an exported variable which contains the help string). The latter is
# useful for not cluttering the command-line. The help string lists all the
# expected inputs. The help string forms the specification, which defines:
#
#      (1)  the name & the ordering of all items;
#      (2)  how many parameters that an item has;
#      (3)  if an item is required | is optional;
#      (4)  if an item is part of an OR'ed group;
#      (5)  if it is a positional parm, indirect parm, option
#
#_DESC_END # Document page delimiters; o/p end: getparms -help
#############################################################################
#############################################################################
#_FEAT_BGN # Document page delimiters; o/p via: getparms --feat
#
# Why another bash argument|command-line parser? Aren't there enough already?
# What do we still need that the other bash command-line parsers aren't doing?
#
# First, we need an argument|command-line parser because doing the same thing
# over and over again is tedious and error prone. We should do it once and do
# it right, so we can depend on it every time to do the mundane functions.
# That's the purpose of scripts in the first place: doing repetitive tasks.
# Such a functionality should be a built-in utility as part of this|any shell.
#
# Second, most scripts are not written robust enough, because insufficient
# time and effort has been put into the argument parsing, just because it is
# tedious and often not 'worth the effort' from the script writer's point of
# view. This puts all the future users of the script in jeopardy, because
# not all the cases have been considered and designed in. The use of a well-
# tested command-line parser eliminates the undependability of user scripts.
#
# Third, some argument parsing tasks are often hard to get right, so that
# they are flexible enough to handle all the normal use cases. Handling all
# the different ways a script can be run can be exhausting and it is easy to
# miss some. By handling this in a well-tested argument parser, we know that
# all the cases are already covered and we can concentrate on our own script.
#
# Fourth, because user scripts are written typically just to get the job
# done, they are not extensible. Every time a change is made to the script
# by adding or changing the command line arguments, we risk breaking the
# whole script. By defining a clear specification for arguments, we can
# avoid this and make the changing of command line arguments a simple task.
#
# So what kind of tasks should a complete argument parser be able to do?
# Consider the extensive list of features that are supported by getparms:
#
# A. Basic Capabilities & Error Checking
# - support intermixing options with positional parms
# - support for optional and required positional parms
# - support whitespace in any run-time parameter values
# - support pure options (for any order): -c -o | -o -c
# - support indirect options (any order): -i indp -o out
# - support short and long option naming: -a & --auto-par
# - ensure multiple options with same name aren't received
# - ensure multiple OR'ed opts aren't rcvd: -a & --auto-par
# - handle end of options marker (--) to end options parsing
# - ensure gather all required parms, then get optional parms
# - a well-defined, simple syntax for specifying cmd-line args
# - default help opts for the caller's help utility (-h|--help)
#   & ability to change them to other options or even disable it
#
# B. Robustness & Configurability
# - extensive error checking for non-conforming arg conditions
# - support for old-style indirect parameters (e.g.: -o=outfile)
# - support for suppression of error messages (i.e. a quiet mode)
# - support the ability to tailor the output returned to the caller
# - thorough checking of command-line argument specification ensures
#   that what the user has specified actually makes sense in practice
# - distinguish between fatal & non-fatal specification errors, which
#   allows program to go on & process command line items where possible
# - the ability for the user to pre-test just the specification in order
#   to ensure the specification is valid & supportable [the Analyze mode]
# - support for disabling of capabilities which are not needed or are not
#   desired (e.g.: disable support for combining of single letter options)
# - support for changing whether the delimiters imply required or optional
# - ensure all argument names are unique, even between parameters & options
#
# C. Advanced User Capabilities
# - support for changing parsing symbols to match one's own needs
# - support indirect options with multiple parms: {-o in out temp}
# - support Short-Hand Indirect Parms (no equals): -n# (# an integer)
# - support combining of pure options (in any order) for single letter
#   options (-i -o => -io|-oi) and dual letter options (-in -io => -ino)
# - support linking OR'ed options, so only one received (e.g.: -v|--verb)
# - support for multiple consecutive parameters when the number of parms
#   is unknown beforehand, only at runtime (e.g.: num ... or -f file ...)
#   with auto-naming of 'consecutive' arguments (e.g.: num_1, num_2, ...)
# - support for alternate output naming for any option so that it doesn't
#   need to be constrained by its option string search (e.g.: -o:output)
# - support the grouping of arguments with the same requirement condition;
#   following usage makes both parm1 and parm2 be optional: [parm1 parm2]
# - allow mixing options & a positional parm so 1 or the other is received
#   (e.g.: -i|--out|num); -i or --out or parm 'num' is allowed (but only 1)
# - support parm type-checking: is it a string, an int, a number, or an int
#   |string preceded|annexed by specific text (e.g.: $, %, 'From:', '.txt')
# - support for parameter enumerations and parameter range checking where
#   the range checking is numerical for integers and lexical for strings
# - support Extended Regex Expressions for string matching of parameters
# - specialized data checking: validate IP|MAC|email address formatting,
#   positive|negative numbers|integers only, hex number checking (with|
#   without 0x or x prefixes), binary number checking, string checking
#   all caps|small with|without spaces with|without symbols, checking if
#   an input has a valid path or is a valid file or is readable|writable
# - support beginning parms which occur before any options are allowed
# - captures all specification or command-line errors before quitting,
#   so that all errors are known (and not just the first one caught)
# - optional printing of spec parsing (based on configuration option)
#   allows the script designer as well as the script user to see how
#   the specification as well as the command-line inputs were parsed
# - handles hex input: converts all declared hex integers to decimal
#   & auto-converts any integer that begins with 0x|x|\x to decimals
# - when multiple indirect parms | Short-Hand Indirect Parms received
#   for the same option, all values are stored in the output variable
#   separated by equals so the caller can know all the values received
# - support multi-line help string output via embedded carriage returns
# - extensive debugging feature allows user to see what getparms is doing
#
# D. Limitations
# - in order to reduce the complexity and increase the speed of getparms,
#   no specification values (e.g. enums & range checking values) can have
#   any whitespaces; Note: this does not affect the values received from
#   the command-line input, which may freely have whitespaces in them
#
#_FEAT_END # Document page delimiters; o/p end: getparms --feat
#############################################################################
#############################################################################
#_INFO_BGN # Document page delimiters; o/p via: getparms --help
# Overview: getparms parses the command line on behalf of the caller, based on
#           the caller's supplied HELP string, which acts as a specification;
#           getparms verifies all required items are received, collects optional
#           ones, checking each item's position, number, datatype, & even range;
#           getparms generates an error list, & outputs the results in a user
#           configurable 'array' format to the console so the caller can grab
#           the results for each item by looping through each one to check for
#           any detected errors or for the received items. In looping over the
#           received output lines, the caller can match the item by it's name
#           (as described in the Naming section below). The beauty of getparms
#           is instead of using an arcane specification format, it uses the
#           calling function's own HELP string to establish the format for all
#           options and parameters that is familiar to most 'Nix script users.
#
# ArgTypes: First we must describe the different arg types supported, specially
#           their features & their differences. Arguments can be broken up into
#           2 major areas: Parameters & Options. 1) Parameters are positional
#           items that stand alone with no prefixed dash [i.e.: '-'|'--'] & have
#           a fixed place in the cmd-line (ignoring options). [Henceforth they
#           are called: 'parms'. Note: any leading hyphen in this case will be
#           seen as part of the parm.] Parms are specified as required|optional.
#
#           2) Options are positionally-independent flags & come in any order.
#           They are always prefixed by a hyphen(s). They are often perceived as
#           optional (only), but in fact sometimes it is useful to make them be
#           required. Options can come in short|long form, where the short form
#           is one letter (or a few) preceded by 1 dash (e.g.: -a | -in); the
#           long form is a descriptive word|phrase preceded by 2 dashes (e.g.:
#           --miles-per-hour). Four types of options are supported by getparms:
#
#           a) Pure Options are stand-alone options, which act as flags; they
#              are either received or not received (& so evaluate to: 1 or 0).
#           b) Normal Indirect Parms (NIP) are options followed by 1+ required
#              parms. Note: an ind. parm can be specified as required|optional,
#              but once a user in the command-line supplies the option (even
#              if optional), the associated specified parms are now all required.
#              In the normal form, the option is separated from the required
#              parm(s) by 1+ spaces in short|long form (e.g.: -i infile | --input
#              infile). To signal this is not a pure option followed by a posi-
#              tional parm, they must be enclosed within delimiters as follows:
#              <-a|--amount parm> [-t|--time parm] {-s|--sides parm1 parm2 ...}
#              [Note: any of the delimiter pairs may be used to specify NIPs.
#              Indirect parms from here on will typically be called indparms.]
#           c) Old-Style Ind Parms [OSIP] work like normal indparms with the
#              following changes. In OSIP all intervening spaces are replaced
#              with an equals sign (=), e.g.: -i=input | --in=input. OSIP is
#              limited to 1 parm only. As a result, it does not require to be
#              within matching delimiters, for example: -i|inches=input;
#              Thus, {-f prm1 prm2} means both prm1 & prm2 are indparms of -f,
#              while {-f=prm1 prm2} means only prm1 is seen as indparm. of -f,
#              while prm2 is a completely independent positional parameter.
#              Note: when parsing the received command line arguments, the
#              default for getparms is to support both formats. The OSIP form
#              may be disabled for the command line (via config option: -ci).
#           d) Short-hand Indirect Parms [SHIP] are a combination of pure option
#              and positional parm introduced by getparms as a user convenience.
#              They are an indparm with no space & the value abuts the option.
#              [Optionally an equals ('=') may also separate the option & parm.
#              This handles the awkward SHIP --m-p-h= received as --m-p-h-10.5,
#              instead of the much more readable cmd-line input: --m-p-h=-10.5]
#              It is always specified as an OSIP without a name (e.g.: -d=) &
#              the cmd-line is the option & value (e.g.: -d5 | -d=-3). Values
#              can be: empty, +|-, and|or a numeral (integer|decimal), followed
#              optionally by nothing or a sequence of numbers (comma separated,
#              e.g.: -d-5.1,6.2), or a closed range of numbers (e.g.: -d-4--14),
#              or an open range of numbers (e.g.: -d5- or -d5+). The option can
#              be short|long, but unlike indparms, the short & long option SHIPs
#              must be specified separately & OR'ed together (e.g.: -s=|--m-p-h=).
#              SHIP items can't be named the same as pure opts (e.g.: -d= -d).
#              The allowed forms are: -d, -d+, -d-, -d#, -d#+, -d#-, -d#,#, -d#-#
#              [To restrict these see the section "SHIP:" under Configurability.]
#
# EndOpt:   Double dash (--) signifies the end of command line options, after
#           which only positional parms are allowed (no: -o|--out). One EndOpt
#           can be in the specification. If no EndOpt is specified, it is auto-
#           determined when parsing the HELP string. If '--' is in the command
#           line before the specified/auto-determined one, it takes precedence.
#
# BgnOpt:   BgnOpt is added to support beginning optional positional parms. A
#           dash plus (-+) signifies the start of command line options, before
#           which only positional parms are allowed (no: -o|--out). One BgnOpt
#           marker can be specified. If no BgnOpt is specified, it will be auto-
#           determined when parsing the HELP string. If '-+' is in the command
#           line before the specified|auto-determined one, it takes precedence.
#           [As this is non-standard, the symbol is configurable (e.g.: '++').]
#
# Naming:   Regular parms & Indirect parms (e.g.: count & -f infile) use their
#           parm strings (i.e. 'count' & 'infile') as the output variable name.
#           Pure options & SHIP opts (e.g.: -a|--arg-parse & -d=|--miles=) use
#           their option strings with all dashes changed to underscores ('_')
#           as their output variable name (e.g.: _a|__arg_parse & _d|__miles).
#           Note: ALL dashes are changed to underscores (i.e. __arg_parse, not
#           __arg-parse), so if the user desires, he can eval the value output
#           by getparms right into his own variable, e.g.: eval "__arg_parse=1".
#
#           To support end of options ('--') & end of begin parms ('-+') markers
#           a trailing '+' in an option is translated to '_plus', so the output
#           names for these are respectively: __ & __plus. Doing this prevents
#           output name collisions between similarly named options ending one
#           ending in + & the other not (e.g.: -b & -b+ => _b & _b_plus).
#           Note: a final plus sign ('+') is also allowed on any pure option
#           in order to support the following useful OR'ed group: -a|-a-|-a+.
#           Normally output names for this OR'ed group would be:  _a|_a_|_a, but
#           this causes an output name collision for the 1st and last options
#           (-a & -a+). To prevent this, the output name of any option ending
#           in '+' will be changed to '_plus' (e.g.: -a+ => _a_plus).
#
#           Optionally, the names for both pure options & SHIP opts can both be
#           configured to drop the leading underscores via the -cl config option
#           [e.g: _a|__arg_val => a|arg_val; _n|__num => n|num; __plus => plus]
#           The end of options marker (--) is unique as it only consists of 2
#           hyphens, so in this case leading underscores aren't dropped (__).
#           Note: If a pure option contains integers in its name (e.g.: -b5) &
#           a SHIP has the same leading letters as that pure opt (e.g.: -b=), then
#           the value of 5 for the SHIP item is effectively 'stolen' as it will
#           always be seen as the pure option (-b5). The avoid this (1) change
#           the name of either the pure option (e.g.: -b_5) or the SHIP, or (2)
#           to use the old-style SHIP format in the command-line (e.g.: -b=5).
#
# AltNames: Due to the shortness of names for pure opts & SHIP opts and because
#           they have no associated parm, which can be freely named, along with
#           the limitation that their name is used to find the option, it is
#           advantageous to support alternate names for these item types. For
#           consistency, alt. names are also allowed on the option part of an
#           indirect parameter (e.g.: -f:altname indparm). Alternate naming is
#           specified by adding a colon after the option (e.g.: -i:index |
#           -n=:number). These allow the output names for any option to be much
#           more descriptive. These alt. names are used when showing the result
#           of parsing the command-line. Note: alt. names are not needed (and
#           generate warnings, e.g.: 02 [PALT]: Params can't have an alt. name:
#           'n' has altname: 'pnam') for parms because the user can freely assign
#           names as they aren't used directly when parsing the command-line.
#           [Note: as these are warnings, not errors, processing will continue.]
#
#           As a result we get the corresponding output names for the inputs:
#           1) the pure option:  -o|--out           => _o|__out (or out)
#              alternate names:  -o:on|--out:other  => on|other
#           2) short ind. parm:  -n=|--num=         => _n|__num (or num)
#              alternate names:  --num=:alt|-n:num= => alt|num
#              NB: alt. name can come before|after the SHIP marker ('=')
#           3) indirect option:  -f infile          => _f   & infile
#              alternate names:  -f:file infile     => file & infile
#           4) oldstyle indprm:  -f=infile          => _f   & infile
#              alternate names:  -f:file=infile     => file & infile
#              alternate names:  -f=infile:file     => file & infile
#              NB: alt. name can come before|after the OSIP marker ('=')
#           5) named parameter:  count              => count
#
# Required: Grouping delimiters (as well as the no-delimiters case) make all the
#           contained arguments to be of the same type regarding being required
#           or being optional arguments. The defaults are as follows: 'empty'
#           (i.e. no delimiters) and Angle delimiters ('<>') are both required.
#           While Parens ('()') and Curly delimiters ('{}') are both optional.
#           [Note: the defaults can be changed (see the Options section later).]
#
# Format:   inputs are specified via the HELP string with the syntax shown below.
#           The HELP string is in a specific format where spaces represent the
#           division between items to parse, unless within a quoted string. As
#           a result, getparms can process items as regular command line items
#           & doesn't need time-costly parsing. Note: anything after a space &
#           hash (' #') is seen as an 'end comment' and is ignored in processing.
#
#           -------------------------------|-------------------|----------------
#           input item   | official format | getparms format   | also supported
#           -------------|-----------------|-------------------|----------------
#           required arg | <angle_bracket> | <angle__brackets> | no_delimiter *
#           optional arg | [squarebracket] | [square_brackets] | {curly_braces}
#           indirect prm | -f|-file infile | -f|-file infile   | -f|-file=infile
#           short indprm | (not supported) | -d# (where '#' is a pos|neg num or
#                        |                 |     a closed/open range: -d5-7|-d5-
#           end comments | (not supported) | usage comments (end of help string)
#           --------------------------------------------------------------------
#
# Linking:  Sometimes items are "one or the other, but not both" (meaning, it is
#           OK to receive -i | -o, but not both). This is done via OR'ed groups,
#           e.g.: -i|-o. OR'ed groups are split into options & 0 or 1 named parms
#           (e.g.: -v|--vrb|m|-i=file; where -v & --vrb are short & long options,
#           m a pos. parm], & -i=file an OSIP). All of these items are linked so
#           that only 1 can be received. In an OR'ed group, multiple options are
#           allowed to indicate different user modes, but at most only 1 pos. parm
#           is allowed as only 1 could ever be received (which would always be
#           the first 1 specified). So if > 1 pos. parms is specified in an OR'ed
#           group, it is flagged as an error. Note: normal indirect parms are
#           not allowed to be specified in an an OR'ed group, but on the command
#           line the OSIP can be given with space(s) instead of the equals.
#
# ------------------------------------------------------------------------------
#  Note the close look alikes of OR'ed groups, OSIP item, & normal ind parms
#  with both short and long options specified and observe their differences:
#   -f|--file=           => 1 OR group (-f pure opt or SHIP [--file=])
#   -f=|--file=          => 1 OR group (2 SHIP parms [-f= or --file=])
#   -f|--file|prm1       => 1 OR group (2 pure opts [-f or --file] or a parm)
#   -f|--file=prm1       => 1 ind parm with 2 OR'ed options [-f|--file & prm1]
#   -f|--file=prm1 prm2  => 1 ind parm [-f|--file & prm1] & 1 pos. parm [prm2]
#  {-f|--file=prm1 prm2} => 1 ind parm [-f|--file & prm1] & 1 pos. parm [prm2]
#  {-f|--file prm1 prm2} => 1 ind parm [-f|--file] having 2 parms [prm1 & prm2]
#  {-f|prm2|--file=prm1} => 1 OR group [-f opt or prm2 parm or indparm [--f prm1]
#  {-f|--file=prm1|prm2} => 1 OR group (1 indparm [-f or --file & parm1] or 1 parm)
#  [Putting the pos parm at the start makes no difference {prm2|-f|--file=prm1}
#  but putting it between the short & long options clearly makes a difference.]
# ------------------------------------------------------------------------------
#
# Multiple: Multiple indirect parms (e.g. {-i|--in parm1 parm2}) can be specified
#           only by placing them in the same delimited group: (), {}, [], <>.
#           Note that OSIP (-i=parm) only support a single indirect parameter.
#           Multiple indirect [a.k.a. MIND] groups can be specified as required
#           or optional, but even if the group is optional, once the option is
#           received then all the specified parms will then be seen as required.
#
# Endless:  To support endless|more consecutive indirect|positional parms when the
#           number of parms is unknown, the SYMB MORE symbol is used, the ellipsis
#           ['...'] by default. It must immediately follow 1 named parameter with
#           a preceding space. E.g.: named ...; clearly an indefinite parm symbol
#           must be the last item specified (other than the end comment). Given
#           a parm name 'parm' {-f parm}, each of the received command line parms
#           will be named: parm_1, parm_2, parm_3, etc. Note the SYMB MORE
#           symbol can be changed from its default value. [See Prefs. section.]
#           Note the distinction between <-f prm1 prm2 ...> and <-f prm1 ... >.
#           The first means we must get prm1 & prm2; the second only prm1.
#           Note: Pure options, indp options, and SHIP items can't be endless.
#
# Help:     The caller's help options default to -h|--help, but can be altered.
#           To specify new help options they must immediately follow the help
#           option ('-?') and due to the pipe symbol must be quoted. Examples:
#           To change short & long help opts to '-i --info' do: -?"-i|--info"
#           NB: when using '|' the quoted string must but up to -? with no space
#           & if unquoted, it gets the error: -bash: --help: command not found;
#           To disable long or short help opts do one of these: -?-i or -?--info
#           To disable both of short and long help options use: -?
#
#           The HELP string should be quoted to support 1 or more items. It must
#           begin with the calling script's name, followed by all the supported
#           options & parms, and optionally it can be followed by the comment
#           marker ('#') & comments. After the HELP string are the actual cmd-
#           line entries; e.g: -~ "func {-m} leng # -m metric (m), else in feet"
#           The script's name must be a valid varname: ^[A-Za-z_][A-Za-z_0-9]*$
#
#           The HELP string can also be indirectly specified via an exported var.
#           In this case the HELP string need not be quoted as it will only be
#           the exported varname. This is specified by making the HELP string
#           be only the exported varname preceded with a period ('.'). Note:
#           the varname (excluding the prefixed period must meet the rules of a
#           Bash variable, i.e.: ^[A-Za-z_][A-Za-z_0-9]*$ [E.g.: -~ .MY_HELP]
#           Note: varname can't be '__HELP__', the internal local help variable.
#
#           To get help on this utility, run getparms with no options or '-h'
#           (for brief help) or '--help' (for extended help, show these notes).
#           Other specialized help info include: --version|--examples|--history,
#           which will respectively give the version, examples, change history.
#           For added debug help include the debug option'-d': getparms.sh -d -h
#
#           Note: --examples shows a list of output variations (starting with the
#           most verbose to the least verbose) based on different configurations.
#           To show a specific example|range: --examples -do{n{-{m}}}; where
#           -do lists a summary, -do# shows only '#' & -don-m shows 'n' thru 'm'.
#
# Invoking: When getparms is invoked, options are allowed in any order as long
#           as they all come before the Specification (i.e. the HELP string).
#           The trigger for getparms to capture the Specification is either:
#           a. the optional help defaults options: -?
#           b. the optional Specification option:  -~
#           One of these must directly precede the Specification parameter.
#           Note that 2 common problems with running getparms is forgetting:
#           1. to have one one of these indicators preceding the HELP string
#           2. to put the function name as the first item in the HELP string
#
# Advanced Users
#-------------------------------------------------------------------------------
# Combos:   Combination of single letter options is a feature that if -i & -v
#           are defined options, it allows -vi or -iv to be entered in the
#           command line & both options will be enabled. This feature is auto-
#           enabled by default, but can be disabled (via -cm). ComboOpt only
#           makes sense if there are no multi-letter options (e.g. -input).
#           If this is found in the spec, then this feature is auto-disabled.
#
# DataType: Typed data can be specified to limit the values of an argument. These
#           can be specified on positional|indirect parms, but not on pure opts
#           (e.g.: -i|--verb), which are only received or not. Enable datatype
#           checking by post-fixing parm with a tilda ('name~') & the datatype.
#           1. Specialized Values (use: ip{4|6}{d|h},mac,web,e):
#              Supports: IP & MAC addresses, websites, email
#              ip4d & ip4h : IPv4 in decimal & hex format
#              ip6d & ip6h : IPv6 in decimal & hex format
#              ip4  & ip6  : IPv4 & IPv6 in decimal | hex
#              ipd  & iph  : IPv4 | IPv6 in decimal & hex
#              ipg  & mac  : generic IP & a MAC address
#              e           : emails like: name[.last]@domain.ext
#                            [A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$
#              web         : [http[s]:://][www.]site.org[/*] <= no spaces allowed
#                            www.url-with-querystring.com/?url=has-querystring
#                            [mailto:]person@site.com
#
#           2. String Types (s|v): the 2 string types are variable names ('v') &
#              generic strings ('s'). Generic strings may contain any character,
#              while variable names must begin with an underscore|letter and the
#              rest of the characters (if any) must be underscores|letters|numbers.
#              Each of these 2 string classes have postfix letters, which if used,
#              specify what characters are allowed. Varnames, as mentioned, have
#              only the following 5 sub-types: un~+- (which are described below).
#
#               v : varnames     [_a-zA-Z][_a-zA-Z0-9]* <= un~+-
#              ---------------------------------------------------
#               ~ : case ins.    [a-zA-Z] => [a-zA-Z][a-zA-Z]*
#               + : capitals     [A-Z]    => [A-Z][A-Z]*
#               - : lowercase    [a-z]    => [a-z][a-z]*
#               u : underscore   [_]      => [_][_]*
#               n : numbers      [0-9]    => illegal by itself
#              ---------------------------------------------------
#              Thus ~vcln yields [a-zA-Z][a-zA-Z0-9]*
#
#               s : any char with subtypes <= abcdefghijklmnopqrstuvwxyz~+-
#              ------------------------------------------------------------
#               a : at mark      [@]         |  n : numbers       [0-9]
#               b : backslash    [\\]         |  o : or sign       [|]
#               c : colons       [:;]        |  p : plus          [+]
#               d : delimiter    [[]()<>{}]  |  q : quotes        ["']
#               e : equals       [=]         |  r : rest          [,]
#               f : fwd slash    [/]         |  s : star|asterisk [*]
#               g : grammar      [!?:;,.]    |  t : tilda         [~]
#               h : hash mark    [#]         |  u : underscore    [_]
#               i : inquiry      [?]         |  v : percent       [%]
#               j : jot|period   [.]         |  w : white(space)  [ ]
#               k : caret|hat    [^]         |  x : exclamation   [!]
#               l : logic|math   [*/~=|&^%]  |  y : symbols       [@#$\]
#               m : minus|dash   [-]         |  z : dollars       [$]
#              ------------------------------------------------------------------
#               Note: some symbols can be set individually or as part of a group.
#               Those that can't be set individually include: colons, delimiters,
#               ampersand ('&'), dollar sign ('$'). Backtick (`) isn't supported.
#
#           3. Numeric Types (uses: B,b,h,i|n{p|n},%{#}):
#              [numbers can have decimal point (3.14), but integers can't]
#              B   : zero|one;  b  : boolean (010);  h : hex int (no +/-);
#              ip  : pos. int;  in : neg. integer;   i : pos/neg. integer;
#              np  : pos. num;  nn : neg. numbers;   n : pos/neg. numbers;
#              %   : 0-100 num;                      # : unsigned integer;
#              %n{-m} : n{-m} specifies a simple inclusive range, n <= x <= m;
#              if m is unspecified, the range is respect to zero, 0 <= x <= n;
#              the '%' symbol may be optionally omitted (the default datatype);
#              NB: n{-m} is a number if either n|m are a number, else it is an
#              int (i.e.: 50.0|50). Note percents values (n|m) can be negative.
#
#              All numeric types (except percents) support the special value
#              types of surrounding strings, values, enums, & ranges. [For
#              details on these value types see the Values section below.] To
#              specify surrounding strings the numeric type must be followed
#              by a string type s|v (& options: abcdefghijklmnopqrstuvwxyz~+-).
#              [NB: the string type for special options ~|+|- may be omitted.]
#
#           4. File Type (uses: f|d|p{-},fr{w},fw,):
#              f  : file (verify exists);  fu : file (verify file's dir exists)
#              d  : dir  (verify exists);  du : dir  (verify parent dir exists)
#              p  : path (a file or dir);  pu : path (verify path's dir exists)
#              pr : path readable;  pw : path writable;  prw: path read & write
#              dr : dir  readable;  dw : dir  writable;  drw: dir  read & write
#              fr : file readable;  fw : file writable;  frw: file read & write
#              fx : file exe; frx: rd+exe; fwx: write+exe; frwx : rd+write+exe
#
# Modifier: Each of the item types have unique modifiers that they support (e.g.:
#           altname [alt] or datatype [typ]). To simplify & speed up processing,
#           items only support one modifer. So SHIP items do not support number
#           datatypes. [The exception is indparms where the option supports alt
#           names.] Notice the altname is joined to the option that it modifies.
#           The modifiers supported for each specific kind of item are:
#
# Item Type Support  |alt|typ|multi|mor|  base e.g.   |  alt/type      |  swapped
# -------------------|---|---|-----|---|--------------|----------------|--------------
# 1) unnamed options | + |   |     |   |  -i:index    |                |
# 2) short ind. parm | + |   |     |   |  -d:dist=    |  -d=:dist      |
# 3) old-style indp. | + | + |     |   |  -p:per=dir  |  -p=dir~d      |  -p:per=dir~d
# 4) indirect option | + | + |  +  | + | {-p:per dir} | {-p dir~d}     | {-p:per dir~d}
#                    |   |   |     |   | <-d len wid> | <-i fil~f ...> |
# 5) positional parm |   | + |  +  | + | file~s%+.txt | terms ...      |
#
# Values:   Datatypes marked with an asterisk ('*') on -ht output support: value,
#           range, & enum types, while datatypes marked with a plus sign ('+')
#           support: value & enum types (but not ranges). Support for these is
#           done by following the datatype with a matching separator & separating
#           extra items with the same separator. There are 2 kinds of matching
#           separators: plain ('@') & regex ('%') [the symbols are configurable].
#           Plain matching uses standard Bash pattern matching, while all the
#           regex matching uses Bash Extended Regular Expressions (ERE) matching.
#
#           This means when doing regex matching, that any string with special
#           regex chars (i.e.: .+*?^{}()[]|$), which are not intended to be
#           used in their special sense, must be handled specially. Typically,
#           this means escaping them, but square brackets & parens are unique.
#           [See Regex section below for info on delimiter 'unique' handling.]
#           NB: Spaces can be in any command-line value by quoting the item,
#           but spaces cannot be in the datatype values or ranges or enums
#           (in order to speed up and simplify getparms parsing requirements).
#
#           1. Values can be plain matching or regex matching. Plain matching
#           uses 1 value preceded by the 'plain' separator ('@'), e.g: -i@5
#           [Single values may not seem useful initially, but consider this:
#           ~s@yes [which requires the user to enter a case insensitive "yes"].
#           Regex matching uses 1 value preceded by the regex separator ('%'),
#           e.g: -i%5 [which will find if 5 is in the received string anywhere].
#           [To specify where in a string the pattern is see section: Location.]
#
#           2. Enums allow multiple values separated by value dividers ('@|%').
#           Enums are either plain pattern matches ('@') or regex matches ('%'),
#           as follows: ~s@__@__{@__}... or ~s%__%__{%__}.... Note: immediately
#           after a string or variable datatype (~s|~v) can be its sub-types.
#           E.g.: 3 lower case plain enums: ~s-@slow@med@fast. Enums may have
#           2 or more values, which the received value will be checked against.
#           Note: if the case type string specifiers are used (~|-|+), this
#           will overrule the case of the enums. Thus, ~s+@slow@med@fast will
#           match FAST, but not fast as the matched string must be uppercase.
#           For exact matching don't use a case specifier, e.g.: ~s@slow@fast
#
#           3. Ranges are only plain matching, requiring 2 values separated by
#           a range divider ('-'), where the low value is 1st & high value 2nd.
#           This ordering is not enforced, but if violated no value will satisfy
#           the test. A valid sample range is: -i@-4--1 [expects ints between
#           -4 and -1, inclusive]. Ranges also apply to strings where range
#           checking is done alphabetically. E.g.: ~s-@head-hear [This ensures
#           the string is lowercase & sorts between head & hear, inclusively].
#           [Ranges with the location symbol (def. '~') are flagged as errors
#           so that there is no confusion between ranges and surrounding text.]
#
#           Percentage datatypes (%) are a special type of range where 0, 1, or
#           2 limit values may be given. In this case where the 2nd value is not
#           (m) it is defined to be zero. If not values are given, the 1st value
#           (n) is defined to be 100. So the default range is: 0 <= rcvd <= 100.
#           So ~% (or ~) is a range of 0-100 & ~%-2.5 gives a range of -2.5-0.
#
# Location: For values and enums (not ranges), the matching of the string will
#           vary based on a specified location symbol ('~') as follows:
#           match whole of a string with a value/enum leave as is:   @str   [ALL]
#           match start of a string with a value/enum postfix with:  @str~  [BGN]
#           match trail of a string with a value/enum preface with: @~str   [END]
#           match midst of a string with a value/enum surround w/:  @~str~  [ANY]
#           match outer of a string with a value/enum pre+postfix:  @as~bs  [GRD]
#           match inner of a string with a value/enum pre+postfix: @~as~bs~ [SLC]
#           Note: the location symbol can also be used with regex searches ('%'),
#           but with regex searches the default (with no location) is to do: ANY.
#           With regex searches instead of using the location symbol, the standard
#           locators can also be used: ^ (for starting match) & $ (for end match).
#           Note: when the datatype symbol is changed (via: -pt), the location
#           symbol (SYMB MTCH) will also be changed to the exact same value.
#
# Extract:  Datatypes also support string extraction. When the separator symbol
#           is repeated twice in succession for plain or regex matching (i.e.:
#           '@@'|'%%') then extraction is done if the match is found. Note: the
#           following examples are for the equal value type, but extraction is
#           also supported for enum and surround types (but not for ranges).
#
#           a) without extraction whole matched string is returned:
#           parm~s@+end    with "prebookend"  => parm="prebookend";
#           parm~s@pre+    with "prebookend"  => parm="prebookend";
#           parm~s@+book+  with "prebookend"  => parm="prebookend";
#
#           b) with a plain extraction matched part is removed:
#           parm~s@@+end   with "prebookend"  => parm="prebook"
#           parm~s@@pre+   with "prebookend"  => parm="bookend"
#
#           c) mid plain match, all matches replaced with space:
#           parm~s@@+book+ with "prebookend"  => parm="pre end"
#           parm~s@@+to+   with "1tomanyto1"  => parm="1 many 1"
#
#           d) with extraction the regex match is retrieved:
#           parm~s%%+end.  with "prebookends" => parm="ends"
#           parm~s%%pr.*   with "prebookend"  => parm="prebookend" # match to end
#           parm~s%%pr.+   with "prebookend"  => parm="pre"
#
#           e) mid regex match, only 1st match is retrieved:
#           parm~s%%+boo.+ with "prebookend"  => parm="book"
#           parm~s%%+to.+  with "1tomanyto1"  => parm="tom"
#
#           f) e.g. mid regex match using character ranges:
#           parm~s%%+ma[l-n][x-z]+ with "1tomanyto1"  => parm="many"
#
#           g) numeric types with a specified string type without a surrounding
#           string will remove the specified string type(s) and replace them a
#           space [Note: leading space(s), trailing space(s), & multiple spaces
#           within the string are removed in this case as shown in the example]
#           parm~is-       with "a5b6 def7"   => "5 6 7"
#
# Negate:   When extracting, we may not always want what what was left over (as
#           in the case of plain extraction) or what was matched (in the case
#           of regex extraction). For this we have the negated extraction, which
#           is specified by tripling the separator symbol: '@@@'|'%%%'. Then for
#           plain extraction what was matched will be returned, while for the
#           regex extraction what was matched will be removed from the rx string.
#
# Configurability
#-------------------------------------------------------------------------------
# Analysis: Analysis is a mode [-ca] that allows the user to distinguish
#           between specification errors (those from his own HELP string)
#           vs. those from run-time command line parsing. In Analysis mode,
#           execution stops after analysis of the HELP string is complete.
#           If Analysis mode sees no errors it outputs: ANALYZE=0  : SUCCESS
#           [To see the parsed parameters also configure debug (-d).]
#
# Options:  Delimiters have an interpreted meaning regarding required|optional.
#           The following table show the default values & the option to change.
#           To flip the default interpretation use the Flip option that is shown.
#
#           Symbols  Name     Default   Flip  (comments)
#           --------------------------------------------------
#                    Empty    required  -on   (no delimiters)
#           []       Square   optional  -os
#           ()       Parens   optional  -op
#           <>       Angle    required  -oa
#           {}       Curly    optional  -oc
#
#           Note: these option flags (-o) with n|s|p|a|c for ''|[]|()|<>|{}
#           can also be combined, so: -os -on -oa => -onsa; which will flip each
#           (i.e. Square brackets is set to required but no delimiters & Angle
#           brackets become optional. Or the delimiter interpretation can be
#           explicitly set|cleared with postfix flags: +|-; for e.g.: -on-s+a-
#
# SHIP:     Short Hand Indirect Parmameters by default offers many variations
#           in format (namely:  -d, -d+, -d-, -d#, -d#+, -d#-, -d#,#, -d#-#),
#           where '#' can be a signed|unsigned integer|decimal numeral. This
#           may go beyond some people's needs. Hence, SHIP options, i.e.: -+.,012
#           can be used after the "=" to specify exactly what subtypes to allow.
#           '.' means any number specified will be allowed to have a decimal part.
#           NB: if no digit associated with '.' (e.g.: -d.), '1' will be assumed.
#
#           descript.  opt         0    +    -    1    1+    1-     ,      2
#           ----------------------------------------------------------------
#           allowall: -d=      => -d  -d+  -d-  -d#  -d#+  -d#-  -d#,#  -d#-#
#           havempty: -d=0     => -d
#           end_plus: -d=+     =>     -d+
#           endminus: -d=-     =>          -d-
#           endplmin: -d=+-    =>     -d+  -d-
#           numbered: -d=1     =>               -d#
#           auto-num: -d=.     =>               -d#
#           enumer8d: -d=,     =>                                -d#,#
#           isranged: -d=2     =>                                       -d#-#

#           combos.    opts        0    +    -    1    1+    1-     ,      2
#           ----------------------------------------------------------------
#                     -d=0+-   => -d  -d+  -d-
#                     -d=1+-   =>     -d+  -d-  -d#  -d#+  -d#-
#                     -d=,+-   =>     -d+  -d-                   -d#,#
#                     -d=2+-   =>     -d+  -d-                          -d#-#
#                     -d=,1    =>               -d#              -d#,#
#                     -d=,2    =>                                -d#,#  -d#-#
#                     -d=12    =>               -d#                     -d#-#
#                     -d=12,   =>               -d#              -d#,#  -d#-#
#
#           A +|- option flag takes on a different meaning if it occurs before|
#           after an enum|number|range (i.e. a digit: ,|1|2). If the +|- flag is
#           before a digit, it refers to a signed num (e.g. -d=+1|-d=-2|-d- =>
#           -d+5|-d-4--1|-d-3,-1), but if it's after a digit, it refers to a
#           trailing +|- (e.g.: -d=1+|-d=2- => -d5+|-d-4-). If +|- occurs with-
#           out any digit (e.g.: -d+|-d-0), then it is always a trailing +|-.
#
# Symbols:  Several symbols are used by getparms in order to do parsing. The
#           default parsing symbols are shown below. They can be modified via
#           the parsing option (-p) with dash separated values. Note that
#           Multiple parsing symbols can be changed at the same time. Examples
#           to make end comments to '// '& multiple parms to '..': -p-e//-m..
#    -b-+   [SYMB EOBP] end of bgn parms marker, after which options allowed
#    -g|    [SYMB GRUP] pipe is used to group mode options, e.g.: -i|n|--out
#    -l+    [SYMB MTCH] plus is string match location symbol: bgn, mid, end
#    -a:    [SYMB ALTN] signifies what follows is an option's alternate name
#    -r-    [SYMB RANG] separator to divide the high and low range of values
#    -m...  [SYMB MORE] ellipsis signifies there are unspecified more parms.
#    -e#    [SYMB ECMT] end comment marker: everything after it is a comment
#           [Note: technically a space is always prefixed to this character]
#    -t~    [SYMB TYPE] signifies what data type this string must conform to
#    -p@    [SYMB PLAN] separator for plain datatypes and range|enums|values
#    -x%    [SYMB REGX] separator for regex datatypes and range|enums|values
#
#           Note: when modifying symbols used for parsing, each change must
#           leave the parsing symbol set without any duplicate values. So to
#           swap 2 values requires using a temporary swap value; example:
#           g| -> g: and a: -> a| requires doing the following: -p-g^-a|-g:
#
# Prefs:    Preferences can be configured by setting a configuration flag.
#           The default output is 'bare'. It only shows the items that have
#           been received. An e.g. row of bare output:    'param2="all in"'
#           The item's specification number can be added via the -cr flag.
#           An example row showing as numbered is this:   ' 4 __verb=0'
#           The item's status & number received can be added via -cs flag.
#           e.g. row showing its status is as follows: 'empty[0]: __verb=0'
#           e.g. with flags of -cs & -cr: '14 valid[1]: param2="all in"'
#           [To show all the different examples, run: getparms --examples]
#           As many of these config flags as desired can be set or left unset.
#           [Note that any of the config flags can be combined together
#           (except for -cu, as it requires an associated text string); an
#           example of options being set at one time is: -cc -cs -co => -ccso]
#
#           Some of the following are only visible with the detail flag (-d).
#           Following are the configs that affect the display of outputs
#     -ca : Analyze only mode: only check specification not command-line items
#     -cb : Beginning processing result to be shown for all specification rows
#     -cc : Capture statuses of command-line items even if item is not changed
#     -ce : Suppress all extra empty lines added just for beautifying displays
#     -ch : Help message is suppressed on getting a help option or if no input
#     -cl : Leading underscores from any dashed item's output name are removed
#     -cn : No error messages will be outputted [i.e. operate in a quiet mode]
#     -cq : Suppress output messages except for result (fnam=0) [a quiet mode]
#     -cr : Row numbers (0-based) are to be prefixed to each row that's output
#     -cs : Status of displayed command-line items to be prefixed for each row
#     -cu : User message text is added to output: -cu{=| }"user supplied text"
#     -cw : Disable auto-Wrapping of long lines (e.g.: SpecLine or HELP lines)
#           [NB: -cc & -cq are at odds, if both are set -cc will override -cq]
#           [NB: if -cn enabled then the result will be saved in a file (-cy)]
#     ------------------------------------------------------------------------
#           Following are the configs affecting the command-line parsing
#     -cd : Disable errors on duplicates of same: opt, ind parm, SHIP received
#     -co : Disable combining of multiple One [1] letter pure options into one
#     -cm : Disable combining of Multiple two [2] letter pure options into one
#     -cx : Disable the use of location symbols for regex matching|extractions
#     -cy : Save result of running getparms into file for later retrieval (-r)
#     -ci : Disable old style Ind Parm assignments, warn if -i=val in cmd-line
#           [NB: this only disables OSIP in command-line, but not in the spec,
#           otherwise no way to specify normal ind parm within an OR'ed group]
#
# Display
#-------------------------------------------------------------------------------
# Output:   If row config (-cr) is set, each output row is preceded by its row
#           i.e. its index specification number & its received cmd-line index
#           separated by a colon, e.g.: 0:0 func=0. If status config (-cs) is
#           set, each output row is preceded by its statuses: valid[0]: func=0.
#           If both are set, row & index are shown first: 0:0 valid[0]: func=0.
#           What follows the last colon is the item name, equals, & its value(s).
#           Note: for options 'value' will be the number of times received.
#           For options (including the opt part of an indprm), the value is always
#           a number (e.g.: 0, 1, ...), so the value when printed is not quoted.
#           Parms (including the parm part of an indprm) can have any string,
#           which may include spaces, so the value is always quoted. SHIP items
#           should always have a number, except when they have an empty value
#           or an invalid value. So if the value is empty or the value is invalid
#           it will be quoted, otherwise a valid received value will be unquoted.
#           [See Examples section below to show how to list example outputs.]
#
#           For endless parms (e.g.: parm,... | -i=parm,...) we can just add
#           extra array elements at the end of the output array for we are sure
#           that endless parms are always the last item that will be parsed.
#           This is not the case for multiple Short-Hand Ind Parm (e.g.: -d5,6,)
#           for these occur anywhere in the command-line. If we added extra
#           array elements in the middle of the output array, then all items
#           after this would have to be recopied after the newly added output
#           items, and it would sever the 1-to-1 correspondence between the
#           Specification Array & Output array. As a result the comma separated
#           values for a multiple SHIP variable will be kept as one value (i.e.:
#           -d5,6, => _d=5,6,), which the user will need to separate himself.
#
# Status:   The status of each item in the output array is assigned a state
#           based on the item's properties and whether it was received or not.
#           The output state will only be shown if status config is set (-cs).
#           The default suppressed statuses below will only be shown when the
#           capture all command-line arguments config flag has been set (-cc):
#           "empty" # item not received (if optional) - default suppressed;
#           "misin" # item not received (if required) - default suppressed;
#           "invld" # item was received invalid value;
#           "valid" # item was received no problem;
#           "multi" # item was received multiple times. When multiple values
#           are received for the same ind parm or SHIP item, then the extra
#           values are tacked on with equals: multi[2]: file="f1=f2" or _d="1=2".
#           The indices multiple values were received at are comma separated.
#
#           Note: that any unreceived items will show received index as: '-'.
#           The received value (what is after the '=') is quoted for any non-
#           number type (see row 2) or if the row is empty (see row 4). Options
#           being 0|'number of types received' are considered as number types.
#           For ind parm both opt & parm have a list of indices (rows 1 & 2).
#
# Examples & Errors
#-------------------------------------------------------------------------------
# Examples: In the first example, multiple received ind parms are not flagged
#           as an error due to suppressing duplicates (-cd). This is so the
#           user can see the multi status & how the received indices are shown.
#           Following that is an e.g. of duplicates for a SHIP item. It shows
#           the beginning processing block ("SpecLine:") that is enabled by -cb.
#           [Note: to see additional debug output, run: getparms -d --help]
#
# getparms -ccrsd -~ 'func -d=parm {-i} {prm2}' -d prm1 -d prm2 -d prm3
#
#  0:-     valid[0]: func=0  : SUCCESS
#  1:0,2,4 multi[3]: _d=3
#  2:1,3,5 multi[3]: parm="prm1=prm2=prm3"
#  3:-     empty[0]: _i=0
#  4:-     empty[0]: prm2=""
#
# getparms -cbrsd -~ 'func -d=' -d1 -d2
#
# SpecLine: func -d=
#  0 optn[00]: func  "-h|--help"        [hlp][hlp]
#  1 reqd[01]: _d    "-d"               [sip][sip]
#
# RxdInput: 2: -d1 -d2
#  0:-   valid[0]: func=0  : SUCCESS
#  1:0,1 multi[2]: _d=1=2
#
# Samples:  the test samples are shown via the option: -s<c|o|d|e|v|f|a|r|m|s>;
#           -sa0 will show all the available samples. The other letters show
#           sub-groupings of samples: c=config, o=output display, d=datatype,
#           e=errors, v=verify order, f=features, r=required|optional, m=matching,
#           s=string. Following the letter with nothing will show the description
#           of all the tests in this subgroup (or for -sa all descriptions).
#           Following it with 0 will run all of the tests, e.g.: -sd0
#           Following it with n- will run test n & following:    -sd3-
#           Following it with n-m will run test n through m:     -sd3-4
#           The following is a complex HELP specification sample explained:
#
# HELP='func {f_txt~sj-@~.cpp@~.h} <-v:vrb|m|--vrb> {-i}{-j} [-m=miles] \\
# <-f|--files file1 file2> {--} parm1~ip [parm2] # info'
#
# Explained:
# a. func       : this is the name of the shell script calling getparms
# b. {f_txt}    : this represents an optional positional parameter
# c. ~sj-       : input must be lowercase letters (-) and|or jots|periods (j)
# d. @~.cpp@~.h : means a value must be matched (@), ~str means it must match
#    at the end ('~'); so @~.cpp@~.h means the input must end with .cpp or .h
# e. -v:vrb     : means the option -v has the alternate name "vrb"; this
#    is used in the results array (instead of the default option name, "_v").
#    Alternate names are not required but useful for the user's local varname.
# f. <...>      : means the items contained within angle brackets are required
# g. -v|m|--vrb : a mixed OR'ed group, where only 1 of the the OR'ed items can
#    be received: short option '-v' or long option '--vrb' or the pos. parm 'm'
# h. {-i}{-j}   : '-i' & '-j' are optional pure options, which in the output
#    array (without alt. names) will be named respectively "_i" & "_j". Note:
#    with config -cl the output names become "i" & "j" (without underscores).
# i. [...]      : means the items within []|()|{} are optional (by default).
# j. -m=miles   : indirect parms are specified with an equals or a space; if
#    a space is used the item must be wrapped in delimiters, e.g.: {-f indp};
#    command-line parsing accepts an equals or a space (without delimiters).
#    The output array name for the indirect parm will in this case be "miles".
# k. <-f|--files ifil ofil> : a required multiple indirect parameter group
#    can be specified with a short option "-f" and|or long option "--files".
#    Note even if this was specified as optional {-f|--files ifil ofil},
#    once -f or --files is found, then both file1 and file2 are now required.
#    This could have been specified as an indefinite indirect parm group (aka
#    as a more group: <-f|--files ifil ofil ...>. More groups must always be
#    the last item specified. Output names of received parms in this case are:
#    ifil, ofil_1, ofil_2, etc. Note: Any datatype associated with the
#    last parm (i.e. ofil) will be applied to all subsequent parms (ofil_#).
# l. {--}       : end of options marker indicates no options can be after this.
#    Note: if this was specified as required (<-->), then the end of options
#    marker will be required in the command-line (not the normative case).
# m. parm1~ip   : a required parameter with a datatype of a positive int (~ip).
# n. [parm2]    : a optional parameter with no datatype.
# o. "# info"   : this is an end comment, all after " # " is not parsed.
#    ['#' can be user-configured to be another string, e.g.: "//".]
#
# Error e.g.: errors are of 2 types: fatal & non-fatal. Fatal errors are preceded
#           with the line "Errors:". If these occur in the Analyze phase, then
#           command-line items will not be parsed. Non-fatal errors are reported
#           as warnings & are preceded with the line: "Warning: ". Errors &
#           warnings have the same format. Let's consider the following warning.
#           Multiple errors & warnings may be outputted. The format of each is:
#           n [ERRC] .......error_string...........: error specifics
#           (where n is the associated spec row num & ERRC is a 4 letter code
#           & the error specifics often notes the offending item & its position)
#           [Error messages may be suppressed via the no errors config (-cn).]
#           Overall failure code is returned in function status, e.g.: func=2
#           To get the meaning of this overall error, use the debug flag: -d
#           func=2 : UNFOUND : cannot locate required items [ 2]
#
# Warn_Msgs: 1
# 13 [OADD] No Options after a double dash: -l after 12
# ErrorMsgs: 1
# 01 [PFER]: Parameter format doesn't match: bad mismatch, s/b: ~s- [24:string: s[a-z~+-]] was: parm='a-b'
#
# Explained: failure because dash ('-') in parmam. string
# initial number (01)     : command-line 1-based arg. num
# bracketed code [PFER]   : the internal error identifier
# following strings       : a error comment with bad data
# s/b: ~s-                : a string of lowercase letters
# [24:string: s[a-z~+-]   : the specified string num+type
# parm='a-b'              : item's name => received value
#
# Return Values (useful if errors are suppressed [-cn])
#------------------------------------------
SUCCESS=0; # everything successfully done
FAILURE=1; # received bad setup option(s)
UNFOUND=2; # cannot locate required items
FOUNDIT=3; # found unwanted item or value
NOTSPEC=4; # problem in the specification
TOOMANY=5; # multiple same items received
MISMTCH=6; # a param format doesn't match
UNSUPPT=7; # feature disabled|unsupported
MISORDR=8; # wrong ordering cmd-line item
ILLFORM=9; # item is ill-formed/not a var
UNKNOWN=10;# an unknown item was received
#
# In Depth Details
#-------------------------------------------------------------------------------
# Requirements: it is expected that the caller of this script has a
#     $HOME/bin (or similar) directory where getparms.sh is located &
#     temp files needed by getparms.sh can be created (& also deleted).
#     To copy all the needed files used by getparms to a new location
#     use the copy utility of getparms: getparms.sh -cp {dest_dir}
#
# Specification Restrictions (i.e. restrictions on the HELP string):
# 0.  the first item must be the function name (e.g.: func), which
#     must not begin with a hyphen (to distinguish it from an option)
#     and also because this is not recommended by the Unix standard;
#     it also can't have spaces, exclamation marks, or dollar signs;
#     NB: if it is not a valid varname ([_A-Za-z][_A-Za-z0-9]*), then
#     the output will use 'func' instead of the given function name
# 1.  parameters themselves aren't allowed to have an alternate name
#     (but this is only flagged as a warning & processing continues)
# 2.  only items that have a parameter(s) can have a defined datatype
# 3.  parm names & alt. names (if applicable) must be valid varnames
# 4.  only positional parms allowed after the option end marker (--)
# 5.  error if multiple end of options markers (--) have been found
# 6.  endless (more'ed) parms can't have any other items after them
# 7.  within a mixed OR'ed group {-v|m|--verb} only allow one param
#     (subsequent params would never get set, as only first taken)
#
# Explanations on why some other parsing rules are not enforced:
# 1.  an optional positional parm followed by anything other than
#     another positional parameter - consider the following cases:
#     [prm1] prm2 OR [prm1] -i; we wouldn't know if prm1 was prm1|prm2
#     nor would we be able to set -i as it would be swallowed by prm1.
#     The 1st problem is solved by counting the number of parms.
#     The 2nd problem is solved by scanning for options 1st, then
#     gobbling up the remaining parms (both are now being done).
# 2.  optional options not allowed before a positional parmeter,
#     e.g.: {-o} parm (have no way of knowing if -o actually parm).
#     This restriction can be removed when the end options marker (EOM)
#     intervenes between (-o -- parm); or required parms are counted.
#     Since the EOM can be entered from the command-line and because
#     getparms counts the number of required parms, don't enforce this.
# 3.  pure options (e.g.: -i) normally are considered optional only,
#     but we have the exception if they are OR'ed (e.g.: -i|--n|m)
#     [which can be specified as optional or as required; so we allow
#     this to be required as it may be used to set an operating mode].
# 4.  optionless parameters (e.g.: name) are positional & so should be
#     required - but under special situations it could be known (such
#     as when we count the number of arguments), so we skip this rule.
#     This also allows us to support more'd parms (with an unknown no.);
#     e.g.: add 1 5 7 ... # a function that requires an unknown number.
#
# Parsing: standard parsing allows pure and ind. parm options to freely
#     be positioned anywhere before the 'end-of-options' marker ('--').
#     [This is usually done by first extracting all the known options.]
# 1.  When options precede the first parameter in the specification, then
#     option-first processing works great (without any beginning parms):
#     a. getparms.sh -ccs -~ "func {-i}{prm}" -i val1 => _i=1; prm="val1";
#     b. getparms.sh -ccs -~ "func {-i}{prm}" val1 -i => _i=1; prm="val1";
#     Thus if the optional option is specified before the optional parm,
#     then the opt is grabbed 1st and either order in the cmd-line works.
#
# 2.  The problem with stripping out all options first is that this can't
#     support free-text parms at the start of the cmdline followed by opts.
#     Taking all options 1st causes an initial required pos. parm to go empty:
#     -. "func {prm}{-i}" -i      => prm="";     _i=0; # so prm can't be: -i
#     But this is handled by getparms through the idea of beginning parms:
#     a. "func {prm}{-i}" -i      => prm="-i";   _i=0;
#     b. "func  prm {-i}" -i      => prm="-i";   _i=0;
#     c. "func {prm}{-i}" val1 -i => prm="val1"; _i=1;
#
# 3.  getparms counts the number of required items & only fills optionals
#     when there are enough command line items left to fill all requireds:
#     a. "func {-i}{prm1}{prm2}" val1 -i => prm1="val1"; prm2="";    _i=1
#     b. "func {prm1} prm2 {-i}" val1 -i => prm1="val1"; prm2="-i";  _i=0
#        Here there's only 1 required item (prm2), but 2 rcvd cmdline items,
#        hence both parms will be filled as they are both 'beginning parms'.
#     c. "func {prm1} prm2  -i " val1 -i =>              prm2="val1"; _i=1
#        Here there are 2 required items (prm2 & -i) & 2 rcvd cmdline items,
#        so prm1 can't be filled, but prm2 & -i are both correctly received.
#
# 4.  But how to handle beginning optional parms with options following?
#     We saw in Step 3 if all items after begin parms are required, it's fine,
#     but it doesn't solve the problem where an optional item is needed after.
#     This is solved by introducing an 'end-of-beginning parms' marker ('-+'):
#     a. "func {prm1} prm2  -i  {prm3}"  val1 -+ -i val2
#         => prm1=""; prm2="val1"; _i=1; prm3="val2"
#     b. "func {prm1} prm2 {-i} {prm3}"  val1 -+ -i val2
#         => prm1=""; prm2="val1"; _i=1; prm3="val2"
#
# 5.  Thus, getparms will 1st (a) gobble up any required begin parms, then (b)
#     check if the number of items left is > number of remaining required items
#     in order to fill optional beginning parms, then (c) it will strip out all
#     options (pure & indirect) until it sees the end of options marker. Then
#     it will (d) gobble up all end parms. Note: because of stripping out all
#     opts (step c), there is one case that at first sight may seem wrong.
#     a. "func <-f|--files=ifil ofil>" -i -f 1 2 => ifil=1, ofil=-i, 2 UNKI
#        This puts -i (not 2) into ofil (an end parm), because -f ifil (an
#        ind. parm with option '-f' is stripped out first). This is correct.
#     b. on the other hand the following construct of a multi-indp is more
#        like we would expect, where -i is caught as the unknown item (UNKI):
#        "func <-f|--files ifil ofil>" -i -f 1 2 => ifil=1, ofil=2, -i UNKI
#
# Alternate Format Support:
# - variations in parameter types can be handled often just by naming:
#   file|dir        => file_or_dir
# - some OR'ing combos are not supported, but may be done by different means,
#   e.g.: {-x|-o|-b n}  => {-x}|{-o}|{-b n} => -x|-o|n  # mixed group format
# - Condensed Format syntax: supported by listing all option variations
#   0) {-r|-w|-x{+|-}}  => -r+|-r|-r-|-w+|-w|-w-|-x+|-x|-x-
#   1) {-n{+|-} num}    => -n=num|-n=+num|-n=-num  # a signed ind parm
#      Item 1 can be supported with as an indirect parameter just by moving
#      the +|- to the number (num): -n=num where num is pos|neg|unsigned|""
#      and specifying the datatype of num as a signed number or integer.
#   2) -da<-|+>         => -da-|-da+      # no -da, -|+ is required
#      Item 2 can be supported via Short-Hand Ind Parm (via: '-da#'), but
#      the user will have to discard any returned numbered values (-da5).
#   3) -da{-|+}         => -da-|-da+|-da  # ok -da, -|+ is optional
#      Item 3 can be supported via Short-Hand Ind Parm (via: '-da#'), but
#      the user will have to discard any numbered & empty values (e.g.: -d).
#   4) -b{{-}#{-{#}}    => this is the SHIP item type directly (e.g.: -b=).
#
# Escaping: Care must be used when using the parsing symbols ('|:-...#,~+@')
#           in the specification in Datatype values. End comments (SYMB ECMT:
#           '#') & Group Indicators (SYMB GRUP: '|') are checked before the
#           Datatype values (e.g.: '\|'). If the end delimiters '])>}' occur
#           in Datatype values in a corresponding grouping of the same type,
#           they must be escaped or the 2nd end delimiter will be seen as a
#           new item. Spec processing removes the escaping for Symbols ECMT
#           & GRUP (e.g. '\|' => '|'), & End delimiters, but not for quoting.
#           If an escaped Symbol is needed in the output, it must be double
#           escaped in the Specification. For example: '\\|' => '\|'.
#
# File Use: the following files are used to run getparms:
#           - getparms.sh            : the executable script
#
#           the following files are needed to show getparms examples:
#           - getparms.xcfg.txt      : configs  examples generated by getparmstest.sh
#           - getparms.xdat.txt      : datatype examples generated by getparmstest.sh
#           - getparms.xerr.txt      : errored  examples generated by getparmstest.sh
#           - getparms.xfet.txt      : features examples generated by getparmstest.sh
#           - getparms.xmat.txt      : matching examples generated by getparmstest.sh
#           - getparms.xout.txt      : displays examples generated by getparmstest.sh
#           - getparms.xreq.txt      : required examples generated by getparmstest.sh
#           - getparms.xstr.txt      : str type examples generated by getparmstest.sh
#           - getparms.xvar.txt      : varietal examples generated by getparmstest.sh
#
#           If any of above txt files are lost|damaged, use next file to recreate
#           them using this -x option: getparmstest.sh -x
#           - getparmstest.sh        : test script, generates help files for getparms
#
#           the following are temp files created by getparms [often to speed the
#           future execution: PID = procID, USR = username, FCN = function]:
#           - .getparms.dbgl.txt     : temp file used for debug long help
#           - .getparms.fcns.txt     : temp file to capture internal functions list
#           - .getparms.fcnv.txt     : temp file to capture internal functions verbose
#           - .getparms.feat.txt     : temp file used for features help
#           - .getparms.hist.txt     : temp file used for history help
#           - .getparms.long.txt     : temp file used for long help
#           - .getparms.rslt.USR     : temp file used for storing the result when no func
#           - .getparms.rslt.USR.FCN : temp file used for storing the result for function
#           - .getparms.welc.txt     : temp file used for assembling the welcome info
#           - .getparms.welc.USR     : temp file that user has seen welcome banner (0-byte)
#
# Regex:    regex searching is enabled for all Regex match (%) searches. These
#           use bash Extended Regular Expressions (ERE) with the special symbols:
#           ^   : matches start of string  => + (at end of string)
#           $   : matches trail of string  => + (at bgn of string)
#           .   : matches any 1 character, use .* to match multiple chars
#           *   : match 0|more quantifier <=> {0,}
#           +   : match 1|more quantifier <=> {1,} [ensure not final char.]
#           ?   : preceding made optional <=> {0,1}
#           |   : match this (b4) | after <= remember to put longer match 1st
#           [NB: '|' symbol can't be used due to getparms OR'ed groups symbol]
#           [NB: '^' & '$' symbols are unneeded due to getparms '~' symbol use]
#           Though the default for bash ERE, [[ "$str" =~ find ]], is to match
#           anywhere in the string, because this passes through getparms first
#           (with no '~'), it is overridden to mean find the whole string, i.e.
#           [[ "$str" =~ ^find$ ]]. To find anywhere 'find' must be ~find~.
#
#           The following are the regex characters which are used as delimiters:
#           {}  : indicator of repetition <= e.g.: {5} | {3,5} = do 5x | 3-5x
#           ()  : specify a capture group <= 1st is ${BASH_REMATCH[1]}
#                                         <= 2nd is ${BASH_REMATCH[2]}, etc.
#           \n  : capture group reference <= refer to back ref. by numeric order
#                 e.g.: ([ab])=\1         <= finds: 'a=a' | 'b=b'
#           (?) : set a non-capture group <= Set(?:Val)? = SetVal|Set
#                 [Note: in this case the parans do not form a capture group]
#           []  : match range|set chars   <= [a-z]  match any lowercase letter
#           [^] : match all but this set  <= [^0-9] match all but numbers
#
#           Note: the symbols in the left column are not supported by Bash's ERE
#           but can instead be accommodated by the right column constructs:
#           [word boundary: space, horiz|vert tab, new line, return, form feed
#           (which equate to the escaped character sequences: ' \\t\\v\\r\\n\\f')]
#
#           \\n : match on any line feeds
#           \\r : match a carriage return
#           \\t : match on tab characters
#           \\d : match any digit = [0-9]   => [[:digit:]]  : any digit [0-9]
#           \\D : match non-digit = [^0-9]  => [^[:digit:]] : non-digit [^0-9]
#           \\s : match a whitespace char   => [[:space:]]  : any whitespace
#           \\S : match non-whitespace char => [^[:space:]] : non-whitespace
#           \\w : match on word boundary    => [_[:alnum:]] : any word boundary
#           \\W : match non-word boundary   => [^_[:alnum:]]: non-word boundary
#           \\l : match lower letter [a-z]  => [[:lower:]]  : any lowercase [a-z]
#           \\u : match upper letter [A-Z]  => [[:upper:]]  : any uppercase [A-Z]
#           NB: to match a whole word must do: [_[:alnum:]]+
#
#           Additionally the following named ranges can be used:
#           [[:print:]]  : match printable char.
#           [[:graph:]]  : any printable no space
#           [[:blank:]]  : any space | tab char.  [ \t]
#           [[:ascii:]]  : match ASCII chars      {0--127}
#           [[:alpha:]]  : match any letter       [A-Za-z]
#           [[:alnum:]]  : match any letter|num   [A-Za-z0-9]
#           [[:xdigit:]] : match any hexadecimal  [A-Fa-f0-9]
#           [[:word:]]   : continuous alphanum|_  [A-Za-z0-9_]
#           [[:punct:]]  : match any punctuation  [~`!@#$%^&*()_-+={}[]|\:;"'<>,.?/]
#           [[:cntrl:]]  : match any char not part of the following classes:
#                          [[:upper:]], [[:lower:]], [[:alpha:]], [[:digit:]],
#                          [[:print:]], [[:punct:]], [[:graph:]], [[:xdigit:]]
#           Sample: ~s%%[[:digit:]]* with "ABCDE12345abcde" => 12345
#
#           Bash ERE matching doesn't support quoting of strings for the purpose
#           of removing the special meaning of regex symbols & in general causes
#           the regex search to fail. Thus getparms removes any unescaped quotes
#           within any search string intended for regex matching (i.e. '%'|'%%').
#           Quoting, in general, is unreliable as Bash often removes quote marks.
#           To search for any desired quote marks, they must be single escaped.
#           To search for any of the non-delimiter regex characters ('.+*?^|$')
#           they must be double escaped. So to find an actual period do: ~s%\\.
#           Any pattern with spaces, in order to be rightly parsed by getparms,
#           must be quoted; but the regex tests in turn will fail with unescaped
#           quotes, so getparms in turn removes all unescaped quote marks. While
#           searching for delimiter regex chars '{}[]()' requires special care.
#
#           Bash command line: requires parans to be escaped (unless in quotes)
#           get after bgn str: ~s%%bgn\(.*\)      "abgnmidendz";    => midendz
#           get after end str: ~s%%\(.*\)end      "abgnmidendz";    => abgnmid
#           between bgn & end: ~s%%bgn\(.*\)end   "abgnmidendz";    => mid
#
#           To actually search for parans, they also must be escaped:
#           to exclude parans: ~s%%[\(]\(.*\)[\)] "abgn(mid)endz";  => mid
#           to include parans: ~s%%\([\(].*[\)]\) "abgn(mid)endz";  => (mid)
#
#           To avoid all escaping of parans, instead quote the match string
#           between bgn & end: "~s%%bgn(.*)end"   "abgnmidendz";    => mid
#           also equivalently: "~s"%%bgn(.*)end"  "abgnmidendz";    => mid
#
#           Working w/ angles: the simplest of delimiters, no special care needed
#           get w/ the angles: "~s%%(<.*>)"       "abgn<mid>endz";  => <mid>
#           get inside angles: "~s%%<(.*)>"       "abgn<mid>endz";  => mid
#           or alternatively:  "~s%%<[^<>]+>"     "abgn<mid>endz";  => mid
#
#           Working w/ braces: the 2nd simplest delimiter, only minimal care needed
#           get inside braces: "~s%%({.*})"       "abgn<mid>endz";  => {mid}
#           get beside braces: "~s%%{(.*)}"       "abgn<mid>endz";  => mid
#           A numbers problem: above doesn't work if 1st char after '{' is a number
#           retrieves nothing: "~s%%({2.*})"      "abgn{2mid}endz"; => ""
#           a fix for numbers: "~s%%([{]2.*})"    "abgn{2mid}endz"; => {2mid}
#
#           Works w/ brackets: additional care needed for bracket processing
#           get w/in brackets: "~s%%bgn[[](.*)[]]end" "abgn[mid]endz" => mid
#           get with brackets: "~s%%bgn([[].*[]])end" "abgn[mid]endz" => [mid]
#
#           To extract string:
#           all after a begin: ~s"%%bgn(.*)"       "abgnmidendz";    => midendz
#           all befor a trail: ~s"%%(.*)end"       "abgnmidendz";    => abgnmid
#           all between match: ~s"%%bgn(.*)end"    "abgnmidendz";    => mid
#
#           To get actual str: match string is quoted to protect parans & the
#           escaped quotes around 'bgn(.*)end' to ensure special chars not interpreted
#           to get sub-string: ~s"%%\"bgn(.*)end\"" "abgn(.*)endz";  => bgn(.*)end
#           shown not a match: ~s"%%\"bgn(.*)end\"" "abgn(ab)endz";  =>
#
#           Without any paran: don't need quotes around match string but still need
#           escaped quotes around inner string 'bgn.*end' to match without interpretation
#           Without any paran: ~s%%\"bgn.*end\"    "abgn.*endz";     => bgn.*end
#
#           Extract integers:
#           Matches are removed on extractions (%% or @@), but only the 1st match
#           2 digits followed by a digit at start: ~i%%88.+   "8876543210";  => "6543210"
#           2 digits girded by 2 digits in middle: ~i%%+.23.+ "12341235123"; => "1235123"
#           Notice only the 1st match (1234, the 2nd would have been 1235) is removed
#           Note all of the 1st match are removed: ~i%%+.23.+ "12341231234"; => "123"
#
#_INFO_END # Document page delimiters; o/p end: getparms --help
#############################################################################
#############################################################################
#_DBG1_BGN # Document page delimiters; o/p via: getparms -d --help | --help -d
# The following describe the debugging features & associated flags of getparms
# ------------------------------------------------------------------------------
# Help:     To get a list of enums & strings used by getparms, use these flags:
#           -h{d|e|p|o|t} # each of these can be specified as -h. or -h -.
#           -hd  to get a list of debugging flags enums [display all debug flags]
#           -he  to get a list of all err strings enums [display all error enums]
#           -hp  to get a list of parsing symbols enums [display all parse enums]
#           -ho  to get a list of delimiter option enum [display all option enum]
#           -ht  to get a list of enum for all datatype [display all data-typing]
#           -hts to get a list of all string type opts  [display all string type]
#           -htn to get a list of all number type opts  [display all number type]
#
# Output:   Debug output to aid in seeing why the parsing results may not be as
#           expected can be enabled via (-d). This will show the internal parsing
#           results of the specification, along with other debugging data. To
#           only show the results of the specification without the extra debug
#           data use -cb. Here is an extensive example using the -cb option:
#
# HELP='func <f_txt~sj~@+".Txt"> -v:verb|m~h|--verb {-in} {-io} -i {-j} [-m=indp]
# -e <-f|--files ifil tfil ofil> {--} <prm1~ip> [prm2 prm3~sw-] # info'
# getparms -cb -on -?"-h|--help" -~ "$HELP" file.txt 0x48 -ion -ij -e --files in.txt tmp.txt out.txt 12 "all in" "all on";
#
# SpecLine: func <f_txt~sj~@+".Txt"> -v:verb|m~h|--verb {-in} {-io} -i {-j} [-m=indp] -e
# <-f|--files ifil tfil ofil> {--} <prm1~ip> [prm2 prm3~sw-]
# optn[00]: func     "-h|--help"        [hlp][hlp]
# reqd[01]: f_txt    ""                 [bgn][prm][~sj~@+.Txt]
# optn[02]: verb     "-v"          2:01|[mix][opt]
# optn[02]: m        ""            2:02|[mix][prm][~h]
# optn[02]: __verb   "--verb"      2:03|[mix][opt]
# optn[03]: _in      "-in"              [opt][opt]
# optn[04]: _io      "-io"              [opt][opt]
# optn[05]: _i       "-i"               [opt][opt]
# optn[06]: _j       "-j"               [opt][opt]
# optn[07]: _m       "-m"         10:01=[osi][opt]
# optn[07]: indp     ""           10:02=[osi][prm]
# optn[08]: _e       "-e"               [opt][opt]
# reqd[09]: _f       "-f"         14:01:[ind][opt]
# reqd[09]: __files  "--files"    14:02:[ind][opt]
# reqd[09]: ifil     ""           14:03:[ind][prm]
# reqd[09]: tfil     ""           14:04:[ind][prm]
# reqd[09]: ofil     ""           14:05:[ind][prm]
# optn[10]: __       "--"               [eom][eom]
# reqd[11]: prm1     ""                 [end][prm][~ip]
# optn[12]: prm2     ""                 [end][prm]
# optn[12]: prm3     ""                 [end][prm][~sw-]
#
# RxdInput: 12: file.txt 0x48 -ion -ij -e --files in.txt tmp.txt out.txt 12 all in all on
# func=0  : SUCCESS
# f_txt="file.txt"
# m=0x48
# _in=1
# _io=1
# _i=1
# _j=1
# _e=1
# __files=1
# ifil="in.txt"
# tfil="tmp.txt"
# ofil="out.txt"
# prm1=12
# prm2="all in"
# prm3="all on"
#
# Explain:  'SpecLine:' shows the HELP spec. Following it is each parsed item
#           where optional|required is indicated by the string 'optn|reqd'.
#           In brackets is the item number (e.g.: [01]). Looking at row 01:
#           'reqd[01]: file_txt  ""                 [bgn][prm][~sj~@+.Txt]'
#           the item number is followed by the output varname ('file_txt')
#           [where any hyphens in the name have been changed to underscores];
#           this is followed by the option, if it exists (else it's empty: "").
#           If the item is linked to another item, a group number separated
#           by a colon & the item number it is in that group (e.g.: '2:01').
#           This is followed by '=', if it is an OSIP, ':' if it is a normal
#           ind parm, or '|' if it's part of an OR'ed group (e.g.: '-v|m').
#           Next in brackets comes the item's function (1 of the following):
#
#           [mor] : if it is a more (endless) parameter  (e.g.: parm ...)
#           [osi] : if it is an Old Style Ind parameter  (e.g.: -f=parm)
#           [ind] : if it is a normal indirect parameter (e.g.: -f parm)
#           [mix] : if it is a mixed OR'ed group         (e.g.: -v|m)
#           [org] : if it is a non-mixed OR'ed group     (e.g.: -v|--verb)
#           [bgn] : if it is a beginning positional parm
#           [end] : if it is a trailing positional parm
#           [sip] : if it is a Short Hand Ind parameter  (e.g.: -f=)
#           [opt] : if it is a normal option             (e.g.: -f)
#
#           Following this comes the item's type in brackets, which will be:
#           [unk] : unknown item    |  [sip] : short hand ind parm
#           [hlp] : help option     |  [prm] : positional parameter
#           [opt] : pure option     |  [eom] : end of options marker
#
#           Finally, if it exists, is the datatype with any surrounding text
#           (e.g.: [~sj~@+.Txt]). The datatype always begins with the datatype
#           symbol (def.: '~'), the datatype kind (e.g.: 's' [string]) with any
#           options (e.g.: 'j' for jot|period & '~' for case insens.) & any
#           surrounding text ('@'|'%'|'@@'|'%%' for bash search or regex, extract
#           if doubled) & the text type (e.g.: +.Txt [means ends with '.Txt']).
#
#           Note: the first row [00] is special for it contains the calling
#           script's name (specified in HELP) and the help options being used.
#           Note: the "SpecLine" block is also printed with the -cb option.
#           In either case (-d|-cb), the "SpecLine" block is printed before
#           the output parms. To keep them separate and to allow easier parsing
#           in these cases, the output parms will have the title "RxdInput:".
#
# Testing:  All testing for getparms is done via the getparmstest.sh script.
#           Note: getparmstest.sh is used to create the examples that are
#           available for view in getparms with the show samples opt ('-s').
#           Any change made to getparms is thoroughly tested by a complete
#           regimen of over 600 tests that test all getparms features. When
#           new features or fixes are added to getparms a complete regression
#           test is done and any relevant tests that are needed are added to
#           getparmstest to keep the test coverage complete and up to date.
#           If one of the sample files is damaged or lost they can be easily
#           regenerated by running the command: getparmstest.sh -x
#
# Tracing:  basic debug output is enabled via -d, which outputs after the input
#           specification, but before the output results; Note: if the beginning
#           output result is not enabled (via -cb), -d will auto-enable -cb;
#           basic debug output will display the item indices [ItemIndex], names
#           [ItemNames], & the counts [ItemCount] of beginning parms, options,
#           ind parms, end parms, & hidden parms (hidden are those parms within
#           an OR'ed group); it also shows the number of remaining required &
#           optional items [ReqOption] & a list of all ind options [IndOpList];
#           if any configs (-c.) have been set they will be listed [Configure];
#           if any options (-o.) have changed they will also be in [Configure] &
#           it will list the present delimiter interpretation [optional|required].
#
#           the available debug flags are as follows: -d{_|a|b|c|d|i|s}
#           -d  outputs the fields as stated above
#           -d_ trace the Initial|Common functions
#           -da trace Analyze Spec part of getparms
#           -db trace BoxOrPackage part of getparms
#           -dc trace Command Line part of getparms
#           -dd trace Deliver results from getparms
#           -d?#. : ?=a|b|c|d (as above) & .={<^|:|=|#>str}; enables trace 'n'
#               optional string match finds at: ^ bgn, : any, = all, or # end
#           -di{m{-{n}}} prints specification items (with all relevant fields)
#           -ds prints cmd-line prior to shifting optional to required parms
#
#           Note: the tracing flags are broken up into the 5 major parts or groups;
#           Part _ is for initialization | command functions (where flags are -d_?);
#           Part a is for specification analysis functionality (and flags are -da?);
#           Part b is for boxing|packing results of the analysis (& flags are -db?);
#           Part c is for command-line processing of actual user input (flags -dc?);
#           Part d is for deliver results of the the command-line (with flags -dd?).
#           E.g.: -da enables tracing of the whole analysis section for any item
#           -da7: enables tracing of an analysis function GetDataType for any item
#           -da7=3: enables tracing in GetDataType only when the index is 3
#           To match whole string use =, e.g. -da7=3, searches for:  3
#           To begin search use a caret, e.g. -da7^3, searches for:  3*
#           To end a search use an hash, e.g. -da7$3, searches for: *3
#           To find any where use colon, e.g. -da7:3, searches for: *3*
#_DBG1_END # Document page delimiters; o/p end: getparms -d --help | --help -d
#############################################################################
# here is where the complete list of debug enums is printed out: PrintAllDebug

#############################################################################
# Coding Conventions and Developer Notes
# Function Naming: a capital first letter in the function name indicates that
# the function is not available for external sub-function testing (see Sub Func).
# NB: any function in lower case that ends in _dev is for developer use only.
# Remember not to do: echo "$var" or printf "$var" unless var is guaranteed
# not to begin with a hyphen ('-'), replace both with: printf "%s\n" "$var".
# Ensure that every DBG_TRC enable has 2+ spaces between DBG_TRC & number.
# To verify that tracing each debug number is paired, meaning that for every
# DBG_TRC enable ("DBG_TRC  nn") there exists at least 1 DBG_TRC disable
# ("DBG_TRC -x nn"), the tester can run: getparms -x dbgenum -v;
#
# Packaging Notes
# When a new release is made ensure the following steps are consecutively done:
# 1. update version#: bump GETPARMS_VERS
# 2. run all testing: getparmstest.sh -ta0
# 3. regenerate help: getparmstest.sh -x
# 4. copy all files:  getparms.sh -cp dstdir
#############################################################################

#############################################################################
# Code Start: Identity & Files Use
# To see all BGN+END labels: grep -E '#_.*_BGN|#_.*_END' getparms.sh | grep ^#_
# Flags used for help marks: WELC, DESC, FEAT, INFO, DBG1, DBG2, HIST
#############################################################################
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; # SELF is used to call self
then SRCD=0; SELF="$0";       # who am i:  /user/bin/getparms.sh
else SRCD=1; SELF=/$HOME/bin/getparms.sh; fi # don't want sourcer, e.g.: getparmstest
PID=$PPID;                    # processId: xxx
ROAD=${SELF%/*};              # road/path: /user/bin
NAME=${SELF##*/};             # my script: getparms.sh
FUNC=${NAME%.*}               # function:  getparms [needs NAME]
ALLX="$ROAD/${FUNC}*.sh";     # all exec:  /user/bin/getparms*.sh
FNAME="";                     # user function, set in Main
HIDN="$ROAD/.$FUNC";          # hidden:    /user/bin/.getparms
WELC="$HIDN.welc.$USER"       # welcome:   /user/bin/.getparms.welc
RSLT="$HIDN.rslt.$USER";      # file rslt: /user/bin/.getparms.rslt.func
ENAF="$HIDN.$PID.ena.txt";    # file temp: /user/bin/.getparms.pid.ena.txt
DISF="$HIDN.$PID.dis.txt";    # file temp: /user/bin/.getparms.pid.dis.txt
FLST="$HIDN.fcns.txt";        # file temp: /user/bin/.getparms.fcns.txt
VLST="$HIDN.fcnv.txt";        # file temp: /user/bin/.getparms.fcnv.txt

#############################################################################
# Files generated & reused to speed up lengthy help menus
#############################################################################
declare -a PGENF;                        # array of pre-generated files
WELF="$HIDN.welc.txt"; PGENF+=("$WELF"); # file temp: /user/bin/.getparms.welc.txt
FETF="$HIDN.feat.txt"; PGENF+=("$FETF"); # file temp: /user/bin/.getparms.feat.txt
HISF="$HIDN.hist.txt"; PGENF+=("$HISF"); # file temp: /user/bin/.getparms.hist.txt
EXMF="$TEST_XOUT";     PGENF+=("$EXMF"); # file temp: /user/bin/getparms.xout.txt
                                         # not used - /user/bin/.getparms.exam.txt
LNGF="$HIDN.long.txt"; PGENF+=("$LNGF"); # file temp: /user/bin/.getparms.long.txt
DBGL="$HIDN.dbgl.txt"; PGENF+=("$DBGL"); # file temp: /user/bin/.getparms.dbgl.txt

#############################################################################
# Get Sample : displays sample getparms execution runs
# These are purposely all viewable files to be copied with getparms.sh
# NB: keep below in sync with SAMP_OPTS (here in getparms)
# and keep Ex_Tests (in getparmstest.sh) in sync with Ex_Files
#############################################################################
VIEW="$ROAD/$FUNC";           # path: /user/bin/getparms
TEST_XALL="$VIEW.x???.txt";   # file: /user/bin/getparms.x???.txt   [Test AllTest e.g.] (only displayed)
TEST_CNFG="$VIEW.xcfg.txt";   # file: /user/bin/getparms.xcfg.txt   [Test Configs e.g.]
TEST_XFET="$VIEW.xfet.txt";   # file: /user/bin/getparms.xfet.txt   [Test Feature e.g.]
TEST_XVAR="$VIEW.xvar.txt";   # file: /user/bin/getparms.xvar.txt   [Test Variety e.g.]
TEST_XDAT="$VIEW.xdat.txt";   # file: /user/bin/getparms.xdat.txt   [Test DataTyp e.g.]
TEST_XSTR="$VIEW.xstr.txt";   # file: /user/bin/getparms.xstr.txt   [Test StrType e.g.]
TEST_XREQ="$VIEW.xreq.txt";   # file: /user/bin/getparms.xreq.txt   [Test ReqOpts e.g.]
TEST_XMAT="$VIEW.xmat.txt";   # file: /user/bin/getparms.xmat.txt   [Test Matches e.g.]
TEST_XERR="$VIEW.xerr.txt";   # file: /user/bin/getparms.xerr.txt   [Test Errored e.g.]
TEST_XOUT="$VIEW.xout.txt";   # file: /user/bin/getparms.xout.txt   [Test Outputs e.g.]
# the arrays used for samples
SAMP_OPTS='c|o|d|e|v|f|a|r|m|s'; # list of sample options
declare -a Ex_Files=("$TEST_XALL" "$TEST_CNFG" "$TEST_XFET" "$TEST_XVAR" "$TEST_XDAT" "$TEST_XSTR" "$TEST_XREQ" "$TEST_XMAT" "$TEST_XERR" "$TEST_XOUT");
declare -a Ex_Optns=(   "-sa"        "-sc"        "-sf"        "-sv"        "-sd"        "-ss"        "-sr"        "-sm"        "-se"         "-so");
# numbers and sizes:      0            1            2            3            4            5            6            7            8             9
declare -a Ex_Descs=("-sa         : show all categories of samples"
                     "-sc{n{-{m}} : show all configuration samples or a range"
                     "-sf{n{-{m}} : show all feature-based samples or a range"
                     "-sv{n{-{m}} : show all order variety samples or a range"
                     "-sd{n{-{m}} : show all types of data samples or a range"
                     "-ss{n{-{m}} : show all stringed type samples or a range"
                     "-sr{n{-{m}} : show all required|optl samples or a range"
                     "-sm{n{-{m}} : show all matching kind samples or a range"
                     "-se{n{-{m}} : show all kind of error samples or a range"
                     "-so{n{-{m}} : show all types outputs samples or a range"
);

###########################################################################
# Developer related defines and functions
# NB: can't put 'getparms' in help line or fcn gets excluded from getparms -x
# upd8_dev - any pre-generated file that exists will be touched;
#            useful to shorten runtime of: getparmstest.sh -a0
#
# Use the following construct to comment out code
#if [ ]; then # ifdef
#fi  # endif
###########################################################################
DEVELOPERS="cvonhamm "; DEVELOPERS+=" charles2"; # checks if user is developer
if [[ " $DEVELOPERS " == *" $USER "* ]]; then DEV=1;  else DEV=0;  fi
DEVADD="Developer Note: Add this config to getparmstest.sh to capture error";

function  upd8_dev() { # upd8_dev  {-s} # -s = touch get parms itself, else touch all of the pre-generated files
    if  [[ "$1" == -s ]]; then touch "$SELF"; return; fi
    local file; for file in "${PGENF[@]}";
    do if [ -f "$file" ]; then touch "$file"; fi; done
}

#############################################################################
# defines related generic error messages used also by getparmstest.sh
# error strings & well-known strings for searching by getparmstest.sh
#############################################################################
if [[ "$TRACING" != 1 ]] && [[ "$TRACING" != 0 ]]; then TRACING=0; fi # ensure defined
OPTREQ="change delimiters to required or optional";
GENFIL="generate file via: getparmstest.sh -x"
SPCMDL="Specification|CommandLine Errs";
RTNHDG="Meanings of the Return Codes";
BADOPT="Bad|unknown option:"; # don't call BOPT (name already used)
DT_MNG="Datatype meaning";
NODIR="dir does not exist:";
NOFIL="file doesn't exist:";
SMITM="items are the same:";
ERRMSG="ErrorMsgs:";
WRNMSG="Warn_Msgs:";
SPCLIN="SpecLine:";
VERSTR="ver.";
CR="
";

#############################################################################
# Long Help Strings
#############################################################################
LHLP_HELP="--help";         # extended help
LHLP_HLP2="{-}-help";       # short|extended help
LHLP_EXAM="--examples";     # actually: --ex*
LHLP_VERS="--version";      # actually: --ver*
LHLP_HIST="--history";      # actually: --his*
LHLP_FEAT="--feature";      # actually: --feat*
LHLP_FEATS="--features";    # actually: --feat*

#############################################################################
# Globals used to get function output so we don't have to invoke evaluate
#############################################################################
OPT='';  BGN='';  END='';  NUM=''; MIN=''; MAX='';  # globals: GetRange
VAL0=''; VAL1=''; VAL2='';  # global used to return values of: ChgCase
HEX_NUM=''; TMP='';         # global used to return string of: Hex2Dec & ErrStr|Opt Name
STR_CMP=''; STR_BAD='';     # global used to get compare str.: GetCompare & Get ShipFlags
XTRCNUM=''; XTRCSTR='';     # global used to get extracted num|str from pre+annx: is_number | RangeStr
UNESCBF=''; UNESCAF='';     # global to get string before & after unesc'd symbol: GetUnescape
UNESCAP=''; NOESC=0;        # global used to return string after escapes removed: DelEscapes & HasUnescape

# defines for changing case
LCAS="abcdefghijklmnopqrstuvwxyz"; # used for changing case & string testing
UCAS="ABCDEFGHIJKLMNOPQRSTUVWXYZ"; # used for changing case & string testing

#############################################################################
# Regex patterns used by getparms
# NB: we have to distinguish between 'detecting' hex vs. 'extracting' hex
# to convert hex to decimal: strip off prefixes (0x|x|\x) & leading zeros
# More regex patterns for the datatype number types are in RegxPatt array
# but they can't be here because they require the Datatypes to be defined
#############################################################################
# initial set is for extracting (not enforcing)
REGX_NUMS='[+-]?[0-9]*[.]?[0-9]+';
REGX_POSN='[+]?[0-9]*[.]?[0-9]+';
REGX_NEGN='[-][0-9]*[.]?[0-9]+';
REGX_INTS='[+-]?[0-9]+';
REGX_POSI='[+]?[0-9]+';
REGX_NEGI='[-][0-9]+';
REGX_UINT='[0-9]+';
REGX_ZER1='[0-1]';
REGX_BOOL='[0-1]*';
REGX_PERI='[+-]?[0-9]+';             # same as: REGX_INTS
REGX_PERF='[+-]?[0-9]*[.]?[0-9]+';   # same as: REGX_NUMS
RE_CHARS='.+*?^{}()[]|$';            # regex chars needing escaping for regular use
HEX_PATT='(x|0x)?0?([1-9a-fA-F]{1,}[0-9a-fA-F]?)';  # extract hex nos. (discards prefix)

# following set is for enforcing|ensuring a datatype
UNSN_INT='^[0-9]+$';                 # extract whole integer that is not signed
SIGN_INT='^[+-]?[0-9]+$';            # extract whole integer that may be signed (allows multiple leading 0)
SIGN_NUM='^[+-]?[0-9]*[.]?[0-9]+$';  # extract whole numeral that may be signed (allows no leading 0 : .nu)
PROP_NUM='^[+-]?((0|[1-9][0-9]*)([.][0-9]+)?)$';    # no multiple leading 0, decimals require leading digit
VAR_NAME='^[A-Za-z_][A-Za-z_0-9]*$'; # check if whole str a valid variable name
VAR_CHAR='[A-Za-z_][A-Za-z_0-9]*';   # check if a string is valid variable name
IS_A_HEX='^(x|0x|\x)[0-9a-fA-F]{1,}$';              # used to check if hex no. (prefix req'd.: 0x|x|\x)
ALL__HEX='^(x|0x|\x)?[0-9a-fA-F]{1,}$';             # used to check if all hex (includes bare: HH)
IS_EMAIL='^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$';
# Normal='^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$';    # mac : Mac hex addr.
MAC_ADDR='^([[:xdigit:]]{2}:){6}$';  # mac : Mac hex addr. (supply: "$data":)
# NB: in the following pattern the '|' with nothing doesn't work in bash 3.2.57
#ISANURL='^(https?://|ftp://|file://|www\.|)[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$';
IS_ANURL='^(https?://|ftp://|file://|www\.)*[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$';
IPV6_DEC='^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){15}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$';
IPV4_DEC='^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$';
IPV4_HEX='^(([1-9a-fA-F]?[0-9a-fA-F])\.){3}([1-9a-fA-F]?[0-9a-fA-F])$';
IPV6_HEX='^(([0-9a-fA-F]){1,4}\:){7}(([0-9a-fA-F]){1,4})$'; # leading 0's allowed

#############################################################################
# SIP REGEX Support: +|-; 5; -5-; 5+; 5.6,7.8; & 5-6; 5.6-7.8; -6--5
# Note: we don't allow leading '.'|'0' (e.g.: .1|01); regex for SHIP
# called SIP, but enum indices for SHIP are all referred to as: SHIP_
#############################################################################
SIP_PLMS='[+-]?';
SIP_DECP="([.][0-9]+)?";
SIP_UINT='(0|[1-9][0-9]*)';
SIP_UNUM="$SIP_UINT$SIP_DECP";
SIP_SNUM="$SIP_PLMS$SIP_UNUM";
SIP_SINT="$SIP_PLMS$SIP_UINT";          # Note: not used (just for reference)
# defaults with no options set          # ones: ([+-]?(0|[1-9][0-9]*)([.][0-9]+)?)?[+-]?
SIP_ONES="^($SIP_SNUM)?$SIP_PLMS$";     # extract monos: ^{{+|-}#}{+|-}$
SIP_RANG="^$SIP_SNUM[-]$SIP_SNUM$";     # extract range: ^(0|[1-9][0-9]*)([.][0-9]+)?[-](0|[1-9][0-9]*)$
SIP_ENUM="^$SIP_SNUM([,]$SIP_SNUM)+$";  # extract enums: ^(0|[1-9][0-9]*)([.][0-9]+)?([,](0|[1-9][0-9]*))+$

#############################################################################
# List of my defined 'standard' return codes; to get the list of all internal
# errors that map to 'standard' errors below: getparms -he -m; e.g. error:
# 0 valid[0]: func=9 : MISORDR : wrong ordering cmd-line item [ 9]
#############################################################################
declare -a ErrorStr; declare -a ErrDetail; # verify following mappings by running: getparms -he -m
ErrorStr[$SUCCESS]="SUCCESS";   ErrDetail[$SUCCESS]=""; # "everything successfully done [0]";  # : {no errors}
ErrorStr[$FAILURE]="FAILURE";   ErrDetail[$FAILURE]="received bad setup option(s) [ 1]"; # 4: MTHS|RTUN|TOSA|XNAM
ErrorStr[$UNFOUND]="UNFOUND";   ErrDetail[$UNFOUND]="cannot locate required items [ 2]"; # 4: DTPV|MIPP|QUNF|REQD
ErrorStr[$FOUNDIT]="FOUNDIT";   ErrDetail[$FOUNDIT]="found unwanted item or value [ 3]"; # 4: DFCN|MULO|MULP|RHLP
ErrorStr[$NOTSPEC]="NOTSPEC";   ErrDetail[$NOTSPEC]="problem in the specification [ 4]"; # 4: BPVR|MTPI|PALT|RWEV
ErrorStr[$TOOMANY]="TOOMANY";   ErrDetail[$TOOMANY]="multiple same items received [ 5]"; # 4: MIOG|MORP|MSOR|MIPC
ErrorStr[$MISMTCH]="MISMTCH";   ErrDetail[$MISMTCH]="a param format doesn't match [ 6]"; # 4: DTSH|DVUN|INVN|PFER
ErrorStr[$UNSUPPT]="UNSUPPT";   ErrDetail[$UNSUPPT]="feature disabled|unsupported [ 7]"; # 4: CFUN|DTOP|INDO|OIND
ErrorStr[$MISORDR]="MISORDR";   ErrDetail[$MISORDR]="wrong ordering cmd-line item [ 8]"; # 4: ENDL|MRPP|OADD|RVOR
ErrorStr[$ILLFORM]="ILLFORM";   ErrDetail[$ILLFORM]="item is ill-formed|not a var [ 9]"; # 4: BFCN|BNAM|SIPI|UMSG
ErrorStr[$UNKNOWN]="UNKNOWN";   ErrDetail[$UNKNOWN]="an unknown item was received [10]"; # 5: DTUD|SHOP|UNKC|UNKI|UNDF
MAX_ERR=$UNKNOWN; # Keep as last                                                   Total: 41

#############################################################################
# generate err string: -n => #, -b => ErrorStr, else: ErrorStr : ErrDetail [#]
# e.g.: UNFOUND : cannot locate required items [ 2]
# e.g. -r: 2 : UNFOUND : cannot locate required items [ 2]
# also supports inputs of: func=2 (where func=
#############################################################################
function  ErrStr() { local HELP="ErrStr {-b|-n|-r}{-v} {retCode} # -b bare name, no opt. same as -v (verbose), -n no.";
    local opt=0; local num=0; local rev=0; local vrb=0; TMP=""; # def.: verbose, rev
    while [ $# -gt 0 ] && [[ "$1" == -* ]]; do case "$1" in
        -b) opt=1; vrb=0; shift;;
        -n) opt=1; vrb=0; shift; num=1;;
        -r) vrb=0; rev=1; shift;;
        -v) opt=1; vrb=1; shift;;
        -*) echo "$HELP: bad opt=$1" >&2; return $UNKNOWN;;
    esac; done; if ((opt == 0)); then rev=1; fi # if no opts, def. is rev=1
    local err=$1; shift; local func=${err/=*/}; # discards "=*" to get "func"
    if   [[ "$err" == "$func" ]]; then func=""; else func+="="; fi
    err=${err/*=/}; # in case: func=# => err=#
    if ! [[ "$err" =~ [0-9]+ ]] || ((err > MAX_ERR)); then err=$MAX_ERR; fi
    local lng="${ErrDetail[$err]}";    local errStr="${ErrorStr[$err]}";
    # NB: must be left aligned numbers (%-2d) so that it is: func=0  : SUCCESS
    if   ((err < 10)); then printf -v err "%-2d" "$err"; fi # e.g.: 2 => "2 "
    if   ((rev == 1));                 then TMP="$func$err : $errStr";
    elif ((num == 1)) && ((vrb == 1)); then TMP=$func$err; TMP+=" : $errStr";
    elif ((num == 1));                 then TMP=$err; else TMP="$errStr"; fi
    if   ((vrb == 1)) && [[ "$lng" ]]; then TMP+=" = $lng"; fi
}

#############################################################################
# Error Enums: see all errors via -he; ensure these are continuous numbers
# or add dummy: ErrName[$...]=""; these are distinct from 'standard' return
# values that use ErrorStr & ErrorMsg. To get the list of all the internal
# errors that map to 'standard' return codes run: -he -r (-he -m for sorted).
# Values prior to CMDL are: Specification Errors. The first line is a header.
# Note: have to keep CFUN different from BPVR, as should be ignored in order
# to allow backward capability with different configuration options
# Note: leave DFCN & DTSH as is in case we eliminate them as errors in future.
#############################################################################
declare -a ErrName;        declare -a ErrText; i=-1;
((i++)); BERR=$i; ErrName[$i]="BERR"; ErrText[$i]="List of Specification Errors";    # 0 = ErrText[BERR]
((i++)); UNDF=$i; ErrName[$i]="UNDF"; ErrText[$i]="An undefined error is supplied:"; # 1
((i++)); BFCN=$i; ErrName[$i]="BFCN"; ErrText[$i]="Bad|absent function name found:"; # 2
((i++)); BNAM=$i; ErrName[$i]="BNAM"; ErrText[$i]="Item's name contains bad chars:"; # 3
((i++)); BPVR=$i; ErrName[$i]="BPVR"; ErrText[$i]="Bad parsing value was received:"; # 4
((i++)); CFUN=$i; ErrName[$i]="CFUN"; ErrText[$i]="Unknown -c Config was received:"; # 5
((i++)); DFCN=$i; ErrName[$i]="DFCN"; ErrText[$i]="Collides with the scripts name:"; # 6  MULP? no
((i++)); DTOP=$i; ErrName[$i]="DTOP"; ErrText[$i]="Options don't support Datatype:"; # 7
((i++)); DTPV=$i; ErrName[$i]="DTPV"; ErrText[$i]="Datatype requires a parm value:"; # 8
((i++)); DTSH=$i; ErrName[$i]="DTSH"; ErrText[$i]="Datatype unsupported for SHIPs:"; # 9  DTSH? no
((i++)); DTUD=$i; ErrName[$i]="DTUD"; ErrText[$i]="Unrecognized Datatype received:"; # 10
((i++)); DVUN=$i; ErrName[$i]="DVUN"; ErrText[$i]="DataValu unsupported for dtype:"; # 11
((i++)); ENDL=$i; ErrName[$i]="ENDL"; ErrText[$i]="Item after endless parm. found:"; # 12
((i++)); INVN=$i; ErrName[$i]="INVN"; ErrText[$i]="Invalid received number format:"; # 13
((i++)); MIPP=$i; ErrName[$i]="MIPP"; ErrText[$i]="Missing IndirectParameter parm:"; # 14
((i++)); MORP=$i; ErrName[$i]="MORP"; ErrText[$i]="Multiple parm in a Mixed group:"; # 15
((i++)); MIPC=$i; ErrName[$i]="MIPC"; ErrText[$i]="Multiple IndirectParm w/commas:"; # 16
((i++)); MRPP=$i; ErrName[$i]="MRPP"; ErrText[$i]="More requires a preceding parm:"; # 17
((i++)); MTHS=$i; ErrName[$i]="MTHS"; ErrText[$i]="Empty HELP Option string given!"; # 18
((i++)); MTPI=$i; ErrName[$i]="MTPI"; ErrText[$i]="Parsing item empty | has space:"; # 19
((i++)); MULO=$i; ErrName[$i]="MULO"; ErrText[$i]="Multiple option with same name:"; # 20
((i++)); MULP=$i; ErrName[$i]="MULP"; ErrText[$i]="Multiple output names are same:"; # 21
((i++)); OADD=$i; ErrName[$i]="OADD"; ErrText[$i]="No Options after a double dash:"; # 22
((i++)); PALT=$i; ErrName[$i]="PALT"; ErrText[$i]="Params can't have an alt. name:"; # 23
((i++)); QUNF=$i; ErrName[$i]="QUNF"; ErrText[$i]="Quoted string was not finished:"; # 24
((i++)); RHLP=$i; ErrName[$i]="RHLP"; ErrText[$i]="Collides with defined help opt:"; # 25
((i++)); RNAE=$i; ErrName[$i]="RNAE"; ErrText[$i]="Range not allowed with extract:"; # 26
((i++)); SHOP=$i; ErrName[$i]="SHOP"; ErrText[$i]="Unrecognized SHIP option found:"; # 27
((i++)); TOSA=$i; ErrName[$i]="TOSA"; ErrText[$i]="Total Optimized size != to all:"; # 28
((i++)); XNAM=$i; ErrName[$i]="XNAM"; ErrText[$i]="Exported Help var. name is bad:"; # 29

((i++)); CMDL=$i; ErrName[$i]="CMDL"; ErrText[$i]="List of All CommandLine Errs";    # 30 # Bgn Cmd-Line Errs
((i++)); INDO=$i; ErrName[$i]="INDO"; ErrText[$i]="IndOptions can't be p/o combos:"; # 31
((i++)); OIND=$i; ErrName[$i]="OIND"; ErrText[$i]="Old Style IndParam is disabled:"; # 32
((i++)); MIOG=$i; ErrName[$i]="MIOG"; ErrText[$i]="More than 1 item in ORed group:"; # 33
((i++)); MSOR=$i; ErrName[$i]="MSOR"; ErrText[$i]="Multiple same options received:"; # 34
((i++)); PFER=$i; ErrName[$i]="PFER"; ErrText[$i]="Parameter format doesn't match:"; # 35
((i++)); REQD=$i; ErrName[$i]="REQD"; ErrText[$i]="Required item was not received:"; # 36
((i++)); RVOR=$i; ErrName[$i]="RVOR"; ErrText[$i]="Received Value is Out of Range:"; # 37
((i++)); RWEV=$i; ErrName[$i]="RWEV"; ErrText[$i]="Received Wrong Enumerate Value:"; # 38
((i++)); SIPI=$i; ErrName[$i]="SIPI"; ErrText[$i]="Short Hand Ind Parm bad format:"; # 39
((i++)); UMSG=$i; ErrName[$i]="UMSG"; ErrText[$i]="User message is missing or bad:"; # 40
((i++)); UNKC=$i; ErrName[$i]="UNKC"; ErrText[$i]="Unknown combo opt was received:"; # 41
((i++)); UNKI=$i; ErrName[$i]="UNKI"; ErrText[$i]="Unknown parameter was received:"; # 42
((i++)); ZERR=$i; # keep this one past last Error                                    # 43

# List of Errors that tests are still needed for (N/A: BERR, UNDF, CMDL, TOSA)
TestsNeeded=""; # NB: keep in sync with getparmstest.sh

#############################################################################
# Map the above errors to one of the standard errors (ErrorStr)
# that are used for the return status, which are listed below:
# FAILURE=1;
# UNFOUND=2;   # cannot locate required items
# FOUNDIT=3;   # found unwanted item or value
# NOTSPEC=4;   # problem in the specification
# TOOMANY=5;   # multiple same items received
# MISMTCH=6;   # a param format doesn't match
# UNSUPPT=7;   # feature disabled|unsupported
# MISORDR=8;   # wrong ordering cmd-line item
# ILLFORM=9;   # item is ill-formed/not a var
# UNKNOWN=10;
# ---------------------------------------------------------------------------
# Non-fatal errors are those found during the Analyze phase in the Spec,
# which though wrong don't prevent continued execution, but if they cause
# multiple other errors it is best to make them fatal anyway
#############################################################################
declare -a ErrMapped; declare -a ErrPrnt; declare -a FatalErr;
i=$BERR; ErrMapped[$i]=$SUCCESS; ErrPrnt[$i]=0; FatalErr[$i]=0;
i=$UNDF; ErrMapped[$i]=$UNKNOWN; ErrPrnt[$i]=1; FatalErr[$i]=0; # An undefined error is supplied [pgming err]
i=$BFCN; ErrMapped[$i]=$ILLFORM; ErrPrnt[$i]=1; FatalErr[$i]=1; # Bad|absent function name found [can't cont] [or: UNFOUND]
i=$BNAM; ErrMapped[$i]=$ILLFORM; ErrPrnt[$i]=1; FatalErr[$i]=1; # Item's name contains bad chars [can't cont]
i=$BPVR; ErrMapped[$i]=$NOTSPEC; ErrPrnt[$i]=1; FatalErr[$i]=1; # Bad parsing value was received [fix it 1st]
i=$CFUN; ErrMapped[$i]=$UNSUPPT; ErrPrnt[$i]=1; FatalErr[$i]=0; # Unknown -c Config was received
i=$DFCN; ErrMapped[$i]=$FOUNDIT; ErrPrnt[$i]=1; FatalErr[$i]=0; # Collides with the scripts name
i=$DTOP; ErrMapped[$i]=$UNSUPPT; ErrPrnt[$i]=1; FatalErr[$i]=0; # Options don't support Datatype
i=$DTPV; ErrMapped[$i]=$UNFOUND; ErrPrnt[$i]=1; FatalErr[$i]=0; # Datatype requires a parm value              [or: ILLFORM]
i=$DTSH; ErrMapped[$i]=$MISMTCH; ErrPrnt[$i]=1; FatalErr[$i]=0; # Datatype unsupported for SHIPs
i=$DTUD; ErrMapped[$i]=$UNKNOWN; ErrPrnt[$i]=1; FatalErr[$i]=0; # Unrecognized Datatype received
i=$DVUN; ErrMapped[$i]=$MISMTCH; ErrPrnt[$i]=1; FatalErr[$i]=0; # DataValu unsupported for dtype
i=$ENDL; ErrMapped[$i]=$MISORDR; ErrPrnt[$i]=1; FatalErr[$i]=0; # Item after endless parm. found
i=$INVN; ErrMapped[$i]=$MISMTCH; ErrPrnt[$i]=1; FatalErr[$i]=0; # Invalid received number format
i=$MIPP; ErrMapped[$i]=$UNFOUND; ErrPrnt[$i]=1; FatalErr[$i]=1; # Missing IndirectParameter parm [can't cont]
i=$MORP; ErrMapped[$i]=$TOOMANY; ErrPrnt[$i]=1; FatalErr[$i]=0; # Multiple parm in a Mixed group
i=$MIPC; ErrMapped[$i]=$TOOMANY; ErrPrnt[$i]=1; FatalErr[$i]=1; # Multiple OSIPs comma separated [can't cont]
i=$MRPP; ErrMapped[$i]=$MISORDR; ErrPrnt[$i]=1; FatalErr[$i]=1; # More requires a preceding parm [can't cont]
i=$MTHS; ErrMapped[$i]=$FAILURE; ErrPrnt[$i]=1; FatalErr[$i]=1; # Empty HELP Option string given [can't cont]
i=$MTPI; ErrMapped[$i]=$NOTSPEC; ErrPrnt[$i]=1; FatalErr[$i]=1; # Parsing item empty | has space [can't cont] [or: ILLFORM]
i=$MULO; ErrMapped[$i]=$FOUNDIT; ErrPrnt[$i]=1; FatalErr[$i]=1; # Multiple option with same name [don't cont]
i=$MULP; ErrMapped[$i]=$FOUNDIT; ErrPrnt[$i]=1; FatalErr[$i]=0; # Multiple output names are same
i=$OADD; ErrMapped[$i]=$MISORDR; ErrPrnt[$i]=1; FatalErr[$i]=0; # No Options after a double dash
i=$PALT; ErrMapped[$i]=$NOTSPEC; ErrPrnt[$i]=1; FatalErr[$i]=0; # Params can't have an alt. name [can ignore] [or: UNSUPPT]
i=$QUNF; ErrMapped[$i]=$UNFOUND; ErrPrnt[$i]=1; FatalErr[$i]=1; # Quoted string was not finished [can't cont] [or: ILLFORM]
i=$RHLP; ErrMapped[$i]=$FOUNDIT; ErrPrnt[$i]=0; FatalErr[$i]=1; # Collides with defined help opt [can't cont]
i=$RNAE; ErrMapped[$i]=$FAILURE; ErrPrnt[$i]=1; FatalErr[$i]=0; # Range not allowed with extract [can ignore]
i=$SHOP; ErrMapped[$i]=$UNKNOWN; ErrPrnt[$i]=1; FatalErr[$i]=1; # Unrecognized SHIP option found [a spec err]
i=$TOSA; ErrMapped[$i]=$FAILURE; ErrPrnt[$i]=1; FatalErr[$i]=0; # Total Optimized size != to all [pgming err]
i=$XNAM; ErrMapped[$i]=$FAILURE; ErrPrnt[$i]=1; FatalErr[$i]=1; # Exported Help var. name is bad [can't cont] [or: ILLFORM]
# Note:  Fatal for cmd-line items makes no difference but does show as: Warn_Msgs
i=$CMDL; ErrMapped[$i]=$UNKNOWN; ErrPrnt[$i]=1; FatalErr[$i]=0; # Bgn of the Command-Line Errors ####
i=$INDO; ErrMapped[$i]=$UNSUPPT; ErrPrnt[$i]=1; FatalErr[$i]=1; # IndOptions can't be p/o combos
i=$OIND; ErrMapped[$i]=$UNSUPPT; ErrPrnt[$i]=1; FatalErr[$i]=0; # Old Style IndParam is disabled
i=$MIOG; ErrMapped[$i]=$TOOMANY; ErrPrnt[$i]=1; FatalErr[$i]=1; # More than 1 item in ORed group
i=$MSOR; ErrMapped[$i]=$TOOMANY; ErrPrnt[$i]=1; FatalErr[$i]=1; # Multiple same options received
i=$PFER; ErrMapped[$i]=$MISMTCH; ErrPrnt[$i]=1; FatalErr[$i]=1; # Parameter format doesn't match
i=$REQD; ErrMapped[$i]=$UNFOUND; ErrPrnt[$i]=1; FatalErr[$i]=1; # Required item was not received
i=$RVOR; ErrMapped[$i]=$MISORDR; ErrPrnt[$i]=1; FatalErr[$i]=1; # Received Value is Out of Range
i=$RWEV; ErrMapped[$i]=$NOTSPEC; ErrPrnt[$i]=1; FatalErr[$i]=1; # Received Wrong Enumerate Value
i=$SIPI; ErrMapped[$i]=$ILLFORM; ErrPrnt[$i]=1; FatalErr[$i]=1; # Short Hand Ind Parm bad format
i=$UMSG; ErrMapped[$i]=$ILLFORM; ErrPrnt[$i]=1; FatalErr[$i]=1; # User message not kept together
i=$UNKC; ErrMapped[$i]=$UNKNOWN; ErrPrnt[$i]=1; FatalErr[$i]=1; # Unknown combo opt was received
i=$UNKI; ErrMapped[$i]=$UNKNOWN; ErrPrnt[$i]=1; FatalErr[$i]=1; # Unknown parameter was received

#############################################################################
# PrintAllRtnErr {-b|-r|-m} # -b rtn codes, -r reverse [rtn codes 1st], -m map
# Skip printing of this if doing any version of -m|-r  [see Print AllErrMsg]
#############################################################################
function  PrintAllRtnErr() { # PrintAllRtnErr {-b|-r|-m} # called from -he
    if [[ "$1" == -*[rm]* ]] || [[ "$2" == -*[rm]* ]]; then return; fi
    local err; local lead=""; #"    ";
   #if [[ "$1" == -*b* ]] || [[ "$2" == -*b* ]]; then lead=""; fi
    printf " Returns = $RTNHDG\n"  "$lead"
    for ((err=SUCCESS; err <= MAX_ERR; err++)); do
        ErrStr -v $err; if ((err == SUCCESS));
        then TMP+=" = everything successfully done [ 0]"; fi
        printf " %s%s\n" "$lead" "$TMP"; # %02d "$err"
    done
}

#############################################################################
# Print All Error Messages shows error enum & their associated return code
# mappings (via: -he). To show return codes & their mappings to error enum,
# i.e. the reverse listing, add -r. To show only return code enum and its
# message strings do: -he -b. To show sorted list of mappings: -he -m | -hem
# Options: {-b|-r|-m} # -b rtn codes, -r rev. [rtn codes 1st], -m mappings
#############################################################################
function  PrintAllErrMsg() { # PrintAllErrMsg {-r|-m} # prints all errors # called from -he
    if [[ "$1" == -*b* ]] || [[ "$2" == -*b* ]]; then return; fi # only do: PrintAllRtnErr
    local cr="";  if ((CfgSet[CF_ECHONO] == 0)); then cr="$CR"; fi
    if [[ "$1" == -*m* ]] || [[ "$2" == -*m* ]]; then # line up after ': '
        # sample error: FAILURE : received bad setup option(s) [ 1] <= MTHS = Empty HELP Option string given [18]
        printf "${cr}Returns : Standard Return Value string      <= Code = $SPCMDL\n";
        getparms -he -r | grep -v "^[[:space:]]*$" | grep -v "Code = " | sort; return;
    fi

    local rev=0; if [[ "$1" == -*r* ]] || [[ "$2" == -*r* ]]; then rev=1; fi
    local str; local ic; local msg; local err; local map; local len; if ((rev == 0));
    then local go2="Mapping = to the Standard Return Value"; # normal order
                 printf "$cr    Code = %-34s $go2\n" "${ErrText[$BERR]}"; # line up after ': '
        for ((ic=BERR+1; ic < ZERR; ic++)); do msg="${ErrText[$ic]}";
            if  [[ "$msg" ]];  then err=${ErrName[$ic]}; map=${ErrMapped[$ic]};
                 ErrStr -v $map;  # get std return code & string [in TMP]
                 if   ((ic == CMDL)); then  # print cmdline separator line
                 printf "$cr    Code = %-34s $go2\n" "${ErrText[$ic]}"; else
                 printf "%02d: %-4s = %s => %s\n" $ic "$err" "$msg" "$TMP"; fi
            fi
        done; # else print in reverse with mapping first
    else local frm="Code = Internal getparms.sh errorcode ";
                 printf "${cr}Returns = %-33s <= $frm\n" "${ErrText[$BERR]}"; # line up after ': '
        for ((ic=BERR+1; ic < ZERR; ic++)); do msg="${ErrText[$ic]}"; # print even if no err string
            err=${ErrName[$ic]}; map=${ErrMapped[$ic]}; len=${#msg};
            ErrStr -v $map;  # get std return code & string [in TMP]
            if   ((ic == CMDL)); then  # print cmdline separator line
                 printf "${cr}Returns = %-33s <= $frm\n" "${ErrText[$ic]}";
            else msg="${msg:0:len-1}"; # drop last ch (':')
                 printf "%s <= %-4s = $msg [%02d]\n"   "$TMP" "$err" $ic; fi
        done;
    fi; if  ((CfgSet[CF_ECHONO] == 0)); then echo; fi
}

#############################################################################
# Set Types of Input & Output Status Enums
# NB: since indparm are both option+parms, their status is stored separately
# Invalid enums are an error level below ErrName, which have been added to separate
# different reasons for errs in is_string, is_number, RangeStr, RangeNum, & Matchdata
# NB: RxdInvld array stores the actual received value
#############################################################################
declare -a   BaseName;
UNK_BASE=0;  BaseName[$UNK_BASE]="unk";      # Unknown|Bad: an unknown|empty BaseTyp
HLP_BASE=1;  BaseName[$HLP_BASE]="hlp";      # Helps Items: help strings & function name
OPT_BASE=2;  BaseName[$OPT_BASE]="opt";      # Option Type: -img or -i|--index
SIP_BASE=3;  BaseName[$SIP_BASE]="sip";      # ShortIndPrm: -i=
PRM_BASE=4;  BaseName[$PRM_BASE]="prm";      # Pure Param.: name or name|name2
EOM_BASE=5;  BaseName[$EOM_BASE]="eom";      # EndOfMarker: --|-+
MAX_BASE=6;  # Keep as last

declare -a   RxMsgStr; ResultStr="Result";   # 'name' of result: if ! -cc [short: 1st 3 letters]
RX_EMPTY=0;  RxMsgStr[$RX_EMPTY]="empty";    # item not received (if optional) [was: emt => emp]
RX_MISSN=1;  RxMsgStr[$RX_MISSN]="misin";    # item not received (if required) [was: mis => mis]
RX_INVLD=2;  RxMsgStr[$RX_INVLD]="invld";    # item was received invalid value [was: inv => inv]
RX_2MANY=3;  RxMsgStr[$RX_2MANY]="multi";    # item was received too often     [was: mny => mul]
RX_VALID=4;  RxMsgStr[$RX_VALID]="valid";    # item was received no problem    [was: vld => val]
RX_ENDOF=5;  # Keep as last

declare -a   IndName; declare -a   IndShrt;  # IndStat stores actual value
IND_EMPT=0;  IndName[$IND_EMPT]="IND_EMPT";  IndShrt[$IND_EMPT]="empt";  # starting state => search for option
IND_OPTN=1;  IndName[$IND_OPTN]="IND_OPTN";  IndShrt[$IND_OPTN]="optn";  # found a option => search for param.
IND_INDP=2;  IndName[$IND_INDP]="IND_INDP";  IndShrt[$IND_INDP]="indp";  # found a param. => save ind. param.
IND_OSIP=3;  IndName[$IND_OSIP]="IND_OSIP";  IndShrt[$IND_OSIP]="osip";  # old style indp => save data (-i=ind)
IND_ERRS=4;  IndName[$IND_ERRS]="IND_ERRS";  IndShrt[$IND_ERRS]="errs";  # keep one past last valid enum

declare -a   Invalids;    declare -a InvMsg;
INV_GOOD=0;  Invalids[$INV_GOOD]="INV_GOOD"; InvMsg[$INV_GOOD]="not invalid ";
INV_STRG=1;  Invalids[$INV_STRG]="INV_STRG"; InvMsg[$INV_STRG]="wrong string";
INV_NUMB=2;  Invalids[$INV_NUMB]="INV_NUMB"; InvMsg[$INV_NUMB]="wrong number";
INV_TYPE=3;  Invalids[$INV_TYPE]="INV_TYPE"; InvMsg[$INV_TYPE]="bad datatype";
INV_ENUM=4;  Invalids[$INV_ENUM]="INV_ENUM"; InvMsg[$INV_ENUM]="bad enum val";
INV_FILE=5;  Invalids[$INV_FILE]="INV_FILE"; InvMsg[$INV_FILE]="bad file|dir";
INV_MTCH=6;  Invalids[$INV_MTCH]="INV_MTCH"; InvMsg[$INV_MTCH]="bad mismatch";  # (often hex)
INV_RANG=7;  Invalids[$INV_RANG]="INV_RANG"; InvMsg[$INV_RANG]="out of range";
INV_VALU=8;  Invalids[$INV_VALU]="INV_VALU"; InvMsg[$INV_VALU]="wrong values";
INV_OPTN=9;  Invalids[$INV_OPTN]="INV_OPTN"; InvMsg[$INV_OPTN]="a bad option";
INV_FIND=10; Invalids[$INV_FIND]="INV_FIND"; InvMsg[$INV_FIND]="wasn't found";
INV_SHIP=11; Invalids[$INV_SHIP]="INV_SHIP"; InvMsg[$INV_SHIP]="bad SHIP form";
INV_OSIP=12; Invalids[$INV_OSIP]="INV_OSIP"; InvMsg[$INV_OSIP]="OSIP disabled";
INV_UNSP=13; Invalids[$INV_UNSP]="INV_UNSP"; InvMsg[$INV_UNSP]="not supported"; # enums w/ spaces

#############################################################################
# Some are multiply mapped:
# INVN from INV_NUMB|INV_MTCH; PFER from INV_STRG|INV_FILE|INV_VALU
# Note: some of the following return codes are only mapped (marked as such)
#############################################################################
declare -a InvErr; declare -a InvRtn; # NB: not using MISORDR
InvErr[$INV_GOOD]="";    InvRtn[$INV_GOOD]=$SUCCESS; # "not invalid "
InvErr[$INV_STRG]=$PFER; InvRtn[$INV_STRG]=$FAILURE; # "wrong string"
InvErr[$INV_NUMB]=$INVN; InvRtn[$INV_NUMB]=$FAILURE; # "wrong number"  [only mapped!]
InvErr[$INV_TYPE]=$RNAE; InvRtn[$INV_TYPE]=$NOTSPEC; # "bad datatype"  [only mapped!]
InvErr[$INV_ENUM]=$RWEV; InvRtn[$INV_ENUM]=$NOTSPEC; # "bad enum val"  [only mapped!]
InvErr[$INV_FILE]=$PFER; InvRtn[$INV_FILE]=$UNFOUND; # "bad file|dir"  (make new err)
InvErr[$INV_MTCH]=$INVN; InvRtn[$INV_MTCH]=$MISMTCH; # "bad mismatch"  [only mapped!] (or PFER if NAN)
InvErr[$INV_RANG]=$RVOR; InvRtn[$INV_RANG]=$TOOMANY; # "out of range"  [only mapped!]
InvErr[$INV_VALU]=$PFER; InvRtn[$INV_VALU]=$UNFOUND; # "wrong values"
InvErr[$INV_OPTN]=$UNKI; InvRtn[$INV_OPTN]=$UNKNOWN; # "a bad option"
InvErr[$INV_FIND]=$DTUD; InvRtn[$INV_FIND]=$UNFOUND; # "wasn't found"  [only mapped!]
InvErr[$INV_SHIP]=$SIPI; InvRtn[$INV_SHIP]=$ILLFORM; # "bad SHIP form" [only mapped!]
InvErr[$INV_OSIP]=$OIND; InvRtn[$INV_OSIP]=$FOUNDIT; # "OSIP disabled"
InvErr[$INV_UNSP]=$DVUN; InvRtn[$INV_UNSP]=$UNSUPPT; # "not supported"

################################################################################
# Simplified version of unstub to make debug functions point to an actual
# function only when debugging has been enabled. Default is to leave them
# pointing to stubs, which do nothing to not slow down execution. Modified
# version of stub from GitHub Gist by jimeh/stub.bash (Dec 9, 2019).
# [Only the function stub encapsulated and simplified here in Unstub:
# Copyright (c) 2014 Jim Myhrberg.] Note here we are exporting so that if
# a shell is called the same definition will still be used.
#
# Note the original stub function used in stub and restore (respectively):
# if [[ "$(type      "$cmd" 2>/dev/null | head -1)" == *"$FCNSTR" ]];
# if [[ "$(type "$BKUP$cmd" 2>/dev/null | head -1)" == *"$FCNSTR" ]];
# where: local FCNSTR="is a function";
# [Note: unset even if function doesn't exist (no output error message)]
################################################################################
function  Unstub() { # Unstub cmd
    local cmd="$1"; local fcn;           # in our case we know backup always exists
    fcn="$(type "__$cmd" | tail -n +2)"; # get orig def. (skip "is a function")
    fcn="${fcn/__$cmd/$cmd}";            # replace function name to original
    eval "$fcn"; export -f "$cmd";       # restore original & export it
} # never remove backup in simplified case

#############################################################################
# Some functions are useful for debugging but are not technically needed for
# getparms. The following functions are in that category: cdebug
# Function Exists checks if a function is defined in the running environment.
#############################################################################
function  FuncExists()  { declare -F -- "$@" >/dev/null; } # check if a function exists [$@ for multiple functions]

#############################################################################
# cdebug turns tracing on & off; it has several forms (described below).
# Note: cdebug passes through the status, except in the 2 parameter case
# where SUCCESS if returned if the end tracing state matches the 1st parm.
# This way it can be used in if statements (as shown below).
#
# cdebug on|off                     # forces tracing on|off based on string
# cdebug -s no; ...; cdebug -s on;  # temporarily disable tracing by saving
#                                   # the tracing state & then restoring it
# cdebug on|off on|off|!0|0         # turns tracings on|off conditionally based
#                                   # on the second parameter if on|!0 (i.e. 1+)
# e.g.:  if   cdebug on $dbg; then ...; fi # if tests only work for 2 parm case
#        if ! cdebug on $dbg; then ...; fi # if tests only work for 2 parm case
#############################################################################
if ! FuncExists cdebug; then
cdebug() { # cdebug {-s} on|no {on|1|no|0} # turn on|off tracing # -s save & restore tracing
    # don't want to trace this function (in case tracing is already on when called)
    # so we wrap this entire function & discard any output from it sending to null
    { local sts=$?;  local do=1; local off="+x"; local val=0; # set defaults (off)
      if  [[ "$1" == -s ]]; then shift; # NB: this form only uses 1 parm remaining
          if   [[ "$1" == on ]]; then   # this is the restore previous state case
               # only turn tracing back on, if previously: on
               if [[ "$SAVTRACE" != "" ]]; then val=$SAVTRACE;
                  if  [[ "$val" == "1" ]]; then off="-x"; fi # else leave off
               else do=0; fi
          else export SAVTRACE=$TRACING; # save present state & turn off (default)
          fi;  if ((do == 1)); then export TRACING=$val; set $off; fi # set tracing

      else # if 2+ parms and 2nd parm is not enabled, then ignore this call
          if  [ $# -ge 2 ]; then if [[ "$2" == no ]] || [ "$2" == 0 ]; then do=0;
              elif [[ ! "$TRACING" ]]; then TRACING=0; export TRACING=0; fi
          fi; if ((do == 1)); then if [[ "$1" == on ]] || ([[ "$1" =~ ^[0-9]+$ ]] && (($1 >= 1)));
              then off="-x"; val=1; fi; export TRACING=$val; set $off; # set tracing
          fi; if [ $# -ge 2 ]; then sts=$(((val == TRACING) ? SUCCESS : FAILURE)); fi
      fi; return $sts; # return original status, unless 2 parm method
    } 2>/dev/null;
};  fi

#############################################################################
# Globals used to speed up processing or control overall program flow.
# Make sure to add all new globals to the global init routine (gbl init),
# which must be called for iterative calls to getparms from calling script
#############################################################################
RMARGS=0;                 # num. of removed args: Collapse Args
NbEcho=0;                 # track echoes printed out @start
DbgPrt=0;                 # flag to print basic debug info  (enable via -d)
TrcIni=0;                 # flag to trace Initial only part (enable via -d_)
TrcAna=0;                 # flag to trace Analyze only part (enable via -da)
TrcBox=0;                 # flag to trace Check Spec'n part (enable via -db)
TrcCmd=0;                 # flag to trace Command-line part (enable via -dc)
TrcDel=0;                 # flag to trace Deliver results   (enable via -dd)
TrcItm="";                # flag to display an item's state (enable via -di)
TrcShr=0;                 # flag to display cmdline b4 shift(enable via -ds)
TrcDbg=0;                 # flag to trace DBG_TRC routines (manually change)
DbgNum=0;                 # flag to count the number of enabled debug flags
Reinit=0;                 # flag to indicate getparms calling itself so reinit
PrtReq=1;                 # count of required numbers to print by Prt ReqNum
DbgMsg="";                # text supplied by user & passed to output display
GotHelp=0;                # set if we exited without printing func=status
RtnRslt="";               # set if we retrieve the last execution result
GotEndl=0;                # set if we received end endless item
OPTBGN=-1;                # bgn of options location (not set)
OPTEND=-1;                # end of options location (not set)
RUNTEST="";               # if != "" then test string to use
DlmtrsChg=0;              # number of delimiters are changed
PgmSymChg=0;              # number of symbols are changed
EndBgnNdx=-1;             # spec end of bgnprms marker index
EndOptNdx=-1;             # spec end of options marker index
RxdEndBgn=-1;             # cmd-line rcvd end bgnparm marker
RxdEndOpt=-1;             # cmd-line rcvd end options marker
CmdLineBgn=0;             # cmd-line rcvd number begin items
CmdLineNum=0;             # number of all command line items
CmdLineStr="";            # string of all command line items
HlpOpt1="-h";             # default single dash help option (-h)
HlpOpt2="$LHLP_HELP";     # default double dash help option (--help)
HlpOpts="$HlpOpt1|$HlpOpt2"; # combined def. help options: -h|--help
COLS=$(tput cols); COLS=$((COLS < 80 ? COLS : 80)); # don't allow > 80
#-----------------------------------------------------------
# globals used in Indparm State processing, reset in InitInd
IndStat=$IND_EMPT;        # state of searching for an indprm
IndHead=0;                # head option index of indarm item
IndOrnu=0;                # OR'ed group number indp found at
LstOrnu=0;                # OR'ed group number of last option
IndGrpn=0;                # group number this indp prm is on
IndOpts=0;                # number of options in this indprm
IndPrms=0;                # number of indparms in this group
#-----------------------------------------------------------

function  InitGbl() { # initializes global variables (InitGlobals)
    DbgPrt=0; TrcDbg=0; TrcShr=0; TrcItm="";
    TrcIni=0; TrcAna=0; TrcBox=0; TrcCmd=0; TrcDel=0;

    OPT=''; BGN=''; END=''; NUM=''; MIN=''; MAX=''; # for GetRange
    VAL0=''; VAL1=''; VAL2='';  # global used to return values of: ChgCase
    HEX_NUM=''; TMP='';         # global used to get hexadecimals: Hex2Dec & ErrStr+Opt Name
    STR_CMP=''; STR_BAD='';     # global used to get compare str.: GetCompare & Get ShipFlags
    XTRCNUM=''; XTRCSTR='';     # global used to get extracted num|str from pre+annex: is_number | RangeStr
    UNESCBF=''; UNESCAF='';     # global to get strings before & after unesc'd symbol: GetUnescape
    UNESCAP=''; NOESC=0;        # global used to return string after escapes removed:  DelEscapes & HasUnescape

    RMARGS=0;                   # num. of removed args: Collapse Args
    DbgNum=0; NbEcho=0;         # enabled debug flags & echoes printed
    PrtReq=1;                   # count of required nums. to print
    DbgMsg=""; RUNTEST="";      # user text pass to output display + test str
    RtnRslt="";                 # set if we get getparms last result
    GotHelp=0; GotEndl=0;       # if exited & didn't print status + rxd endless
    OPTBGN=-1; OPTEND=-1;       # bgn+end of options location (not set)
    DlmtrsChg=0;  PgmSymChg=0;  # number of delimiters+symbols changed
    EndBgnNdx=-1; EndOptNdx=-1; # spec end of bgnprms+options marker index
    RxdEndBgn=-1; RxdEndOpt=-1; # cmd-line rcvd end bgnparm+options markers
    CmdLineBgn=0; CmdLineNum=0;  # cmd-line rcvd number begin items + all
    CmdLineStr="";              # string of all command line items
    HlpOpt1="-h";               # default single dash help option
    HlpOpt2="$LHLP_HELP";       # default double dash help option
    HlpOpts="$HlpOpt1|$HlpOpt2"; # combined def.: -h|--help
    COLS=$(tput cols);          COLS=$((COLS < 80 ? COLS : 80)); # don't allow > 80

    InitInd 0 "InitGbl";        # init all globals of IndparmState
}

#############################################################################
# Fill Str fills a string with a set character based on the length of another
# string or the difference between a total length and that string's length
# ref is the string that illustrates the length that needs to be filled,
# bgn is the string that begins the string but must be padded with char,
# chr is the char/string that will be used for padding (default = '-').
#############################################################################
function  FillStr() { # FillStr {-o outvarnam}{-q}{-n} bgn ref {char=-} # -n no c/r
    local out=""; local qot=""; local cr=$CR;
    if [[ "$1" == -o ]]; then out="$2"; shift 2; fi
    if [[ "$1" == -q ]]; then qot="'";  shift 1; fi
    if [[ "$1" == -n ]]; then cr="";    shift 1; fi
    local bgn="$1"; local ref="$2"; local chr="$3"; shift 3;
    local prt=0;    local tmp="";   local left;  local fill;
    if [[ ! "$out" ]]; then out="tmp"; prt=1; fi
    if [[ ! "$chr" ]]; then chr="-"; fi
    if [[ ! "$bgn" ]]; then printf -v $out "$fill";
    else printf -v $out "%s" "$ref";
        local lout=${#ref}; local lmid=${#bgn};
        if  ((lmid < lout)); then ((left = lout-lmid));
            eval printf -v fill -- "$chr%.0s" {1..$left}; # fill w/ left no. chars
                 printf -v $out "%s$fill" "$bgn";
        else     printf -v $out "$bgn"; fi # whole str is bgn
    fi; if ((prt == 1)); then printf "$qot%s$qot$cr" "$tmp"; fi
}

#############################################################################
# Print List (Array) function - this doesn't work right if array has empty
# array elements, as empty elements are compressed, then indexing doesn't
# align, but for full arrays it works fine; also doesn't work for external
#############################################################################
function  PrintList() { # PrintList {-i}{-n} min max {-m msg} list # -n no number
    local ndx=0;  if [[ "$1" == -i ]]; then ndx=1; shift; fi # print map indices
    local don=1;  if [[ "$1" == -n ]]; then don=0; shift; fi # print row numbers
    local min=$1; local max=$2; shift 2;
    if [[ "$1" == "-m" ]]; then printf "%s" "$2"; shift 2; fi
    local  ic; local cnt=0; local arr=("$@");
    for  ((ic=min; ic < max; ic++));  do  local str="${arr[$ic]}";
        if [[ "$str" ]]; then ((cnt++));
            if   ((ndx == 1)); # print mapped indices also
            then printf "%02d [%02d]: %s\n" $ic "${CmdLineNdx[$ic]}" "$str";
            elif ((don == 1)); # only print non-empty strings
            then printf "%02d: %s\n" $ic "$str";
            else printf      " %s\n"     "$str"; fi
        fi
    done; #if ((cnt > 0)) && ((CfgSet[CF_ECHONO] == 0)); then echo; fi
}

#############################################################################
# Enum help : in order to print out the internal enums used by getparms with
# their associated meanings, the following help flags are used. They can be
# specified either separately (e.g.: -h -.) or as combined (e.g.: -h.), where:
# . is c|d|e|p|o|t; d is for debug, e for errors, p for parsing symbols,
# o for the delimiter interpretation (required|optional), t for datatypes.
#############################################################################
HLP_ALLS=''; # auto-assembled in InitHlp: 'depot'
HLP_VALS=''; # 'd=debug numbers, e=errors, p=parsing, o=options, t=typedata'
# sub-types of HLP_TYPE
HLP_NUMT='tn';
HLP_STRT='ts';
# main type of HLP_TYPE
HELP_BGN=0; declare -a HelpStr;  declare -a  HelpNam;  declare -a  HelpOpt;
DBUG_NUM=0; HLP_DBUG='d'; HelpNam[$DBUG_NUM]="debug numbers"; HelpOpt[$DBUG_NUM]=$HLP_DBUG;
ERRS_NUM=1; HLP_ERRS='e'; HelpNam[$ERRS_NUM]="errors";        HelpOpt[$ERRS_NUM]=$HLP_ERRS;
PARS_NUM=2; HLP_PARS='p'; HelpNam[$PARS_NUM]="parsing";       HelpOpt[$PARS_NUM]=$HLP_PARS;
OPTS_NUM=3; HLP_OPTS='o'; HelpNam[$OPTS_NUM]="options";       HelpOpt[$OPTS_NUM]=$HLP_OPTS; # sam as HLP_PARS
TYPE_NUM=4; HLP_TYPE='t'; HelpNam[$TYPE_NUM]="typedata";      HelpOpt[$TYPE_NUM]=$HLP_TYPE;
HELP_END=5; # keep as one past last ..._NUM

HelpStr[$DBUG_NUM]="option used for debug numbers help";
HelpStr[$ERRS_NUM]="option used for error strings help";
HelpStr[$PARS_NUM]="option used for parsed symbol help";
HelpStr[$OPTS_NUM]="option used for delimiter opt help";
HelpStr[$TYPE_NUM]="option used for the data type help";

function  InitHlp() { # initializes HLPALLS & HLP_VALS
    local ic; HLP_ALLS='';  HLP_VALS='';
    for ((ic=HELP_BGN; ic < HELP_END; ic++));
    do  if   ((ic == 0)); # assemble all hlp opts
        then HLP_ALLS+="${HelpOpt[$ic]}";  HLP_VALS+="${HelpOpt[$ic]}=${HelpNam[$ic]}";
        else HLP_ALLS+="|${HelpOpt[$ic]}"; HLP_VALS+=", ${HelpOpt[$ic]}=${HelpNam[$ic]}";
        fi
    done
}

#############################################################################
# Set Configuration Enums (see by: getparms [i.e. called from: Get Help]).
# All config entries (Cfg Set) are initialized by Init Cfg to 0, so they can
# be indirectly used: bool=${CfgSet[$CF_CAPALL]};    # 0|1
# & directly used as: if ((CfgSet[CF_INDEQL] == 1)); # w/o any runtime error
# if [[ "${CfgSet[$CF_INDEQL]}" == "1" ]]; then      # safer if undefined
# NB: in CF_ALLS, 'p' is not available, as it is used for the copying funtion
#############################################################################
CF_ALLS='abcehlnqrsuwxdiomy'; # auto-assembled in InitCfg [9 left: 'fgjkptvz']
CF_TYPE='-c';  # signifies a configuration option; used options: $CF_ALLS
CF_COPY='-cp'; # signifies a copy request option (difft than all config opts)
CF_RSLT='-r';  # option to retrieve the last result from rslt file & echo
declare -a     CfgSet; # array of config flags: CF_... : 0|1 (run-time variable)
declare -a     CfgStr;              declare -a CfgDbg;    declare -a CfgOpt; # config options: -c?
               # configs affecting the display  # remember to add new enum to Set Cfg

((i=0)); CF_BEGINS=$i; CfgStr[$i]="CF_BEGINS"; CfgDbg[$i]=0; CfgOpt[$i]="";  # -c  [print all cfg.]
((i++)); CF_ANALYZ=$i; CfgStr[$i]="CF_ANALYZ"; CfgDbg[$i]=1; CfgOpt[$i]="a"; # -ca [debug function]
((i++)); CF_BGNSPC=$i; CfgStr[$i]="CF_BGNSPC"; CfgDbg[$i]=1; CfgOpt[$i]="b"; # -cb [debug function]
((i++)); CF_CAPALL=$i; CfgStr[$i]="CF_CAPALL"; CfgDbg[$i]=0; CfgOpt[$i]="c"; # -cc [disp. function]
((i++)); CF_ECHONO=$i; CfgStr[$i]="CF_ECHONO"; CfgDbg[$i]=0; CfgOpt[$i]="e"; # -ce [skip all echos]
((i++)); CF_HELPNO=$i; CfgStr[$i]="CF_HELPNO"; CfgDbg[$i]=0; CfgOpt[$i]="h"; # -ch [verbose config]
((i++)); CF_LDUSNO=$i; CfgStr[$i]="CF_LDUSNO"; CfgDbg[$i]=0; CfgOpt[$i]="l"; # -cl [disp. function]
((i++)); CF_NO_ERR=$i; CfgStr[$i]="CF_NO_ERR"; CfgDbg[$i]=0; CfgOpt[$i]="n"; # -cn [verbose config]
((i++)); CF_NO_OUT=$i; CfgStr[$i]="CF_NO_OUT"; CfgDbg[$i]=0; CfgOpt[$i]="q"; # -cq [-cc over-rides]
((i++)); CF_ROWNUM=$i; CfgStr[$i]="CF_ROWNUM"; CfgDbg[$i]=0; CfgOpt[$i]="r"; # -cr [verbose config]
((i++)); CF_STATUS=$i; CfgStr[$i]="CF_STATUS"; CfgDbg[$i]=0; CfgOpt[$i]="s"; # -cs [verbose config]
((i++)); CF_USRMSG=$i; CfgStr[$i]="CF_USRMSG"; CfgDbg[$i]=0; CfgOpt[$i]="u"; # -cu [a user message]
((i++)); CF_NOWRAP=$i; CfgStr[$i]="CF_NOWRAP"; CfgDbg[$i]=1; CfgOpt[$i]="w"; # -cw [no wrap output]
         # notes & divider line between specification & command-line configs # ---
((i++)); CF_PARSE1=$i; CfgStr[$i]="CF_PARSE1"; CfgDbg[$i]=1; CfgOpt[$i]="";  # --- [internal note]
((i++)); CF_PARSE2=$i; CfgStr[$i]="CF_PARSE2"; CfgDbg[$i]=1; CfgOpt[$i]="";  # --- [detail note]
((i++)); CF_PARSED=$i; CfgStr[$i]="CF_PARSED"; CfgDbg[$i]=0; CfgOpt[$i]="";  # --- [divide enum]
         # configs affecting command-line parsing [used as limit] next enum  # ---
((i++)); CF_DUPOPT=$i; CfgStr[$i]="CF_DUPOPT"; CfgDbg[$i]=0; CfgOpt[$i]="d"; # -cd
((i++)); CF_INDEQL=$i; CfgStr[$i]="CF_INDEQL"; CfgDbg[$i]=0; CfgOpt[$i]="i"; # -ci
((i++)); CF_MULTOP=$i; CfgStr[$i]="CF_MULTOP"; CfgDbg[$i]=0; CfgOpt[$i]="o"; # -co
((i++)); CF_MULT2O=$i; CfgStr[$i]="CF_MULT2O"; CfgDbg[$i]=0; CfgOpt[$i]="m"; # -cm
((i++)); CF_RGXLOC=$i; CfgStr[$i]="CF_RGXLOC"; CfgDbg[$i]=0; CfgOpt[$i]="x"; # -cx [no '~' locates]
((i++)); CF_RESULT=$i; CfgStr[$i]="CF_RESULT"; CfgDbg[$i]=1; CfgOpt[$i]="y"; # -cy
((i++)); CF_MAXOPT=$i; # keep 1 past last configuration

# we also need the combined options (display) w/ shortcut names for menus
i=$CF_BEGINS; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; BEGINS=${CfgOptn[$i]}; # -c
i=$CF_ANALYZ; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; ANALYZ=${CfgOptn[$i]}; # -ca
i=$CF_BGNSPC; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; BGNSPC=${CfgOptn[$i]}; # -cb
i=$CF_CAPALL; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; CAPALL=${CfgOptn[$i]}; # -cc
i=$CF_ECHONO; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; ECHONO=${CfgOptn[$i]}; # -ce
i=$CF_HELPNO; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; HELPNO=${CfgOptn[$i]}; # -ch
i=$CF_LDUSNO; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; LDUSNO=${CfgOptn[$i]}; # -cl
i=$CF_NO_ERR; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; NO_ERR=${CfgOptn[$i]}; # -cn
i=$CF_NO_OUT; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; NO_OUT=${CfgOptn[$i]}; # -cq
i=$CF_ROWNUM; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; ROWNUM=${CfgOptn[$i]}; # -cr
i=$CF_STATUS; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; STATUS=${CfgOptn[$i]}; # -cs
i=$CF_USRMSG; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; USRMSG=${CfgOptn[$i]}; # -cu
i=$CF_NOWRAP; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; NOWRAP=${CfgOptn[$i]}; # -cw

i=$CF_DUPOPT; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; DUPOPT=${CfgOptn[$i]}; # -cd
i=$CF_INDEQL; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; INDEQL=${CfgOptn[$i]}; # -ci
i=$CF_MULTOP; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; MULTOP=${CfgOptn[$i]}; # -co
i=$CF_MULT2O; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; MULT2O=${CfgOptn[$i]}; # -cm
i=$CF_RGXLOC; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; RGXLOC=${CfgOptn[$i]}; # -cx
i=$CF_RESULT; CfgOptn[$i]=$CF_TYPE${CfgOpt[$i]}; RESULT=${CfgOptn[$i]}; # -cy

declare -a CfgMsg;
CfgMsg[$CF_BEGINS]="Following are the configs that affect the display of outputs";       # opt (values other than 0|1)
CfgMsg[$CF_ANALYZ]="Analyze only mode: only check specification not command-line items"; # -ca
CfgMsg[$CF_BGNSPC]="Beginning processing result to be shown for all specification rows"; # -cb
CfgMsg[$CF_CAPALL]="Capture statuses of command-line items even if item is not changed"; # -cc
CfgMsg[$CF_ECHONO]="Suppress all extra empty lines added just for beautifying displays"; # -ce
CfgMsg[$CF_HELPNO]="Help message is suppressed on getting a help option or if no input"; # -ch
CfgMsg[$CF_LDUSNO]="Leading underscores from any dashed item's output name are removed"; # -cl
CfgMsg[$CF_NO_ERR]="No error messages will be outputted [i.e. operate in a quiet mode]"; # -cn
# don't change 'fnam' here to 'func' or it will cause 'getparmstest.sh -th0' tests to fail!
CfgMsg[$CF_NO_OUT]="Suppress output messages except for result (fnam=0) [a quiet mode]"; # -cq [overridden by -cc]
CfgMsg[$CF_ROWNUM]="Row numbers (0-based) are to be prefixed to each row that's output"; # -cr
CfgMsg[$CF_STATUS]="Status of displayed command-line items to be prefixed for each row"; # -cs
CfgMsg[$CF_USRMSG]="User message text is added to output: $USRMSG{=| }'user supplied text'"; # -cu
CfgMsg[$CF_NOWRAP]="Disable auto-Wrapping of long lines (e.g.: SpecLine or HELP lines)"; # -cw

         # notes and divider line between specification and command-line configs
CfgMsg[$CF_PARSE1]="[NB: $CAPALL & $NO_OUT are at odds, if both are set $CAPALL will override $NO_OUT]"; # divider
CfgMsg[$CF_PARSE2]="[NB: if $NO_ERR enabled then the result will be saved in a file ($RESULT)]"; # divider
CfgMsg[$CF_PARSED]="Following are the configs affecting the command-line parsing";       # divider
         # configs affecting command-line parsing [used as a limit] = next enum val
CfgMsg[$CF_DUPOPT]="Disable errors on duplicates of same: opt, ind parm, SHIP received"; # -cd
CfgMsg[$CF_INDEQL]="Disable old style Ind Parm assignments, warn if -i=val in cmd-line"; # -ci
CfgMsg[$CF_MULTOP]="Disable combining of multiple One [1] letter pure options into one"; # -co (2 if auto-disabled)
CfgMsg[$CF_MULT2O]="Disable combining of Multiple two [2] letter pure options into one"; # -cm (2 if auto-disabled)
CfgMsg[$CF_RGXLOC]="Disable the use of location symbols for regex matching|extractions"; # -cx [no '~' locates]
CfgMsg[$CF_RESULT]="Save result of running getparms into file for later retrieval (-r)"; # -cy
CfgMsg[$CF_MAXOPT]=""; # EndNote

function  InitCfg() { # init CF_ALLS & CfgSet array to disabled (0)
    CF_ALLS=''; local ic; for ((ic=CF_BEGINS; ic<CF_MAXOPT; ic++));
    do CfgSet[$ic]=0; CF_ALLS+=${CfgOpt[$ic]}; done; # assemble all cfg. opts
}

#############################################################################
# Print AllCfgs : called from: Get Help
# Note: debug printing will print notes with "NB: " in them
# in addition to some configs which are more of a debug nature
#############################################################################
function  PrintAllCfgs() { # PrintAllCfgs # print all CfgOpt # called by Set Cfg (no opt) or by Get Help
    local ic; printf " ----- %s -----\n" "${CfgMsg[$CF_BEGINS]}"; # 7 chars lines up after ':'
    for ((ic=CF_BEGINS+1; ic <= CF_MAXOPT; ic++)); do local opt;
        local msg="${CfgMsg[$ic]}";
        local dbg=${CfgDbg[$ic]};   # if 1 only show if detailed output
        case "$ic" in
        $CF_PARSE1|$CF_PARSE2) # print divider note
              if [[ "$msg" ]] && ( ((DbgPrt == 1)) || ((dbg == 0)) );
              then printf "       %s\n" "$msg";  fi;;
        $CF_PARSED) # print parsed separator line
              if [[ "$msg" ]]; then
              printf " ----- %s -----\n" "$msg"; fi;;
        $CF_MAXOPT) # print final notes lines
              if [[ "$msg" ]]; then
              printf "       %s\n" "$msg"; fi;; #     : ...
        *)    if [[ "$msg" ]] && ( ((DbgPrt == 1)) || ((dbg == 0)) );
              # print only if non-debug unless doing the debug printing
              then opt="${CfgOpt[$ic]}"; # only print non-empty strings
              printf " ${CF_TYPE}%-2s: %s\n" "$opt" "$msg"; fi;; # -ci : ...
        esac;
    done; if  ((CfgSet[CF_ECHONO] == 0)); then echo; fi
} # end Print AllCfgs

#############################################################################
# Set Cfg : sets appropriate config option
# Print Cfg Set : prints the config options that are set
# Note: Set Cfg & Print CfgSet must be put after error strings are defined
#############################################################################
function  SetCfg()  { # SetCfg {opt {indx}} # no opt calls PrintAllCfgs
    local sts=$SUCCESS; local opt="$1"; local ic=$2; # NB: both may be ""
    local n=0; local len=${#opt};                    # caller stripped off -c
    DBG_TRC  3 "$ic" "SetCfg: ic:$ic, opt:$opt";     # assemble all cfg. opts: 1st DF_ALLS no '|'
    while ((n < len)); do local ltr="${opt:$n:1}";   # process letter by letter
        case "$ltr" in # setcfg not called unless found "-c*" or to print all
            # Note: we don't include the header rows: CF_BEGINS & CF_PARSEn
            # following are all configs affecting display
            ${CfgOpt[$CF_ANALYZ]})  CfgSet[$CF_ANALYZ]=1;;  # -ca => a
            ${CfgOpt[$CF_BGNSPC]})  CfgSet[$CF_BGNSPC]=1;;  # -cb => b
            ${CfgOpt[$CF_CAPALL]})  CfgSet[$CF_CAPALL]=1;;  # -cc => c
            ${CfgOpt[$CF_ECHONO]})  CfgSet[$CF_ECHONO]=1;;  # -ce => e
            ${CfgOpt[$CF_HELPNO]})  CfgSet[$CF_HELPNO]=1;;  # -ch => h
            ${CfgOpt[$CF_LDUSNO]})  CfgSet[$CF_LDUSNO]=1;;  # -cl => l
            ${CfgOpt[$CF_NO_ERR]})  CfgSet[$CF_NO_ERR]=1;;  # -cn => n
            ${CfgOpt[$CF_NO_OUT]})  CfgSet[$CF_NO_OUT]=1;;  # -cq => q
            ${CfgOpt[$CF_ROWNUM]})  CfgSet[$CF_ROWNUM]=1;;  # -cr => r
            ${CfgOpt[$CF_STATUS]})  CfgSet[$CF_STATUS]=1;;  # -cs => s
            ${CfgOpt[$CF_USRMSG]})  CfgSet[$CF_USRMSG]=1;;  # -cu => u
            ${CfgOpt[$CF_NOWRAP]})  CfgSet[$CF_NOWRAP]=1;;  # -cw => w
            # following are all configs parsing cmd-line
            ${CfgOpt[$CF_DUPOPT]})  CfgSet[$CF_DUPOPT]=1;;  # -cd => d
            ${CfgOpt[$CF_INDEQL]})  CfgSet[$CF_INDEQL]=1;;  # -ci => i
            ${CfgOpt[$CF_MULT2O]})  CfgSet[$CF_MULT2O]=1;;  # -co => o
            ${CfgOpt[$CF_MULTOP]})  CfgSet[$CF_MULTOP]=1;;  # -cm => m
            ${CfgOpt[$CF_RGXLOC]})  CfgSet[$CF_RGXLOC]=1;;  # -cx => x
            ${CfgOpt[$CF_RESULT]})  CfgSet[$CF_RESULT]=1;;  # -cy => y
            # Note: next 2 rows would call PrintAllCfgs, but now done in
            # getparms help is called because of FAILURE return status
            ${CfgOpt[$CF_BEGINS]}|$CF_TYPE) sts=$FAILURE;; # ""|-c : show help & quit
            *)  PrintErr $ic "$CFUN" "$ic" "opt=$CF_TYPE$opt [found in SetCfg]" >&2;
                n=$len; sts=$FAILURE; break;; # quit after first error
        esac;
    ((n++)); done; DBG_TRC -x 3 "$ic" "SetCfg: ic:$ic"; return $sts;
} # end Set Cfg

function  PrintCfgSet() { # print set CfgSet # called by Print Spec to print enabled prefs
    if  ((DbgPrt == 0)); then return; fi
    printf "Configure:\n"; PrintChgOpt;
    printf "DlmtrReqd: '%s' [%s] are ''%s reqd: %s\n" "$OC_ALLS" "$OC_NAME" "$OC_SYMS" "$OC_REQD";
    if  ((PgmSymChg == 1)); then printf "PgmSymbol: %s  Associated Symbol: '%s'\n" "$DF_NAME" "$DF_NOSP"; fi
    local ic; local name; local desc; local optn; local xtra;
    for ((ic=CF_BEGINS+1; ic<CF_MAXOPT; ic++)); do if ((CfgSet[ic] != 0)); then
        name="${CfgStr[$ic]}"; desc="${CfgMsg[$ic]}"; optn="$CF_TYPE${CfgOpt[$ic]}";
        xtra=""; if ((CfgSet[ic] == 2)); then  xtra="(auto-disabled)"; fi
        printf "%s: %s [%s] %s\n" "$name" "$desc" "$optn" "$xtra";
    fi; done;
} # end Print CfgSet

#############################################################################
# Set Rslt checks if the result needs to be saved to a file for later
# retrieval (-r). Saving can be specifically enabled via config (-cy)
# or auto-enabled by a config that requires it (like -cn [no errors])
# or by any call to get help during a regular run (that is not -h*).
# Set Rslt determines if the saved result file needs to be deleted.
#############################################################################
function  SetRslt() { # SetRslt sts
    local set=$FAILURE; local sts=$1; shift;
    if  ((SRCD == 0)) && [[ ! "$RtnRslt" ]]; then              # if not getting the result now
        local file=$RSLT; if [[ "$FNAME" ]]; then file="$RSLT.$FNAME"; fi
        if   ((CfgSet[CF_RESULT] == 1)); then set=$SUCCESS;    # if am configured to save result
        elif ((CfgSet[CF_NO_ERR] == 1)); then set=$SUCCESS;    # if not showing any errors, save
        elif ((GotHelp == 1));           then set=$SUCCESS;    # if we had to get any help, save
        fi;  if ((set == SUCCESS)); then if [[ "$file" ]];     # save the result in result file
             then echo "$FNAME=$sts" >"$file"; else echo "$sts" >"$file"; fi
       #elif [ -f $RSLT ]; then rm -f $RSLT; fi                # if not getting result, rm file
        fi
    fi; return $set;
} # end Set Rslt

#############################################################################
# Get Rslt checks if the result needs to be reported based on a global flag
# Rtn Rslt (set by -r). Get Rslt only returns success if the result was
# previously saved (via -cy or by a config that requires it (-cn [no errors])
# or by any call to get help during a regular run (that is not -h*)).
# Note: Set Rslt is called after GetRslt at the end of getparms
#############################################################################
function  GetRslt() { # GetRslt # command to get result (-r)
    local get=$FAILURE;
    if  ((SRCD == 0)) && [[ "$RtnRslt" ]] && [[ "$RtnRslt" != *" "* ]]; then
        local file="$RSLT"; if [[ "$RtnRslt" != _ ]]; then file="$RSLT.$RtnRslt"; fi
        if  [ -f "$file" ]; then  local sts=$(cat "$file"); get=${sts/*=/}; # get just num
            if   ((DbgPrt == 1)); then ErrStr -r -v "$sts"; sts="$TMP"; fi
            echo "$sts"; # should be: func=n | n (latter if no func in HELP
        fi  # else echo nothing, but we still need caller to return
    fi; return $get;
} # end Get Rslt

#############################################################################
# Special Parsing Characters:
# Rsvd: -_a-zA-Z0-9 => these are reserved for variable names|options [64]
# Band: `!$*\/'" ;  => these are banned for bash expansion | parsing [11]
# Used:  []{}<>()   => these are reserved for bash grouping of items [8]
# Free: =^&/        => these are free to swap with below swappables  [4]
# Swap: ?|:-...#,~@ => these are getparms parsing usage (swappables) [11]
#       [e.g. set all parsing symbols: -pg|%a:%r-%m...%e#%n,%t~%v@]
#
# Notes on 'Band' (i.e 'Banned') characters:
#       ` and ! could cause bash execution so they are banned
#       $ could resolve to a variable's value so it is banned
#       * could expand to a list of files so it's thus banned
#       \ (backslash) is the escape character so it is banned
#       space messes up our parsing optimizing so it's banned
#       quotes ('") can 'disappear', so we can't rely on them
#       semicolon (;) terminates the line so it's also banned
#       % to allow swapping we need a reserved character that
#       is a separator that can't be 1 of the Swap|Free chars
#
# when changing parsing characters any unspecified items remain defaulted
# alt.names only with pure & SHIP opts, datatypes only with pos. & ind. parms
# e.g.: -i:altname OR -i=:data OR {-i=indparm~s-} OR [parm~i]
#############################################################################
SPACGRP=' ';            # [1]  'w' in ~ss type strings WhiteSpace
UNDRSCR='_';            # [1]  'u' in ~su type strings Underscore
CAPSGRP='A-Z';          # [26] '+' in ~s+ type strings (UCAS is for full A-Z)
LOWRGRP='a-z';          # [26] '-' in ~s- type strings (LCAS is for full a-z)
NUMSGRP='0-9';          # [10] 'n' in ~sn type strings (NMBR is for full 0-9)
DLMTGRP='[]()<>{}';     # [10] 'd' in ~sd type strings (printing & searching)
MATHGRP="*/~=|&^%";     # [8]  'l' in ~sl type strings Logic (printing & searching)
PUNCGRP="\!?:;,.";      # [6]  'g' in ~sg type strings (must escape: bang)
PUNCDSP="!?:;,.";       # [6]  'g' in ~sg type strings (good for printing & searching)
SYMSGRP="@#$\\";        # [4]  'y' in ~sy type strings (good for printing & searching)
QUOTGRP="\"'";          # [2]  'q' in -sq type strings (must escape: double quotemark)
# Note: only character that we have chosen not to support: backtick (`)
# Note: several of the above symbols are also specified individually

# Following are the versions required for use with regular expression pattern matching
# NB: order & position of square brackets: they must be 1st in regex pattern & ] b4 [
# NB: minus|hyphen ('-') must be last in searches & must be put at end of expressions
SPACPAT="\ ";           # SPACGRP to be used with regular expressions;
DLMTPAT="][()\<\>{}";   # DLMTGRP to be used with regular expressions; NB: ][ must be 1st
MATHPAT="\+*/~=|\&^%-"; # MATHGRP to be used with regular expressions; NB: - must be last char
PUNCPAT="\!\?\:\;\,\."; # PUNCGRP to be used with regular expressions; NB: all must be esc.
QUOTPAT="\"\'";         # QUOTGRP to be used with regular expressions; NB: all must be esc.
SYMSPAT="@#$\\";        # SYMSGRP to be used with regular expressions;

# Following are characters that we need to handle specially
NOESCAP=" \` \! \? \" \' "; # chars we don't want to unescape
NOESCBQ=" \` \! \? ";       # chars we don't want to unescape but quotes

################# Variables used to show the Symbol usage ###############################
ALL_SYM=",._-+~=\`'\":;?!@#$%^&*\\|/[]()<>{}";
DF_NAME='';     # InitSyms auto-assembled: 'EOBP GRUP ALTN MORE ECMT RANG TYPE PLAN REGX'
DF_EXPL='';     # 'BgnParm Groups AltName More EndCmnt Range Typedata Plain regeX'
DF_ALLS='';     # auto-assembled in InitSyms: "b|g|a|m|e|r|t|p|x" [bgamertpx]
DF_SYMS='';     # auto-assembled in InitSyms: "-+ | + : ... # - ~ % @ "
DF_NOSP='';     # auto-assembled in InitSyms: "-+|+:...#-~%@"
CF_PARS='-p';   # parsing config to change parsing symbol
################# Next we have the Non-Configurable Symbols #############################
SYMB_WELC='-w'; # NB: this is the option to force the display of the welcome info banner
SYMB_SAMP='-s'; # NB: this is the option signalling to display getparmstest sample files
SYMB_UTIL='-x'; # NB: this is the option signalling to call an internal utility function
SYMB_SPEC='-~'; # NB: this is the option signalling the Specification (i.e. HELP) string
SYMB_HELP='-?'; # NB: this is the option signalling setting of the HELP option (-h|--help)
SYMB_CNFG='-';  # this separates config values & need not be distinct from SYMB_ values
                # NB: this item is not configurable so it doesn't need a separate default
SYMB_INDP='=';  # NB: this is the separator for old-style indirect parms (e.g.: -i=index);
                # it is a well-known standard and as such cannot be configured, but at the
                # same time '=' can be used for other purposes also, so it is in SYM FREE;
                # it also specifies a short-hand indirect parm (e.g.: -i=) in the spec.
SYMB_EOOM='--'; # the end of options marker (after which only positional parms are allowed)
################# Next we have all the Configurable Symbols #############################
# now we have to keep a copy of the standard default value (SYMB_...) vs. configured (SymCfg)
# Note: the location symbol (LOCS) is forced to be the same as the datatype symbol (TYPE)
# since location symbols are only used with datatypes, so this saves us the use of a symbol
#########################################################################################
DFLT_EOBP='-+'; SYMB_EOBP="$DFLT_EOBP"; # end of bgn parms marker, after which options allowed
DFLT_GRUP='|';  SYMB_GRUP="$DFLT_GRUP"; # pipe is used to group mode options, e.g.: -i|n|--out
DFLT_ALTN=':';  SYMB_ALTN="$DFLT_ALTN"; # signifies what follows is an option's alternate name
DFLT_MORE=...;  SYMB_MORE="$DFLT_MORE"; # ellipsis signifies there are unspecified more parms.
DFLT_ECMT='#';  SYMB_ECMT="$DFLT_ECMT"; # end comment marker: everything after ' # ' is comment
DFLT_RANG='-';  SYMB_RANG="$DFLT_RANG"; # separator to divide the high and low range of values
DFLT_TYPE='~';  SYMB_TYPE="$DFLT_TYPE"; # signifies what data type this string must conform to
DFLT_LOCS='~';  SYMB_LOCS="$DFLT_LOCS"; # where to match: .~ (@ bgn), ~.~ (@ mid), ~. (@ end)
DFLT_PLAN='@';  SYMB_PLAN="$DFLT_PLAN"; # separator for plain datatypes and range|enums|values
DFLT_REGX='%';  SYMB_REGX="$DFLT_REGX"; # separator for regex datatypes and range|enums|values
SYMB_GETX="$SYMB_PLAN$SYMB_PLAN";       # plain extract symbols: using double plain separators
SYMB_GETP="$SYMB_REGX$SYMB_REGX";       # regex extract symbols: using double regex separators
SYMB_NEGX="$SYMB_GETX$SYMB_PLAN";       # plain extract symbols: using triple plain separators
SYMB_NEGP="$SYMB_GETP$SYMB_REGX";       # regex extract symbols: using triple regex separators

# the following are used effectively only for printing the configured values
declare -a   SymStr;       declare -a   SymCfg;             declare -a   SymOpt; # array of symbols
SYM_STRT=0;  SymStr[$SYM_STRT]="";      SymCfg[$SYM_STRT]="";            SymOpt[$SYM_STRT]="";
SYM_EOBP=1;  SymStr[$SYM_EOBP]="EOBP";  SymCfg[$SYM_EOBP]="$SYMB_EOBP";  SymOpt[$SYM_EOBP]="b"; # '-+'
SYM_GRUP=2;  SymStr[$SYM_GRUP]="GRUP";  SymCfg[$SYM_GRUP]="$SYMB_GRUP";  SymOpt[$SYM_GRUP]="g"; # '|'
SYM_ALTN=3;  SymStr[$SYM_ALTN]="ALTN";  SymCfg[$SYM_ALTN]="$SYMB_ALTN";  SymOpt[$SYM_ALTN]="a"; # ':'
SYM_MORE=4;  SymStr[$SYM_MORE]="MORE";  SymCfg[$SYM_MORE]="$SYMB_MORE";  SymOpt[$SYM_MORE]="m"; # ...
SYM_ECMT=5;  SymStr[$SYM_ECMT]="ECMT";  SymCfg[$SYM_ECMT]="$SYMB_ECMT";  SymOpt[$SYM_ECMT]="e"; # '#'
SYM_RANG=6;  SymStr[$SYM_RANG]="RANG";  SymCfg[$SYM_RANG]="$SYMB_RANG";  SymOpt[$SYM_RANG]="r"; # '-'
SYM_TYPE=7;  SymStr[$SYM_TYPE]="TYPE";  SymCfg[$SYM_TYPE]="$SYMB_TYPE";  SymOpt[$SYM_TYPE]="t"; # '~'
SYM_PLAN=8;  SymStr[$SYM_PLAN]="PLAN";  SymCfg[$SYM_PLAN]="$SYMB_PLAN";  SymOpt[$SYM_PLAN]="p"; # '@'
SYM_REGX=9;  SymStr[$SYM_REGX]="REGX";  SymCfg[$SYM_REGX]="$SYMB_REGX";  SymOpt[$SYM_REGX]="x"; # '%'
SYM_LAST=10; SYM_BGN=$((SYM_STRT+1));   NUM_SYM=$((SYM_LAST-1)); # used: adegmnprstx; unused: "bcfhijkloquvwyz"

declare -a SymExp; declare -a SymMsg;
SymExp[$SYM_EOBP]="BgnParm";  SymMsg[$SYM_EOBP]="double plus signals the end of beginning parameters "; # b'-+'
SymExp[$SYM_GRUP]="Groups";   SymMsg[$SYM_GRUP]="pipe is used to group mode options, e.g.: -i|n|--out"; # g'|'
SymExp[$SYM_ALTN]="AltName";  SymMsg[$SYM_ALTN]="signifies what follows is an option's alternate name"; # a':'
SymExp[$SYM_MORE]="More";     SymMsg[$SYM_MORE]="separator signifies there are unspecified more parms"; # m'...'
SymExp[$SYM_ECMT]="EndCmnt";  SymMsg[$SYM_ECMT]="end comment marker: everything after it is a comment"; # e'#'
SymExp[$SYM_RANG]="Range";    SymMsg[$SYM_RANG]="separator to divide the high and low range of values"; # r'-'
SymExp[$SYM_TYPE]="Typedata"; SymMsg[$SYM_TYPE]="signifies what data type this string must conform to"; # t'~'
SymExp[$SYM_PLAN]="Plain";    SymMsg[$SYM_PLAN]="separator for plain datatypes and range|enums|values"; # p'@'
SymExp[$SYM_REGX]="regeX";    SymMsg[$SYM_REGX]="separator for regex datatypes and range|enums|values"; # x'%'
# list of all defaulted and forbidden symbols
SYM_BOTH="\
${SymOpt[$SYM_EOBP]}$SYMB_EOBP$SYMB_CNFG\
${SymOpt[$SYM_GRUP]}$SYMB_GRUP$SYMB_CNFG\
${SymOpt[$SYM_ALTN]}$SYMB_ALTN$SYMB_CNFG\
${SymOpt[$SYM_MORE]}$SYMB_MORE$SYMB_CNFG\
${SymOpt[$SYM_ECMT]}$SYMB_ECMT$SYMB_CNFG\
${SymOpt[$SYM_RANG]}$SYMB_RANG$SYMB_CNFG\
${SymOpt[$SYM_TYPE]}$SYMB_TYPE$SYMB_CNFG\
${SymOpt[$SYM_PLAN]}$SYMB_PLAN$SYMB_CNFG\
${SymOpt[$SYM_REGX]}$SYMB_REGX";

# Can't use '=' (its reserved for old-style indirect params: -i=indparm)
SYM_FREE="^,&";  # & used by 'NIX to put process in bkgnd so must escape
SYM_BAND="\` ! $ * = \\ / ' \"   ; [ ] { } < > ( ) "; # includes a space
# rm all intervening spaces, but include 1 before ';' so it can be seen
SYM_BAND_NOSP="${SYM_BAND// /}"; SYM_BAND_NOSP="${SYM_BAND_NOSP/;/ ;}";
SYM_DLMT="${SYM_BAND_NOSP#*";"}";      # get after ';' i.e.: "[]{}<>()"
SYM_EXPN="${SYM_BAND_NOSP/"$SYM_DLMT"/}";    # all but DLMT:  `!$*\/'";
DATA_TEXT="* Allow the types value|range|enum"; # used in: DataTextSpcl
DATA_TXT2="+ Allow the types values and enums"; # used in: DataTxt2Spcl
NMBR="9876543210"; # put 0 last, not first, to avoid any octal problems
ALPHANUM="-_$LCAS$UCAS$NMBR"; # full listing needed to get number chars

#############################################################################
# Special Parsing Characters for SHIP items
#############################################################################
# OR'ed bits of SHIP flags for each SHIP item
SHIPCH='+-.,012'; # the following are used for choosing a subset of the SHIP opts
declare -a           ShipStr; declare -a ShipOpt;    declare -a  ShipPM;  declare -a  ShipMask;
SHIP_ALL=0; ((i=0)); ShipStr[$i]="ALL";  ShipOpt[$i]="$SHIPCH";  ShipPM[$i]=0;  ShipMask[$i]=0;         # ''  =0x000=0
SHIP_PLE=1; ((i++)); ShipStr[$i]="PLE";  ShipOpt[$i]='+';        ShipPM[$i]=1;  ShipMask[$i]=$((1<<0)); # '+' =0x001=1
SHIP_MNE=2; ((i++)); ShipStr[$i]="MNE";  ShipOpt[$i]='-';        ShipPM[$i]=1;  ShipMask[$i]=$((1<<1)); # '-' =0x002=2
SHIP_DOT=3; ((i++)); ShipStr[$i]="DOT";  ShipOpt[$i]='.';        ShipPM[$i]=0;  ShipMask[$i]=$((1<<2)); # '.' =0x004=4
SHIP_COM=4; ((i++)); ShipStr[$i]="COM";  ShipOpt[$i]=',';        ShipPM[$i]=0;  ShipMask[$i]=$((1<<3)); # ',' =0x008=8
SHIP_NON=5; ((i++)); ShipStr[$i]="NON";  ShipOpt[$i]='0';        ShipPM[$i]=0;  ShipMask[$i]=$((1<<4)); # '0' =0x010=16
SHIP_ONE=6; ((i++)); ShipStr[$i]="ONE";  ShipOpt[$i]='1';        ShipPM[$i]=0;  ShipMask[$i]=$((1<<5)); # '1' =0x020=32
SHIP_TWO=7; ((i++)); ShipStr[$i]="TWO";  ShipOpt[$i]='2';        ShipPM[$i]=0;  ShipMask[$i]=$((1<<6)); # '2' =0x040=64
#----------- the following 2 occur when +|- is before ONE|TWO|COM  ----------------------------------
SHIP_PLS=8; ((i++)); ShipStr[$i]="PLS";  ShipOpt[$i]='+';        ShipPM[$i]=1;  ShipMask[$i]=$((1<<7)); # '+'.=0x080=128
SHIP_MNS=9; ((i++)); ShipStr[$i]="MNS";  ShipOpt[$i]='-';        ShipPM[$i]=1;  ShipMask[$i]=$((1<<8)); # '-'.=0x100=256
#-------------------------------------------------------------------------------------------------------
SHIP_LST=10; SHIP_BGN=$((SHIP_ALL+1)); SHIP_END=$((SHIP_LST-2)); # min & max index limits
SHIP_BIT_1_2=$((ShipMask[SHIP_ONE] | ShipMask[SHIP_TWO]));       # 0x20 |0x40 =0x60 = 96
SHIP_BIT_DIG=$((ShipMask[SHIP_COM] | SHIP_BIT_1_2));             # 0x08 |0x60 =0x68 =104
SHIP_BIT_NUM=$((ShipMask[SHIP_DOT] | SHIP_BIT_DIG));             # 0x68 |0x04 =0x6C =108
SHIP_BIT_NUN=$((ShipMask[SHIP_NON] | SHIP_BIT_NUM));             # 0x6C |0x10 =0x7C =124
SHIP_BIT_MPE=$((ShipMask[SHIP_MNE] | ShipMask[SHIP_PLE]));       # 0x01 |0x02 =0x03 =  3
SHIP_BIT_MPS=$((ShipMask[SHIP_MNS] | ShipMask[SHIP_PLS]));       # 0x100|0x080=0x180=384
SHIP_BIT_MPB=$((SHIP_BIT_MPE       | SHIP_BIT_MPS));             # 0x03 |0x180=0x183=387
SHIP_BIT_ALL=$((SHIP_BIT_NUN       | SHIP_BIT_MPB));             # 0x7C |0x183=0x1FF=511

declare -a ShipSt8Str;
SHIP_ST8_OFF=0; ((i=0)); ShipSt8Str[$i]="n/a"; # not configured
SHIP_ST8_BAD=1; ((i++)); ShipSt8Str[$i]="bad"; # was bad format
SHIP_ST8_EMT=2; ((i++)); ShipSt8Str[$i]="emt"; # was bad empty
SHIP_ST8_NON=3; ((i++)); ShipSt8Str[$i]="non"; # was good empty
SHIP_ST8_ONE=4; ((i++)); ShipSt8Str[$i]="one"; # was good num.
SHIP_ST8_ENM=5; ((i++)); ShipSt8Str[$i]="enm"; # was good enum
SHIP_ST8_RNG=6; ((i++)); ShipSt8Str[$i]="rng"; # was good range
################ End of SHIP Options ########################################

#############################################################################
# InitSyms sets up all the related symbol arrays and variables
#############################################################################
function  InitSyms() { # initialize all SYMB_ & SymCfg & builds DF_ALLS, DF_SYMS, DF_NAME, DF_EXPL
    local ic=0; SymCfg[$ic]=""; DF_ALLS=''; DF_SYMS=' '; DF_NAME=""; DF_EXPL="";
    DBG_TRC  2 "$ic" "InitSyms: ic:$ic"; # assemble all cfg. opts: 1st DF_ALLS no '|'
    ((ic++)); SYMB_EOBP="$DFLT_EOBP"; SymCfg[$ic]="$SYMB_EOBP"; DF_ALLS+="${SymOpt[$ic]}";
              DF_SYMS+="${SymCfg[$ic]} "; DF_NAME+="${SymStr[$ic]}"; DF_EXPL+="${SymExp[$ic]}";
    ((ic++)); SYMB_GRUP="$DFLT_GRUP"; SymCfg[$ic]="$SYMB_GRUP"; DF_ALLS+="|${SymOpt[$ic]}";
              DF_SYMS+="${SymCfg[$ic]} "; DF_NAME+="${SymStr[$ic]}"; DF_EXPL+=" ${SymExp[$ic]}";
    ((ic++)); SYMB_ALTN="$DFLT_ALTN"; SymCfg[$ic]="$SYMB_ALTN"; DF_ALLS+="|${SymOpt[$ic]}";
              DF_SYMS+="${SymCfg[$ic]} "; DF_NAME+=" ${SymStr[$ic]}"; DF_EXPL+=" ${SymExp[$ic]}";
    ((ic++)); SYMB_MORE="$DFLT_MORE"; SymCfg[$ic]="$SYMB_MORE"; DF_ALLS+="|${SymOpt[$ic]}";
              DF_SYMS+="${SymCfg[$ic]} "; DF_NAME+=" ${SymStr[$ic]}"; DF_EXPL+=" ${SymExp[$ic]}";
    ((ic++)); SYMB_ECMT="$DFLT_ECMT"; SymCfg[$ic]="$SYMB_ECMT"; DF_ALLS+="|${SymOpt[$ic]}";
              DF_SYMS+="${SymCfg[$ic]} "; DF_NAME+=" ${SymStr[$ic]}"; DF_EXPL+=" ${SymExp[$ic]}";
    ((ic++)); SYMB_RANG="$DFLT_RANG"; SymCfg[$ic]="$SYMB_RANG"; DF_ALLS+="|${SymOpt[$ic]}";
              DF_SYMS+="${SymCfg[$ic]} "; DF_NAME+=" ${SymStr[$ic]}"; DF_EXPL+=" ${SymExp[$ic]}";
    ((ic++)); SYMB_TYPE="$DFLT_TYPE"; SymCfg[$ic]="$SYMB_TYPE"; DF_ALLS+="|${SymOpt[$ic]}";
              DF_SYMS+="${SymCfg[$ic]} "; DF_NAME+=" ${SymStr[$ic]}"; DF_EXPL+=" ${SymExp[$ic]}";
              SYMB_LOCS="$DFLT_LOCS";
    ((ic++)); SYMB_PLAN="$DFLT_PLAN"; SymCfg[$ic]="$SYMB_PLAN"; DF_ALLS+="|${SymOpt[$ic]}";
              SYMB_GETX="$SYMB_PLAN$SYMB_PLAN"; SYMB_NEGX="$SYMB_GETX$SYMB_PLAN";
              DF_SYMS+="${SymCfg[$ic]} "; DF_NAME+=" ${SymStr[$ic]}"; DF_EXPL+=" ${SymExp[$ic]}";
    ((ic++)); SYMB_REGX="$DFLT_REGX"; SymCfg[$ic]="$SYMB_REGX"; DF_ALLS+="|${SymOpt[$ic]}";
              SYMB_GETP="$SYMB_REGX$SYMB_REGX"; SYMB_NEGP="$SYMB_GETP$SYMB_REGX";
              DF_SYMS+="${SymCfg[$ic]} "; DF_NAME+=" ${SymStr[$ic]}"; DF_EXPL+=" ${SymExp[$ic]}";
   #DF_EXPL='BgnParm Groups AltName More EndCmnt Range Typedata Plain regeX';
   #DF_SYMS=" $SYMB_EOBP $SYMB_GRUP $SYMB_ALTN $SYMB_MORE $SYMB_ECMT $SYMB_RANG $SYMB_TYPE $SYMB_PLAN $SYMB_REGX";
    DF_NOSP="${DF_SYMS// /}"; # remove all spaces
    DataTextSpcl="[$DATA_TEXT, ${SYMB_TYPE}...$SYMB_PLAN by m|m${SYMB_RANG}n|m${SYMB_PLAN}n${SYMB_PLAN}o]";
    DataTxt2Spcl="[$DATA_TXT2, ${SYMB_TYPE}...$SYMB_PLAN by m|   |m${SYMB_PLAN}n${SYMB_PLAN}o]";
    DBG_TRC -x 2 "$ic" "InitSyms: ic:$ic";
} # end InitSyms

#############################################################################
# Print symbols routines
# Print Syms is for printing the presently configured set of symbols (used by normal help)
# PrintAllSymbol is for printing detailed information on the set of symbols (-hp | -h -p)
#############################################################################
function  PrintSyms() { # PrintSyms # prints out all symbol preferences
    echo " ${CF_PARS}. : .=$DF_ALLS  [default values in same order: $DF_NOSP ]";
   #echo "       .= $DF_EXPL; change single|several (with seperators: '$SYMB_CNFG'), e.g.: ${CF_PARS}g= | ${CF_PARS}g=${SYMB_CNFG}a?" | Indent -a -i 7 -m 76;
    echo "       .= $DF_EXPL;";  # "BgnParm Groups AltName More EndCmnt Range Typedata Plain regeX";
    echo "       change single|several (with seperators: '-'), e.g.: -pg= | -pg=-a?";
} # used in both PrintAll Symbol & in Get Help

function  PrintAllSymbol() { # PrintAllSymbol # prints all Symbol info
    local msg; local opt; local cfg;
    if  ((CfgSet[CF_ECHONO] == 0)); then echo; fi
    echo " ----- Following are the configs to change the symbols for parsing ------";
    local ic; local str; printf "%s" "$(PrintSyms)";
    for ((ic=SYM_STRT+1; ic < SYM_DONE; ic++)); do
        msg="${SymMsg[$ic]}"; str="${SymStr[$ic]}";
        opt="${SymOpt[$ic]}"; cfg="${SymCfg[$ic]}";
        printf " %-9s : %s  [%s]\n" "$CF_PARS${opt}'$cfg'" "$msg" "$str";
    done; echo;
    printf " ----- Following shows which characters are available for parsing -------\n";
    printf " Rsvd: %-13s [%02d]  these are reserved for variable names|options\n" \
                   "-_a-zA-Z0-9" "${#ALPHANUM}";
    printf " Band: %-13s [%02d]  banned for bash expansion|parsing with spaces\n" \
                   "$SYM_EXPN"   "${#SYM_EXPN}";
    if ((DbgPrt != 0)); then
    printf "    %s[includes a leading space]\n" "$SYM_BAND"; # skip print of $DF_SYMS
    fi
    printf " Used: %-13s [%02d]  these are reserved for bash grouping of items\n" \
                   "$SYM_DLMT"   "${#SYM_DLMT}";
    # NB: don't use ${#SYM_FREE} as the number of symbols since '...' is 1 symbol (not 3)
    printf " Free: %-13s [%02d]  these are free to swap with below swappables \n" \
                   "$SYM_FREE"   "${#SYM_FREE}";
    printf " Swap: %-13s [%02d]  these are getparms parsing usage (swappables)\n" \
                   "$DF_NOSP"    "$NUM_SYM";
    printf "       to set all parsing symbols: %s\n" "$CF_PARS$SYM_BOTH";
    if  ((CfgSet[CF_ECHONO] == 0)); then echo; fi;
} # Note: Set Sym must be put after error strings are defined

#############################################################################
# Debugging Enums and Messages, displayed by: -hd{a|b|c|d} | -h -d{a|b|c|d}
# To see the enums used for debugging: getparms -x dbgenum | getparms -hd -n
# To see the enums used for debugging with the descriptions: getparms -hd
# Previously had -dt to display times (removed), -dm to add a user message to
# output (moved to -cu), & -do to display output samples (now in --examples)
#############################################################################
DBG_OPT='-d';
DBGGRPS='_|a|b|c|d|';  # debug options to enable code blocks
DBGOPTS='_|a|b|c|d|i'; # list of all debug options available (hide 's')
DBG_GRP="$DBG_OPT{$DBGGRPS}"; # -d{_|a|b|c|d}
DBG_ALL="$DBG_OPT{$DBGOPTS}"; # -d{_|a|b|c|d|i}

declare -a DbgOptn; declare -a DbgText; declare -a DbgOffG; declare -a DbgEndG;
# Note: End is set at end of group inits, j=$((i)) is to convert hex to dec value
# Note:  i is index (0-based), j is offset (0x10*n based), & k is group (0-based)
((k=0)); i=0x00; j=$((i)); DbgOptn[$j]=_;  DbgOffG[$k]=$j; DbgText[$j]="Trace Init/Common Funcs. "; # TrcIni - -d_
((k++)); i=0x20; j=$((i)); DbgOptn[$j]=a;  DbgOffG[$k]=$j; DbgText[$j]="Trace Analyzing the Spec."; # TrcAna - -da
((k++)); i=0x40; j=$((i)); DbgOptn[$j]=b;  DbgOffG[$k]=$j; DbgText[$j]="Trace Boxing or Packaging"; # TrcBox - -db
((k++)); i=0x60; j=$((i)); DbgOptn[$j]=c;  DbgOffG[$k]=$j; DbgText[$j]="Trace Command Line parts "; # TrcCmd - -dc
((k++)); i=0x80; j=$((i)); DbgOptn[$j]=d;  DbgOffG[$k]=$j; DbgText[$j]="Trace Delivery of result "; # TrcDel - -dd
                                                                                                    # TrcShr - -ds
((k++)); DBG_GRP_NUM=$k; # 1 past last

# Init. Debug Variables (-d_)
((i=0)); ((k=0)); j=${DbgOffG[$k]};    opt="${DbgOptn[$j]}";                    # 0x00 = 0
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace all of get parms.sh"; # 0x01 = 1
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Init Syms by index "; # 0x02 = 2
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set Cfg opt by indx"; # 0x03 = 3
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set Symbol function"; # 0x04 = 4
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set Item cfg by ndx"; # 0x05 = 5
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set Rcvd with index"; # 0x06 = 6
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set Rcvd with value"; # 0x07 = 7
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Copy Array by index"; # 0x08 = 8
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace FindStr by its data"; # 0x09 = 9
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace is string by string"; # 0x0A = 10
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace is number by number"; # 0x0B = 11
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Has Unesc by symbol"; # 0x0C = 12
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Del Escap by symbol"; # 0x0D = 13
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Get Unesc by symbol"; # 0x0E = 14
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos Get Quotes progress"; # 0x0F = 15
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace function Get EndNdx"; # 0x10 = 16
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos GetEndNdx loop valu"; # 0x11 = 17
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos set end option indx"; # 0x12 = 18
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Get DataStr by indx"; # 0x13 = 19
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Range Num by index "; # 0x14 = 20
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Range Str by datain"; # 0x15 = 21
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Update Ored by indx"; # 0x16 = 22
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace CollapseArgs by ndx"; # 0x17 = 23
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Move Array by index"; # 0x18 = 24 [move by 08]
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Ship Flags by index"; # 0x19 = 25 [move by 18]
((i++)); ((j++)); DbgEndG[$k]=$j;      # 1 past last

# Analysis Debug Variables (-da)
((i=0)); ((k++)); j=${DbgOffG[$k]};    opt="${DbgOptn[$j]}";                    # 0x20 = 32
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace delimiters by items"; # 0x21 = 33
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace item's type by indx"; # 0x22 = 34
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace set dlimiter by ndx"; # 0x23 = 35
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos set dlimiter by ndx"; # 0x24 = 36
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set the base by ndx"; # 0x25 = 37
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace data type with item"; # 0x26 = 38
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Get DataType by ndx"; # 0x27 = 39
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace alt. name from item"; # 0x28 = 40
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Opt Name by an indx"; # 0x29 = 41
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace getitem name by ndx"; # 0x2A = 42
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos getitem name by ndx"; # 0x2B = 43
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Update Ind by index"; # 0x2C = 44
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set Spec prm w/ ndx"; # 0x2D = 45
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set Spec prm w/ nam"; # 0x2E = 46
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos Set Spec prm w/ ndx"; # 0x2F = 47
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set Spec with index"; # 0x30 = 48
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set Spec with name "; # 0x31 = 49
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos items@end spec loop"; # 0x32 = 50
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos advance to next prm"; # 0x33 = 51
((i++)); ((j++)); DbgEndG[$k]=$j;      # 1 past last

# Boxing Debug Variables (-db)
((i=0)); ((k++)); j=${DbgOffG[$k]};    opt="${DbgOptn[$j]}";                    # 0x40 = 64
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace all Init Lists func"; # 0x41 = 65
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace GetIndPrm item num "; # 0x42 = 66
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace SetIndPrm by index "; # 0x43 = 67
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Get Mixed item num "; # 0x44 = 68
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Set Mixed by index "; # 0x45 = 69
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Multiop init index "; # 0x46 = 70
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace GetBgnPrm item num "; # 0x47 = 71
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace PrintSpec by index "; # 0x48 = 72
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace PrintOptNdx by ndx "; # 0x49 = 73
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Spec errors by ndx "; # 0x4A = 74
((i++)); ((j++)); DbgEndG[$k]=$j;      # 1 past last

# Cmd-Line Debug Variables (-dc)
((i=0)); ((k++)); j=${DbgOffG[$k]};    opt="${DbgOptn[$j]}";                    # 0x60 =  96
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Cleanup Cmdl by ndx"; # 0x61 =  97
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace prehandle detect --"; # 0x62 =  98
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace GetPosPrmBgn by prm"; # 0x63 =  99
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace GetPosPrmEnd by prm"; # 0x64 = 100
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Match Data by dtype"; # 0x65 = 101
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Match Data by index"; # 0x66 = 102
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace GetPos SetRxd by pc"; # 0x67 = 103
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Multi-opts. by parm"; # 0x68 = 104
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos Multi-opts. by parm"; # 0x69 = 105
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace multi-op setup loop"; # 0x6A = 106
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace multi-op combo loop"; # 0x6B = 107
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Opt.Options by parm"; # 0x6C = 108
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace INDP receive by src"; # 0x6D = 109
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace opt parms. by index"; # 0x6E = 110
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace SetRxd option by pc"; # 0x6F = 111
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Quotes option by pc"; # 0x70 = 112
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace SetRxd indprm by pc"; # 0x71 = 113
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace end indprm adv loop"; # 0x72 = 114
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace if option not found"; # 0x73 = 115
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos Option was unfound!"; # 0x74 = 116
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Option loop by indx"; # 0x75 = 117
((i++)); ((j++)); DbgEndG[$k]=$j;      # 1 past last

# Delivery Debug Variables (-dd)
((i=0)); ((k++)); j=${DbgOffG[$k]};    opt="${DbgOptn[$j]}";                    # 0x80 = 128
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace HandleUnknown by pc"; # 0x81 = 129
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace cmdline err by indx"; # 0x82 = 130
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace ChkIndParm by index"; # 0x83 = 131
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace PrintErr by an indx"; # 0x84 = 132
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace PrintErrors routine"; # 0x85 = 133
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace PrintCmdLine by ndx"; # 0x86 = 134
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="echos PrintCmdLine by ndx"; # 0x87 = 135
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Disp Items by index"; # 0x88 = 136
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Shift Parm by index"; # 0x89 = 137
((i++)); ((j++)); DbgOptn[$j]=$opt$i;  DbgText[$j]="trace Prm Datatype by ndx"; # 0x8A = 138
((i++)); ((j++)); DbgEndG[$k]=$j;      # 1 past last

function  ChkDbgNum() { # routine to verify no overlaps in groups
    local nxt; local end; local bgn; local errs=0; local opt;
    local ic;  local num=$((DBG_GRP_NUM-1)); # check n with n+1, so last 1 no check
    for ((ic=0; ic < num; ic++));  do  nxt=$((ic+1));
        end=${DbgEndG[$ic]}; bgn=${DbgOffG[$nxt]}; # NB: '=' is still OK
        if  ((end > bgn)); then  ((errs++));
            off=${DbgOffG[$ic]}; opt=${DbgOptn[$off]};
            printf "Warning: %s (end %n) is past start of next group! FIXME!\n" "$opt" "$end" >&2;
        fi
    done; return $errs;
}

#############################################################################
# String Matching Types (corresponding to SRCH_...)
# NB: the default search for non-regx searches is 'ALL', but for regx is 'ANY'
# NB: FIND_ symbols are used only for debug, so don't need to be configurable
# but SRCH_ enums are used for internal tracking of the string searching only
#############################################################################
declare -a  SrchFlg; # str Searching # FIND Debugging
SRCH_ALL=0; SrchFlg[$SRCH_ALL]="all";  FIND_ALL='='; #   ...   : wholestring (non-regx def.): no '~'
SRCH_ANY=1; SrchFlg[$SRCH_ANY]="any";  FIND_ANY='~'; #  +...+  : anywhere in (the regx def.): it has
SRCH_BGN=2; SrchFlg[$SRCH_BGN]="bgn";  FIND_BGN='^'; #   ...+  : bgn strings
SRCH_END=3; SrchFlg[$SRCH_END]="end";  FIND_END='#'; #  +...   : end strings (don't use '$')
SRCH_GRD=4; SrchFlg[$SRCH_GRD]="grd";  FIND_GRD='+'; #  ..+..  : gird | wrap (N/A for debug) - start to end
SRCH_SLC=5; SrchFlg[$SRCH_SLC]="slc";  FIND_SLC='.'; # +..+..+ : slice str.  (N/A for debug) - any where in
SRCH_MAX=6;

declare -a  SrchSym; declare -a SrchStr;
SrchSym[$SRCH_ALL]="$FIND_ALL"; SrchStr[$SRCH_ALL]="strings must match whole";
SrchSym[$SRCH_ANY]="$FIND_ANY"; SrchStr[$SRCH_ANY]="strings can be any where";
SrchSym[$SRCH_BGN]="$FIND_BGN"; SrchStr[$SRCH_BGN]="strings must begin these";
SrchSym[$SRCH_END]="$FIND_END"; SrchStr[$SRCH_END]="strings must end with it";
SrchSym[$SRCH_GRD]="$FIND_GRD"; SrchStr[$SRCH_GRD]="strings girded (bgn-end)";
SrchSym[$SRCH_SLC]="$FIND_SLC"; SrchStr[$SRCH_SLC]="string slice anywhere in";

#############################################################################
# Print Srch prints all the search symbols (SrchSym)
#############################################################################
function  PrintSrch() { # PrintSrch prefix # print search options for debugging
    local str; local chr; local prefix="$@"; # SRCH GRD & GRD not p/o debugging
    local min=$SRCH_ALL;  local max=$SRCH_END; # $SRCH_MAX;
    local cr=""; if  ((CfgSet[CF_ECHONO] == 0)); then cr="$CR"; fi
    printf  "$cr$@Symbols for Debug Matching:\n" "$prefix";
    local ic; for ((ic=min; ic <= max; ic++));  do # only print debug strings
        str="${SrchStr[$ic]}";  chr="${SrchSym[$ic]}";
        printf "%s'%s'  %s\n" "$prefix" "$chr" "$str";
    done; if ((CfgSet[CF_ECHONO] == 0)); then echo; fi
}

#############################################################################
# Printing Debug nums
# Get AllDebug prints all the debug enumerations
# Print AllDebug determines the range of debug enums to print
# Print AllDebug is called from -hd* or -h -d*
#############################################################################
function  GetAllDebug() { # GetAllDebug typ bgn num
    local typ="$1"; local bgn=$2; local num=$3;
    local ic;  local end; local nam; local txt;
    local jc;  local off; local opt;
    if   [[ "$typ" == "sum" ]]; then # print header line
        printf "Major Groups of Tracing Enums  : opt\n";
        printf "%s\n" "------------------------------------";
    elif [[ "$typ" == "num" ]]; then if ((CfgSet[CF_ECHONO] == 0)); then echo; fi; fi
    for ((ic=bgn; ic < num; ic++));  do     # loop over groups
        end=${DbgEndG[$ic]};  off=${DbgOffG[$ic]}; bgn=$off;
        opt=${DbgOptn[$off]}; txt="${DbgText[$bgn]}"; ((bgn++));
        if [[ "$typ" == "sum" ]]; then
             printf "%-4s %s : -d%s\n" "$off" "$txt" "$opt";
        else if [[ "$typ" == "all" ]]; then # print group header line
                 printf "\n%-3s %s (0x%02X) : -d$opt\n" "$off" "$txt" "$off";
                 printf "%s\n" "-------------------------------------------";
             fi; for ((jc=bgn; jc < end; jc++)); # now loop thru all of group
             do  nam=${DbgText[$jc]}; if [[ "$nam" ]]; then
                 if [[ "$typ" == "num" ]]; then printf "%s\n" "$jc";
                 else opt=${DbgOptn[$jc]};
                      printf "%-3s %s (0x%02X) : -d$opt\n" "$jc" "$nam" "$jc";
                 fi
             fi; done
        fi
    done;
    if   [[ "$typ" != "all" ]]; then if ((CfgSet[CF_ECHONO] == 0)); then echo; fi
    else PrintSrch; fi # show srch options if all
} # end GetAll Debug

function  PrintAllDebug() { # -d{_|a|b|c|d}{-t}{-s|-n} # print debug enums: -n|-s num|headings only, -d sets enum range, -t trace, range options: -s=-sum, -n=-num, -d=-all -di=-init, -da=-analyze, -db=-boxing, -dc=-cmd-line, -dd=-delivery
    local HELP="PrintAllDebug {{$DBG_GRP}{-t}{-s|-n} # print debug enums: -n|-s num|headings only, -d sets enum range, -t trace";
    local HLP2="range options: -s=-sum, -n=-num, -d=-all -di=-init, -da=-analyze, -db=-boxing, -dc=-cmd-line, -dd=-delivery";
    local opt;   local rng=""; local typ="all"; # default if no options
    local bgn=0; local num=$DBG_GRP_NUM; local dbgtrc=0; local all=1;
    while [[ "$1" == -* ]]; do opt="$1"; shift;
        case "$opt" in                                 # process options
         -t)            dbgtrc=1;;                     # trace this func
         -s|-hds|-sum*) all=0; typ="sum";;             # do heading only
         -n|-hdn|-num*) all=0; typ="num";;             # do numbers only
        -d_|-hd_|-init) all=0; bgn=0; num=$((bgn+1));; # do the init enum
        -da|-hda|-ana*) all=0; bgn=1; num=$((bgn+1));; # do -a enums only
        -db|-hdb|-box*) all=0; bgn=2; num=$((bgn+1));; # do -b enums only
        -dc|-hdc|-cmd*) all=0; bgn=3; num=$((bgn+1));; # do -c enums only
        -dd|-hdd|-del*) all=0; bgn=4; num=$((bgn+1));; # do -d enums only
        -hd|-d|-all)    ;;                             # do all the enums
        *)   if [[ "$opt" != -h ]]; then echo "Error: bad opt: $opt" >&2; fi
             echo "$HELP" >&2; echo "$HLP2" >&2; return $FAILURE;;
        esac
    done
    if  cdebug on "$dbgtrc"; then local DBG=" typ=$typ, bgn=$bgn, num=$num"; fi
    if  [[ "$typ" == "sum" ]]; then # ignore -d{_|a|b|c|d} if doing summary
        bgn=0; num=$DBG_GRP_NUM; if ((CfgSet[CF_ECHONO] == 0)); then echo; fi
    fi
    if  ((all == 1));
    then GetAllDebug "$typ" $bgn $num | less;
    else GetAllDebug "$typ" $bgn $num ; fi;  cdebug no "$dbgtrc";
} # end PrintAllDebug

#############################################################################
# Debugging functions or operations
# DBG_ENA : sets all configuration itms of Dbg arrays (all off|"" by default)
# DBG_TRC : tests if need to trace|echoe message during run-time
##################### Debug Array ###########################################
declare -a DbgCfg;  # array of debug flag is configure on: 1|""  # configure: -d0xHH|-dNNN|-d{a-d}nn
declare -a DbgTrc;  # array of debug allow trace|but echo: 1|0   # configure: -d. # no trace, only echo
declare -a DbgStr;  # array of debug string to search for: "str" # configure: str
declare -a DbgTyp;  # array of debug search type configed: SRCH_ # configure: :|^|#|=
declare -a DbgEna;  # array of debug tracing been enabled: 1|0   # execution

function  InitDbg() { # init run-time debug array variables
    # loop over all types, then over all enums within a type
    local min=0; local max=$DBG_GRP_NUM;
    local ic; local bgn; local end; local off;
    for ((ic=min; ic < max; ic++)); do
        bgn=${DbgOffG[$ic]}; end=${DbgEndG[$ic]};
        for (( jc=bgn;  jc < end; jc++ ));  do  # init cfg
            DbgCfg[$ic]=0;  DbgTrc[$ic]=0;  DbgEna[$ic]=0;
            DbgStr[$ic]=""; DbgTyp[$ic]=0;  # Type: SRCH ALL=0
        done
    done
}

#############################################################################
# this command is called from the command line to enable a given debug flag;
# it allows setting by group (a,b,c,d) & offset number (1...n) or by absolute
# debug number (n); it also allows setting echo only (.) or to allow tracing
#############################################################################
function  DBG_ENA() { # DBG_ENA -d{.}{_|a|b|c|d}n{<:|^|#|=>str} # . echo only, else trace; n debug no.; match str with ':' any, '^' bgn, '#' end, '=' exact
    local str=""; local src; local sts=$SUCCESS; # cdebug on;
    local typ=0;  local num=$1;  shift;  local trc=1;
    if   [[ "$num" == "-d."* ]]; then num="${num:3}"; trc=0;
    elif [[ "$num" == "-d"*  ]]; then num="${num:2}"; fi
    local off=0; case "$num" in  # get offset based on group
    ${DbgOptn[${DbgOffG[0]}]}*) off=${DbgOffG[0]}; num=${num:1};; # rem _
    ${DbgOptn[${DbgOffG[1]}]}*) off=${DbgOffG[1]}; num=${num:1};; # rem a
    ${DbgOptn[${DbgOffG[2]}]}*) off=${DbgOffG[2]}; num=${num:1};; # rem b
    ${DbgOptn[${DbgOffG[3]}]}*) off=${DbgOffG[3]}; num=${num:1};; # rem c
    ${DbgOptn[${DbgOffG[4]}]}*) off=${DbgOffG[4]}; num=${num:1};; # rem d
    esac; case "$num" in  # per separator: get after & before src => str & num
    *"$FIND_ALL"*)  src="$FIND_ALL";     typ="$SRCH_ALL"; # all: '='
                    str=${num#*"$src"};  num=${num/"$src"$str/};;
    *"$FIND_ANY"*)  src="$FIND_ANY";     typ="$SRCH_ANY"; # any: '~'
                    str=${num#*"$src"};  num=${num/"$src"$str/};;
    *"$FIND_BGN"*)  src="$FIND_BGN";     typ="$SRCH_BGN"; # bgn: '^'
                    str=${num#*"$src"};  num=${num/"$src"$str/};;
    *"$FIND_END"*)  src="$FIND_END";     typ="$SRCH_END"; # end: '#'
                    str=${num#*"$src"};  num=${num/"$src"$str/};;
    esac; # in case we fall thru, extract nums, discarding leading -d{.}{_|a|b|c|d}
    # here is where we catch leftover letter, e.g.: -df5 => f5 (no 0x & not all num)
    if   [[ "$num" =~ $IS_A_HEX ]]; then num=$((num)); # if 0xHH, convert to dec
    else [[ "$num" =~ [0-9]+ ]]; num="${BASH_REMATCH[0]}"; fi # if no num, num="", a56=7 => 56
    if   [[ "$num" ]]; then   # no need to check against any max value
         ((num+=off));        # add a base offset we extracted earlier
         DbgCfg[$num]=1;      # configured flag (allow to be processed)
         DbgTrc[$num]=$trc;   # allow tracing (1) | just doing echo (0)
         DbgStr[$num]="$str"; # match value (what str to match if any)
         DbgTyp[$num]="$typ"; # match types (type of match we're doing)
         DbgEna[$num]=0;      # init run-time flag to not enabled yet
         if ((DbgNum == 0));  # next line will set DBG_TRC to __DBG_TRC
         then Unstub DBG_TRC; fi; ((DbgNum++));
    else sts=$FAILURE; fi;    # cdebug no;
    return $sts;
}

#############################################################################
# DBG_TRC is called as getparms executes through its code. It is the main
# means of debugging and/or tracing code for predefined places in functions.
# Note: for speed when not in use DBG_TRC is assigned the dummy function,
# which always returns false. If any debugging is enabled (via -d#), then
# the real __DBG_TRC is unstubbed back to the base DBG_TRC name.
#
# __DBG_TRC : This tracing function has the distinct operations below
# (where 'n' is the predefined tracing number for a particular code section):
# DBG_TRC    n {chk} {msg} : enables tracing, message printed if supplied
# DBG_TRC -p n {chk} {msg} : pausing tracing, message printed if supplied (or: -d)
# DBG_TRC -r n {chk} {msg} : restore tracing, message printed if supplied
# DBG_TRC -x n {chk} {msg} : cancels tracing, message printed if supplied
# DBG_TRC -s n {chk} {msg} : skipany tracing, message printed if supplied
#
# Notes:
# 1. supplied message is printed, only if this function returns SUCCESS
# 2. if chk string supplied, then msg is only printed if str matches chk
# 3. to skip tracing use the -s option; it returns SUCCESS if matched so
#    caller can execute own functionality (e.g. calling own print function)
# 4. DbgCfg is if this enum has been configured for use (-da1|-d122|-d0x81)
#    DbgEna is if this enum has been enabled in run-time tracing (DBG_TRC 0x81)
# 5. pausing & restore functions only apply if tracing was enabled in run-time
# 6. Debug this function by uncommenting & setting trigger value: TrcDbg=0x81;
#    then uncomment the 1st line of function & the 'fi' before 'local rtn=...'
# 7. Warning: don't call function "is number" here, as it calls this function!
#############################################################################
#TrcDbg=0x30;
function  DBG_TRC()   { return $FAILURE; }                          # dummy to speed execution
function  __DBG_TRC() { # DBG_TRC {-x|-s} n {{chk} msg} # -x turn off, -s skip trace, n enum, chk str to test, msg text
#if [[ "$TrcDbg" == "$1" ]] || [[ "$TrcDbg" == "$2" ]]; then { set -x; } 2>/dev/null; else
    { set +x; } 2>/dev/null; # fi                                   # turn tracing off silently
    local rtn=$FAILURE; local dis=0; local was=0; local trc=1;      # set the default values
    if   [[ "$1" == -x ]];    then dis=1; shift;                    # are we disabling tracing
    elif [[ "$1" == -s ]];    then dis=2; shift;                    # are we skipping  tracing
    elif [[ "$1" == -r ]];    then dis=4; shift;                    # are we restoring tracing
    elif [[ "$1" == -[pd] ]]; then dis=3; shift; fi                 # are we pausing a tracing
    local num=$1; num=$((num)); shift;    # convert to dec in case hex, if not a number => 0
    if  [[ "${DbgCfg[$num]}" == 1 ]]; then                          # nothing to do if !config.
        local str="${DbgStr[$num]}";  local chk="";
        if  [ $# -gt 1 ]; then chk="$1"; shift; fi; local msg="$1"; # get remaining inputs
        if  [[ ! "$chk" ]] || [[ ! "$str" ]]; then rtn=0;           # no value to check against
        else local typ="${DbgTyp[$num]}"; case "$typ" in            # we must check chk string
        "$SRCH_ALL") [[ "$chk" ==  "$str"  ]] && rtn=0;;            # "=" match at all of item
        "$SRCH_ANY") [[ "$chk" == *"$str"* ]] && rtn=0;;            # "~" match any where in str
        "$SRCH_BGN") [[ "$chk" ==  "$str"* ]] && rtn=0;;            # "^" match at the beginning
        "$SRCH_END") [[ "$chk" == *"$str"  ]] && rtn=0;;            # "#" match at the trailing
        esac; fi; if ((rtn == 0)); then was=${DbgEna[$num]};        # capture old enable state
            if  [[ "$msg" ]]; then printf "%s\n" "$msg" >&2; fi     # only print if a message
            if  ((dis <= 1)); then trc=${DbgTrc[$num]};             # only enable|disable alter trace state
                local ena=$(( (dis == 0) && (trc == 1) ));          # enable only if trace allow & not disabling
                DbgEna[$num]=$ena;                                  # record new tracing state
            fi
        fi
    fi; if   ((rtn == 0)) && ((dis != 2)); then                     # do only if we should change
        if   ((dis == 0)); then if ((trc == 1)); then cdebug on; fi # turn on if tracing allowed
        elif ((dis == 1)); then if ((was == 1)); then cdebug no; fi # was on, turn off officially
        elif ((dis == 4)); then if ((was == 1)); then cdebug on; fi # turn on if tracing before
        elif ((dis == 3)); then if ((was == 1)); then cdebug no; fi; fi # turn off if tracing b4
    # silently reenable if were tracing & not disabling             # above line needed if TrcDbg
    elif ((TRACING == 1)); then { set -x; } 2>/dev/null; fi         # if were tracing turn back on
    { return $rtn; } 2>/dev/null;                                   # do silently don't put in trace
} # end DBG_TRC

#############################################################################
# To check if all the DBG_... calls are matched we must first find them all.
# This is the purpose of dbgenum. To do this we need to capture both "DBG_TRC  ",
# "DBG_TRC -x " & "DBG_TRC -s "; Note: doing 3 string removes: "DBG_TRC -x",
# "DBG_TRC -x", & "DBG_TRC  " to ensure we get all the debug numbers used,
# then we take the output and do a unique numeric sort on it. Note: this
# assumes each line may have only one of these constructs on it. Then to
# print the results we call Dbg GetLine to formats the grepped DBG_ line.
#############################################################################
function  DbgGetLine() { # DbgGetLine {-d}{-H} "line" # -v verbose, -H num in hex
    local vrb=0; if [[ "$1" == -v ]]; then shift; vrb=1; fi
    local hex=0; if [[ "$1" == -H ]]; then shift; hex=1; fi
    local line="${1/*DBG_TRC/}"; if [[ ! "$1" ]]; then return $FAILURE; fi
    local whol="$line";  line="${line##*( )}"; # remove all from space onwards (longest)
    line="${line/ */}";  line="${line/;*/}";
    if  [[ "$line" ]] && [[ "$line" != *'"'* ]]; then
        if  ((vrb == 0)); then
            if  [[ "$line" == 0x* ]]; then line=$((line)); fi # convert to dec
            if  [[ "$line" =~ $UNSN_INT ]]; then if ((hex == 0)); # only nums
                then printf "%-3s\n" "$line";
                else printf "%02X\n" "$line"; fi
            fi
        else # printing detail: rem all from num and before
            whol="${whol/*$line/}"; whol="${whol/;*/}";  # rem all from colon on
           #if [[ "$whol" == *'""'* ]]; then whol=""; fi # discard detail $ic ""

            if  [[ "$line" == 0x* ]]; then line=$((line)); fi  # convert to dec
            if  [[ "$line" =~ $UNSN_INT ]]; then if ((hex == 0)); # only nums
                then printf "%-3s %s\n" "$line" "$whol";
                else printf "%02X %s\n" "$line" "$whol"; fi
            fi
        fi
    fi
} # end Dbg GetLine

function  dbgenum() { local HELP="dbgenum -v|{-t}{-d}{-r}{-H}{-s|-x|+x|x} # -v verify, else show sorted numerical list, -d detail, -r repeated else unique, -H in hex, -s|-x|+x = search skip|disable|trace only";
    local trc=0; local vrb=""; local hex=""; local uniq="-un"; local grp;
    if  [[ "$1" == -t ]]; then trc=1;     shift; fi
    if  [[ "$1" == -v ]]; then shift; DbgVerify $trc; return $?; fi
    if  [[ "$1" == -t ]]; then trc=1;     shift; fi
    if  [[ "$1" == -d ]]; then vrb=-v;    shift; fi
    if  [[ "$1" == -H ]]; then hex=$1;    shift; fi
    if  [[ "$1" == -r ]]; then uniq="-n"; shift; fi
    local src="DBG_TRC";  local sts=$SUCCESS; local typ="$1"; # srch type
    cdebug on "$trc";
    if  [[ "$typ" == -s ]]; then grp="$src -s ";  # do skipping only: -s
        grep "$grp" $NAME | grep -v "^#" | while read line;
        do  line="${line/*"$grp"/}";              # rem if opt precedes num {-s}
            DbgGetLine $vrb $hex "$line";
        done | sort $uniq;
    elif [[ "$typ" == -x ]]; then grp="$src -x "; # do disables only: -x
        grep "$grp" $NAME | grep -v "^#" | while read line;
        do  line="${line/*"$grp"/}";              # rem if opt precedes num (-x|-s)
            DbgGetLine $vrb $hex "$line";
        done | sort $uniq;
    elif [[ "$typ" == +x ]]; then grp="$src  ";   # do enables only: ""
        grep "$grp" $NAME | grep -v "^#" | while read line;
        do  line="${line/*"$grp"/}";              # rem if opt precedes num (-x|-s)
            DbgGetLine $vrb $hex "$line";
        done | sort $uniq;
    elif [[ "$typ" == "" ]]; then grp="$src ";    # do for all types
        grep "$grp" $NAME | grep -v "^#" | while read line;
        do  line="${line/*"$src -x "/}"; line="${line/*"$src -s "/}";
            DbgGetLine $vrb $hex "$line";         # rem if opt precedes num (-x|-s)
        done | sort $uniq;
    elif [[ "$typ" == x ]] || [[ "$typ" == -+x ]] || [[ "$typ" == +-x ]]; then grp="$src ";
        grep "$grp" $NAME | grep -v "$src -s " | grep -v "^#" | while read line;
        do  line="${line/*"$src -x "/}";          # rem if opt precedes num {-x}
            DbgGetLine $vrb $hex "$line";         # doing enable & disable
        done | sort $uniq;
    else echo "$HELP" >&2; sts=$FAILURE; fi
    cdebug no "$trc"; return $sts;
} # end dbg enum

#############################################################################
# DbgVerify verifies DBG_TRC enables are matched with 1+ DBG_TRC disables
# NB: grep of diff output ensures if no such lines we get a failure status,
# which is what we want, as failure in this case means they match perfectly
#############################################################################
function  DbgVerify() { # DbgVerify trc # verifies if DBG_TRC & DBG_TRC -x match
    local trc=0; if [[ "$1" == 1 ]]; then trc=1; shift; fi
    dbgenum +x >"$ENAF"; dbgenum -x >"$DISF";    # enable & disable cases
    diff  -w  -B "$ENAF" "$DISF" | grep -E -v ^"---"$; local sts=$?; # get status
    if [ $sts -ne 0 ]; then echo "success"; sts=$SUCCESS; # error means no diffs (success)
    else echo "FAILURE"; sts=$FAILURE; fi        # diffs are output above if any
    if ((trc == 1)) || ((sts == FAILURE));       # if fail|trace save files
    then echo "files used: $ENAF $DISF" >&2;     # print out file names
    else rm -f "$ENAF" "$DISF"; fi; return $sts; # remove temp files
}

#############################################################################
# Following Escape functions are to deal with escaped special symbols
# HasUnescape checks for a given symbol if there is an unescaped one
#############################################################################
function  HasUnescape() { # HasUnescape sym val # result in global NOESC
    local sym="$1"; local lsym=${#sym}; local sts=$FAILURE;
    local val="$2"; local lval=${#val}; NOESC=0; # init global
    if   [ $# -lt 2 ] || ((lsym == 0)) || ((lval == 0)) || [[ "$val" != *"$sym"* ]];
    then return $FAILURE; fi

    DBG_TRC  12 "$sym" "HasUnescape: sym:$sym, val:$val";
    if  ((lsym == 1)); then # single character symbols : replace method
        local lval=${#val}; local temp; local ltmp; local esc;
        temp=${val//[^"$sym"]/}; ltmp=${#temp}; ((NOESC = ltmp)); # add no. sym
        temp=${val//\\"$sym"};   ltmp=${#temp}; ((esc   = lval - ltmp));
        temp="\\$sym";           ltmp=${#temp}; ((esc   = esc  / ltmp));
        ((NOESC -= esc));   # subtract no. escaped sym (int. div. ok)
        sts=$((NOESC > 0 ? SUCCESS : FAILURE));
    else local find; local lfnd; local escd; local lesc; # hunt & peck method
        # NB: the following test guarantees the 1st search will always be found
        while [[ "$val" == *"$sym"* ]]; do # NB: if not found, then find == val
            find="${val#*"$sym"}";   lfnd=${#find}; # get rest after sym
            escd="${val#*"\\$sym"}"; lesc=${#escd}; # get rest after \\sym [may not exist]
            if ((lfnd < lesc)); then NOESC=1; val=""; sts=$SUCCESS; # was found
            else val="$find"; fi           # advance val to what's after last find
        done
    fi; DBG_TRC -x 12 "$sym" "HasUnescape: NOESC=$NOESC"; return $sts;
    # caller tests global NOESC: if ((NOESC > 0));
    # or alternatively, do this: chck=$((NOESC > 0));
} # end Has Unescape

#############################################################################
# GetUnescape extracts what is before & after the unescaped 'symbol'
# NB: there are some uses where the before string needs the trailing symbol (-k)
#############################################################################
function  GetUnescape() { # GetUnescape {-k}{-u} sym val # results in globals UNESCBF & UNESCAF # -k keep trailing sym in b4, -u unescape
    local keep=0; if [[ "$1" == -k ]]; then keep=1; shift; fi
    local unes=0; if [[ "$1" == -u ]]; then unes=1; shift; fi
    local sym="$1"; local lsym=${#sym};
    local val="$2"; local lval=${#val};
    local sts=$FAILURE; UNESCBF=""; UNESCAF=""; # init globals
    if [ $# -lt 2 ] || ((lsym == 0)) || ((lval == 0)) || [[ "$val" != *"$sym"* ]];
    then return $sts; fi

    local tail="$val"; local find; local escd;
    local head="";     local lbfr; local lesc; local bfor;
    DBG_TRC  14 "$sym" "GetUnescape: sym:$sym, val:$val, keep:$keep";
    # NB: the following test guarantees the 1st search will always be found
    while [[ "$tail" == *"$sym"* ]]; do # NB: if not found, then find == tail
        bfor="${tail%%"$sym"*}";     lbfr=${#bfor}; # get what is b4 sym
        escd="${tail%%"\\$sym"*}";   lesc=${#escd}; # get what is b4 \sym [may not exist]
        find="${tail#*"$sym"}";                     # get rest after sym
        if ((lbfr < lesc)); then     tail="";       # stop: unescaped was found
            UNESCBF="$head$bfor";  UNESCAF="$find"; sts=$SUCCESS;
            if ((keep == 1)); then UNESCBF+="$sym"; fi
            if ((unes == 1)); then UNESCBF="${UNESCBF//\\$sym/$sym}"; fi
        else bfor+="$sym"; tail="$find"; head+="$bfor"; fi # advance to what's in find
    done; # NB: if no unescaped symbols, both UNESCBF and UNESCAF will be empty
    DBG_TRC -x 14 "$sym" ""; # "GetUnescape: UNESCBF='$UNESCBF' & UNESCAF='$UNESCAF'";
    return $sts; # caller gets requested string from globals UNESCBF & UNESCAF
    # caller probably wants to remove escapes from b4: UNESCBF="${UNESCBF//\\$sym/$sym}";
} # end Get Unescape

#############################################################################
# DelEscapes  deletes the escapes before the specified symbol if found
#############################################################################
function  DelEscapes() { # DelEscapes {-q} val # result in global UNESCAP # -q remove escapes b4 quotes also
    local quot=0; local noqt="$NOESCAP"; # first check if anything to do
    if [[ "$1" == -q ]]; then quot=1; shift; noqt="$NOESCBQ"; fi
    local val="$1"; if [[ "$val" != *\\* ]]; then UNESCAP="$val"; return $SUCCESS; fi
    local tail="$val"; local lval=${#val}; local remn="";
    local bfor; local lbfr; local nchr; UNESCAP=""; # init global
    DBG_TRC  13 "$val" "DelEscapes: val:$val, quot:$quot";
    # NB: the following test guarantees the 1st search will always be found
    while  [[ "$tail" == *\\* ]]; do # NB: if not found, then rest == tail
        bfor="${tail%%"\\"*}";     lbfr=${#bfor};   # get what is b4 '\'
        remn="${tail#*"\\"}";                       # get rest after '\'
        nchr="${remn:0:1}";                         # 1st char after '\'
        if [[ "$noqt" == *"$nchr"* ]]; then bfor+="\\"; fi # add it back!
        UNESCAP+="$bfor"; tail="$remn"; # advance to what's left in rest
    done; UNESCAP+="$tail"; # take whatever is left in rest
    DBG_TRC -x 13 "$val" ""; # "GetUnescape: UNESCBF='$UNESCBF' & UNESCAF='$UNESCAF'";
    return $sts; # caller gets requested string from globals UNESCBF & UNESCAF
} # end Del Escapes left

#############################################################################
# testing routine: test above 3 functions via unescape external function (below)
# To test via external call:
# getparms -x unescape -v -d -q 'func <item~i@\<\"+\"\>>'; # "func <item~i@<"+">>"
# getparms -x unescape -v -d    'func <item~i@\<\"+\"\>>'; # "func <item~i@<\"+\">>"
#############################################################################
function  unescape() { local HELP="unescape  {-t}{-v}{{-k}{-u|-d} -g|-ga|-gb|-gd} sym val # -d del esc, -u unesc, -k keep trail sym b4, -g|-ga b4|after, -gb b4+after, -gd dbg, else b4 sym, else unesc sym found";
    local vrb=0; local get=0; local del=0; local aft=0; local bfr=0;
    local opk;   local opu;   local opd;   local sym;   local val;
    local dbgtrc=0; if [[ "$1" == -t ]]; then dbgtrc=1; shift; fi
    if   [[ "$1" == -v  ]]; then vrb=1;         shift; fi
    if   [[ "$1" == -k  ]]; then opk=$1;        shift; fi
    if   [[ "$1" == -u  ]]; then opu=$1;        shift;
    elif [[ "$1" == -d  ]]; then del=1;         shift; fi
    if   [[ "$1" == -q  ]]; then opd=$1;        shift; fi
    if   [[ "$1" == -g  ]]; then get=1; bfr=1;  shift; # get before
    elif [[ "$1" == -ga ]]; then get=1; aft=1;  shift; # get after
    elif [[ "$1" == -gb ]]; then get=1; bfr=1;  shift; aft=1; # get both
    elif [[ "$1" == -gd ]] ||
         [[ "$1" == -gv ]]; then get=1; vrb=1;  shift; fi     # get detail
    # else call Has Unescape; set return code based on function calling
    cdebug on "$dbgtrc"; local sts=$((get == 0 ? 0 : FAILURE)); # return for Has: 0=unf.|1+=found
    if   ((del != 1)) && [ $# -lt 2 ]; then echo "$HELP" >&2; else
        if   ((del == 1)); then sym="\\"; val="$1"; shift;
        else  sym="$1"; val="$2"; shift 2; fi
        if   ((del == 1)); then DelEscapes  $opd  "$val"; sts=$?;
            if ((vrb == 1)); then echo "'$UNESCAP'"; fi
        elif ((get == 0)); then HasUnescape "$sym" "$val"; sts=$?;
            if ((vrb == 1)); then echo "$NOESC"; fi
        else GetUnescape $opk $opu "$sym" "$val"; sts=$?; local all="$UNESCBF$sym$UNESCAF";
            if ((vrb == 1)); then local eql=0; if [[ "$val" == "$all" ]]; then eql=1; fi
                echo "val='$val' bf='$UNESCBF' sym='$sym' af='$UNESCAF' all='$all' [eql=$eql]";
                elif ((bfr == 1)) && ((aft == 1)); then echo "'$UNESCBF' '$UNESCAF'"
                elif ((bfr == 1)); then echo "'$UNESCBF'";
                elif ((aft == 1)); then echo "'$UNESCAF'"; fi
        fi
    fi; cdebug no "$dbgtrc"; return $sts;
} # end unescape (external|test function)

#############################################################################
# Item Type Enums: used in parsing (see by: -hp)
# Symbl & Items arrays are used only for printing in Print All Items, but are
# also used by testing program getparmstest.sh, as are: IOptn, ICmnt, IReqd
# Note: REQ_..... are the default values, you are not to change these!
# Note: ITEM_NOLMT is used to config no delimiters as required|optional
# Note: IReqDef array never changes after initialized (defaults only)
#############################################################################
CF_SYMB='o';    # parsing option to change parsing items to required/optional
CF_ITEM="-$CF_SYMB"; # i.e.: '-o'
OC_NAME='';    # auto-assembled in InitItem:  " NoLmt Sqare Paran Angle Curly "
OC_SYMS='';    # auto-assembled in InitItem:  "''[]()<>{}"
OC_ALLS='';    # auto-assembled in InitItem:  "n|s|p|a|c"
OC_REQD='';    # auto-assembled in InitItem:  "10010"

  i=-1;                    declare -a IReqDef;      declare -a IReqd;      declare -a IOptn; declare -a Items;
((i++)); ITEM_INVAL=$i; REQD_INVAL=0; IReqDef[$i]=$REQD_INVAL; IReqd[$i]=$REQD_INVAL; IOptn[$i]='';  Items[$i]="Inval";
((i++)); ITEM_NOLMT=$i; REQD_NOLMT=1; IReqDef[$i]=$REQD_NOLMT; IReqd[$i]=$REQD_NOLMT; IOptn[$i]='n'; Items[$i]="NoLmt";
((i++)); ITEM_SQARE=$i; REQD_SQARE=0; IReqDef[$i]=$REQD_SQARE; IReqd[$i]=$REQD_SQARE; IOptn[$i]='s'; Items[$i]="Sqare";
((i++)); ITEM_PARAN=$i; REQD_PARAN=0; IReqDef[$i]=$REQD_PARAN; IReqd[$i]=$REQD_PARAN; IOptn[$i]='p'; Items[$i]="Paran";
((i++)); ITEM_ANGLE=$i; REQD_ANGLE=1; IReqDef[$i]=$REQD_ANGLE; IReqd[$i]=$REQD_ANGLE; IOptn[$i]='a'; Items[$i]="Angle";
((i++)); ITEM_CURLY=$i; REQD_CURLY=0; IReqDef[$i]=$REQD_CURLY; IReqd[$i]=$REQD_CURLY; IOptn[$i]='c'; Items[$i]="Curly";
((i++)); ITEM_SDASH=$i; REQD_SDASH=0; IReqDef[$i]=$REQD_SDASH; IReqd[$i]=$REQD_SDASH; IOptn[$i]='';  Items[$i]="SDash";
((i++)); ITEM_WORDS=$i; REQD_WORDS=0; IReqDef[$i]=$REQD_WORDS; IReqd[$i]=$REQD_WORDS; IOptn[$i]='';  Items[$i]="Words";
((i++)); ITEM_DDASH=$i; REQD_DDASH=0; IReqDef[$i]=$REQD_DDASH; IReqd[$i]=$REQD_DDASH; IOptn[$i]='';  Items[$i]="DDash";
((i++)); ITEM_MINPL=$i; REQD_MINPL=0; IReqDef[$i]=$REQD_MINPL; IReqd[$i]=$REQD_MINPL; IOptn[$i]='';  Items[$i]="MinPl";
((i++)); ITEM_QUOTE=$i; REQD_QUOTE=0; IReqDef[$i]=$REQD_QUOTE; IReqd[$i]=$REQD_QUOTE; IOptn[$i]='';  Items[$i]="Quote";
((i++)); ITEM_PIPES=$i; REQD_PIPES=0; IReqDef[$i]=$REQD_PIPES; IReqd[$i]=$REQD_PIPES; IOptn[$i]='';  Items[$i]="Pipes";
((i++)); ITEM_COMNT=$i; REQD_COMNT=0; IReqDef[$i]=$REQD_COMNT; IReqd[$i]=$REQD_COMNT; IOptn[$i]='';  Items[$i]="Comnt";
((i++)); ITEM_MAXIM=$i; ITEM_START=1; # always keep MAXIM as the last ITEM

declare -a ICmnt; declare -a CfgRq; declare -a Symbl; declare -a SymblSp;
i=$ITEM_INVAL; ICmnt[$i]="unsupported";                CfgRq[$i]="n";
               Symbl[$i]="!";          SymblSp[$i]=" ! ";         # unsupported
i=$ITEM_NOLMT; ICmnt[$i]="default required demarking"; CfgRq[$i]="y";
               Symbl[$i]="";           SymblSp[$i]="' '";         # no delimiter: ''  req
i=$ITEM_SQARE; ICmnt[$i]="default optional delimiter"; CfgRq[$i]="y";
               Symbl[$i]="[]";         SymblSp[$i]="[ ]";         # immutable: []  opt
i=$ITEM_PARAN; ICmnt[$i]="default optional delimiter"; CfgRq[$i]="y";
               Symbl[$i]="()";         SymblSp[$i]="( )";         # immutable: ()  opt
i=$ITEM_ANGLE; ICmnt[$i]="default required delimiter"; CfgRq[$i]="y";
               Symbl[$i]="<>";         SymblSp[$i]="< >";         # immutable: <>  req
i=$ITEM_CURLY; ICmnt[$i]="default optional delimiter"; CfgRq[$i]="y";
               Symbl[$i]="{}";         SymblSp[$i]="{ }";         # immutable: {}  opt
i=$ITEM_SDASH; ICmnt[$i]="unconfigurable option mark"; CfgRq[$i]="n";
               Symbl[$i]="-";          SymblSp[$i]=" - ";         # immutable: -
i=$ITEM_WORDS; ICmnt[$i]="unconfigurable item marker"; CfgRq[$i]="n";
               Symbl[$i]=" ";          SymblSp[$i]="   ";         # immutable: " "
i=$ITEM_DDASH; ICmnt[$i]="is specifiable as required"; CfgRq[$i]="n";
               Symbl[$i]="$SYMB_EOOM"; SymblSp[$i]="$SYMB_EOOM";  # immutable: --
i=$ITEM_MINPL; ICmnt[$i]="configurable end begin prm"; CfgRq[$i]="y";
               Symbl[$i]="$SYMB_EOBP"; SymblSp[$i]="$SYMB_EOBP";  #   changeable: -+
i=$ITEM_QUOTE; ICmnt[$i]="encapsulate spaces|special"; CfgRq[$i]="n";
               Symbl[$i]='""';         SymblSp[$i]='""'; # immutable: ""
i=$ITEM_PIPES; ICmnt[$i]="configurable groups marker"; CfgRq[$i]="n";
               Symbl[$i]="$SYMB_GRUP"; SymblSp[$i]="$SYMB_GRUP";  # dflt: |
i=$ITEM_COMNT; ICmnt[$i]="configurable comments mark"; CfgRq[$i]="n";
               Symbl[$i]="$SYMB_ECMT"; SymblSp[$i]="$SYMB_ECMT";  # dflt: #

#############################################################################
# Print & update routines for symbols
#############################################################################
function  PrintItem() { # PrintItem # prints out all item options in one line
    echo " $CF_ITEM. : .=$OC_ALLS for ''${OC_SYMS} [required=1; optional=0; set to: $OC_REQD]";
    echo "       to flip|set|clear delimiter's interpretation (|+|-): ${CF_ITEM}n OR ${CF_ITEM}n-c+"
} # used in both Print All Items & in Get Help

function  PrintChgOpt() { # prints all changed options, called as part of: -d
    local def; local req; #local hdr=0;
    local ic; local sym; local cmt; local opt; local str;
    for ((ic=ITEM_START; ic<ITEM_MAXIM; ic++)); do
        def=${IReqDef[$ic]}; req=${IReqd[$ic]}; str="${Items[$ic]}";
        if [[ "$str" ]] && ((def != req)); then # print changed settings
           #if ((hdr == 0));   then printf "OptionChg:\n"; hdr=1; fi
            if ((req == 1));   then cmt="items required"; else cmt="items optional"; fi
            sym="${SymblSp[$ic]}";  if [[ ! "$sym" ]]; then sym="\"\""; fi
            opt="$CF_ITEM${IOptn[$ic]}"; # must be valid if str not empty
            printf "%s=%s: %-3s %s (option: %s)\n" "$str" "$sym" "$sym" "$cmt" "$opt";
        fi
    done; # echo; # done by Configure:
}

function  PrintAllOption() { # prints all program options, called as part of: -ho
    local ic; local sym; local cfg; local cmt; local opt; local str;
    printf "\n ----- Following options $OPTREQ ------\n";
    printf "%s\n" "$(PrintItem)";
    printf          " ----- Following shows the delimiters and separators \n";
    printf "%s\n" " Name [req] opt Sym  Cfg   Notes  [required|optional]";
    printf          " ----------------------------------------------------\n";
    for ((ic=ITEM_START; ic<ITEM_MAXIM; ic++)); do
        str="${Items[$ic]}"; sym="${Symbl[$ic]}";
        cfg="${CfgRq[$ic]}"; cmt="${ICmnt[$ic]}";
        if [[ ! "${IOptn[$ic]}" ]]; then opt=""; else opt="-${IOptn[$ic]}"; fi
        if [[ "$str" ]]; then
        printf " %s[ %d ] %-3s %-4s  %-3s  %s\n" "$str" ${IReqd[$ic]} "$opt" "'$sym'" "$cfg" "$cmt"; fi
    done; if ((CfgSet[CF_ECHONO] == 0)); then echo; fi
} # end Print AllOption

function  Upd8Item() { # Upd8Item updates optional|required configs
    local ic; OC_ALLS=''; OC_REQD=''; OC_SYMS=''; OC_NAME=' '; # auto-assembled
    for ((ic=ITEM_START; ic < ITEM_MAXIM; ic++)); do
        if  [[ "${IOptn[$ic]}" ]]; then   # non-empty strings
            if ((ic == ITEM_START)); then
            OC_ALLS+="${IOptn[$ic]}"; else
            OC_ALLS+="|${IOptn[$ic]}"; fi # "nspac"
            OC_REQD+="${IReqd[$ic]}";     # "10010"
            OC_SYMS+="${Symbl[$ic]}";     # ''[]()<>{}
            OC_NAME+="${Items[$ic]} ";    # " NoLmt Sqare Paran Angle Curly "
        fi
    done
}

function  InitItem() { # InitItem initializes IReqd back to defaults
    IReqd[$ITEM_INVAL]=$REQD_INVAL;  IReqd[$ITEM_NOLMT]=$REQD_NOLMT;
    IReqd[$ITEM_SQARE]=$REQD_SQARE;  IReqd[$ITEM_PARAN]=$REQD_PARAN;
    IReqd[$ITEM_ANGLE]=$REQD_ANGLE;  IReqd[$ITEM_CURLY]=$REQD_CURLY;
    IReqd[$ITEM_SDASH]=$REQD_SDASH;  IReqd[$ITEM_WORDS]=$REQD_WORDS;
    IReqd[$ITEM_DDASH]=$REQD_DDASH;  IReqd[$ITEM_MINPL]=$REQD_MINPL;
    IReqd[$ITEM_QUOTE]=$REQD_QUOTE;  IReqd[$ITEM_PIPES]=$REQD_PIPES;
    IReqd[$ITEM_COMNT]=$REQD_COMNT;  Upd8Item;
}

function  SetItem() { # SetItem delimiter{+-}... index # e.g.: -o=eac # CF_ITEM ('-o') removed, set ac, clear e
    local dlmtr="$1"; local indx=$2; shift 2; local n=0; local got=0; local sts=$SUCCESS;
    local str; local item; local val; local unk=0; DlmtrsChg=0; # no. delimiters changed

    DBG_TRC  5 "$indx" "SetItem: indx:$indx, dlmtr:'$dlmtr'";
    while [[ "${dlmtr:n}" ]]; do str="${dlmtr:n}"; # wade thru items
    case "$str" in # set|clr|flip (+|-|) the setting of the option (check against defaults)
        "${IOptn[$ITEM_NOLMT]}+"*) IReqd[$ITEM_NOLMT]=1; ((n++)); got=1;  # n+
                              if ((IReqd[ITEM_NOLMT] != REQD_NOLMT)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_SQARE]}+"*) IReqd[$ITEM_SQARE]=1; ((n++)); got=1;  # s+
                              if ((IReqd[ITEM_SQARE] != REQD_SQARE)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_PARAN]}+"*) IReqd[$ITEM_PARAN]=1; ((n++)); got=1;  # p+
                              if ((IReqd[ITEM_PARAN] != REQD_PARAN)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_ANGLE]}+"*) IReqd[$ITEM_ANGLE]=1; ((n++)); got=1;  # a+
                              if ((IReqd[ITEM_ANGLE] != REQD_ANGLE)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_CURLY]}+"*) IReqd[$ITEM_CURLY]=1; ((n++)); got=1;  # c+
                              if ((IReqd[ITEM_CURLY] != REQD_CURLY)); then ((DlmtrsChg++)); fi;;

        "${IOptn[$ITEM_NOLMT]}-"*) IReqd[$ITEM_NOLMT]=0; ((n++)); got=1;  # n-
                              if ((IReqd[ITEM_NOLMT] != REQD_NOLMT)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_SQARE]}-"*) IReqd[$ITEM_SQARE]=0; ((n++)); got=1;  # s-
                              if ((IReqd[ITEM_SQARE] != REQD_SQARE)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_PARAN]}-"*) IReqd[$ITEM_PARAN]=0; ((n++)); got=1;  # p-
                              if ((IReqd[ITEM_PARAN] != REQD_PARAN)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_ANGLE]}-"*) IReqd[$ITEM_ANGLE]=0; ((n++)); got=1;  # a-
                              if ((IReqd[ITEM_ANGLE] != REQD_ANGLE)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_CURLY]}-"*) IReqd[$ITEM_CURLY]=0; ((n++)); got=1;  # c-
                              if ((IReqd[ITEM_CURLY] != REQD_CURLY)); then ((DlmtrsChg++)); fi;;

        "${IOptn[$ITEM_NOLMT]}"*)  item=$ITEM_NOLMT; val=${IReqd[$item]};
                                   IReqd[$item]=$((val == 0 ? 1 : 0)); got=1;  # n
                              if ((IReqd[ITEM_NOLMT] != REQD_NOLMT)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_SQARE]}"*)  item=$ITEM_SQARE; val=${IReqd[$item]};
                                   IReqd[$item]=$((val == 0 ? 1 : 0)); got=1;  # s
                              if ((IReqd[ITEM_SQARE] != REQD_SQARE)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_PARAN]}"*)  item=$ITEM_PARAN; val=${IReqd[$item]};
                                   IReqd[$item]=$((val == 0 ? 1 : 0)); got=1;  # p
                              if ((IReqd[ITEM_PARAN] != REQD_PARAN)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_ANGLE]}"*)  item=$ITEM_ANGLE; val=${IReqd[$item]};
                                   IReqd[$item]=$((val == 0 ? 1 : 0)); got=1;  # a
                              if ((IReqd[ITEM_ANGLE] != REQD_ANGLE)); then ((DlmtrsChg++)); fi;;
        "${IOptn[$ITEM_CURLY]}"*)  item=$ITEM_CURLY; val=${IReqd[$item]};
                                   IReqd[$item]=$((val == 0 ? 1 : 0)); got=1;  # c
                              if ((IReqd[ITEM_CURLY] != REQD_CURLY)); then ((DlmtrsChg++)); fi;;
        *) PrintErr $indx "$BPVR"  0 "SetItem unknown letter: $dlmtr at $n" >&2; # was: -p
                                   # quit as soon as we encounter our first error
                                   unk=1; sts=$FAILURE; break;; # flag already set error
    esac; ((n++)); done;   if  ((unk == 0)); then # NB: we can get multiple got=1 & 1 unk=1
        if   ((got == 1)); then Upd8Item; # update associated Item variables [next was: -p]
        else PrintErr $indx "$MTPI"  0 "found in SetItem no val4 $dlmtr" >&2; sts=$FAILURE; fi
    fi; DBG_TRC -x 5 "$indx" "SetItem: indx:$indx, dlmtr:'$dlmtr'";
    return $sts; # no illegal combos that we must prevent
} # end Set Item

#############################################################################
# Set Symbol character function (NB: CF_PARS (-p) removed prior to call)
# Want to be able to change one or more of the characters at same time, so
# we need a unique separator character to divide letters from the values.
# Can't depend on quotes as they may be stripped before we see them; also the
# separator char (aka: SYMB CNFG) can't be swappable|free char (e.g. ','|' ');
# originally used '%' which we reserved; this approach was simple but looked
# ugly. Ideally we'd like to use the option flag '-', but that collides with
# SYMB RANG ('-'), but we can't let that be 1 to a space. Note: that we
# are not restricting any of the symbols to be only one character in length.
#############################################################################
function  SetSym()  { # SetSym sym{%sym} # e.g.: m'..'%i':'%e'/'
    if [[ "$1" == *" "* ]]; then return $FAILURE; fi
    local ltr; local val; local asym; local n=0; local sts=$SUCCESS;
    local sym="$1"; DBG_TRC  4 "SetSym: sym:'$sym'";
    if [[ "$sym" ==  "-"* ]]; then sym="${sym:1}"; fi # swallow leading '-' if present
    # catch error where SYMB_CNFG ('-') is used for another symbol
    # replace all '-' with ' '; if sym using '-' restore; & check if at end
    # but don't do this for the end of beginning parm marker
    if [[ "$sym" != ${SymOpt[$SYM_EOBP]}* ]];
    then sym="${sym//$SYMB_CNFG/ }"; sym="${sym/  /$SYMB_CNFG }"; sym="${sym/% /$SYMB_CNFG}"; fi
    declare -a syms; syms=(${sym}); # arrayize input string
    local TMPSYMS=" $SYMB_EOBP $SYMB_GRUP $SYMB_ALTN $SYMB_MORE $SYMB_ECMT $SYMB_RANG $SYMB_TYPE $SYMB_PLAN $SYMB_REGX ";
    # Note: at this point all quotes have been 'lost'
    for asym in "${syms[@]}"; do # process leading letter & extract value after it
        ltr="${asym:0:1}"; val="${asym:1}"; # advance 1 letter
        if   [[ ! "$val" ]] || [[ "$val" == *" "* ]]; # if empty or has a space
        then PrintErr 0 "$MTPI"  0 "SetSym badval in '${sym:1}'" >&2; sts=$FAILURE; # was: -p
        elif [[ "$SYM_BAND" == *"$val"* ]];           # disallow banned symbols
        then PrintErr 0 "$BPVR"  0 "SetSym banned in '${sym:1}'" >&2; sts=$FAILURE; # was: -p
        elif [[ "$val" =~ [A-Za-z0-9] ]];             # disallow any alpha-numerics
        then PrintErr 0 "$BPVR"  0 "SetSym alpha# in '${sym:1}'" >&2; sts=$FAILURE; # was: -p
        elif [[ "$TMPSYMS"  == *" $val "* ]];         # can't be in existing set (don't match . with ...
        then PrintErr 0 "$BPVR"  0 "SetSym a dupe in '${sym:1}'" >&2; sts=$FAILURE; # was: -p
        else local TMP="let=${SymOpt[$SYM_EOBP]}, SYM_EOBP=$SYM_EOBP, SymCfg[$SYM_EOBP]=${SymCfg[$SYM_EOBP]}"
        case "$ltr" in
            "${SymOpt[$SYM_EOBP]}") SYMB_EOBP="$val"; SymCfg[$SYM_EOBP]="$val";; # b
            "${SymOpt[$SYM_GRUP]}") SYMB_GRUP="$val"; SymCfg[$SYM_GRUP]="$val";; # g
            "${SymOpt[$SYM_ALTN]}") SYMB_ALTN="$val"; SymCfg[$SYM_ALTN]="$val";; # a
            "${SymOpt[$SYM_MORE]}") SYMB_MORE="$val"; SymCfg[$SYM_MORE]="$val";; # m
            "${SymOpt[$SYM_ECMT]}") SYMB_ECMT="$val"; SymCfg[$SYM_ECMT]="$val";; # e
            "${SymOpt[$SYM_RANG]}") SYMB_RANG="$val"; SymCfg[$SYM_RANG]="$val";; # r
            "${SymOpt[$SYM_TYPE]}") SYMB_TYPE="$val"; SymCfg[$SYM_TYPE]="$val";  # t
                                    SYMB_LOCS=$SYMB_TYPE;;
            "${SymOpt[$SYM_PLAN]}") SYMB_PLAN="$val"; SymCfg[$SYM_PLAN]="$val";  # p
                                    SYMB_GETX="$val$val"; SYMB_NEGX="$val$val$val";;
            "${SymOpt[$SYM_REGX]}") SYMB_REGX="$val"; SymCfg[$SYM_REGX]="$val";  # x
                                    SYMB_GETP="$val$val"; SYMB_NEGP="$val$val$val";;
            *) PrintErr 0 "$BPVR"  0 "SetSym unknown letter: $syms @ $n" >&2; sts=$FAILURE; break;; # was: -p
        esac; ((n++)); fi # update temp copy of DF_SYMS
        TMPSYMS=" $SYMB_EOBP $SYMB_GRUP $SYMB_ALTN $SYMB_MORE $SYMB_ECMT $SYMB_RANG $SYMB_TYPE $SYMB_PLAN $SYMB_REGX ";
    done; # verify no illegal values for datatypes, purposely only do outside loop
    # so the user can temporarily use an illegal value to do intermediate swapping
    if  ((sts == SUCCESS)); then # now we must reset value of 'all symbols' value
        DF_SYMS=" $SYMB_EOBP $SYMB_GRUP $SYMB_ALTN $SYMB_MORE $SYMB_ECMT $SYMB_RANG $SYMB_TYPE $SYMB_PLAN $SYMB_REGX ";
        DF_NOSP="${DF_SYMS// /}"; # remove all spaces
        DataTextSpcl="[$DATA_TEXT, ${SYMB_TYPE}...$SYMB_PLAN by m|m${SYMB_RANG}n|m${SYMB_PLAN}n${SYMB_PLAN}o]";
        DataTxt2Spcl="[$DATA_TXT2, ${SYMB_TYPE}...$SYMB_PLAN by m|   |m${SYMB_PLAN}n${SYMB_PLAN}o]";
        Symbl[$ITEM_MINPL]="$SYMB_EOBP"; Symbl[$ITEM_PIPES]="$SYMB_GRUP"; Symbl[$ITEM_COMNT]="$SYMB_ECMT";

        PgmSymChg=0; # recalculate symbols changed
        local jc;  for ((jc=SYM_BGN; jc < SYM_LAST; jc++)); do case "$jc" in
        $SYM_EOBP) if [[ "$SYMB_EOBP" != "$DFLT_EOBP" ]]; then ((PgmSymChg++)); fi;;
        $SYM_GRUP) if [[ "$SYMB_GRUP" != "$DFLT_GRUP" ]]; then ((PgmSymChg++)); fi;;
        $SYM_ALTN) if [[ "$SYMB_ALTN" != "$DFLT_ALTN" ]]; then ((PgmSymChg++)); fi;;
        $SYM_RANG) if [[ "$SYMB_RANG" != "$DFLT_RANG" ]]; then ((PgmSymChg++)); fi;;
        $SYM_MORE) if [[ "$SYMB_MORE" != "$DFLT_MORE" ]]; then ((PgmSymChg++)); fi;;
        $SYM_ECMT) if [[ "$SYMB_ECMT" != "$DFLT_ECMT" ]]; then ((PgmSymChg++)); fi;;
        $SYM_TYPE) if [[ "$SYMB_TYPE" != "$DFLT_TYPE" ]]; then ((PgmSymChg++)); fi;;
        $SYM_PLAN) if [[ "$SYMB_PLAN" != "$DFLT_PLAN" ]]; then ((PgmSymChg++)); fi;;
        $SYM_REGX) if [[ "$SYMB_REGX" != "$DFLT_REGX" ]]; then ((PgmSymChg++)); fi;;
        *) ;;
        esac; done
    fi; DBG_TRC -x 4; # NB: no chk here
    return $sts;
} # end Set Sym

#############################################################################
# this function outputs changes in putting together quoted items with spaces
# Print Aggregate changes (debug):        1    2   3    4   5    6    7    8    9    10   11   12
#############################################################################
function  PrintAggregate() { # Aggregate name ndx cmdl top disc proc mtdn item save rest parm mtch
    local name="$1"; local ndx=$2;     local cmdl=$3;   local top=$4;    shift 4;
    local disc=$1;   local proc="$2";  local mtdn=$3;   local item="$4"; shift 4;
    local save="$1"; local remn="$2";  local parm="$3"; local mtch="$4"; shift 4;
    local sstr="";   if [[ "$save" ]]; then printf -v sstr "=> save=%s " "$save"; fi
    local pstr="";   if [[ "$parm" ]]; then printf -v pstr "=> parm=%s " "$parm"; fi
    local cr="";     if ((top == 1)) ; then cr=$CR; fi
    printf "$cr[%2d] %-6s: disc|proc|mtdn|mtch %d|%d|%d|%s rest=%s %s=> item=%s %s\n" \
           "$ndx" "$name" "$disc" "$proc" "$mtdn" "$mtch" "$remn" "$sstr" "$item" "$pstr"
}

#############################################################################
# Get Compare function loops through available string type options and forms
# the regex pattern which matches. Consolidated here so that it can be used
# by both is string and is number functions
# Note: following loops are coded to work even if repeated letters, e.g.: unn-
# Have verified via testing that regex with repeated patterns works fine,
# so no need to add extra code that checks for them and slows down processing
#############################################################################
CAS_STYP="~ + -";                   # case: insens. upper lower     [temp]
VAR_STYP="u n $CAS_STYP";           # u n ~ + -                     [used]
STR_ONLY="a b c d e f g h i j k l m n o p q r s t u v w x y z"; #   [temp]
STR_STYP="$STR_ONLY $CAS_STYP";     # add: ~ + -                    [used]
# generate versions with no spaces  # for shorthand displays
VAR_STYP_NOSP=${VAR_STYP// /};      # un~+-                         [used]
STR_STYP_NOSP=${STR_STYP// /};      # abcdefghijklmnopqrstuvwxyz~+- [used]
STR_STYP_DISP="a-z~+-";

function  GetCompare() { # GetCompare <v[un~+-]|-s{abcdefghijklmnopqrstuvwxyz~+-}>
    local dbgtrc=0; if [[ "$1" == -t ]]; then dbgtrc=1; shift; fi
    local opt="$1"; if [[ ! "$opt" ]]; then opt="-s"; fi; local bad="";
    local cmp="";   STR_CMP=""; STR_BAD=""; cdebug on "$dbgtrc"; # globals
    case "$opt" in # NB: using * allows empty string to pass, else use +
    -s)     ans=$INV_GOOD;; # string case insens. : any # nothing to do (cmp="")
    -s*)    local let;  local bgns; local caps; local smls; local quot; local spac;
            local hash; local dash; local plus; local atmk; local jots;
            local syms; local dlrs; local back; local star; local fwds;
            local tild; local eqal; local osym; local hats; local pcnt;
            local paus; local clon; local qstn; local unds; local xclm;
            local ic;   local punc; local len=${#opt};
            for ((ic=2; ic < len; ic++)); do let="${opt:$ic:1}"; # skip '-s'
                if  [[ "$STR_STYP" == *"$let"* ]]; then # abcdefghijklmnopqrstuvwxyz~+- w/ spaces
                    case "$let" in
                    '~') caps="$CAPSGRP";  # grp: A-Z    (upper case)
                         smls="$LOWRGRP";; # grp: a-z    (lower case)
                    '+') caps="$CAPSGRP";; # grp: A-Z    (upper case)
                    '-') smls="$LOWRGRP";; # grp: a-z    (lower case)
                    'a') atmk="@";;        # ind: at symbol
                    'b') back="\\";;       # ind: backslash
                    'c') clon=":;";;       # ind: colons
                    'd') bgns="$DLMTPAT";; # grp: ][()\<\>{} # '][' must be 1st to work
                    'e') eqal="=";;        # ind: equals
                    'f') fwds="/";;        # ind: forward slash
                    'g') punc="$PUNCPAT";; # grp: grammar (punct.): "'!?:;,.
                    'h') hash='#';;        # ind: hashmark
                    'i') qstn="\?";;       # ind: inquiry (question mark)
                    'j') jots='.';;        # ind: jot (period)   # escaped vers.
                    'k') hats="\^";;       # ind: caret (hat)    # escaped vers.
                    'l') math="$MATHPAT";; # grp: logic: *~=|&^% # escaped vers., - must be last
                    'm') dash="-";;        # ind: minus (dash)
                    'n') nums="$NUMSGRP";; # grp: 0-9 (numbers)
                    'o') osym="|";;        # ind: or: |
                    'p') plus="+";;        # ind: plus: +
                    'q') quot="\"'";;      # ind: quotes: "'
                    'r') paus=",";;        # ind: rest (comma): ,
                    's') star="*";;        # ind: star (asterisk): *
                    't') tild="~";;        # ind: tilda: ~
                    'u') unds="$UNDRSCR";; # grp: underscore: _
                    'v') pcnt="%";;        # ind: percent: %
                    'w') spac="\ ";;       # ind: whitespace: ' '
                    'x') xclm="\!";;       # ind: exclamation: !
                    'y') syms="$SYMSPAT";; # grp: symbols: @#$\\
                    'z') dlrs="\$";;       # ind: dollars: $
                    *)   bad+="$let";;     # bad: collect bad letters
                    esac;
                else bad+="$let"; fi
            done; # if no overall container group, reform it from its component options
            if   [[ ! "$math" ]]; then math="$eqal$fwds$hats$osym$pcnt$star$tild"; fi
            if   [[ ! "$punc" ]]; then punc="$clon$jots$qstn$paus$xclm"; fi
            if   [[ ! "$syms" ]]; then syms="$atmk$back$hash$dlrs"; fi
            # now join all container groups in proper order to form compare string
            cmp="$bgns$unds$caps$smls$nums$syms$punc$math$quot$plus$spac$dash";
            if   [[ "$cmp" ]] && [[ ! "$bad" ]]; then ans=$INV_GOOD; fi;;
    # Note: varnames must have 1+ more chars, empty string is a failure
    -v)     cmp=$VAR_CHAR; ans=$INV_GOOD;; # variable name (any)
    -v*)    local ic; local len=${#opt}; local let;
            local bgn; local end; local caps; local smls; local unds; local nums;
            for ((ic=2; ic < len; ic++)); do let="${opt:$ic:1}"; # skip '-v'
                if  [[ "$VAR_STYP" == *"$let"* ]]; then # u n ~ + -
                    case "$let" in
                    'u') unds="$UNDRSCR";; # ind: _      (underscore)
                    'n') nums="$NUMSGRP";; # grp: 0-9    (numbers)
                    '~') caps="$CAPSGRP";  # grp: A-Z    (upper case)
                         smls="$LOWRGRP";; # grp: a-z    (lower case)
                    '+') caps="$CAPSGRP";; # grp: A-Z    (upper case)
                    '-') smls="$LOWRGRP";; # grp: a-z    (lower case)
                    *)   bad+="$let";;     # bad: collect bad letters
                    esac;
                else bad+="$let"; fi
            done; # Note: all p/o begin fields are also p/o ending fields
            bgn="$unds$smls$caps"; end="$bgn$nums"; # setup begin & ending
            # Technically this must be "^[$bgn][$end]*$" to be correct, but
            # we may be trying to find the varname in another string, so
            # we can't specify here from beginning to ending
            cmp="[$bgn][$end]*"; # now join all strings in their proper order
            if [[ "$bgn$end" ]] && [[ ! "$bad" ]]; then ans=$INV_GOOD; fi;;
    *)      bad="$opt";; # FAILURE
    esac; STR_CMP="$cmp"; STR_BAD="$bad";
    cdebug no "$dbgtrc"; return $ans;
} # end Get Compare

#############################################################################
# is string & is number are needed in data type checking, so place here
# instead of with other string or number helper functions that are later
#
# is string notes
# -s is do generic strings (anything character goes)
# -v is do string for 'NIX style variable names: {_a-zA-Z}{_a-zA-Z0-9}*
# Note: the basic options -v|-s are case insensitive by default, thus adding
# any options to thm will limit the characters to only those flags where:
# c=caps [A-Z], l=lower [a-z], u=underscore [_], n=#s [0-9], m=math [-+*~=|&^%],
# s=space, d=delimiters [[]()<>{}], p=punctuation ["'`!?:;,.], y symbols [`@#$\/]
# NB: use internal string tests, as they are faster than extern tools (e.g.: tr)
# NB: requires use of Get Compare (which is reused by is_number)
# NB: to be able to use in regex compares '-' must be last char. in string
#############################################################################
function  stroptions_help() { # stroptions_help
    local shrt="$VAR_STYP_NOSP"; local long="$STR_STYP_DISP";
    echo "  -s[$long]* = string => any character (unless 1+ of following): "    >&2;
    echo "     a : at mark      [@]         |  n : numbers       [0-9]     "    >&2;
    echo "     b : backslash    [\]         |  o : or sign       [|]       "    >&2;
    echo "     c : colons       [:;]        |  p : plus          [+]       "    >&2;
    echo "     d : delimiter    [$DLMTGRP]  |  q : quotes        [\"']     "    >&2;
    echo "     e : equals       [=]         |  r : rest          [,]       "    >&2;
    echo "     f : fwd slash    [/]         |  s : star|asterisk [*]       "    >&2;
    echo "     g : grammar      [$PUNCDSP]    |  t : tilda         [~]     "    >&2;
    echo "     h : hash mark    [#]         |  u : underscore    [_]       "    >&2;
    echo "     i : inquiry      [?]         |  v : percent       [%]       "    >&2;
    echo "     j : jot|period   [.]         |  w : white(space)  [ ]       "    >&2;
    echo "     k : caret|hat    [^]         |  x : exclamation   [!]       "    >&2;
    echo "     l : logic|math   [$MATHGRP]  |  y : symbols       [$SYMSGRP]"    >&2;
    echo "     m : minus|dash   [-]         |  z : dollars       [\$]      "    >&2;
    echo "   case: ~|+|- = insens.|caps|lower                              "    >&2;
    echo "   e.g.: -ss~ => [a-z A-Z]* # case insens. string with spaces    "    >&2;
    echo "   ---------------------------------------------------------------"   >&2;
    echo "  -v[$shrt] = varname => [A-Za-z_][A-Za-z_0-9]* where u=_; n=[0-9]"   >&2; # DATA_VAR_NAM
    echo "   case: ~|+|- = insens.|caps|lower; e.g.: -vn- => [a-z][a-z0-9]* "   >&2;
    echo "   Note: the option -vn by itself is not allowed in a varname"        >&2;
} # used by both: is string & is number
function  is_string_help() { # is_string_help {badopt}
    echo >&2;  if [[ "$1" ]] && [[ "$1" != "-h" ]]; then echo "bad parms: '$1'" >&2;
    else local shrt="$VAR_STYP_NOSP"; local long="$STR_STYP_DISP";
    echo "is_string str {-t} {-v[$shrt] | -s[$long]} # def=-s (any ch.), -t trace" >&2;
    stroptions_help; echo >&2; fi # shared between is_number & is_string
}
function  is_string() { # is_string str <-v[un~+-]> | -s[abcdefghijklmnopqrstuvwxyz~+-]> # ~|+|- ins.|cap|low, u _, n numbers, d delimiters, l logic/math, g grammar, y symbols; -t trace (-h full help)
    local dbgtrc=0; if [[ "$1" == -t ]]; then dbgtrc=1; shift; fi
    local str="$1"; local opt="$2"; local ans=$INV_STRG;
    if [[ "$opt" == -h ]] || [[ "$opt" == -'?' ]] || ( [ $# -eq 1 ] &&
     ( [[ "$str" == -h ]] || [[ "$str" == -'?' ]] ) );
    then is_string_help; return $ans; fi; if ! cdebug on "$dbgtrc";
    then DBG_TRC  10 "$str" "is_string: str:$str, opt:$opt"; fi

    # empty string matches all, except a varname which requires 1+ chars
    if [[ ! "$opt" ]]; then opt="-s"; fi
    if [[ "$opt" != "v"* ]] && [[ ! "$str" ]]; then return $INV_GOOD; fi
    # Get Compare handles looping thru all -v*|-s* options
    GetCompare "$opt"; ans=$?; local cmp="$STR_CMP"; local bad="$STR_BAD";
    if   [[ "$bad" ]] || ((ans != INV_GOOD)); then is_string_help "$bad";
    elif [[ "$cmp" ]]; then shopt -u nocasematch; # only do if needed
        # turn off any nocasematch setting (-s) so we  match the case
        if   [[ "$opt" == -s* ]]; then if ! [[ "$str" =~ ^[$cmp]*$ ]]; then ans=$INV_STRG; fi
        elif [[ "$opt" == -v* ]]; then if ! [[ "$str" =~ ^${cmp}$  ]]; then ans=$INV_STRG; fi; fi
    fi; if ! cdebug no "$dbgtrc";
    then DBG_TRC -x 10 "$str" ""; fi; return $ans;
} # end is string

#############################################################################
# Value Enums distinguish the data values given by user (stored in Valu Type)
# Value enums are used for matching data types: ranges, enums, & surrounding
# Surrounding text can be used for equals or enums (not ranges), which is why
# it is not a separate value type
#############################################################################
declare -a  NumType;       declare -a IntType; # IntType are inputs to is_number
NUM_NAN=0;  NumType[$NUM_NAN]="nan";  IntType[$NUM_NAN]="";   # not a number
NUM_INT=1;  NumType[$NUM_INT]="int";  IntType[$NUM_INT]="-i"; # if an integer
NUM_HEX=2;  NumType[$NUM_HEX]="hex";  IntType[$NUM_HEX]="-h"; # if an hex int
NUM_DEC=3;  NumType[$NUM_DEC]="dec";  IntType[$NUM_DEC]="-n"; # if a decimal (i.e. a number)

((i=-1));   declare -a     ValuName;            # NB: the values are powers of two
((i++));    VALU_NONE=$i;  ValuName[$i]="NONE"; # 0 : if no values
((i++));    VALU_EQAL=$i;  ValuName[$i]="EQAL"; # 1 : if value equals  [no special char (def.)]
((i++));    VALU_RANG=$i;  ValuName[$i]="RANG"; # 2 : if value a range [signified by SYMB RANG]
((i++));    VALU_ENUM=$i;  ValuName[$i]="ENUM"; # 3 : if value an enum [signified by SYMB ENUM]
((i++));    VALU_LAST=$i;                       # 4 : keep 1 past last value

declare -a  ValuBits; # Note: the BIT values are powers of two
BIT_NONE=0; ValuBits[$VALU_NONE]=$BIT_NONE;     # if no values
BIT_EQAL=1; ValuBits[$VALU_EQAL]=$BIT_EQAL;     # if value equals
BIT_RANG=2; ValuBits[$VALU_RANG]=$BIT_RANG;     # if value a range
BIT_ENUM=4; ValuBits[$VALU_ENUM]=$BIT_ENUM;     # if value an enum
BIT_DOAL=$((BIT_EQAL|BIT_RANG|BIT_ENUM));       # support all type
BIT_NORS=$((BIT_EQAL|BIT_ENUM));                # no range support

#############################################################################
# DataTypes Enums for verifying specific item values
#############################################################################
((i=-1)); declare -a       DataText;                declare -a DataOpts;
((i++)); DATA_IS_NONE=$i;  DataText[$i]="";                    DataOpts[$i]=""; # no type specified: no DATA type
# following are IP addresses: ip4d, ip4h, ip6d, ip6h, ip4, ip6, ipd, iph, ipg
((i++)); DATA_IP4_DEC=$i;  DataText[$i]="IP4 decimal value";   DataOpts[$i]="${SYMB_TYPE}ip4d"; # 1
((i++)); DATA_IP4_HEX=$i;  DataText[$i]="IP4 hexadec value";   DataOpts[$i]="${SYMB_TYPE}ip4h"; # 2
((i++)); DATA_IP6_DEC=$i;  DataText[$i]="IP6 decimal value";   DataOpts[$i]="${SYMB_TYPE}ip6d"; # 3
((i++)); DATA_IP6_HEX=$i;  DataText[$i]="IP6 hexadec value";   DataOpts[$i]="${SYMB_TYPE}ip6h"; # 4
((i++)); DATA_IP4_NUM=$i;  DataText[$i]="IP4 numeral value";   DataOpts[$i]="${SYMB_TYPE}ip4";  # 5
((i++)); DATA_IP6_NUM=$i;  DataText[$i]="IP6 numeral value";   DataOpts[$i]="${SYMB_TYPE}ip6";  # 6
((i++)); DATA_IPN_DEC=$i;  DataText[$i]="IPn decimal value";   DataOpts[$i]="${SYMB_TYPE}ipd";  # 7
((i++)); DATA_IPN_HEX=$i;  DataText[$i]="IPn hexadec value";   DataOpts[$i]="${SYMB_TYPE}iph";  # 8
((i++)); DATA_IPN_NUM=$i;  DataText[$i]="IPn generic value";   DataOpts[$i]="${SYMB_TYPE}ipg";  # 9
((i++)); DATA_MAC_HEX=$i;  DataText[$i]="a MAC hex address";   DataOpts[$i]="${SYMB_TYPE}mac";  # 10
((i++)); DATA_E_MAILS=$i;  DataText[$i]="an E-mail address";   DataOpts[$i]="${SYMB_TYPE}e";    # 11
((i++)); DATA_ANY_URL=$i;  DataText[$i]="an URL or website";   DataOpts[$i]="${SYMB_TYPE}u";    # 12
# following are numbers|integers, supporting text before and/or after a number & ranges|enums
((i++)); DATA_NUM_POS=$i;  DataText[$i]="a positive number *"; DataOpts[$i]="${SYMB_TYPE}np";   # 13
((i++)); DATA_NUM_NEG=$i;  DataText[$i]="a negative number *"; DataOpts[$i]="${SYMB_TYPE}nn";   # 14
((i++)); DATA_ANUMBER=$i;  DataText[$i]="a pos/neg. number *"; DataOpts[$i]="${SYMB_TYPE}n";    # 15
((i++)); DATA_INT_POS=$i;  DataText[$i]="positive integers *"; DataOpts[$i]="${SYMB_TYPE}ip";   # 16
((i++)); DATA_INT_NEG=$i;  DataText[$i]="negative integers *"; DataOpts[$i]="${SYMB_TYPE}in";   # 17
((i++)); DATA_INTEGER=$i;  DataText[$i]="pos/neg. integers *"; DataOpts[$i]="${SYMB_TYPE}i";    # 18
((i++)); DATA_UNS_INT=$i;  DataText[$i]="unsigned integers *"; DataOpts[$i]="${SYMB_TYPE}#";    # 19
((i++)); DATA_ZEROONE=$i;  DataText[$i]="zero or one (0|1) *"; DataOpts[$i]="${SYMB_TYPE}B";    # 20
((i++)); DATA_BOOLNUM=$i;  DataText[$i]="boolean num (011) *"; DataOpts[$i]="${SYMB_TYPE}b";    # 21
((i++)); DATA_PERCENT=$i;  DataText[$i]="num% 0-val|-val-0 *"; DataOpts[$i]="${SYMB_TYPE}%";    # 22 [range]
((i++)); DATA_HEX_NUM=$i;  DataText[$i]="a hexadecimal num *"; DataOpts[$i]="${SYMB_TYPE}h";    # 23
# following are string types: bare 's' unneeded (no checks) unless a range|value(s) supplied
((i++)); DATA_STR_GEN=$i;  DataText[$i]="string: s[$STR_STYP_DISP] *";  DataOpts[$i]="${SYMB_TYPE}s"; # 24
((i++)); DATA_VAR_NAM=$i;  DataText[$i]="varnam: v[$VAR_STYP_NOSP]  *"; DataOpts[$i]="${SYMB_TYPE}v"; # 25
# following are file/dir types - NB: prw* must be before pr*
((i++)); DATA_PATH_RW=$i;  DataText[$i]="path read | write +"; DataOpts[$i]="${SYMB_TYPE}prw";  # 26
((i++)); DATA_PATH_WR=$i;  DataText[$i]="is path writable? +"; DataOpts[$i]="${SYMB_TYPE}pw";   # 27
((i++)); DATA_PATH_RD=$i;  DataText[$i]="is path readable? +"; DataOpts[$i]="${SYMB_TYPE}pr";   # 28
((i++)); DATA_PATH_UP=$i;  DataText[$i]="file|dir .. exist +"; DataOpts[$i]="${SYMB_TYPE}pu";   # 29
((i++)); DATA_PATH_NO=$i;  DataText[$i]="file or dir miss? +"; DataOpts[$i]="${SYMB_TYPE}pn";   # 30
((i++)); DATA_PATH_IS=$i;  DataText[$i]="file or dir exist +"; DataOpts[$i]="${SYMB_TYPE}p";    # 31
((i++)); DATA_DIRS_RW=$i;  DataText[$i]="file read | write +"; DataOpts[$i]="${SYMB_TYPE}drw";  # 32
((i++)); DATA_DIRS_WR=$i;  DataText[$i]="is file writable? +"; DataOpts[$i]="${SYMB_TYPE}dw";   # 33
((i++)); DATA_DIRS_RD=$i;  DataText[$i]="is file readable? +"; DataOpts[$i]="${SYMB_TYPE}dr";   # 34
((i++)); DATA_DIRS_UP=$i;  DataText[$i]="does parent exist +"; DataOpts[$i]="${SYMB_TYPE}du";   # 35
((i++)); DATA_DIRS_NO=$i;  DataText[$i]="this isn't a dir. +"; DataOpts[$i]="${SYMB_TYPE}dn";   # 36
((i++)); DATA_DIRS_IS=$i;  DataText[$i]="does a dir exist? +"; DataOpts[$i]="${SYMB_TYPE}d";    # 37
((i++)); DATA_FIL_RWX=$i;  DataText[$i]="file rd+write+exe +"; DataOpts[$i]="${SYMB_TYPE}frwx"; # 38
((i++)); DATA_FILE_WX=$i;  DataText[$i]="file write & exe. +"; DataOpts[$i]="${SYMB_TYPE}fwx";  # 39
((i++)); DATA_FILE_RX=$i;  DataText[$i]="file read and exe +"; DataOpts[$i]="${SYMB_TYPE}frx";  # 40
((i++)); DATA_FILE_EX=$i;  DataText[$i]="file isexecutable +"; DataOpts[$i]="${SYMB_TYPE}fx";   # 41
((i++)); DATA_FILE_RW=$i;  DataText[$i]="file read | write +"; DataOpts[$i]="${SYMB_TYPE}frw";  # 42
((i++)); DATA_FILE_WR=$i;  DataText[$i]="is file writable? +"; DataOpts[$i]="${SYMB_TYPE}fw";   # 43
((i++)); DATA_FILE_RD=$i;  DataText[$i]="is file readable? +"; DataOpts[$i]="${SYMB_TYPE}fr";   # 44
((i++)); DATA_FILE_UP=$i;  DataText[$i]="file path exists? +"; DataOpts[$i]="${SYMB_TYPE}fu";   # 45
((i++)); DATA_FILE_NO=$i;  DataText[$i]="does file exist?  +"; DataOpts[$i]="${SYMB_TYPE}fn";   # 46
((i++)); DATA_FILE_IS=$i;  DataText[$i]="check file exists +"; DataOpts[$i]="${SYMB_TYPE}f";    # 47
((i++)); DATA_MAXGOOD=$i;  # always keep as last good value # 48

# Following are used just to report errors within datatype functions
DATA_MISDATA=100; DataText[$DATA_MISDATA]="required data blank"; # missing required data
DATA_BADDATA=101; DataText[$DATA_BADDATA]="required data wrong"; # required data wrong
DATA_NO_FILE=102; DataText[$DATA_NO_FILE]="file does not exist"; # file does not exist
DATA_BAD_OPT=103; DataText[$DATA_BAD_OPT]="bad option supplied"; # bad option supplied
DATA_NO_PATH=104; DataText[$DATA_NO_PATH]="path does not exist"; # path does not exist

declare -a DataShip; # if supported by Short Hand Indirect Parms (SHIP)
declare -a DataSupt; # indicates what value types are supported by this datatype
DataShip[$DATA_IS_NONE]=0; DataSupt[$DATA_IS_NONE]="$BIT_NONE";
# following are IP addresses: ip4d, ip4h, ip6d, ip6h, ip4, ip6, ipd, iph, ip
DataShip[$DATA_IP4_DEC]=0; DataSupt[$DATA_IP4_DEC]="$BIT_EQAL";  # ip4d: IP4 decimal value  : (not comparable)
DataShip[$DATA_IP4_HEX]=0; DataSupt[$DATA_IP4_HEX]="$BIT_EQAL";  # ip4h: IP4 hexadec value  : (not comparable)
DataShip[$DATA_IP6_DEC]=0; DataSupt[$DATA_IP6_DEC]="$BIT_EQAL";  # ip6d: IP6 decimal value  : (not comparable)
DataShip[$DATA_IP6_HEX]=0; DataSupt[$DATA_IP6_HEX]="$BIT_EQAL";  # ip6h: IP6 hexadec value  : (not comparable)
DataShip[$DATA_IP4_NUM]=0; DataSupt[$DATA_IP4_NUM]="$BIT_EQAL";  # ip4 : IP4 numeral value  : (not comparable)
DataShip[$DATA_IP6_NUM]=0; DataSupt[$DATA_IP6_NUM]="$BIT_EQAL";  # ip6 : IP6 numeral value  : (not comparable)
DataShip[$DATA_IPN_DEC]=0; DataSupt[$DATA_IPN_DEC]="$BIT_EQAL";  # iph : IPn decimal value  : (not comparable)
DataShip[$DATA_IPN_HEX]=0; DataSupt[$DATA_IPN_HEX]="$BIT_EQAL";  # ipd : IPn hexadec value  : (not comparable)
DataShip[$DATA_IPN_NUM]=0; DataSupt[$DATA_IPN_NUM]="$BIT_EQAL";  # ipg : IPn generic value  : (not comparable)
DataShip[$DATA_MAC_HEX]=0; DataSupt[$DATA_MAC_HEX]="$BIT_EQAL";  # mac : a Mac hex address  : (not comparable)
DataShip[$DATA_E_MAILS]=0; DataSupt[$DATA_E_MAILS]="$BIT_EQAL";  # e   : an E-mail address  : (not comparable)
DataShip[$DATA_ANY_URL]=0; DataSupt[$DATA_ANY_URL]="$BIT_EQAL";  # u   : an URL or website  : (not comparable)
# following are generic numbers|integers
DataShip[$DATA_NUM_POS]=1; DataSupt[$DATA_NUM_POS]="$BIT_DOAL";  # np  : positive number    : {m|m-n|m+n|m@n@o}
DataShip[$DATA_NUM_NEG]=1; DataSupt[$DATA_NUM_NEG]="$BIT_DOAL";  # nn  : negative number    : {m|m-n|m+n|m@n@o}
DataShip[$DATA_ANUMBER]=1; DataSupt[$DATA_ANUMBER]="$BIT_DOAL";  # n   : pos/neg. number    : {m|m-n|m+n|m@n@o}
DataShip[$DATA_INT_POS]=1; DataSupt[$DATA_INT_POS]="$BIT_DOAL";  # ip  : positive integer   : {m|m-n|m+n|m@n@o}
DataShip[$DATA_INT_NEG]=1; DataSupt[$DATA_INT_NEG]="$BIT_DOAL";  # in  : negative integer   : {m|m-n|m+n|m@n@o}
DataShip[$DATA_INTEGER]=1; DataSupt[$DATA_INTEGER]="$BIT_DOAL";  # i   : pos/neg. integer   : {m|m-n|m+n|m@n@o}
DataShip[$DATA_UNS_INT]=1; DataSupt[$DATA_UNS_INT]="$BIT_DOAL";  # #   : unsigned integer   : {m|m-n|m+n|m@n@o}
DataShip[$DATA_ZEROONE]=1; DataSupt[$DATA_ZEROONE]="$BIT_DOAL";  # B   : zero or one (0|1)  : {m|m-n|m+n|m@n@o}
DataShip[$DATA_BOOLNUM]=1; DataSupt[$DATA_BOOLNUM]="$BIT_DOAL";  # b   : boolean num (010)  : {m|m-n|m+n|m@n@o}
DataShip[$DATA_PERCENT]=1; DataSupt[$DATA_PERCENT]="$BIT_DOAL";  # %   : num% 0-val|-val-0  : (not comparable)
DataShip[$DATA_HEX_NUM]=0; DataSupt[$DATA_HEX_NUM]="$BIT_DOAL";  # h   : hexadecimal num(s) : {m|m-n|m+n|m@n@o}
# following are string types
DataShip[$DATA_STR_GEN]=0; DataSupt[$DATA_STR_GEN]="$BIT_DOAL";  # s   : a generic string   : {m|m-n|m+n|m@n@o}
DataShip[$DATA_VAR_NAM]=0; DataSupt[$DATA_VAR_NAM]="$BIT_DOAL";  # v   : any variable name  : {m|m-n|m+n|m@n@o}
# following are file/dir types
DataShip[$DATA_PATH_RW]=0; DataSupt[$DATA_PATH_RW]="$BIT_NORS";  # prw : dir|file rd & wr   : {m|m+n|m@n@o}
DataShip[$DATA_PATH_WR]=0; DataSupt[$DATA_PATH_WR]="$BIT_NORS";  # pw  : dir|file writable  : {m|m+n|m@n@o}
DataShip[$DATA_PATH_RD]=0; DataSupt[$DATA_PATH_RD]="$BIT_NORS";  # pr  : dir|file readable  : {m|m+n|m@n@o}
DataShip[$DATA_PATH_UP]=0; DataSupt[$DATA_PATH_UP]="$BIT_NORS";  # pu  : dir|file path is   : {m|m+n|m@n@o}
DataShip[$DATA_PATH_NO]=0; DataSupt[$DATA_PATH_NO]="$BIT_NORS";  # pn  : dir|file is not    : {m|m+n|m@n@o}
DataShip[$DATA_PATH_IS]=0; DataSupt[$DATA_PATH_IS]="$BIT_NORS";  # p   : dir|file exist     : {m|m+n|m@n@o}
DataShip[$DATA_DIRS_RW]=0; DataSupt[$DATA_DIRS_RW]="$BIT_NORS";  # drw : dir read & write   : {m|m+n|m@n@o}
DataShip[$DATA_DIRS_WR]=0; DataSupt[$DATA_DIRS_WR]="$BIT_NORS";  # dw  : dir writable       : {m|m+n|m@n@o}
DataShip[$DATA_DIRS_RD]=0; DataSupt[$DATA_DIRS_RD]="$BIT_NORS";  # dr  : dir readable       : {m|m+n|m@n@o}
DataShip[$DATA_DIRS_UP]=0; DataSupt[$DATA_DIRS_UP]="$BIT_NORS";  # du  : dir parent exists  : {m|m+n|m@n@o}
DataShip[$DATA_DIRS_NO]=0; DataSupt[$DATA_DIRS_NO]="$BIT_NORS";  # dn  : dir not exist      : {m|m+n|m@n@o}
DataShip[$DATA_DIRS_IS]=0; DataSupt[$DATA_DIRS_IS]="$BIT_NORS";  # d   : dir exist          : {m|m+n|m@n@o}
DataShip[$DATA_FIL_RWX]=0; DataSupt[$DATA_FIL_RWX]="$BIT_NORS";  # frwx: file rd+write+exe  : {m|m+n|m@n@o}
DataShip[$DATA_FILE_WX]=0; DataSupt[$DATA_FILE_WX]="$BIT_NORS";  # fwx : file write & exe   : {m|m+n|m@n@o}
DataShip[$DATA_FILE_RX]=0; DataSupt[$DATA_FILE_RX]="$BIT_NORS";  # frx : file read and exe  : {m|m+n|m@n@o}
DataShip[$DATA_FILE_EX]=0; DataSupt[$DATA_FILE_EX]="$BIT_NORS";  # fx  : file isexecutable  : {m|m+n|m@n@o}
DataShip[$DATA_FILE_RW]=0; DataSupt[$DATA_FILE_RW]="$BIT_NORS";  # frw : file read & write  : {m|m+n|m@n@o}
DataShip[$DATA_FILE_WR]=0; DataSupt[$DATA_FILE_WR]="$BIT_NORS";  # fw  : file writable      : {m|m+n|m@n@o}
DataShip[$DATA_FILE_RD]=0; DataSupt[$DATA_FILE_RD]="$BIT_NORS";  # fr  : file readable      : {m|m+n|m@n@o}
DataShip[$DATA_FILE_UP]=0; DataSupt[$DATA_FILE_UP]="$BIT_NORS";  # fu  : file path exists   : {m|m+n|m@n@o}
DataShip[$DATA_FILE_NO]=0; DataSupt[$DATA_FILE_NO]="$BIT_NORS";  # fn  : file not exist     : {m|m+n|m@n@o}
DataShip[$DATA_FILE_IS]=0; DataSupt[$DATA_FILE_IS]="$BIT_NORS";  # f   : file exist         : {m|m+n|m@n@o}

#############################################################################
# Regex patterns needed for integer or number DataTypes Enums
# NB: these aren't from start to end here (^...$), let user do
#############################################################################
declare -a RegxPatt; # bash ERE mask to extract datatype
RegxPatt[$DATA_ANUMBER]='[+-]?[0-9]*[.]?[0-9]+';   # REGX_NUMS
RegxPatt[$DATA_NUM_POS]='[+]?[0-9]*[.]?[0-9]+';    # REGX_POSN
RegxPatt[$DATA_NUM_NEG]='[-][0-9]*[.]?[0-9]+';     # REGX_NEGN
RegxPatt[$DATA_INTEGER]='[+-]?[0-9]+';             # REGX_INTS
RegxPatt[$DATA_INT_POS]='[+]?[0-9]+';              # REGX_POSI
RegxPatt[$DATA_INT_NEG]='[-][0-9]+';               # REGX_NEGI
RegxPatt[$DATA_UNS_INT]='[0-9]+';                  # REGX_UINT
RegxPatt[$DATA_ZEROONE]='[0-1]';                   # REGX_ZER1
RegxPatt[$DATA_BOOLNUM]='[0-1]*';                  # REGX_BOOL
RegxPatt[$DATA_PERCENT]='[+-]?[0-9]*[.]?[0-9]+';   # => DATA_ANUMBER
RegxPatt[$DATA_HEX_NUM]='(x|0x)?0?([1-9a-fA-F]{1,}[0-9a-fA-F]?)'; # HEX_PATT

function  PrintAllTypes() { # print all datatype related info (called from: -ht)
    local ic; local str; local src; local typ; local cnt=0; local off="  ";
    local colHdr="value  = $DT_MNG";  local dash;
    printf "\n%s%s%-7s%s\n" "$off" "$colHdr" " " "$colHdr";
    printf -v dash -- '-%.0s' {1..58}; printf "%s%s\n" "$off" "$dash";
    for ((ic=DATA_IS_NONE; ic<DATA_MAXGOOD; ic++)); do str="${DataText[$ic]}";
        if  [[ "$str" ]]; then src="${DataOpts[$ic]}";
            printf -v typ "%-6s = " "$src";
            printf "  %-30s" "$typ$str";
            ((cnt++)); if ((cnt >= 2)); then echo; cnt=0; fi
        fi # in case we end with an odd number add prefixing <c/r>
    done; local rtn="$CR$CR"; if ((cnt == 0)); then rtn="$CR"; fi
    printf "$rtn%s%s\n" "$off" "$DataTextSpcl";
    printf     "%s%s\n" "$off" "$DataTxt2Spcl";
    printf "%s[%s plain matching, %s regex matching, double to do extract]\n" "$off" "$SYMB_PLAN" "$SYMB_REGX";
    printf "%s[use triple matching symbols to do negative matching case]\n" "$off"
    printf "%s[*|+ value|enum all|bgn|gird|has|end with %s\n" "$off" "m|m+|m+n|+m+|+m]";
   #printf "%s[alt after ~.: +|-|~ for capitals|smalls|case insensitive]\n" "$off";
    printf "%s[Default if no type is specified is string ['s'], e.g.: $SYMB_TYPE]\n" "$off";
    printf "%s[To see string+var|number options: $NAME -hts|-htn ]\n" "$off"; # getparms.sh
    if  ((CfgSet[CF_ECHONO] == 0)); then echo; fi
} # end Print AllTypes
function  PrintNumTypes() { is_number_help; } # called from: -htn [old: getparms.sh -x is_string -h]
function  PrintStrTypes() { is_string_help; } # called from: -hts [old: getparms.sh -x is_number -h]

#################################################################################
# Data Arrays that are used by getparms (see also the array CfgSet [above])
# NB: when adding a new array remember to add it to: Init Array & Copy Array
# Some items need to be linked together: (1) the indparm with all its parms,
# (2) OR'ed options [-i|--in], and (3) Mixed groups [-o|-f|m|-i=parm]. All
# the items in the linked group will have the same link number, which will
# always be the index of the first item in the linked group. But notice that
# indparm may be part of a larger linked group, and when we check to see if
# we've gotten a correct indparm, checking if we've received the option(s) is
# not enough, we also have to make sure that we've gotten all the indparms.
# So the first option of an indparm group will store: (a) how many options
# total have been received, (b) how many total parms have been received, and
# (c) the index of where the parms begin (so we can jump over the options)
#################################################################################

####################### Spec Arrays (set by Set Spec) ###########################
# Note: these arrays are all based on the number of items specified by user.
# The DescName is used for error messages, name reused checking, & in lists.
# The ParmName is the parm name or if an option the option with '-' removed.
# The RcvdName is the ParmName but with '_n' postfixed for any more'd parms.
# The Alt_Name must be kept separate from the ParmName so that we have both.
# Thus the output name used is the Alt_Name (if available) or the RcvdName.
#################################################################################
declare -a ItemIndx;  # array of the index this is on: n (for ease of debugging)
declare -a CmdlIndx;  # array of the cmdl index is on: n (for ease of debugging)
declare -a LinkIndx;  # array of link to related parm: -1|n [Ored|Mixd] link points to head
declare -a MoreIndx;  # array of the more values indx: 0 | 1 ... n [0=no more]
declare -a GroupNum;  # array of group number this on: n
declare -a Ored_Num;  # array of OR'ed items now done: n
declare -a SrchName;  # array of option search string: -i | ""
declare -a ParmName;  # array of parameter names e.g.: _i | parm
declare -a Alt_Name;  # array of alternate names e.g.: "" | altnam (if avail.)
declare -a DescName;  # array of descript. names e.g.: -i | parm | altnam
declare -a GoodName;  # array of if name is valid one: 1|0
declare -a HasAltNm;  # array of option name has alt.: 1|0
declare -a ReqdItem;  # array of if item is required : 1|0
declare -a MixedGrp;  # array of if its in mixed list: 1|0
declare -a Ored_Grp;  # array of if this is p/o OR'ed: 1|0 [-o|--on]
declare -a BaseType;  # array of the item's Base enum: ..._BASE
declare -a IndpType;  # array of the item's IND_ enum: IND_...
####################### Indp Arrays (set by Set Spec) ###########################
# Note: these arrays are only applicable to ind. parm 'groups'
#################################################################################
declare -a AllItems;  # array of complete indp. name : -f|--file prm1 prm2 [@head]
declare -a MindIndx;  # array of link to related parm: -1|n  [link points to head]
declare -a MindParm;  # array of if its p/o ind parm.: 0|1|2 [include opt: 2=OSIP]
declare -a IndpOpts;  # array of indparm options list: "-i|--in" [set by Set Spec]
declare -a ParmIndx;  # array of index of first parm.: 0 ... n [set by Set Spec]
declare -a NumParms;  # array of number parms. to get: n       [set by Set Spec] (NB: 0 for SHIP)
declare -a NumOptns;  # array of number optns spec'ed: n       [set by Set Spec]
declare -a RxdParms;  # array of count of rxd params.: n       [set by Set Rcvd]
declare -a RxdOptns;  # array of count of rxd options: n       [set by Set Rcvd]
####################### SHIP Arrays (set by Get ShipFlag) #######################
# Note: these arrays are only applicable to short hand indirect parms
declare -a ShipBits;  # the configured SHIP bit flags: 2|4 ... [set by GetShipFlag]
declare -a ShipChar;  # the configured SHIP character: +-,.012 [set by GetShipFlag]
declare -a ShipOnes;  # the configured SHIP srch mono: regex   [set by GetShipFlag]
declare -a ShipEnum;  # the configured SHIP srch enum: regex   [set by GetShipFlag]
declare -a ShipRang;  # the configured SHIP srch rang: regex   [set by GetShipFlag]
declare -a ShipTest;  # the resultant SHIP tst result: regex   [set by GetShipFlag]
####################### Other Arrays (by index) #################################
declare -a MissPnam;  # array of if missing parm name: enum|"" [set by PrintErrs]
####################### Type Arrays (set by another) ############################
# Note: these arrays are all still based on the number of specified items
# Note: any new arrays here remember to add to ClrDataType
#################################################################################
declare -a BgnParam;  # array of if a beginning parm.: 1|0      [GetBgnPrm()]
declare -a DataRegx;  # array of config regex matches: 1|0      [data type()]
declare -a Extracts;  # array of flags to extract str: 1|0      [data type()]
declare -a Negation;  # array of flags to do negation: 1|0      [data type()]
declare -a DataType;  # array of a data type to match: DATA_... [data type()]
declare -a DataPost;  # array of a str postfix letter: un~+-    [data type()]
declare -a DataVal1;  # array of data values to match: bgn      [data type()]
declare -a DataVal2;  # array of data values to match: end      [data type()]
declare -a DataSrch;  # array of string search locale: SRCH_    [see SrchFlg]
declare -a ValuType;  # array of enums of value types: VALU_    [data type()]
declare -a NmbrType;  # array of enums of value types: NUM_     [data type()]
####################### Rcvd Arrays (set by SetRcvd) ############################
# Note: these arrays are all still based on the number of specified items
#################################################################################
declare -a MissIndp;  # array of indp names not rcvd.: name, name_1
declare -a RcvdName;  # array of names of items rcvd.: name, name_1
declare -a RxdState;  # array of present rcvd. status: RX_...
declare -a RxdInvld;  # array of if doesn't matchtype: INV_ enums
declare -a RxdNmOpt;  # array of names of optns rcvd.: -i --in [should be 0|1] @ link
declare -a RxdNuOpt;  # array of number options rcvd.: 0|1|... [should be 0|1] @ link
declare -a RxdCount;  # array of times item was rcvd.: 0|1|... [-1 if mixed & opt rcvd]
declare -a RxdValue;  # array of the last value rcvd.: val     [Note: may be ""]
declare -a RxdIndex;  # array of indices in cmd. line: 3,4
#################################################################################
# Note: following arrays are all based on other numbering sizes, not NumAllItm
####################### Output Arrays ###########################################
declare -a CmdLineNdx;# array of original cmdl indices
declare -a OutArray;  # array for writing rcvd output
declare -a ParseErr;  # array for writing rcvd errors
declare -a ParsEnum;  # array of received error enums
####################### Optimal Arrays ##########################################
declare -a NdxBgnPrm; # array of indices of begining params - set by Init AllItem
declare -a NdxEndPrm; # array of indices of trailing params - set by Init AllItem
declare -a NdxIndPrm; # array of indices of indirect params - set by Init AllItem
declare -a NdxOption; # array of indices of all the options - set by Set Spec
declare -a NdxRxdOpt; # array of indices of all rxd options - set by Set Rcvd
declare -a GroupNams; # array of names of items in this grp - set by Set Spec
####################### Multi-Option Arrays #####################################
declare -a ShortOpts; # array of singleletter options: -i   [size: NumShrtOp]
declare -a ShortIndx; # array of singleletter indices: 2, 5, 6, 8 [NumShrtOp]
declare -a ShipOptns; # array of SHIP options srchstr: -i   [size: NumShipOp]
declare -a ShipIndex; # array of SHIP options indices: 2, 5, 6, 8 [NumShipOp]
declare -a TwoLtrCnt; # array of count of 2 letter options
declare -a TwoLtrNdx; # array of indics of 2 letter options for that letter: "3 5 "
declare -a TwoLtrOpt; # array of 2 letter options indexed by ASCII value
####################### of 1st letter, e.g.: -ca -cb => TwoLtrOpt[99]=" a b "
# Calculated Array sizes & Item counts
# Note: the BgnPrm & EndPrm must not include any indirect parms
##################################################################################
FatalErrs=0;    # subset of specification errors for which we can't parse cmdline
NumRxdOpt=0;    # number of elements in NdxRxdOpt array based on received options
NumBgnPrm=0;    # number of elements in NdxBgnPrm array based on begining params.
NumEndPrm=0;    # number of elements in NdxEndPrm array based on trailing params.
NumPrmReq=0;    # number of all required parameters that are in the specification
NumReqBgn=0;    # number of required bgn parameters that are in the specification
NumReqEnd=0;    # number of required end parameters that are in the specification
EndOptPrm=0;    # number of optional end parameters that are in the specification
NumIndOpt=0;    # number of options that are part of indirect params (short|long)
NumIndPrm=0;    # number of elements in NdxIndPrm array based on indirect params.
NumHidPrm=0;    # number of elements in NdxHidPrm list based on mixed hidden parm
NumShrtOp=0;    # number of elements in Shrt Opts array based on 1-letter options
NumShipOp=0;    # number of elements in Ship Opts array based on num SHIP options
Do2LtrOpt=0;    # flag that is set when > 1 TwoLtrOpt is added to the same letter
NumFunctn=0;    # number of elements received for the function (e.g.: [0] = func)
NumAllItm=0;    # number of elements in non-Optimal arrays having specified items
NumReqOpt=0;    # number of required options (includes parms of req'd ind. parms)
RemReqOpt=0;    # number of the required options that we are still trying to find
RemReqBgn=0;    # number of the required bgn parm that we're still trying to find
RemReqEnd=0;    # number of the required end parm that we're still trying to find
RxdOptPrm=0;    # number of the optional parameter that we have received to date
NumErrors=0;    # number of elements in the ParseErr array based on parsing error
NumOption=0;    # number of elements in NdxOption array based on optional options
                # includes num IndOpts, so NumPureOpt is difft, but not HLP_BASE.
#################################################################################
# Lists used by getparms: strings composed of all the items in a list, space
# separated, so that they can be easily printed and searched (e.g.: if [[ "$List"
# == " $opt " ]]). NB when searching: to avoid false matches (e.g.: 5 matching 15)
# we must put a space before the 1st item & after the last items (e.g.: " 1 3 5 ").
#################################################################################
NdxOfShip=' ';  # list of indices of all SHIP params - set by Set Spec
NdxReqPrm=' ';  # list of indices of required params - set by Init AllItem
NamHidPrm='';   # list of names of mixed hidden parm - set by Init AllItem
NdxHidPrm='';   # list of indices of mix hidden parm - set by Init AllItem
EndBgnRxd='';   # index if unspecified end opts marker rcvd.: 4
EndOptRxd='';   # index if unspecified end opts marker rcvd.: 14
RxOptParm='';   # indices of rcvd optional parm: " 3 4"
ParmNames=' ';  # list of all given parm. names: " m param1 "
IndOption=' ';  # list of all given indp option: " -f --file "
IndpNames=' ';  # list of all given indp. names: " ind1 ind2 "
SrchOptns=' ';  # list of all given optn. names: " -i --file " # excludes SHIPs
SrchShips=' ';  # list of all given SHIP  names: " -b -d "
DualOptns=' ';  # list of all given optn. names of dual opts: " c "
DualNmbrs=' ';  # list of all given optn. value of dual opts: " 99 "
LongOptns=' ';  # list of all given long optns.: " --in --out "
RcvdOptns=' ';  # list of all received options : " -i --files "
#################################################################################

#################################################################################
# Display Items (debug routine called by -di) displays the fields of the
# specified items useful for debugging. Display Items loops through the items
# & iteratively calls Disp Item; -di loops thru all, -di# just number #, and
# -di#-# does a range, while -d#- starts from # & goes to the end.
#################################################################################
function  DispItem() { # DispItem indx spec {msg} [Debug function]
    local indx=$1;   local spec=$2;   local msg="$3"; # trace parm processing
    DBG_TRC  0x88 "$indx" "DispItem: indx:$indx, spec:$spec, msg:$msg";
    local rxst=${RxdState[$indx]};    local rstr="${RxMsgStr[$rxst]:0:3}"; # short version
    local base=${BaseType[$indx]};    local bstr="${BaseName[$base]}";
    local parm=$((base == PRM_BASE)); local snam="${SrchName[$indx]}";
    local ship=$((base == SIP_BASE)); local midx="${MindIndx[$indx]}";
    local optn=$((base == OPT_BASE)); local nstr;
    local pnam="${ParmName[$indx]}";  local desc="${DescName[$indx]}";
    local misp="${MissPnam[$indx]}";  if [[ ! "$misp" ]]; then misp="\"\""; fi
    local rxin="${RxdIndex[$indx]}";  if [[ ! "$rxin" ]]; then rxin="\"\""; fi
    local rval="${RxdValue[$indx]}";  local dtyp="${DataType[$indx]}";
    local altn="${Alt_Name[$indx]}";  if [[ "$altn" ]]; then altn=":$altn"; fi
    if   [[ ! "$snam" ]]; then snam="\"\""; fi; local shch="";
    if   ((ship == 1)); then nstr="Ship"; shch="${ShipChar[$indx]}";
         if [[ ! "$rval" ]]; then rval="\"\""; fi
    elif ((parm == 1)); then nstr="Parm"; else rval=" $rval"; nstr="Optn"; fi
    DBG_TRC -x 0x88 "$indx" "DispItem: bgn"; # don't trace displaying

    # Notes: if altn, then Desc will be that, else depends on if parm|optn
    local ntyp="${NmbrType[$indx]}"; nstr="${NumType[$ntyp]}";  # convert to string
    if [[ "$msg" ]]; then printf "%s\n" "$msg"; fi
    printf "%s DispItem %02d %s\n" \
            "=============" "$indx" "============================================" >&2;
    printf  "BaseType=%s| NumType=%s | Name (Srch|Desc|Parm): %s|%s|%s\n" \
            "$bstr" "$nstr" "$snam" "$desc" "$pnam" >&2;
    printf  "MoreIndx=%2d | MixedGrp=%2d | Ored_Grp=%2d | Ored_Num=%2d | LinkIndx=%2d\n" \
            "${MoreIndx[$indx]}" "${MixedGrp[$indx]}" "${Ored_Grp[$indx]}" \
            "${Ored_Num[$indx]}" "${LinkIndx[$indx]}"  >&2;
    printf  "CmdlIndx=%2d | ReqdItem=%2d | GoodName=%2d | MissPnam=%2s | HasAltNm=%2d\n" \
            "${CmdlIndx[$indx]}" "${ReqdItem[$indx]}" "${GoodName[$indx]}" "$misp" \
            "${HasAltNm[$indx]}"  >&2;

    if  ((ship == 1)); then local test="${ShipTest[$indx]}"; # for any SHIP: (for cfgd SHIP: [[ "$shch" ]])
    printf  "%s\n" "------------- SHIP Option : State=${ShipSt8Str[$test]} --------------------------------" >&2;
        local enum="${ShipEnum[$indx]}"; local rang="${ShipRang[$indx]}";
        local ones="${ShipOnes[$indx]}"; local bits="${ShipBits[$indx]}";
        printf  "ShipBits=%03X: %-11s | Ones='%s'\n" "$bits" "[$shch]" "$ones" >&2;
        if   [[ "$rang" ]]; then printf "Rang='%s'\n" "$rang" >&2; fi
        if   [[ "$enum" ]]; then printf "Enum='%s'\n" "$enum" >&2; fi
    fi # ------------------------- End all Cfg SHIPs ---------------------------

    if  ((midx != -1)); then #---- Only for Ind Parms --------------------------
    printf  "MindParm=%2d | MindIndx=%2d | ParmIndx=%2d | NumParms=%2d | NumOptns=%2d\n" \
            "${MindParm[$indx]}" "${MindIndx[$indx]}" "${ParmIndx[$indx]}" \
            "${NumParms[$indx]}" "${NumOptns[$indx]}"  >&2;
    fi # ------------------------- End all Ind Parms ---------------------------

    # ---------------------------- Only for Datatypes --------------------------
    DBG_TRC  0x88 "$indx" "DispItem: end"; # trace setup processing
    if  ((dtyp != DATA_IS_NONE)); then local dtyStr; # only print DataType fields if set
    local dstr="${DataText[$dtyp]}"; if [[ "$dstr" =~ [+*]$ ]];
    then local dlen=${#dstr}; dstr="${dstr:0:dlen-1}"; fi # remove trailing: "+"|"*"
    printf -v midStr ": %s" "$dstr";
    printf -v dtyStr " -------------------------------------------"; # 1 < midStr
    local ldst=${#dtyStr}; local ltmp=${#midStr}; local left; # ((left = ldst-ltmp));
    if  ((ltmp < ldst)); then FillStr -o dtyStr "$midStr" "$dtyStr"; fi
    local post="${DataPost[$indx]}";  if [[ ! "$post" ]]; then post="\"\""; fi
    local val1="${DataVal1[$indx]}";  local val2="${DataVal2[$indx]}";
    local valt="${ValuType[$indx]}";
    if  ((valt == VALU_RANG));     then val1="${val1}-${val2}"; # a range
    elif [[ "$val1" && "$val2" ]]; then val1="${val1}|${val2}"; # surrounding text
    elif [[ "$val2" ]]; then val1="|$val2"; else val1="$val1";  fi # quote !number & !range

    local dsrc="${DataSrch[$indx]}"; dsrc="${SrchFlg[$dsrc]}";  # convert to string
    local vtyp="${ValuType[$indx]}"; vtyp="${ValuName[$vtyp]}"; # convert to string
    if  ((ntyp == NUM_NAN)) && ((valt != VALU_RANG)); then      # when to quote
        val1="\"$val1\""; if ((optn != 1)); then rval="\"$rval\""; fi
    fi  # else leave unquoted

    local dvlStr;  printf -v dvlStr "            |             |            ";
   #FillStr -o dvlStr "$pfix" "$dvlStr";
    DBG_TRC -x 0x88 "$indx" "DispItem: end"; # don't trace displaying

    if  [[ "$val1" ]]; then
    printf -v midStr "  DataValu=%s " "$val1";
    printf -v dtyStr " -------------------------------------------"; # 1 < midStr
    local ldst=${#dtyStr}; local ltmp=${#midStr}; local left; # ((left = ldst-ltmp));
    if  ((ltmp < ldst)); then FillStr -o dtyStr "$midStr" "$dtyStr"; fi
    fi
    printf  "%s[%02d]%s\n" "------------- DataType" "$dtyp" "$dtyStr" >&2; # ~|+|-  1|0 1|0 1|0 un~+-
    local  neg8='0'; if [[ "${Negation[$indx]}" == 1 ]]; then neg8='-';
                   elif [[ "$Extracts{[$indx]}" == 1 ]]; then neg8='+'; fi
    printf  "Extracts=%2s | DataRegx=%2d | DataSrch=%s| ValTyp=%s | DataPost=%s\n" \
            "$neg8" "${DataRegx[$indx]}" "$dsrc" "$vtyp" "$post" >&2;
   #printf  "Extracts=%2d | $dvlStr | DataValu=%s\n" "${Extracts[$indx]}" "$val1" >&2; # VALU_ NUM_ bgn|end SRCH_|SRCH|
    fi # ------------------------- End Datatypes -------------------------------

    printf  "%s\n" "------------- Rcvd Arrays --------------------------------------------" >&2;
    printf  "RxdState=%s| RxdOptns=%2d | RxdParms=%2d | RxdNmOpt='%s' | RcvdName=%s\n" \
            "$rstr" "${RxdOptns[$indx]}" "${RxdParms[$indx]}" "${RxdNmOpt[$indx]}" "${RcvdName[$indx]}" >&2;
    printf  "RxdNuOpt=%2d | RxdCount=%2d | RxdInvld=%2d | RxdIndex=%-3s| RxdValue=%s\n"  \
            "${RxdNuOpt[$indx]}" "${RxdCount[$indx]}" "${RxdInvld[$indx]}" "$rxin" "$rval" >&2;
} # end Disp Item

function  DispItems() { # DispItems # from: -di [Debug function]
    local bgn; local end; local ic;
    if [[ "$TrcItm" =~ ([-]?[0-9]+)("-")?([0-9]+)? ]]; then
         bgn=${BASH_REMATCH[1]}; end=${BASH_REMATCH[3]};
         if   [[ ! "${BASH_REMATCH[2]}" ]];  then  end=$((bgn+1));
         elif [[ ! "$end" ]]; then end=$NumAllItm; else ((end++)); fi
         if   ((bgn < 0)); then bgn=1; end=$NumAllItm; fi
    else bgn=1; end=$NumAllItm; fi  # NB: if end < bgn do none
    local num=$((end-bgn)); if ((num > 0)); then echo >&2; fi
    for ((ic=bgn; ic < end; ic++)); do DispItem $ic; done
    if  ((num > 0)); then
    printf  "%s\n" "----------------------------------------------------------------------" >&2; fi
} # end Disp Items

#################################################################################
# Init All & the Reinit flag is|was needed for whenever getparms calls itself
# repeatedly in order to reinitialize its internal flags & states. This was
# needed when self-tests were a part of getparms, else a previous test would
# affect a subsequent one. This is still needed for the display samples tests.
# A related function is CleanUp which cleans up previous datatype flags.
#################################################################################
function  InitAll() {   # needed for successive calls to getparms (by getparmstest)
    cdebug -s no;       # don't trace this but save state
    # init SymSet & set DF_SYMS, DF_NOSP, & SYMB_..., IReqd  & set OC_ALLS, OC_REQD
    InitCfg; InitHlp; InitSyms; InitItem;
    if ((Reinit == 1)); then # Reset all Array variables
        InitDbg;        # init DbgCfg, DbgEna, DbgStr [NB: allow getparms -d# -x ...]
        InitGbl;        # init DbgPrt, TrcIni, TrcAna, TrcBox, TrcCmd, TrcDel, ...
        # counts
        FatalErrs=0;    # subset of specification errors for which we can't parse cmdline
        NumRxdOpt=0;    # number of elements in NdxRxdOpt array based on received options
        NumBgnPrm=0;    # number of elements in NdxBgnPrm array based on begining params.
        NumEndPrm=0;    # number of elements in NdxEndPrm array based on trailing params.
        NumPrmReq=0;    # number of all require parameters that are in the specification
        NumReqBgn=0;    # number of required bgn parameters that are in the specification
        NumReqEnd=0;    # number of required end parameters that are in the specification
        EndOptPrm=0;    # number of optional end parameters that are in the specification
        NumIndOpt=0;    # number of options that are part of indirect params (short|long)
        NumIndPrm=0;    # number of elements in NdxIndPrm array based on indirect params.
        NumHidPrm=0;    # number of elements in NdxHidPrm array based on mixed hidden prm
        NumShrtOp=0;    # number of elements in Shrt Opts array based on 1-letter options
        NumShipOp=0;    # number of elements in Ship Opts array based on num SHIP options
        Do2LtrOpt=0;    # flag that is set when > 1 TwoLtrOpt is added to the same letter
        NumFunctn=0;    # number of elements received for the function (e.g.: [0] = func)
        NumAllItm=0;    # number of elements in non-Optimal arrays having specified items
        NumReqOpt=0;    # number of required options (includes parms of req'd ind. parms)
        RemReqOpt=0;    # number of the required options that we are still trying to find
        RemReqBgn=0;    # number of the required bgn parm that we're still trying to find
        RemReqEnd=0;    # number of the required end parm that we're still trying to find
        RxdOptPrm=0;    # number of the optional parameter that we have received to date
        NumErrors=0;    # number of elements in the ParseErr array based on parsing error
        NumOption=0;    # number of elements in NdxOption array based on optional options

        # lists
        NdxOfShip=' ';  # list of indices of all SHIP params - set by Set Spec
        NdxReqPrm=' ';  # list of indices of required parms  - set by Init AllItem
        NamHidPrm='';   # list of names of mixed hidden parm - set by Init AllItem
        NdxHidPrm='';   # list of indices of mix hidden parm - set by Init AllItem
        EndBgnRxd='';   # index if unspecified end opts marker rcvd.: 4
        EndOptRxd='';   # index if unspecified end opts marker rcvd.: 14
        RxOptParm='';   # indices of rcvd optional parm: " 3 4"
        ParmNames=' ';  # list of all given parm. names: " m param1 "
        IndOption=' ';  # list of all given indp option: " -f --file "
        IndpNames=' ';  # list of all given indp. names: " ind1 ind2 "
        SrchOptns=' ';  # list of all given optn. names: " -i --file " # excludes SHIPs
        SrchShips=' ';  # list of all given SHIP  names: " -b -d "
        DualOptns=' ';  # list of all given optn. names of dual opts: " c "
        DualNmbrs=' ';  # list of all given optn. value of dual opts: " 99 "
        LongOptns=' ';  # list of all given long optns.: " --in --out "
        RcvdOptns=' ';  # list of all received options : " -i --files "

    fi; cdebug -s on;   # restore previous trace state
} # end Init All

#################################################################################
# hex 2 dec converts hexadecimal to decimal numbers
# NB: this function must not fail just because it's not a hex number
# (unless of course if should be a hex number [i.e.: -s])
# NB: $((16#$val)) below only works to convert to hex value if we've
# already stripped off the prefix (0x|\x|x), which HEX_PATT does for us
#################################################################################
function  Hex2Dec() { local HELP="Hex2Dec {-p}{-s} dec # convert hex (0x|\\x|x) to decimal, -p no prefix";
    local trace=0;   if  [[ "$1" == -t ]]; then trace=1; shift; fi # only for ext'l. use
    local nopre=0;   if  [[ "$1" == -p ]]; then nopre=1; shift; fi # only for ext'l. use
    local shudb=0;   if  [[ "$1" == -s ]]; then shudb=1; shift; fi
    if   [[ "$1" == -h ]]; then echo "$HELP" >&2; return $FAILURE; fi # only ext'l.
    if   [[ !  "$@" ]];  then HEX_NUM=""; return $FAILURE; fi      # can be int'l., so no echo
    local sts=$SUCCESS;  # Note: can't check for -* since negative numbers here will fail
    cdebug on "$trace";  local val="$1";
    if   [[ "$val" =~ $IS_A_HEX ]]; then                           # claim 2b a hex number
         [[ "$val" =~ $HEX_PATT ]]; val="${BASH_REMATCH[2]}"; val=$((16#$val));
    elif (( shudb  == 1)); then                                    # supposed 2b hex number
      if [[ "$val" =~ $ALL__HEX ]]; then                           # and it is a hex number
         [[ "$val" =~ $HEX_PATT ]]; val="${BASH_REMATCH[2]}"; val=$((16#$val));
      else sts=$INV_NUMB; fi                                       # not all hex digits!
    elif ((nopre == 1)); then val=$((16#$val)); fi; HEX_NUM=$val;  # no prefix force convert
    cdebug on "$trace"; return $sts;
}

#################################################################################
# Change Case changes the case of the input string(s) (up to 3)
# the default is to go to lower case (since it is faster), so this is used
# not just for lower case comparisons, but also for case insens. comparisons
#################################################################################
function  ChgCase() { local HELP="ChgCase {-u} val0 {val1 {val2}} # -u uppercase else lowercase";
    local trace=0; if [[ "$1" == -t ]]; then trace=1; shift; fi # only for ext'l. use
    local upper=0; if [[ "$1" == -u ]]; then upper=1; shift; fi
    local PRIZE; local CHARS; local LLEFT; cdebug on "$trace";
    local val0="$1"; local val1="$2"; local val2="$3";
    if  ((upper == 1)); then
        if  [[ "$val0" ]]; then PRIZE="${val0-}"; CHARS=''; LLEFT='';
            while [[ "$PRIZE" =~ [a-z] ]]; do   # match a lower case letter
                CHARS="${BASH_REMATCH[0]}";     # next lower char to change
                LLEFT="${LCAS%%${CHARS}*}";     # done lower case letters
                PRIZE="${PRIZE//${CHARS}/${UCAS:${#LLEFT}:1}}";
            done; val0="$PRIZE";
        fi
        if  [[ "$val1" ]]; then PRIZE="${val1-}"; CHARS=''; LLEFT='';
            while [[ "$PRIZE" =~ [a-z] ]]; do   # match a lower case letter
                CHARS="${BASH_REMATCH[0]}";     # next lower char to change
                LLEFT="${LCAS%%${CHARS}*}";     # done lower case letters
                PRIZE="${PRIZE//${CHARS}/${UCAS:${#LLEFT}:1}}";
            done; val1="$PRIZE";
        fi
        if  [[ "$val2" ]]; then PRIZE="${val2-}"; CHARS=''; LLEFT='';
            while [[ "$PRIZE" =~ [a-z] ]]; do   # match a lower case letter
                CHARS="${BASH_REMATCH[0]}";     # next lower char to change
                LLEFT="${LCAS%%${CHARS}*}";     # done lower case letters
                PRIZE="${PRIZE//${CHARS}/${UCAS:${#LLEFT}:1}}";
            done; val2="$PRIZE";
        fi
    else # go to lower (inludes insens.)
        if  [[ "$val0" ]]; then PRIZE="${val0-}"; CHARS=''; LLEFT='';
            while [[ "$PRIZE" =~ [A-Z] ]]; do   # match uppercase letters
                CHARS="${BASH_REMATCH[0]}";     # next upper char to change
                LLEFT="${UCAS%%${CHARS}*}";     # done upper case letters
                PRIZE="${PRIZE//${CHARS}/${LCAS:${#LLEFT}:1}}";
            done; val0="$PRIZE";
        fi
        if [[ "$val1" ]]; then PRIZE="${val1-}"; CHARS=''; LLEFT='';
            while [[ "$PRIZE" =~ [A-Z] ]]; do   # match uppercase letters
                CHARS="${BASH_REMATCH[0]}";     # next upper char to change
                LLEFT="${UCAS%%${CHARS}*}";     # done upper case letters
                PRIZE="${PRIZE//${CHARS}/${LCAS:${#LLEFT}:1}}";
            done; val1="$PRIZE";
        fi
        if [[ "$val2" ]]; then PRIZE="${val2-}"; CHARS=''; LLEFT='';
            while [[ "$PRIZE" =~ [A-Z] ]]; do   # match uppercase letters
                CHARS="${BASH_REMATCH[0]}";     # next upper char to change
                LLEFT="${UCAS%%${CHARS}*}";     # done upper case letters
                PRIZE="${PRIZE//${CHARS}/${LCAS:${#LLEFT}:1}}";
            done; val2="$PRIZE";
        fi
    fi; VAL0=$val0; VAL1=$val1; VAL2=$val2; cdebug no "$trace"; # global outputs
} # end chg case

#################################################################################
# is number notes - saves extracted no. in global XTRCNUM
# 1. hex formats (any case with HH digits): HH, xHH, 0xHH
# 2. for hex integers no negative|positive sign is allowed
# 3. -i* for integer, no i or with n a number ('.' allowed)
# 4. note that 0.0 is not an integer, it's a positive number
# 5. prefix & postfix characters can be required, e.g.: $23.00
# 6. note that '+' is allowed for all positive & pos|neg items
# 7. -x0|1: regex (0) or plain (1) match with surrounding strings
# NB: even though is number allows -n-|-n+|-i-|-i+ as inputs externally
# (meaning: neg|pos number|integer, getparms can't use these options for
# they collide with surrounding string opts (+-~) that immediately follow
#################################################################################
function  is_number_help() { # is_number_help {badopt}
    echo >&2;  if [[ "$1" ]] && [[ "$1" != "-h" ]]; then echo "bad parms:'$1'" >&2;
    else local shrt="$VAR_STYP_NOSP"; local long="$STR_STYP_DISP";
    echo "is_number num {-t} -v[$shrt] |" >&2;
    echo "  -s[$long]}{-re}{-rm|-neg8}{-w}{-pre s}{-mid s}{-anx s}{-x|-b|-B|-#|-i{+|-|p|n}|-{n}{+|-|p|n}} " >&2;
    echo "  -re regex, -rm|neg8 rm|rtn mid, -w whole (else partial), -x hex (case insens.): HH|xHH|0xHH,"   >&2;
    echo "  -b bool, -B 0/1, -# uints, -i int, else num, +|p pos., -|n neg.; if -pre|-mid|-anx is set,"     >&2;
    echo "     this looks for specific strings: preceding|in midst|annexing (trailing) number pattern "     >&2;
    stroptions_help; # shared between is_number & is_string
    echo "   Note: to extract numbers from surrounded text use -rm & -s" >&2;
    echo >&2; fi
}
function  is_number() { # num {-t}{-s{~|+|-}}{-re}{-rm|neg8} {-x|-b|-B|-#|-i{+|-|p|n}|-{n}{+|-|p|n}}{-w} {-pre s}{-mid s}{-anx s} # -re regex, -rm|-neg rm|negate mid, -w whole (else part), -x hex (HH|xHH|0xHH case ins), -b=bool (101...), -B=0/1 (bit), -# uint, -i int, else num, & where: +|p pos, -|n neg; if -pre|mid|anx look for: preced|midst|annex(trail num
    local popt="";  local dopre=0; local opt;    local cmp=""; local quit=0;
    local mopt="";  local domid=0; local num;    local bad=""; XTRCNUM=""; # set global
    local aopt="";  local doanx=0; local arr=0;  local sts=$INV_NUMB;
    # set defaults for the receive options (pre, mid, anx are done above)
    local styp="";  local vtyp=""; local trac=0; local regx=0;
    local remv=0;   local neg8=0;  local whol=0;
    local amsk="";  local nmsk="[+-]?[0-9]*[.]?[0-9]+"; # pos.|neg. num (-n|-) [default]

    if [ $# -eq 0 ]; then is_number_help; return $sts; fi
    local num="$1";  if [[ ! "$num" ]]; then return $sts; # must do quietly
    elif [[ "$num" == -h ]] || [[ "$num" == -'?' ]]; then is_number_help; return $INV_NUMB; fi
    shift; local orig="$num";
    while [[ "$1" == -* ]]; do opt="$1"; shift;
    case "$opt" in
        -t)         trac=1;;
        -s*)        styp=$opt;;
        -v*)        vtyp=$opt;;
        -re)        regx=1;;
        -rm)        remv=1;;
        -neg8)      neg8=1;;
        -w)         whol=1;;
        -pre)       popt=$1; shift; if [[ "$popt" ]]; then dopre=1; fi;; # may be empty
        -mid)       mopt=$1; shift; if [[ "$mopt" ]]; then domid=1; fi;; # may be empty
        -anx)       aopt=$1; shift; if [[ "$aopt" ]]; then doanx=1; fi;; # may be empty
        # following are the specific number types
        -B)         nmsk="[0-1]";;                  # binary value
        -b)         nmsk="[0-1]*";;                 # Boolean int
        -x)         nmsk="[0]?[xX]?[0-9a-fA-F]+";;  # {0}xHH|{0}HH hexint
        -i)         nmsk="[+-]?[0-9]+";;            # any  integer
        -i+|-ip)    nmsk="[+]?[0-9]+";;             # pos. integer
        -i-|-in)    nmsk="-[0-9]+";;                # neg. integer
       "-#")        nmsk="[0-9]+";;                 # unsigned int
        -n)         nmsk="[+-]?[0-9]*[.]?[0-9]+";   # pos.|neg. num (-n|-) [default]
                    amsk="[+-]?[0-9]+[.]";;
        -n-|-nn|--) nmsk="-[0-9]*[.]?[0-9]+";       # neg. number
                    amsk="-[0-9]+[.]";;
        -n+|-np|-+) nmsk="[+]?[0-9]*[.]?[0-9]+";    # pos. number
                    amsk="[+]?[0-9]+[.]";;
        -*)         quit=1; bad+=" $opt";;
    esac; done # NB: if externals not set bgnsecs or lstsecs, use present time
    if  ((quit != 0)); then is_number_help "$bad"; return $INV_NUMB; fi # NB: can't do -* or else neg. #s fail
    if [[ "$styp" ]] && [[ "$vtyp" ]]; then is_number_help "-s -v"; return $INV_NUMB; fi
    if ! cdebug on "$trac"; # NB: trace option takes precedence over debug flag
    then DBG_TRC  11 "$orig" "is_number: styp|num:$styp|'$str', pre:'$popt', mid:'$mopt', anx:'$aopt'"; fi

    local ans=$INV_GOOD; # next get any string options
    if [[ "$styp" ]]; then GetCompare "$styp"; ans=$?; cmp=$STR_CMP; bad=$STR_BAD;
        if   [[ "$bad" ]] || ((ans != INV_GOOD)); then is_number_help "$bad";
            if ! cdebug no "$trac"; then DBG_TRC -x 11 "$orig" ""; fi; return $ans;
        elif [[ "$cmp" ]]; then shopt -u nocasematch;   # only do if needed
            # turn off any nocasematch setting (-s) so we  match the case
            if   [[ "$num" =~ [$cmp]*($nmsk)[$cmp]* ]]; # take what we can find
            then XTRCNUM="${BASH_REMATCH[1]}"; if ((neg8 == 1));
            then XTRCNUM="${num//$XTRCNUM/}";  fi
            elif [[ "$amsk" ]] && [[ "$num" =~ [$cmp]*($amsk)[$cmp]* ]]; # alt. num fmt: 50.
            then XTRCNUM="${BASH_REMATCH[1]}"; if ((neg8 == 1));
            then XTRCNUM="${num//$XTRCNUM/}";  fi
            else ans=$INV_STRG; fi
        fi
    fi

    # next check if we are looking for surrounding text and put it aside
    if ((dopre == 1)) || ((domid == 1)) || ((doanx == 1)); then # rm pre, mid, annex if given
        local got=0; XTRCNUM=""; # assume if pre, anx, mid that we are extracting
        if  ((regx == 1)); then local tmp; # doing regex matching
            if   ((dopre == 1)) || ((doanx == 1)); then if ((whol == 1));
                 then if [[ ! "$num" =~ ^$popt(.*)$aopt$ ]]; then num=""; fi # no change if got line
                 else if [[   "$num" =~  $popt(.*)$aopt  ]]; then tmp="${BASH_REMATCH[1]}";
                      if ((neg8 == 1)); then num=${num/$tmp/}; else num=$tmp; fi
                 else num=""; fi; fi
            elif ((domid == 1)); then local tmp; if ((whol == 1)); # search anywhere
                 then if [[ ! "$num" =~ ^$mopt$ ]]; then num=""; fi # no change if got, whole line
                 else if [[   "$num" =~ ($mopt) ]]; then tmp="${BASH_REMATCH[1]}";
                      if ((neg8 == 1)); then num=${num/$tmp/}; else num=$tmp; fi
                 else num=""; fi; fi
            fi
        else if  ((dopre == 1)) || ((doanx == 1)); then if ((whol == 1)); # doing plain matching
                 then if [[ "$num" !=  $popt*$aopt  ]]; then num=""; fi   # no change if got line
                 else if [[ "$num" != *$popt*$aopt* ]]; then num=""; else got=1; fi; fi
                 if   ((got == 1)); then
                      if [[ "$popt" ]]; then num="${num#*$popt}"; fi # rm short pre at bgn
                      if [[ "$aopt" ]]; then num="${num%$aopt*}"; fi # rm short anx at end
                 fi
            elif ((domid == 1)); then if ((whol == 1));
                 then if [[ "$num" !=  $mopt  ]]; then num="";  fi   # fine as is (whole line)
                 else if [[ "$num" != *$mopt* ]]; then num="";  else
                    if ((remv == 1)) && ((neg8 == 0)); then arr=1;
                         num="${num//$mopt/ }";       # replace all with space
                    else num="${num%$mopt*}$mopt";    # remove short after mopt at end
                         num="$mopt${num#*$mopt}"; fi # remove short befor mopt at bgn
                    fi
                 fi
            fi
        fi
    elif [[ "$styp" ]]; then num="$XTRCNUM"; fi # may have spaces here also

    local sav=""; # now we're ready to check numeric part only
    if  [[ "$num" ]]; then local val;
        for val in $num; do  # arrayize (by spaces)
            if   [[ "$val" =~ ^${nmsk}$ ]]; then sts=$INV_GOOD;
                 if [[ "$sav" ]]; then sav+=" $val"; else sav="$val"; fi
            elif [[ "$amsk" ]] && [[ "$val" =~ ^${amsk}$ ]]; then sts=$INV_GOOD; # alt. num fmt: 50.
                 if [[ "$sav" ]]; then sav+=" $val"; else sav="$val"; fi
            fi
        done
    fi; XTRCNUM="$sav"; # Note: purposely discarded leading & trailing space(s)
    if ! cdebug no "$trac"; then DBG_TRC -x 11 "$orig" ""; fi
    return $sts;
} # end is number : returns INV_GOOD|INV_NUMB

#################################################################################
# Get Ship Flags: checks if a recognized SHIP flag was supplied in HELP string
#           descript.  opt         0    +    -    1    1+    1-     ,      2
#           ----------------------------------------------------------------
#           allowall: -d=      => -d  -d+  -d-  -d#  -d#+  -d#-  -d#,#  -d#-#
#           havempty: -d=0     => -d
#           end_plus: -d=+     =>     -d+
#           endminus: -d=-     =>          -d-
#           endplmin: -d=+-    =>     -d+  -d-
#           numbered: -d=1     =>               -d#
#           auto-num: -d=.     =>               -d#
#           enumer8d: -d=,     =>                                -d#,#
#           isranged: -d=2     =>                                       -d#-#
#                     -d=0+-   => -d  -d+  -d-
#                     -d=1+-   =>     -d+  -d-  -d#  -d#+  -d#-
#                     -d=,+-   =>     -d+  -d-                   -d#,#
#                     -d=2+-   =>     -d+  -d-                          -d#-#
#                     -d=,1    =>               -d#              -d#,#
#                     -d=,2    =>                                -d#,#  -d#-#
#                     -d=12    =>               -d#                     -d#-#
#                     -d=12,   =>               -d#              -d#,#  -d#-#
#################################################################################
function  GetShipFlags() { # $indx sopt
    STR_BAD=''; # set global
    local ic; local indx=$1; local sopt=$2; shift; local sts=$SUCCESS;
    local flag=0; local char=''; local ones=''; local enum=''; local rang='';
    DBG_TRC  0x19 "$indx" "ShipFlags: indx:$indx, sopt:$sopt";
    if   [[ "$sopt" == *"$SYMB_MORE"* ]]; then sts=$FAILURE; # if a more item (illegal)
    # NB: the order of flags is important: if +|- rxd b4|after digits (i.e.: 12, <=> ONE|TWO|COM)
    elif [[ "$sopt" ]]; then local dig=0; local bit; local ch; local nu; local pm; local got; local TMP;
        while ((${#sopt} > 0)); do nu="${sopt:0:1}"; got=0; local list=" 1 2 3 4 5 6 7"; # take lead char
            for ic in $list; do # < SHIP_END (don't include SHIP_PLS & SHIP_MNS)
                ch=${ShipOpt[$ic]}; #TMP="****[$ic]****";
                if  [[ "$nu" == "$ch" ]]; then got=1;  bit=${ShipMask[ic]}; pm=${ShipPM[$ic]};
                    # check if +|- rxd b4 digit (12,: ONE|TWO|COM) iff digit later
                    # else the +|- stays as an ending symbol
                    if  ((dig == 0)) && ((pm == 1)) && [[ "$sopt" =~ [,12] ]]; then
                        if   ((bit == SHIP_PLE)); then bit=${ShipMask[$SHIP_PLS]};
                        elif ((bit == SHIP_MNE)); then bit=${ShipMask[$SHIP_MNS]}; fi
                    fi; flag=$((flag | bit)); # Or in bit & see if digit set
                    #printf -v TMP "0x%X" "$SHIP_BIT_DIG"; # TMP=$((flag & SHIP_BIT_DIG));
                    dig=$(((flag & SHIP_BIT_DIG) != 0));   # set digit flag if '1|2|,'
                    # now remove ch. & check if remaining string is empty
                    if  ((pm == 0)); then sopt=${sopt//$ch}; # can delete all
                         list=${list/ $ic};   # del this index from ch. list
                    else sopt="${sopt:1}"; fi # can only del this this 1 ch.
                fi
            done; if ((got == 0)); then STR_BAD+="$nu"; sopt="${sopt:1}"; fi
        done; if [[ "$STR_BAD" ]]; then sts=$UNFOUND; else local bit;
            # handle minus-plus checks before numbers
            local  mpb=$((flag & SHIP_BIT_MPS)); local pls="";
            if   ((mpb == SHIP_BIT_MPS));        then  pls="[+-]?";  char="+-";
            elif ((mpb == ShipMask[SHIP_MNS]));  then  pls="[-]?";   char="-";
            elif ((mpb == ShipMask[SHIP_PLS]));  then  pls="[+]?";   char="+"; fi

            # handle minus-plus checks at the ending
            local  mpe=$((flag & SHIP_BIT_MPE)); local end=""; local estr="";
            if   ((mpe == SHIP_BIT_MPE));        then  end="[+-]?";  estr="+-";
            elif ((mpe == ShipMask[SHIP_MNE]));  then  end="[-]?";   estr="-";
            elif ((mpe == ShipMask[SHIP_PLE]));  then  end="[+]?";   estr="+"; fi

            # check for remaining flags
            bit=${ShipMask[SHIP_DOT]}; local dot=$(((flag & bit) == bit));
            bit=${ShipMask[SHIP_COM]}; local enu=$(((flag & bit) == bit));
            bit=${ShipMask[SHIP_NON]}; local non=$(((flag & bit) == bit));
            bit=${ShipMask[SHIP_ONE]}; local num=$(((flag & bit) == bit));
            bit=${ShipMask[SHIP_TWO]}; local rng=$(((flag & bit) == bit));
            local one=$num;

            # form char string here (to ensure no dupes)
            if ((dot == 1)); then char+="."; fi # =${ShipOpt[$SHIP_DOT]};
            if ((enu == 1)); then char+=","; fi # =${ShipOpt[$SHIP_COM]};
            if ((non == 1)); then char+="0"; fi # =${ShipOpt[$SHIP_NON]};
            if ((num == 1)); then char+="1"; fi # =${ShipOpt[$SHIP_ONE]};
            if ((rng == 1)); then char+="2"; fi # =${ShipOpt[$SHIP_TWO]};
            char+="$estr";   # add any end string to the end of char list

            # check for any flag which should auto-enable numbers
            local dec="";     if ((dot == 1)); then num=1; dec="$SIP_DECP";
                              if ((dig == 0)); then one=1; fi # auto-enable
            elif ((rng == 1)) || ((enu == 1)); then num=1; fi
            local qty="";     if ((num == 1)); then qty="$SIP_UINT$dec"; fi
            # don't add to char list because we are not doing '1'
           #if   ((one == 0)) && ((num == 1)); then char="1$char"; fi

            if   ((rng != 0)); # set range pattern check: exactly 2 num reqd
            then rang="^$pls$qty[-]$pls$qty$"; fi
            #SIP_RANG="^[+-]?(0|[1-9][0-9]*([.][0-9]+)?[-][+-]?(0|[1-9][0-9]*)([.][0-9]+)?)$";
            if   ((enu == 1)); # set enum. pattern check: 1+ csv nums reqd
            then enum="^$pls$qty([,]$pls$qty)+$"; fi
            #SIP_ENUM="^[+-]?(0|[1-9][0-9]*([.][0-9]+)?([,][+-]?(0|[1-9][0-9]*)([.][0-9]+)?)+$"

            # set ones search only if none | one set
            if   ((non == 1)) && ((one == 1)); then ones="^($pls$qty)?$end$";
            elif ((non == 1)) && [[ "$end" ]]; then ones="^$end$";
            elif ((one == 1)); then ones="^$pls$qty$end$";
            elif [[ "$end" ]]; then ones="^$end$"; fi
        fi
    else char="$SHIPCH";   ones="$SIP_ONES"; flag=$SHIP_BIT_ALL;
         enum="$SIP_ENUM"; rang="$SIP_RANG"; # these include: ^...$
    fi

    # set derived SHIP opts (even if fail)
    ShipBits[$indx]=$flag; # SHIP bit flags
    ShipChar[$indx]=$char; # SHIP character
    ShipOnes[$indx]=$ones; # SHIP src monos
    ShipEnum[$indx]=$enum; # SHIP src enums
    ShipRang[$indx]=$rang; # SHIP src range
    DBG_TRC -x 0x19 "$indx" ""; return $sts;
} # end Get ShipFlags

#############################################################################
# ClrDataType is needed when getparmtest iteratively calls getparms to clear
# out all previously set array values. It is called by CleanUp for all items.
#############################################################################
function  ClrDataType() { # ClrDataType indx
    local ic=$1;
    DataType[$ic]="$DATA_IS_NONE"; # store data type to check
    DataSrch[$ic]="$SRCH_ALL";     # store data string locale
    ValuType[$ic]="$VALU_NONE";    # store enum flag to check
    NmbrType[$ic]="$NUM_NAN";      # store enum of number type
    DataPost[$ic]="";              # store str postfix letters
    DataVal1[$ic]="";              # store data valu to check
    DataVal2[$ic]="";              # store data valu to check
    DataRegx[$ic]=0;               # store data regex matches
    Extracts[$ic]=0;               # store if extracting strs
    Negation[$ic]=0;               # store if doing negations
} # end Clr DataType

function  CleanUp() { # CleanUp # add all cleanup functions here
    local ic; for ((ic=0; ic < NumAllItm; ic++)); do
        ClrDataType $ic; # reset all Datatype fields
    done;
}

#############################################################################
# Get Data Type: checks if a recognized data type was supplied in HELP string;
# str begins with SYMB TYPE (~) & is followed by specific value (no leading -)
#############################################################################
function  GetDataType() { # base ic "str" {test} # get data type & value & stores in arrays
    local base=$1;     local indx="$2";  local orig="$3";  local test="$4"; shift 4;
    local val1="";     local valt=$VALU_NONE;  local dtyp=$DATA_IS_NONE;
    local val2="";     local supt=$BIT_NONE;   local regx=0;    local sbhex="";
    local post="";     local sts=$SUCCESS;     local numt=$NUM_NAN;
    local bval="";     local srch=$SRCH_ALL;   local n=${#str}; # n for dequoting string
    local mtch="";     local xtrc=0;           local neg8=0;    local styp="";
    local doloc=$((CfgSet[CF_RGXLOC] != 1)); # NB: invert bool value
    local str="$orig"; local plus=0;

    if  [[ "$test" ]]; then test="-p"; fi    # for matchdata (test function)
    if  ((n > 1)); then local bgn="${str:0:1}"; local end="${str:$n-1:1}";
        if ( [[ "$bgn" == "'" ]] || [[ "$bgn" == '"' ]] ) && [[ "$bgn" == "$end" ]];
        then str="${str:1:$n-2}"; fi         # now str de-quoted
    fi; DBG_TRC  0x27 "$ic" "GetDataType: indx:$indx, str:'$str'";
    if  [[ "$str" != "$SYMB_TYPE" ]] && [[ "$str" == "$SYMB_TYPE"* ]]; then
        local getval=0; local getstr=0; local getnum=0;
        case "$str" in # Don't use DFLT REGX at end of case value, else get wrong error (INV FIND)
         # following are IP addresses: ip4d, ip4h, ip6d, ip6h, ip4, ip6, ipd, iph, ipg
        "${DataOpts[$DATA_IP4_DEC]}")                dtyp=$DATA_IP4_DEC;;  # ip4d: IP4 decimal
        "${DataOpts[$DATA_IP4_HEX]}")                dtyp=$DATA_IP4_HEX;;  # ip4h: IP4 hexadec
        "${DataOpts[$DATA_IP6_DEC]}")                dtyp=$DATA_IP6_DEC;;  # ip6d: IP6 decimal
        "${DataOpts[$DATA_IP6_HEX]}")                dtyp=$DATA_IP6_HEX;;  # ip6h: IP6 hexadec
        "${DataOpts[$DATA_IP4_NUM]}")                dtyp=$DATA_IP4_NUM;;  # ip4 : IP4 numeral
        "${DataOpts[$DATA_IP6_NUM]}")                dtyp=$DATA_IP6_NUM;;  # ip6 : IP6 numeral
        "${DataOpts[$DATA_IPN_DEC]}")                dtyp=$DATA_IPN_DEC;;  # iph : IPn decimal
        "${DataOpts[$DATA_IPN_HEX]}")                dtyp=$DATA_IPN_HEX;;  # ipd : IPn hexadec
        "${DataOpts[$DATA_IPN_NUM]}")                dtyp=$DATA_IPN_NUM;;  # ipg : IPn generic
        "${DataOpts[$DATA_MAC_HEX]}")                dtyp=$DATA_MAC_HEX;;  # mac : Mac hex addr.
        "${DataOpts[$DATA_E_MAILS]}")                dtyp=$DATA_E_MAILS;;  # e   : E-mail addr.
        "${DataOpts[$DATA_ANY_URL]}")                dtyp=$DATA_ANY_URL;;  # u   : URL|website
         # following are those numbers/integers which have no extra data
        "${DataOpts[$DATA_NUM_POS]}") numt=$NUM_DEC; dtyp=$DATA_NUM_POS;;  # np  : positive num
        "${DataOpts[$DATA_NUM_NEG]}") numt=$NUM_DEC; dtyp=$DATA_NUM_NEG;;  # nn  : negative num
        "${DataOpts[$DATA_ANUMBER]}") numt=$NUM_DEC; dtyp=$DATA_ANUMBER;;  # n   : generic  num
        "${DataOpts[$DATA_INT_POS]}") numt=$NUM_INT; dtyp=$DATA_INT_POS;;  # ip  : positive int
        "${DataOpts[$DATA_INT_NEG]}") numt=$NUM_INT; dtyp=$DATA_INT_NEG;;  # in  : negative int
        "${DataOpts[$DATA_INTEGER]}") numt=$NUM_INT; dtyp=$DATA_INTEGER;;  # i   : generic  int
        "${DataOpts[$DATA_UNS_INT]}") numt=$NUM_INT; dtyp=$DATA_UNS_INT;;  # #   : unsigned int
        "${DataOpts[$DATA_ZEROONE]}") numt=$NUM_INT; dtyp=$DATA_ZEROONE;;  # B   : zero or one (0|1)
        "${DataOpts[$DATA_BOOLNUM]}") numt=$NUM_INT; dtyp=$DATA_BOOLNUM;;  # b   : boolean int (0110)
        "${DataOpts[$DATA_HEX_NUM]}") numt=$NUM_HEX; dtyp=$DATA_HEX_NUM; sbhex="-s";;  # h   : hex int
        "${DataOpts[$DATA_PERCENT]}")   val1=0;      dtyp=$DATA_PERCENT;   # %   : percent num (0.0-100.0)
                                        val2=100;    valt=$VALU_RANG;      # del ~% so no confusion w/ regex symbol (%)
                    str=${str/${DataOpts[$DATA_PERCENT]}}; numt=$NUM_DEC;; # allow decimal: 3.5%
         # following are numbers|integers, supporting text before and/or after & ranges|enums
        "${DataOpts[$DATA_NUM_POS]}"*)  getnum=1;    dtyp=$DATA_NUM_POS;   # np* : positive num
                                                     numt=$NUM_DEC;;
        "${DataOpts[$DATA_NUM_NEG]}"*)  getnum=1;    dtyp=$DATA_NUM_NEG;   # nn* : negative num
                                                     numt=$NUM_DEC;;
        "${DataOpts[$DATA_ANUMBER]}"*)  getnum=1;    dtyp=$DATA_ANUMBER;   # n*  : generic  num
                                                     numt=$NUM_DEC;;
        "${DataOpts[$DATA_INT_POS]}"*)  getnum=1;    dtyp=$DATA_INT_POS;   # ip* : positive int
                                                     numt=$NUM_INT;;
        "${DataOpts[$DATA_INT_NEG]}"*)  getnum=1;    dtyp=$DATA_INT_NEG;   # in* : negative int
                                                     numt=$NUM_INT;;
        "${DataOpts[$DATA_INTEGER]}"*)  getnum=1;    dtyp=$DATA_INTEGER;   # i*  : generic  int
                                                     numt=$NUM_INT;;
        "${DataOpts[$DATA_UNS_INT]}"*)  getnum=1;    dtyp=$DATA_UNS_INT;   # #*  : unsigned int
                                                     numt=$NUM_INT;;
        "${DataOpts[$DATA_ZEROONE]}"*)  getnum=1;    dtyp=$DATA_ZEROONE;   # B   : zero or one (0|1)
                                                     numt=$NUM_INT;;
        "${DataOpts[$DATA_BOOLNUM]}"*)  getnum=1;    dtyp=$DATA_BOOLNUM;   # b*  : boolean int (0110)
                                                     numt=$NUM_INT;;
        "${DataOpts[$DATA_HEX_NUM]}"*)  getnum=1;    dtyp=$DATA_HEX_NUM;   # h*  : hexadecimal int
                                        sbhex="-s";  numt=$NUM_HEX;;
        "${DataOpts[$DATA_PERCENT]}"*)               dtyp=$DATA_PERCENT;   # %*  : percent (0-n)
                                     str="${str:2}"; numt=$NUM_INT;        # next num|int part
                         if   [[ "$str" =~ ([+-]?[0-9]*[.]?[0-9]+[.]?)([-][+-]?[0-9]*[.]?[0-9]+[.]?)? ]]; then
                         getnum=1;  val1=${BASH_REMATCH[1]}; val2=${BASH_REMATCH[2]}; str="${str/$val1$val2}";
                         if   [[ "$val1" =~ "." ]] || [[ "$val2" =~ "." ]]; then numt=$NUM_DEC; fi
                         if   [[ "$val1" == "+"* ]]; then val1=${val1:1}; fi # rm leading '+'
                         if   [[ "$val2" ]]; then val2="${val2:1}";          # rm leading '-'
                              if [[ "$val2" == "+"* ]]; then val2=${val2:1}; fi # rm leading '+'
                         elif [[ "$val1" == "-"* ]]; then val2=0; else val2=$val1; val1=0; fi
                         else  sts=$INV_FIND; fi;;   # allow decimal: 3.5%
         # following are string types with and without values
        "${DataOpts[$DATA_STR_GEN]}")                dtyp=$DATA_STR_GEN;;  # s   : a generic string
        "${DataOpts[$DATA_STR_GEN]}"*)  getstr=1;    dtyp=$DATA_STR_GEN;;  # s*  : a generic string
        "${DataOpts[$DATA_VAR_NAM]}")                dtyp=$DATA_VAR_NAM;;  # v   : any variable name
        "${DataOpts[$DATA_VAR_NAM]}"*)  getstr=1;    dtyp=$DATA_VAR_NAM;;  # v*  : any variable name
         # following are file/dir types
        "${DataOpts[$DATA_PATH_RW]}")                dtyp=$DATA_PATH_RW;;  # prw : dir|file read & write
        "${DataOpts[$DATA_PATH_WR]}")                dtyp=$DATA_PATH_WR;;  # pw  : dir|file writable
        "${DataOpts[$DATA_PATH_RD]}")                dtyp=$DATA_PATH_RD;;  # pr  : dir|file readable
        "${DataOpts[$DATA_PATH_UP]}")                dtyp=$DATA_PATH_UP;;  # pu  : dir|file parent exists
        "${DataOpts[$DATA_PATH_NO]}")                dtyp=$DATA_PATH_NO;;  # pn  : dir|file not exist
        "${DataOpts[$DATA_PATH_IS]}")                dtyp=$DATA_PATH_IS;;  # p   : does dir|file exist
        "${DataOpts[$DATA_DIRS_RW]}")                dtyp=$DATA_DIRS_RW;;  # drw : dir read & write
        "${DataOpts[$DATA_DIRS_WR]}")                dtyp=$DATA_DIRS_WR;;  # dw  : dir writable
        "${DataOpts[$DATA_DIRS_RD]}")                dtyp=$DATA_DIRS_RD;;  # dr  : dir readable
        "${DataOpts[$DATA_DIRS_UP]}")                dtyp=$DATA_DIRS_UP;;  # du  : dir parent exists
        "${DataOpts[$DATA_DIRS_NO]}")                dtyp=$DATA_DIRS_NO;;  # dn  : dir not exist
        "${DataOpts[$DATA_DIRS_IS]}")                dtyp=$DATA_DIRS_IS;;  # d   : does dir exist
        "${DataOpts[$DATA_FIL_RWX]}")                dtyp=$DATA_FIL_RWX;;  # frwx: file rd+write+exe
        "${DataOpts[$DATA_FILE_WX]}")                dtyp=$DATA_FILE_WX;;  # fwx : file write & exe
        "${DataOpts[$DATA_FILE_RX]}")                dtyp=$DATA_FILE_RX;;  # frx : file read and exe
        "${DataOpts[$DATA_FILE_EX]}")                dtyp=$DATA_FILE_EX;;  # fx  : file isexecutable
        "${DataOpts[$DATA_FILE_RW]}")                dtyp=$DATA_FILE_RW;;  # frw : file read & write
        "${DataOpts[$DATA_FILE_WR]}")                dtyp=$DATA_FILE_WR;;  # fw  : file writable
        "${DataOpts[$DATA_FILE_RD]}")                dtyp=$DATA_FILE_RD;;  # fr  : file readable
        "${DataOpts[$DATA_FILE_UP]}")                dtyp=$DATA_FILE_UP;;  # fu  : file path exists
        "${DataOpts[$DATA_FILE_NO]}")                dtyp=$DATA_FILE_NO;;  # fn  : file not exist
        "${DataOpts[$DATA_FILE_IS]}")                dtyp=$DATA_FILE_IS;;  # f   : file exists
         # following are file/dir types w/ values
        "${DataOpts[$DATA_PATH_RW]}"*)  getstr=1;    dtyp=$DATA_PATH_RW;;  # prw*: dir|file read & write
        "${DataOpts[$DATA_PATH_WR]}"*)  getstr=1;    dtyp=$DATA_PATH_WR;;  # pw* : dir|file writable
        "${DataOpts[$DATA_PATH_RD]}"*)  getstr=1;    dtyp=$DATA_PATH_RD;;  # pr* : dir|file readable
        "${DataOpts[$DATA_PATH_UP]}"*)  getstr=1;    dtyp=$DATA_PATH_UP;;  # pu* : dir|file parent exists
        "${DataOpts[$DATA_PATH_NO]}"*)  getstr=1;    dtyp=$DATA_PATH_NO;;  # pn* : dir|file not exist
        "${DataOpts[$DATA_PATH_IS]}"*)  getstr=1;    dtyp=$DATA_PATH_IS;;  # p*  : does dir|file exist
        "${DataOpts[$DATA_DIRS_RW]}"*)  getstr=1;    dtyp=$DATA_DIRS_RW;;  # drw*: dir read & write
        "${DataOpts[$DATA_DIRS_WR]}"*)  getstr=1;    dtyp=$DATA_DIRS_WR;;  # dw* : dir writable
        "${DataOpts[$DATA_DIRS_RD]}"*)  getstr=1;    dtyp=$DATA_DIRS_RD;;  # dr* : dir readable
        "${DataOpts[$DATA_DIRS_UP]}"*)  getstr=1;    dtyp=$DATA_DIRS_UP;;  # du* : dir parent exists
        "${DataOpts[$DATA_DIRS_NO]}"*)  getstr=1;    dtyp=$DATA_DIRS_NO;;  # dn* : dir not exist
        "${DataOpts[$DATA_DIRS_IS]}"*)  getstr=1;    dtyp=$DATA_DIRS_IS;;  # d*  : does dir exist
        "${DataOpts[$DATA_FIL_RWX]}"*)  getstr=1;    dtyp=$DATA_FIL_RWX;;  # frwx: file rd+write+exe
        "${DataOpts[$DATA_FILE_WX]}"*)  getstr=1;    dtyp=$DATA_FILE_WX;;  # fwx : file write & exe
        "${DataOpts[$DATA_FILE_RX]}"*)  getstr=1;    dtyp=$DATA_FILE_RX;;  # frx : file read and exe
        "${DataOpts[$DATA_FILE_EX]}"*)  getstr=1;    dtyp=$DATA_FILE_EX;;  # fx  : file isexecutable
        "${DataOpts[$DATA_FILE_RW]}"*)  getstr=1;    dtyp=$DATA_FILE_RW;;  # frw*: file read & write
        "${DataOpts[$DATA_FILE_WR]}"*)  getstr=1;    dtyp=$DATA_FILE_WR;;  # fw* : file writable
        "${DataOpts[$DATA_FILE_RD]}"*)  getstr=1;    dtyp=$DATA_FILE_RD;;  # fr* : file readable
        "${DataOpts[$DATA_FILE_UP]}"*)  getstr=1;    dtyp=$DATA_FILE_UP;;  # fu* : file path exists
        "${DataOpts[$DATA_FILE_NO]}"*)  getstr=1;    dtyp=$DATA_FILE_NO;;  # fn* : file not exist
        "${DataOpts[$DATA_FILE_IS]}"*)  getstr=1;    dtyp=$DATA_FILE_IS;;  # f*  : file exists
         # is it a signed bare number (i.e. default percent) or an unknown datatype (i.e. an error)
        "${SYMB_TYPE}"*) str="${str:1}";  # rm leading '~'; allow int|num % based on value given
                         if   [[ "$str" =~ ([+-]?[0-9]*[.]?[0-9]+[.]?)([-][+-]?[0-9]*[.]?[0-9]+[.]?)? ]]; then
                         numt=$NUM_INT; getnum=1;    dtyp=$DATA_PERCENT;
                         val1=${BASH_REMATCH[1]}; val2=${BASH_REMATCH[2]}; str="${str/$val1$val2}";
                         if   [[ "$val1" =~ "." ]] || [[ "$val2" =~ "." ]]; then numt=$NUM_DEC; fi
                         if   [[ "$val1" == "+"* ]]; then val1=${val1:1}; fi    # rm leading '+'
                         if   [[ "$val2" ]]; then val2="${val2:1}";             # rm leading '-'
                              if [[ "$val2" == "+"* ]]; then val2=${val2:1}; fi # rm leading '+'
                         elif [[ "$val1" == "-"* ]]; then val2=0; else val2=$val1; val1=0; fi
                         else  sts=$INV_FIND; fi;;        # allow decimal: 3.5%
        *) ;; # default: DATA_IS_NONE (not an error)
        esac; local rmv; local letr;  local chs;          # end case str

        local vch="$SYMB_REGX"; supt=${DataSupt[$dtyp]};  # set defaults: vch='%'; xch='@';
        local xch="$SYMB_PLAN"; local fail=0;             # get supported types for this dtyp
        # NB: xtrc is set here whenever the separator char. is doubled (extracting cond.)
        # but regx is set here & below depending on if we're processing the REGX char (%)
        if  ((getstr == 1)) || ((getnum == 1)); then      # get prefixes that limit item type
            if   HasUnescape    "$vch" "$str"; then       # have unescaped separator?
                 GetUnescape -u "$vch" "$str";            # this is guaranteed to work
                 mtch="$UNESCAF"; chs="$vch";             # get text after 1st separator
                 if [[ "${mtch:0:1}" == "$vch" ]];        # did we receive 2nd separator?
                 then xtrc=1; mtch=${mtch:1}; chs="$vch$vch"; # remove the 2nd separator
                 if [[ "${mtch:0:1}" == "$vch" ]];        # did we receive 3rd separator?
                 then neg8=1; mtch=${mtch:1}; chs="$chs$vch"; # remove the 3rd separator
                 fi; fi; if [[ "$mtch" ]]; then getval=1; fi  # if something remains after sep.
                 post=${str%%"$chs"*}; regx=1;            # remove from chs on [regx matching]
            elif HasUnescape    "$xch" "$str"; then       # have unescaped separator?
                 GetUnescape -u "$xch" "$str";            # this is guaranteed to work
                 mtch="$UNESCAF"; chs="$xch";             # get text after 1st separator
                 if [[ "${mtch:0:1}" == "$xch" ]];        # did we receive 2nd separator?
                 then xtrc=1; mtch=${mtch:1}; chs="$xch$xch"; # remove the 2nd separator
                 if [[ "${mtch:0:1}" == "$xch" ]];        # did we receive 3rd separator?
                 then neg8=1; mtch=${mtch:1}; chs="$chs$xch"; # remove the 3rd separator
                 fi; fi; if [[ "$mtch" ]]; then getval=1; fi  # if something remains after sep.
                 post=${str%%"$chs"*};                    # remove from chs on [full matching]
            else post="$str"; fi; rmv="${DataOpts[$dtyp]}";

            post=${post#$rmv*}; local psav=$post; # rem from bgn: ~dtyp; e.g.: ~sun => un
            if [[ "$post" ]] && ((dtyp != DATA_PERCENT)); then
                local comp; local ic; rmv=""; local nolp=0;
                if   ((getnum == 1)); then
                     case "$post" in # grab prefixes to cycle thru to ensure all are valid
                     's'*)          comp="$STR_STYP"; post=${post:1};; # s: "abcdefghijklmnopqrstuvwxyz~+-" (w/ spaces)
                     'v'*)          comp="$VAR_STYP"; post=${post:1};; # v: "u n ~ + -"
                     '+'|'-'|'~')   nolp=1; styp="s";;    # + - ~ => s{+|-|~}
                     *)     fail=1; sts=$INV_UNSP;;       # set bval in loop
                     esac
                else case "$dtyp" in # grab prefixes to cycle thru to ensure all are valid
                     $DATA_STR_GEN) comp="$STR_STYP";;    # ~s: "abcdefghijklmnopqrstuvwxyz~+-" (w/ spaces)
                     $DATA_VAR_NAM) comp="$VAR_STYP";;    # ~v: "u n ~ + -"
                     *)     fail=1; sts=$INV_UNSP;;       # set bval in loop
                     esac
                fi;  if  ((nolp == 0)); then local len=${#post}; # loop thru each letter
                     for ((ic=0; ic < len; ic++)); do     # gather all bad letters
                         letr="${post:$ic:1}";            # 1 letter at a time, no spaces
                         if [[ "$comp" != *"$letr"* ]] || [[ "$letr" == " " ]]; then
                             if   [[ ! "$bval" ]]; then bval="bad opts: "; fi
                             fail=1; sts=$INV_UNSP; bval+="$letr";
                         fi
                     done
                fi;  rmv="${DataOpts[$dtyp]}$psav";
                if ((getnum == 1)); then post="$psav"; fi
            fi
            if ((fail == 0)); then                        # get value(s)
                local btyp=$DATA_BADDATA; local bgn; local end; local ch; local n;
                if  ((dtyp != DATA_PERCENT)); then
                    if [[ ! "$rmv" ]];  then rmv="${DataOpts[$dtyp]}"; fi
                    val1="${str#$rmv*}";                  # rem from bgn: ~dtyp
                    if     [[ "$val1" == "$vch"* ]];      then val1="${val1:1}"; regx=1;    # rem: % if present
                        if [[ "${val1:0:1}" == "$vch" ]]; then val1="${val1:1}"; xtrc=1;    # rem 2nd separator
                        if [[ "${val1:0:1}" == "$vch" ]]; then val1="${val1:1}"; neg8=1;    # rem 3rd separator
                        fi; fi; if [[ ! "$val1" ]]; then dtyp=$DATA_MISDATA; sts=$FAILURE; fi
                    elif   [[ "$val1" == "$xch"* ]];      then val1="${val1:1}";            # rem: @ if present
                        if [[ "${val1:0:1}" == "$xch" ]]; then val1="${val1:1}"; xtrc=1;    # rem 2nd separator
                        if [[ "${val1:0:1}" == "$xch" ]]; then val1="${val1:1}"; neg8=1;    # rem 3rd separator
                        fi; fi; if [[ ! "$val1" ]]; then dtyp=$DATA_MISDATA; sts=$FAILURE; fi
                    fi
                fi  # end not percents
                if ((sts == SUCCESS)); then local dval=0; local sepc; # else continue, we're done here

                    #####################################################################
                    # ENUMS: can't use '|' to separate enums as this is used for SYMB
                    # GRUP to identify multiple ind parms (-f|--file in) & mixed groups
                    # {-i|--out|m} & we need to support enums for these very parms. Also
                    # we want to support enums as plain matches (via SYMB PLAN) or as
                    # regex matches (via SYMB REGX): ~s-@__@__{@__} | ~s-%__%__{%__}.
                    # So determine if we have any unescaped PLAN|REGX symbols ('@'|'%').
                    #####################################################################
                    if  ((dval == 0)) && [[ "$val1" == *"$xch"* ]]; then # ensure not all '@' escaped
                        local temp; local ltmp; local nume; local lval=${#val1};
                        temp=${val1//[^"$xch"]/}; ltmp=${#temp};  dval=$ltmp; # set no. '@'
                        temp=${val1//\\$xch};     ltmp=${#temp}; ((nume = lval - ltmp));
                        temp="\\$xch";            ltmp=${#temp}; ((nume = nume / ltmp));
                        ((dval -= nume));               # subtract escaped '@' (int. div. ok)
                        if ((dval > 0)); then sepc="$xch"; fi
                    fi  # don't check for '%' if already have found '@' (one|other, not both)
                    if  ((dval == 0)) && [[ "$val1" == *"$vch"* ]]; then # ensure not all '%' escaped
                        local temp; local ltmp; local nume; local lval=${#val1};
                        temp=${val1//[^"$vch"]/}; ltmp=${#temp}; ((dval = ltmp)); # add no. '%'
                        temp=${val1//\\$vch};     ltmp=${#temp}; ((nume = lval - ltmp));
                        temp="\\$vch";            ltmp=${#temp}; ((nume = nume / ltmp));
                        ((dval -= nume));               # subtract escaped '%' (int. div. ok)
                        if ((dval > 0)); then sepc="$vch"; regx=1; fi
                    fi; if [[ "$val1" ]] || [[ "$val2" ]]; then valt=$VALU_EQAL; fi # set new def.

                    # Note: appears that searching for an escaped SYMB LOCS is not needed here
                    local norng=0; # NB: regx set several places, check for a loc. marker ('~')
                    if  ((regx == 1)); then srch=$SRCH_ANY; # def. for regex is to search any
                        if ((doloc == 1)) && [[ "$val1" == *"$SYMB_LOCS"* ]]; then norng=1; fi
                    fi

                    #####################################################################
                    # We have enums if count of PLAN|REGX > 0, for if we have at least
                    # 1, then we have at least 2 enums (e.g.: val1@val2), else a value
                    # Cycle thru all enums & dequote & change to decimal if hex
                    #####################################################################
                    if ((dval > 0)); then valt=$VALU_ENUM; local one=1;
                        local oifs="$IFS";  IFS="$sepc";   local val;
                        declare -a arr; arr=($val1); n=${#arr[@]}; IFS="$oifs"; val1=""; # arrayize val1
                        for val in "${arr[@]}"; do n="$val"; n=${#val};                  # dequote each value
                            if  ((n > 1)); then  bgn="${val:0:1}"; end="${val:$n-1:1}";
                                if ( [[ "$bgn" == "'" ]] || [[ "$bgn" == '"' ]] ) && [[ "$bgn" == "$end" ]];
                                then val="${val:1:$n-2}"; fi                             # now de-quoted
                            fi; if   [[ "$val" ]];  then                                 # doing range checking
                                if   [[ "$val" == *" "* ]]; then                         # spaces not allowed
                                     sts=$INV_UNSP; bval="spaces not allowed for enums";
                                elif [[ "$val" != *"."* ]]; then # hexnums can't have '.' in them
                                    if Hex2Dec $sbhex "$val"; then val=$HEX_NUM; else sts=$INV_NUMB; fi
                                fi
                            fi; if ((one == 1)); then  val1="$val"; one=0; else val1+="$sepc$val"; fi
                        done; # allow illegal values, so don't check datatype for enums

                    #####################################################################
                    # Pseudo-RANG : percent datatypes always have a low value & a specified
                    # or default high value (e.g.: 0-100 or -50-0).
                    #####################################################################
                    elif ((dtyp == DATA_PERCENT)); then valt=$VALU_RANG;

                    #####################################################################
                    # SYMB RANG ('a-b') means doing a range, so we need 2 values, but must
                    # be careful if either value is a number and has a negative sign; but
                    # following correctly handles negatives: "-5--4" [val2 only for ranges]
                    # but prevent %|%% with [-] to be seen as a range by getparms. We want
                    # to allow illegal values, so don't check if all numbers when getnum=1
                    # and don't check if val1 < val2 to allow illegal ranges on purpose.
                    # NB: number ranges can't be quoted & can't have location symbol ('~')
                    #####################################################################
                    elif ((norng == 0)) && [[ "$val1" == *?"$SYMB_RANG"?* ]] &&  # ensures a divider after 1st ch.
                        [[ "$val1" != *"["*"$SYMB_RANG"*"]"* ]]; then # excludes any regex range
                        valt=$VALU_RANG; ch="${val1:0:1}"; # get 1st ch. & test if range divider
                        if  [[  "$ch"  ==  "$SYMB_RANG"  ]]; then val1="${val1:1}"; else ch=""; fi
                        if  [[ "$val1" == *"$SYMB_LOCS"* ]]; then plus=1; fi     # flag error if '~'
                        # get after 1st range divider & b4 range & add back lead char.
                        val2=${val1#*"$SYMB_RANG"}; val1="$ch${val1/"$SYMB_RANG"*/}";
                        n=${#val1};   # do de-quote function for val1
                        if ((n > 1)); then bgn="${val1:0:1}"; end="${val1:$n-1:1}";
                            if ( [[ "$bgn" == "'" ]] || [[ "$bgn" == '"' ]] ) && [[ "$bgn" == "$end" ]];
                            then val1="${val1:1:$n-2}"; fi
                        fi; n=${#val2};   # do de-quote function for val2
                        if ((n > 1)); then bgn="${val2:0:1}"; end="${val2:$n-1:1}";
                            if ( [[ "$bgn" == "'" ]] || [[ "$bgn" == '"' ]] ) && [[ "$bgn" == "$end" ]];
                            then val2="${val2:1:$n-2}"; fi
                        fi

                    #####################################################################
                    # Handle location indicator ('~'): used to indicate string position
                    # but only if not disabled by configuration for regex processing:
                    # pre~ | ~mid~ | ~end (no '~' indicates all for non-regx, but or regx
                    # means any); regx also supports ^ & $ for bgn & end; but we don't
                    # extract these here for multiple enums, e.g.: ~s%~\.end%pre\.~
                    #####################################################################
                    elif [[ "$val1" ]]; then local vlen=${#val1};     # def.: srch=$SRCH_ALL;
                        if  ((regx == 0)) || ((doloc == 1)); then
                            if   [[ "$val1" ==  "$SYMB_LOCS"*"$SYMB_LOCS"*"$SYMB_LOCS" ]]; # ~...~...~
                            then srch=$SRCH_SLC; val1="${val1:1:vlen-2}"; # ~...~ => ...~...
                                 val2="${val1/*"$SYMB_LOCS"}"; val1="${val1/"$SYMB_LOCS"$val2}"; # split
                            elif [[ "$val1" ==  "$SYMB_LOCS"*"$SYMB_LOCS" ]];
                            then srch=$SRCH_ANY; val1="${val1:1:vlen-2}"; # ~...~ (rm outer)
                            elif [[ "$val1" ==  *"$SYMB_LOCS"  ]];
                            then srch=$SRCH_BGN; val1="${val1:0:vlen-1}"; #  ...~ (rm trail)
                            elif [[ "$val1" ==   "$SYMB_LOCS"* ]];
                            then srch=$SRCH_END; val1="${val1:1}";        # ~...  (rm begin)
                            elif [[ "$val1" == *"$SYMB_LOCS"* ]];
                            then srch=$SRCH_GRD; # need to split values   # ..~.. (split it)
                                 val2="${val1/*"$SYMB_LOCS"}"; val1="${val1/"$SYMB_LOCS"$val2}";
                            fi
                        fi # not regx or regx with do location

                        n=${#val1};   # do de-quote function for val1
                        if ((n > 1)); then bgn="${val1:0:1}"; end="${val1:$n-1:1}";
                            if ( [[ "$bgn" == "'" ]] || [[ "$bgn" == '"' ]] ) && [[ "$bgn" == "$end" ]];
                            then val1="${val1:1:$n-2}"; fi
                        fi; n=${#val2};   # do de-quote function for val2
                        if ((n > 1)); then bgn="${val2:0:1}"; end="${val2:$n-1:1}";
                            if ( [[ "$bgn" == "'" ]] || [[ "$bgn" == '"' ]] ) && [[ "$bgn" == "$end" ]];
                            then val2="${val2:1:$n-2}"; fi
                        fi
                    fi  # end of all if types

                    ############################################################
                    # To auto-escape all RE_CHARS chars we'd have to loop through
                    # all 13 RE_CHARS chars, but also when found, we'd have to
                    # loop thru $prem$mtch by parts to see which are escaped and
                    # which aren't, which would greatly increase the analyze time
                    # so instead users are required to escape them themselves!
                    # Remove the leading escape characters from val1 and val2.
                    ############################################################
                    if  [[ "${val1:0:1}" == '\\' ]]; then val1=${val1:1}; fi
                    if  [[ "${val2:0:1}" == '\\' ]]; then val2=${val2:1}; fi
                   #if  [[ "$val1" ]]; then unescapech "$val1"; val1="$TMP"; fi
                   #if  [[ "$val2" ]]; then unescapech "$val2"; val2="$TMP"; fi
                fi  # end sts == SUCCESS
            fi  # end of if fail = 0
        fi  # end get num or get str
    fi  # end SYMB_TYPE*

    #####################################################################
    # check if we need to convert hexadecimal input to decimal; Note: the
    # enum values are done inline above (as we loop thru array of values)
    #####################################################################
    if [[ "$val2" ]] && [[ "$val2" != *"."* ]];
    then if Hex2Dec $sbhex "$val2"; then val2=$HEX_NUM; else sts=$INV_NUMB; fi; fi
    if [[ "$val1" ]] && [[ "$val1" != *"."* ]];
    then if Hex2Dec $sbhex "$val1"; then val1=$HEX_NUM; else sts=$INV_NUMB; fi; fi

    #####################################################################
    # now set the number type if it was not already set
    # Note: following is only for display w/|w/o quotes
    #####################################################################
    if  ((dtyp == DATA_IS_NONE)); then  # && ((numt == $NUM_NAN))
        case "$base" in # skipping: HLP_BASE, EOM_BASE, PRM_BASE => NUM_NAN
        $HLP_BASE) numt=$NUM_INT;;  # 1 Helps Items: help strings
        $OPT_BASE) numt=$NUM_INT;;  # 2 Option Type: -i|--index
        $SIP_BASE) numt=$NUM_DEC;;  # 3 ShortIndPrm: -d=
        $EOM_BASE) numt=$NUM_INT;;  # 5 EndOpMarker: --|-+
        esac
    fi

    #####################################################################
    # now set all data for this entry (even if NONE)
    #####################################################################
    local pfix="$styp$post"; # use whichone|both is set
    DataType[$indx]="$dtyp"; # store data type to check
    DataSrch[$indx]="$srch"; # store data string locale
    ValuType[$indx]="$valt"; # store enum flag to check
    NmbrType[$indx]="$numt"; # store enum of number type
    DataPost[$indx]="$pfix"; # store str|num postfix(es): un~+-
    DataVal1[$indx]="$val1"; # store data valu to check
    DataVal2[$indx]="$val2"; # store data valu to check
    DataRegx[$indx]="$regx"; # store data if regx match
    Extracts[$indx]="$xtrc"; # store if extracting strs
    Negation[$indx]="$neg8"; # store if doing negations

    #####################################################################
    # check if illegal combo specified, but don't overwrite another error
    # (actual is this specific type, supt is all supported for this type)
    #####################################################################
    if  ((sts == SUCCESS)); then local actual=${ValuBits[$valt]}; # this type
        if (( (supt & actual) != actual)); # check if supported for this dtyp
        then sts=$INV_UNSP; bval="${ValuName[$valt]}";    # next: VALU RANG not supported
        elif ((xtrc == 1)) && ((valt != VALU_ENUM)) && ((valt != VALU_EQAL));
        then sts=$INV_TYPE; bval="${ValuName[$valt]}";    # srch only allowed for above 2
        elif ((plus == 1));
        then sts=$INV_TYPE; bval="${ValuName[$valt]}"; fi # can't have range & surrounding
    fi

    #####################################################################
    # we have to do return code translation here
    # RangeStr: INV_GOOD|INV_ENUM|INV_RANG|INV_VALU
    # RangeNum: INV_GOOD|INV_ENUM|INV_RANG|INV_VALU|INV_TYPE|INV_MTCH|INV_NUMB
    #####################################################################
    local msg="${InvMsg[$sts]}"; local err="${InvErr[$sts]}";
    case "$sts" in # record any error & generate the error string for it
    $INV_GOOD) ;;  # nothing to do (but exclude from the catchall default)
    $INV_MTCH) if ((numt == NUM_NAN)); then err=$PFER; fi
               sts=${InvRtn[$sts]}; PrintErr $test $indx "$err" "$indx" "$orig @ $indx [$msg]" >&2;;
    $INV_ENUM|$INV_RANG|$INV_TYPE|$INV_VALU|$INV_FIND|$INV_NUMB)
               sts=${InvRtn[$sts]}; PrintErr $test $indx "$err" "$indx" "$orig @ $indx [$msg]" >&2;;
    $INV_UNSP) sts=${InvRtn[$sts]}; PrintErr $test $indx "$err" "$indx" "$orig @ $indx [$msg] val='$bval'" >&2;;
    *)         sts=$FAILURE; local  dtxt=${DataText[$dtyp]}; if [[ "$dtxt" =~ " "[+*]$ ]]; then
               local dlen=${#dtxt}; dtxt="${dtxt:0:dlen-2}"; fi # remove trailing: " +"|" *"
               PrintErr  $test $indx "$DTPV" "$indx" "$orig @ $indx val='$bval' [$dtxt] [$msg]" >&2;;
    esac;      DBG_TRC -x 0x27 "$ic" "sts:$sts"; return $sts;
} # end Get DataType

######################################################################################
# Find Str searches for srch string in data; it does regex|plain matching
# based on the part flag, returns if match was successful, and sets the
# global string var XTRCSTR to save the matched|extracted string
# NB: no "<=" operator so in str compares do neg. of ">"
# NB: don't need quotes since no spaces anyway
#                                  1     2    3    4     5      6      7    8
######################################################################################
function  FindStr() { # FindStr "srch" regx xtrc neg8 "data" "val1" "val2" isnu
    local srch=$1;   local regx=$2;   local xtrc=$3;   local neg8=$4; shift 4;
    local data="$1"; local val1="$2"; local val2="$3"; local isnu=$4; shift 4;
    DBG_TRC  9 "$data" "FindStr: data:$data, srch:${SrchFlg[$srch]}[$srch], regx:$regx, neg8:$neg8, xtrc:$xtrc, vals:$val1|$val2, isnu:$isnu";
    local good=$FAILURE; case "$srch" in # support getting whole|start|trail| midst
    $SRCH_ALL) # 0: this has to match the whole string
        if  ((regx == 0)); then # plain match, not Bash ERE [ALL=0]
            if [[ "$data" ==   "$val1"   ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); then XTRCSTR="$data";
            if ((neg8 == 1)); then XTRCSTR=""; fi; fi; fi
        elif   [[ "$data" =~  ^${val1}$  ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); # do extraction, unless it fails
            then XTRCSTR="${BASH_REMATCH[1]}"; if [[ ! "$XTRCSTR" ]];
            then XTRCSTR="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCSTR="${data/$XTRCSTR/}";  fi; fi
        fi;;
    $SRCH_BGN) # 2: this only has to match the start of the string
        if  ((regx == 0)); then # plain match, not Bash ERE [BGN=2]
            if [[ "$data" ==   "$val1"*  ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); then XTRCSTR=${data#"$val1"}; # rm bgn
            if ((neg8 == 1)); then XTRCSTR="${data/$XTRCSTR/}"; fi
            if ((isnu != 0)); then XTRCNUM="$XTRCSTR";
            if ((neg8 == 1)); then XTRCNUM="${data/$XTRCNUM/}"; fi; fi; fi; fi
        elif   [[ "$data" =~  ^${val1}  ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); # do extraction, unless it fails
            then XTRCSTR="${BASH_REMATCH[1]}"; if [[ ! "$XTRCSTR" ]];
            then XTRCSTR="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCSTR="${data/$XTRCSTR/}";  fi; fi
        fi;;
    $SRCH_END) # 3: this only has to match the end of the string
        if  ((regx == 0)); then # plain match, not Bash ERE [END=3]
            if [[ "$data" == *"$val1" ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); then XTRCSTR=${data%"$val1"}; # rm end
            if ((neg8 == 1)); then XTRCSTR="${data/$XTRCSTR/}"; fi
            if ((isnu != 0)); then XTRCNUM="$XTRCSTR";
            if ((neg8 == 1)); then XTRCNUM="${data/$XTRCNUM/}"; fi; fi; fi; fi
        elif   [[ "$data" =~   ${val1}$  ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); # do extraction, unless it fails
            then XTRCSTR="${BASH_REMATCH[1]}"; if [[ ! "$XTRCSTR" ]];
            then XTRCSTR="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCSTR="${data/$XTRCSTR/}";  fi; fi
        fi;;
    $SRCH_GRD) # 4: grid has to match the start and end of the string
        if  ((regx == 0)); then # plain match, not Bash ERE [GRD=4]
            if [[ "$data" ==  "$val1"*"$val2"  ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); then XTRCSTR=${data#"$val1"}; # rm bgn &
                                XTRCSTR=${XTRCSTR%"$val2"}; # rm end
            if ((neg8 == 1)); then XTRCSTR="${data/$XTRCSTR/}"; fi
            if ((isnu != 0)); then XTRCNUM="$XTRCSTR";
            if ((neg8 == 1)); then XTRCNUM="${data/$XTRCSTR/}"; fi; fi; fi; fi
        elif   [[ "$data" =~ ^${val1}(.*)${val2}$ ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); # do extraction, unless it fails
            then XTRCSTR="${BASH_REMATCH[1]}"; if [[ ! "$XTRCSTR" ]];
            then XTRCSTR="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCSTR="${data/$XTRCSTR/}";  fi; fi
        fi;;
    $SRCH_SLC) # 5: slice can match anywhere in the string
        if  ((regx == 0)); then # plain match, not Bash ERE [GRD=4]
            if [[ "$data" ==  *"$val1"*"$val2"*  ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); then XTRCSTR=${data#"$val1"}; # rm bgn &
                                XTRCSTR=${XTRCSTR%"$val2"}; # rm end
            if ((neg8 == 1)); then XTRCSTR="${data/$XTRCSTR/}"; fi
            if ((isnu != 0)); then XTRCNUM="$XTRCSTR";
            if ((neg8 == 1)); then XTRCNUM="${data/$XTRCNUM/}"; fi; fi; fi; fi
        elif   [[ "$val2" ]]; then
            if [[ "$data" =~  ${val1}(.*)${val2}  ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); # do extraction, unless it fails
            then XTRCSTR="${BASH_REMATCH[1]}"; if [[ ! "$XTRCSTR" ]];
            then XTRCSTR="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCSTR="${data/$XTRCSTR/}";  fi; fi; fi
        else if [[ "$data" =~  ${val1}  ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); # do extraction, unless it fails
            then XTRCSTR="${BASH_REMATCH[1]}"; if [[ ! "$XTRCSTR" ]];
            then XTRCSTR="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCSTR="${data/$XTRCSTR/}";  fi; fi; fi;
        fi;;
    *)  # 1: SRCH_ANY # doesn't have to match the start|end of the string
        if  ((regx == 0)); then # plain matching, not Bash ERE [ANY=1]
            if [[ "$data" == *"$val1"* ]]; then good=$INV_GOOD;
            # NB: replace all occurrences of found string with space
            if ((xtrc == 1)); then XTRCSTR=${data//"$val1"/ };
            if ((neg8 == 1)); then XTRCSTR="${data/$XTRCSTR/}"; fi
            if ((isnu != 0)); then XTRCNUM="$XTRCSTR";
            if ((neg8 == 1)); then XTRCNUM="${data/$XTRCNUM/}"; fi; fi; fi; fi
        elif   [[ "$data" =~  ${val1}  ]]; then good=$INV_GOOD;
            if ((xtrc == 1)); # do extraction, unless it fails
            then XTRCSTR="${BASH_REMATCH[1]}"; if [[ ! "$XTRCSTR" ]];
            then XTRCSTR="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCSTR="${data/$XTRCSTR/}";  fi; fi
        fi;;
    esac; DBG_TRC -x 9 "$data" "FindStr: good:$good"; return $good;
} # end Find Str returns SUCCESS|FAILURE & sets XTRCSTR if xtrc=1

#############################################################################
# Find Num searches for srch string in data; it does regex|plain matching
# based on the part flag, returns if match was successful, and sets the
# global string var XTRCNUM to save the matched|extracted number
#############################################################################
function  FindNum() { # FindNum "srch" regx xtrc neg8 "data" "val1" "val2" dtyp
    local srch=$1;   local regx=$2;   local xtrc=$3;   local neg8=$4; shift 4;
    local data="$1"; local val1="$2"; local val2="$3"; local dtyp=$4; shift 4; local good=$FAILURE;
    DBG_TRC  9 "$data" "FindNum: data:$data, srch:${SrchFlg[$srch]}[$srch], regx:$regx, xtrc:$xtrc, vals:$val1|$val2";
    local xpat=${RegxPatt[$dtyp]}; if [[ ! "$xpat" ]]; then return $good; fi # failed
    case "$srch" in # support getting whole|start|trail| midst
    # NB: no "<=" operator so in str compares do neg. of ">"
    $SRCH_ALL) if ((regx == 0)); then # plain match, not Bash ERE [ALL=0]
            if [[ "$data" ==   "$val1"   ]]; then good=$INV_GOOD; XTRCNUM="$data"; fi
        elif   [[ "$data" =~ ^(${xpat})?${val1}(${xpat})?$ ]]; then good=$INV_GOOD;
                 XTRCNUM="${BASH_REMATCH[1]}"; if [[ ! "$XTRCNUM" ]];
            then XTRCNUM="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCNUM="${data/$XTRCNUM/}";  fi
        fi;;
    $SRCH_BGN) if ((regx == 0)); then # plain match, not Bash ERE [BGN=2]
            if [[ "$data" ==   "$val1"* ]]; then good=$INV_GOOD; XTRCNUM=${data#"$val1"}; fi # rm bgn
        elif   [[ "$data" =~  ^${val1}(${xpat}) ]]; then good=$INV_GOOD;
                 XTRCNUM="${BASH_REMATCH[1]}"; if [[ ! "$XTRCNUM" ]];
            then XTRCNUM="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCNUM="${data/$XTRCNUM/}";  fi
        fi;;
    $SRCH_END) if ((regx == 0)); then # plain match, not Bash ERE [END=3]
            if [[ "$data" ==  *"$val1"   ]]; then good=$INV_GOOD; XTRCNUM=${data%"$val1"}; fi # rm end
        elif   [[ "$data" =~   (${xpat})${val1}$  ]]; then good=$INV_GOOD;
                 XTRCNUM="${BASH_REMATCH[1]}"; if [[ ! "$XTRCNUM" ]];
            then XTRCNUM="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCNUM="${data/$XTRCNUM/}";  fi
        fi;;
    $SRCH_SLC) # slice can match anywhere in the string
        if ((regx == 0)); then # plain match, not Bash ERE [GRD=4]
            if [[ "$data" == *"$val1"*"$val2"* ]]; then good=$INV_GOOD;
                 XTRCNUM=${data#"$val1"}; XTRCNUM=${XTRCNUM%"$val2"}; if ((neg8 == 1));
            then XTRCNUM="${data/$XTRCNUM/}";  fi; fi # rm bgn & end
        elif   [[ "$data" =~  ${val1}(${xpat})${val2}  ]]; then good=$INV_GOOD;
                 XTRCNUM="${BASH_REMATCH[1]}"; if [[ ! "$XTRCNUM" ]];
            then XTRCNUM="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCNUM="${data/$XTRCNUM/}";  fi
        fi;;
    $SRCH_GRD) # grid has to match the start and end of the string
        if ((regx == 0)); then # plain match, not Bash ERE [GRD=4]
            if [[ "$data" ==  "$val1"*"$val2" ]]; then good=$INV_GOOD;
                 XTRCNUM=${data#"$val1"}; XTRCNUM=${XTRCNUM%"$val2"}; if ((neg8 == 1));
            then XTRCNUM="${data/$XTRCNUM/}";  fi; fi # rm bgn & end
        elif   [[ "$data" =~ ^${val1}(${xpat})${val2}$ ]]; then good=$INV_GOOD;
                 XTRCNUM="${BASH_REMATCH[1]}"; if [[ ! "$XTRCNUM" ]];
            then XTRCNUM="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCNUM="${data/$XTRCNUM/}";  fi
        fi;;
    *)  if  ((regx == 0)); then # plain matching, not Bash ERE [SRCH_ANY=1]
            if [[ "$data" ==  *"$val1"* ]]; then good=$INV_GOOD;
            # NB: replace all occurrences of found string with space
            if ((xtrc == 1)); then XTRCNUM=${data//"$val1"/ }; if ((neg8 == 1));
            then XTRCNUM="${data/$XTRCNUM/}";  fi
            else XTRCNUM="$data"; fi; fi
        elif   [[ "$data" =~ ((${xpat})?${val1}(${xpat})?) ]]; then good=$INV_GOOD;
                 XTRCNUM="${BASH_REMATCH[1]}"; if [[ ! "$XTRCNUM" ]];
            then XTRCNUM="${BASH_REMATCH[0]}"; fi; if ((neg8 == 1));
            then XTRCNUM="${data/$XTRCNUM/}";  fi
        fi;;
    esac; DBG_TRC -x 9 "$data" "FindNum: good:$good"; return $good;
} # end Find Num returns SUCCESS|FAILURE & sets XTRCNUM if xtrc=1

#############################################################################
# Range Num checks if there is a value|range|enum for a num|int
# Note: to compare numbers we have to use bc, since bash only does integers.
# Numerals are: pos.: -np, neg.: -nn, pos./neg.: -n
# Integers are: pos.: -ip, neg.: -in, pos./neg.: -n, -# raw integer
# num  = 1|0 : means decimal number | an integer
#                          1   2    3    4    5    6    7    8    9   10   11   12
###################################################################################
function  RangeNum() { # num ntyp dtyp styp data valt val1 val2 part srch xtrc neg8
    DBG_TRC  20 "$indx" "RangeNum: num:$2, valt:$7"; local good=$INV_RANG;
    local num=$1;  local ntyp=$2;   local dtyp=$3; shift 3;
    local styp=$1; local data="$2"; local valt=$3; local val1=$4; shift 4;
    local val2=$1; local part=$2;   local srch=$3; local xtrc=$4; shift 4;
    local neg8=$1; shift;           local pre="";  local anx="";  local mid="";
    local regx=""; if ((part == 1)); then regx="-re"; fi
    local remv=""; if ((neg8 == 1)); then remv="-neg8"; # negate
                 elif ((xtrc == 1)); then remv="-rm"; fi
    local doloc=$((CfgSet[CF_RGXLOC] != 1)); # NB: invert bool value

    ########################################################################
    # Note: have excluded spaces in surrounding text so can skip quoting
    # '+' may cause comparisons to fail, so we always delete it if found
    # NB: can't just check [[ "$val2" ]] for ranges as girding text also has
    ########################################################################
    if   ((valt == VALU_RANG)); then # do range checking [RANG] (extraction N/A)
         is_number "$data" $styp $regx $pre $mid $anx $ntyp; good=$?;
         if  ((good == 0)); then data=$XTRCNUM;
             if   [[ "$data" == "+"* ]]; then data=${data:1}; fi # rm leading '+'
             # now we can convert hex numbers to decimal
             local sbhex="";  if ((dtyp == DATA_HEX_NUM));  then sbhex="-s"; fi
             if   [[ "$data" ]] && [[ "$data" != *"."* ]]; then
                  if Hex2Dec $sbhex "$data"; then data=$HEX_NUM; else return $INV_NUMB; fi
             fi;  XTRCNUM=$data;
             if   ((num == 1)); then
                  if [[ $(bc <<< "($val1 <= $data) && ($data <= $val2)") -eq 1 ]];
                  then good=$INV_GOOD; else good=$INV_RANG; fi
             elif ((val1 <= data)) && ((data <= val2));
             then good=$INV_GOOD; else good=$INV_RANG; fi
         fi

    elif ((valt == VALU_ENUM)); then # must loop thru enum values
        local sepc="$SYMB_PLAN"; if ((part == 1)); then sepc="$SYMB_REGX"; fi
        local oifs="$IFS"; IFS="$sepc"; local found=0; good=$INV_ENUM; # assume err
        declare -a arr; arr=($val1); IFS="$oifs"; val1=""; val2="";    # arrayize val1 (enum str)
        local ic; local num=${#arr[@]};   # so we can loop thru all values
        for ((ic = 0; (ic < num) && (found == 0); ic++)); do  # quit if we find a match
            if  [[ "${arr[$ic]}" ]]; then val1="${arr[$ic]}"; # only do if non-empty string
                srch=$SRCH_ALL; if ((part == 1)); then srch=$SRCH_ANY; fi
                val2=""; local vlen=${#val1}; # get vars, Note: dequoting already done
                if  ((part == 0)) || ((doloc == 1)); then
                    if   [[ "$val1" ==  "$SYMB_LOCS"*"$SYMB_LOCS"*"$SYMB_LOCS" ]]; # ~...~...~
                    then srch=$SRCH_SLC; val1="${val1:1:vlen-2}"; # ~...~ => ...~...
                         val2="${val1/*"$SYMB_LOCS"}"; val1="${val1/"$SYMB_LOCS"$val2}"; # now split
                    elif [[ "$val1" ==  "$SYMB_LOCS"*"$SYMB_LOCS" ]];
                    then srch=$SRCH_ANY; val1="${val1:1:vlen-2}"; # ~...~ (rm outer)
                    elif [[ "$val1" ==  *"$SYMB_LOCS"  ]];
                    then srch=$SRCH_BGN; val1="${val1:0:vlen-1}"; #  ...~ (rm trail)
                    elif [[ "$val1" ==   "$SYMB_LOCS"* ]];
                    then srch=$SRCH_END; val1="${val1:1}";        # ~...  (rm begin)
                    elif [[ "$val1" == *"$SYMB_LOCS"* ]];
                    then srch=$SRCH_GRD; # need to split values   # ..~..  (split)
                         val2="${val1/*"$SYMB_LOCS"}"; val1="${val1/"$SYMB_LOCS"$val2}";
                    fi   # exclude escaped '+'?
                fi # end not regex or regex && doloc
                if   FindNum "$srch" $part $xtrc $neg8 "$data" "$val1" "$val2" $dtyp; then
                     if is_number "$XTRCNUM" $styp $regx $remv $pre $mid $anx $ntyp; then good=$INV_GOOD; found=1;
                        if   ((xtrc == 1)); then data=$XTRCNUM; fi
                        if   [[ "$data" == "+"* ]]; then data=${data:1}; fi # rm leading '+'
                        # now we can convert hex numbers to decimal
                        local sbhex="";  if ((dtyp == DATA_HEX_NUM));  then sbhex="-s"; fi
                        if   [[ "$data" ]] && [[ "$data" != *"."* ]]; then
                             if   Hex2Dec $sbhex "$data"; then data=$HEX_NUM; else return $INV_NUMB; fi
                        fi;  XTRCNUM=$data;
                    fi  # if is number
                fi  # if Find Num
            fi  # if a value
        done

    elif [[ "$val1" ]]; then local srnd=0;
        case "$srch" in
            $SRCH_BGN)   pre="-pre $val1"; srnd=1;;                   # bgn :  ...~
            $SRCH_END)   anx="-anx $val1"; srnd=1;;                   # end : ~...
            $SRCH_ANY)   mid="-mid $val1"; srnd=1;;                   # any : ~...~
            $SRCH_GRD)   pre="-pre $val1"; srnd=1; anx="-anx $val2";; # grd : ..~..
            $SRCH_SLC)   pre="-pre $val1"; srnd=1; anx="-anx $val2";; # slc :~..~..~
        esac; if [[ "$data" == "+"* ]]; then data=${data:1}; fi       # rm leading '+'
        is_number  "$data" $styp $regx $remv $pre $mid $anx $ntyp; good=$?;
        if  ((good == 0)); then # if extraction done, val1 & val2 aren't to be compared
            # against, so then we are done with them, and we can make them empty strings
            if ((srnd == 1)) && [[ "$data" != "$XTRCNUM" ]]; then val1=""; val2=""; fi
            if ((xtrc == 1)); then data=$XTRCNUM; fi
            if [[ "$data" == *" "* ]]; then XTRCNUM=$data; else
                # now we can convert hex numbers to decimal
                local sbhex="";  if ((dtyp == DATA_HEX_NUM));  then sbhex="-s"; fi
                if  [[ "$data" ]] && [[ "$data" != *"."* ]]; then
                    if Hex2Dec $sbhex "$data"; then data=$HEX_NUM; else return $INV_NUMB; fi
                fi; XTRCNUM=$data;
                if  [[ "$val1" ]] || [[ "$val2" ]]; then # no point if no vals left
                    if   [[ "$val1" ]] && [[ "$val1" == *"+"* ]]; then val1=${val1//+}; fi # rm all '+'
                    if   [[ "$val2" ]] && [[ "$val2" == *"+"* ]]; then val2=${val2//+}; fi # rm all '+'
                    if   ((srch != SRCH_ALL)) || ((part == 1)); then  # do regex check
                         # here we just check if string is present, not its numeric value
                         if FindNum "$srch" $part $xtrc $neg8 "$data" "$val1" "$val2" $dtyp;
                         then good=$INV_GOOD; else good=$INV_MTCH; fi
                    elif ((num == 1)); then local TMP="data:$data, val1:$val1";
                         if  [[ $(bc <<< "$data == $val1") -eq 1 ]];
                         then good=$INV_GOOD; else good=$INV_VALU; fi
                    elif ((data == val1));    then good=$INV_GOOD; else good=$INV_VALU; fi
                fi
            fi  # if no spaces
        fi
    else is_number "$data" $styp $regx $remv $pre $mid $anx $ntyp; good=$?; fi # no value to check against, but check data
    DBG_TRC -x 20 "$indx" "RangeNumEnd: XTRCNUM:$XTRCNUM, good:$good"; return $good;
} # Range Num returns: INV_GOOD|INV_TYPE|INV_MTCH|INV_RANG|INV_ENUM|INV_NUMB|INV_VALU & sets XTRCNUM

#############################################################################
# Range Str checks if there is a value|range|enum for a string
# Note: we could get present setting of nocasematch & then resstore it by:
# local on=$(shopt -q nocasematch 2>/dev/null); # SUCCESS if on, else FAILURE
# tried: shopt -s nocasematch; do_compare; shopt -u nocasematch;
# but this just doesn't work reliably in certain comparisons, e.g.: do_compare =
# [[ ! "$val1u" > "$datau" ]]  && [[ ! "$datau" > "$val2u" ]] && good=$SUCCESS;
# 'Bed' fails to be between 'BABY' & 'BEER'. Bash 3 doesn't have: declare -u var
#                             1      2    3    4    5    6    7    8
#############################################################################
function  RangeStr() { # RangeStr -s<~|+|-> data valt regx val1 val2 xtrc neg8 srch
    DBG_TRC  21 "$2" "RangeStr end: data:$2, num:$num, good:$good"; # by data
    local strop=$1; local data="$2"; local valt=$3;   shift 3;
    local regx=$1;  local val1="$2"; local val2="$3"; shift 3;
    local xtrc=$1;  local neg8=$2;   local srch=$3;   shift 3;
    local styp=${strop:2}; local good=$INV_MTCH;
    local doloc=$((CfgSet[CF_RGXLOC] != 1)); # NB: invert bool value

    if  is_string "$data" "$strop";  then local doup=0; local dolo=0; local doin=0;

        ########################################################################
        # NB: don't want to move val1 & val2 capitalization into Get DataType or
        # it shows up in the Specification values & looks like a processing error
        # Additionally we want to check against the real value of val1 & val2;
        # the exception is if we are doing a case insensitivity check. Note:
        # we've already checked the case of the data in is string above using
        # strop, now we're comparing against the case specified by the SubType
        # Note: ~slp+@.txt this says to do both lower & upper case => insens.
        ########################################################################
        local cap=0; if [[ "$styp" == *"+"* ]] || [[ "$styp" == *c* ]]; then cap=1; fi
        local low=0; if [[ "$styp" == *"-"* ]] || [[ "$styp" == *l* ]]; then low=1; fi
        local ins=0; if [[ "$styp" == *"~"* ]]; then doin=1; dolo=1; # lo faster
        elif (((cap == 1) && (low == 1))); then doin=1; dolo=1;
        elif  ((cap == 1));  then doup=1;  elif  ((low == 1));  then dolo=1; fi
        # change all to lower case if doing insensitive (else never change data)
        if   ((doin == 1)); then ChgCase    "$data" "$val1" "$val2";
                                 data="$VAL0"; val1="$VAL1"; val2="$VAL2";
        elif ((dolo == 1)); then ChgCase    "$val1" "$val2";
                                 val1="$VAL0"; val2="$VAL1";
        elif ((doup == 1)); then ChgCase -u "$val1" "$val2";
                                 val1="$VAL0"; val2="$VAL1"; fi

        ########################################################################
        # NB: Bash on Darwin (3.2.57) has a problem handling regular expressions.
        # It uses ERE and supports quoting explicitly but not when in a variable!
        # data="file.txt"; fail="file_txt"; quot='".txt"$'; unqt=.txt$;
        # escd=\.txt$; desc=\\.txt$;
        # explicit case fail works: [[ "$fail" =~ ".txt"$ ]]
        # explicit case good works: [[ "$data" =~ ".txt"$ ]]
        # variable case good FAILS: [[ "$data" =~  $quot  ]] # quotes get in way
        # unquoted case good works: [[ "$data" =~  $unqt  ]]
        # unquoted case fail FAILS: [[ "$fail" =~  $unqt  ]] # . matches any char
        #
        # So we can't keep user quotes but must strip them & readd them.
        # Note: if we leave unquoted, then we must escape special chars,
        # but notice single escaping doesn't work, it has to be double:
        #
        # escaped  case good works: [[ "$data" =~  $escd  ]]
        # escaped  case fail FAILS: [[ "$fail" =~  $escd  ]] # . matches any char
        # dbl-escd case good works: [[ "$data" =~  $desc  ]]
        # dbl-escd case fail works: [[ "$fail" =~  $desc  ]] # . must be dbl.esc.
        #
        # working with quote marks: data="I'm ok"; escd="\'m "; [[ "$data" =~ $escd ]]
        #                           [NB: spaces needn't be escaped once it's in a var]
        # working with regex chars: data="Am.ok";  desc="\\.";  [[ "$data" =~ $desc ]];
        #                           fail="Notok";  desc="\\.";  [[ "$fail" =~ $desc ]];
        ########################################################################
        if  ((valt == VALU_EQAL)); then  XTRCSTR="";  good=$INV_VALU; # surround checking
            if  [[ "$val1" ]]; then # NB: only ranges have val2
                if FindStr "$srch" $regx $xtrc $neg8 "$data" "$val1" "$val2" 0;
                then good=$INV_GOOD; fi
            fi

        elif ((valt == VALU_RANG)) || [[ "$val2" ]]; then # do range checking (% % also)
           if ( [[ ! "$val1" ]] || [[ ! "$val1" > "$data" ]] ) && # NB: no <= so do negative of '>'
              ( [[ ! "$val2" ]] || [[ ! "$data" > "$val2" ]] );
           then good=$INV_GOOD; else good=$INV_RANG; fi

        elif ((valt == VALU_ENUM)); then # must loop thru values
            local sepc="$SYMB_PLAN"; if ((regx == 1)); then sepc="$SYMB_REGX"; fi
            local oifs="$IFS"; IFS="$sepc"; local found=0; good=$INV_ENUM; # assume err
            declare -a arr; arr=($val1); IFS="$oifs"; # arrayize val1 (enum str)
            local ic; local num=${#arr[@]};           # so we can loop thru all values
            for ((ic = 0; (ic < num) && (found == 0); ic++)); do  # quit if we find a match
                if  [[ "${arr[$ic]}" ]]; then val1="${arr[$ic]}"; # only do if non-empty string
                    srch=$SRCH_ALL; if ((regx == 1)); then srch=$SRCH_ANY; fi
                    val2=""; local vlen=${#val1}; # get vars, Note: dequoting already done
                    if  ((regx == 0)) || ((doloc == 1)); then
                        if   [[ "$val1" ==  "$SYMB_LOCS"*"$SYMB_LOCS"*"$SYMB_LOCS" ]]; # ~...~...~
                        then srch=$SRCH_SLC; val1="${val1:1:vlen-2}"; # rm: +...+ => ...+...
                             val2="${val1/*"$SYMB_LOCS"}"; val1="${val1/"$SYMB_LOCS"$val2}"; # now split
                        elif [[ "$val1" ==  "$SYMB_LOCS"*"$SYMB_LOCS" ]];
                        then srch=$SRCH_ANY; val1="${val1:1:vlen-2}"; # ~...~ (rm outer)
                        elif [[ "$val1" ==  *"$SYMB_LOCS"  ]];
                        then srch=$SRCH_BGN; val1="${val1:0:vlen-1}"; #  ...~ (rm trail)
                        elif [[ "$val1" ==   "$SYMB_LOCS"* ]];
                        then srch=$SRCH_END; val1="${val1:1}";        # ~...  (rm begin)
                        elif [[ "$val1" == *"$SYMB_LOCS"* ]];
                        then srch=$SRCH_GRD; # need to split values   # ..~..  (split)
                             val2="${val1/*"$SYMB_LOCS"}"; val1="${val1/"$SYMB_LOCS"$val2}";
                        fi  # # exclude escaped '+'?
                    fi  # end if not regex or regex && doloc
                    if  FindStr "$srch" $regx $xtrc $neg8 "$data" "$val1" "$val2" 0;
                    then good=$INV_GOOD; found=1; fi
                fi  # if a value
            done

        elif [[ "$val1" ]]; then # do value checking
             if [[ "$val1" ==  "$data" ]]; then good=$INV_GOOD; else good=$INV_VALU; fi
        else good=$INV_GOOD; fi
    fi; DBG_TRC -x 21 "$data" "Range Str end: data:$data, num:$num, good:$good";
    return $good;
} # Range Str returns: INV_GOOD|INV_ENUM|INV_RANG|INV_VALU & sets XTRCSTR

#############################################################################
# Match Data checks if received command-line value matches specified datatype
# <p{-}|d{-}|f{-}|fr|fw|frw}{ip4d|ip4h|ip6d|ip6h|ip4|ip6|ipd|iph|ipg>|
# <-s|-l|-a|-w{i|+|-}>
#############################################################################
function  MatchData() { # MatchData ic "data" # NB: if nothing to match, must return INV_GOOD
    local indx=$1; local data="$2";  shift 2; local ntyp;
    local dtyp=${DataType[$indx]};   local fail=$INV_MTCH;
    if [[ ! "$dtyp" ]] || ((dtyp == DATA_IS_NONE)) || ((dtyp >= DATA_MAXGOOD)); then return $INV_GOOD; fi

    local post=${DataPost[$indx]};   # un~+-
    DBG_TRC  0x66 "$indx" "MatchData indx:$indx, dtyp:$dtyp, data:$data, post:$post"; # by indx
    DBG_TRC  0x65 "$dtyp" "MatchData dtyp:$dtyp, indx:$indx, data:$data, post:$post"; # by type
    local xtrc=${Extracts[$indx]};   local neg8=${Negation[$indx]};  local regx="${DataRegx[$indx]}";
    local val1="${DataVal1[$indx]}"; local val2="${DataVal2[$indx]}";
    local valt="${ValuType[$indx]}"; local srch="${DataSrch[$indx]}";
    local ntyp=${NmbrType[$indx]};   local numt="${IntType[$ntyp]}"; # -i|-h|-n
    local styp="";  if [[ "$post" ]];  then
          if   ((ntyp == NUM_NAN));    then styp="-s$post";
          elif [[ "$post" =~ ^[sv] ]]; then styp="-$post"; else styp="-s$post"; fi  # -s~|-s+|-s-|-sc|-sl
    fi
    case  "$dtyp" in # Note: * are for items that have a value to check against
    # following are IP addresses: ip4d, ip4h, ip6d, ip6h, ip4, ip6, ipd, iph, ipg
    # NB: leading zeroes, e.g. 01 (unless only 0), are not allowed
    "${DATA_IP4_DEC}")   [[ "$data" =~ $IPV4_DEC ]]   && fail=$INV_GOOD;; # ip4d: IP4 decimal
    "${DATA_IP4_HEX}")   [[ "$data" =~ $IPV4_HEX ]]   && fail=$INV_GOOD;; # ip4h: IP4 hexadec
    "${DATA_IP6_DEC}")   [[ "$data" =~ $IPV6_DEC ]]   && fail=$INV_GOOD;; # ip6d: IP6 decimal
    "${DATA_IP6_HEX}")   [[ "$data" =~ $IPV6_HEX ]]   && fail=$INV_GOOD;; # ip6h: IP6 hexadec
    "${DATA_IP4_NUM}") ( [[ "$data" =~ $IPV4_DEC ]] ||
                         [[ "$data" =~ $IPV4_HEX ]] ) && fail=$INV_GOOD;; # ip4 : IP4 numeral
    "${DATA_IP6_NUM}") ( [[ "$data" =~ $IPV6_DEC ]] ||
                         [[ "$data" =~ $IPV6_HEX ]] ) && fail=$INV_GOOD;; # ip6 : IP6 numeral
    "${DATA_IPN_DEC}") ( [[ "$data" =~ $IPV4_DEC ]] ||
                         [[ "$data" =~ $IPV6_DEC ]] ) && fail=$INV_GOOD;; # ipd : IPn decimal
    "${DATA_IPN_HEX}") ( [[ "$data" =~ $IPV4_HEX ]] ||
                         [[ "$data" =~ $IPV6_HEX ]] ) && fail=$INV_GOOD;; # iph : IPn hexadec
    "${DATA_IPN_NUM}") ( [[ "$data" =~ $IPV4_DEC ]] || [[ "$data" =~ $IPV6_DEC ]] ||
                         [[ "$data" =~ $IPV4_HEX ]] || [[ "$data" =~ $IPV6_HEX ]] ) &&
                                                         fail=$INV_GOOD;; # ipg : IPn numeral
    "${DATA_MAC_HEX}")  [[ "$data": =~ $MAC_ADDR ]]   && fail=$INV_GOOD;; # mac : Mac hex addr.
    "${DATA_E_MAILS}")  [[ "$data"  =~ $IS_EMAIL ]]   && fail=$INV_GOOD;; # e   : email
    "${DATA_ANY_URL}")  [[ "$data"  =~ $IS_ANURL ]]   &&
                        [[ "$data"  != *" "* ]]       && fail=$INV_GOOD;; # u   : URL|website

    # following are numbers|integers (NB: numbers require external utility bc)
    "${DATA_NUM_POS}") RangeNum 1 -np   "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # +nu
    "${DATA_NUM_NEG}") RangeNum 1 -nn   "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # -nu
    "${DATA_ANUMBER}") RangeNum 1 -n    "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # nu
    "${DATA_INT_POS}") RangeNum 0 -ip   "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # +int
    "${DATA_INT_NEG}") RangeNum 0 -in   "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # -int
    "${DATA_INTEGER}") RangeNum 0 -i    "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # int
    "${DATA_UNS_INT}") RangeNum 0 '-#'  "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # uint

    # following are special type (restricted range) of numbers
    "${DATA_PERCENT}") RangeNum 1 $numt "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # % : (0-100) num|int
    "${DATA_HEX_NUM}") RangeNum 0 -x    "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # h : hexint
    "${DATA_ZEROONE}") RangeNum 0 -B    "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # zo : zero or one (0|1)
    "${DATA_BOOLNUM}") RangeNum 0 -b    "$dtyp" "$styp" "$data" "$valt" "$val1" "$val2" "$regx" "$srch" $xtrc $neg8; fail=$?;; # B  : boolean int (0110)

    # String operations: is_string "str" -opt {"src"}
    "${DATA_STR_GEN}") RangeStr -s$post "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch"; fail=$?;; # s : str
    "${DATA_VAR_NAM}") RangeStr -v$post "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch"; fail=$?;; # v : var

    # File|dir operations: file|dir may not yet exist, so can't use it to go to dir & get parent
    "${DATA_PATH_RW}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if ( [ -d "$data" ] || [ -f "$data" ] ) &&
                       [ -r "$data" ] && [ -w "$data" ]; then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;; # prw : path rd-write
    "${DATA_PATH_WR}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if ( [ -d "$data" ] || [ -f "$data" ] ) &&
                                         [ -w "$data" ]; then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;; # pw  : path writable
    "${DATA_PATH_RD}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if ( [ -d "$data" ] || [ -f "$data" ] ) &&
                                         [ -r "$data" ]; then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;; # pr  : path readable
    "${DATA_PATH_UP}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then data="${data%"/"*}";
                       if [ -d "$data" ]; then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;                # pu  : path parent is
    "${DATA_PATH_NO}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if ! [ -d "$data" ] &&  ! [ -f "$data" ];
                       then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;                                   # pn  : path not exist
    "${DATA_PATH_IS}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if ( [ -d "$data" ] || [ -f "$data" ] );
                       then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;                                   # p   : path exists

    "${DATA_DIRS_RW}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -d "$data" ] && [ -r "$data" ] &&
                                         [ -w "$data" ]; then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;; # drw : dir rd-write
    "${DATA_DIRS_WR}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -d "$data" ] && [ -w "$data" ];
                       then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;                         # dw  : dir writable
    "${DATA_DIRS_RD}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -d "$data" ] && [ -r "$data" ];
                       then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;                         # dr  : dir readable
    "${DATA_DIRS_UP}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then data="${data%"/"*}"; if [ -d "$data" ];
                       then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;                         # du  : dir parent is
    "${DATA_DIRS_NO}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if ! [ -d "$data" ]; then fail=$INV_GOOD;
                       else fail=$INV_FILE; fi; fi;;                                              # dn  : dir not exist
    "${DATA_DIRS_IS}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -d "$data" ]; then fail=$INV_GOOD;
                       else fail=$INV_FILE; fi; fi;;                                              # d   : dir exists

    "${DATA_FIL_RWX}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -f "$data" ] && [ -r "$data" ] &&
                       [ -w "$data" ] && [ -x "$data" ]; then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;; # frwx: file rd+write+exe
    "${DATA_FILE_WX}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -f "$data" ] && [ -w "$data" ] &&
                       [ -x "$data" ]; then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;         # fwx : file write & exe
    "${DATA_FILE_RX}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -f "$data" ] && [ -r "$data" ] &&
                       [ -x "$data" ]; then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;         # frx : file read and exe
    "${DATA_FILE_EX}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -f "$data" ] && [ -x "$data" ];
                       then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;                         # fx  : file isexecutable
    "${DATA_FILE_RW}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -f "$data" ] && [ -r "$data" ] &&
                       [ -w "$data" ]; then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;         # frw : file rd-write
    "${DATA_FILE_WR}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -f "$data" ] && [ -w "$data" ];
                       then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;                         # fw  : file writable
    "${DATA_FILE_RD}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -f "$data" ] && [ -r "$data" ];
                       then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;                         # fr  : file readable
    "${DATA_FILE_UP}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then data="${data%"/"*}"; if [ -d "$data" ];
                       then fail=$INV_GOOD; else fail=$INV_FILE; fi; fi;;                         # fu  : file parent is
    "${DATA_FILE_NO}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if ! [ -f "$data" ]; then fail=$INV_GOOD;
                       else fail=$INV_FILE; fi; fi;;                                              # fn  : file not exist
    "${DATA_FILE_IS}") RangeStr "$styp"  "$data" $valt "$regx" "$val1" "$val2" "$xtrc" "$neg8" "$srch";
                       fail=$?; if [ $fail -eq 0 ]; then if [ -f "$data" ]; then fail=$INV_GOOD;
                       else fail=$INV_FILE; fi; fi;;                                              # f   : file exists
    *) ;; esac;
    DBG_TRC -x 0x65 "$dtyp" "fail:$fail"; # don't put this on the same line with
    DBG_TRC -x 0x66 "$indx" "fail:$fail"; # next line, it messes up dbgenum greps
    return $fail; # INV_GOOD|INV_TYPE|INV_MTCH|INV_RANG|INV_ENUM|INV_VALU|INV_FILE|INV_NUMB
} # end Match Data

#############################################################################
# Helper Functions to support external usage|testing of matching data types.
# matchdata is a test function, written to test specific Match Data results.
#############################################################################
function  matchdata() { local HELP="matchdata {-t}{-b base} fmt_srch_str srch {indx=0} # -t trace, -s string (else number)";
    local HLP2="getparms $SYMB_UTIL matchdata ~i@-31--1 -11; result"; # -x
    local sts=$FAILURE; local verb=0; local base=$PRM_BASE;
    local dbgtrc=0; if [[ "$1" == -t ]]; then dbgtrc=1; shift; fi
    if  [[ "$1" == -b ]]; then base=$2; shift 2; fi; cdebug on "$dbgtrc";
    if  [ $# -eq 0 ] || ( [ $# -eq 1 ] && [[ "$1" == -h ]] );
    then echo "$HELP" >&2; PrintAllTypes;
         printf "Example calling:\n%s\n" "$HLP2";
    else local fmt="$1"; local data="$2"; local indx=$3;
         if   [[ ! "$indx" ]]; then indx=0; # for test index=0 is fine
         elif [[ ! "$indx" =~ ^[0-9]+$ ]]; then cdebug no "$dbgtrc"; # if tracing, stop
             echo  "$HELP" >&2; PrintAllTypes; return $sts;
         fi; if [[ "$fmt" == *"$SYMB_GETP"* ]] || [[ "$fmt" == *"$SYMB_GETX"* ]]; then verb=1; fi
         GetDataType $base "$indx" "$fmt" 1; sts=$?; # print now # lookup dtyp based on fmt string given by user
         # above sets: DataType[$indx]=$dtyp;  DataVal*[$indx]=$dval*;
         # and also:   ValuType[$indx]=$VALU_; NmbrType[$indx]=$NUM_;  ...
         if  [ $sts -ne $INV_GOOD ];  then cdebug no "$dbgtrc"; # if tracing, stop
             echo  "$HELP" >&2; PrintAllTypes; echo "Error: ${InvMsg[$sts]} [$sts]";
         else # now we can get the data type set by Get Data Type in order to save the data
             local     dtyp="${DataType[$indx]}"; # NB: only access via dtyp here in this test
             DataSrch[$dtyp]="$data"; MatchData "$indx" "$data"; sts=$?;
             if  ((verb == 1)); then local isnum=${NmbrType[$indx]};
                 if ((isnum == NUM_NAN)); then printf "%s\n" "$XTRCSTR";
                 elif [[  "$XTRCNUM"  ]]; then printf "%s\n" "$XTRCNUM";
                                          else printf "%s\n" "${RxdValue[$indx]}"; fi
             fi
         fi
    fi;  cdebug no "$dbgtrc"; return $sts;
} # end match data (test routine to verify Get DataType)

#############################################################################
# This function sets all applicable array values for a specification item.
# This function also checks if the option|name has been used more than 1x.
# Note: at this point we don't know if it is a ind parm; done in Init AllItem
# Note: all parms after 'base' are optional and thus must set a default set.
#############################################################################
function  SetSpec() { # SetSpec grpn "name" "srch" reqd cmdl nump link dtyp mind "altn" base | mlnk ored ornb indt|opt indp # after ' | ' items are optional
    local indx=$NumAllItm;  # Set Spec keeps master count of items
    local grpn=$1;    local name="$2";  local srch="$3"; local reqd="$4"; shift 4;
    local cmdl="$1";  local nump="$2";  local link="$3"; local dtyp="$4"; shift 4;
    local mind="$1";  local altn="$2";  local base="$3"; shift 3;
    # now handle optional parms by setting default if empty
    local mlnk="$1";  if [[ ! "$mlnk" ]]; then mlnk=-1; fi; local head;
    local ored="$2";  if [[ ! "$ored" ]]; then ored=0;  fi;
    local ornb="$3";  if [[ ! "$ornb" ]]; then ornb=0;  fi
    local indt="$4";  # or: sopt (if SIP_BASE, set defaults based on base)
    local indp="$5";  shift 5;
    local hsal=0;     if [[   "$altn" ]]; then hsal=1;  fi

    if  [[ "$name" == "$SYMB_MORE"* ]]; then # now check if a more item
        local pndx=$((indx-1));            # only need to flag the parm before this one
        local pbas=${BaseType[$pndx]};     # set head More Indx if previous item a parm
        # NB: options (including SHIP) aren't allowed to have more as they have no parm
        if  ((pbas == PRM_BASE)); then MoreIndx[$pndx]=$pndx; # prev item parm, set idx
        else PrintErr $indx "$MRPP" $ic "$name but preceding was: '${DescName[$pndx]}'" >&2; fi
        # If we continue to add this, we get the additional Warning:
        # 03 [TOSA]: Total Optimized size != to all: s/b=3, is=2 [Fcn=1, BgnPrm=0, Opts=1, Indp=0, EndPrm=0]
        return; # don't record more item separately
    fi

    ############################################################
    # even if no datatype must still call Get Data Type to set
    ############################################################
    if ((indx != 0)); then GetDataType $base $cmdl "$dtyp";  fi # Note: ~ already added
    DBG_TRC  0x30 "$indx" "Set Spec: indx:$indx, name|altn:$name|$altn, ored:$ored, mind:$mind, indt:$indt, base:${BaseName[$base]}";
    local parm=$((base == PRM_BASE)); local hasp=$((parm == 1));
    local pure=$((base == OPT_BASE)); local errd=0;  # only record 1 error
    local eomk=$((base == EOM_BASE)); # end of marker
    local ship=$((base == SIP_BASE)); # shorthand indp
    local optn=$(((pure == 1) || (ship == 1)));

    if   ((ship == 1));   then sopt="$indt"; indt=0; # NB: may validly be ""
         GetShipFlags $indx "$sopt"; local sts=$?;   # stores Ship options
         case "$sts" in # check if it was unsuccessful
         $FAILURE) PrintErr $indx "$MRPP" $ic "$srch=$SYMB_MORE more symbol must be the next item"     >&2;;
         $UNFOUND) PrintErr $indx "$SHOP" $ic "following symbols are unrecognized $srch=$STR_BAD$indp" >&2;;
         esac;
    elif [[ ! "$indt" ]]; then indt=0; fi

    ############################################################
    # set def.: misin|empty (if in OR'ed group) # if reqd, init state: missing
    # set SHIP options if available
    ############################################################
    local ost8=$(( ( (reqd == 1) && (ored == 0) ) ? RX_MISSN : RX_EMPTY));
    if   ((mind != 0)); then head=$IndHead; else head=$mlnk; fi
    DBG_TRC -s 0x2F $indx "Set Spec: name:$name, reqd:$reqd, ored:$ored, srch:$srch";

    ############################################################
    # Set the descriptive & received names based on the type
    ############################################################
    local desc="$name"; local rxnm="$name"; if   ((hsal == 1)); # def: _i|n
    then  desc="$altn";       rxnm="$altn"; elif ((optn == 1)) || ((eomk == 1));
    then  desc="$srch"; fi    # OPT_BASE|SIP_BASE|EOM_BASE

    ############################################################
    # Even if OSIP is disabled, it is OK for OSIP to be spec'ed
    # (for it's the only way to specify an ind parm as p/o an OR
    # group), we just can't process it during the command line
    # as an OSIP; Mind Parm also set in Init AllItem by Set Links
    ############################################################

    ItemIndx[$indx]="$indx"; # store index on [debug]
    CmdlIndx[$indx]="$cmdl"; # cmd-line index unused
    GroupNum[$indx]="$grpn"; # group number this on
    ParmName[$indx]="$name"; # store name to be used
    Alt_Name[$indx]="$altn"; # store alternate name (debugging only)
    SrchName[$indx]="$srch"; # option search string
    DescName[$indx]="$desc"; # name used for errors
    HasAltNm[$indx]="$hsal"; # has an alternate name
    ReqdItem[$indx]="$reqd"; # if required|optional
    NumParms[$indx]="$nump"; # no. of parms. to get
    LinkIndx[$indx]="$link"; # points to -1 or linked parm
    MindParm[$indx]="$mind"; # if it is part of a multi indp
    Ored_Grp[$indx]="$ored"; # if this is a part of an OR'ed
    Ored_Num[$indx]="$ornb"; # OR'ed number that items is on
    BaseType[$indx]="$base"; # what is item's Base enum type
    IndpType[$indx]="$indt"; # what is item's Indp enum type
    NumOptns[$indx]=$pure;   # start with 1 if a pure option

    IndpOpts[$indx]="";      # an OR'ed list of indp options
    ParmIndx[$indx]=-1;      # initialize to a invalid index
    MixedGrp[$indx]=0;       # if part of mixed list (set in Set Mixed)
    MoreIndx[$indx]=0;       # if has more values (always 0 here)

    ############################################################
    # Set applicable ind parm items
    ############################################################
    if  ((mind != 0)); then     local ondx; local jc=0;
         local numo=$IndOpts;   local nump=$IndPrms;
         local head=$IndHead;   local pndx=$((head+numo));
         local item=$((numo+nump));
         MindIndx[$indx]=$head;    # points to -1 or linked parm
         while ((jc < item)); do ndx=$((head+jc));
             MindParm[$ndx]=$mind; # set for items in indp group
             MindIndx[$ndx]=$head; # point to head index for all
             # following are all set by Set IndPrm
            #NumParms[$ndx]=$nump; NumOptns[$ndx]=$numo; ParmIndx[$ndx]=$pndx;
            #if ((jc < numo)); then ((numo--)); else ((nump--)); fi
             ((jc++));
         done
    else MindIndx[$indx]=-1; fi # points to -1 or linked parm

    ############################################################
    # Removed setting of Data array vals when dtype=DATA IS NONE;
    # datatype agreements with item are done in Chk Spec Items;
    # following are setting up for post-processing of cmdline items
    # NB: can't set Miss Pnam here since it is tracked by PrintErrs
    # NB: can't set RemReqPrm here since don't yet know if BgnParm
    ############################################################
    BgnParam[$indx]=0;       # initialize not bgn parm : set by Init AllItem
    RxdState[$indx]="$ost8"; # initialize output state
    RcvdName[$indx]="$rxnm"; # printed name on outputs : name | altn (if exists)
    MissIndp[$indx]="";      # initialize to none : fix this in Init AllItem
    RxdCount[$indx]=0;       # initialize none rcvd.
    RxdInvld[$indx]=0;       # if rcvd value invalid
    RxdIndex[$indx]="";      # index in command line
    RxdValue[$indx]="";      # set rcvd value to empty
    RxdNmOpt[$indx]="";      # names of optns rcvd.: -i --input [should be 0 or 1]
    RxdNuOpt[$indx]=0;       # number options rcvd.: 0|1|2|...  [should be 0 or 1]
    RxdParms[$indx]=0;       # count of rxd indparms
    RxdOptns[$indx]=0;       # count of rxd indoptns
   #MissPnam[$indx]="";      # if indprm name missing
    local gnam=${GroupNams[$grpn]}; # assemble string with all items in this group
    if [[ "$gnam" ]]; then gnam+="$desc "; else gnam=" $desc "; fi
    GroupNams[$grpn]="$gnam";
    DBG_TRC -x 0x30 "$indx" ""; # end of settings tracing

    ############################################################
    # Test 12. verify valid positional, ind parm, or alt. name;
    # only valid chars in name are: [_A-Za-z][_A-Za-z0-9]*
    # Note: 'name' for options has '-' converted to '_' already
    # Must do here because we may not get any cmd-line parms.
    # Note: recording of name errors is done in ChkSpecItems.
    ############################################################
    DBG_TRC  0x31 "$name" "Set Spec: name:$name, GroupNams:$gnam"; # checks
    local namok=1; # check if a valid varname
    if ! is_string "$name" -v; then namok=0; errd=1;
       #if ((hasp == 1)) && [[ "$name" == *"$SYMB_ALTN"* ]]; # altname check=':'
       #then PrintErr $indx "$PALT" $ic "\"$name\" has altname symbol \"$SYMB_ALTN\"" >&2; else
        if ((indx == 0)); then
             PrintErr $indx "$BFCN" $ic "\"$name\" - s/b: [_a-zA-Z][_a-zA-Z0-9]*" >&2;
       #else PrintErr $indx "$BNAM" $ic "\"$name\" - s/b: [_a-zA-Z][_a-zA-Z0-9]*" >&2;
        fi
    fi; GoodName[$indx]=$namok; # record if it has a valid name

    ########################################################################
    # Set derived info, specifically: Optimized Index Lists
    # NB: NumBgnPrm & NumEndPrm calculated separately in Init AllItem
    # because we must know what are ind. parms which are not in these lists
    ########################################################################
    ((NumAllItm++));    if  ((base == HLP_BASE));  then   ((NumFunctn++));    # was: NumEmptys
    elif [[ "$srch" ]]; then NdxOption[$NumOption]=$indx; ((NumOption++)); fi # was: SetOptions

    ########################################################################
    # Can't add opts on the fly to Shrt Opts list, sinc we must not add ind
    # parm opts to it since they can't be combined in single-letter combos;
    # same is true for Two Ltr Opts list; the problem is at this point, we
    # don't know yet if an option in general is part of an ind parm (e.g.:
    # {-f indp}), so we have to do these functions later in Init AllItem.
    # But we can still ensure this option isn't used already. Also we must
    # build up an option list using the mapped names (-o => _o) to ensure
    # that these mapped names do not collide with any items in Parm Names.
    # Now we only add to these aggregate lists, if it is not already there.
    # Multiple end option markers (--) are checked elsewhere (with MULO).
    ########################################################################
    if  [[ "$srch" ]]; then # NB: here we need to include help (indx=0)
        if   [[ "$srch" == *"|"* ]]; then srch="${srch/'|'/ }"; fi
        if   [[ "$srch" == "$HlpOpt1" ]] || [[ "$srch" == "$HlpOpt2" ]]; then
             local str; if [[ "$srch" == "$HlpOpt1" ]];
             then  str="$HlpOpt1"; else str="$HlpOpt2"; fi
             PrintErr $indx "$RHLP" $indx "$str"  >&2; errd=1;
        elif [[ "$srch" == "$SYMB_EOOM" ]]; then if ((ship == 1));
        then SrchShips+="$srch "; else SrchOptns+="$srch "; fi
        elif [[ "$SrchOptns" == *" $srch "* ]]; then
             PrintErr $indx "$MULO" $indx "$srch" >&2; errd=1;
        elif [[ "$SrchShips" == *" $srch "* ]]; then
             PrintErr $indx "$MULO" $indx "$srch" >&2; errd=1;
        elif ((ship == 1)); then SrchShips+="$srch "; else SrchOptns+="$srch "; fi
    fi  # Note: last else above includes ind parm options

    ########################################################################
    # Check if the parm name is duplicated, but we must build an aggregate
    # parm name list to ensure that Opt Name doesn't collide with ParmNames
    ########################################################################
    if  ((namok == 1)); then
        if [[ "$ParmNames" == *" $name "* ]];
        then if ((errd == 0)); # without this check we record MULO & MULP
            then local ic; local jc=-1; # get index of name found
                 for ((ic=0; ic < NumAllItm; ic++)); do
                     local chck="${RcvdName[$ic]}";
                     if   ((ic != indx)) && [[ "$name" == "$chck" ]];
                     then ((jc=ic)); break; fi
                 done; if ((jc == 0));
                 then PrintErr $indx "$DFCN" $indx "$name @ $jc & $indx" >&2;
                 else local diff=0; ########################################
                      # want to allow options as -a and -a+ not to be seen as
                      # a collision, but problem is parm name for -a+ => _a
                      # so exclude based on difference in search name length
                      ######################################################
                      if ((BaseType[jc] == OPT_BASE)) && ((BaseType[indx] == OPT_BASE));
                      then  local lopt1=${#SrchName[$jc]}; local lopt2=${#SrchName[$indx]};
                          diff=$((lopt1 != lopt2)); # if diff length, not a collision
                      fi; if ((diff == 0)); then
                      PrintErr $jc   "$MULP" $jc   "$name @ $jc & $indx" >&2; fi
                 fi
            fi
        else  ParmNames+="$name "; fi # only add if not already there
    fi; DBG_TRC -x 0x31  "$name" "";  # NB: setting bgn parms done separately
} # end Set Spec

#############################################################################
# Function to copy one item's array values to another. This is specifically
# used for endless (i.e. 'mored') parameters, where we don't know how many
# we will have until we process the command-line. Of course this only works
# because we enforce that an endless parm must be the last item in the spec.
# The copy for an endless parm will always be to the next index (i.e. +1).
# Uncopied commented out fields don't apply (e.g. naming), since these need
# to be different for the new copied location. Note: this is called from
# within Set Rcvd after every field has already been set except RxdState.
#############################################################################
function  CopyArray() { # CopyArray indx # dest is indx++
    local indx=$1; shift; local last=$indx; ((indx++));
    DBG_TRC  8 "$indx" "CopyArray: indx:$last, more:${MoreIndx[$last]}";
    if  ((last > 0)); then                           # 0 is help, don't copy it
        ItemIndx[$indx]="$indx";                     # update the stored index on [debug]

        # items hard-coded due to endless parm, since copied items can't be required
        # Note: function name & endless parms are optional, even if 1st is required!
        HasAltNm[$indx]=0;                           # can't have an alt. name for copied items
        MissPnam[$indx]="";                          # always start as unset   - no indprm name
        NumParms[$indx]=1;                           # no. of parms. to get    - do one more
        ReqdItem[$indx]=0;                           # if required|optional    - is optional

        # items that need to be copied over
        GroupNum[$indx]="${GroupNum[$last]}";        # group number this is on
        Ored_Num[$indx]="${Ored_Num[$last]}";        # OR'ed items now done: n
        MoreIndx[$indx]="${MoreIndx[$last]}";        # index head if more values
        ParmName[$indx]="${ParmName[$last]}";        # always same as original
        Alt_Name[$indx]="${Alt_Name[$last]}";        # always same as original
        GoodName[$indx]="${GoodName[$last]}";        # always same as original
        LinkIndx[$indx]="${LinkIndx[$last]}";        # always same as original - points to head
        MindIndx[$indx]="${MindIndx[$last]}";        # always same as original - points to head
        MindParm[$indx]="${MindParm[$last]}";        # if it is part of a mixed ind.
        MixedGrp[$indx]="${MixedGrp[$last]}";        # if it is part of a mixed list
        Ored_Grp[$indx]="${Ored_Grp[$last]}";        # if this is a part of an OR'ed
        Ored_Num[$indx]="${Ored_Num[$last]}";        # number OR'd items gone by - p/o same num
        ParmIndx[$indx]="${ParmIndx[$last]}";        # 1st index of indprm or more
        BaseType[$indx]="${BaseType[$last]}";        # what is item's Base enum type
        IndpType[$indx]="${IndpType[$last]}";        # what is item's Indp enum type
        BgnParam[$indx]="${BgnParam[$last]}";        # if it's a beginging parm
        DescName[$indx]="${DescName[$last]}";        # store name to be used (same as base)

        # derived SHIP items
        ShipBits[$indx]="${ShipBits[$last]}";        # the configured SHIP bit flags
        ShipChar[$indx]="${ShipChar[$last]}";        # the configured SHIP character
        ShipOnes[$indx]="${ShipOnes[$last]}";        # the configured SHIP src monos
        ShipEnum[$indx]="${ShipEnum[$last]}";        # the configured SHIP src enums
        ShipRang[$indx]="${ShipRang[$last]}";        # the configured SHIP src range
        ShipTest[$indx]="";                          # always start as unset   - no ship test run

        # optionally copied over
        SrchName[$indx]="${SrchName[$last]}";        # option search string (should be "")

        # Need to also copy over Datatype fields
        DataType[$indx]="${DataType[$last]}";        # store data type to check
        DataPost[$indx]="${DataPost[$last]}";        # store str postfix letter: un~+-
        DataVal1[$indx]="${DataVal1[$last]}";        # store data valu to check
        DataVal2[$indx]="${DataVal2[$last]}";        # store data valu to check
        DataSrch[$indx]="${DataSrch[$last]}";        # store search string locale
        ValuType[$indx]="${ValuType[$last]}";        # store of enumerated valu
        NmbrType[$indx]="${NmbrType[$last]}";        # store of enumerated valu
        DataRegx[$indx]="${DataRegx[$last]}";        # store doing regex matches
        Extracts[$indx]="${Extracts[$last]}";        # store if extract the str
        Negation[$indx]="${Extracts[$last]}";        # store if doing negations

        # Set received info (rest set in Set Rcvd)
        RxdState[$indx]=$RX_EMPTY;                   # store the output state  - set to empty
        RcvdName[$indx]="${ParmName[$indx]}";        # names of the items rcvd - set to pname
        RxdCount[$indx]=0;                           # times item was received - don't copy
        RxdInvld[$indx]=0;                           # if does not match type  - don't copy
        RxdValue[$indx]="";                          # last param. value rcvd  - don't copy
        RxdIndex[$indx]="";                          # index in command line   - don't copy
        RxdNmOpt[$indx]="";                          # names of optns rcvd.: -i --input [should be 0 or 1]
        RxdNuOpt[$indx]=0;                           # number options rcvd.: 0|1|2|...  [should be 0 or 1]
        RxdParms[$indx]=0;                           # count of rxd indparms
        RxdOptns[$indx]=0;                           # count of rxd indoptns
    fi; DBG_TRC -x 8 "$indx" "";
} # end Copy Array

#############################################################################
# Function to move one item's array values to another. This is specifically
# used for moving an optional received parm to a required unreceived parm.
# Note: here we effectively are only copying over received related fields.
# In this case the indices are in general not adjoining, so we must know
# the destination index in addition to the source. This is post-processing
# after all the cmd-line items have already been handled (from Shift Parm)
# so we are assured that the RxdState has already been set for the source.
# Note: Datatype fields can't be set here as they haven't been checked yet.
#############################################################################
function  MoveArray() { # MoveArray indx dest
    if [[ ! "$1" ]] || [[ ! "$2" ]] || [[ "$1" == "$2" ]]; then return $FAILURE; fi
    local last=$1; local indx=$2; shift 2;
    DBG_TRC  0x18 "$indx" "MoveArray: src|dst:$last|$indx, more:${MoreIndx[$indx]}";
    # copy the source to destination       # clear out old location   # Set rcvd info (rest set in Set Rcvd)
    RxdState[$indx]=${RxdState[$last]};    RxdState[$last]=$RX_EMPTY; # store the output state : RX_VALID
    RxdCount[$indx]=${RxdCount[$last]};    RxdCount[$last]=0;         # times item was received: 1
    RxdInvld[$indx]=${RxdInvld[$last]};    RxdInvld[$last]=0;         # if does not match type : 0
    RxdValue[$indx]="${RxdValue[$last]}";  RxdValue[$last]='';        # last param. value rcvd :
    RxdIndex[$indx]=${RxdIndex[$last]};    RxdIndex[$last]='';        # index in command line  :
    RxdNmOpt[$indx]=${RxdNmOpt[$last]};    RxdNmOpt[$last]='';        # names of options rcvd. : -i --input [s/b 0]
    RxdNuOpt[$indx]=${RxdNuOpt[$last]};    RxdNuOpt[$last]=0;         # number of options rcvd : 0|1|2|...  [s/b 0]
    RxdParms[$indx]=${RxdParms[$last]};    RxdParms[$last]=0;         # count of rxd indparms  : 0
    RxdOptns[$indx]=${RxdOptns[$last]};    RxdOptns[$last]=0;         # count of rxd indoptns  :
    DBG_TRC -x 0x18 "$indx" "";
} # end Move Array

#############################################################################
# Get Data String can only be called after Set Rcvd sets all data values.
# Note: this function is called by both Set Rcvd and by Print Spec.
#############################################################################
function  GetDataStr()  { # GetDataStr {-t}{-l} ndx rtnvar # get data string at index, -l long output, -t no trail " *"|" +"
    local notl=0; if [[ "$1" == -t ]]; then notl=1; shift; fi
    local long=0; if [[ "$1" == -l ]]; then long=1; shift; fi
    local doloc=$((CfgSet[CF_RGXLOC] != 1)); # NB: invert bool value
    local regx="${DataRegx[$1]}"; # index
    DBG_TRC  19 "$1" "Get DataStr bgn ndx:$ndx";
    local dtyp="${DataType[$1]}"; if [[ ! "$dtyp" ]]; then dtyp=$DATA_IS_NONE; fi
    local val1="${DataVal1[$1]}"; local post="${DataPost[$1]}";
    local val2="${DataVal2[$1]}"; local vstr=""; local lstr="";
    local srch="${DataSrch[$1]}"; local valt="${ValuType[$1]}";
    local dlen; local bgn=''; local end=''; local mid='';    # settings for: SRCH_ALL
    if  ((regx == 0)) || ((doloc == 1)); then
        case "$srch" in
            $SRCH_BGN)  end="$SYMB_LOCS";;                   # bgn :  ...~   (1 value)
            $SRCH_END)  bgn="$SYMB_LOCS";;                   # end : ~...    (1 value)
            $SRCH_GRD)  mid="$SYMB_LOCS";;                   # grid: ..~..   (2 value)
            $SRCH_SLC)  bgn="$SYMB_LOCS"; end="$SYMB_LOCS";
                        mid="$SYMB_LOCS";;                   # grid: ~..~..~ (2 value)
            $SRCH_ANY)  bgn="$SYMB_LOCS"; end="$SYMB_LOCS";; # any : ~...~   (1 value)
        esac
    fi
    if  ((long == 1)); then lstr="${DataText[$dtyp]}";
        if  ((notl == 1)) && [[ "$lstr" =~ " "[+*]$ ]]; then
            dlen=${#lstr};  lstr="${lstr:0:dlen-2}"; fi # remove trailing: " +"|" *"
        if [[ "$lstr" ]];   then lstr=" [$dtyp:$lstr]"; fi
    fi; if [[ "$val1" ]] || [[ "$val2" ]]; then
        local xtrc="${Extracts[$1]}";  # 1|0
        local neg8="${Negation[$1]}";  # 1|0
        local sep="$SYMB_PLAN"; # '@'
        if   (( regx == 1 )); then sep="$SYMB_REGX"; fi # %
        if   (( neg8 == 1 )); then sep="$sep$sep$sep";  # tripled
        elif (( xtrc == 1 )); then sep="$sep$sep";   fi # doubled
        if   ((dtyp == DATA_PERCENT)); then sep="";  fi # N/A here
        if   [[ "$mid" ]];          then vstr="$sep$bgn$val1$mid$val2$end";  # ~..~..~ | ..~..
        elif ((valt == VALU_ENUM)); then vstr="$sep$bgn$val1$end";
        elif [[ ! "$val2" ]];       then vstr="$sep$bgn$val1$end";
        elif ((valt == VALU_RANG)); then vstr="$sep$val1$SYMB_RANG$val2";    # RANG
                                    else vstr="$sep$val1|$val2"; fi
    fi; printf -v "$2" -- "%s" "${DataOpts[$dtyp]}$post$vstr$lstr"; # set o/p var
    DBG_TRC -x 19 "$1" "Get DataStr end ndx:$ndx";
} # end Get DataStr

#############################################################################
# Upd8Ind updates the indparm state machine to see if this is an ind parm.
# 2 cases: OSIP (-f=parm), which only ever has one parm, and the normal case
# (-i|--in prm1 ...), which can have multiple parms and multiple options.
# Init Ind resets all the state variables used by Indp State Processing.
# Rcvd Ind sets all the state variables when an OSIP is received.
# Upd8Ind is the state machine update function called for each item.
#############################################################################
function  InitInd() { # InitInd grpn {from}
    local grpn=$1; shift 1;   if [[ ! "$grpn" ]]; then grpn=0; fi
    IndStat=$IND_EMPT;        # state of searching for an indprm
    IndHead=0; IndOrnu=0;     # head option index of indarm item  # OR'ed group number indp found at
    LstOrnu=0; IndOpts=0;     # OR'ed group number of last option # number of options in this indprm
    IndPrms=0; IndGrpn=$grpn; # number of indparms in this group  # group number this indp prm is on
}

function  RcvdInd() { # RcvdInd indx indp pure parm ornu
    local indx=$1; local indp=$2; local pure=$3; local parm=$4; shift 4;
    local ornu=$1; shift 1; local opts=$IndOpts;
    local mind=$((indp == 1 ? 2 : 1)); # set derived data
    local stat=$((indp == 1 ? IND_OSIP : IND_INDP));
    local head=$((indx - opts + 1));   # if 2 opts, then head is 1 back
    # if > 1 option, need to find its head index
    local jc=$head; while ((jc < indx)); do
        MindIndx[$jc]=$head; MindParm[$jc]=$mind;
        NumOptns[$jc]=$opts; NumParms[$jc]=1; ((jc++));
    done; IndStat=$stat; IndHead=$head; IndGrpn=$grpn; IndOrnu=$ornu; IndPrms=1;
}

function  Upd8Ind() { # Upd8Ind indx name indp pure parm ornu grpn spb4
    local indx=$1; local name=$2; local indp=$3; local pure=$4; shift 4;
    local parm=$1; local ornu=$2; local grpn=$3; local spb4=$4; shift 4;
    # if group number changes or if previous state was IND_OSIP
    # then we need to start over (but we save new group number)
    local stnm=${IndName[$IndStat]}; # debugging only
    DBG_TRC  0x2C "$indx" "Upd8Ind=$stnm ($IndStat): IndGrpn:$IndGrpn, indx:$indx, name:$name, indp:$indp, spb4:$spb4, grpn:$grpn, ornu:$ornu, pure|parm:$pure|$parm";
    if   ((grpn != IndGrpn)) || ((IndStat == IND_OSIP)); then InitInd $grpn "grpn chg"; fi
    if   ((pure == 0)) && ((parm == 0)); then return; fi # nothing to do

    # NB: ensured above that at this point we can't be in: IND_OSIP
    case "$IndStat" in # handle: <-o|--on parm1 parm2 ...>
    $IND_EMPT) # starting state => search for option
        if   ((pure == 1)); then # advance to next state
             IndStat=$IND_OPTN;  IndHead=$indx; # save 1st option
             IndOrnu=$ornu;      LstOrnu=$ornu; IndOpts=1;
             if  ((indp == 2));  then RcvdInd "$indx" 1 "$pure" "$parm" "$ornu"; fi
        fi;;
    $IND_OPTN) # found a option => search for param.
        if   ((pure == 1)); then ((IndOpts++)); # increment options rcvd
             if  ((indp == 2));  then RcvdInd "$indx" 1 "$pure" "$parm" "$ornu"; fi
        # then we must have a parm (& previously option(s)), so advance
        elif ((spb4 == 0));       then InitInd $grpn "opt nosp"; # 2: a mixed parm, restart
        elif ((ornu != LstOrnu)); then InitInd $grpn "opt parm"; # 3: a mixed parm, restart
        else IndStat=$IND_INDP;  ((IndParm++)); fi;;      # advance to the next state
    $IND_INDP) # found a param. => save ind parm.
        if   ((pure == 1)); # fall back to start
        then InitInd $grpn "prm opt"; IndHead=$indx;      # 4: then a new option, so restart
             IndOrnu=$ornu; LstOrnu=$ornu; ((IndOpts++));
             if  ((indp == 2));  then RcvdInd "$indx" 1 "$pure" "$parm" "$ornu"; fi
        elif ((spb4 == 0)); # fall back to start
        then InitInd $grpn "prm ord"; IndHead=$indx;      # 5: then a new option, so restart
             IndOrnu=$ornu; LstOrnu=$ornu;
             if  ((indp == 2));  then RcvdInd "$indx" 1 "$pure" "$parm" "$ornu"; fi
        else ((IndParm++)); fi;;                          # a parm, increment number received
    *)  InitInd $grpn "unk IndStat:$IndStat";;            # go back to searching, reset all flags
    esac; DBG_TRC -x 0x2C "$indx" "state=${IndName[$IndStat]}";
} # end Upd8 Ind

#############################################################################
# Init Opts  adds options to the single letter & multi-letter combos
#            [NB: this can't be called until after the indparms are setup]
# in combining options we exclude long options, SIP BASE, & ind parms
# Note: end of markers may be in NdxOption, but shouldn't be in Short Opts
# as the latter can't be part of single|double letter option combinations
#############################################################################
function  InitOpts() { # InitOpts initializes all letter combos & option structures
    local ic; for ((ic=0; ic < NumOption; ic++)); do
        DBG_TRC  0x46 "$ic" "MultiOp init: $NumOption options"; # doesn't include HELP
        local indx=${NdxOption[$ic]};      local base="${BaseType[$indx]}";
        local srch="${SrchName[$indx]}";   local mind="${MindParm[$indx]}";
        local eomk=$((base == EOM_BASE));  local ship=$((base == SIP_BASE));
        if  ((eomk == 1)) || ((ship == 0)); then if [[ "$srch" == --* ]] || ((mind != 0)); then
            if ((eomk == 0)); then IndOption+="$srch "; fi # only save !eomk
            DBG_TRC -x 0x46 "$ic" ""; continue;            # loop over indp opts
        fi; fi; local len=${#srch}; # NB: these all OPT_BASE by default

        ############################################################
        # For handling SHIP items (NB: Srch Ships set in Set Spec)
        ############################################################
        if  ((ship == 1)); then NdxOfShip+="$indx ";
            ShipOptns[$NumShrtOp]="$srch";       # keep option: -d
            ShipIndex[$NumShipOp]=$indx; ((NumShipOp++)); # keep index, bump total

        ############################################################
        # For combining single letter options we keep 1 global list
        # of single letter options (ShortIndx) which has the index
        # where this option is stored with a count Num ShrtOp. If
        # enabled we loop through this sub-list to match per letter.
        # Note: Short Opts is not to have any ind parm group options.
        ############################################################
        elif ((len == 2)); then # store single letter opt, e.g.: -i
            if  ((CfgSet[CF_MULTOP] == 0)); then # if not disabled
                ShortOpts[$NumShrtOp]="$srch";   # keep option: -v
                ShortIndx[$NumShrtOp]=$indx;     # keep option index
                ((NumShrtOp++));                 # bump total
            fi

        ############################################################
        # Store double letter options: Note: bash 3.x doesn't support
        # assoc. arrays, so convert the letter to ASCII number for an
        # index, e.g.: 'c'=>99, so -ca -cb => TwoLtrOpt[99]=> " a b "
        # then for multi-letter options from cmd-line check if first
        # letter is in TwoLtrOpt & go thru remaining letters to see
        # if each is in the string stored at that index of TwoLtrOpt
        ############################################################
        elif ((len > 2)); then   # store dual letter options? e.g.: -ca
            LongOptns+="$srch "; # add => "-ca " to "... "
            if  ((len == 3)) && ((CfgSet[CF_MULT2O] == 0)) && # if not disabled
                [[ "$srch" =~ -[A-Za-z]* ]]; then local ltr="${srch:1:1}";
                local ndx; printf  -v ndx "%d" "'$ltr"; # -ca => c => 99 [needs: ']
                TwoLtrNdx[$ndx]+="$indx ";       # store option indices
                ((TwoLtrCnt[ndx]++));            # increment the count
                if ((TwoLtrCnt[ndx] > 1)); then Do2LtrOpt=1; fi
                TwoLtrOpt[$ndx]+="${srch:2:1} "; # add => "a " to "... "
                if [[ "$DualOptns" != *" $ltr "* ]]; then # add if not there
                    DualOptns+="$ltr ";          # add => "c "  to "... "
                fi; if [[ "$DualNmbrs" != *" $ndx "* ]]; then # add if not there
                    DualNmbrs+="$ndx ";          # add => "99 " to "... "
                fi
            fi
        fi; DBG_TRC -x 0x46 "$ic" "";
    done
} # Init Opts

#############################################################################
# State and Link Processing
# Set Mixed  sets the links for a mixed group
# Set IndPrm sets the links for an indirect parameter
# [NB: sometimes ind is set (-f=parm) & sometimes we must determine (-f parm)]
# Each of these functions are called from Init All Item
#############################################################################
function  SetMixed() { # SetMixed bgn end val
    local dbg=0; local name;   local base;   local prev;
    local ic=$1; local end=$2; local val=$3; shift 3;
    if ((ic < end)); then dbg=1; DBG_TRC  0x45 "$ic" "Set Mixed: bgn:$ic, end:$end, val:$val"; fi
    while ((ic < end)); do
        name="${ParmName[$ic]}";  base=${BaseType[$ic]};
        if  ((base == PRM_BASE)); then prev="$NamHidPrm";
            if  [[ "$prev" != *" $name "* ]]; then ((NumHidPrm++)); # only if not already added
                if [[ "$prev" ]]; # check if we're adding first item or another
                then NamHidPrm+="$name "; NdxHidPrm+=" $ic";
                else NamHidPrm=" $name "; NdxHidPrm="$ic";   fi
            fi
        fi; MixedGrp[$ic]=1; LinkIndx[$ic]=$val; ((ic++));
    done; if ((dbg == 1)); then DBG_TRC -x 0x45 "$ic" ""; fi
}

function  SetIndPrm() { # SetIndPrm head endx numo nump
    local indx=$1; if ((indx == -1)); then return $FAILURE; fi
    local head=$head; local name; local base; local srch;
    local endx=$2; local numo=$3; local nump=$4; shift 4;
    local pndx=$((head+numo)); local ostr=""; local full=""; # init as empty

    DBG_TRC  0x43 "$indx" "SetIndPrm: indx:$indx, endx:$endx, numo:$numo, nump:$nump, pndx:$pndx";
    while ((indx < endx)); do name="${DescName[$indx]}"; full+="$name ";
        base=${BaseType[$indx]};   srch=${SrchName[$indx]};
        if   ((base == PRM_BASE)); then IndpNames+="$name "; # add parm name to list
             NdxIndPrm[$NumIndPrm]=$indx; ((NumIndPrm++));
        elif ((base == OPT_BASE)); then   ((NumIndOpt++));
             if [[ "$ostr" ]]; then ostr+="|$srch"; else ostr="$srch"; fi
        fi;  # save ind parm data in each location for consistency
        MindIndx[$indx]=$head; ParmIndx[$indx]=$pndx;
        NumParms[$indx]=$nump; NumOptns[$indx]=$numo;
        # want the counts of numo & nump to decrease as we move forward
        if ((numo > 0)); then ((numo--)); else ((nump--)); fi; ((indx++));
    done;
    IndpOpts[$head]="$ostr"; # shows OR'ed options @ head
    AllItems[$head]="$full"; # remember whole name @ head
    DBG_TRC -x 0x43 "$indx" "";
} # end Set IndPrm

#############################################################################
# Get IndParm is called from Init AllItem in order to loop thru all items
# to determine which items are part of a ind parm & then call Set IndPrm.
# Find where indp flag set: -f=indp [1 parm] || (-f indp ...) [1+ parm]
# Optimized so that Set IndPrm is only called on the last parm of group.
#############################################################################
function  GetIndPrm() { # GetIndPrm finds all items part of indp
    local head=-1; local numo=0; local mind; local nmnd; # unique to Get IndParm
    local grpn=-1; local nump=0; local nugp; local base;
    local ngrp; local lsti=$UNK_BASE;  local ic=1; local jc;
    while ((ic < NumAllItm));  do DBG_TRC  0x42 "$ic" "GetIndPrm: NumAllItm:$NumAllItm";
        grpn=${GroupNum[$ic]}; jc=$((ic+1)); # to check next group
        base=${BaseType[$ic]}; pnam="${ParmName[$ic]}"; # for debug
        mind=${MindParm[$ic]}; head=${MindIndx[$ic]};
        # Note: next items may not exist so we have be to take care
        ngrp=${GroupNum[$jc]}; if [[ ! "$ngrp" ]]; then ngrp=-1; fi
        nmnd=${MindParm[$jc]}; if [[ ! "$ngrp" ]]; then nmnd=0;  fi

        # the 2nd test captures the case: {-f|--file=prm1 prm2}
        nugp=$(((grpn != ngrp) || (mind != nmnd)));
        if ((nugp == 0)); then # need to catch case: -f=in1|-g=in2
             local nbas=${BaseType[$jc]};
             if   ((base == PRM_BASE)) && ((nbas != PRM_BASE)); then nugp=1; fi
        fi;  if   ((base == OPT_BASE));
        then if   ((lsti == PRM_BASE));
             then SetIndPrm "$head" "$jc" "$numo" "$nump"; # nugrp
                  head=-1; numo=0; nump=0; # now start anew
             fi;  ((numo++));
        elif ((base == PRM_BASE)); then ((nump++)); fi
        if   ((mind != 0)); then
             if   ((nugp == 1)) && ((head != -1)); then
                  SetIndPrm "$head" "$jc" "$numo" "$nump"; # save
                  head=-1; numo=0; nump=0; # now start anew
             fi
        else head=-1; numo=0; nump=0; fi; ((ic++)); lsti=$base; # reset counts
        DBG_TRC -x 0x42 "$ic" "GetIndPrm: NumAllItm:$NumAllItm";
    done; # so we never have any unfinished indparm groups
} # end Get IndPrm

#############################################################################
# Get Mixed is called from Init AllItem in order to loop through all items
# to determine perform several linkings. It establishes the linkings for:
# 1. which items are part of a mixed group & then calls Set Mixed
# 2. which items are part of a mored group & then calls Set Mored
# Optimized so Set calls only called on the last item in the group.
#############################################################################
function  GetMixed() { # GetMixed finds all items part of a mixed group
    local link=-1; local numo=0; local orgp; local ornb; local mixd=0;
    local grpn=-1; local nump=0; local nugp; local base; local ic=1; local jc;
    while ((ic < NumAllItm)); do DBG_TRC  0x44 "$ic" "GetMixed: NumAllItm:$NumAllItm";
        grpn=${GroupNum[$ic]};  jc=$((ic+1)); #more=${MoreIndx[$jc]};
        base=${BaseType[$ic]};  pnam="${ParmName[$ic]}"; # for debug
        # Note: next items may not exist so we have be to take care
        ngrp=${GroupNum[$jc]};  if [[ ! "$ngrp" ]]; then ngrp=-1; fi
        nugp=$((grpn != ngrp)); # here this is redundant: || (link != nlnk)
        if   ((nugp == 1)); then bgn=$ic; fi # save starting index of group
        orgp=${Ored_Grp[$ic]};  link=${LinkIndx[$ic]};  # update group & link
        if   ((base == OPT_BASE)); then ((numo++));
        elif ((base == PRM_BASE)); then ((nump++));
             if   ((orgp == 1));   then ((mixd++)); fi  # note if it's a mixed group
        fi;  if   ((nugp == 1)); then      # then update last group
             if   ((link != -1)) && ((mixd > 0));
             then SetMixed "$link" "$jc"  "$link"; fi
             link=$ic; numo=0; nump=0; mixd=0; # reset for new group
        fi;  DBG_TRC -x 0x44 "$ic" ""; ((ic++));
    done; # in this case we never have any unfinished mixed groups
} # end Get Mixed

#############################################################################
# Get BgnPrm is called from Init AllItem in order to loop through all items
# to determine which parms are part of the bgn parms vs. in the end parms.
# Once we see an option, all remaining parameters are put in the end bin.
# Note: OR'ed groups even if required are individually still optional, thus
# any positional parm in a Mixed group will be put in the ending parm list.
#############################################################################
function  GetBgnPrm() { # GetBgnPrm finds all beginning parms
    local incr=0; local link=-1; local reqd; local nump; local parm; local base;
    local bgnp=1; local llnk=-1; local mixd; local srch; local mind;
    local incr=0; local ic=1;    # ignore ic=0 (that's where we store help)

    while ((ic < NumAllItm));    # set begin & ending parms & what's reqd
    do  DBG_TRC  0x47 "$ic" "Get BgnPrm: ic<NumAllItm:$ic<$NumAllItm parm:${ParmName[$ic]}";
        srch="${SrchName[$ic]}"; mind="${MindParm[$ic]}";
        link="${MindIndx[$ic]}"; mixd="${MixedGrp[$ic]}";
        reqd=${ReqdItem[$ic]};   base="${BaseType[$ic]}"; parm=$((base == PRM_BASE));

        ############################################################
        # 1st search parm ends Bgn Parm collection (never reset bgnp
        # back to 1) this will include both pure opts & ind parm opt;
        # Note: the parm part of indp is collected under options, so we
        # we don't need to count them with the counts of pos. parms.
        # Num Parms is for ind parms, +1 is for pure opts; exclude any-
        # thing in a multi-ind parm, mixed items (m|-i), or ind parm.
        ############################################################
        if  [[ "$srch" ]]; then bgnp=0; # search items can't be begin parms
            if  ((reqd == 1)) && ((mixd == 0)); then # ignore mixed, never truly required
                if ((link == -1)) || ((link == ic));
                then nump=${NumParms[$ic]}; ((NumReqOpt += (nump+1))); fi
            fi

        ############################################################
        # NB: NumHidPrm is set in Set Mixed
        # NB: NumIndPrm & NdxIndPrm[] are set in Set IndPrm
        # Following is no longer the case, now optional parms in bgn
        #if ((reqd == 0)); then bgnp=0; fi # 1st opt. parm puts us in end parms
        ############################################################
        elif ((parm == 1)); then # only deal now with parms
            if   ((mind != 0)); then bgnp=0;
            elif ((mixd == 1)); then bgnp=0;      # don't allow mixed items in bgn parms
                     NdxEndPrm[$NumEndPrm]=$ic; ((NumEndPrm++)); ((EndOptPrm++)); # always opt. & end
            elif ((reqd == 1)); then NdxReqPrm+="$ic "; ((NumPrmReq++));
                if  ((bgnp == 1)); # NB: with all NumBgnPrm required: NumBgnReq=NumBgnPrm
                then NdxBgnPrm[$NumBgnPrm]=$ic; ((NumBgnPrm++)); ((NumReqBgn++));     BgnParam[$ic]=1;
                else NdxEndPrm[$NumEndPrm]=$ic; ((NumEndPrm++)); ((NumReqEnd++)); fi #BgnParam[$ic]=0; # set in Set Spec
            else if ((bgnp == 1)); # NB: with all NumBgnPrm required: NumBgnReq=NumBgnPrm
                then NdxBgnPrm[$NumBgnPrm]=$ic; ((NumBgnPrm++));   BgnParam[$ic]=1;
                else NdxEndPrm[$NumEndPrm]=$ic; ((NumEndPrm++)); ((EndOptPrm++)); fi #BgnParam[$ic]=0; # set in Set Spec
            fi
        else bgnp=0; fi; llnk=$link;
        DBG_TRC -x 0x47 "$ic" ""; ((ic++));           # update all loop variables
    done; # initially all set to same
    RemReqOpt=$NumReqOpt; # number of the required options that we need to find
    RemReqPrm=$NumPrmReq; # number of the required all parm that we need to find
    RemReqBgn=$NumReqBgn; # number of the required bgn parm that we need to find
    RemReqEnd=$NumReqEnd; # number of the required end parm that we need to find
} # end Get BgnPrm

#############################################################################
# Init All Optimized Lists takes care of setting up several arrays and lists
# which can only easily be done after all specified items are already set.
# This specifically applies to: (1) Indirect Parms, (2) OR'ed groups (especially
# Mixed groups), (3) Option Combos (which requires IndParms to be setup), &
# (4) Beginning vs. Ending Parm determination. The first 2 initializations
# (Get IndPrm & Get Mixed) are affected by the group number & a new OR flag.
#############################################################################
function  InitLists() { # inits all parms for optimized lists
    DBG_TRC  0x41 "InitLists: NumAllItm:$NumAllItm";
    GetIndPrm; GetMixed; # find all IndParm groups & all the Mixed groups
    InitOpts;            # after indparms setup, now we can setup options
    GetBgnPrm;           # after GetMixed see where parm go: bgn|end parm
    DBG_TRC -x 0x41;     # for any item
}

#############################################################################
# OptName is called prior to Set Spec so the stored names can't be used here.
# OptName forms the name: parm => parm; -i parm => parm; -o => _o (or: o); and
# --arg-parse => __arg_parse (or: arg_parse); NB: the latter 2 'or:' names
# (i.e.: o & arg_parse) only occur when CF_LDUSNO=1 (-cl) config is enabled
# EOBP (-+) & EOOM (--) are special and are specifically not changed
# onam: "-i n" => n, "-i" => _i, "n" => n, -d= => _d
#############################################################################
function  OptName() { # {-o} name # -o get ind opt name # i.e. GetOptName
    local getopt=0; if [ $# -gt 1 ] && [[ "$1" == "-o" ]]; then getopt=1; shift; fi
    # Note: need to save a copy of input name which we don't save, so save in _tmp
    local onam; local _tmp="$1"; DBG_TRC  0x29 "$_tmp" "OptName: nam:$_tmp, -o:$getopt";
    if  ((getopt == 1)); then onam="${1%% *}";          # get 1st word in case (ind opt)
        if  [[ "$onam" == *"$SYMB_INDP"* ]]; then       # was SYMB_NUMB='#', now '='
            if   [[ "$onam" =~ (.*)[{]"$SYMB_INDP"[}] ]]; then onam="${BASH_REMATCH[1]}";
            elif [[ "$onam" =~ (.*)"$SYMB_INDP" ]];       then onam="${BASH_REMATCH[1]}"; fi
        fi
    else onam="$1"; # shift;
        local sep=' ';  local oifs="$IFS";    IFS="$sep";
        local arr=($@); local num=${#arr[@]}; IFS="$oifs";
        if   ((num <= 1)) && [[ "$1" == -* ]];  # if only optn
        then onam="${1%% *}";                   # get 1st word
        elif ((num >  1)) && [[ "$1" == -* ]];  # get 2nd word
        then onam="${1#* }";  # faster to delete 1st column than to cut
            if   [[ "$onam" == "$1" ]]; then onam=""; fi # no separator, past end (empty)
        fi  # else default: onam="$1";          # now check if we need to split onam
        if  [[ "$onam" == *"$SYMB_INDP"* ]]; then   # was SYMB_NUMB='#', now '='
            if   [[ "$onam" =~ (.*)[{]"$SYMB_INDP"[}] ]]; then onam="${BASH_REMATCH[1]}";
            elif [[ "$onam" =~ (.*)"$SYMB_INDP" ]];       then onam="${BASH_REMATCH[1]}"; fi
        fi

        #-------------------------------------
        # do the option name translations here
        # 1. trailing + => _plus
        # 2. anywhere - => _
        # 3. del ldg. _ => "" [iff CF_LDUSNO=1]
        #-------------------------------------
        # don't incidentally replace any internal|leading '+'s (user error)
        if  [[ "$onam" =~ ([+]+)$ ]];
            then local oend="${BASH_REMATCH[1]}"; # capture all end '+'
            onam=${onam%$oend};    # remove consecutive plus's from end
            oend=${oend//+/_plus}; # change all trailing '+' => '_plus'
            onam+="$oend";         # now we can add back translated end
        fi  # Note: this could result in: -o_plus_plus...
        if  [[ "$onam" == *"-"* ]]; then onam=${onam//-/_}; fi # all - => _
        # NB: remove all leading dashes, but only if something is left
        if  ((CfgSet[CF_LDUSNO] == 1)) && [[ "$onam" =~ ^_[_]*(.*) ]];
        then if [[ "${BASH_REMATCH[1]}" ]]; then onam="${BASH_REMATCH[1]}"; fi; fi
    fi; DBG_TRC -x 0x29 "$_tmp" "OptName: nam='$onam'"; TMP="$onam"; # global
} # end Opt Name

#############################################################################
# Print Routines (print to error, not to stdio)
# If don't want to print num, pass num as: ""
# NB: using -o str with GetName in while loop does not work, so write to TMP
#############################################################################
function  PrintOptNdx() { # called by Print Spec
    if  ((DbgPrt == 0)); then return; fi # else print extra debug info
    local nbp; local sbp; local ic=0;
    local nop; local sop; local jc=0;
    local nip; local sip; local mc=0;
    local nep; local sep; local kc=0;
    local nso; local sso; local lc=0;
    local nsh; local shn; local oc=0;
    local ndo; local sdo; local nc=0; local ndx;
    local purOp=$(( NumOption > NumIndPrm ? (NumOption-NumIndPrm) : 0)); # debug only val
    DBG_TRC  0x49 "$ic" "PrintOptNdx: pure opts=$purOp";

    local reqdParm="";  if ((NumPrmReq > 0 )); then reqdParm="ReqPrm[$NumPrmReq]|"; fi
    local rxendopt="~"; if [[ "$EndOptRxd" ]]; then rxendopt="="; fi # def. calculated
    local rxendbgn="~"; if [[ "$EndBgnRxd" ]]; then rxendbgn="="; fi # def. calculated

    local shp="$NamHidPrm"; local len=${#shp}; local hdns="";
    local nhp="$NdxHidPrm"; shp="${shp:1:len-2}"; # discard 1st & lst space
    local hdn=0; if [[ "$shp" ]] || ((nhp > 0)); then hdn=1; fi
    if  ((hdn == 1)); then nhp="($nhp)"; shp="($shp)"; hdns="|Hidp[$NumHidPrm]"; fi

    while  ((ic < NumBgnPrm));  do  ndx=${NdxBgnPrm[$ic]};
        if ((ic != 0)); then sbp+=" "; fi
        sbp+="${ParmName[$ndx]}";   nbp+=" $ndx"; ((ic++));
    done
    while  ((jc < NumOption));  do  ndx=${NdxOption[$jc]};
        if ((jc != 0)); then sop+=" "; fi
        sop+="${SrchName[$ndx]}";   nop+=" $ndx"; ((jc++));
    done
    while  ((mc < NumIndPrm));  do  ndx=${NdxIndPrm[$mc]};
        if ((mc != 0)); then sip+=" "; fi
        sip+="${DescName[$ndx]}";   nip+=" $ndx"; ((mc++));
    done
    while  ((kc < NumEndPrm));  do  ndx=${NdxEndPrm[$kc]};
        if ((kc != 0)); then sep+=" "; fi
        sep+="${ParmName[$ndx]}";   nep+=" $ndx"; ((kc++));
    done

    printf "ItemIndex: $nbp |$nop |$nip |$nep $nhp\n"; # indices
    printf "ItemNames: [%s][%s][%s][%s] %s\n" "$sbp" "$sop" "$sip" "$sep" "$shp"; # vals
    printf "ItemCount: BgnPrm[%d]|Opts[%d]|Indp[%d]|EndPrm[%d]%s\n" \
"$NumBgnPrm" "$NumOption" "$NumIndPrm" "$NumEndPrm" "$hdns";
    printf "ReqdItems: ${reqdParm}RemReqPrm[%d]|RemReqBgn[%d]|RemReqEnd[%d]|RemReqOpt[%d]|EndBgn|Opt:%s%d|%s%d\n" \
"$RemReqPrm" "$RemReqBgn" "$RemReqEnd" "$RemReqOpt" "$rxendbgn" $OPTBGN "$rxendopt" $OPTEND;
    printf "OptlItems: $EndOptPrm[%d]|NumRxdOpt[%d]\n" \
"$EndOptPrm" "$NumRxdOpt" ;

    if  ((NumShipOp > 0)); then   # only print if have SHIP Items
        while ((oc < NumShipOp)); do nsh+=" ${ShipIndex[$oc]}"; ((oc++));
        done; printf "SrchShips:$nsh [$SrchShips]\n"; # e.g.: ShipOptns: 1 2 [ -b -c ]
    fi

    # combine single option list with ind option list for display if possible
    local str; local nst;
    local indop=0; if [[ "$IndOption" != " " ]]; then indop=1; fi
    if  ((NumShrtOp > 0)); then   # only print if multi-single-op enabled
        while ((lc < NumShrtOp)); do str="${ShortOpts[$lc]}";
            sso+=" $str"; nso+=" ${ShortIndx[$lc]}"; ((lc++));
        done; if ((indop == 1));
        then printf "SinglOpts:$nso [$sso ] IndOp [$IndOption]\n";
        else printf "SinglOpts:$nso [$sso ]\n"; fi
    elif ((indop == 1)); then printf "IndOpList: [$IndOption]\n"; fi

    # e.g.: Dual_Opts: -v -i -j -e @ 2 5 6 8
    if  ((CfgSet[CF_MULT2O] == 0)); then # only print if multi-dual-op enabled
        local n=0; local off; local arr=($DualOptns); # arrayize
        for ndx in $DualNmbrs; do                     # format: " 105 "
            ndo=${arr[$n]};  ((n++));                 # get nth opt, e.g.: c
            sdo="${TwoLtrOpt[$ndx]}";                 # numitem -o cnt "$sdo"
            off="${TwoLtrNdx[$ndx]}";                 # get number items
            local sep=' ';    local oifs="$IFS";      IFS="$sep";
            local arr=($sdo); local cnt=${#arr[@]};   IFS="$oifs";
            if  ((cnt > 1));  then printf "Dual_Opts: -$ndo : %s[ %s]\n" "$off" "$sdo"; fi
        done
    fi; if  ((CfgSet[CF_ECHONO] == 0)); then echo; fi
    DBG_TRC -x 0x49 "$ic" "";
} # end Print OptNdx

#############################################################################
# Chk Ndx Cnts: verifies all calculated array lengths match up and prints a
# warning if they don't. When they don't there is some coding error.
#############################################################################
function  ChkNdxCnts() { # routine to verify counts match up
    local num=$NumAllItm; local sts=$FAILURE; local noerr=0; # debug flag
    local sum=$((NumFunctn+NumBgnPrm+NumOption+NumIndPrm+NumEndPrm));
    if   ((sum == num)); then return $SUCCESS; fi
    local Hidp=$NumHidPrm; if ((Hidp != 0)); then Hidp="[Hidp=$Hidp]"; else Hidp=""; fi
    if   ((noerr == 1)); then
         printf "Warning: %s s/b=$NumAllItm, is=$sum \
[Fcn=$NumFunctn, BgnPrm=$NumBgnPrm, Opts=$NumOption, Indp=$NumIndPrm,\
 EndPrm=$NumEndPrm] $Hidp\n" "${ErrText[$TOSA]}" >&2;
    else PrintErr 0 "$TOSA" "$num" "s/b=$NumAllItm, is=$sum \
[Fcn=$NumFunctn, BgnPrm=$NumBgnPrm, Opts=$NumOption, Indp=$NumIndPrm,\
 EndPrm=$NumEndPrm] $Hidp" >&2; fi; return $sts;
}

###########################################################################
# Check for any specification errors/problems & report (except: MTHS & MULO)
# NB: this is called after Init All Item, so that all indp are setup already.
# NB: if '-+' not specified, calculate OPTBGN by finding lst Beginning Param
# NB: if '--' not specified, calculate OPTEND by finding 1st Required Option
#     [can't do this latter, else we won't handle multiple identical options]
# If no ending required items, then set end of options marker to NumAllItm.
# Set 'last' variables for when we need to check any sequential operation.
###########################################################################
function  ChkSpecItems() { # ChkSpecItems
    local last_optn=-1; local last_parm=-1; local indx;
    local last_link=-1; local last_pnam=""; local pcnt=0;
    local last_bgnp=-1; local ic=1; # skip help option (0)
    while ((ic < NumAllItm)); do indx=$ic; # in case code copied

        ############################################################
        # Get the item's information needed for all the next checks
        ############################################################
        local srch="${SrchName[$ic]}";    local altn="${Alt_Name[$ic]}";
        local dnam="${DescName[$ic]}";    local pnam="${ParmName[$ic]}";
        DBG_TRC  0x4A "$ic" "All Cmdline item: dnam:$dnam, allitem:$NumAllItm";
        local mixd="${MixedGrp[$ic]}";    local link="${LinkIndx[$ic]}";
        local more="${MoreIndx[$ic]}";    local base="${BaseType[$ic]}";
        # Note: pos parms & indp (either type) have parm=1, but not SHIP
        local parm=$((base == PRM_BASE)); local indp="${MindParm[$ic]}";
        local pure=$((base == OPT_BASE)); local indt="${IndpType[$ic]}";
        local ship=$((base == SIP_BASE)); local hsan=${HasAltNm[$ic]};
        local bgnp=${BgnParam[$ic]};
        # Note: any pure or indp (of either type) clearly has an option
        local optn=0; if ((pure == 1)) || ((indp != 0)); then optn=1; fi

        ############################################################
        # Set any derived variables: if no specified '--', then we
        # derive it based on one past last option (pure|indirect)
        # Requires GetBgnPrm in Init Lists to be called before this
        ############################################################
        if  ((OPTBGN == -1)); then
            if   [[ "$srch" == "$SYMB_EOBP" ]]; then OPTBGN=$ic; # was: $((ic+1));
            elif ((bgnp == 1)); then last_bgnp=$((ic+1)); fi # 1-based
        fi
        if  ((OPTEND == -1)); then
            if   [[ "$srch" == "$SYMB_EOOM" ]]; then OPTEND=$ic; # was: $((ic+1));
            elif ((optn == 1)); then last_optn=$((ic+1)); fi # 1-based
        fi

        ############################################################
        # Test 1: a parametered item can't have an alternate name
        # (includes pos. parm & indp (all types), but not SHIP)
        ############################################################
        if  ((parm == 1)); then # a parameter
            if   ((hsan == 1)); then # does it have an alt. name (':')
                 PrintErr $ic "$PALT" $ic "\"$pnam\" has altname: '$altn'" >&2;
            fi

        ############################################################
        # Test 2: no items without parameters can have a data type
        ############################################################
        else local dtyp="${DataType[$ic]}";        # no parm item, get datatype
            if ((dtyp != DATA_IS_NONE)); then      # non-parm with a datatype!
                if   ((ship == 1)); then           # don't support Datatypes for SHIP
                     PrintErr $ic "$DTSH" $ic "$srch SHIP dtyp=$dtyp [must be num|range|listnum]" >&2;
                elif ((mind == 0)); then           # if part of indp parm then it's ok
                     local bnam="${BaseName[$base]}";   local dtxt=${DataText[$dtyp]};
                     if [[ "$dtxt" =~ " "[+*]$ ]]; then local dlen=${#dtxt};
                     dtxt="${dtxt:0:dlen-2}"; fi   # remove trailing: " +"|" *"
                     PrintErr $ic "$DTOP" $ic "$bnam $dnam dtyp=$dtyp [$dtxt]" >&2;
                fi # all non-parms cannot have a datatype
            fi
        fi

        ############################################################
        # Test 3: parm & alt name (if have) must be valid varnames
        # & don't support comma separated OSIP (e.g.: -f=prm1,prm2
        # Note: don't want multiple BNAM errors per item so choose 1
        # Note: have to also check EOOP in case user has changed it
        ############################################################
        if   [[ "$pnam" == *","* ]] && ((indt == IND_OSIP));
        then PrintErr $ic "$MIPC" $ic "OSIP names='$pnam'" >&2;
        elif [[ "$pnam" == *","* ]] && ((parm == 1));
        then PrintErr $ic "$MIPC" $ic "Parm names='$pnam'" >&2;
        elif ((hsan == 1)) && ! is_string "$altn" -v;
            then PrintErr $ic "$BNAM" $ic "altn:'$altn' s/b: [_a-zA-Z][_a-zA-Z0-9]*" >&2;
        elif [[ "$srch" != "$SYMB_EOBP" ]] && [[ "$srch" != "$SYMB_EOOM" ]]; then
            if ! is_string "$pnam" -v; then if [[ "$srch" ]];
                then PrintErr $ic "$BNAM" $ic "optn:'$srch' s/b: [_a-zA-Z][_a-zA-Z0-9]*" >&2;
                else PrintErr $ic "$BNAM" $ic "parm:'$pnam' s/b: [_a-zA-Z][_a-zA-Z0-9]*" >&2; fi
            fi
        fi

        ############################################################
        # Test 4: prevent multiple end markers [done in initial loop]
        # Test 5: only positional parms allowed after option end mark
        # Note: OPTEND initialized to -1, for it can validly be 0
        ############################################################
        if ((OPTEND != -1)) && ((ic >= OPTEND)) && [[ "$srch" ]] &&
           ((parm != 1)) && [[ "$srch" != "$SYMB_EOOM" ]];
        then PrintErr $ic "$OADD" $ic "$srch after $((OPTEND-1))" >&2; fi

        ############################################################
        # Test 6: endless parms can't have any other item after them
        # but must be the last of all items: file ... OR {-f=file ...}
        # Note: the previous parm is the 1 flagged with the more flag
        ############################################################
        if  ((last_parm != -1)); then  # this is generally an error
            if [[ "$srch" != "$SYMB_EOOM" ]]; then # ignore end of opt marker
                PrintErr $ic "$ENDL" $ic "name='$dnam' @ $last_parm" >&2;
                last_parm=-1; # only record error once for each '...'
            fi # else keep the last parm set for next loop
        elif ((more != 0)); then last_parm=$ic; fi

        ############################################################
        # Test 7. within OR'ed group {-v|m|--verb} only allow 1 parm
        # (subsequent ones would never get set, as only 1st taken),
        # but remember to ignore OSIP parms, e.g.: (-f=parm1|m|-a)
        ############################################################
        if  ((mixd == 1)); then if ((last_link != link)); then pcnt=0; fi # reset parm count
            if  ((parm == 1)) && ((indp == 0)); then ((pcnt++));
                if ((pcnt == 1)); then last_pnam="$dnam";  # save copy of 1st name
                else PrintErr $ic "$MORP" $ic "orig|name:$last_pnam|$dnam [$pcnt]" >&2; fi
            fi
        fi

        ############################################################
        # Now we can update the last variables and loop variables
        ############################################################
        last_link=$link; DBG_TRC -x 0x4A "$ic" ""; ((ic++));
    done

    ############################################################
    # Set end of ... markers based on the last item of their kind
    # Note: can't set eoom (OPTEND) based on last specified option
    # otherwise we will miss multiple identical received options
    ############################################################
    if  ((OPTBGN == -1)); then OPTBGN=$((last_bgnp == -1 ? 1 : last_bgnp));
        if   ((last_bgnp >= NumAllItm));
        then DBG_TRC -s 48 $ic "endbp based on the firstItem: OPTBGN:$OPTBGN";
        else DBG_TRC -s 48 $ic "endbp based on last bgnp + 1: OPTBGN:$OPTBGN"; fi
    fi
if [ ]; then # ifdef [see above explanation]
    if  ((OPTEND == -1)); then OPTEND=$((last_optn == -1 ? NumAllItm : last_optn));
        if   ((last_optn >= NumAllItm));
        then DBG_TRC -s 48 $ic "endop based on NumberAllItem: OPTEND:$OPTEND";
        else DBG_TRC -s 48 $ic "endop based on last optn + 1: OPTEND:$OPTEND"; fi
    fi
fi  # endif
    # now we can do debug printing, always prints something, so raw echo ok
    if  ((DbgPrt == 1)); then PrintOptNdx; PrintCfgSet; echo; fi
} # end Chk SpecItems

#############################################################################
# Whenever we receive one item in an OR'ed group, we need to flag the other
# items that they are no longer required and don't have to be grabbed, but
# we have to be careful with indparms part of an OR'ed group: -f=parm|m|-a
#############################################################################
function  Upd8Ored() { # Upd8Ored indx # called from Set Rcvd
    local indx=$1; shift 1; local link="${LinkIndx[$indx]}";
    if  ((link == -1)); then return $FAILURE; fi # should never happen
    local rcvd; local mind; local base; local pind; local pnam;
    local ic=$link; local llnk=$link; # start at link & move forward while link is the same
    DBG_TRC  22 "$indx" "Upd8Ored: indx:$indx, ic=llnk=link:$link";
    while  [[ "$link" ]] && ((link == llnk)); do # pnam just for debug
        if ((ic != indx)); then pnam="${ParmName[$ic]}"; # skip rcvd index
            rcvd=${RxdCount[$ic]}; mind=${MindParm[$ic]}; base=${BaseType[$ic]};
            pind=$(((mind != 0) && (base == PRM_BASE)));
            if ((rcvd == 0)) && ((pind == 0)); then RxdCount[$ic]=-1; fi # mark can't rx
        fi; ((ic++)); link="${LinkIndx[$ic]}";   # advance to next item
    done; DBG_TRC -x 22 "$indx" "Upd8Ored end: ic:$ic";
}

#############################################################################
# Set Rcvd (was InitRcvd) sets the status of a received command-line item
# NB: For the more interesting cases debugging is enabled by the caller.
# NB: Can't call this in shell, else writes to Arrays vanish on return!
# The invd parameter is the enum of type INV_....
#############################################################################
function  SetRcvd() { # SetRcvd indx cmdl "valu" invd mcnt "from"
    local indx=$1; local cmdl=$2; local valu="$3";  shift 3;
    local invd=$1; local mcnt=$2; local from="$3";  shift 3; # from for debug
    local more="${MoreIndx[$indx]}";   # to be safe, get more from base index
    if  ((more != 0)); then ((indx+=mcnt)); fi # adjust to next pos. (mcnt is 0-based)
     # grab all needed info for item from its index
    local invm="${InvMsg[$invd]}";    local dtyp="${DataType[$indx]}";
    local link="${LinkIndx[$indx]}";  local mlnk="${MindIndx[$indx]}";
    local base="${BaseType[$indx]}";  local mind="${MindParm[$indx]}";
    local valt="${ValuType[$indx]}";  local numt="${NmbrType[$indx]}";
    local pnam="${ParmName[$indx]}";  local srch="${SrchName[$indx]}";
    local mixd="${MixedGrp[$indx]}";  local ored="${Ored_Grp[$indx]}";
    local reqd=${ReqdItem[$indx]};    local parm=$((base == PRM_BASE));
    local pure=$((base == OPT_BASE)); local bstr="${BaseName[$base]}";
    local ship=$((base == SIP_BASE));

    DBG_TRC  6 "$indx" "Set Rcvd $from: pnam:$pnam, ndx|cmdl:$indx|$cmdl, val:$valu, more|mcnt=$more|$mcnt, inv='$invm', base=$bstr";
    DBG_TRC  7 "$valu" "Set Rcvd $from: pnam:$pnam, ndx|cmdl:$indx|$cmdl, val:$valu, more|mcnt=$more|$mcnt, inv='$invm', base=$bstr";

    ############################################################
    # Get proper value of the received item based on its type
    # Always get the extracted value if we have it; note that
    # we need to get the extracted value (not received value)
    # which comes from the last call to is number or is string
    # (by Range Num or Range Str from Match Data call)
    ############################################################
    if   ((pure == 1)); then valu=1; # pure opt use '1' for valu, not option
    elif ((ship == 1)); then valu="${valu/$srch/}"; # rm src (-d)
    elif ((numt == NUM_NAN)); then
         if [[ "$XTRCSTR" ]]; then valu=$XTRCSTR; fi
    else if [[ "$XTRCNUM" ]]; then valu=$XTRCNUM; fi; fi

    ############################################################
    # Set the derived values: rxdname=basename_n (1-based)
    # Update received counts & name & index lists
    ############################################################
    if  ((more != 0)); then RcvdName[$indx]="${pnam}_$((mcnt+1))"; fi
    local rcnt=${RxdCount[$indx]};     # NB: rcnt may be -1, so can't ++
    if  ((rcnt <= 0)); then rcnt=1;    # catch first rxd of an option
        if  [[ "$srch" ]]; then        # add to received option array
            RcvdOptns+="$srch ";       # add search string to the list
            NdxRxdOpt[$NumRxdOpt]=$indx; ((NumRxdOpt++));
        fi
    else ((rcnt++)); fi                # increment count & save it
    RxdCount[$indx]="$rcnt";           # update count & set Rxd Index
    RxdInvld[$indx]="$invd";           # if rcvd value was invalid data type

    ############################################################
    # Update ind parm counts & 'required' & 'optional' counts
    # Note: BgnParm are all required so we don't 'count' them
    ############################################################
    if  ((mind != 0)) && ((mlnk != -1)); then
        if   ((pure == 1)); then ((RxdOptns[mlnk]++));
        elif ((parm == 1)); then ((RxdParms[mlnk]++)); fi
    fi
    if  ((reqd == 1)); then
        if [[ "$srch" ]]; then
            if  ((RemReqOpt > 0)); then ((RemReqOpt--)); fi
        elif    ((parm == 1)); then
            if  ((mixd == 0)) && ((mind == 0)); then
                NdxReqPrm="${NdxReqPrm/ $indx/}"; # remove indx from list
                if  ((RemReqPrm > 0)); then ((RemReqPrm--)); fi
                local bgnPrm=${BgnParam[$indx]};  if ((bgnPrm == 1));
                then if ((RemReqBgn > 0)); then ((RemReqBgn--)); fi
                else if ((RemReqEnd > 0)); then ((RemReqEnd--)); fi; fi
            fi
        fi
    else # thus optional : keep track of optional parms rcvd
        if [[ ! "$srch" ]] && ((parm == 1)) && ((mixd == 0));
        then RxOptParm+=" $indx"; ((RxdOptPrm++)); fi
    fi

    ############################################################
    # Set link-related items
    ############################################################
    if ((link != -1)) && ((pure == 1)); then
        RxdNmOpt[$link]+=" $srch"; # names of optns rcvd.: -i --input
        ((RxdNuOpt[$link]++));     # number options rcvd.: 0|1|2|...
    fi # end if valid link

    ############################################################
    # De-quote any received value
    ############################################################
    local n=${#valu};  # dequote it
    if  ((n > 1)); then local bgn="${valu:0:1}"; local end="${valu:$n-1:1}";
        if ( [[ "$bgn" == "'" ]] || [[ "$bgn" == '"' ]] ) && [[ "$bgn" == "$end" ]];
        then valu="${valu:1:$n-2}"; fi # now dequoted
    fi

    ############################################################
    # Save all received info: value & index & update rcvd count
    ############################################################
    if   ((rcnt > 1)); then
         RxdIndex[$indx]+=",$cmdl";         # construct a string of indices
         if ((ship == 1)) || (( (parm == 1) && (mind != 0) )); # only grab all values for indparm
         then RxdValue[$indx]+="=$valu";    # write received value (put on end w/ =)
         else RxdValue[$indx]="$valu"; fi   # could be pure option (thus 1 value)
    else RxdIndex[$indx]="$cmdl";           # store its position in command line
         RxdValue[$indx]="$valu";           # write received value (1st value)
    fi

    ############################################################
    # Check if invalid (from mismatch) & get mismatch error info
    # NB: certain errors have already been logged, so skip them
    ############################################################
    if  ((invd != INV_GOOD)) && ((invd != INV_OSIP)); then local dstr="";
        GetDataStr -t -l $indx dstr; # get data string & store in dstr
        local err="${InvErr[$invd]}"; local name="${RcvdName[$indx]}";
        if ((invd == INV_MTCH)) && ((numt == NUM_NAN)); then err=$PFER; fi
        if [[ "$dstr" ]]; then dstr=", s/b: $dstr was"; fi # quote even if ship
        PrintErr $indx "$err" "$indx" "$from $invm$dstr: $name='$valu'" >&2;
    fi

    ############################################################
    # Copy Array: if an endless parm, then need to copy forward=1
    # Remember to see if we need to extend number of total items
    ############################################################
    if  ((more != 0)); then CopyArray "$indx"; fi
    local add=$((indx-NumAllItm+1)); # should be 0|1
    if  ((add > 0));   then ((NumAllItm += add)); fi

    ############################################################
    # Only set the output state after we have copied forward:
    # if received, then overwrite Output State from its default
    # (default for ost8 set in Set Spec to: RX_MISSN : RX_EMPTY)
    # NB: but ensure we don't overwrite an invalid data status
    # Then update state for other items in any OR'ed group.
    ############################################################
    local ost8=$((rcnt == 1 ? RX_VALID : RX_2MANY)); # latter: rcnt > 1
          ost8=$((invd != 0 ? RX_INVLD : ost8)); # preserve if invalid
    RxdState[$indx]="$ost8"; if ((ored != 0)); then Upd8Ored $indx; fi
    DBG_TRC -x 6 "$indx" ""; # don't put this on the same line with
    DBG_TRC -x 7 "$valu" ""; # next line, it messes up dbgenum greps
} # end Set Rcvd

#############################################################################
# Print Spec prints the specified items [for debugging only]
#############################################################################
function  PrintSpec() { # PrintSpec {-n} opts # print parsed specification, -n no indent
    local opts="$@"; local cnt=$NumAllItm; # NB: 10 is 0-9, 11 is 00-10
    local namw=0; local nth=1; local link=-1; local pink=-1;
    local srcw=0; local pth=1; local llnk=-1; local plnk=-1;
    local shoNum=${CfgSet[$CF_ROWNUM]};
    local nowrap=${CfgSet[$CF_NOWRAP]}; local ic=0;

    while ((ic < cnt)); do # pre-pass to get max field width of name & srch
          local srch="\"${SrchName[$ic]}\""; # option quoted (in case empty)
          local name="${ParmName[$ic]}"; ((ic++)); # advance to next item
          local srcl=${#srch}; if ((srcl > srcw)); then srcw=$srcl; fi
          local naml=${#name}; if ((naml > namw)); then namw=$naml; fi
    done; ((namw+=2)); ((srcw+=2)); ic=0;
    if  ((CfgSet[CF_ECHONO] == 0)); then echo; ((NbEcho++)); fi
    if  ((nowrap == 0));
    then  echo "$SPCLIN $opts" | Indent -e -s ":" -m 100; # fold -s -w $COLS;
    else  echo "$SPCLIN $opts"; fi

    while ((ic < cnt)); do local name="${ParmName[$ic]}"; # final pass to print data
        local altn="${Alt_Name[$ic]}";     local srch="\"${SrchName[$ic]}\"";
        DBG_TRC  0x48 "$ic"  "Print Spec: name:$name, srch:$srch";
        llnk=$link; link=${LinkIndx[$ic]}; local nump="${NumParms[$ic]}";
        plnk=$pink; pink=${ParmIndx[$ic]}; local mind="${MindParm[$ic]}";
        local reqd="${ReqdItem[$ic]}";     local dstr; GetDataStr $ic dstr;
        local regx="${DataRegx[$ic]}";     local base="${BaseType[$ic]}";
        local more="${MoreIndx[$ic]}";     local type="${BaseName[$base]}";
        local mixd="${MixedGrp[$ic]}";     local grpn=${GroupNum[$ic]};
        local ornb=${Ored_Num[$ic]};       local ored=${Ored_Grp[$ic]};
        local bprm=${BgnParam[$ic]};       local parm=$((base == PRM_BASE));
        local typstr="[$type]";            local mixstr="$typstr";
        local opnm="$name"; if [[ "$altn" ]]; then opnm="$altn"; fi

        ############################################################
        # set any derived information fields
        # typstr & mixstr are defaulted to: empty, opt, sip, prm
        ############################################################
        local tstr=""; local ostr=" "; local lstr="     "; local pstr="";
        if   ((regx == 1));  then pstr="regx"; fi
        if ((link != llnk)); then nth=1; else ((nth++)); fi
        if ((pink != plnk)); then pth=1; else ((pth++)); fi
        if   ((more != 0));  then mixstr="[mor]"; # NB: followed by: [ind]|[prm]
        elif ((mind == 2));  then mixstr="[osi]"; # NB: indparm take precedence
        elif ((mind == 1));  then mixstr="[ind]"; # NB: indparm take precedence
        elif ((mixd == 1));  then mixstr="[mix]";
        elif ((ored == 1));  then mixstr="[org]";
        elif ((bprm == 1));  then mixstr="[bgn]";
        elif ((parm == 1));  then mixstr="[end]"; fi
        if   ((mind == 2));  then ostr="=";     # " 1:01=" (OSIP indparm has precedence)
        elif ((mind == 1));  then ostr=":";     # " 1:01:" (Norm indparm has precedence)
        elif ((ored != 0));  then ostr="|"; fi  # " 1:01|"
        if   [[ "$dstr" ]];  then tstr+="[$dstr]"; fi
        if   [[ "$pstr" ]];  then tstr+="[$pstr]"; fi
        if   ((pink >= 0));  then printf -v lstr "%2d:%02d" "$pink" "$pth";
        elif ((link >= 0));  then printf -v lstr "%2d:%02d" "$link" "$nth"; fi

        ############################################################
        # now we're ready to print the entry's data
        ############################################################
        local rstr="reqd";   if ((reqd == 0)); then rstr="optn"; fi
        if ((shoNum == 1)); # print item num: -cr #  0 opt[0]: func
        then printf "%2d %s[%02d]: %-"$namw"s%-"$srcw"s%s%s\n" $ic  "$rstr" \
                   $grpn "$opnm" "$srch" "$lstr$ostr$mixstr$typstr" "$tstr";
        else printf     "%s[%02d]: %-"$namw"s%-"$srcw"s%s%s\n"      "$rstr" \
                   $grpn "$opnm" "$srch" "$lstr$ostr$mixstr$typstr" "$tstr";
        fi; DBG_TRC -x 0x48 "$ic" ""; ((ic++));
    done; if  ((CfgSet[CF_ECHONO] == 0)); then echo; fi
} # end Print Spec

#############################################################################
# Match Err searches for the enum if found (at the supplied ic if ic != 1)
# e.g.: the 1st (i.e. former) will be suppressed by the 2nd (i.e. latter)
# 01 [DVUN]: DataValu unsupported for dtype: ~ni @ 1 [not supported] val='bad opts: i'
# 01 [DTOP]: Options don't support Datatype: opt -o~ni dtyp=15 [a pos/neg. number]
#############################################################################
function  MatchErr() { # MatchErr ndx enum # returns success if found
    local ndx=$1; local enum=$2; shift 2;
    local got=$FAILURE; local find; local loc; TMP=0;
    for ((ic=0; (ic < NumErrors) && (got == FAILURE); ic++)); do find=${ParsEnum[$ic]};
        if  ((find == enum)); then loc="${ParseErr[$ic]}"; loc="${loc/ */}"; # get index
            if ((ndx == -1)) || ((ndx == loc)); # if ndx is the same or don't care
            then got=$SUCCESS; TMP=$ic; fi # else keep searching
        fi
    done; return $got;
}

#############################################################################
# Print Err saves error in Parse Err array to be printed later or if -p option
# it will print the error immediately and not save it causing getparms to quit
# because NumErrors > 0. Note: nums may be empty, just used for sub-cases where
# we print the index, which is why we can't combine it with the index itself.
# At the same time Print Err also does error filtering so one error doesn't
# unnecessarily cause other errors. These cases are 'filtered' out when
# detected and only the main error recorded/printed. For example when we have
# 2 options that are specified with the same search pattern (e.g. '-i'), then
# we would always see the following 2 errors, the latter of which can be filtered:
# 04 [MULO]: Multiple option with same name: --
# 04 [MULP]: Multiple output names are same: __ @ 2 & 4
#
# Filter out errors which are overshadowed by other errors on the same index:
# [BNAM]: Item's name contains bad chars & MORP Multiple parm in a Mixed group
# [MIPP]: Missing parm name may cause BNAM when only '=', so discard the latter
# [MRPP]: Missing parm b4 more causes BNAM every time, so discard the latter
# [MULO]: Multiple end opt markers always cause [MULP]: Multiple output names
#########################################################################
function  PrintErr() { # PrintErr {-p}{-m domult ch} indx enum nums {"val"} # -p print
    local msg=""; local bgn=""; local print=0; local domult=0;
    if   [[ "$1" == "-p" ]]; then print=1; shift 1; fi
    if   [[ "$1" == "-m" ]]; then domult=$2; shift 2; fi
    local indx=$1; local enum="$2"; local nums=$3; local val="$4";  shift 4;
    local enam="${ErrName[$enum]}"; # print below: NoErrs:${CfgSet[$CF_NO_ERR]},
    local bad=0; local skip=""; local ic; local item="${val/ */}";  # get 1st word
    if ! [[ "$enum" =~  ^[0-9]+$  ]]; then bad=1;          # not a number
    elif ((enum <= BERR)) || ((enum >= ZERR)); then bad=1; # not in range
    elif [[ ! "${ErrPrnt[$enum]}" ]]; then bad=1; fi       # no enum str.
    if   ((DEV == 1)) && [[ "$TestsNeeded" == *" $enum "* ]];
    then echo "$DEVADD $enum=${ErrText[$enum]}" >&2; fi

    # form the new message here (since we may need for replacement)
    # NB: msg must start with a non-space for Match Err to work right
    if  ((bad == 1)); # not a number | outside range | no enum str.
    then printf -v bgn "%s enum=%s val=%s" "${ErrText[UNDF]}" "$enum" "$val";
    else printf -v bgn "%s %s" "${ErrText[$enum]}" "$val"; fi
    printf -v msg "%02d [%s]: %s\n" "$nums" "$enam" "$bgn";
    DBG_TRC  0x84   "$indx" "PrintErr idx|num:$indx|$num, enum:$enum=$enam, Errs:$NumErrors, domult:$domult";
    DBG_TRC -s 0x84 "$indx" "msg:'$msg'";  # don't need: val:'$val'

    if  ((bad == 1)); then enum=$UNDF;
    else local sind=$indx; local filter=""; local ovrwrt=0; local olde;
        case "$enum" in # filtering cases
        # Following are all where former error should skip latter error (via flag set)
        $ENDL) GotEndl=1;;                 # record so we discard REQD errors after this
        $MRPP) MissPnam[$indx]=$enum;;     # set so we skip any BNAM errs for same index
        $PALT) MissPnam[$indx]=$enum;;     # set so we skip any BNAM errs for same index
        $MIPP) MissPnam[$indx]=$enum;;     # set so we skip any BNAM errs for same index
        # Following are all where latter error should be ignored
        $BNAM) skip="${MissPnam[$indx]}";; # skip if we're missing the ind parm name
        $MORP) if [[ "${GoodName[$indx]}" == 0 ]]; then skip=$BNAM; fi;; # skip if bad name
        $REQD) if (( GotEndl == 1)); then skip=$ENDL; fi;;
        # Following are all where former error should rule over new error
        $MULP) olde=$MULO; filter=$enum;;  # can't use flag here, must be on same index
        # Following are all where latter error should overwrite old error
        $DTOP) olde=$DVUN; ovrwrt=1;;
        esac;
        if   [[ "$filter" ]] && MatchErr $sind $olde; then skip=$filter;
        elif ((ovrwrt == 1)) && MatchErr $sind $olde; then ic=$TMP;
            ParseErr[$ic]=$msg; ParsEnum[$ic]=$enum;
        fi
        if  [[ "$skip" ]]; then # turn off tracing if enabled & return
            DBG_TRC -x 0x84 "$indx" "skipping $enam due to err overshadowed by ${ErrName[$skip]}";
            return; # if skipping, we discard this error so we're done
        fi
    fi

    if ((print == 1)); then printf "%s" "$msg"; else local found=0; # print now, don't store
         #################################################################
         # Check for multiple errors we only want to print first/last of.
         # A repeated error is one where the messages are the same, but
         # for the same item name. For e.g. we keep only one of each of:
         # 01 [MSOR]: Multiple same options received: -i @ 0 1
         # 02 [MSOR]: Multiple same options received: parm @ 3 5
         # Overwriting so Print Err caller keeps running list of indices.
         #################################################################
         local etxt="${ErrText[$enum]}";
         for ((ic=0; (ic < NumErrors) && (found == 0); ic++)); do
            local old=${ParseErr[$ic]}; # removed index from both
            local shold="${old#* }";    # get old msg: "[XXXX]: ..."
            local shmsg="${msg#* }";    # get new msg: "[XXXX]: ..."
            if   [[ "$shmsg" == "$shold" ]]; then found=1; # discard repeated msgs

            ################################################################
            # when get an unknown dual opt (-cxy) want it to display as such
            # & not as error: 03 [UNKI] Unknown parameter was received: -x
            # & with nexterr: 03 [UNKI] Unknown parameter was received: -y
            ################################################################
            elif ((domult != 0)) && [[ "${msg/: */}" == "${old/: */}" ]]; then
                found=1; bgn="${old%:*}";   # rm shortest match from the end
                local   oend="${old/"$bgn: "/}"; oend="${oend/$CR/}"; # discard <cr>
                local   mend="${msg/*: /}"; # discard longest "...: " string
                oend="${oend/-/}"; mend="${mend/-/}"; # discard leading - if present
                ParseErr[$ic]="$bgn: $oend$mend"; # overwrite this msg

            ################################################################
            # when we get multiple errors
            # 04 [MSOR]: Multiple same options received: -- -- @ 3 4
            # 05 [MSOR]: Multiple same options received: -- -- @ 3 4 5
            # want to keep the original row number, i.e. 3 not 5
            ################################################################
            elif ((enum == ParsEnum[ic])); then case  "$enum" in # check special repeats
                $MSOR) local oend=${old/*"$etxt "};         # discard message up to ": "
                       local last="${oend/ */}";            # get first word, e.g.: -i
                       if [[ "$item" == "$last" ]];
                       then ParseErr[$ic]="$msg"; found=1; fi;;
                $ENDL) found=1;;                            # only want first of these
                $OADD) found=1;;                            # only want first of these
                esac
            fi
         done; if ((found == 0)); then # add to errors array if new
             ParseErr[$NumErrors]=$msg; ParsEnum[$NumErrors]=$enum;
             local fatal=${FatalErr[$enum]}; if ((fatal == 1));
             then ((FatalErrs++)); fi; ((NumErrors++));
         fi
    fi; DBG_TRC -x 0x84 "$indx" "";
} # end Print Err

#############################################################################
# Print Errors handles printing all previously stored errors and determining
# the overall return code for getparms. Previously printed via: printf '%s'
# "${ParseErr[@]}"; but now we have entries (e.g.: help) with nothing to print
# & also we need to capture the overall return code. NB: this return code must
# be captured before printing the output array, as the output array printing
# (Print CmdLine) needs the return code from this routine in order to print!
#############################################################################
function  PrintErrors() { # PrintErrors {-n|-b}{-v} result # print all errors
    local vrb=-v; local num="";
    if   [[ "$1" == "-n" ]]; then vrb=""; shift; num=$1;
    elif [[ "$1" == "-b" ]]; then vrb=""; shift; num=$1; fi
    if   [[ "$1" == "-v" ]]; then vrb=$1; shift; fi
    local rslt=$1; shift;   local error=1;
    local warns=1; #local nbEcho=0;
    local doprt=$((CfgSet[CF_NO_ERR] != 1)); # NB: invert bool value
    local ic; local cnt=0; local msg; local enum; local ftl; # fatal
    # must loop thru (even if not printing) to get error code!
    for ((ic=0; ic < NumErrors; ic++)); do
        DBG_TRC  0x85 "$ic" "PrintErrors: error:$rslt, num:$NumErrors, doprt:$doprt";
        msg="${ParseErr[$ic]}"; enum=${ParsEnum[$ic]}; ftl="${FatalErr[$enum]}";  # 0|1
        if   ((enum > rslt)); then rslt=$enum; fi       # take greatest error
        if   ((doprt == 1)) && [[ "$msg" ]]; then
            if   ((ftl == 1)); then # if fatal error
                 if  ((error  == 1)); then error=0;
                     if  ((NbEcho == 0)); then
                         if  ((CfgSet[CF_ECHONO] == 0)); then echo; ((NbEcho++)); fi
                     fi; printf "$ERRMSG $FatalErrs\n" >&2; # only print 1x
                 fi
            else if  ((warns  == 1)); then warns=0;     # just a warning
                     if  ((NbEcho == 0)); then
                         if  ((CfgSet[CF_ECHONO] == 0)); then echo; ((NbEcho++)); fi
                     fi; local warnErrs=$((NumErrors - FatalErrs));
                     printf "$WRNMSG $warnErrs \n" >&2; # only print 1x
                 fi
            fi;  printf "%s" "$msg" >&2; ((cnt++));     # msg already has "\n"
        fi; DBG_TRC -x 0x85 "$ic" "";
    done

    if  ((CfgSet[CF_ECHONO] == 0)); then
        if (( (error == 0) || (warns == 0) )); then echo >&2; fi # need extra c/r at end
    fi; rslt=${ErrMapped[$rslt]}; # map to a standard return code
    if  [[ ! "$rslt" ]]; then rslt=$UNKNOWN; fi # ensure in table

    #################################################################
    # if Analyzing & not suppressing errors, then show status
    # since Analyze mode will not print out Cmd-Line results
    #################################################################
    if  ((CfgSet[CF_ANALYZ] == 1)); then # if Analyze mode
        #local cr="$CR"; if ((CfgSet[CF_ECHONO] == 1)); then cr=$CR; fi
        local vrb=""; if ((DbgPrt == 1)); then vrb="-v"; fi
        ErrStr -r $num $vrb "ANALYZE=$rslt"; printf "$TMP$cr\n"; # std out, not err
    fi; return $rslt;
} # end Print Errors

#############################################################################
# Print Cmd Line : prints the results of all command line processing in
# the configured format. Note it is passed the return status of getparms
#############################################################################
function  PrintCmdLine() { # PrintCmdLine result # prints processed cmd-line
    if ((CfgSet[CF_ANALYZ] == 1)); then return; fi # don't print when Analyzing
    local dohdr=0; if ((CfgSet[CF_BGNSPC] == 1)); then dohdr=1; fi # Print Spec
    DBG_TRC  0x86 "Output rcvd cmd-line: specified items=$NumAllItm";
    local shoNum=${CfgSet[$CF_ROWNUM]};      # -cr : show row numbers
    local shoAll=${CfgSet[$CF_CAPALL]};      # -cc : show unrxd items
    local no_Out=${CfgSet[$CF_NO_OUT]};      # -cq : don't show output (quiet)
    if  ((shoAll == 1)); then no_Out=0; fi   # Note: -cc overrides -cq setting
    local errOpt="-n"; local presh=1; local fail=0; local rxinmax=1; local rxinlen;

    if  [[ "$1" != -1 ]]; then presh=0; fail="$1"; # skip if doing pre-shifted print
        if  ((CfgSet[CF_ECHONO] == 0)); then
            if  ((NbEcho == 0)); then echo; ((NbEcho++)); fi
        fi
        if  ((DbgPrt == 1)); then errOpt+=" -v"; # print extra info if debugging
            local endOptRxd=""; if [[ "$EndOptRxd" ]]; then endOptRxd="[EndOpt $EndOptRxd]"; fi
            local endBgnRxd=""; if [[ "$EndBgnRxd" ]]; then endBgnRxd="[EndBgn $EndBgnRxd]"; fi
            if  ((CmdLineNum == 0)); then printf "RxdInput: 0\n";
            else printf "RxdInput: %d: %s %s%s\n" "$CmdLineNum" "$CmdLineStr" "$endOptRxd" "$endBgnRxd"; fi
        # NB: if "SpecLine:" is printed then we want to separate received input via title
        elif ((dohdr == 1)); then
            local endOptRxd=""; if [[ "$EndOptRxd" ]]; then endOptRxd="[EndOpt $EndOptRxd]"; fi
            local endBgnRxd=""; if [[ "$EndBgnRxd" ]]; then endBgnRxd="[EndBgn $EndBgnRxd]"; fi
            if  ((CmdLineNum == 0)); then printf "RxdInput: \n";
            else printf "RxdInput: %d: %s %s%s\n" "$CmdLineNum" "$CmdLineStr" "$endOptRxd" "$endBgnRxd"; fi
        fi
    else NbEcho=0; fi # reset if printing Shifted command line (not final)
    shift; local bare=$((CfgSet[CF_STATUS] != 1)); # NB: invert bit value

    # if showing numbers then do pre-loop to get longest rcvd index string
    if ((shoNum == 1)); then local ic=0;
        while ((ic < NumAllItm)); do              # print rxd ones
            rcvd="${RxdCount[$ic]}";              # times received
            rcvd=$((rcvd > 0 ? rcvd : 0));        # convert to n|0 (since it may be -1)
            if  ((shoAll == 1)) || ((rcvd > 0));  then # name="${RcvdName[$ic]}"; # debug
                if  ((rcvd >= 1)); then rxinlen="${#RxdIndex[$ic]}";
                    if ((rxinlen > rxinmax)); then rxinmax=$rxinlen; fi
                fi
            fi; ((ic++));
        done
    fi

    #########################################################################
    # 1. if func name has non-varname chars, set to 'func' so eval works
    # 2. get overall status so we can assign & print it: func=0 : SUCCESS
    # 3. mark that we received '0' entry to ensure it always gets printed
    # 4. print any user supplied debug message (supplied from: -cu "text")
    #########################################################################
    if ! is_string "${RcvdName[0]}" -v;  then  RcvdName[0]="func"; fi  # [1]
    ErrStr -r $errOpt "$fail";  local err=$?;  RxdValue[0]="$TMP";     # [2a]
    RxdState[0]=$((err == 0 ? RX_VALID : RX_INVLD));                   # [2b]
    BaseType[0]=$HLP_BASE; #RxdCount[0]=1;    # ensure it gets printed # [3]

    if [[ "$DbgMsg" ]]; then printf -- "%s\n" "$DbgMsg"; fi # user dbg # [4]
    local rcvd; local name; local valu; local base; local rxin; local eomk;
    local pure; local ship; local vstr; local ost8; local ostr; local invd;
    local ic=$presh;  while ((ic < NumAllItm)); # print rxd ones
    do  rcvd="${RxdCount[$ic]}";              # times received
        DBG_TRC -s 0x87 $ic "CfgSet[CF_CAPALL]=$shoAll (ic=$ic): rcvd=$rcvd"; # -cc
        rcvd=$((rcvd > 0 ? rcvd : 0));        # convert to n|0 (since it may be -1)
        if  ((shoAll == 1)) || ((rcvd > 0)) || ((ic == 0)); then # print status [ic=0]
            base="${BaseType[$ic]}";          invd="${RxdInvld[$ic]}";
            name="${RcvdName[$ic]}";          valu="${RxdValue[$ic]}";
            numt="${NmbrType[$ic]}";          eomk=$((base == EOM_BASE));
            pure=$((base == OPT_BASE));       ship=$((base == SIP_BASE));
            if   ((eomk == 1)); then local len=${#name};
                 if ((len == 1)); then name=" $name"; fi # add space before (_ => " _")
            fi
            if   (( ic  == 0)); then vstr="$valu"; # don't quote func status
            elif ((pure == 1)); then vstr="$rcvd"; # or pure opts: 0|1|2|...
            elif ((eomk == 1)); then vstr="$rcvd"; # or endmarker: 0|1|2|...
            elif ((ship == 1)) && ( ((rcvd < 1)) || ((invd != 0)) || [[ ! "$valu" ]] );
            then vstr="\"$valu\"";            # quote if invalid or an empty value
            elif ((rcvd  > 0)) && ((numt != NUM_NAN)); then vstr="$valu"; # don't quote numbers
            else vstr="\"$valu\""; fi         # quote to show as empty
            if   ((bare == 1)); then          # NB: then do normal prints
                 if ((shoNum == 1));          # print row num: -cr
                 then if ((rcvd >= 1)); then rxin="${RxdIndex[$ic]}"; else rxin="-"; fi
                      if [[ ! "$rxin" ]]; then rxin="-"; fi
                      printf "%2d:%-"$rxinmax"s %s=%s\n" $ic "$rxin" "$name" "$vstr";
                 else printf                   "%s=%s\n"             "$name" "$vstr"; fi
            else ost8=${RxdState[$ic]}; ostr=${RxMsgStr[$ost8]}; # use full length
                 if ((shoNum == 1));          # print item num: -cr
                 then if ((rcvd >= 1)); then rxin="${RxdIndex[$ic]}"; else rxin="-"; fi
                      if [[ ! "$rxin" ]]; then rxin="-"; fi
                      printf "%2d:%-"$rxinmax"s %s[%d]: %s=%s\n" $ic "$rxin" "$ostr" $rcvd "$name" "$vstr";
                 else printf          "%s[%d]: %s=%s\n"                      "$ostr" $rcvd "$name" "$vstr"; fi
            fi
        fi; ((ic++)); if ((no_Out == 1)); then break; fi # only show func result
    done; DBG_TRC -x 0x86; # for all items
} # end Print CmdLine

#############################################################################
# Check ChkIndParm checks if we have received a command line IndParm correctly
# Note: should be called only if Mind Parm is set and this is the link index
#############################################################################
function  ChkIndParm() { # ChkIndParm indx more
    local ic=$1; local mor=$2;  shift 2; # more not used but tells us who called us
    local lnk=${MindIndx[$ic]}; local mnd=${MindParm[$ic]};
    local rtn=$(((lnk != ic) || (mnd == 0))); local nam="${DescName[$ic]}"; # for debug
    if  ((rtn == 1)); then return $FAILURE; fi # nothing to do (rtn=0=SUCCESS)
    DBG_TRC  0x83 "$ic" "ChkIndParm ic:$ic, nam:$nam, mor|mnd|lnk:$mor|$mnd|$lnk, rtn=$rtn";

    # don't care about RxdCount, but how many opts & prms rcvd!
    local rop="${RxdOptns[$ic]}"; local req="${ReqdItem[$ic]}";
    local opn="${RxdNmOpt[$ic]}"; local rpm="${RxdParms[$ic]}";
    local nup="${NumParms[$ic]}"; local nop="${NumOptns[$ic]}";
    local mxd="${MixedGrp[$ic]}"; local org="${Ored_Grp[$ic]}";
    local all="${AllItems[$ic]}"; local ops="${IndpOpts[$ic]}";
    local rin="${RxdIndex[$ic]}";
    # if mind part of mixed group then reqd is really optional
    req=$(((req == 1) && (mxd == 0)));  # alter 'required'

    if   ((rop == 0));    then # we can't have rcvd any parms
         if ((req == 1)); then PrintErr $ic "$REQD" $ic "ind opts: $ops" >&2; fi
         rtn=$FAILURE;    # nothing else to do if rop == 0
    elif ((org == 1))  && ((rop >  nop)); then PrintErr $ic "$MIOG" $ic "$opn"  >&2;
         rtn=$FAILURE;    # nothing else to do if rop > nop
    elif ((rop > nop)) && ((CfgSet[CF_DUPOPT] == 0)); # if duplicates not disabled
    then PrintErr $ic "$MSOR" $ic "$nam received ${rop}x @ $rin" >&2; # print 'nx' for times
         rtn=$FAILURE;    # nothing else to do if rop > nop
    # okay rpm > nup as this can happen in 'more' cases
    elif ((rpm < nup));   then PrintErr $ic "$MIPP" $ic "s/b $nup, was $rpm for: $all" >&2;
         rtn=$FAILURE;    # nothing else to do if rpm != nup
    fi;  DBG_TRC -x 0x83 "$ic" "ChkIndParm ic:$ic, mor:$mor, rtn=$rtn";
    return $rtn;
} # end Chk IndParm

#############################################################################
# Called after all Analysis tasks are done, to setup for cmd-line processing
#############################################################################
function  DoBoxingTasks() { # DoBoxingTasks ic save opts
    local ic=$1; local save="$2"; local opts="$opts"; shift 3;
    cdebug on "$TrcBox";                       # do Boxing only tracing
    if [[ "$save" ]] && [[ "$save" == *[^[:space:]]* ]]; then
        PrintErr $ic "$QUNF" $ic "item:'$save' @ $ic [5]" >&2;
    fi; InitLists; ChkNdxCnts; # debug 1st via: -d0x41;
    if ((CfgSet[CF_BGNSPC] == 1)); then PrintSpec "$opts"; fi # print spec array
    ChkSpecItems; cdebug no "$TrcBox"; # if any spec problems, calls Print Err
} # end Do Boxing Tasks

#############################################################################
# Prt ReqNum: debug function to print reqd num parms left from run-time values
# globals used: PrtReq, narg
#############################################################################
function  PrtReqNum() { # PrtReqNum pc # debugging function (traced by caller)
    local pc=$1; if ((PrtReq <= 0)); then return; fi; ((PrtReq--)); # only PrtReq #x
    local cr=""; if ((CfgSet[CF_ECHONO] == 0)); then cr="$CR"; fi
    local reqitm=$((RemReqPrm+RemReqOpt)); local left=$((narg - pc - reqitm));
    printf "PrtReqNum: BgnPrm=$NumBgnPrm, ReqPrm=$NumPrmReq, ReqOpt=$NumReqOpt : RemReq Prm=$RemReqPrm + Opt=$RemReqOpt\n" >&2
    printf "PrtReqNum: narg-pc: ${narg}-${pc}=%d, reqitm=$reqitm, left=$left$cr\n" $((narg - pc)) >&2
}

#############################################################################
# Check if we need to shift any received optional parms into subsequent
# required parm positions. This occurs under the following condition, when
# option follows parm in cmd-line: "func {-i} {prm1} prm2" val1 -i
# Note: If there is no remaining required parms or no received optional parms,
# then there is nothing to do here and we can return immediately.
#############################################################################
function  ShiftParm() { # ShiftParm bgn
    local bgn=$1; shift; cdebug on "$TrcDel";    # bgn:0|1
    if ((TrcShr == 1)); then PrintCmdLine -1; fi # print pre-shifted vals
    DBG_TRC  0x89 "" "ShiftPosPrm: RxdOptPrm|RemReqPrm=$RxdOptPrm|$RemReqPrm, RxOptParm:$RxOptParm, NdxReqPrm:$NdxReqPrm";
    if ((RemReqPrm == 0)) || ((RxdOptPrm == 0));
    then DBG_TRC -x 0x89 "" ""; cdebug no "$TrcDel"; return; fi

    local HaveArr=($RxOptParm); # arrayize list of rcvd opt parm
    local NeedArr=($NdxReqPrm); # arrayize list of need req parm
    local off=0;  local cnt=$RemReqPrm;   if  ((RxdOptPrm > RemReqPrm));
    then  off=$((RxdOptPrm - RemReqPrm)); else  cnt=$RxdOptPrm; fi
    local end=$((off+cnt)); local oth; local src; local dst;
    local srb; local dsb;

    # do in reverse order so we don't overwrite next item
    # but don't allow moving from end parm to begin parm
    local jc=0;  for ((jc=end-1; jc >= off; jc--, cnt--)); do
        oth=$((cnt-1)); src=${HaveArr[$jc]}; dst=${NeedArr[$oth]};
        srb=${BgnParam[$src]}; dsb=${BgnParam[$dst]};
        # only move if both same and match bgn call
        if ((srb == dsb)) && ((bgn == srb)); then
            MoveArray $src $dst; # copies src to dst & clrs out src
            NdxReqPrm="${NdxReqPrm/ $dst/}"; # remove indx from list
        fi
    done; cdebug no "$TrcDel"; DBG_TRC -x 0x89 "" "";
} # end Shift Parm

#############################################################################
# Since we didn't do datatype checking (because we might be shifting the
# parm's location), we do all datatype checking here at the end.
#############################################################################
function  PrmDatatype() { # do all datatype checking of all parms
    local ic=0; local jc; cdebug on "$TrcDel";
    DBG_TRC  0x8A "$ic" "Set PrmDatatype: ic=$ic (name:$dnam)";
    while ((ic < NumAllItm)); do
        local bas=${BaseType[$ic]};  local dnam=${DescName[$ic]}; # debug only
        local rxd=${RxdCount[$ic]};  local prm=$((bas == PRM_BASE));
        if  ((prm == 0)); then ((ic++)); continue; fi # don't look at opts|SHIP
        if  ((rxd <= 0)); then ((ic++)); continue; fi # only look at if was rxd

        ############################################################
        # get the rest of the item's needed information
        # Check if parameter value matches its data type
        # Here we don't clear out errors as they are real.
        # NB: we can't record error until we call Set Rcvd
        ############################################################
        local mnd=${MindParm[$ic]};     local mix=${MixedGrp[$ic]};
        local mor=${MoreIndx[$ic]};     local val=${RxdValue[$ic]};
        DBG_TRC -p 0x8A "$ic" "";
        MatchData $ic "$val"; invd=$?;  # debug with 0x66|0x65
        DBG_TRC -r 0x8A "$ic" "";
        local isnum=${NmbrType[$ic]};   local nuval;
        if  ((isnum == NUM_NAN)); then  nuval="$XTRCSTR";  else nuval="$XTRCNUM"; fi
        if  [[ "$nuval" ]]; then RxdValue[$ic]="$nuval"; fi # else leave as is

        ############################################################
        # Check if invalid (from mismatch) & get mismatch error info
        # NB: certain errors have already been logged, so skip them
        ############################################################
        if  ((invd != INV_GOOD)) && ((invd != INV_OSIP)); then local dstr="";
            local invm="${InvMsg[$invd]}"; #local dtyp="${DataType[$ic]}";
            local name="${RcvdName[$ic]}";  local err="${InvErr[$invd]}";
            RxdInvld[$ic]="$ic";        RxdState[$ic]=$RX_INVLD; # set state
            GetDataStr -t -l $ic dstr;  # get data string & store in dstr
            if ((invd == INV_MTCH)) && ((numt == NUM_NAN)); then err=$PFER; fi
            if [[ "$dstr" ]]; then dstr=", s/b: $dstr was"; fi
            PrintErr $ic "$err" "$ic" "$invm$dstr: $name='$val'" >&2;
        fi; ((ic++));
    done; DBG_TRC -x 0x8A "$ic" ""; cdebug no "$TrcDel";
} # end Prm Datatype

#############################################################################
# Check consistency of command line parameters (but only if no help request)
# - have we got all the required parameters?
# - did we get any parameter more than once?
# - did we get more than 1 'or'ed parameter?
#############################################################################
function  ChkCmdLine() { # Check consistency of command line parameters
    local ic=0; local jc; cdebug on "$TrcDel";
    local prtdbg=$DbgPrt; # flag to only print Prt ReqNum 1x (when debugging)
    while ((ic < NumAllItm)); do  local dnam=${DescName[$ic]};

        ############################################################
        # get the item's information
        ############################################################
        DBG_TRC  0x82 "$ic" "Check CmdLine: ic=$ic (name:$dnam)";
        local rxd=${RxdCount[$ic]};     local req=${ReqdItem[$ic]};
        local lnk=${LinkIndx[$ic]};     local hed=${MindIndx[$ic]};
        local mnd=${MindParm[$ic]};     local mix=${MixedGrp[$ic]};
        local mor=${MoreIndx[$ic]};     local grp=${GroupNum[$ic]};
        local org=${Ored_Grp[$ic]};     local bas=${BaseType[$ic]};
        local prm=$((bas == PRM_BASE)); local opt=$((bas == OPT_BASE));
        #mnd=$(((mnd != 0) && (prm == 1))); # restrict mind group flag

        ############################################################
        # separately handle the cases of 'more' items: parm & indparm
        # 1. parm: only need to check if base item required & not
        #    received (all of the rest are effectively optional)
        # 2. mind: if required, then must have received flag & all
        #    parms, if optional & a flag received, must have all parm
        ############################################################
        if ((mor != 0)); then
            if ((mor == ic)); then # only need to check when on link
                if   ((mnd != 0)); then   # handle more mind: (-f prm ...)
                     ChkIndParm $ic $mor; # debug w/ 0x83
                elif ((req == 1)) && ((rxd == 0)); then
                     PrintErr $ic "$REQD" $ic "more: $dnam" >&2;
                fi
            fi
        elif   ((mnd !=  0)); then # NB: mind items may have link == -1
            if ((hed == ic)); then ChkIndParm $ic $mor; fi # handle mind: (-f prm ...)

        ############################################################
        # check if multiple received for any option, but ignore if
        # duplicate received options error disabled by config (-cd);
        # if pure option use srch name, else use parm name
        # NB: need to specially handle unique case of: rxd=-1
        # Indirect parm are handled in linking case below, not here
        ############################################################
        elif  ((lnk == -1)); then # no MIXD, MORE, or MIND
            if   ((rxd > 1)) && ((CfgSet[CF_DUPOPT] == 0)); then # name: -a|altname|parm
                 PrintErr $ic "$MSOR" $ic "$dnam @ ${RxdIndex[$ic]}" >&2;
            elif ((req == 1)) && ((rxd == 0)); # if none rcvd but 1 required
            then PrintErr $ic "$REQD" $ic "$dnam @ $ic" >&2;
                 if ((prtdbg == 1)); then PrtReqNum $ic; prtdbg=0; fi # print 1x
            fi
        fi

        ############################################################
        # here we handle mixed & unmixed OR'ed groups, specifically:
        # -o|--on and -o|m|-a and -o|m|-a|-i=ind; Note: in the cases
        # where we have an indparm we only need check that the option
        # was received since indparm is checked above, but we must
        # catch the case where it is first as part of an OR'ed group:
        # -i=ind|-o|m|-a; which is why this can't be an elif test
        ############################################################
        if  ((org == 1)) && ((ic == lnk)); then
             local ric="";  local oic="";  local pic="";  local reqd=0;
             local rnam=""; local onam=""; local pnam="";
             local orxd=0; local prxd=0;   local llnk=$lnk; jc=$lnk;
             while (((lnk == llnk)) && ((lnk != -1))); do # do at least once since recounting
                 local nnm=${DescName[$jc]};     local bas=${BaseType[$jc]};
                 local nrq=${ReqdItem[$jc]};     local nrx=${RxdCount[$jc]};
                 local pur=$((bas == OPT_BASE)); local shp=$((bas == SIP_BASE));
                 local opt=$((pur || shp));      local prm=$((bas == PRM_BASE));
                 # NB: we are overwriting the mnd flag set above in the loop
                 # here we want to exclude any mnd parms (options are okay)
                 mnd=${MindParm[$jc]}; mnd=$(((mnd > 0) && (prm == 1)));
                 if  ((mnd == 0)); then
                     if  ((req == 1)); then ((reqd++));
                        rnam+="$nnm "; ric+="$jc ";
                     fi; if  ((nrx > 0)); then # exclude -1 case & indparm
                         if   ((opt == 1)); then ((orxd+=nrx));
                              onam+="$nnm "; oic+="$jc ";
                         elif ((prm == 1)); then ((prxd+=nrx)); # mix=1
                              pnam+="$nnm "; pic+="$jc ";
                         fi
                     fi  # advance to next item and re-get link
                 fi; ((jc++)); lnk=${LinkIndx[$jc]}; # next item
             done # done recalculating rxd, so now we can retest

             ############################################################
             # check errors if > 1 received, or none received but required
             ############################################################
             local  totl=$((orxd + prxd));
             if   ((totl > 1)); # multiple rcvd in OR'ed group
             then PrintErr $ic "$MIOG" $ic "$onam$pnam@ $oic$pic" >&2;
             elif ((reqd > 0)) && ((totl == 0));
             then PrintErr $ic "$REQD" $ic "ored: $rnam@ $ric" >&2; fi
        fi;  DBG_TRC -x 0x82 "$ic" ""; ((ic++));
    done; cdebug no "$TrcDel";
} # end Chk CmdLine

#############################################################################
# Get EndNdx is called right before '--' is added to arrays.
# We need to go thru the Arrays & count the number of items:
# each mixed group is just 1 & indirect parm is 1 + numparm
#############################################################################
function  GetEndNdx() { # GetEndNdx ic # counts number of items
    local ic; local cnt=0; # -- will be 1 more & skip help [0]
    DBG_TRC  16 "GetEndNdx: ic:$1, NumAllItm:$NumAllItm";
    for ((ic=0; ic < NumAllItm; ic++)); do # count help option if present (ic=0)
        local srch="${SrchName[$ic]}"; local prms="${NumParms[$ic]}";
        local link="${LinkIndx[$ic]}"; # multiple options: -i|-j should be 1 not 2
        if   [[ ! "$srch" ]] || ((prms > 0)); then ((cnt++)); # all parms
        elif ((link == -1)); then ((cnt++));    # all unlinked options
        elif ((link == ic)); then ((cnt++)); fi # count only 1st one
        DBG_TRC -s 17 "GetEndNdx: name:${ParmName[$ic]}, ic:$ic, cnt:$cnt";
    done; EndOptNdx=$cnt; # was: if ((OPTEND == -1)) || ((cnt < OPTEND)); then OPTEND=$cnt; fi
    DBG_TRC -x 16; # for any value
}

############################################################
# Get Entire Quote - Part a
# Check if unmatched quotes (the result of enclosed space(s))
# NB: must quote item so we don't interpret delimiters: [] ()
# determine which comes 1st: single | double quote | neither
# NB: this must carry over from a previous unmatched case
# so we need to note what we are matching now for later
# [Since this is reused the caller should enable tracing.]
############################################################
function  ChkQuote() { # ChkQuote pc "from"
    # NB: default case is that we are matched (if not looking for anything)
    local bgn=1; if [[ "$mtch" ]]; then bgn=0; mtdn=0; else mtdn=1; fi
    local pc=$1; local frm="$2"; shift 2; local DBG=""; # local for debugging purposes
    if   DBG_TRC -s 15 $pc ""; # Note: only used for printing
    then PrintAggregate "setitm $frm (bgn=$bgn)" $pc 1 1 $disc $proc $mtdn "$item" "$save" "$rest" "" "$mtch" >&2; fi

    # only check for the case where we have quotes containing spaces, all else is mtdn=1
    if  [[ "$item" ]] && ( [[ "$item" != '""' ]] && [[ "$item" != "''" ]] ) &&
        [[ "$item" =~ [\'\"] ]]; then # contains a quote, so we must check if matched: '|"
        local noqt=0;  local sql=0;   local dql=0; local litm=${#item};
        if  [[ ! "$mtch" ]]; then # if just starting
            local sqt="${item%%"'"*}"; sql=${#sqt};
            local dqt="${item%%'"'*}"; dql=${#dqt};
        fi; if [[ "$mtch" == "'" ]] || ( [[ ! "$mtch" ]] && ((sql < dql)) ); then
            local escd=0; local qmrk="'";
            local temp=${item//[^\']/}; noqt=${#temp}; # discard all but single quotes
            if  ((noqt > 0)); then                     # must check if any are escaped
                temp=${item//\\$qmrk};  ltmp=${#temp}; ((escd = litm - ltmp));
                temp="\\$qmrk";         ltmp=${#temp}; ((escd = escd / ltmp));
                ((noqt -= escd)); # subtract escaped ',' (integer division above is valid)
                if (((noqt & 1) == 1)); then  # if odd no. quotes & looking, then done
                if ((bgn == 0)); then mtdn=1; # NB: item could be: "....
                     item=${item/"$mtch"*/"$mtch"};    # discard all after quotemark
                else mtch=$qmrk; mtdn=0; fi; fi
            fi  # if no quotes, then can't clear mtch
        elif [[ "$mtch" == '"' ]] || ( [[ ! "$mtch" ]] && ((dql < sql)) ); then
            local escd=0; local qmrk='"';
            local temp=${item//[^\"]/}; noqt=${#temp}; # discard all but double quotes
            if  ((noqt > 0)); then                     # must check if any are escaped
                temp=${item//\\$qmrk};  ltmp=${#temp}; ((escd = litm - ltmp));
                temp="\\$qmrk";         ltmp=${#temp}; ((escd = escd / ltmp));
                ((noqt -= escd)); # subtract escaped ',' (integer division above is valid)
                if (((noqt & 1) == 1)); then  # if odd no. quotes & looking, then done
                if ((bgn == 0)); then mtdn=1; # NB: item could be: "....
                     item=${item/"$mtch"*/"$mtch"};    # discard all after quotemark
                else mtch=$qmrk; mtdn=0; fi; fi
            fi  # if no quotes, then can't clear mtch
        fi
    fi; DBG_TRC -x 15 $pc "Advance1: exit ChkQuote mtch=$mtch, mtdn:$mtdn";
} # end Chk Quote

###########################################################################
# Get Quote - aggregates individual items broken up by spaces within quotes
# Check if we have the whole item to process now, otherwise keep gathering
# items until we have a whole quote; get option info (was: whatitem "$item")
# Note: returns FAILURE only if the caller should do a continue
# Note: Get Quote requires the use of variables external to it (i.e. globals)
# that must be set up & resent to on the next call. List of globals modiied:
# pc, lstpc, disc, proc, save, rest. The caller must init these to:
# pc=0; lstpc=0; disc=0; proc=0; save=""; rest="$@";
#
# Use the 'rest' string to capture a whole item with all its spaces.
# - mtch is set when we have an unmatched leading quote; Note that this quote
#   may have been in the middle of an item, e.g.: -i="a value"
# - disc is set when we don't have a whole quoted item
###########################################################################
function  GetQuote() { # GetQuote incr ic narg mtdn "mtch" "item"
    local incr=$1; # 0 if not pc increment, else increment it
    local ic=$2;   local narg=$3;   local mtdn=$4; shift 4;
    local mtch=$1; local item="$2"; shift 2; local DBG="disc:$disc, rest=\"$rest\""; # for debugging

    if  ((disc == 1)) || [[ "$mtch" ]]; then
        if  [[ ! "$item" ]];  then disc=0; proc=1;
            PrintErr $ic "$QUNF" $ic "item:'$save' @ $ic [1]" >&2; # e.g.: param3?"
        elif ((disc == 0));   then disc=1; # unmatched && just found
            rest="${rest#"${rest%%[![:blank:]]*}"}";    # rem lead whitespaces [spec: save=]
        elif ((mtdn == 1));   then disc=0; proc=1; fi   # discard && match dn. [spec: mtch=""]
        # else keep discarding item(s) til end quote found
    else    rest="${rest#"${rest%%[![:blank:]]*}"}"; proc=1; fi # rem lead w/s [spec: not done]

    #######################################################################
    # have to be careful because we don't want to discard spaces in rest,
    # which may be real, but we also need to match the beginning of rest
    # with or without the leading spaces, so we only remove them in a
    # temporary variable for the sake of matching only
    #######################################################################
    local clnrst="${rest#"${rest%%[![:blank:]]*}"}";    # rem lead whitespaces (for matching only)
    if  [[ "$item" ]]; then                             # don't advance if nothing
        if [[ "$clnrst" == "$item"* ]]; then            # if it matches bgn of string
             save+="${rest/"$item"*/$item}";   # grab all up to item          [spec: not done]
             rest="${rest#*"$item"}";          # del shortest match from bgn  [spec: save=item]
             # NB: without next line for UNKI we get " parm" instead of "parm"
             if ((mtdn == 1)); then rest="${rest#"${rest%%[![:blank:]]*}"}"; fi
        else save="$rest";  rest=""; fi
    fi; if DBG_TRC -s 15 $pc "";
    then PrintAggregate "redrst" $pc 1 0 $disc $proc $mtdn "$item" "$save" "$rest" "" "$mtch" >&2; fi

    if ((incr != 0)); then lstpc=$pc; ((pc++)); fi # was: item=$1; shift;
    if ((proc == 0)); then   # check if there's no more data: if not process as is
        if   ((pc >  narg)); then proc=1; disc=0;       # record data
             PrintErr $ic "$QUNF" $ic "save:'$save' @ $ic [2]" >&2; # e.g.: param3?"
        # NB: if no more args, but we've started something, then process unfinished|partial item
        elif ((pc == narg)) && [[ "$item" ]]; then proc=1; disc=0; # process data as is
        else return $FAILURE; fi # was: continue; fi    # NB: already advanced pc
    fi; if DBG_TRC -s 15 $pc "";
    then PrintAggregate "up8prm" $pc 1 0 $disc $proc $mtdn "$item" "$save" "$rest" "" "$mtch" >&2; fi
    return $SUCCESS;
} # end Get Quote ic

###########################################################################
# Collapse Args receives a list of indices to delete from the array args
# and collapses args by moving down slots left open by deleted indices.
# It also adjusts the CmdLine Index array so the original index is kept.
# Note: this is only to be used to remove real command-line items, and
# not for collapsing quoted items with spaces that have gotten separated.
###########################################################################
function  CollapseArgs() { # CollapseArgs "$rid" call
    local rid="$1"; local call="$2"; shift 2;
    DBG_TRC  0x17 "$call" "Collapse Args: call:$call, rid:'$rid', pc|narg:$pc|$narg, savlst|savpc:$savlst|$savpc";
    local src; local dst=$pc; local cnt=0;
    for ((src=pc; src < narg; src++));  do
        if   [[ " $rid" == *" $src "* ]]; then ((cnt++)); continue; # skip, don't copy
        elif ((cnt > 0)); then CmdLineNdx[$dst]=${CmdLineNdx[$src]};
             #local ZZZ="dst|src:$dst|$src";
             if   ((call == 0));
             then CmdLine[$dst]="${args[$src]}";
             else CmdLine[$dst]="${CmdLine[$src]}"; fi
        fi;  ((dst++));
    done;    ((narg -= cnt)); ((RMARGS+=cnt)); local ZZZ="cnt:$cnt"; rid=""; # adjust num. args
    DBG_TRC -x 0x17 "$call" "lstpc|pc|narg:$lstpc|$pc|$narg";
} # end Collapse Args

###########################################################################
# Clean up the Command-Line [PRE] to simplify normal parsing
# 1. Stores a snapshot of cmd-line string & puts it into an array for easier
#    accessing and skipping/compaction of the array.
# 2. Simultaneously cleans up cmd-line input aggregating broken quoted items.
#    Sometimes quoted items with spaces get broken up into multiple items,
#    instead of 1, so: "val 1" => '"val' & '1"'. To fix this requires taking
#    original string & grabbing all between start & end quotes ('"val' & '1"').
# 3. Scans the command line to get indices of 'end of ...' markers so
#    we can handle parsing of optional vs. required pos. parms better
#    and at the same time extracts these from the command-lin array.
#    a. End of Bgn Prm Marker (-+): option are allowed after this
#       if '-+' received & earlier than OPTBGN, use earlier place
#    b. End of Options Marker (--): no options allowed after this
#       if '--' received & earlier than OPTEND, use earlier place
#
# Globals use: CmdLineStr, CmdLineNdx, CmdLineBgn,
#              EndBgnNdx,  EndOptNdx,  args, narg
# Globals set: RxdEndBgn,  RxdEndOpt,  EndBgnRxd,  EndOptRxd, OPTBGN, OPTEND
#              CmdLine,    cl, pc
# NB: we can call Set Rcvd here without also extracting items
###########################################################################
function  CleanupCL() { # Clean up Command-Line to simplify normal parsing
    local item; local rid="";
    local pc=0; local lstpc=0; local cl=0; local disc=0; local mtch="";

    while ((pc < narg)); do item="${args[$pc]}";
        DBG_TRC  0x61 "$pc" "Cleanup CL top loop: pc<narg:$pc<$narg, item:$item";

        ############################################################
        # Step 1: set vars for partial|full quote; get item,
        # aggregate any split quotes with spaces, dequote item,
        # then advance to next position, and do any cleanup.
        ############################################################
        local proc=0; local mtdn=0; local found=0; local bad=0;
        ChkQuote $pc; if ! GetQuote 1 $pc $narg $mtdn "$mtch" "$item";  # lstpc++, pc++
        then  DBG_TRC -x 0x61 "$pc" "CleanupCL cont loop"; continue; fi # skip uncompleted & advance to next one

        local n=${#save}; if ((n > 1)); # dequote function # was: save
        then local bgn="${save:0:1}"; local end="${save:$n-1:1}";
             if ( [[ "$bgn" == "'" ]] || [[ "$bgn" == '"' ]] ) && [[ "$bgn" == "$end" ]];
             then save="${save:1:$n-2}"; fi  # now dequoted
        fi;  item="$save"; save=""; mtch=""; # do cleanup

        ############################################################
        # Step 2: Pre-handle any end bgnparm markers ('-+') so that
        # we don't clutter up the rest of code for special checks.
        # If not specified, then we don't 'save' it anywhere.
        ############################################################
        if  [[ "$item" == "$SYMB_EOBP" ]]; then ((disc++));
            DBG_TRC  0x62 "$lstpc" "Handle end bgnprm ($SYMB_EOBP) [-a] RxdEndBgn:$RxdEndBgn";
            if   ((RxdEndBgn == -1)); then RxdEndBgn=$lstpc; fi # capture 1st ndx
            if   ((EndBgnNdx != -1)); then   # save if specified, else track
                 if ((lstpc < OPTBGN)); then OPTBGN=$lstpc; fi
                 SetRcvd $EndBgnNdx $lstpc "$item" 0 0 "$SYMB_EOBP"; # save: double dash (invd=0)
            elif [[ ! "$EndBgnRxd" ]]; then EndBgnRxd="$lstpc";
            elif ((CfgSet[CF_DUPOPT] == 0)); then
                 EndBgnRxd+=",$lstpc"; # record each occurrence
                 local orig="${EndBgnRxd%%,*}"; # discard longest match
                 # use first index for row number, not the last one
                 PrintErr $orig "$MSOR" $orig "$item @ $EndBgnRxd" >&2;
            fi;  rid+="$lstpc ";
            DBG_TRC -x 0x62 "$lstpc" ""; # go to next item

        ############################################################
        # Step 3: Pre-handle any end options markers ('--') so that
        # we don't clutter up the rest of code for special checks.
        # If not specified, then we don't 'save' it anywhere.
        ############################################################
        elif  [[ "$item" == "$SYMB_EOOM" ]]; then ((disc++));
            DBG_TRC  0x62 "$lstpc" "Handle end option ($SYMB_EOOM) [-a] RxdEndOpt:$RxdEndOpt";
            if   ((RxdEndOpt == -1)); then RxdEndOpt=$lstpc; fi # capture 1st ndx
            if   ((EndOptNdx != -1)); then  # save if specified, else track
                 if ((lstpc < OPTEND)); then OPTEND=$lstpc; fi  # ignore if OPTEND=-1
                 SetRcvd $EndOptNdx $lstpc "$item" 0 0 "$SYMB_EOOM"; # save: --
            elif [[ ! "$EndOptRxd" ]];  then EndOptRxd="$lstpc";
            elif ((CfgSet[CF_DUPOPT] == 0)); then
                 EndOptRxd+=",$lstpc"; # record each occurrence
                 local orig="${EndOptRxd%%,*}"; # discard longest match
                 # use first index for row number, not the last one
                 PrintErr $orig "$MSOR" $orig "$item @ $EndOptRxd" >&2;
            fi;  rid+="$lstpc ";
            DBG_TRC -x 0x62 "$lstpc" ""; # go to next item

        ############################################################
        # Step 4: Count how many items are before end of ... markers
        # and save items that are not end of ... markers
        ############################################################
        else CmdLine[$cl]="$item";  CmdLineNdx[$cl]=$cl; # save value & initial indices
             lstpc=$cl; ((cl++)); # advance; below here use lstpc
             if  ((RxdEndBgn == -1)) && ((lstpc < OPTBGN)); then ((CmdLineBgn++)); fi
        fi;  DBG_TRC -x 0x61 "$pc" "CleanupCL bot loop";
    done; cdebug no "$TrcCmd"; # do Cmdline only tracing off

    if   ((TrcShr == 1));
    then PrintList -i 0 $cl -m "Cleanup CL: cl|narg:$cl|$narg$CR" "${CmdLine[@]}";
    echo "CleanupCL: RxdEndBgn:$RxdEndBgn, rid:'$rid'";
        if  ((CfgSet[CF_ECHONO] == 0)); then echo; fi
    fi; narg=$cl; # pc=0; lstpc=0; # start over
   #((narg -= disc)); # only do if actually removing (now done in Collapse Args)
    if [[ "$rid" ]]; then CollapseArgs "$rid" 0; fi
} # end Cleanup CL

############################################################################
# Get PosPrm gobbles up any open positional parameters that we come to that
# are specified in either the beginning or ending parameter lists. Note:
# we can't grab any parm which is part of an OR'ed (i.e. mixed) group, when
# any of the mixed group has already been received. Since parms are always
# named, don't have any alternate name. But we only grab optional parms if
# we have enough items left. Beginning optional parms are part begin parms,
# so we have to check for optional parms even if doing begining parms.
#
# Warning: this function uses globals: parm, found, ...
# & it also modifies several of them:  rest, save, pc, lstpc
# [Those globals that are modified using a different name are explicitly
# saved at the end of this function.]
############################################################################
function  GetPosPrm() { # GetPosPrm bgnprm # 0|1
    local bgnPrm=$1;    local bstr="bgn";  local _pc=$pc;  # save pc for turning trace off
    if  ((bgnPrm == 0)); then bstr="end";  fi
    local dbgVal=$((bgnPrm == 0 ? 0x64 : 0x63));
    local getItm=$((bgnPrm == 0 ? getEnd    : getBgn));    # global modified: num items to get
    local itmNdx=$((bgnPrm == 0 ? endNdx    : bgnNdx));    # global modified: ndx into items
    local NumPrm=$((bgnPrm == 0 ? NumEndPrm : NumBgnPrm));
    DBG_TRC $dbgVal "$pc" "Get PosPrm $bstr next:${CmdLine[$pc]}, pc<narg:$pc<$narg, getItm:$getItm, itmNdx:$itmNdx, NumPrm:$NumPrm, RxdEndBgn:$RxdEndBgn, hveobp|hveoom:$hveobp|$hveoom"; # 0x64 | 0x63
    local reqd; local cnt; local nam; local left;
    local ic=0; local mcnt=0; local invd=0; local found=0; local more=0;

    ############################################################
    # Debugging help, displays list of CmdLine for call
    ############################################################
    DBG_TRC -p $dbgVal "$_pc" "";  # 0x64 | 0x63
    local ndx=${CmdLineNdx[$pc]};  # orig pc
    if  ((TrcShr == 1)); then echo "GetPosPrm: bgn:$bgnPrm pc:$pc";
        echo "GetPosPrm: array[${pc}-$narg]: ic:$ic, getItm:$getItm, ndx<num:$itmNdx<$NumPrm, item=${CmdLine[$pc]}";
        PrintList -i $pc $narg -m "GetPosPrm: $bstr narg:$narg$CR" "${CmdLine[@]}";
    fi; DBG_TRC -r $dbgVal "$_pc" ""; # 0x64 | 0x63
    if  ((OPTBGN != -1)) && ((ndx >= OPTBGN)); then hveobp=1; fi # was: minpl=1;
    if  ((OPTEND != -1)) && ((ndx >= OPTEND)); then hveoom=1; fi # was: ddash=1;

    ############################################################
    # Loop as long as pc < narg & we still need items (getItm) &
    # we keep finding items, but we're not beyond the number of
    # begin parm if we are searching for beginning parms
    ############################################################
    while ((pc <  narg)) && ( ((more != 0 )) || ( ((getItm > 0)) &&
          ((itmNdx < NumPrm)) && ( ((bgnPrm == 0)) ||
          ( ((hveobp == 0)) && ( ((RxdEndOpt == -1)) || ((ndx < RxdEndOpt)) ||
          ((OPTEND == -1)) || ((ndx < OPTEND)) ) ) ) ) ); do

        ############################################################
        # End of ... markers have already been removed, so we check
        # against their indices to see if we have passed them
        # Requires GetBgnPrm in Init Lists to be called before this
        ############################################################
       #echo "pc|lstpc:$pc|$lstpc, bgnPrm:$bgnPrm, CmdLineNdx:${CmdLineNdx[@]}";
        item="${CmdLine[$pc]}"; ndx=${CmdLineNdx[$pc]}; if ((bgnPrm == 1));   # original pc
        then if  ((hveobp == 0)) && ((OPTBGN != -1)) && ((ndx >= OPTBGN)); then hveobp=1; fi     # was: minpl=1;
        else if  ((hveoom == 0)) && ((OPTEND != -1)) && ((ndx >= OPTEND)); then hveoom=1; fi; fi # was: ddash=1;

        ############################################################
        # Step a: Handle parameters (srch == ""), get stored info
        ############################################################
        if ((more == 0)); then if ((bgnPrm == 1));  # get index for parms list
            then ic=${NdxBgnPrm[$itmNdx]}; else ic=${NdxEndPrm[$itmNdx]}; fi
            more=${MoreIndx[$ic]}; cnt=${RxdCount[$ic]};
            reqd=${ReqdItem[$ic]}; nam=${DescName[$ic]}; # debug
        fi; ((itmNdx++)); # advance to next index

        ################################################################
        # Check if have optional pos parm that we can fill (exclude more
        # parms). Already advanced pc, so pc=pc-1; NB: counting at here
        # is imperfect since we can't account for opts removed later
        ################################################################
        if  ((more != 0)) || ( ((cnt == 0)) && ( ((bgnPrm == 0)) || ((hveobp == 0)) ) ); then
            DBG_TRC -s $dbgVal "$_pc" "Get PosPrm $bstr lstpc<narg:$lstpc<$narg, getItm:$getItm, ndx:$ndx, NumPrm:$NumPrm, RxdEndBgn|EndBgnNdx:$RxdEndBgn|$EndBgnNdx, RemReqBgn|RemReqEnd|RemReqOpt:$RemReqBgn|$RemReqEnd|$RemReqOpt, hveobp|hveoom:$hveobp|$hveoom"; # 0x64 | 0x63
            if  ((reqd == 0)) && ((more == 0)); then local cont=0; # local ro=$RemReqOpt; # debug
                if   ((bgnPrm == 0)); then                         # not used: RemReqOpt
                     left=$((narg - lstpc - RemReqEnd));           # find how many items left
                     if ((left <  0)); then cont=1; fi
                else if ((RxdEndBgn != -1)) || ((EndBgnNdx != -1));
                     then DBG_TRC -s 0x63 "$pc" "Get PosPrm $bstr left:$CmdLineBgn - $pc - $RemReqBgn [item=${CmdLine[$lstpc]}]";
                          left=$((CmdLineBgn - pc - RemReqBgn));  # find how many items left
                     else DBG_TRC -s 0x63 "$pc" "Get PosPrm $bstr left:$narg - $pc - $RemReqPrm - $RemReqOpt [item=${CmdLine[$lstpc]}]";
                          left=$((narg - pc - RemReqPrm - RemReqOpt)); fi # not: RemReqBgn
                     if ((left <= 0)); then cont=1; fi
                fi;  if ((cont == 1)); then ZZZ="CONT!!!"; continue; fi # go to next itmNdx (already incremented)
            fi # DBG_TRC -x $dbgVal "$_pc" "pc:$pc"; # 0x64 | 0x63

            ################################################################
            # Note: don't check if parm value matches data type here, since
            # its position can change in the call to Shift Prm (hence invd=0)
            ################################################################
            if   ((more != 0)); then if ((reqd == 1)); then ((prmReq--)); else ((endOpt--)); fi; fi
            DBG_TRC -p $dbgVal "$_pc" "SetRcvd $ic $ndx $item $invd $mcnt [pc:$pc] : item='$item'"; # 0x64 | 0x63
            DBG_TRC  0x67 "$ic"  "Set Rcvd prm: ic|pc|ndx:$ic|$pc|$ndx, invd|prmReq|Opt:$invd|$prmReq|$endOpt, more|mcnt:$more|$mcnt, item:$item";
            SetRcvd "$ic" "$ndx" "$item" $invd $mcnt "prm$bstr"; # RxdCount++
            found=1; ((getItm--));
            DBG_TRC -x 0x67 "$ic" "getItm:$getItm"; # end of Set Rcvd
            DBG_TRC -r $dbgVal "$_pc" ""; # 0x64 | 0x63

            ndx=${CmdLineNdx[$pc]}; item="${CmdLine[$pc]}"; lstpc=$pc; ((pc++)); # adv.: item=$1; shift;
            if  ((more != 0)); then ((mcnt++)); fi # goto next input item but don't advance ic!
        fi; local YYY="more:$more, pc|narg:$pc|$narg, getItm:$getItm, itmNdx<NumPrm:$itmNdx<$NumPrm, bgnPrm:$bgnPrm, hveobp:$hveobp, RxdEndOpt:$RxdEndOpt, ndx<OPTEND:$ndx<$OPTEND";
    done; if ((bgnPrm == 0));  # update modified globals
    then  getEnd=$getItm; endNdx=$itmNdx; else getBgn=$getItm; bgnNdx=$itmNdx; fi # turn off
    DBG_TRC -x $dbgVal "$_pc" "pc:$pc"; # 0x64 | 0x63
    if    ((TrcShr == 1)); then echo "GetPosPrm: end:$bgnPrm pc:$pc";
        if ((bgnPrm == 0)) && ((CfgSet[CF_ECHONO] == 0)); then echo; ((NbEcho++)); fi
    fi; if ((found == 0)); then return $FAILURE; else return $SUCCESS; fi
} # end Get PosPrm

#############################################################################
# Called at bottom of looping over receiving cmd-line items to record if the
# item was unknown (i.e. it wasn't found and wasn't marked as invalid)
# Note: can't check RxdCount as this will be not be 0
#############################################################################
function  HandleUnknown() { # HandleUnknown pc endop
    local parm; local invl; local indx;
    local pc=$1; local endop=$2; shift 2; local _pc=$pc;
    DBG_TRC  0x81 "$_pc" "HandleUnknown: pc<narg:$pc<$narg, endop:$endop";
    while ((pc < narg)); do parm="${CmdLine[$pc]}"; # use pc presently on
        indx=${CmdLineNdx[$pc]}; invl=${RxdInvld[$indx]};
        if  [[ ! "$invl" ]] || ((invl == 0)); then RxdInvld[$indx]=1;
            PrintErr $indx "$UNKI" $indx "$parm" >&2;
            if ((DbgPrt == 1)); then PrtReqNum $indx; fi
        fi; ((pc++));
    done; DBG_TRC -x 0x81 "$_pc" "";
} # end Handle Unknown

###########################################################################
# Indent - indents output passed in as a parameter or read in from input
# and it handles multi-line input; optional options include (in order):
# 1/0       : tells if this is first line (default) or not
# -a        : do for all lines, else reset after each line
# -c{2}     : end broken line with continuation char. ('\\') for echo
# -c1       : end broken line with continuation char. ('\')  for printf "%s"
# -e        : suppress (i.e. swallow) all of the empty lines
# -s sep    : base indent on 1st line's sep char. (e.g.: ':')
# -i indent : use fixed indent for non-first lines (def. = 4)
# -m max    : wrap line at max length (def. 80), must be < col width of term.
###########################################################################
function  IndentLoop() { # lines cnt noemt doall off first cols
    local name=$1[@]; local lines=("${!name}"); local cnt=$2;
    local noemt=$3;   local doall=$4; local off=$5; local first=$6; shift 6;
    local cols=$1;    local ic; local line; local what; local temp; local off;

    # if not doing all, reset first flag for each line
    for ((ic=0; ic < cnt; ic++)); do temp="${lines[$ic]}";
        if ((noemt == 0)) || [[ "$temp" ]]; then
            while IFS= read -r line;  do what="$line";
                if ((doall == 0)) || ((first == 1)) || ((off <= 0));
                then printf "%s\n"              "$what"; first=0;
                else printf "%-"$off"s%s\n" " " "$what"; fi
            done < <(printf "%s\n" "$temp" | fold -s -w $cols);
        fi
    done
} # subroutine for Indent to handle looping
# Note: Indent is fixed to handle tab chars
function  Indent() { local HELP="{-t}{1st}{-a}{-c{1}}{-e}{-s sep}{-i indent=4}{-m maxwide=80} {str} # 1st=0|1, -a indent all after 1st, indent val based on 1st sep and|or fixed num, -e suppress empties, -t trace";
    local cch='\\';
    local dbgtrc=0; if [[ "$1" == -t ]]; then dbgtrc=1; cdebug on; shift; fi
    local first=1;  if (($# > 1)) && ([[ "$1" == 1 ]] || [[ "$1" == 0 ]]); then first=$1; shift; fi
    local doall=0;  if [[ "$1" == -a  ]]; then doall=1; shift 1; fi
    local docnt=0;  if [[ "$1" == -c1 ]]; then docnt=1; shift 1;
                  elif [[ "$1" == -c* ]]; then docnt=2; shift 1; fi
    local noemt=0;  if [[ "$1" == -e  ]]; then noemt=1; shift 1; fi
    local sep="";   if [[ "$1" == -s  ]]; then sep=$2;  shift 2; fi
    local off=4;    if [[ "$1" == -i  ]]; then off=$2;  shift 2; fi
    local max;      if [[ "$1" == -m  ]]; then max=$2;  shift 2; else max=$(tput cols); fi
    local cols=$(tput cols); cols=$((cols < max ? cols : max));  # don't allow > max
    declare -a lines; declare -a nulin; local oifs="$IFS"; local line; local getlen=0;
    if  ((first == 1)) && [[ "$sep" ]];   then getlen=1; fi

    # do this in case command line parms include carriage returns
    if [[ "$1" ]]; then     IFS="$CR"; lines=("$@"); IFS="$oifs";
    else  IFS='';  local ic; local leng; # preserve (especially) leading spaces
        # store tab-expanded line, can't use wc -L on Darwin, so use expand
        while read line; do lines+=($(printf "%s" "$line" | expand));
        # do pre-scan to calculate offset from input based on separator char.
        if ((getlen == 1)) && [[ "$line" == *"$sep"* ]]; then  # calc. offset
            # discard all after sep & add back sep w/ 1 space to get indent length
            line="${line/$sep*/$sep }"; leng=${#line}; if ((leng > off)); then off=$leng; fi
        fi
    done; fi; local cnt=${#lines[@]}; IFS="$CR"; # get line count
    IFS="$oifs";     # indent the collected lines based on config.
    # have to reduce max width by offset for the folded lines
    if ((cols > off)); then ((cols -= off)); fi
    case "$docnt" in # NB: double quotes on sed won't work on this
    2)  IndentLoop lines $cnt $noemt $doall $off $first $cols | sed '$!s/$/ \\\\/';;
    1)  IndentLoop lines $cnt $noemt $doall $off $first $cols | sed '$!s/$/ \\/';;
    0)  IndentLoop lines $cnt $noemt $doall $off $first $cols;;
    esac; cdebug no "$dbgtrc";
} # end Indent (useful internal & external output display function)

###########################################################################
# Get Range is used to extract the beginning & ending values when given an
# option in the form -...n{-{m}}; these are 1-based ranges, where 0 represents
# the 'do all' tests case & -... (with no numbers) means show test description.
# Note that n is the starting test case, m the last test case to be done;
# bgn is the minimum test number, while end is the maximum allowable test.
# If end is received with 0, this is flagged as an error. Note: where the max
# is not known or not to be checked it use -1 for end. Note: this routine is
# also used by getparmstest.sh for doing individual or multiple tests. Note
# the special case: -td0  1 14    => OPT=-td; BGN=1;  END=14; NUM=14; MIN=1; MAX=14
# For failure case: -td15 1 14    => OPT=-td; BGN=-1; END=0;  NUM=0;  MIN=1; MAX=14
# Notes on a range: if either of the values are valid then we don't fail.
# Example partials: -td14-15 1 14 => OPT=-td; BGN=14; END=14; NUM=1;  MIN=1; MAX=14
#                   -td1-3  2 14  => OPT=-td; BGN=2;  END=3;  NUM=2;  MIN=2; MAX=14
# Middle overlaps:  -td1-15 2 14  => OPT=-td; BGN=2;  END=14; NUM=13; MIN=2; MAX=14
###########################################################################
function  GetRange() { # {-t} -..{n{-{m}} {bgn# {end#}} # bgn=1, end=max (def no max=-1), -t trace
    local trc=0;  if   [[ "$1" == -t ]]; then trc=1; shift; fi
    local tst=$1; local val; local tmp; local sts=$SUCCESS;
    # NB: can't set bgn or end here to $((val)) as this yields 0 even if an empty string
    local bgn=$2; local end=$3; cdebug on "$trc";
    if   [[ ! "$bgn" ]]; then bgn=1;  elif [[ ! "$bgn" =~ ^[+]?[0-9]+$ ]]; then bgn=0; fi
    if   [[ ! "$end" ]] || [[ "$end" == -1 ]]; then end=-1;
    elif [[ ! "$end" =~ ^[+]?[0-9]+$ ]];       then end=0; fi
    local min=$bgn; local max=$end;  local num=$(( (end < 0) ? -1 : (max-min+1) ));
    if   [[ "$1" == -h ]] || [[ ! "$tst" ]] || ((bgn == 0)) || ((end == 0)) ||
          ( ((end > 0)) && ((bgn > end)) )  || ( ((max != -1)) && ((max < min)) ); then sts=$FAILURE;
    fi;  OPT="$tst"; BGN=$min; END=$max; NUM=$num; MIN=$min; MAX=$max; # globals to no tests

    if  ((sts == 0)); then
        if  [[ "$tst" =~ ([0-9]+[-]?[0-9]*) ]]; then val="${BASH_REMATCH[1]}"; # n{-{m}}
            OPT=${tst/$val*/}; # can't do ((val = tmp)) here or 01-07 becomes -6
            if   [[ "$tst" != *"$val" ]]; then sts=$FAILURE; # some trailing non-numbers
            elif [[ "$val" =~ ^[0-9]+$ ]]; then # if all num. (no dash), start number: n
                 val=$((10#$val)); # convert 0n -> n
                 if  ((val != 0)); then # NB: below we must include val == bgn
                     if  ((val >= bgn)); then bgn=$((val)); # move bgn >
                         if   ((max > 0)) && ((max < val)); then sts=$FAILURE;
                         else end=$bgn; fi # doing 1 value
                     fi  # else val < bgn (nothing to do)
                 fi  # else == 0 (do all case)
            elif [[ "$val" =~ ^([0-9]+)[-]$ ]]; then val="${BASH_REMATCH[1]}"; # open: n- (discarded -)
                 val=$((10#$val)); # convert 0n -> n
                 if  ((val != 0)); then
                     if  ((val > bgn)); then bgn=$((val)); # move bgn >
                         if  ((max > 0)) && ((max < val)); then sts=$FAILURE;
                         fi # leave end value as is (bgn-end)
                     fi  # else val <= bgn (nothing to do)
                 fi  # else == 0 (do all case)
            elif [[ "$val" =~ ^([0-9]+)[-]([0-9]+)$ ]]; then            # range case: n-m
                 val=${BASH_REMATCH[1]};  val=$((10#$val));             # rm leading 0
                 tmp=${BASH_REMATCH[2]};  tmp=$((10#$tmp));             # rm leading 0
                 if  ((val != 0)); then
                     if  ((val > bgn)); then bgn=$((val)); # move bgn >
                         if  ((max > 0)) && ((max < val)); then sts=$FAILURE;
                         fi # leave end value as is (bgn-end)
                     fi  # else val <= bgn (nothing to do)
                 fi  # else == 0 (do all case)
                 if  ((tmp != 0)); then
                     if  ((tmp < end)); then end=$((tmp)); # move end <
                         if ((tmp < min)); then sts=$FAILURE;
                         fi # leave bgn value as is (bgn-end)
                     fi  # else tmp >= end (nothing to do)
                 fi  # else == 0 (do all case)
                 # NB: let user choose how to handle rev. order: bgn > end
            else sts=$FAILURE; fi; if ((sts != SUCCESS)); # set globals for caller
            then BGN=-1;   END=0;    NUM=0;
            else BGN=$bgn; END=$end; NUM=$(( (end < bgn) ? (bgn-end+1) : (end-bgn+1) )); fi
        else sts=$FAILURE; fi; cdebug no "$trc";
    fi; return $sts; # return status
} # end Get Range (useful internal & external range option parser)

###########################################################################
# Version Err checks the versions of the sample files, comparing them to
# the present version. It is written so it can process a space-separated
# list of files+versions+options. If number of items is the max, then a
# search of all versions is made to see if they are all the same. If so,
# then then only the overall test is printed, else the individual tests.
###########################################################################
function  VersionErr() { # VersionErr file vers opt VERS
    declare -a file; declare -a vers; declare -a opts;
    file=($1); vers=($2); opts=($3); # arrayize inputs
    local VERS="$4"; local max=${#Ex_Optns[@]}; ((max--)); # go from 9 to 8, skip 0
    local size=${#file[@]}; # local vsiz=${#vers[@]}; local osiz=${#opts[@]}; # DEBUG
    local run;  declare -a badVers; local badCnt=0;
    local diff=$((size != max)); local ic=0; local bad; local b4=0;
    # Note: even if diff == 1, we still have to go loop thru to set badVers
    for ((ic=1; ic < size; ic++, b4++)); do
        if [[ "${vers[$ic]}" != "${vers[$b4]}" ]]; then bad=1; diff=1; ((badCnt++));
             #file=${Ex_Files[$ic]}; file=${file##*/}; # toss path
        else bad=0; fi; badVers[$ic]=$bad;
    done
    if  ((badCnt > 0)); then
        for ((ic=0; ic < size; ic++)); do if [[ "${bad[$ic]}" == 1 ]]; then
            bad="Warning: Sample file [${file[$ic]} $VERSTR ${vers[$ic]}] vs. getparms.sh [$VERS]!";
            run="Repairs: getparmstest.sh -x ${opts[$ic]} OR getparmstest.sh -x ${Ex_Optns[$ic]}";
            printf "%s\n%s\n\n" "$bad" "$run" >&2;
        fi; done # looping over list of files
    else    local optn; if ((size == 1)); then optn=${opts[0]}; else optn=${Ex_Optns[0]}; fi
            bad="Warning: Sample file [$file $VERSTR ${vers[0]}] vs. getparms.sh [$VERS]!";
            run="Repairs: getparmstest.sh -x $optn";
            printf "%s\n%s\n\n" "$bad" "$run" >&2;
    fi # all the same, so only print overall
} # end Version Err

###########################################################################
# get sample displays the user selected file(s) to display as examples.
# At the same time it checks the version of every file with the present
# version of getparms. Any differences are collected in a space-separated
# list of files+versions+options, which is then passed on to Version Err.
# Note: '-v version' only for testing purposes (so not put in help string).
# Note: Doing 'less' on each file (instead of cat all files to 1 file 1st)
# allows user to 'skip' to section of samples he desires by typing 'q's.
###########################################################################
function  getsample() { local HLP="getsample {-d}{-v{=| }vers} -s<$SAMP_OPTS>{n{-{m}}} # -s{$SAMP_OPTS} [def. -sa]"
    declare -a HELP; local ndx=-1; local rng=""; local all=0;
    ((ndx++)); HELP[$ndx]="getsample -s<$SAMP_OPTS>{n{-{m}}} # get samples, if no n list category"
    ((ndx++)); HELP[$ndx]="             if n=0 show all, n show just n, n- show n to end, n-m show a range";
    ((ndx++)); HELP[$ndx]="             Note: -sa (alone) [all option] does not support a number | a range";
    local VERS="$GETPARMS_VERS"; local file; local sts=$SUCCESS;            # -t{c|o|d|e|v|f|a|r|m|s}
    local dbg=0;   if [[ "$1" == -d ]] || [[ "$1" == -t ]]; then shift; dbg=1; fi
    local dover=0; if [[ "$1" == -v   ]]; then dover=1; VERS=$2; shift 2;
                 elif [[ "$1" == -v=* ]]; then dover=1; VERS=${1/-v=/}; shift; fi
    local bgn=1;  local end=${#Ex_Files[@]}; local opt=${1/-t/-s}; shift;
    cdebug on "$dbg"; # getparmstest uses '-t*', but getparms uses '-s*', so map it
    #if  ((dbg == 1)); then echo "frm=$frm, un2=$un2"; fi
    case "$opt" in  # find a requested test
    "")     bgn=1;  all=1;; # end=max # file all of file types
    -sa)    bgn=1;  all=1;; # end=max # file all of test types
    -sc*)   bgn=1;  end=$((bgn+1));;  # file specific features
    -sf*)   bgn=2;  end=$((bgn+1));;  # file specific features
    -sv*)   bgn=3;  end=$((bgn+1));;  # file variety features
    -sd*)   bgn=4;  end=$((bgn+1));;  # file data type values
    -ss*)   bgn=5;  end=$((bgn+1));;  # file data type strings
    -sr*)   bgn=6;  end=$((bgn+1));;  # file required|optional
    -sm*)   bgn=7;  end=$((bgn+1));;  # file matches & extract
    -se*)   bgn=8;  end=$((bgn+1));;  # file individual errors
    -so*)   bgn=9;  end=$((bgn+1));;  # files output displays
    -s)     printf "%s\n" "${HELP[@]}" >&2;  # no bad opt here
            printf "          %s\n" "${Ex_Descs[@]}" >&2;  echo >&2;
            cdebug no "$dbg"; return $FAILURE;;
    *)      # includes -san{-{m}}
            echo "bad opt=$opt" >&2; printf "%s\n" "${HELP[@]}" >&2; echo >&2;
            printf "          %s\n" "${Ex_Descs[@]}" >&2;  echo >&2;
            cdebug no "$dbg"; return $FAILURE;;
    esac;   if ((all == 0)); then if [[ "$opt" =~ [0-9]+[-]?[0-9]* ]];
    then rng=${BASH_REMATCH[0]}; fi; fi

    local vers=""; local files=""; local opts=""; local cr="$CR";
    local ic; local cnt=0;
    for ((ic=bgn; ic < end; ic++)); do # do for 1/all subtests specified
        opt="${Ex_Optns[$ic]}";  file="${Ex_Files[$ic]}"; ((cnt++));
        # to optimize grep, we want to stop after finding the first match
        if  [ -f "$file" ]; then local ver=$(grep -m1 "Examples .* $VERSTR " "$file");
            ver="${ver/* $VERSTR /}";  ver="${ver/]*}"; # extract version
            if [[ "$ver" ]] && [[ "$ver" != "$VERS" ]]; then # flag mismatch
                opts+=" $opt"; vers+=" $ver"; files+=" ${file##*/}"; # discard path
            fi; if ((dover == 0)); then # NB: for display must grep out #_XMPL
                if   [[ ! "$rng" ]] || ((all == 1)); then
                if   ((opt != -so)); then less "$file"; # range N/A on all
                else grep -E -v ^"#_XMPL" "$file" | less; fi
                else GetXmpl "$file" "$opt$rng"; fi
            fi
        else echo "$cr$GENFIL $opt # file=$file" >&2; cr=""; fi
    done; if ((cnt != 0)); then echo; fi # report errors, discard leading space
    if [[ "$vers" ]]; then VersionErr "${files:1}" "${vers:1}" "${opts:1}" "$VERS"; sts=$FAILURE; fi
    cdebug no "$dbg"; return $sts;
} # end get sample : NB: also called by getparmstest.sh

#############################################################################
# Get Help Functions
# The Get... routines below search this file for defined markers and print
# out what is between the associated ..._BGN and ..._END markers; this way
# editing this file with notes becomes the extended help for this utility.
# Get Text can also get from another (sample) file.
# -x supports the alterate format '# example n'
#############################################################################
function  GetText() { # {-f file} {-x}{-p}{-c} key {bgn {end}} # print '_KEY' delimited text (_BGN to _END), -p preserve leading '# ', -c clear page when done
    local file="$SELF"; if [[ "$1" == -f ]]; then file=$2; shift 2; fi
    local exam=0; if [[ "$1" == -x* ]]; then exam=1; shift; fi; local BGN;
    local keep=0; if [[ "$1" == -p  ]]; then keep=1; shift; fi; local END;
    local cler=0; if [[ "$1" == -c  ]]; then cler=1; shift; fi; local find="";
    local nomo=0; local last=""; local END2="Examples End"; # common to both
    local key=$1; shift; local end;
    # Note: if no numbers, then bgn="" in which case we can't do: ((bgn)) => 0
    local bgn=""; if [[ "$1" ]]; then bgn=$1; shift; # if no bgn, then no end
        bgn=$((bgn)); end=$((bgn)); if [[ "$1" ]]; then end=$1; end=$((end)); shift; fi
    fi # cdebug on;
    if   ((exam == 1)) && [[ "$bgn" ]]; # NB: exam=1: bgn to end=end+1, while display is bgn_BGN to end_END
    then ((end++));     BGN="# example $bgn";  END="# example $end";
    else find="#_$key"; BGN="$find${bgn}_BGN"; END="$find${end}_END"; fi
    local skip=1; local oifs="$IFS"; IFS=""; # preserve leading spaces
    #---------------------------------------------------------------
    # Once we turn off searching, we don't want to turn it on again
    # that way, if we find "# example 1" and stop at: "# example 2"
    # we don't want to get "# example 10"
    # use clear for longer multi-page displays
    #---------------------------------------------------------------
    cat "$file" | while read line; do
        if   ((nomo == 1)); then continue; fi
        if   ((skip == 1)); then
            if [[ "$line" == "$BGN"* ]]; then # print skips if exam
                if ((exam == 1)); then # following test only do for 1st
                    if ((skip == 1)) && [[ "$last" == "#---"* ]]; then
                    printf "%s\n" "$last"; fi; printf "%s\n" "$line";
                fi; skip=0;
            fi # 2nd search below is if last item
        elif [[ "$line" == "$END"* ]] || [[ "$line" == *"$END2"* ]]; then skip=1; nomo=1;
        elif ((keep == 0)) && [[ "$line" == "#"* ]];  # don't change to "#"
        then printf "%s\n" "${line:2}"; # discard leading "# "|"#"
        else printf "%s\n" "$line"; fi; last="$line"; # print until end
    done | if [[ "$find" ]]; then grep -v "$find"; else cat; fi |
           if ((cler == 1)); then less; else cat; fi
    IFS="$oifs"; # cdebug no; # restore original IFS
} # end Get Text (used by all Get... help functions)

#############################################################################
# Get Help functions: note this group doesn't support range
#############################################################################
function  GetDbg1() { GetText "DBG1"; }    # GetDbg1 # prints 'debug1'  via -d --help : _DBG1_BGN|_DBG1_END
function  GetInfo() { GetText "INFO"; }    # GetInfo # prints 'manual'  via --help    : _INFO_BGN|_INFO_END
function  GetDesc() { GetText "DESC"; }    # GetDesc # prints descrip.  via --help    : _DESC_BGN|_DESC_END
function  GetWelc() { GetText "WELC"; }    # GetWelc # prints 'welcome' via 1st use   : _WELC_BGN|_WELC_END
function  GetFeat() { GetText -c "FEAT"; } # GetFeat # prints 'feature' via --feature : _FEAT_BGN|_FEAT_END
function  GetHist() { GetText -c "HIST"; } # GetHist # prints 'history' via --history : _HIST_BGN|_HIST_END
function  GetVers() { echo "$GETPARMS_VERS"; }       # prints 'version' via --version

#############################################################################
# Get Xmpl Function : gets examples of running getparms from pre-generated
# files created by getparmstest.sh -x. These files are used to get the full
# description with the specification and command line input and the result
# or just a brief description. The Get Xmpl function supports range: {n{-{m}}},
# so that a range of tests may be specified. Display output (-so) is unique,
# as output is preserved without any change; thus, empty lines are printed.
#
# Each test in display output is bracketed with "#_XMPL?_BGN" & "#_XMPL?_END",
# where '?' is the relevant test number. All other sample tests are bracketed
# by "# example ?" & "# example ??", where '?' is the relevant test number
# and "??" is the test number plus one, or if it is the last test, which is
# followed by "# Test* Examples End", where '*' is the specific test, as in:
# getparms.xcfg.txt:# TestConfigs Examples End
# getparms.xdat.txt:# TestDataTyp Examples End
# getparms.xerr.txt:# TestErrored Examples End
# getparms.xfet.txt:# TestFeature Examples End
# getparms.xmat.txt:# TestMatches Examples End
# getparms.xout.txt:# TestOutputs Examples End
# getparms.xreq.txt:# TestReqOpts Examples End
# getparms.xstr.txt:# TestStrType Examples End
# getparms.xvar.txt:# TestVariety Examples End
#############################################################################
function  GetXmpl() { local HELP="GetXmpl file {-l}{-<s|d|t>{n{-{m}}}} # prints display examples";
    local HLP2="        n=0 all, else display n, n- from n to end, n-m range, -l skip less";
    local doall=0; # cdebug on
    local file="$1"; shift; local gmax="Examples Bgn ";
    local all=0; local bgn=1; local num;
    local lss=1;  if [[ "$1" == -l ]]; then lss=0;  shift; fi # -l skips less
    local tst=$1; shift;  if [[ "$tst" ]]; then tst="${tst/d/s}"; tst="${tst/t/s}"; fi
    local exm=-x; if [[ "$tst" == -so* ]]; then exm=""; fi # output display format unique
    if  [[ "$1" == -* ]];
    then echo "$BADOPT $1"   >&2; echo "$HELP" >&2; echo "$HLP2" >&2; return $FAILURE; fi
    if  [[ "$tst" ]] && [[ "$tst" != -s* ]];
    then echo "$BADOPT $tst" >&2; echo "$HELP" >&2; echo "$HLP2" >&2; return $FAILURE; fi

    # NB: caller is responsible for verifying file exists
    local line=$(grep -E -m1 "$gmax" "$file"); local end;
    local nurec="Max:";  line=${line/*$nurec/};
    if [[ "$line" =~ [0-9]+ ]]; then end=${BASH_REMATCH[0]};
    else echo "file $file missing max records [$nurec] (test=$tst)"; fi

    if  [[ "$tst" =~ [0-9] ]]; then
        if ! GetRange "$tst" "$bgn" "$end"; then
             echo "bad range: $tst [max=$end]";
             echo "$HELP" >&2; echo "$HLP2" >&2; return $FAILURE;
        else num=$NUM; if ((num == end)); then doall=1;
                       elif ((num == 1)); then lss=0; fi
             bgn=$BGN; end=$END; # get results from globals
        fi
    else  doall=1; fi # output display has a special search pattern

    if  ((doall == 1)); then local find;
         if [[ "$exm" ]]; then find="# example "; else find="#_XMPL"; fi
         if ((lss == 0));
         then cat "$file" | grep -v "$find";
         else cat "$file" | grep -v "$find" | less; fi
    else if  ((lss == 0));
         then GetText -f "$file" $exm -p "XMPL" "$bgn" $end;
         else GetText -f "$file" $exm -p "XMPL" "$bgn" $end | less; fi
    fi # cdebug no
} # end Get Xmpl : via --examples -so*


# Upd8 File checks if file is older | uncreated & thus must be updated
function  Upd8File() { # Upd8File fil1 {fil2} # is fil1 newer than fil2 (def.: self)
    local file1="$1"; local file2="$2"; if [[ ! "$2" ]]; then file2="$SELF";  fi
    ( ! [ -f "$file2" ] ) && return $FAILURE;   # don't need to update file1
    ( ! [ -f "$file1" ] ) || [ "$file1" -ot "$file2" ] && return $SUCCESS; return $FAILURE;
} # file2 must exist to be newer, if not created file1 must be newer

# caller responsible for checking if "WELC" file does not exist
function  Welcome() {    # output Welcome information if not previously done
    local  file="$WELF"; # create file if doesn't exist | older than getparms
    if Upd8File "$file"; then GetWelc >"$file"; GetDesc >>"$file"; GetFeat >>"$file"; GetInfo >>"$file"; fi
    touch "$WELC"; less "$file";
} # .getparms.welc.txt
function  Feature() {    # output Feature information
    local  file="$FETF"; # create file if doesn't exist | older than getparms
    if Upd8File "$file"; then GetFeat >"$file"; fi; less "$file";
} # .getparms.feat.txt
function  History() {    # output History information
    local  file="$HISF"; # create file if doesn't exist | older than getparms
    if Upd8File "$file"; then GetHist >"$file"; fi; less "$file";
} # .getparms.hist.txt
function  Example() {   # Example {-d{n{-{m}}}} # output Example information
    local  file="$EXMF"; GetXmpl "$file" "$@";   # actually now: "$TEST_XOUT";
    # in this case, use file if it exists but give warning if older than getparms
} # getparms.xout.txt   # was: .getparms.exam.txt
function  LongHlp() {   # output LongHlp information
    # create file if doesn't exist | older than getparms
    local file="$LNGF"; if ((DbgPrt == 1)); then file="$DBGL"; fi
    if  Upd8File "$file"; then # Sub Func call does 'getparms -x' # list of int. funcs
        if   ((DbgPrt == 1));  # NB: this gets long "debug help" (not long help)
        then GetDbg1 >"$file"; PrintAllDebug >>"$file";
        else GetDesc >"$file"; GetInfo >>"$file"; fi
    fi; less "$file";
} # .getparms.long.txt

#############################################################################
# Sample Positive Spec. & Cmd-line Test (was: -t+)
#############################################################################
# complex version for detailed output
TESTSTR="func <file~sj~@+.Txt> -v:verb|m~h|--verb {-in}{-io} -i -j [-m=indp] \\ $CR -e <-f|--files in out> {--} <prm1~ip> [prm2 prm3] # detail on the items";
TESTRUN="getparms -on $SYMB_HELP\"$HlpOpts\" $SYMB_SPEC \"\$HELP\" file.txt 0x48 -ion -ij -e --files \\ $CR in_file.txt out_file.txt 12 'phrase1 with spaces' 'phrase2 with spaces';"
ASAMPLE="HELP=\"$TESTSTR\""; # a good example, used in getparms HELP string
# simple version for briefer output
TESTSIM='func <file> -v:verb|m|--verb -i {-j} [-m=indp] <-f|--file in> text'
SIMPRUN="getparms $SYMB_SPEC \"\$HELP\" file.txt 0x48  -i --files in.txt 'phrase with spaces'"
ASIMPLE="HELP=\"$TESTSIM\""; # a good example, used in getparms HELP string

#############################################################################
# Help Functions
# We tailor the help messages based on if doing debug printing|debug timing,
# that way the help output is not so overwhelming for the normal base case.
# This allows us to take the full display of 46 lines & cut it to 28 lines.
# NB: Welcome banner only shown to be shown if this is the first time for
# this user with no options and if he is not specifically suppressing help.
#############################################################################
function  GetHelp() { # GetHelp -h inputs # gets help brief help for getparms
    if [[ "$1" == -h ]]; then shift; fi # discard if present
    if [[ "$1" != "" ]]; then printf "Unknown item: $@\n" >&2;
    elif [ ! -f "$WELC" ] && [[ "${CfgSet[$CF_HELPNO]}" != 1 ]]; then Welcome; fi
    if [[ "${CfgSet[$CF_HELPNO]}" == 1 ]]; then return; fi # don't print help
    local cr="$CR"; if [[ "${CfgSet[$CF_ECHONO]}" == 1 ]]; then cr="$CR"; fi
    declare  -a  HElP; local input; if [[ "$1" == -h* ]]; then shift; fi # ignore
    local ndx=0; HELP[$ndx]=""; # start with an empty line
    ((ndx++));   HELP[$ndx]="getparms is a generalized, configurable bash command-line parsing utility";
    ((ndx++));   if ((DbgPrt == 1)); # only show full help if debug flag set
    then         HELP[$ndx]="getparms {-c.} {$DBG_ALL}} {$SYMB_SAMP.} {$CF_ITEM.} {$CF_PARS.} {$SYMB_HELP.} $SYMB_SPEC \"\$HELP\" ...";
    ((ndx++));   HELP[$ndx]="getparms -h{$HLP_ALLS}|$LHLP_HLP2|$LHLP_VERS|$LHLP_EXAM|$LHLP_FEATS|$LHLP_HIST";
    if ((DEV == 1)); then  # only for developers
    ((ndx++));   HELP[$ndx]="getparms $SYMB_WELC|$SYMB_UTIL # $SYMB_WELC=restore welcome banner | $SYMB_UTIL=access external utilities";
    fi
    else         HELP[$ndx]="getparms {-c.}{-d}{$SYMB_HELP.} $SYMB_SPEC \"\$HELP\" ... # ... are cmd-line items from user";
    ((ndx++));   HELP[$ndx]="getparms $SYMB_SAMP.|$CF_ITEM.|$CF_PARS.|-h|$LHLP_HLP2|$LHLP_VERS|$LHLP_EXAM|$LHLP_FEAT|$LHLP_HIST";
    fi           # o.|-p.|-s.|-h|{-}-help|--version|--examples|--feature|--history
    local lines="$(PrintAllCfgs 2>&1)"; # grab o/p & store in array
    for line in "$lines"; do
    ((ndx++));   HELP[$ndx]="$line";    # print each line except "NB:" lines unless in detail
    done
    ((ndx++));   HELP[$ndx]=" ----- Following are the debug|detail option for debugging getparms -----"
    if ((DbgPrt == 0)); then # only show full help if debug flag set
    ((ndx++));   HELP[$ndx]=" -d. : show internal Specification parsing details (& extra help options)";
    else                     # only show extended debugging if debug flag set
    ((ndx++));   HELP[$ndx]=" -cp {-f} {dst_dir} : copy getparms files to new dir [def.=PWD], -f force";
    ((ndx++));   HELP[$ndx]=" -d. : detail: .=$DBGGRPS trace Initial|Analyze|Boxing|Cmdline|Delivery";
    ((ndx++));   HELP[$ndx]=" -di.: .={n{-{m}}} show internal state of nth to mth parse item, else all";   # Display Items
    ((ndx++));   HELP[$ndx]=" -d#.: .={<^|:|=|#>str} do trace #, find at: ^ start, : any, = all, # end";
    fi
    ((ndx++));   HELP[$ndx]=" $SYMB_SAMP. : .=$SAMP_OPTS: show samples of the spec. with command-line";
    ((ndx++));   HELP[$ndx]="       c=config|o=output|d=dtype|e=errs|v=variety|f=feature|a=all|r=reqd|";
    ((ndx++));   HELP[$ndx]="       m=match|s=strings & followed by optional {n{-{m}}} to show a range";
    ((ndx++));   HELP[$ndx]=" ----- Following are the rest of the options for extending getparms -----"
    ((ndx++));   HELP[$ndx]="$(PrintItem)"; # call function to retrieve item's help : -o. :
    ((ndx++));   HELP[$ndx]="$(PrintSyms)"; # call function to get the symbols help : -p. :
    ((ndx++));   HELP[$ndx]=" $SYMB_HELP. : set the help options: short|long|both [defaults set to: -h|$LHLP_HELP]";
    ((ndx++));   HELP[$ndx]="       if the default help option was included ($SYMB_HELP.), '$SYMB_SPEC' can be omitted"
    if ((DbgPrt == 1)); then # only show extended debugging if debug flag set
    ((ndx++));   HELP[$ndx]=" -h. : help . $HLP_VALS";
    ((ndx++));   HELP[$ndx]="       -e {-b|-r|-m} # -b rtn codes, -r rev. [rtn codes 1st], -m mappings";
    fi

    printf "%s\n" "${HELP[@]}"  >&2; # print all help lines from above
    COLS=$(tput cols); COLS=$((COLS < 80 ? COLS : 80)); # don't allow > 80
    local exam="Example Use [for more examples call: getparms.sh $SYMB_SAMP<$SAMP_OPTS>]";
    printf "\n%s\n" "${exam}"   >&2; # print a complex example
    printf -- "%s\n" "-------------------------------------------------------------------------"
    if ((DbgPrt == 1)); then         # show more detailed example
    printf "%s\n"    "$ASAMPLE" >&2; # | fold -s -w $COLS  >&2;
    printf "%s$cr\n" "$TESTRUN" >&2; # | fold -s -w $COLS  >&2;
    else                             # show more simple example
    printf "%s\n"    "$ASIMPLE" >&2; # | fold -s -w $COLS  >&2;
    printf "%s$cr\n" "$SIMPRUN" >&2; # | fold -s -w $COLS  >&2;
    fi
} # end Get Help

function  getparms_help() { # getparms_help {--his*|--h*||-help|--ex*|--ver*} | {-h{d|e|p|o|t}}
    local sts=$SUCCESS;
    local opt="$1"; local spcl="$2";   # don't shift opt or spcl yet
    if [[ "$opt" == -h ]]; then shift; # can now discard opt (-h)
    case "$spcl" in     # -h -{d|e|p|o|t} [2 option method]
    -$HLP_DBUG*)        PrintAllDebug  $@;;     # {-h} -d* => -d*
    -$HLP_ERRS)  shift; PrintAllRtnErr $@;      # {-h} -e {-b|-r|-m} # -b rtn codes only
                        PrintAllErrMsg $@;;     # {-h} -e {-b|-r|-m} # -r rtn codes 1st, -m map
    -$HLP_ERRS*)        PrintAllRtnErr $@;      # {-h} -e{b|r|m}     # -b rtn codes only
                        PrintAllErrMsg $@;;     # {-h} -e{b|r|m}     # -r rtn codes 1st, -m map
    -$HLP_PARS)         PrintAllSymbol;;        # {-h} -p [CF_PARS]
    -$HLP_OPTS)         PrintAllOption;;        # {-h} -o [CF_ITEM]
    -$HLP_TYPE)         PrintAllTypes;;         # {-h} -t
    -$HLP_NUMT)         PrintNumTypes;;         # {-h} -tn
    -$HLP_STRT)         PrintStrTypes;;         # {-h} -ts
    *)                  GetHelp "$@";  GotHelp=1; sts=$FAILURE;;
    esac; elif [[ "$opt" == -h* ]];
    then  case "$opt" in # -hd|-he|-hp|-ho|-ht [1 opt method] NB: -help must be before -he*
    -help)              GetDesc;;               # -help (short description)      - !sav
    -h$HLP_DBUG*)       PrintAllDebug  $@;;     # -hd* {-d{a|b|c|d|i}{-t}{-s|-n} - !sav
    -h$HLP_ERRS) shift; PrintAllRtnErr $@;      # -he {-b|-r|-m}                 - !sav
                        PrintAllErrMsg $@;;     # -he {-b|-r|-m}                 - !sav
    -h$HLP_ERRS*)       PrintAllRtnErr $@;      # -he{b|r|m}                     - !sav
                        PrintAllErrMsg $@;;     # -he{b|r|m}                     - !sav
    -h$HLP_PARS)        PrintAllSymbol;;        # -hp [CF_PARS]                  - !sav
    -h$HLP_OPTS)        PrintAllOption;;        # -ho [CF_ITEM]                  - !sav
    -h$HLP_TYPE)        PrintAllTypes;;         # -ht                            - !sav
    -h$HLP_NUMT)        PrintNumTypes;;         # -htn
    -h$HLP_STRT)        PrintStrTypes;;         # -hts
    *)                  GetHelp "$@"; GotHelp=1; sts=$FAILURE;;
    esac; else case "$opt" in # following are the extended options
    --ver*|-ver*)       GetVers;;               # --version|-version             - !sav
    --fea*|-fea*)       Feature;;               # --feature|-feature             - save
    --ex*|-ex*)  shift; Example "$@";;          # {-}-example {-s{n{-{m}}}}      - save
    --his*)             History;;               # --history                      - save
    --h*)               LongHlp;;               # --help (i.e. long explan.)     - save
    *)                  GetHelp "$@"; GotHelp=1; sts=$FAILURE;;
    esac; fi; return $sts;
} # end get parmshelp

function  samedir()  { local HELP="samedir src {dst=PWD} # dir is same";
    # Note: have to be careful as the dirs may not yet be created!
    local abs1="$1"; if   [[ !  "$1" ]];    then abs1="$PWD";
                     elif [[ -d "$1" ]];    then abs1="$(cd -- "$1" && pwd -P)";
                     elif [[ "$1" != /* ]]; then abs1="$PWD/$abs1"; fi; shift;
    local abs2="$1"; if   [[ !  "$1" ]];    then abs2="$PWD";
                     elif [[ -d "$1" ]];    then abs2="$(cd -- "$1" && pwd -P)";
                     elif [[ "$1" != /* ]]; then abs2="$PWD/$abs2"; fi; shift;
    if [[ "$abs1" == "$abs2" ]]; then return $SUCCESS; else return $FAILURE; fi
}

function  getparms_cp() { local HELP="getparms_cp {-f} {dst_dir} # -f force"; # called from -cp
    local frc=-i; local dop=""; local src="$ROAD"; local cnt=$#;
    if [[ "$1" == -f ]]; then frc=$1; dop=-pv; shift; fi
    # NB: next line prevents dst_dir from beginning with hyphen (ok)
    if [[ "$1" == -* ]]; then echo "$HELP" >&2; return $FAILURE; fi
    local dst="$PWD"; if [[ "$1" ]]; then dst="$1"; shift; fi
    if  samedir "$src" "$dst"; then echo "Error: $SMITM $dst" >&2;
        if ((cnt == 0)); then echo "usage: $HELP" >&2; fi; return $FAILURE;
    fi
    if [[ !  -d "$src"  ]]; then echo "Error: $NODIR $src" >&2; return $FAILURE; fi
    if [[ !  -d "$dst"  ]]; then mkdir $dop "$dst" 2>/dev/null; fi # try to make it
    if [[ !  -d "$dst"  ]]; then echo "Error: $NODIR $dst" >&2; return $FAILURE; fi

    # Note: if first fails, cp will output: "not overwritten"
    # must eval both as they contain * & ??? (respectively), which must be expanded
    if ! eval cp -p $frc "$ALLX"      "$dst/"; then return $FAILURE; fi  # /user/bin/getparms*.sh => dst
    if ! eval cp -p  -f  "$TEST_XALL" "$dst/"; # /user/bin/getparms.x???.txt (9 files)
    then echo "operation aborted" >&2; return $FAILURE; fi
} # end getparms cp

#############################################################################
# Check User Message
# ensure if message begins with quote it ends with same kind of quote;
# spaces allowed in user messages, but only if preserved within quote;
# ensure message not empty & not next getparms option (-c* ... -?* -~)
# NB: needn't check for -s|-w|-x as these should never have user msg.
# Nor need we check for unmatched quotes as command can't be completed.
#############################################################################
function  ChkUsrMsg() { # ChkUsrMsg jc ...
    local jc=$1; shift; local sts=$SUCCESS;
    if ! [[ "$DbgMsg" ]] ||                     # no rcvd message
         [[ "$DbgMsg" =~ ^-[cdop] ]] ||         # getparms option
         [[ "$DbgMsg" == "$SYMB_SPEC"* ]] ||    # spec indicator: -~
         [[ "$DbgMsg" == "$SYMB_HELP"* ]];      # help indicator:  -?
    then sts=$UMSG; # must print right away or doesn't get displayed
         if ((CfgSet[CF_ECHONO] == 0)); then echo; fi
         PrintErr -p  $jc "$UMSG"  $jc "\"$DbgMsg $@\"" >&2; sts=${ErrMapped[$UMSG]};
         if ((CfgSet[CF_ECHONO] == 0)); then echo; fi
    fi;  return $sts;
}

#############################################################################
# Main Function - Overall Structure:
# - 1st  get & process the options that affect how getparms works    [OPT]
# - 2nd  user supplied HELP string is processed as a specification   [HLP]
# - 3rd  check for any specification errors/problems & report them   [ANA]
# - 4th  if analyzing only, then output any debugging info and exit  [BOX]
# - 5th  perform pre-scan on command line to get EOBP & EOOM markers [PRE]
# - 6th  parse all the beginning parms, if any available & specified [BPP]
# - 7th  extract all the options that are available & are specified  [XOP]
# - 8th  parse all the ending parms, if any available & specified    [EPP]
# - 9th  check the consistency of all received command line items    [CCL]
# - 10th print command line items & collected errors if enabled      [POP]
# - 11th write out/return results to caller in specified format      [OUT]
#############################################################################
function  getparms() { # main function (see help for options)

    ############################################################
    # initialize all getparms options
    #set -o nounset # treat referring to unset vars as err # N/A
    # NB: don't trace Init Dbg but save & restore trace state
    ############################################################
    InitAll; cdebug -s no; InitDbg; cdebug -s on;  local sts; local tmp;
    local display=""; local options=""; local configs=""; local hlpopt="";
    local shohlp=0;   local gethlp=0;   local done=0; local jc=0; local dbg;

    ############################################################
    # While we loop thru arguments [OPT] we need to collect them
    # & possibly pass them to a sub-function (e.g. to do help).
    # Valid getparms options: -?* -~ -d* -c* -o* -p* -x -h* --*
    # Keep grabbing items until we receive the required option
    # indicator for the Specification string ('-~') or none left.
    # Note: gethlp if help asked for, shohlp if help bcuz bad opt
    ############################################################
    while [ $# -gt 0 ] && ((done == 0)); do case "$1" in # here we shift thru getparm options
    "$SYMB_HELP"*) if [[ "$1" == "$SYMB_HELP" ]] && [[ "$2" != $SYMB_SPEC* ]]; then # no -? -~
                   options+="$2"; HlpOpts="$2";     shift 2; else                   # a: -? "-h|--help"
                   options+="$1"; HlpOpts="${1:2}"; shift 1; fi; ((jc++)); done=1;  # a: -?*
                   HlpOpt1="${HlpOpts/|*}"; HlpOpt2="${HlpOpts#*|}"; # b4 | & after
                   # Note: don't care if these the same no., but only allow 2 max.
                   if [[ "$HlpOpt2" == *"|"* ]]; then  shohlp=1; hlpopt="-h "; fi;;
    $SYMB_SPEC)    shift; ((jc++)); done=1;;  # designator for HELP block: -~  # handle: -~
    $SYMB_SPEC*)   ((jc++)); done=1;;         # designator for HELP block: -~  # handle: -~
    $USRMSG)       DbgMsg="$2";    shift 2; ((jc+=2));  # store a specified user message: -cu "msg"
                   if ! ChkUsrMsg $jc "$@"; then return $?; fi;;
                   # NB: user messages '=' is optional, so remove but only if present
    $USRMSG*)      tmp=${1:3};     if [[ "$tmp" == "="* ]]; then tmp="${tmp:1}"; fi # rm -cu{=}
                   DbgMsg="$tmp";  shift 1; ((jc++));   # store a specified user message: -cu{=}"msg" => "msg"
                   if ! ChkUsrMsg $jc "$@"; then return $?; fi;;
    $CF_COPY)      shift; getparms_cp "$@"; return $?;; # {-f} {dst_dir} # -f force
    $CF_TYPE*)     if   SetCfg  "${1:2}" "$jc";         # NB: if unknown cfg, keep going (no help)
                   then configs+="$1 ";  ((jc++)); fi;  shift;;                 # handle: -c
    $CF_RSLT)      if [ $# -ge 2 ]; then RtnRslt=$2; shift 2; else shift; fi   # handle: -r (file result)
                   if [[ ! "$RtnRslt" ]]; then RtnRslt="_"; fi;;
    $CF_ITEM*)     if ! SetItem "${1:2}" "$jc";  then  shohlp=1; hlpopt="-h "; # handle: -o
                   else configs+="$1 ";  ((jc++)); fi;  shift;;
    $CF_PARS*)     if ! SetSym  "${1:2}" "$jc";  then  shohlp=1; hlpopt="-h "; # handle: -p
                   else configs+="$1 ";  ((jc++)); fi;  shift;;
    #--------------following are all the debug and test options -------------------------------------
    -d)            dbg=$1; # NB: -d b4 -h is debug flag, after -h is help on debugging (-h -d)
                   options+="$1 "; configs+="-cb ";    DbgPrt=1;  # enable debug print results
                   SetCfg  "b" "$jc";       ((jc++));  shift;;    # auto-enable print begin:-cb
    -d_)           options+="$1 "; shift 1; ((jc++));  TrcIni=1; cdebug on;; # enable Initial
    -da)           options+="$1 "; shift 1; ((jc++));  TrcAna=1;; # enable Analyze
    -db)           options+="$1 "; shift 1; ((jc++));  TrcBox=1;; # enable Boxing
    -dc)           options+="$1 "; shift 1; ((jc++));  TrcCmd=1;; # enable Cmdline
    -dd)           options+="$1 "; shift 1; ((jc++));  TrcDel=1;; # enable Deliver
    -ds)           options+="$1 "; shift 1; ((jc++));  TrcShr=1;; # enable pre-shift cmd-line items
    -di*)          options+="$1 "; if [[ "$1" == *"="* ]]; then   # enable Display Item
                   tmp=${1/*=/}; else tmp="${1:2}"; fi; shift 1; ((jc++)); # TrcItm = 3 | 3- | 3-4
                   if [[ "$tmp" ]]; then TrcItm=$tmp;  else TrcItm="-1"; fi;; # 1 or do a range
    -d*)           if ! DBG_ENA "$1";  then shohlp=1;  hlpopt="-h "; # -d{.}n{<:|^|#|=>str}
                   else options+="$1 "; fi; ((jc++));  shift; DBG_TRC  1 "Debug All";; # debug now
    $SYMB_SAMP*)   getsample $dbg "$@"; return $?;;               # -s*: process samples
    $SYMB_WELC)    rm -rf "$WELC";                                # -w : welcome banner file
                   gethlp=1; shift;;                              #      proceed as normal help
    $SYMB_UTIL)    shift; GetFunc "$@"; return $?;;               # -x : in case debug flags preceded
    #--------------following are all help/end of options --------------------------------------------
    # following are all help/end of options, but we still need to keep going
    -help|--h*)    gethlp=1; hlpopt+="$1 ";   shift;;  # includes: --history && --help
    -h*)           gethlp=1; hlpopt+="$1 ";   shift;   break;;    # support: -h.|-h -.
    --*)           shohlp=1; hlpopt+="$1 ";   shift;   break;;    # --examples must break
    *)             shohlp=1; hlpopt+="$1 ";   shift;;  # don't break here else -tc14 fails
    esac; done;    #---------------------------------------------------------------------------------

    ############################################################
    # check if we need to get help AFTER we get all parms, so that
    # if config to suppress HELP is not first we still act on it
    # also check if we are only returning the last status result
    # NB: user can call with: -?... "$HELP" OR -~ "$HELP"
    # NB: no clean up rquired
    ############################################################
    if   ((gethlp == 1)) || ( ((shohlp == 1)) && ((CfgSet[CF_HELPNO] == 0)) ); then
         getparms_help $hlpopt "$@"; sts=$? CleanUp; return $?;
    elif [[ "$RtnRslt" ]]; then GetRslt; return $?; fi # only report last status
    if   [[ "$1" == "$SYMB_SPEC" ]]; then shift; ((jc++)); fi
    # at this point the next item must be the HELP string

    ############################################################
    # get user's help string and ensure not empty, but if caller
    # entered bare script with no parms, then just show our help
    # NB: if help empty, no function name & can't call Print Cmd Line
    ############################################################
    local __HELP__; local opts; # from now on use caller's help
    if  [[ ! "$1" ]];  then if [ $# -ne 0 ]; then # a failure case
         PrintErr -p 0 "$MTHS" 0 >&2; fi
         getparms_help $hlpopt; CleanUp; return $FAILURE;
    fi;  __HELP__="${1/$SYMB_SPEC}"; shift; # we're past getparms' HELP

    ############################################################
    # check if HELP string is contained in an exported variable
    ############################################################
    if  [[ "$__HELP__" == "."* ]]; then local hvar="${__HELP__:1}"; # rm leading '.'
        if   [[ ! "$hvar" ]]; then
             PrintErr -p 0 "$XNAM" 0  "no varname was given" >&2;
             getparms_help $hlpopt; CleanUp; return $FAILURE;
        elif ! is_string "$hvar" -v ; then
             PrintErr -p 0 "$XNAM" 0  "\"$hvar\" not a valid varname" >&2;
             getparms_help $hlpopt; CleanUp; return $FAILURE;
        elif [[ "$hvar" == __HELP__ ]]; then # collides w/ local name
             PrintErr -p 0 "$XNAM" 0  "collides with int. var: $hvar" >&2;
             getparms_help $hlpopt; CleanUp; return $FAILURE;
        # alternately: if ! $(export | grep -q "declare -x $hvar="); then
        elif ! compgen -e -X "!$hvar" >/dev/null; then
             PrintErr -p 0 "$XNAM" 0  "\"$hvar\" not an exported var" >&2;
             getparms_help $hlpopt; CleanUp; return $FAILURE;
        fi;  __HELP__="${!hvar}"; # get *var (contents of hvar)
        if   [[ ! "$__HELP__" ]]; then
             PrintErr -p 0 "$MTHS" 0  "$hvar=''" >&2; # exported var undefined
             getparms_help $hlpopt; CleanUp; return $FAILURE;
        fi
    fi

    ###########################################################################
    # Do Help string clean up:
    # 1. remove any line continuations symbols in order to simplify parsing
    # 2. remove end comment (if not escaped): delete longest match from end
    # 3. any escaped comments markers replaced just with unescaped versions
    ###########################################################################
    if [[ "$__HELP__" == *"\\"$CR* ]];       then __HELP__="${__HELP__//\\$CR}"; fi
    if [[ "$__HELP__" == *" $SYMB_ECMT"* ]]; then opts="${__HELP__%% $SYMB_ECMT*}";
         opts="${opts//\\$SYMB_ECMT/$SYMB_ECMT}";  # remove escapes b4 any '#'
    else opts="$__HELP__"; fi; local rest="$opts"; # printf "HELP Rcvd: $opts\n";

    ###########################################################################
    # Parse HELP string to get specified items and of what form. Because of
    # OR'ed items (e.g.: -v:verb|--verb|m=3~ip) we need to do all parsing in
    # a do-while loop, so that we loop through all the OR'ed items. Note that
    # the variable 'rest' is the remainder of items still yet to be parsed.
    ###########################################################################
    local dlmt=$ITEM_NOLMT; local end_dlmt=''; # tracks matching delimiter
    local oldifs="$IFS"; IFS=' ';   # save & setup IFS related variables
    declare -a args; args=($opts);  # don't quote, args (already quoted)
    FNAME="${args[0]}";             # capture name of calling function
    local FNLEN=$((${#FNAME}+1));   # length used for indenting help
    local disc=0;  local mind=0;    # discard item & multiple indirect
    local nump=0;  local numi=0;    # number of parms & indirect parms
    local hndx=-1; local reqd=0;    # rcvd specific user help request
    local grpn=0;  local ornb=0;    # group number & OR group num
    local indx=0;  local lind=0;    # spec index & last index
    local ored=0;  local last_or=0; # OR'ed item flags & last
    local narg=${#args[@]};         # number of arguments
    local link=-1;                  # linked index
    cdebug no "$TrcIni";            # done init only trace

    ###########################################################################
    # Arrayizing HELP [HLP] using the standard 'NIX method (i.e.: args=($HELP))
    # means we still have to manually handle any item with spaces, for even if
    # it is quoted it is still broken up and multiple spaces are lost, unless
    # we keep a copy of the whole string and break off array chunks as we go
    ###########################################################################
    local save;          # aggregates items having quoted spaces
    local ltop;          # left over from options after | split
    local ltin;          # left over from indparm after , split
    local item;          # the parsed word used to reduce rest
    local srch;          # string to search for, e.g.: --verb
    local mind;          # flag indicting an indirect parm
    local indp;          # indirect parm part (after '='s)
    local optp;          # option part (before '='s)
    local spb4;          # space before item (vs.|)
    local lnks;          # if linking needed
    local ic=0;          # index for arrays
    local mtch;          # quote to match
    local DBG;           # for debugging
    cdebug on "$TrcAna"; # bgn Analyze trace

    if  ((indx < narg)); then  # 1st arg is func name, handled specially
        # defined constants: reqd=0; num=0; link=-1; mind=0; altn="";
        SetSpec $grpn "${args[$indx]}" "$HlpOpts" 0 "$ic" 0 -1 "~" 0 "" "$HLP_BASE"; ((ic++));
    fi  # NB: if ANY top level loop continue|break to update there: lind=$indx;
    for ((indx=1; indx < narg; indx++)); do # loop over all HELP string

        ############################################################
        # 1. Get Entire Quote - Part a (in ChkQuote) & b (following)
        # Use the 'rest' string to capture a whole item with spaces.
        # - mtch is set when we have an unmatched leading quote
        # - disc is set when we don't have a whole quoted item
        # Check if we have the whole item that we can process now,
        # otherwise keep gathering items until we have a whole quote;
        # get option info (previously called: whatitem "$item")
        ############################################################
        item="${args[$indx]}"; DBG="lind:$lind & indx:$indx";
        local proc=0; local mtdn=0; spb4=$((lind != indx));
        DBG_TRC  15 $indx "GetQuote Spec: indx:$indx, item:'$item', disc:$disc";
        ChkQuote $indx "Proc_Spec itm=$item"; # set vars for partial|full quote

        ############################################################
        # Note: this can't easily be combined with what is done for
        # the cmd-line case because 'save' here is also used to gather
        # the whole delimited group and not just one 'spaced' item.
        # Thus this is why here 'rest' cannot be reduced until the
        # delimited group is gathered & why rest is not reduced until
        # the loop end. [See save's usage in Delimiter Aggregation.]
        ############################################################
        if ((disc == 1)) || [[ "$mtch" ]]; then
            if  [[ ! "$item" ]]; then  proc=1; disc=0;
                PrintErr $ic "$QUNF" $ic "item:'$save' @ $ic [3]" >&2; # e.g.: param3?"
            elif ((disc == 0));   then  # unmatched && just found - remove lead whitespaces
                disc=1;  save="${rest#"${rest%%[![:blank:]]*}"}";
            elif ((mtdn == 1));   then  # discarding && matching done, so found the end
                mtch=""; proc=1;  disc=0; save="${save/$item*/$item}"; # remove all after this item
            fi                          # else keep discarding item til end quote found
        else proc=1; save="$item"; fi   # DBG="NoMatchNoDiscard";

        if ((proc == 0)); then          # check if no more data: if not process as is
            if ((indx >= narg)); then proc=1; disc=0; mtch=""; # record data
                 PrintErr $ic "$QUNF" $ic "item:'$save' @ $ic [4]" >&2; # e.g.: param3?"
            else DBG_TRC -s 15 $indx "Advance3: indx|narg:$indx|$narg, item:'$item' & rest='$rest' => '${rest#*"$item"}'";
                 rest="${rest#*"$item"}"; lind=$indx;
                 continue;  # del shortest match from start
            fi
        fi; DBG_TRC -x 15 $indx "InitGetQuote: proc:$proc, indx:$indx, item:'$item', rest:'$rest' => '${rest#*"$item"}'";

        ####################################################################
        # 2. Delimiter Aggregation
        # Detect if any item is delimited & remove: <>,{},[],(). Default is
        # that no delimiters means required. Allow grouped items, e.g.:
        # (parm1 parm2) OR [-i -j=parm]. NB: grouped item that begins with
        # option followed by parm(s) (e.g.: {-f parm}) has a special meaning:
        # indparm. To support grouped we must carry over the delimiter type.
        # Note, also have to handle the no space case: {-v}{-i:input~i}, so
        # which case we can't just take from the 1st delimiter to the last.
        ####################################################################
        DBG_TRC  0x21 "$dlmt" "bgn dlmt:${Items[$dlmt]}, end_dlmt:$end_dlmt, save:$save";
        if  [[ "$end_dlmt" ]]; then # carryover case
            if   HasUnescape "$end_dlmt" "$save"; # below: rem escaped delimiters
            then GetUnescape "$end_dlmt" "$save"; save="${UNESCBF//\\$end_dlmt/$end_dlmt}";
                 end_dlmt=""; fi                  # signal done
        else mind=0; dlmt=$ITEM_NOLMT;  # non-carryover case     # reset defaults
            local tmp=""; local tmp_dlmt; local remv=2;          # expect rm 2 chars
            # NB: don't use -u here in GetUnescape, remove escaped delimiters later
            case "$save" in # GetUnescape: split into after dlmt (tmp) & b4 dlmt+dlmt (rest)
            "["*) tmp_dlmt="]";  dlmt=$ITEM_SQARE;
                  if ! HasUnescape    "]" "$save"; then end_dlmt="]";  remv=1;
                  else GetUnescape -k "]" "$save"; save="$UNESCBF";    tmp="$UNESCAF"; fi;;
            "("*)  tmp_dlmt=")";  dlmt=$ITEM_PARAN;
                  if ! HasUnescape    ")" "$save"; then end_dlmt=")";  remv=1;
                  else GetUnescape -k ")" "$save"; save="$UNESCBF";    tmp="$UNESCAF"; fi;;
            "<"*) tmp_dlmt=">";  dlmt=$ITEM_ANGLE;
                  if ! HasUnescape    ">" "$save"; then end_dlmt=">";  remv=1;
                  else GetUnescape -k ">" "$save"; save="$UNESCBF";    tmp="$UNESCAF"; fi;;
            "{"*) tmp_dlmt="}";  dlmt=$ITEM_CURLY;
                  if ! HasUnescape    "}" "$save"; then end_dlmt="}";  remv=1;
                  else GetUnescape -k "}" "$save"; save="$UNESCBF";    tmp="$UNESCAF"; fi;;
            esac; # redo is case: {-v}{-i:input~i}; need to put back: {-i:input~i}

            if [[ "$tmp" ]]; then rest="$tmp$rest";  # tmp="{-i:input~i}"
                item="$save";   if [[ "$save" ]];    # redo this index
                then args[$indx]="$tmp"; ((indx--)); # if something to do
                DBG_TRC -s 0x22 $indx "$indx|$ic [disc:$disc, mtch=($mtch)]: REDO"; fi
            fi; reqd=${IReqd[$dlmt]};  ((grpn++));   # next line: del delimiters if present
            if  ((dlmt != ITEM_NOLMT)); then save="${save:1:${#save}-$remv}";
                if [[ "$end_dlmt" ]];   then save="${save//\\$end_dlmt/$end_dlmt}"; fi
            fi
        fi; DBG_TRC -x 0x21 "$dlmt" "end dlmt:${Items[$dlmt]}, end_dlmt:$end_dlmt, save:$save, remv:$remv";
        if [[ ! "$save" ]]; then continue; fi # if nothing to do, skip

        ####################################################################
        # 3. next strip out & process OR'ed items but do at least one loop
        # Note: this must be done before we can determine the base type):
        # split on '|'  to separate out each item from the rest; then we
        # split on words to separate out next ind parm from the rest. We
        # also get total number of ind parms, not counting escaped symbols,
        # based on the number of parms, e.g.: {-f parm1 parm2}; plus we
        # need to check if we've a real OR'ed group (i.e. not escaped '|').
        # FUTURE: may have to search for 1st unesc GRUP symbol in while loop
        # do while: ( ( ((nomor == 0)) && ((disc != 1)) ) || ((numi > 0)) );
        ####################################################################
        local isor=0;   # default set is OR group to false until set true
        while           # loop thru all '|' & ind parms ',' [optp & indp]
            DBG_TRC  0x23 "$ic" "$ic: save:$save, optp:$optp, indp:$indp";
            local arr=($indp); local narr=${#arr[@]}; numi=$narr; # num words
            last_or=$((ored > 0)); ored=0; local nuor=0;
            if  [[ "$save" == *"$SYMB_GRUP"* ]]; then
                local grp="$save";            local leng=${#grp};
                grp="${save%%"$SYMB_GRUP"*}"; local gpln=${#grp};
                if  ((gpln < leng)); then HasUnescape "$SYMB_GRUP" "$save";
                    ored=$((NOESC > 0)); isor=$((isor || ored));
                    if ((ored == 1));  then lind=$indx;  spb4=0; fi
                fi
            fi; if ((ored > last_or)); then ((ornb++));  nuor=1;
            # catch case where we're got last item in OR'ed group
            elif (((last_or == 1) && (ored == 0))); then ored=-1; fi

            # reset all variables that are new for each loop
           #save="${save//\\$SYMB_GRUP/$SYMB_GRUP}";        # now remove escapes b4 '|'
            local none=1; nump=0; parm=""; ltin="";
            if  [[ "$save" ]]; then none=0;                 # ensure we still have options left
                if ((ored == 0)); then ltop=""; else        # have to check this each time
                    ltop="${save#*"$SYMB_GRUP"}";           # get what's left after sep.: delete 1st col
                    if [[ "$ltop" == "$save" ]]; then ltop=""; fi # no separator, past end (empty)
                    save="${save%%"$SYMB_GRUP"*}";
                    if [[ ! "$save" ]]; then save="$ltop"; continue; fi # skip empty OR'ed item: a||b
                fi
            fi; DBG_TRC -x 0x23 "$ic" ""; # end of '|' tracing

            ############################################################
            # 4. in general we work from outer to inner, but we need to
            # split on "=" to separate option from its indirect parm(s)
            # & to identify any SHIP & OSIP items (e.g.: -d= & -f=indp)
            # Remember the option to disable OSIP only affects command
            # line processing, not the specification, especially since
            # OSIP is the only way to specify an ind parm in an OR group
            ############################################################
            local ship=0; local sopt=""; mind=0;
            DBG_TRC  0x24 "$ic" "dlmt=${Items[$dlmt]}";
            if [[ "$save" =~ [^\\]"$SYMB_INDP" ]] || [[ "$save" == "$SYMB_INDP"* ]]; then
                optp="${save%%"$SYMB_INDP"*}";   # get first word, divide at first "="
                indp="${save#*"$SYMB_INDP"}";    # get what's left after the first "="
                if   ( [[ "$indp" ]] && [[ "$optp" ]] ); then      # have to check if all altn
                    if [[ "$indp" =~ (^[$SHIPCH]+)(.*) ]]; then    # have to check if any sopt
                        sopt=${BASH_REMATCH[1]}; # get ship opts
                        indp=${BASH_REMATCH[2]}; # del ship opts
                    fi  # if '=' immediately followed by altname (':') | datatype ('~'), then ship
                    if   [[ "$indp" == "$SYMB_ALTN"* ]];           # SHIP!: -*=:altn (has "=:")
                    then ship=1; optp+="$SYMB_INDP$indp"; indp="";
                    elif [[ "$indp" == "$SYMB_TYPE"* ]];           # SHIP!: -*=~...  (has "=~")
                    then ship=1; optp+="$SYMB_INDP$indp"; indp="";
                    elif [[ "$sopt" != "" ]]; then ship=1;         # SHIP!: -*={+-.,012}
                         sopt+="$indp"; indp="";                   # put any indp back into sopt
                    elif [[ "$indp" ]]; then mind=2;               # OSIP!: -*=parm
                    else ship=1; fi                                # SHIP!: -*={+-.,012}
                elif   [[ ! "$indp" ]] && [[ "$optp" == -* ]]; then ship=1; # SHIP!: -*= (end w/ "=")
                elif ( [[ ! "$optp" ]] && [[   "$indp" ]] ) ||     # began with "=": =parm
                     ( [[ ! "$indp" ]] && [[   "$optp" ]] ) ||     # ended with "=": parm=
                     ( [[ ! "$indp" ]] && [[ ! "$optp" ]] ); then  # have just  "=": =
                    PrintErr $ic "$MIPP" $ic "\"$save\" @ $ic" >&2;  # now clean up save
                    if  [[ "$save" != "$SYMB_INDP" ]]; then        # del "=" unless only "="
                        if   [[ "$save" == *"$SYMB_INDP"  ]];
                        then local sl=${#save}; save=${save:0:sl-1};
                        elif [[ "$save" ==  "$SYMB_INDP"* ]]; then save=${save:1}; fi
                    fi
                fi
            else optp="$save"; indp=""; fi
            DBG_TRC -x 0x24 "$ic" "optp:$optp, indp:$indp";       # end of delimiter tracing

            ################################################################
            # Note: haven't yet gathered the whole delimited group, so this
            # is only for OSIP (-i=parm), where mind is set just above this
            ################################################################
            DBG_TRC  0x25 "$ic" "$ic: indp:$indp, optp:$optp, save=$save";
            numi=$(( mind != 0));                   # only applies to OSIP
           #mind=$(( numi >= 1));                   # mult ind parm: -i=ind1,ind2
            lnks=$(((numi >  1) || (isor == 1)));   # if ind parm or mult. option
            if    ((lnks ==  0)); then link=-1;
            elif  ((nuor ==  1)); then link=$ic;    # OR'ed group followed by another
            elif  ((link == -1)); then link=$ic; fi # else keep previous value

            ################################################################
            # process through any spaced ind parms: {-f parm1 parm2 parm3}
            ################################################################
           #if ((mind != 0)); then # FUTURE: when we have whole delimited group
           #    local none=$((narr > 0)); local arr0="${arr[0]}";
           #    if  ((none == 0)); then lind=$indx; break; fi # if neither, then we're done
           #    ltin="${indp/$arr0}"; indp="$arr0";
           #else link=$ic; fi

            ################################################################
            # 5. next determine what we have: a double dash, a pure option
            # (-i), a short-hand indirect param (-n#), an indirect param
            # (-i parm), or a regular positional parm; set the right flags:
            # is_... flags. Note: must check for '--' before single dash.
            ################################################################
            local pure=0; local aprm=0; local base;        # _BASE of item
            if   [[ "$optp" == $SYMB_EOOM ]]; then base=$EOM_BASE; # no more options (--)
            elif [[ "$optp" == $SYMB_EOBP ]]; then base=$EOM_BASE; # no more bgn prm (-+)
            elif [[ "$optp" == -* ]]; then                 # NB: may have altname: -o:name
                 local bare=${optp/$SYMB_ALTN*/};          # del all after altname ch.
                 if    ((ship == 1)); then
                       base=$SIP_BASE; pure=1; mind=0;     # shorthand: -i= (aprm=0)
                 elif  ((mind != 0));
                 then  base=$PRM_BASE; pure=1; aprm=1;
                 else  base=$OPT_BASE; pure=1; fi          # pure opt.: -i
            elif ((mind != 0));  then
                       base=$PRM_BASE; pure=1; parm=1;     # ind parm.: -i=ind_parm
            else       base=$PRM_BASE; nump=1; aprm=1; fi
            DBG_TRC -x 0x25 "$ic" ""; # end of indp tracing

            ############################################################
            # 6. check if item has a datatype and/or an alternate name
            ############################################################
            local dtyp="";
            DBG_TRC  0x26 "$ic" "Dtype $ic: indp:$indp, optp:$optp, mind:$mind, base:${BaseName[$base]}";
            if   ((mind != 0)) && [[ "$indp" ]]; then parm="$indp"; else parm="$optp"; fi
            local hsdt=0; if  [[ "$parm" == *"$SYMB_TYPE"* ]];
            then  HasUnescape "$SYMB_TYPE" "$parm"; hsdt=$((NOESC > 0)); fi
            local hsoa=0; if  [[ "$optp" == *"$SYMB_ALTN"* ]];
            then  HasUnescape "$SYMB_ALTN" "$optp"; hsoa=$((NOESC > 0)); fi
            local hspa=0; if  [[ "$parm" == *"$SYMB_ALTN"* ]];
            then  HasUnescape "$SYMB_ALTN" "$parm"; hspa=$((NOESC > 0)); fi

            ########################################################
            # 6.1 strip off & save any required datatype supplied: ~*
            # E.g.: param2~s-; but don't call in a shell, as it sets
            # DataType; but if invalid, keep getting parm; Note:
            # the data type function records any formatting error
            ########################################################
            if  ((hsdt == 1)); then # get Datatype
                dtyp=${parm#*"$SYMB_TYPE"}; # get all after first '~'
                parm=${parm/"$SYMB_TYPE"*}; # del all from '~' & after
                if ((ship == 1)); then
                parm=${parm/"$SYMB_INDP"*}; # del all from '=' & after
                fi
            fi; DBG_TRC -x 0x26 "$ic" "";   # end datatype tracing

            ############################################################
            # 6.2. get alternate name (':') if it exists & update options
            # need separate one for option (alon) & for parm (alpn) in
            # case we get one or each on an indparm (-f:anam=parm:indp)
            ############################################################
            local alon=""; local alpn="";
            DBG_TRC  0x28 "$ic" "get alt name: optp:$optp, prm:$parm, base=$base (${BaseName[$base]})";
            if  ((hsoa == 1)); then  # get alt. opt. name if exists
                if   [[ "$optp" == *"$SYMB_ALTN"* ]]; then # -i:altname
                     alon="${optp#*"$SYMB_ALTN"}";     # get what's left after sep.: delete 1st col
                     if ((ship == 1)); then
                     alon=${alon/"$SYMB_INDP"*};       # del all from '=' & after
                     fi; if [[ "$alon" == "$optp" ]]; then alon=""; fi # no sep., past end (empty)
                     optp="${optp%%"$SYMB_ALTN"*}";    # get 1st word, gets: -i [opt.]
                     if ((hsdt == 1)) && [[ "$alon" ]]; then # in case we have a data type
                          # NB: following is an error, but to display alon
                          alon=${alon%%"$SYMB_TYPE"*}; # del from altname (longest match from end)
                     fi
                fi
            fi
            if  ((hspa == 1)); then  # get alt. parm name if exists
                if   [[ "$parm" == *"$SYMB_ALTN"* ]]; then # illegal but process
                     alpn="${parm#*"$SYMB_ALTN"}";     # get what's left after sep.: delete 1st col
                     parm="${parm%%"$SYMB_ALTN"*}";    # get 1st word, gets: parm
                     if ((hsdt == 1)) && [[ "$alpn" ]]; then # in case we have a data type
                          alpn=${alpn%%"$SYMB_TYPE"*}; # del from altname (longest match from end)
                     fi
                fi
            fi; DBG_TRC -x 0x28 "$ic" "get alt name: optp:$optp, prm:$parm, alon|alpn:$alon|$alpn"; # end alt name trace

            ############################################################
            # 7. get the search pattern and determine the name string:
            # if indirect parm., remember name comes from its parm.
            # NB: we set srch name above for EMT BASE, don't clear
            ############################################################
            local name="$parm"; local opnm="";  # option name for indp option
            DBG_TRC  0x2A "$ic" "optp=$optp, alon|alpn:$alon|$alpn, parm=$parm, base=${BaseName[$base]}";
            case "$base" in                     # OptName debug via 0x29
            $HLP_BASE) ;;                       # use given name
            $PRM_BASE) if [[ ! "$parm" ]]; then name="$indp"; fi
                       if ((mind != 0)); then
                       OptName -o "$optp"; srch="$TMP";     # ind parm name, unless empty
                       OptName    "$optp"; opnm="$TMP";     # mod src name, e.g.: _i
                       else srch=""; fi;;       # use given name, no search name
            *) local temp=$optp;   if ((SIP_BASE == base)); then temp=${optp/'='*/}; fi # rm 1st '=' & after
               if [[   "$alon" ]]; then    name="$alon";    # use alt name for name: arg-parse
                       OptName    "$name"; name="$TMP"; alon="$name"; # convert to _: arg_parse
               else    OptName    "$parm"; name="$TMP"; fi  # mod src name, e.g.: _i
                       srch=$temp; opnm=$name;;             # parm setup for stripped srch
            esac;      DBG_TRC -x 0x2A "$ic" "";           # end opt name trace
            DBG_TRC -s 0x2B $ic "Naming indx|ic $indx|$ic: base:${BaseName[$base]}, name|srch:$name|$srch, indp:$indp, optp:$optp, parm:$parm, alon|alpn:$alon|$alpn";

            ############################################################
            # 8. record 1st occurrence of the end of markers: '--|-+'
            # Test 6: record an error if more than 1 OPTEND is found
            # NB: the right index for OPTEND is not ic, must calculate
            ############################################################
            if   [[ "$srch" == "$SYMB_EOBP" ]]; then
                if   ((OPTBGN == -1)); then EndBgnNdx=$indx; OPTBGN=$EndBgnNdx; # only get 1st 1
                     DBG_TRC -s 18 $indx "endbp set based on $SYMB_EOBP marker: OPTBGN:$OPTBGN";
                else PrintErr $EndBgnNdx "$MULO" $EndBgnNdx "$SYMB_EOBP" >&2; fi
            elif [[ "$srch" == "$SYMB_EOOM" ]]; then # GetEndNdx sets EndOptNdx
                if   ((OPTEND == -1)); then GetEndNdx $ic;   OPTEND=$EndOptNdx; # only get 1st 1
                     DBG_TRC -s 18 $indx "endop set based on $SYMB_EOOM marker: OPTEND:$OPTEND";
                else PrintErr $EndOptNdx "$MULO" $EndOptNdx "$SYMB_EOOM" >&2; fi
            fi

            ############################################################
            # 9. set the array contents for any item that must be saved;
            # 'link' is needed for the embedded param. case: m in -v|m;
            # even if no actual DataType, we must still set datatype fields,
            # namely: DataType, DataVal*, DataSrch, ... - debug with 0x27
            # make sure we're setting it on parm, not option for OSIP
            ############################################################
            Upd8Ind $ic $name $mind $pure $aprm $ornb $grpn $spb4; # set IndStat, debug 0x2C
            numi=$IndPrms; if ((IndStat == IND_INDP)); then mind=1; fi # or already set
            local num=$((mind != 0 ? numi : nump)); # used by Set Spec (old: IND BASE)

            DBG_TRC  0x2D "$indx" "Set Spec $ic|$indx: IndStat[$IndStat]:${IndName[$IndStat]}, base:${BaseName[$base]}, alon|alpn:$alon|$alpn, req:$reqd, dflt:'$dflt'";
            DBG_TRC  0x2E "$name" "Set Spec $ic|$indx: IndStat[$IndStat]:${IndName[$IndStat]}, base:${BaseName[$base]}, alon|alpn:$alon|$alpn, req:$reqd, dflt:'$dflt'";
            if   ((IndStat == IND_OSIP));
            then SetSpec $grpn "$opnm" "$srch" "$reqd" "$ic" "$num" "$link" "~"      "$mind" "$alon" "$OPT_BASE" "$link" "$isor" "$ornb"; ((ic++));  # 2 calls so incr
                 SetSpec $grpn "$name" ""      "$reqd" "$ic" "$num" "$link" "~$dtyp" "$mind" "$alpn" "$PRM_BASE" "$link" "$isor" "$ornb" "$IndStat"; # have both items
            elif ((IndStat == IND_INDP));
            then SetSpec $grpn "$name" ""      "$reqd" "$ic" "$num" "$link" "~$dtyp" "$mind" "$alpn" "$PRM_BASE" "$link" "$isor" "$ornb" "$IndStat"; # have only indp
            elif ((base == PRM_BASE));
            then SetSpec $grpn "$name" ""      "$reqd" "$ic" "$num" "$link" "~$dtyp" "$mind" "$alpn" "$PRM_BASE" "$link" "$isor" "$ornb";
            else SetSpec $grpn "$name" "$srch" "$reqd" "$ic" "$num" "$link" "~$dtyp" "$mind" "$alon" "$base"     "$link" "$isor" "$ornb" "$sopt" "$indp"; fi # all SHIP go here (NB: normally indp s/b "")

            # decrement the number of pos.parms|indparms still looking for
            if   ((mind != 0));        then if ((numi > 0)); then ((numi--)); fi
            elif ((base == PRM_BASE)); then if ((nump > 0)); then ((nump--)); fi; fi
            DBG_TRC -x 0x2D "$indx" ""; # don't put this on the same line with
            DBG_TRC -x 0x2E "$name" ""; # next line, it messes up dbgenum greps

            ############################################################
            # 10. end of do while OR'ed loop: do while tests & advance
            # don't advance items index (ic) if more parm specified
            ############################################################
            if [[ "$name" != "$SYMB_MORE" ]]; then ((ic++)); fi
            save="$ltop"; indp="$ltin"; nomor=0; # added entry to arrays
            if [[ "$ltop" == ";"* ]]; then ltop=""; fi
            if [[ "$ltin" == ";"* ]]; then ltin=""; fi
            if [[ ! "$ltop" ]] && [[ ! "$ltin" ]];  then nomor=1; fi
            DBG_TRC -s 0x32 "nomor=$nomor, numi=$numi, base=${BaseName[$base]}, ltop=$ltop, ltin=$ltin";
            ( ( ((nomor == 0)) && ((disc != 1)) ) || ((numi > 0)) ); # then keep going
        do  continue;  done    # loop thru all OR'ed items (save)
        DBG_TRC -s 0x33 $indx "AdvanceX: indx:$indx, item:'$item' & rest='$rest' => '${rest#*"$item"}'";
        rest="${rest#*"$item"}"; lind=$indx; # printf "rest=%s\n" "$rest"; # del shortest match
    done # done parsing all HELP options, ensure nothing remaining & it is not only whitespace
    cdebug no "$TrcAna"; IFS="$oldifs"; # restore orig value # NB: now: rest=comment, e.g.: " # more info"
    ###########################################################################
    # End of Specification Parsing
    ###########################################################################


    ###########################################################################
    # CheckSpec and Clean up tasks for finishing specification processing:
    # 1. Capture specifications into optimized arrays by type
    # 2. Verify we've properly accounted for all variables
    # 3. Debug Code to print out the specified options
    ###########################################################################
    DoBoxingTasks $ic "$save" "$opts"; # check all specification items [BOX]

    if ((FatalErrs > 0)) || ((CfgSet[CF_ANALYZ] == 1)); then # [ANA]
        local sts=$((NumErrors == 0 ? SUCCESS : FAILURE)); CmdLineStr="$@";
        PrintErrors  $sts; sts=$?; # print errors  # debug by -d114
        # Note: need following echo if fatal error
        PrintCmdLine $sts;         # print outputs # debug by -d49
        if ((CfgSet[CF_ANALYZ] == 0)) && ((CfgSet[CF_ECHONO] == 0)); then echo; fi
        CleanUp; return $sts;      # finish up & return status
    fi
    ###########################################################################
    # End Analysis Only Part: Quit if Analyzing only or if Spec error was fatal
    # Following this are the Parsing Command-Line processing [PCL|CMDL]
    ###########################################################################


    ###########################################################################
    # Perform Pre-Scan of Command-Line [PRE] to get index of End of ... markers.
    # This allows us to get an accurate account of required & optional parms.
    # This also allows us to break processing up into bgnprm, middle, endprm.
    # Stores snapshot of cmd-line string & puts it into an array for accessing.
    ###########################################################################
    IFS=' ';  cdebug on "$TrcCmd"; # do Cmdline tracing
    args=("$@"); CmdLineStr="$@";  rest="${args[@]}";  narg=${#args[@]}; # was: $#
    CmdLineNum=$narg; IFS=$oldifs; declare -a CmdLine; CleanupCL "$@";

    ###########################################################################
    # Gobble up open beginning positional parms that we come to   [BPP]
    # Note we can't grab any parm which is part of an OR'ed (mixed)
    # group, when any of the mixed group has already been received.
    ###########################################################################
    local bgnNdx=0; local getBgn=$NumBgnPrm; local endOpt=$EndOptPrm;
    local endNdx=0; local getEnd=$NumEndPrm; local prmReq=$NumPrmReq; local pc=0;
    local hveobp=0; local hveoom=0; local parm=""; local save="";  local lstpc=0;
    GetPosPrm 1; ShiftParm 1; # get begin pos. parms & shift if needed

    ###########################################################################
    # GetOption: Extract all the options that are available & specified  [XOP]
    # Loop over all known|unknown options in the command-line & extract them.
    # Extraction allows us to get an accurate count for end parms processing,
    # but we need to ensure we keep a list of the original indices for display.
    ###########################################################################
    local srch;     local reqd; local invd;   local more=0;
    local nopt=0;   local item; local disc=0; local found=-1; local itmNdx=0;
    local savpc=$pc; local savlst=$lstpc;    local ndx=${CmdLineNdx[$pc]};
    local rid="";   rest="${CmdLine[@]:$pc}";

    while  ((pc < narg)) && ( ((RxdEndOpt == -1)) || ((ndx < RxdEndOpt)) ) &&
                            ( ((OPTEND == -1)) || ((pc < OPTEND)) ); do
        DBG_TRC  0x75 "$pc" "GetOptns rmarg:$RMARGS, next:${CmdLine[$pc]}, rest:'$rest', pc<optend<narg:$pc<$OPTEND<$narg, RxdEndOpt:$RxdEndOpt";

        ############################################################
        # Step 2: Aggregate any quoted items with spaces
        # setup for unmatched quotes (because of enclosed space(s))
        # Not: This is required to keep rest & save in sync
        ############################################################
        found=0; disc=0; invd=$INV_GOOD; local mcnt=0;
        ndx=${CmdLineNdx[$pc]}; item="${CmdLine[$pc]}"; n=${#item}; # dequote it
        if  ((n > 1)); then local bgn="${item:0:1}"; local end="${item:$n-1:1}";
            if ( [[ "$bgn" == "'" ]] || [[ "$bgn" == '"' ]] ) && [[ "$bgn" == "$end" ]];
            then item="${item:1:$n-2}"; fi     # now it is dequoted
        fi; parm="$item"; lstpc=$pc; ((pc++)); # advance: ndx orig pc

        ############################################################
        # Step 3: Error if item collides with a defined help options
        # NB: must quote HlpOpt's otherwise '-?' can match anything
        ############################################################
        if  [[ "$parm" == "$HlpOpt1" ]] || [[ "$parm" == "$HlpOpt2" ]]; then
            SetRcvd 0 $ndx "$parm" 0 0 '-?'; found=1;# save: help options (invd=0)
            local str; if [[ "$parm" == "$HlpOpt1" ]];
            then  str="$HlpOpt1"; else str="$HlpOpt2"; fi
            hndx=$lstpc; PrintErr $ic "$RHLP" $ic "$str" >&2;
            if [[ " $rid" != *" $lstpc "* ]]; then rid+="$lstpc "; fi
            break; # we can quit
        fi  # No need to trace this block, not very interesting|complex

        ################################################################
        # Step 6: Check if we are past the end of options marker to see
        # if we can still process any more options & this is an option.
        # NB: can be past OPTEND yet still be receiving duplicate opts!
        # Handle this case by checking only if we haven't received '--'.
        ################################################################
        if  ((RxdEndOpt == -1)) && ( ((hveoom == 1)) || ( ((OPTEND != -1)) && ((pc > OPTEND)) ) );
        then  RxdEndOpt=$lstpc; # no more opts
              DBG_TRC -s 16 $ic "endop set based on past opts: pc:$pc, parm:$parm, srch:$srch [1d]";
        fi; local optn="${parm/=*/}"; if [[ "$optn" == -* ]] &&
            ( ((RxdEndOpt == -1)) && ((more == 0)) ) || # check if any options left or
            ( ((hveoom == 0)) && [[ "$SrchOptns" == *" $optn "* ]] ); then # if opt repeated (err)

            ############################################################
            # Parse Opts: loop over all opts, which may be linked, for
            # example: {-o|--out outfile ...} OR <-i|--incase|m=|n>.
            # Loop over all options until we find it (optional/required).
            # NB: we must record if we've passed the end options marker.
            # For options, we have to reset index each time as we may not
            # be processing them in order like positional parameters.
            ############################################################
            local anyFound=0; local optNdx=0;  local optEnd=$NumOption; local shipop;
            local anyError=0; local thisFnd=0; local savOpt="$optn"; local shipNdx=0;
            local gotopt=0;   local badopt=0;  local domult=0; local loops=1; # init: no combos


            ############################################################
            # Step 7: Before looping thru combos, match longest match,
            # as these take precedence over combos. E.g.: having -in -it
            # -int & receiving -int, it should match -int, not -in & -it.
            # Ensure a valid option name, else flag it as an error before
            # we waste time going through each letter, e.g.: -v:altname,
            # but handle SHIPs which have non-varname chars at end: +-.,
            ############################################################
            if   [[ "$SrchOptns" == *" $optn "* ]]; then gotopt=1; # norm opt
            else for shipop in $SrchShips; do
                 if   [[ "$optn" ==  "$shipop"* ]]; then gotopt=1; domult=3; break; fi # ship opt base
            done; fi
            if   ((gotopt == 0)) && [[ ! "$optn" =~ ^[-][-a-zA-Z0-9_]*[-+]?$ ]]; then badopt=1; fi # bad varname
            DBG_TRC  0x68 "$optn" "Multi-op bgn: optn:$optn (parm:$parm), got|bad:$gotopt|$badopt";
            if   ((badopt == 1)); then # NB: error processing fails for combos if ':' char involved
                 found=1; thisFnd=1; invd=$INV_OPTN; # Print Err called later => UNKI

            ############################################################
            # Step 8: check if this item is a combination of options,
            # based on CfgSet[CF_MULTOP]=0; e.g.: -ij OR -ji => -i -j
            # Check if we doing multi-ops, not a long opt, but -xy...
            # NB: if CF_MULTOP is disabled, Num ShrtOp will always be 0
            # and if CF_MULT2O is disabled, Do2 LtrOpt will always be 0
            # Handle Num ShrtOp=1 in case we have indirect parm options.
            ############################################################
            elif ((gotopt == 0)); then # don't do multi-op if we already found it
                local olen=${#optn}; local chrndx=0; local leadch;
                if  ((olen > 2)) && [[ "$parm" != --* ]] && [[ "$parm" != *"$"* ]]; then
                    if  [[ "$LongOptns" != *" $optn "* ]] &&
                        (( (NumShrtOp > 1) || ( (NumShrtOp == 1) && (NumIndOpt > 0) ) )); then
                        domult=1; loops=$((olen-1)); optEnd=$NumShrtOp; leadch="";
                    fi # NB: following printf requires leading '
                    if  ((Do2LtrOpt != 0)); then printf -v chrndx "%d" "'${optn:1:1}";  # -ca => c => 99
                        if  ((TwoLtrCnt[chrndx] > 1)); then # exclude special case: -in -io -i -j => -ino -ij
                            if  ((domult == 0)) || [[ "$SrchOptns" != *"-${optn:2:1}"* ]]; then
                                domult=2; leadch=${optn:1:1}; loops=$((olen-1));
                                optEnd=${TwoLtrCnt[$chrndx]};
                            fi
                        fi
                    fi
                fi
                DBG_TRC -s 0x69 "$optn" "ShortIndx Array: ${ShortIndx[@]}, 0:${ShortIndx[0]}, Multi-op: optn:$optn";
            fi; DBG_TRC -x 0x68 "$optn" ""; # end multi-op trace

            ############################################################
            # NB: for multi-op each optn letter is actually its own opt.
            # Add 1 to mlndx to index savOpt to skip over the lead '-',
            # add 2 to mlndx in skip over the lead '-' and first letter.
            # but we need to ignore SHIP options and never combine them
            ############################################################
            local   mlndx=0; local hvShip=0; # if we've found an option that matches SHIP
            while ((mlndx < loops)) && ((hvShip == 0)); do
                DBG_TRC  0x6A  "$mlndx"  "Multi-op combo loop: get (mlndx:$mlndx)";
                if  ((domult == 2)); then
                    optn=${savOpt:$mlndx+2:1};  found=0; thisFnd=0; optNdx=0; # without '-' here
                elif ((domult == 1)); then # e.g.: -ij => -i and -j
                    optn=-${savOpt:$mlndx+1:1}; found=0; thisFnd=0; optNdx=0; # opt with '-' here
                fi; ((mlndx++)); # NB: don't use ((getOpt > 0)) in while loop below
                DBG_TRC -x 0x6A "$mlndx"  "Multi-op combo loop: got:$optn";   # end combo trace
                # otherwise if prevents us from seeing multiply entered identical options
                while ((optNdx < optEnd)) && ((found == 0)) && ((more == 0)); do

                    ############################################################
                    # Get the stored option combos for this particular option;
                    # NB: only handling options here, i.e.: {-i} [-f|--file=parm]
                    # NB: here is where we actually set the ic index
                    ############################################################
                    DBG_TRC  0x6B "$optn" "Match combo op: ic:$ic, ndx:$optNdx, optn|next:$optn|${CmdLine[$pc]}, domult:$domult";
                    local src2=""; case "$domult" in
                        2) declare -a Arry2Ndx;
                           src2="${TwoLtrNdx[$chrndx]}"; Arry2Ndx=($src2);
                           # so that we discard leading and trailing spaces to get true index
                           ic="${Arry2Ndx[$optNdx]}";    # get nth one: $(echo "$str" | cut -d " " -f $optNdx)
                           src2="${TwoLtrOpt[$chrndx]}"; Arry2Ndx=($src2);
                           src2="${Arry2Ndx[$optNdx]}";; # get nth one
                        1) ic=${ShortIndx[$optNdx]};;
                        *) ic=${NdxOption[$optNdx]};;    # both: 0 & 3
                    esac;  ((optNdx++)); invd=$INV_GOOD;
                    if  ((domult == 2)); then srch="$src2"; else srch="${SrchName[$ic]}"; fi
                    more=${MoreIndx[$ic]}; reqd=${ReqdItem[$ic]}; mind=${MindParm[$ic]};
                    base=${BaseType[$ic]}; local ship=$((base == SIP_BASE));
                    DBG_TRC -x 0x6B "$optn" "Match combo op: ic:$ic, ndx:$optNdx, optn|srch|next:$optn|$srch|${CmdLine[$pc]}, domult:$domult";

                    ############################################################
                    # Step 9a: Check if this is a Short-Hand Ind Parm (-d=)
                    # NB: at this point, optn=srch option (item contains val)
                    # but not if a SHIP: optn=-d6- while srch=-d
                    # NB: we have to be careful of -d-|--d- lest we get d-|-d-
                    # and so we have to delete the shortest match from the end
                    # NB: [[ -bc == -b* ]] matches but should match [[ -bc == -bc ]]
                    # so only check SHIP item if we have domult=3
                    ############################################################
                    local hvind=0; local indp=""; # ind part (string, not flag)
                    DBG_TRC  0x6C "$optn" "2c:Options ic:$ic, ndx:$optNdx, optn|next:$optn|${CmdLine[$pc]}, more:$more, mind:$mind, domult:$domult";
                    DBG_TRC  0x6D "$name" "Indp ic|ndx:$ic|$optNdx, srch|optn|item|next:$name|$optn|$item|${CmdLine[$pc]}";
                    if  ((domult == 3)) && ((ship == 1)); then
                        if   [[ "$item" == "$srch"* ]]; # here item=optn
                        then indp="${item/$srch}";  parm=${item%$indp}; hvShip=1;
                             if  [[ "$indp" == "="* ]]; then indp="${indp:1}"; # drop opt'l '='
                                 item=$srch$indp; # extract '=' from item
                             fi; found=1; thisFnd=1; hvind=1;  local ship_one=${ShipOnes[$ic]};
                             # default: allow empty, just +|-, & numbers with commas (list)
                             local ship_flg=${ShipBits[$ic]};  local ship_non=${ShipMask[$SHIP_NON]};
                             local ship_enm=${ShipEnum[$ic]};  local ship_rng=${ShipRang[$ic]};
                             local test=$SHIP_ST8_OFF;
                             # 1st handle if opts are set, but none is unset & have bare option [item=opt]
                             if  ((ship_flg != 0)) && (((ship_flg & ship_non) == 0)) && [[ "$item" == "$srch" ]];
                             then invd=$INV_SHIP;  test=$SHIP_ST8_EMT;
                             elif [[ ! "$indp" ]]; then test=$SHIP_ST8_NON; # bare matching
                             elif [[ "$ship_one" ]] && [[ "$indp" =~ $ship_one ]]; then test=$SHIP_ST8_ONE;
                             elif [[ "$ship_enm" ]] && [[ "$indp" =~ $ship_enm ]]; then test=$SHIP_ST8_ENM;
                             elif [[ "$ship_rng" ]] && [[ "$indp" =~ $ship_rng ]]; then test=$SHIP_ST8_RNG;
                             else invd=$INV_SHIP;  test=$SHIP_ST8_BAD; fi   # SIPI: don't break, print err at end
                             ShipTest[$ic]="$test"; # record result
                        fi # else found=1; thisFnd=1; invd=$INV_SHIP; fi

                    ############################################################
                    # Step 9b: Check if this is an old-style indparm (-i=val)
                    # NB: only set hvind for OSIP (-f=ind), not normal indprm
                    # NB: flag an error when OSIP has been configured disabled
                    ############################################################
                    elif   [[ "$parm" == "$srch$SYMB_INDP"* ]]; then # name debug
                        if ((CfgSet[CF_INDEQL] == 1)); then name="${DescName[$ic]}"; # '=' as ' ' disabled
                             PrintErr $ic "$OIND" $ic "\"$parm\" should be \"${parm/=/ }\"" >&2;
                             found=1; thisFnd=1; invd=$INV_OSIP; # don't break, record bad value
                        fi # but still separate it
                        indp="${parm#*$SYMB_INDP}"; # get after '=' & b4 '='
                        parm="${parm%$SYMB_INDP*}"; item=$parm; hvind=1; # s/b optn= ?
                    fi; DBG_TRC -x 0x6D "$name" ""; # end SHIP trace
                    if [[ "$optn" == "$srch" ]] || ((hvShip == 1)); then

                        ########################################################
                        # Step 10: save the found option & get the number of
                        # parms that we need to get now (if any, e.g. indparm)
                        ########################################################
                        DBG_TRC  0x6E "$ic" "opt parms.: ic:$ic, mcnt|inv|lnk:$mcnt|$invd|$lnk, item=$item";
                        local is_lnk; local mndx; local lnk=-1;
                        local mind=${MindParm[$ic]}; local vals=""; if ((mind != 0));
                        then  mndx=${MindIndx[$ic]}; lnk=$mndx;
                        else  lnk=${LinkIndx[ic]};  mndx=-1; fi
                        if  ((lnk == -1)); then is_lnk=0; lnk=$ic; else is_lnk=1; fi
                        local num=${NumParms[$lnk]};
                        local noparms=$((num == 0)); # true (1) if num=0
                        DBG_TRC -x 0x6E "$ic" "opt parms.: ic|lnk|is_lnk:$ic|$lnk|$is_lnk, mind|mndx:$mind|$mndx";

                        ndx=${CmdLineNdx[$lstpc]};
                        DBG_TRC  0x6F "$ic" "Set Rcvd opt: ic|ndx:$ic|$ndx, mcnt|inv|lnk:$mcnt|$invd|$lnk, item=$item";
                        SetRcvd $ic $ndx "$item" $invd $mcnt "opt"; # save: option # RxdCount++
                        if [[ " $rid" != *" $lstpc "* ]]; then rid+="$lstpc "; fi
                        found=1; thisFnd=1; anyFound=1; # NB: can't advance if -f=parm
                        # NB: don't clear hvShip else get [MSOR]: Multiple same options received

                        ########################################################
                        # Step 11: advance to next item, but only if we don't have
                        # already (as with OSIP [-d=], SHIP [-d=parm]), & More.
                        # NB: we don't get Mixed parms here, but in Get Pos Prm,
                        # but indparm may be part of a mixed group! NB: Move to
                        # 1st parm, skip over multiple options, e.g.: -i|--in ...
                        # NB: ready for next item (pc has already been moved)
                        # NB: SHIP are unique, they have no separate parm, so we
                        # must (only for them) if more'ed increment mcnt here.
                        ########################################################
                        if ((hvind == 0)); then ((ic++)); ((lnk++)); fi
                        local pndx=${ParmIndx[$lnk]}; local mixd=${MixedGrp[$lnk]};
                        local cont=$(( (noparms == 1) || (pndx == -1) ));
                        if ((ship == 1)) && ((more != 0)); then ((mcnt++)); fi
                        DBG_TRC -x 0x6F "$ic" "Set Rcvd end: ic|lnk:$ic|$lnk, ship|cont:$ship|$cont, pndx|noprm=$pndx|$noprm";
                        if ((cont == 1)); then continue; fi

                        ic=$pndx; item="${CmdLine[$pc]}"; parm="$item";
                        while # here, loop thru no. of parms & re-get more each time
                            invd=$INV_GOOD; local n; more=${MoreIndx[$((pndx+mcnt))]};
                            if  ((hvind == 1)) || ( ((pc < narg)) &&
                                ( ((noparms == 1)) || ((num > 0)) || ((more != 0)) ) );
                            then if ((noparms == 0));  then
                                     if ((hvind == 1)); then item="$indp"; else item="${CmdLine[$pc]}"; fi
                                     DBG_TRC  0x70 "$item" "2d-:Parms item:$item, noparms:$noparms, hvind:$hvind, num:$num > 0, ic|ndx<opts|pc<narg:$ic|$optNdx<$NumOption|$pc<$narg, more:$more, mcnt:$mcnt, rest:$rest";
                                     # NB: if hvind then -f=val would have been fully assembled in TopCmdLin
                                     # When we advance to the next item we must re-check these
                                     if (((num > 0)) || ((more != 0))) && ((hvind == 0)); then
                                         # if item of the form "... ..." [only happens w/ indp]
                                         #found=0; disc=0;
                                         ndx=${CmdLineNdx[$pc]}; item="${CmdLine[$pc]}"; n=${#item}; # dequote it
                                         if  ((n > 1)); then local bgn="${item:0:1}"; local end="${item:$n-1:1}";
                                             if ( [[ "$bgn" == "'" ]] || [[ "$bgn" == '"' ]] ) && [[ "$bgn" == "$end" ]];
                                             then item="${item:1:$n-2}"; fi     # now it is dequoted
                                         fi; parm="$item"; lstpc=$pc; ((pc++)); # advance: ndx orig pc
                                     fi; DBG_TRC -x 0x70 "$item" "2d+:Parms item:$item, noparms:$noparms, hvind:$hvind, num:$num > 0, ic|ndx<opts|pc<narg:$ic|$optNdx<$NumOption|$pc<$narg, more:$more, mcnt:$mcnt, rest:$rest";

                                     ################################################
                                     # Step 12: Check if value matches the data type.
                                     # NB: Only indirect parms can have a datatype,
                                     # but if bad, still save item, but continue on.
                                     # NB: can't record error until we call Set Rcvd
                                     ################################################
                                     MatchData $ic "$item"; invd=$?; # debug via 0x66|0x65
                                 elif ((ship == 1)); then item="$indp"; # no strings (so no quotes)
                                 else item="$parm"; fi # pc already moved & no parms (so no quotes)

                                 ########################################################
                                 # Step 13: store data & update count if not already found
                                 # else keep looking in case more than 1 by the same name
                                 # NB: dequoting is now done for all items in Set Rcvd
                                 # NB: if more then increment mcnt, but don't move ic
                                 # For non-more, ensure not past end options marker
                                 ########################################################
                                 if [[ "$vals"  ]]; then vals+=" "; fi; vals+="$item";
                                 ndx=${CmdLineNdx[$lstpc]};
                                 DBG_TRC  0x71 "$ic" "Set Rcvd ind: ic:$ic, mcnt|inv|lnk:$mcnt|$invd|$lnk, vals=$vals";
                                 SetRcvd $ic $ndx "$vals" $invd $mcnt "ind"; # save: opt  # RxdCount++
                                 if [[ " $rid" != *" $lstpc "* ]]; then rid+="$lstpc "; fi
                                 found=1; thisFnd=1; anyFound=1; # ((getOpt--));
                                 DBG_TRC -x 0x71 "$ic" "";

                                 DBG_TRC  0x72 "$ic" "end indprm adv loop: ic|num:$ic|$num, more|lnk|endop:$more|$lnk|$RxdEndOpt";
                                 if  ((noparms == 0)); then vals=""; hvind=0; # if not no parms (i.e. more parms!)
                                     if ((more == 0)); then ((ic++)); ((lnk++)); else ((mcnt++)); fi
                                     if  ((RxdEndOpt == -1)) && ((OPTEND != -1)) && ((pc > OPTEND)); then
                                         DBG_TRC -s 16 $ic "endop set based on past opts: pc:$pc, parm:$parm, srch:$srch [2g]";
                                         # NB: following test assumes SHIP have 0 NumParms
                                         RxdEndOpt=$lstpc; if ((more == 0)) && ((num == 0)); then break; fi # we're done
                                     fi  # else: if 1st gets thru, let all associated parms thru
                                 fi
                                 DBG_TRC -x 0x72 "$ic"  "end indprm adv loop: ic|num:$ic|$num, more|lnk|endop:$more|$lnk|$RxdEndOpt";
                            fi

                            ############################################################
                            # test to continue looping (if false, then done with loop)
                            ############################################################
                            ((num--)); local tmp_num=$num; local tmp_pc="$pc < $narg"; # for debug
                            ((pc < narg)) && ( ((num > 0)) || ((more != 0)) );
                        do  continue;  done; mcnt=0;
                    fi; DBG_TRC -x 0x6C "$parm" "";
                done; # end: while ((optNdx < optEnd)) && ((found == 0)) && ((more == 0))

                ############################################################
                # Step 14: Check if this option was found & continue looping
                # else record error - problem here is this maybe a pos. parm
                # so don't record unknown error, let Handle Unknown do it,
                # unless it was part of a combo, then definitely an error
                ############################################################
                DBG_TRC  0x73 "$parm" "bgn check if optn:$optn found:$found";
                if   ((found == 1)) || [[ ! "$optn" ]]; # was: parm
                then if  ((ic != 0)); then DBG_TRC -x 0x73 "$optn" "end check if optn:$optn found:$found";
                         continue; fi # go to the next item
                     if  ((CfgSet[CF_HELPNO] == 0)); then # print help unless disabled
                         local cr=""; if ((CfgSet[CF_ECHONO] == 0)); then cr="$CR"; echo >&2; fi
                         if ((CfgSet[CF_NOWRAP] == 0));
                         then printf "%s$cr\n" "$__HELP__" | Indent -a -e -i $FNLEN -m 100 >&2;
                         else printf "%s$cr\n" "$__HELP__" >&2; fi
                     fi; DBG_TRC -x 0x73 "$optn" "end check if optn:$optn found:$found";
                     CleanUp; return $FAILURE; # help is special, execute immediately if enabled
                elif [[ "$RcvdOptns" != *" $parm "* ]];  # have to do here since anyFound will set found=1
                then invd=$INV_OPTN; DBG_TRC -x 0x73 "$optn" "end check if optn:$optn found:$found";
                     if   [[ "$IndOption" == " $optn " ]]; # check if opt matches an ind parm opt
                     then PrintErr $lstpc "$INDO" $lstpc "$parm ($optn matches$IndOption)" >&2;
                     elif ((domult == 1)) || ((domult == 2)); # NB: 3 used for SHIP
                     then PrintErr -m $domult $lstpc "$UNKC" $lstpc "$parm has unfound: $optn" >&2; fi
                    #else PrintErr "$UNKI" $lstpc "$parm" >&2; fi # let Handle Unknown do
                else DBG_TRC -x 0x73 "$optn" "end check if optn:$optn found:$found"; fi
            done; if ((anyFound == 1)); then found=1; fi # but thisFnd stays 0
            DBG_TRC -s 0x74 "$parm" "found:$found";
            # NB: if we don't drop option here, we get a waterfall of errors
            if ((found == 0)); then continue; fi # drop option, goto next parm
        fi  # if options are still allowed and an option
        #---- Parse End Parms ------------------------------------------
        DBG_TRC -x 0x75 "$pc" "GetOptns end: pc<optend<narg:$pc<$OPTEND<$narg, RxdEndOpt:$RxdEndOpt";
    done;

    ####################################################################
    # Restore starting point, Collapse array on rid indices (i.e. options
    # since no longer needed), and then we can have only parms left
    ####################################################################
    pc=$savpc; lstpc=$savlst;
    if [[ "$rid" ]]; then CollapseArgs "$rid" 1; fi

    ####################################################################
    # Parse all the ending parms, if any available & specified    [EPP]
    # Gobble up any open positional parameters that are now left.
    # Note we can't grab any parm which is part of an OR'ed (mixed)
    # group when any of the mixed group has already been received.
    # Handle errors if any cmd line item was not found,
    # if end of opts & it looks like an opt (not a neg. number)
    ####################################################################
    GetPosPrm 0; ShiftParm 0; # get end pos. parms & shifting if needed
    HandleUnknown $pc $RxdEndOpt; cdebug no "$TrcCmd"; # stop cmd tracing

    #---- Check Command-Line Items [CCL] ---------------------------
    PrmDatatype; # Do datatype checking of all pos parm, debug via 0x8A
    ChkCmdLine;  # Check consistency of cmd- line items, debug via 0x82

    ###########################################################################
    # Print out cmdline items [POP] to user and collected errors if configured;
    # allow errors to be printed out unless help was the 1st item received.
    # NB: asking for help is a 'failure' to complete processing cmd-line items,
    # but printing out the full results of processing if help was not the first
    # item allows the caller to check for success to see if they should go on.
    # NB: must call Print Errors before Print Cmd Line to get updated result
    # Keep printing of errors in sync with: End of Analysis Only Part
    ###########################################################################
    local sts=$((NumErrors == 0 ? SUCCESS : FAILURE));
    if  ((hndx != 0)); then        # if hlpndx unset (-1) or rcvd but not only parm.
        PrintErrors  $sts; sts=$?; # debug via 0x85   # only print errs if !help
        PrintCmdLine $sts;         # debug via 0x84   # print the output arrays
    fi # NB: help request in cmd-line processing is user's help, not getparms
    if  ((hndx != -1)) && ((CfgSet[CF_HELPNO] == 0)); # if help requested & enabled
    then local cr="";  if ((CfgSet[CF_ECHONO] == 0)); then cr="$CR"; echo >&2; fi
        if   ((CfgSet[CF_NOWRAP] == 0));              # then print it
        then printf "%s$cr\n" "$__HELP__" | Indent -a -e -i $FNLEN -m 100 >&2;
        else printf "%s$cr\n" "$__HELP__" >&2; fi
    fi

    ###########################################################################
    # Output Status [OUT]  NB: if not doing debug or timing, don't print extra
    # line at end. [For reason why, see operation of: getparmstest -td0]
    ###########################################################################
    if  [[ "$TrcItm" ]]; then DispItems; fi # -di: display item, debug via 0x88
    local cr=""; if  ((CfgSet[CF_ECHONO] == 0)); then echo; cr="$CR"; fi
    if  ((DbgPrt == 1)); then printf "PPID=$PPID$cr\n"; fi
    CleanUp; return $sts;      # finish up & return status
} # end get parms

#############################################################################
# End Main Function
#############################################################################

#############################################################################
# Func Out handles those external function that need a verbose flag to output.
# Note: Func Opt should only be used for those functions that Func Output
# won't easily work, as Func Output keeps internal function clean of output.
# Func Output handles those external function that need help to get their
# output printed, since they are optimized using global variables. Other
# functions have print options (-v), while others print themselves.
#############################################################################
function  FuncOut() { # FuncOut func sts # gets output for some functions
    # some functions we want their outputs even if it failed
    local func=$1; local sts=$2; shift 2;
    if   [[ "$sts"  == "$SUCCESS" ]]; then case "$func" in # only output if success
    "is_number") echo "$XTRCNUM";;
    "is_string") echo "$XTRCSTR";;
    esac; fi
}

#############################################################################
# Individual Function Access (exposed by Get Func)
# all utility functions are named lowercase; they are ones that may be useful
# for the user, but are specifically exposed to verify they work correctly;
# grep for all lowercase functions (excluding internal only ones capitalized)
#############################################################################
declare -a funcs;  # auto-generated by grepping this file for functions
function  SubFunc() { # SubFunc {-q}{-v}{-i}{-t} # -q quiet, -t show title header
    local sopt="-u";
    local vrb=1;  if [[ "$1" == -q ]]; then vrb=0; shift; fi
    local det=0;  if [[ "$1" == -v ]]; then det=1; shift; fi
    local int=0;  if [[ "$1" == -i ]]; then int=1; shift; sopt="-fd"; fi; local tab="";
    local hdr=""; if [[ "$1" == -t ]]; then shift; if ((int == 1));
          then hdr="List of All of the Internal Functions"; tab="\t";
          else hdr="Externally Accessible Functions List:"; fi
    fi
    local oifs=$IFS; IFS="$CR"; local help; local func;
    local lcl=0; local cr="$CR";
    # following deletes comments, so skip: " | cut -d '(' -f1
    # specifically exclude from list: Print..., Init...,
    if   ((int == 0));
    then funcs=($(grep "^function .*()" $SELF | sed 's/^function *//' | grep -Ev "^[A-Z]" |  grep -Ev '__|_help|getparms' | sort $sopt));
    elif ((vrb == 1));
    then funcs=($(grep "^function .*()" $SELF | sed 's/^function *//' | grep -Ev '__|_help|getparms' | sort $sopt));
    else funcs=($(grep "^function .*()" $SELF | sed 's/^function *//' | sed 's/[()].*/()/' | grep -Ev '__|_help|getparms' | sort $sopt)); fi
    IFS="$oifs";     # local n="${#funcs[@]}"; printf "Functions[$n]:\n";

    local leng=1; local off=1; # do prescan to get offset of ':'
    if  ((det == 1)); then for func in "${funcs[@]}"; do func="${func/"("*/}"; # echo "$func";
        if   ((DEV == 0)) && [[ "$func" == *_dev ]]; then continue; fi # dev only function
        func+=" "; leng=${#func}; if ((leng > off)); then off=$leng; fi
    done; fi

    if  ((vrb == 1)); then # could have done (but ugly format) via: printf "${funcs[@]}\n"
        if  [[ "$hdr" ]]; then cr="": printf "\n%s\n" "$hdr";
            printf "%s" "-------------------------------------";
        fi; for help in "${funcs[@]}"; do # echo "$help";
            func=${help/"("*}; #if [[ "$func" == *"item"* ]]; then cdebug on; fi
            if  ((DEV == 0)) && [[ "$func" == *_dev ]]; then continue; fi # dev only function
            if  [[ "$help" == *" local "* ]]; then lcl=1; # del shortest from start
                # have to be careful because =' | =" may come after the =" | ='
                # so no matter which order we try to do it it may be wrong,
                # so safer to delete before first "=", then de-quote string
                help="${help#*$SYMB_INDP}"; local n=${#help}; ((n--));
                if   ((n > 0)); then # remove final semicolon (;)
                     if [[ "${help:n:1}" == ';' ]]; then help=${help:0:n}; fi
                fi   # now remove outer matching quotes (de-quote)
                # only remove 1st & last single quote if both there
                if   [[ "${help#\'}" != "$help" ]] && [[ "${help%\'}" != "$help" ]];
                then help="${help#\'}"; help="${help%\'}";
                # only remove 1st & last double quote if both there
                elif [[ "${help#\"}" != "$help" ]] && [[ "${help%\"}" != "$help" ]];
                then help="${help#\"}"; help="${help%\"}"; fi
                help=" $help"; # in local case we have no leading space so we must add one
            elif [[ "$help" == *" # "* ]];  then help=${help#*"#"};
            else  help=""; fi; if [[ "$cr" ]];  then cr=""; echo; fi
            if   ((det == 0)); then func="${func/()*/()}";
                 printf "%s\n" "$func"; # print function name only
            else printf "%-"$off"s $tab:%s\n" "$func" "$help" | Indent -a -s ":"; fi
        done; if ((int == 0)); then
            printf "e.g. call : getparms.sh $SYMB_UTIL matchdata ~i@-31--1 -11; echo \$?";
            printf " # check pattern matching & echo result\n\n";
        fi
    fi
} # end Sub Func (ShowFunc) bgn

#############################################################################
# Get Func gets the list of internal functions (those in all small letters):
# dbgenum, getsample, is_number, is_string, matchdata, unescape, upd8_dev
# Ensure Get Func is not called recursively by Sub Func
#############################################################################
function  GetFunc() { local HELP="GetFunc {-s}{-q}{-v}{-i} cmd opts # -s skip title, -v detail, -i all internal";
    InitAll; while [[ "$1" == -d* ]]; do # even for help to display right we must init all
        if ! DBG_ENA "$1"; then getparms_help -h; return $FAILURE; fi; shift;
    done; local found; local sts=$FAILURE;
    local hdr="-t"; local qyt=-q; local int=""; local det=""; # set defaults
    while [[ "$1" == -* ]]; do opt=$1; shift; case "$opt" in
        -s|-t) hdr="";;              # skip the title lines
        -q) qyt=-q;;                 # don't echo functions
        -v) det=-v;;                 # show function's help
        -i) int=-i; qyt=""; hdr="";; # show all int. funcs (no title)
        -*) printf "%s\n" "$HELP" >&2;  return $FAILURE;;
    esac; done; local func="$1"; shift; local exec=0;
    if [[ ! "$func" ]]; then qyt=""; fi; if [[ "$int" ]];
    then # create file if doesn't exist | older than getparms
         local  file="$FLST"; if [[ "$det" ]]; then file="$VLST"; fi
         if Upd8File "$file"; then
         SubFunc  $qyt $det $int $hdr >"$file"; fi; less "$file";
    else SubFunc  $qyt $det $int $hdr; fi
    if [[ ! "$func" ]]; then return $?; fi

    for found in "${funcs[@]}"; do # NB: must put func in braces to expand b4 ()
        if  [[ "$found" == "${func}()"* ]]; then # ensures we find only 1 func
            # to debug function, set _DEBUG_func=on (via debug function)
            local  dbg="_DEBUG_$func"; dbg=${!dbg}; # get value of the flag
            { cdebug on "$dbg"; } 2>/dev/null       # execute the found func &
            $func "$@"; sts=$?; FuncOut $func $sts; # save status & get output
            ((exec++)); { cdebug no "$dbg"; } 2>/dev/null
        fi
    done; if ((exec == 0)); then echo "no function found!"; fi; return $sts;
} # end Get Func

#############################################################################
# Main Script execution [Note: this must be kept as last function in script!]
# To debug function, set _DEBUG_func=on (via debug function)
#############################################################################
DBG_ME="_DEBUG_$FUNC"; DBG_ON="${!DBG_ME}"; # get value of debug flag
{ cdebug on "$DBG_ON"; } 2>/dev/null;       # to enable cdebug
getparms "$@"; sts=$?; SetRslt $sts; DBG_TRC -x 1 "Done Debug All"; # stop trace
{ cdebug no "$DBG_ON"; } 2>/dev/null;       # to disable cdebug
if ((SRCD == 1)); then return $sts; else exit $sts; fi  # don't exit if sourced
#############################################################################
# End Main Function
#############################################################################

#############################################################################
# Everything below this point is for documentation purposes only (not code)
# NB: after every code modification remember to rerun: getparmstest.sh -x
# TODO:
#############################################################################

#############################################################################
#_HIST_BGN # Document page delimiters; o/p via: getparms --hist
#
# History and Development Notes
# 1.0.4 Functionality Added: (most recent first)
# - When SHIP has an illegal value (e.g. spaces), now command line printed
#   value is quoted so that user's eval can work seamlessly
# - Allowed SHIP values in command-line to be separated from the search string
#   portion by an optional equal sign (e.g.: -m_p_h=50.5) just like an indparm
# - Added configurability of SHIP items by adding SHIP options: -d={+-.,012}
# - Added negate extraction on matching ('@@@'|'%%%') to return what is left
# - Added config setting (-cx) to disable location symbol ('~') use for regx
# - Fixed regex class cases where only one value (e.g.: parm~s%%[[:digit:]]
#   & changed the location marker ('+') to be same as datatype marker ('~')
#   so it does not interfere with Bash regex's use of '+' in regex searches
# - Added documentation detailing all files related to getparms|getparmstest
# - Added copy utility to copy files elsewhere: getparms -cp {-f}{dstdir}
#   and documented the file usage of both getparms.sh and getparmstest.sh
# - Delete debug header OptionChg & put its contents after Configure header
# - Fixed error when cmd-line option began with valid option but had invalid
#   chars (particularly ':'); example: getparms -on -~ "func -v" -v:altn
# - Fixed missing opt output name when alt name has no leading '-' with -cl,
#   example: getparms -cbl -~ "func -v:altn" -v; # => reqd[01]:       "-v"
# - Changed output name of any opt ending in '+' [including '-+'] to '_plus'
#   (was just deleting trailing '+' in output name which caused collisions)
# - Removed external functions visibility and made them only for testing use
#   & added sub-options (-hts & -htn) to support string+var|number opts help
#
# 1.0.3 Functionality Added: (most recent first)
# - Fixed Indent for 0 offset and added ending lines with continuation ('\')
#   so lengthy whole command lines can be broken up but still copied & pasted
# - Fixed carriage returns on user's help output
# - Moved debug output from detailed help (--help) to debug help (-d --help)
# - Allow following OR'ed options -a|-a-|-a+ even though there is an output
#   name collision (_a|_a_|_a) to not be flagged as a collision (MULP)
# - Added initialization tracing (-d_) to trace getparms option parsing
# - Display samples (-so) no longer scraped from getparms, but are generated by
#   getparmstest -x and individual examples (-s?) now support ranges: {n{-{m}}}
# - Fixed problems where any non-ending '+' was accepted in both options & parms
#   (e.g.: -o+o & o+o); now only ending '+' is allowed in options & not in parms
# - Combine UNKO & UNKP into UNKI as the distinction is not relevant
# - Added Upd8File to see if file doesn't exist or is older than base file
# - Added is_older function and create help files once to save run time
# - Allow HELP string to be gotten from an exported variable, so as not to
#   to clutter the command-line; specify name of exported var in HELP string
#   with leading underscore (function names starting with '-' are illegal)
# - Save & maintain the original received command-line indices for reference
#   prior to extracting and compacting the list of received items list
# - Moved all ChkQuote & GetQuote calls into one place for simplicity
# - Added pausing & restore flags (-p|-r) to DBG_TRC to limit sub-functions
# - Now looping over all beginning parms until satisfied, then extracting all
#   options until satisfied, then processing remaining parms & after EOOM
# - Added pre-scan to know where EOBP & EOOM limits are for parm counting
# - Added end of begin parms marker (EOBP == '-+') & made configurable: -pb
#
# 1.0.2 Functionality Added: (most recent first)
# - Added post-cmd-line parm shifting to handle problem with leading options
#   and optional and required parms, where cmd-line order has parm value first
#   then option, so that optional parm was filled, but not the required parm
# - Added new debug option (-ds) to show the pre-shifted placing of parms
# - Added per user & per process ID file extensions so temporary files won't
#   collide even when running multiple copies by same user at the same time
# - Added warning if sample files out of date with actual getparms version
# - Changed user message from debug (-dm "msg") to config flag (-cu "msg")
# - Changed -ce config to now remove all empty echos, not just the last one
# - Added per user welcome banner for getparms.sh {-h} invocation first time
#   and a welcome flag (-w) that allows the welcome banner to be seen again
# - Added sample files generated by getparmstest.sh -x -t<d|e|f|a|r|m|s>
# - Added generic means for 1 error to filter or be filtered by another error
# - Extended percent datatype to handle two input values to go from n-m
# - Fixed getparms -ch  -pz=@ -~ 'func  # error BPVR' # so it outputs func=4
# - Fixed getparms -chn -pz=@ -~ 'func  # error BPVR' # so it hides the error
# - Added configuration to allow multiple options, ind. parm, or SHIP items
#   for the same option not to be flagged as an error
# - Improved displaying of multiple same SHIP item
#
# 1.0.1 Functionality Added: (most recent first)
# - Fixed problem with more ind parm with OR'ed options: -f|--file=parm ...
# - Fixed status of function, was always printing 'valid' even when an error
# - Add full string support for surrounding number datatypes (not just +|-|~)
# - Fixed range hyphen in regex search being confused with normal getparms range
# - Add output capability for external functions using global variables
# - Add the ability to select surrounding text be whole line (i.e. a wrap or
#   girding: '...+...') or just part of a line (i.e. a slice: '+...+...+')
# - Allow the Spec symbol (-~) to directly abut spec string (e.g.: 'func ...')
# - Changed percent datatype to be a range value type (to get a range error)
#   and to support num|int based on the number specified, also allowed default
#   (no datatype specifier just a number to be interpreted as a percent)
# - Added string extraction capability also for plain bash pattern matching
# - Fixed regex matching matching anywhere in string & made ERE unquoted
# - Fixed problem with initial carriage return printed only sometimes (NbEcho)
# - Change unknown configs (-c.) to warning and continue to support new versions
#
# 1.0.0 Functionality Added: (most recent first)
# - Moved timing output config (-ct) to a debug flag (-dt) & added detail (-dt+)
# - Added specific error to catch multiple indparm using comma separated values
# - Allow the option part of new & old indirect parm to have an alternate name
# - Converted help displays longer than 1 page to use less utility for paging
# - Completely reworked DBG_TRC: eliminated DbgCfgOn & combined with DBG_TRC
#   (-s option), eliminated -n option & moved to a configured option ('.'), &
#   reorganized tracing numbers around functionality instead of random numbers
# - Distinguish between failures in occurring in is_string or is_number vs.
#   failures occurring in MatchData (e.g.: whether enum|range|value|match test)
# - Added separate debug help (-d --help) and shortened the normal help (-h)
# - Fixed multi-opt combos to check longest direct match first, so that having
#   -in -it -int and receiving -int matches -int & not -in & -it
# - Added checks to ensure we can't combine pure options with indp options,
#   so that -i -f=indp which specially see that -if is an invalid combination
#
# 0.9.0 Functionality Added: (most recent first)
# - Changed SHIP symbol from '#' to '=' to match ind parms, also added alterate
#   naming both before or after '=': -d:name= | -d=:name, and prevent datatypes
# - Added counts for number changed Delimiters & Program Symbols from default
# - Added error checks for illegal more values: {-f ...}, -f=..., and -i ...
# - Allow getparms to call getparmstest to support testing easier
# - Changed from comma separated indparm in specification (-f=ind1,ind2,...)
#   to delimited indparm {-f ind1 ind2 ...}
# - Fix counting of required items so that we can know if an optional positional
#   parameter position should be accepted or passed over by keeping a running
#   count of required left to get
# - Moved indp option into separate parsed location from first parm, so only
#   receiving the option is displayed better (how many times received); before,
#   -f=prm1,prm2 if only received, -f would show MIPP for prm2, but not prm1
# - Optimized more so that '...' is not saved as a separate entry and so that
#   if only 1 item received we don't display: empty[0]: ...=""; moved more flag
#   to the previous parsed item, which simplifies processing
# - Add _1 to first more parm (so that they are all of the same form: parm_n)
#
# 0.8.0 Functionality Added: (most recent first)
# - Distinguish between received double dash and specified double dash as far
#   as turning off command-line reception of options
# - Moved Check consistency of Specification items to own function: ChkSpecItems
# - Moved Check consistency of command line parameters to function: ChkCmdLine
# - Config -cc (show output even if no changes) now overrides -cq (no output)
# - Changed output so (without -cc) pure options are not printed if not received
# - Added configuration option to suppress HELP output when not needed
# - Fixed parm part of mixed group (e.g.: m|-i) when it is first item specified,
#   should not be in BgnParm (otherwise -i|m ordering would then be different)
# - Fixed problem with "=" in default value being taken by ind. parm processing
# - Added check for missing function name (by excluding a leading hyphen) and
#   if name not valid varname, it's changed in output to 'func' so eval works
# - Added check for output name collisions between options and parms also
#   (e.g.: option -a & parm _a collide; option -a & parm a collide if -cl)
#
# 0.7.0 Functionality Added: (most recent first)
# - Added support for ranges, enums, & numbers in Short-Hand Indirect Parms,
#   e.g.: -d5-6 OR -d5,6 OR -d5, OR -d-6--5 OR -d0.25 OR -d5.6-7.8
# - Added support for Short-Hand Indirect Parms [SHIP] (no equals): -d#
#   and extended it to support empty ("") and sign values ('+'|'-')
# - Distinguish between non-fatal & fatal specification errors & allow
#   the processing of the command-line for non-fatal specification errors
#   still output received command-line options that are useful to know
# - Add Values regex matching to Surrounding strings via new symbol (%)
#   and remove old Surrounding strings approach ('+')
# - Add built-in test for all datatypes (-td), Surrounding strings (-ts), &
#   Required|Optional delimiters (-tr); Note: multi-op (e.g.: -i & -j => -ji),
#   multi-parms (...), parm & option ordering, configuration options (-c), and
#   a sample parsing symbol change (-p) are all tested via Test Output (-do0)
# - Added bgn+mid+end, bgn++end, mid+end, & bgn+mid support to Surrounding text
# - when Analyze error still display the Command Line output
#   e.g.: 0 valid[0]: func=4 : NOTSPEC : problem in the specification [4]
#
# 0.6.0 Functionality Added: (most recent first)
# - Added tracing per section: Analyze only, Cmd-Line only
# - Added prescan of output lines to get max column width for name & srch
# - Added handling for embedded escaped quotes for single & double quotes
#   and verified it works in default strings attached to a parameter
# - Added valid parm name check and error if contains invalid characters
# - Replaced special data configuration separator ('%') with hyphen ('-')
# - Changed EndOptMarker calculation when not specified to now be based
#   on 1 past last specified option (pure|indirect)
# - Added handling of escaped continuation lines: \<cr>
# - Redid string subtypes to allow them to be combined in any order
# - Expanded string datatype by removing s|l|a|w types & replacing with s &
#   subtypes: caps (c), lower (l), underscore (u), n (numbers), s (spaces),
#   delimiters (d), math-logic (m), punctuation (p), & symbols (y); also
#   added a new string datatype variables (v) that must begin with a letter|
#   underscore and optionally followed by only letters|numbers|underscore
# - Added value|enum|surround support (not range) for file types (~frw) and
#   added executable attribute (x)
#
# 0.4.0 Functionality Added: (most recent first)
# - Add auto-detect hex integers and auto-convert to decimal integers
# - Removal of 2 rule restrictions on parameter ordering in HELP string:
#   Test 9: optional option not allowed before positional parm
#   Test 8: reject an optional regular parameter followed by anything other
#   than another regular parameter
# - Add support for unsigned integer datatype ('#')
# - Add datatype for email (~e) of format name@grp.ext & urls|webpages (~u)
#   of format [http[s]:://][www.]site.org
# - Add datatype surrounding text (~s@bgn+end) and replace Substring string
#   types begin, exact [i.e. whole], contain, trail (b|e|c|t{i})
# - Added support for long help messages using Indent and \n recognition, so
#   HELP='func ... # \ninfo line1\ninfo line2' will print as:
#   func ...
#        info line1
#        info line2
# - Added support for file or dir check
# - Added additional error return codes for case when error printing disabled
# - Fix error reporting of multiop letter options: unknown -cxy reported as
#   separately as -c, -x, and -y
# - Add string compare as is (not case insensitive)
# - Add means to collapse repeated error messages
# - Bug fix: capture multiple end options marker error when unspecified
# - Add equals substring search option (~e and ~ei) [Replaced with ~s@]
# - Add option to remove underscores from long options, e.g.: --out => out
#
# 0.4.0 Functionality Added: (most recent first)
# - Support non-colliding single letter and dual letter combinations, e.g.:
#   -in -io -i -j => -ino -ij
# - Add support for dual letter options to be combined, e.g.: -in -io => -ino
# - Add config option to disable dual letter combining feature
# - Remove auto-disabling of single-letter combining feature when any pure
#   options are specified that have 2 or more letters
# - Allow delimiters '[]{}<>()' to be configured for optional|required, and
#   move config pref -co for no delimiters (blank) and tie it to this option
# - Add config option to not print help (if case user wants different format
#   than what is required for the specification format
# - Add support to externally access type checking functions, useful for
#   testing getparms and also for getparms to support useful utility operations
# - Add datatype ranges (~i@1-3) and enumerated lists (~s-@slow,med,fast);
#   Note: range checking for integers is numeric, while for strings is lexical
# - Add IP4|IP6|IP datatype checking (in hex|dec|both), leading 0's excluded
# - Allow configuration of parsing symbols: ensure they are unique & none can
#   be letters or numbers or special bash characters or our grouping symbols
# - Rearranged datatype & default processing to allow them in either order
# - Once an option of a mixed group is found, prevent the parameter of the
#   mixed group to be filled by a subsequent argument (mark as unavailable)
#
# 0.3.0 Functionality Added: (most recent first)
# - Add support to disable any help and to set short and/or long help
# - Add new config option to disable dual letter combining feature (-cm)
# - Add support for dual letter options to be combined, e.g.: -int => -in -it
# - Add new config option to disable single letter combining feature (-co)
# - Add support for single letter options to be combined, e.g.: -via =>
#   -v -i -a (not allowed if any single dash multi-letter option: -in)
# - Add support for intermixed optional positional parameters, e.g.:
#   func {-g} {option1} <param_1> {option2} <param_2>
#   Note: requires counting number of parms & getting required first
# - Add support for endless parameters: parm ... AND -i=parm,...
#   Made naming for both is as follows: parm parm_1 parm_2 ...
#   [This can be used to support but with different names: {src {dst}}]
#   The defined context of 'parm' will apply to all subsequent parm_...
#   Verified for beginning and trailing parms and for indirect parms.
#   Endless parms provides support for different no. of parms, albeit
#   with the same names (parm, parm1, parm2, parm3, parm4). Normally
#   this should be done with indirect parms as modes. Example:
#   1)  printif -s str
#   2   printif -t ena str              # ena: -d|on*|y*|non0
#   3)  printif -w bgn str end
#   4+) printif -x val cmp pre str {post}
#   But now it can be done directly without option modes:
#   1)  printif str
#   2   printif ena str                 # ena: -d|on*|y*|non0
#   3)  printif bgn str end
#   4+) printif val cmp pre str {post}
#
# 0.2.0 Functionality Added: (most recent first)
# - Combine Optional & Required Options into 1 list to maintain order
# - Add grouping support <>,{},[],() for multiple items, where the
#   corresponding state (required|optional) will be applied to all
#   grouped items; e.g.: (-i -j=parm1 parm2) OR <-i -j=parm1 parm2]
#   This can be combined with the 'more' indicator:  <file ...>;
#   Note the difference between an indirect parm: <-f=file ...>
# - Default for no delimiter means required: -i AND -m=n AND name
#   but make it user configurable in case it's not user's preference
# - Ensure set default value expands: var?$PWD; but can be disabled
#   with an escape character: var?\$PWD [this preserves $PWD use]
# - Add support to verify same positional parm name not used > 1x.
#   [NB: not checking for indirect parm names, as they can be the
#   same since they  have different options; e.g.: -i=file -j=file]
# - Add support to verify same option is not used more than once.
#   [NB: comparison uses option only and not any alternate name.]
#
# 0.1.0 Functionality Added: (most recent first)
# - Add extended help option [-help|--h*] option and help on debug
# - Locate required non-option parms by their positional order: 1st, 2nd,
#   ... & that it doesn't match a dashed option; allows -* to be captured
# - Add a quiet mode where the error messages are not outputted
# - Add functionality of optional beginning positional parameters
# - Add Analyze only mode [-a] (only parse HELP string) and timing
# - Add extended help options to display all values for all enums
# - Add '|' support: allow options & 1 named parameter, e.g.: {-n|-p|n}
#   Add linking to verify OR'ed items only received one of OR'ed items.
#   Allow OR ('|') to work for required options also.
# - Allow indirect options to be part of an OR'ed group by creating a
#   multiple indirect group (mind): {-f|-files infile outfile tmpfile}
#
# 0.0.0 Functionality Added: (most recent first)
# - Allow old style equals format for options, e.g.: -o=out OR -o out
# - Allow multiple parms for option, e.g.: -in file1 file2  [use links
#   to keep them together and to 'hide' them from the optimized lists]
#   NB: even if option optional, once found numparms will be required
#   08 opt[3]: ifile  "-f|--file" 08|[min][ind][01/08] help="in file"
#   09 req[1]: tfile  ""          08|[min][ind][02/09] help="tmp file"
#   10 req[1]: ofile  ""          08|[min][ind][03/10] help="out file"
# - Purposely keep going if possible when an error occurs in order to
#   still output received command line options that are useful to know
# - Add errors to an error array and print out after all analysis done
# - Add alternate naming (:altname) for parameter-less arguments
# - Support long options --longopt & have its name be __longopt
#
# OPTIMIZATIONS
# - Moved version string in sample files to top of file instead of file bottom
#   so grep could be optimized to quit after finding the first version string
# - Removed timing code & moved DisplaySamples code to getparmstest.sh (1.0.2)
# - Save longer help files and use existing file if more recent than getparms
# - Replaced DataXact & DataSubt with DataRegx (was: DataFind) & with DataPost
# - Change all calls to DbgSetOn to DBG_ENA & DbgTrace to DBG_TRC and define
#   DBG_TRC() as empty stub & what was DbgTrace() to __DBG_TRC(); on 1st call
#   to DBG_ENA 'unstub' DBG_TRC to __DBG_TRC(). This reduces all tests in -a
#   run of getparmstest.sh -a from 442 to 400 ms/test, a 9.5% reduction/test.
# - Removed all 'space' support in the specification (previously in defaults &
#   ranges) to simplify and thus speed up processing of the specification
# - Removed parm default value support (for both positional & independent parms)
#   as this is better (and more easily) done by the user and it saves many
#   processing difficulties like spaces in the middle of an item
# - optimize string splitting, extract text, entirely rid of nthitem
# - eliminated as many as possible calls to safeval: GetEndNdx return cnt,
#   removed firstlast, haschar, & dequote calls and made inline
# - eliminated calls to eval and used global var instead: GetName, OptName,
#   GetDataStr, nthitem, later eliminated GetName altogether
# - move as many post-processing for loops & do in initial loop if can
# - optimize positional parm processing: don't reset indices but keep last
#   value since they're always in order; updated each time a parm is found
# - replace getword & nextitem with cmdline word processing based on spaces
#   by eliminating all parsed items with spaces except defaults with quotes
# - split all OR'ed options into separate items with linking; this has made
#   command-line checking of parameters faster (by removing while '|' loops)
# - optimize command line parsing by making specified item arrays with only
#   the following characteristics and then search them in the same order
#   1. srch == "" => NdxBgnReq array of begining parms.
#   2. srch != "" => NdxOption array of optional options
#   3. srch == "" => NdxEndPrm array of trailing parms.
# - check for unused functions and delete or move to unused
# - sped up most commonly used functions (e.g. nthitem)
#
# Authors:
# Charles von Hammerstein
#
# The following code portions were adapted from other authors:
# - Unstub  : GitHub Gist by jimeh/stub.bash (Dec 9, 2019), Copyright (c) 2014 Jim Myhrberg (MIT license)
# - ChgCase : Dejay Clayton, StackOverview, July 28, 2018, 23:45
#   https://stackoverflow.com/questions/2264428/how-to-convert-a-string-to-lower-case-in-bash
#_HIST_END # Document page delimiters; o/p end: getparms --hist
#############################################################################

#############################################################################
# Possible Future Support and/or Optimizations:
# - Add back the support for multiple OSIP with commas, i.e.: -f=parm1,parm2
# - Add support for an initialization file (getparms.ini) that contains all
#   default values to be read in at startup. This tailors the default settings
#   for getparms to be what the user typically uses. These can be overwritten
#   by command-line options. Allow -c to remove and regenerate the init file.
#   Allow init files to be specified per caller function: getparms.caller.ini
# - Optimize CleanupCL by combining CollapseArgs with loop in same function
# - Optimize GetIndPrm & GetMixed by combining, so we only loop through once
# ---------------------------------------------------------------------------
# Functionality Purposely Rejected (or alternately implemented)
# - In order to reduce the complexity and increase the speed of getparms, the
#   handling of default values was removed; it is better and more flexible for
#   the caller of getparms to handle the setting of default values themselves;
#   this can be done either before calling getparms or if desired based on
#   seeing the result of what items were received from the command-line; this
#   way getparms does not have to handle the time-intensive cases involving
#   defaults with spaces or with special values that getparms uses for parsing;
#   this way getparms can avoid having to check for many escaped symbols
# - Support for -ovalue where value can be a string (i.e. ind parm -o with no
#   space between the value): problem is no way in specification to distinguish
#   from a pure option (-ovalue) & so no way to set datatype or default value;
#   in run-time it is a can of worms because the value could be anything, like
#   letters, so now it may be -out (which might be another option altogether)
# - Extend SHIP to support number (not hex) datatypes: this was rejected due
#   to overcomplicating SHIP items that are meant to be a simple convenience
#   item that supports number inputs only and it already supports alt names
# - Allow spaces in enums: rejected as it further complicates & slows down
#   getparms, requiring a special delimiter to mark the end of an enum list
#   since we can't count on bash quotes being preserved
# - Have version of getparms that doesn't have debugging, only include debug
#   header file (debug.sh) if -d* detected and file available : using Unstub
# - Add functionality so -a-||-a+ means > 1 can be received : instead use
#   -cd : disable errors on duplicates of same: opt, ind parm, SHIP received
# - Changing default '~' to be string (s, not '%') for ease of doing strings:
#   doesn't help because most of string subtypes would now not be allowed in
#   the default case as they would collide with other options, namely -
#   b, d, e, f, i, h, n, p, u, v and certain combos involving 'g' (ipg), 'r'
#   or 'w' (prw, pr, pw, drw, dr, dw, frw, fr, fw) & 'x' (fx, frx, fwx)
#############################################################################

#############################################################################
# Design Notes
# External Functions:
# Optional external utilities used: cdebug
# [If these are not found, they are automatically stubbed.]
#
# Required external utilities are all standard part of O/S:
#  - needed for comparing decimals: bc
#  - needed for extended help page: less
#  - needed for formatting outputs: grep, sort, sed
#  - needed for the line indenting: expand, fold, tput
#
# Specification Parsing is divided into these tasks:
# -  1st  aggregating any quoted items with spaces
#         so we have a whole item before processing
# -  2nd  tracking items found in a delimiter set
#         (1) determines whether required|optional
#         (2) means for defining normal ind. parms
# -  3rd  loop through the OR'ed items 1 at a time
#         (1) establishes linking for OR'ed items
#         (2) makes way to define normal indparms
# -  4th  split on any non-escaped '=' character
#         (1) establishes whether a SHIP or OSIP
#         (2) separates out option from ind parm
# -  5th  get the item's type: --, opt, SHIP, parm
# -  6th  check if item has unescaped modifiers:
#         (1) a datatype & strip off datatype
#         (2) an alt. name & separate out name
# -  7th  get names for item: alt., opt, & parm
# -  8th  process optional end opts marker: '--'
# -  9th  save characteristics of the spec item
# - 10th  checks to continue & advance to next item
#
# Command line Parsing is divided into these tasks:
# -  1st  loop over all given command-line inputs
# -  2nd  aggregate any quoted items with spaces
# -  3rd  pre-handle end of options markers (--)
# -  4th  see if item collides with help options
# -  5th  check for leading positional parameters
# -  6th  check if not past end of options marker
#         and grab option only part (before '=')
# -  7th  first check if option matches directly
# -  8th  check if this is combination of options
# -  9th  check if a Short-Hand Ind Parm(e.g. -d=)
#         or an old-style ind. parameter (-i=val)
# - 10th  save found option & get number of parms
# - 11th  advance to get next indparm when needed
#         (skipping over multiple OR'ed options)
# - 12th  check if parm val matches the data type
# - 13th  store data and update the found counts
#         check if not past end of options marker
# - 14th  check if option not found & record error
# - 15th  check for any trailing positional parms
# - 16th  handle errors if any item was not found
#
# Notes on item types and related associated flags
#-------------------------------+-------------------
# lnk mor mnd org mix type item | whole
#-------------------------------|-------------------
# -1   0   0   0   0  pure -o   | -o
# -1   0   0   0   0  parm prm  | prm
#  n   1   0   0   0  parm mor  | mor ...
#-------------------------------|-------------------
#  n   0   1   0   0  pure -i   | -i=ind
#  n   0   1   0   0  parm ind  | -i=ind
#-------------------------------|-------------------
#  n   1   1   0   0  parm mor  | -i=mor ...
#-------------------------------|-------------------
#  n   0   0   1   0  pure -o   | -o|--on
#  n   0   0   1   0  pure --on | -o|--on
#-------------------------------|-------------------
#  n   0   1   1   0  pure -i   | -i|--in=ind
#  n   0   1   1   0  pure --in | -i|--in=ind
#  n   0   1   1   0  parm ind  | -i|--in=ind
#-------------------------------|-------------------
#  n   0   0   1   1  parm m    | m|-o|--on
#  n   0   0   1   1  pure -o   | m|-o|--on
#  n   0   0   1   1  pure --on | m|-o|--on
#-------------------------------|-------------------
#  n   0   0   1   0  pure -o   |   -o|--on|-i=ind
#  n   0   0   1   0  pure --on |   -o|--on|-i=ind
#  n   0   1   1   0  pure -i   |   -o|--on|-i=ind
#  n   0   1   1   0  parm ind  |   -o|--on|-i=ind
#-------------------------------|-------------------
#  n   0   0   1   1  parm m    | m|-o|--on|-i=ind
#  n   0   0   1   1  pure -o   | m|-o|--on|-i=ind
#  n   0   0   1   1  pure --on | m|-o|--on|-i=ind
#  n   0   1   1   1  pure -i   | m|-o|--on|-i=ind
#  n   0   1   1   1  parm ind  | m|-o|--on|-i=ind
#############################################################################
