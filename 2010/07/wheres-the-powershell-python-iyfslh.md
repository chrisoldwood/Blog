## Where’s the PowerShell/Python/IYFSLH*?

An obvious question to many might be “why are you still writing batch files when PowerShell superseded it years ago?”. Even VBScript is way more powerful than cmd.exe and then there’s everyone’s pretender to the sysadmin throne – Python (and by extension [IronPython](http://en.wikipedia.org/wiki/IronPython) in the Windows world).

<u>Not Corporate Policy, Again</u>

I’ve been following PowerShell since it was called [Monad](http://blogs.msdn.com/b/monad/), and IronPython too during its pre [DLR](http://en.wikipedia.org/wiki/Dynamic_Language_Runtime) days (especially after a pretty cool demo by Michael Foord at the [ACCU Conference in 2008](http://accu.org/index.php/conferences/accu_conference_2008/accu2008_sessions#IronPython: Dynamic Languages on .NET)). Once again the problem in the corporate world is that Application Servers are often very tightly controlled and organisations generally don’t like teams jumping on every bandwagon when it has the potential to create conflicts and therefore downtime; I’m sure it was [Raymond Chen](http://blogs.msdn.com/b/oldnewthing/)[#] that said “If the solution starts with ‘First Install X’; then now you have two problems”. PowerShell, Python, Ruby, PERL etc. all involve installing runtimes and libraries which may themselves rely on other shared 3rd party components – DLL Hell is still a problem today. Given that many large organisations only recently (i.e. the last couple of years) migrated to XP on the desktop and Windows Server 2003 for their servers you can see why the uptake of PowerShell has been slow – it’s just not been readily available in this environment; plus there’s a mountain of legacy COM and VBScript which still does the job perfectly well.

<u>Drive-By Programming</u>

As a freelance developer I also feel I have the need to act responsibility which means I can’t go off writing code in whatever takes my fancy and then leave my client with a load of stuff they can’t support; of course some see this kind of behaviour as job security… For me to see a technology as worthy of production use means that there must be a critical mass of people (ideally within the team) who can support it. I’ve worked in a medium sized team where we prayed the two production PERL scripts didn’t fail because no one really knew what they did. I’ve also seen an intern write some production code during his 6 month rotation in PowerShell when there was little to no knowledge of it within the team. I raised the obvious question about who would be able to support it when his rotation ended which prompted the usual discussion about code reviews. It also prompted a deeper one about whether we should try and standardise on one ‘glue’ language going forward and where (in the development process) it would be useful to introduce it to allow time to gain the necessary skills for its eventual promotion to production status. One alternative is for the management to be made aware of the impending cost and stump up the training to acquire the critical mass; but training often seems to be the first to go when money gets tight.

Ok, that sounds overly dramatic I know because anyone can perform simple maintenance, such as replacing database connection strings, file-system paths, server names etc. But there is a very real problem there if something more serious goes wrong as it’s highly likely that there won’t be any tests in place to guide any significant development. You also have to factor in that full-time experienced developers often write this kind of code initially but as the team grows and a separate support team comes on board it is _them_ that are faced with picking up this maintenance burden.

<u>The Right Tool For the Job</u>

We discussed right back at the start of my current project what we wanted to pick as our ‘auxiliary’ languages to make sure that we all had the same hymn sheet. The server and client side coding was largely to be done in C#, but we were also going to need a language to act as the ‘glue’ to bind all the disparate Batch Processing tools together; plus we thought we might need another language to aid in development & testing. One again PowerShell and Python seemed to be at the top of the list. But whereas on a previous project it was Python’s interop with COM and C++ that made it look attractive, it was PowerShell’s interop with .Net (due to the C# bias) that made it favourable this time and it was also part of the standard app server and desktop build now so we had no deployment concerns. Somewhat interestingly a few months later the department did a fact-finding mission to see how many people had Python skills as it seems that they wanted to promote the Python/IronPython approach to the development teams instead. I’m looking forward to seeing how this initiative pans out as we’ve only just started on this area of our system so we have very little to throw away.

<u>Proving a Point</u>

I fired up a command prompt on this [9 month old netbook](http://chrisoldwood.blogspot.com/2009/11/my-new-blogging-machine.html) which is fully patched to XP SP3 to knock up some PowerShell equivalents to the cmd shell examples I gave last time and what do you know… PowerShell isn’t installed!



[*] IYFSLH = Insert Your Favourite Scripting Language Here

[#] I’m sure it was him, but my Google Fu is unable to locate this quote.


---
Original: <https://chrisoldwood.blogspot.com/2010/07/wheres-powershellpythoniyfslh.html>\
Copyright: Chris Oldwood 2010\
Published: Tuesday, 27 July 2010 at 07:52\
Labels: .net, tools
