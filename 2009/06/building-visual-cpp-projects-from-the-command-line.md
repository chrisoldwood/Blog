# Building Visual C++ Projects From the Command Line

As a developer biased towards Windows applications I find that both as a professional and a hobbyist that Visual C++ is my day-to-day IDE. I still use VC++ 7.1 (aka VS2003) for my [personal work](http://www.cix.co.uk/~gort/win32.htm) as I ship source code as well as binaries and it's easier to upgrade projects and solutions to later editions of Visual C++ for compatability testing than to go backwards. With 6 class libraries (+ unit tests) and 12 applications to build, manually launching the solutions and interacting with the GUI is just tedious and obviously error prone. But a common question on the forums is whether it is possible to build projects using Visual C++ from the command line - sometimes I wonder if people take the "Visual" in Visual C++ too literally :-)

The starting point is firing up a command prompt and setting up the environment variables so that you can invoke Visual C++ to build a solution. Some editions of Visual C++ have a "Command Prompt" item listed in the External Tools - VS2008 does. If you look at the command for this you'll see that it runs a batch file called vcvars32.bat. But opening the IDE just to fire up a command prompt is madness. Fortunately MS added an environment variable from VC++ 7.0 to make life a little easier - VSxyCOMNTOOLS. This means you can open an arbitrary command prompt and run, say,

C:\> "%VS71COMNTOOLS%..\..\vc7\bin\vcvars32.bat"

Unfortunately the VC folder changed name with VC++ 8.0 to drop the version suffix, so it's,

C:\> "%VS80COMNTOOLS%..\..\vc\bin\vcvars32.bat"

And should you want to cross-compile 64-bit code on 32-bit windows, with VS2008 it's as easy as,

C:\> "%VS90COMNTOOLS%..\..\vc\bin\x86_amd64\vcvarsx86_amd64.bat"

That's still just a little too awkward for me to remember, so I have a .cmd file called SetVars.cmd that I use to setup the variables for whatever version of VC++ I'm testing with,

C:\> SetVars vc71

That covers setting up the enviroment variables. The next job is to invoke Visual C++ to build a solution. This can be done in one way under VC6.0-7.1 and two ways under VC8.0-9.0. The old way was to invoke DEVENV.com like this,

C:\> devenv /nologo /useenv "D:\Dev\my.sln" /build Debug

As of VS2005, you can now use the MSBUILD style tool called VCBUILD. Unfortunately this has a different command line format and cannot be used to build installer (.vdproj) projects. The equivalent command would be this,

C:\> vcbuild /nologo /useenv "D:\Dev\my.sln" "DebugWIN32"

Once again though I find this all a bit tedious and have wrapped this logic into another .cmd script called Build.cmd that just takes a solution filename. The choice of which tool to use, devenv or vcbuild, is based on the compiler that was configured by running the SetVars.cmd script.

C:\> Build "D:\Dev\my.sln"

The natural extension to this is building all my libraries, unit tests and applications from one command so I can see what I have broken. A straight FOR loop wrapped into another .cmd script called BuildAll.cmd helps reduce the clutter from this raw example, 

C:\> FOR /R %I IN (*.sln) DO devenv /nologo /useenv %I /build Debug

The final script I use is for upgrading the projects and solutions from VS2003 to VS2005, VS2008 etc before building. By default I keep VS2003 version files in my source repository and then run the upgrade script followed by the build script to check compilation on later versions of Visual C++,

C:\> FOR /R %I IN (*.vcproj) DO vcbuild /upgrade %I
C:\> FOR /R %I IN (*.sln) devenv /upgrade %I

The one fly-in-the-ointment is that the Express editions of Visual C++ don't allow you to upgrade solutions - only projects. At least not from the command line. However you can do it through the GUI, which means invoking the IDE for each solution and manually clicking the wizard buttons!

C:\> FOR /R %I IN (*.sln) devenv /upgrade %I

The scripts are available [on my website here](http://www.cix.co.uk/~gort/win32.htm#scripts).


---
Original: <https://chrisoldwood.blogspot.com/2009/05/building-visual-c-projects-from-command.html>\
Copyright: Chris Oldwood 2009\
Published: Thursday, 18 June 2009 at 16:01\
Labels: build, visual c++
