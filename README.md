# getparms
getparms is a generalized, configurable Bash command-line parsing utility
with an extensive list of capabilities that outputs results to the caller
in a printed-array format. It is highly configurable, both in its display
output & in command-line processing. It is speed-optimized (as far as Bash
scripts can be). It handles pure options, positional parms, indirect parms
(new & old forms) with support for short and/or long options, & a new type:
short-hand indirect parms. It handles beginning parms that come before any
options, and adds a new end of begin parms marker (-+) where options begin
as well as supporting the standard end of options (--) where options cease.
It thoroughly checks for specification errors & command-line errors, giving
individualized error messages per type that show the incorrect item & what
position it occurred. Where an error causes cascading errors, the secondary
errors are filtered out. Where any specification error does not prevent cmd-
line processing it is downgraded to a warning and processing continues.

It also supports datatype checking, value and range checking, limiting the
received values to a set of enumerated values, alternate naming of options,
and also endless parameters (when the number of parameters is variable).
It supports item grouping where only 1 of the items can validly be received.
It supports full & partial string matching with or without Bash ERE regex.
[All features have been thoroughly tested via the script: getparmstest.sh]
It runs on Linux in Bash and supports Apple's Darwin GNU bash 3.2.57(1).
All this is with a simple help style syntax in the form of a HELP string
(or an exported variable which contains the help string). The latter is
useful for not cluttering the command-line. The help string lists all the
expected inputs. The help string forms the specification, which defines:

     (1)  the name & the ordering of all items;
     (2)  how many parameters that an item has;
     (3)  if an item is required | is optional;
     (4)  if an item is part of an OR'ed group;
     (5)  if it is a positional parm, indirect parm, option

Why another bash argument|command-line parser? Aren't there enough already?
What do we still need that the other bash command-line parsers aren't doing?

First, we need an argument|command-line parser because doing the same thing
over and over again is tedious and error prone. We should do it once and do
it right, so we can depend on it every time to do the mundane functions.
That's the purpose of scripts in the first place: doing repetitive tasks.
Such a functionality should be a built-in utility as part of this|any shell.

Second, most scripts are not written robust enough, because insufficient
time and effort has been put into the argument parsing, just because it is
tedious and often not 'worth the effort' from the script writer's point of
view. This puts all the future users of the script in jeopardy, because
not all the cases have been considered and designed in. The use of a well-
tested command-line parser eliminates the undependability of user scripts.

Third, some argument parsing tasks are often hard to get right, so that
they are flexible enough to handle all the normal use cases. Handling all
the different ways a script can be run can be exhausting and it is easy to
miss some. By handling this in a well-tested argument parser, we know that
all the cases are already covered and we can concentrate on our own script.

Fourth, because user scripts are written typically just to get the job
done, they are not extensible. Every time a change is made to the script
by adding or changing the command line arguments, we risk breaking the
whole script. By defining a clear specification for arguments, we can
avoid this and make the changing of command line arguments a simple task.

So what kind of tasks should a complete argument parser be able to do?
Consider the extensive list of features that are supported by getparms:

A. Basic Capabilities & Error Checking
- support intermixing options with positional parms
- support for optional and required positional parms
- support whitespace in any run-time parameter values
- support pure options (for any order): -c -o | -o -c
- support indirect options (any order): -i indp -o out
- support short and long option naming: -a & --auto-par
- ensure multiple options with same name aren't received
- ensure multiple OR'ed opts aren't rcvd: -a & --auto-par
- handle end of options marker (--) to end options parsing
- ensure gather all required parms, then get optional parms
- a well-defined, simple syntax for specifying cmd-line args
- default help opts for the caller's help utility (-h|--help)
  & ability to change them to other options or even disable it
B. Robustness & Configurability
- extensive error checking for non-conforming arg conditions
- support for old-style indirect parameters (e.g.: -o=outfile)
- support for suppression of error messages (i.e. a quiet mode)
- support the ability to tailor the output returned to the caller
- thorough checking of command-line argument specification ensures
  that what the user has specified actually makes sense in practice
- distinguish between fatal & non-fatal specification errors, which
  allows program to go on & process command line items where possible
- the ability for the user to pre-test just the specification in order
  to ensure the specification is valid & supportable [the Analyze mode]
- support for disabling of capabilities which are not needed or are not
  desired (e.g.: disable support for combining of single letter options)
- support for changing whether the delimiters imply required or optional
- ensure all argument names are unique, even between parameters & options

C. Advanced User Capabilities
- support for changing parsing symbols to match one's own needs
- support indirect options with multiple parms: {-o in out temp}
- support Short-Hand Indirect Parms (no equals): -n# (# an integer)
- support combining of pure options (in any order) for single letter
  options (-i -o => -io|-oi) and dual letter options (-in -io => -ino)
- support linking OR'ed options, so only one received (e.g.: -v|--verb)
- support for multiple consecutive parameters when the number of parms
  is unknown beforehand, only at runtime (e.g.: num ... or -f file ...)
  with auto-naming of 'consecutive' arguments (e.g.: num_1, num_2, ...)
- support for alternate output naming for any option so that it doesn't
  need to be constrained by its option string search (e.g.: -o:output)
- support the grouping of arguments with the same requirement condition;
  following usage makes both parm1 and parm2 be optional: [parm1 parm2]
- allow mixing options & a positional parm so 1 or the other is received
  (e.g.: -i|--out|num); -i or --out or parm 'num' is allowed (but only 1)
- support parm type-checking: is it a string, an int, a number, or an int
  |string preceded|annexed by specific text (e.g.: $, %, 'From:', '.txt')
- support for parameter enumerations and parameter range checking where
  the range checking is numerical for integers and lexical for strings
- support Extended Regex Expressions for string matching of parameters
- specialized data checking: validate IP|MAC|email address formatting,
  positive|negative numbers|integers only, hex number checking (with|
  without 0x or x prefixes), binary number checking, string checking
  all caps|small with|without spaces with|without symbols, checking if
  an input has a valid path or is a valid file or is readable|writable
- support beginning parms which occur before any options are allowed
- captures all specification or command-line errors before quitting,
  so that all errors are known (and not just the first one caught)
- optional printing of spec parsing (based on configuration option)
  allows the script designer as well as the script user to see how
  the specification as well as the command-line inputs were parsed
- handles hex input: converts all declared hex integers to decimal
  & auto-converts any integer that begins with 0x|x|x to decimals
  - when multiple indirect parms | Short-Hand Indirect Parms received
  for the same option, all values are stored in the output variable
  separated by equals so the caller can know all the values received
- support multi-line help string output via embedded carriage returns
- extensive debugging feature allows user to see what getparms is doing

D. Limitations
- in order to reduce the complexity and increase the speed of getparms,
  no specification values (e.g. enums & range checking values) can have
  any whitespaces; Note: this does not affect the values received from
  the command-line input, which may freely have whitespaces in them
