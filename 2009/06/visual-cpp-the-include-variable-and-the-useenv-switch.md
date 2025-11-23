# Visual C++, the INCLUDE variable and the /USEENV switch

Back on my last contract I ported the codebase from VS2003 (VC++ 7.1) to VS2005 (VC++ 8.0). The port was pretty easy, but is wasn't until we started developing with VS2005 that we ran into a really nasty issue.

The system used STLport instead of the bundled STL for a number of reasons, and if you've used STLport with Visual C++ you'll possibly use a .cmd script, along with the devenv /useenv command line switch as a way of injecting the STLport paths into the #include chain before the standard MS ones. Here is an example of how that script built the include path and launched VC++,

`. . . `\
`set VCInstallDir=%VS80COMNTOOLS%..\..`\
`set STLPORT=%DEV%\3rdParty\STLport-4.6.2`\
`set BOOST=%DEV%\3rdParty\boost.1.33.0`\
`. . .`\
`set INCLUDE=^`\
`%STLPORT%\stlport;^`\
`%VCInstallDir%\VC7\include;^`\
`%VCInstallDir%\VC7\atlmfc\include;^`\
`%VCInstallDir%\VC7\PlatformSDK\include;^`\
`%DEV%\OurCode\Lib;^`\
`%BOOST%;^`\
`. . .`\
`start devenv.exe /useenv OurSolution.sln`\

Notice that the codebase also used the INCLUDE variable as the mechanism for finding _it's own_ library code - the line "%DEV%\OurCode\Lib". These libraries were not 'static' in nature they were developed at the same time as the main code and so any library change was expected to cause the relevant dependencies to build immediately.

When I started using VS2005 for actual development I began to run into strange problems, which would manifest as bad builds - virtual functions calling the wrong code, memory corruption etc. Previous experience taught me to disable the "Minimal Rebuild" option and delete the .idb file, but they didn't seem to have any effect. Once my teammates joined me it became a real issue as we were wasting a considerable amount of time. We even talked about dropping VS2005 and going back to VS2003 until we could get our hands on VS2008.

Fortunately one of my colleagues, Sergey Buslov, was not going to be beaten so easily and after an exhaustive search came across a new setting in VS2005, called "External Dependencies". This resides in the same location as the other VC++ paths - "Tools ! Options" under the "Projects & Solutions ! VC++ Directories" section. This is where you normally configure the default Executable, Include, Lib etc paths. The "External Dependencies" list was exactly the same as the INCLUDE environment variable, and lo and behold if you cleared the list, all the dependency issues went away. The documentation only has this to say on the setting,

**Exclude Directories
**_Directory settings displayed in the window are the directories that Visual Studio will skip when searching for scan dependencies.
_
I haven't seen any clarification yet, but I suspect that the Visual Studio team assume that you'll only put paths to 3rd party libraries in your INCLUDE variable. In my own work I have always had a single IncludeDependency that points to the root of my libraries source tree which is specified in every project so I didn't see this at home.

The real kicker though is that there is no obvious way of stopping Visual C++ from configuring the "External Dependencies" from the INCLUDE variable when using the /useenv command line switch! There is no EXTERNAL_DEPENDENCIES variable that I know of that would allow you to configure it appropriately (it does seem a very useful optimisation). In the end the hack Sergey came up with is really ugly :-) He found that if you modified the default paths, VS wouldn't interfere and inject the INCLUDE paths into it. So here are the instructions,

- Open Visual C++ from the standard icon, NOT by invoking it with devenv /useenv or your script.
- Open the "Tools ! Options" dialog and find the "External Dependencies" list.
- Modify them by adding another dummy entry at the end. We just stuck the string "(null)" in there for want of something better.
- Close Visual C++ and re-open it with your script and check that the "External Dependencies" list has not been hijacked.

At the time we hit this (06/2008) there was only one post I could find that seemed similar to our problem,

[http://social.msdn.microsoft.com/forums/en-US/vcgeneral/thread/c447c0bd-bcdb-4e52-a8af-b1341ce3ad9f](http://social.msdn.microsoft.com/forums/en-US/vcgeneral/thread/c447c0bd-bcdb-4e52-a8af-b1341ce3ad9f)

I notice that it's also referenced in the following Microsoft Connect query, but closed as 'unreproducible',

[http://connect.microsoft.com/VisualStudio/feedback/ViewFeedback.aspx?FeedbackID=274454](http://connect.microsoft.com/VisualStudio/feedback/ViewFeedback.aspx?FeedbackID=274454)

I'll see if I can open a new issue and maybe more information about this will come to light.

---
Published: Friday, 19 June 2009 at 11:03\
Labels: visual c++
