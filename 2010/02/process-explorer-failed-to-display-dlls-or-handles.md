## Process Explorer Failed to Display DLLs or Handles

If this was [Mark Russinovich](http://blogs.technet.com/markrussinovich/) he would probably have titled this post “The Curious Case of Process Explorer…”, but I’m not him and it’s not nearly as interesting or challenging as the kinds of issues he blogs about…

The other day I was investigating an issue where our new C# based grid service was failing to run on any engines because of what appeared to be an issue with assembly paths. As a n00b to .Net and having done a little reading into AppDomains and how assembly paths and native paths are used I thought I’d have a look at the grid engine surrogate process with [Process Explorer](http://technet.microsoft.com/en-us/sysinternals/bb896653.aspx) to inspect its Environment Block and also what DLLs it already has loaded. This was on a 64-bit server running Windows Server 2003. After firing up Process Explorer I duly opened the lower pain and switched it to DLL mode only to be presented with an empty list. I humoured myself by checking the sizes of the columns and switching to Handle mode, but the pane was definitely empty. I even clicked on a few other processes like the svchosts’s, but the result was the always the same - nought.

Then, purely by accident, I clicked on explorer.exe and it worked. Realising that this was one of the processes running in my Windows session I added the “Username” column to the top pane and sure enough the only processes I could inspect where my own. Most of the machines I’ve dealt with in the past have been 32-bit boxes except for a few Big Iron 64-bit application servers. Not sure If I’d run into a limitation of Process Explorer on 64-bit Windows, I decided to go old school and run the command-line based Handle tool instead. This time I got a more interesting result:-

`Error loading driver: Access is denied`\



I thought they had granted me admin rights on the box, so again I thought I’d humour myself and check by running:-

`C:\> NET LOCALGROUP Administrators`\

Sure enough I was an administrator. Time to hit the Search Engines…

I didn’t find anything that exactly matched my issue with Process Explorer (PE), but there were some posts about the Handle error message. [One post](http://forum.sysinternals.com/printer_friendly_posts.asp?TID=9237) said to check whether you have the SeLoadDriverPrivilege granted in any process. I checked PE itself, and no I didn’t have this in my token. [The post](http://forum.sysinternals.com/printer_friendly_posts.asp?TID=9237) then went on to describe how you can check if you should have this privilege by using secpol. I did and the Administrators group is indeed granted this right.

Casting my search wider I started searching for info on SeLoadDriverPrivilege in the hope that I might discover where this has affected other similar low-level diagnostic tools. What I found was lots of discussion about rootkits and other malware. Given the environment I was working in I found this scenario extremely unlikely, but at the same time I could imagine how the security software that was running on the server could also be using similar techniques exactly to stop this kind of infection.

Fortunately along the way I came across [another post](http://forum.sysinternals.com/forum_posts.asp?TID=13702&OB=DESC) that mentioned running Process Explorer under the SYSTEM account – the post was actually about Vista and UAC, but the idea seemed worth a go. To do this you can use another Sysinternals tool “psexec” with the “–s” and “–i” switches. I must confess that in all the years I’ve been using psexec I’ve never once needed to use these switches. As the command-line help will tell you, –s runs the process under the SYSTEM account and –i allows it to interact with the desktop. You also need to remember to fully qualify the path to the child process you’re invoking if it’s not going to be on the SYSTEM account PATH, e.g.

`C:\>C:\Tools\psexec –s –i C:\Tools\procexp.exe`\

Lo and behold it did the trick, I could see everything again in Process Explorer. Naturally I’d like to know if the whole SeLoadDriverPrivilege thing was a red herring or not, and if it isn’t, get some closure on why the privilege is missing in the first place – now that’s the kind of job Mark Russinovich would tackle…


---
Original: <https://chrisoldwood.blogspot.com/2010/02/process-explorer-failed-to-display-dlls.html>\
Copyright: Chris Oldwood 2010\
Published: Sunday, 21 February 2010 at 20:05\
Labels: 64-bit windows, tools
