## Windows Batch File Template

The following code is the template I have started using for new Windows batch files[#]:-

```
@echo off      ```
rem ****************************************       
rem Script template       
rem ****************************************

```
:help_requested      ```
if /I "%1" == "-?" call :usage & exit /b 0       
if /I "%1" == "--help" call :usage & exit /b 0

```
:validate_args      ```
if "%1" == "" call :missing_arg & exit /b 1

```
:body      ```
echo SUCCESS...

```
:success      ```
exit /b 0

```
:missing_arg      ```
 echo ERROR: One or more arguments are missing       
 echo.       
 call :usage       
goto :eof

```
:usage      ```
 echo USAGE: %~n0 [option ^\| options...]       
 echo.       
 echo e.g. %~n0       
 echo.       
goto :eof

Once again plenty of credit must go to Raymond Chen as his blog has shown some pretty neat little tricks that has challenged my opinions on how little I thought you could do with them. Also there is a fantastic web site run by [Rob van der Woude](http://www.robvanderwoude.com) that tells you everything you could ever want to know about batch file programming, and more. Although I’ve written MakeFiles in the dim and distant past, virtually all the build and deployment scripts I’ve written more recently have been as batch files as I prefer the imperative style of this “language” to the more functional nature of makefiles; plus I’ve never really needed that amount of power as Visual Studio does most of the heavy lifting. Anyway, here are a few notes about the script that might be useful…

<u>Labels Instead of REMarks</u>

The REM statement is the built in tool for writing comments, but personally I have found that you can also use a label for much the same purpose without the extra noise from the ‘rem’ prefix. OK, so you can’t have spaces in the label (you have to use underscores) but as a long time C/C++ programmer I’m used to this style. The other reason for using them this way is that once I start adding functionality I naturally find myself needing to use flow control anyway and the labels are already there.

<u>Specifying an Exit Code</u>

The EXIT statement, with the /B switch, can be used to specify an exit code. This switch is essential if you want to invoke one batch file from another, such as in a build or deployment process; without it you will exit the command interpreter - even if you’ve been invoked via the CALL statement. By default I tend to just use a single error code “1” unless I’m going to perform some custom error recovery in a calling script.

<u>Chaining Statements</u>

To aid readability (usually in error handling) I sometimes find it more succinct to chain a CALL and EXIT statement on one line rather than on separate lines, e.g.

`if "%1" == "" call :missing_arg `\```
**& exit /b 1        ```
**if "%2" == "" call :missing_arg ```
**& exit /b 1        ```
**if "%3" == "" call :missing_arg **& exit /b 1**

The use of a single “&” means the EXIT will be invoked unconditionally. There are other forms such as “&&” and “\|\|” which allow you to execute subsequent statements based on the result of the previous one, i.e. they’re the moral equivalent of “IF [NOT] ERRORLEVEL 1”.

<u>Path Handling</u>

You can parse paths stored in arguments and variables easily with the “%~” syntax. The one I’ve used in the template above “~n” gives you just the script filename (variable %0 is the full path of the script ala argv[0] in C). For some strange reason you need to look up the help for the FOR statement to find the full details of the path handling syntax[*].

<u>Invoking Functions</u>

One of the most useful features I’ve only recently come to appreciate is the ability to invoke “functions” within the same script. These are defined by a label and effectively return through use of the “GOTO :EOF” statement. You can also pass arguments to the function which appear as variables %1 - %9 just like when script itself is invoked. To make the appearance of scripts with functions a little more readable I tend to indent the code between the label and return.

<u>Escaping The Pipe & Redirection Characters</u>

A common format for usage strings is to use the pipe character “\|” when listing alternate options and the greater-than/less-than “<>” characters to enclose argument names. Naturally these have another meaning to the command interpreter, so you have to escape them with the hat “^” symbol.

<u>Testing Batch Files Prior to Automation</u>

One thing you need to test before invoking your script under automation tools like Task Scheduler or TeamCity is the return codes. If you forget the /b argument to the exit statement, or you get your flow control wrong and just drop through somewhere, you can easily end up returning the default value of 0 which will be treated as successful and your Continuous Integration process will be lying to you. The following two line script (RunScript.cmd) can be used to invoke another script and display its exit code:-

```
call %*      ```
echo ExitCode=[%ERRORLEVEL%]

```
C:\>RunScript.cmd MyScript.cmd arg1 arg2      ```
. . .       
ExitCode=[0]

If you don’t see the exit code then you’ve probably invoked EXIT without the /B switch somewhere.

<u>Command Extensions</u>

Although this template uses some command extensions that were added to more “recent” versions of Windows (i.e. 2000+) they are all enabled out-of-the-box and so you don’t need to do anything special to start using them. In fact Delayed Expansion of variables is the only extension I’ve used so far that has required some explicit action – SETLOCAL ENABLEDELAYEDEXPANSION.



[#] All the build scripts that I currently have in my personal codebase are ancient and were thrown together long before I really had a clue about what you could do inside a batch file, so don’t go looking there for concrete examples… yet.

[*] `C:\> HELP FOR`\


---
Original: <https://chrisoldwood.blogspot.com/2010/06/windows-batch-file-template.html>\
Copyright: Chris Oldwood 2010\
Published: Monday, 28 June 2010 at 18:29\
Labels: build
