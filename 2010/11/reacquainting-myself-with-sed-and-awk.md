## Reacquainting Myself With Sed & Awk

I’ve always felt somewhat uncomfortable using Visual Studio as my main text editor because there seems to be legions of programmers out there that swear by vi and emacs’ text processing prowess. For me (a C++/C# Windows server-side programmer) I find that day-to-day all I need is syntax highlighting, cursor key movement and basic search & replace; plus the basic code navigation aid “Go to definition”. But that’s pretty much it. So I posed a question on [accu-general](http://accu.org/mailman/listinfo/accu-general) to find out if I’m some kind of programming Neanderthal or whether all these supposed fancy text processing aids are actually used _day-to-day_. My straw poll suggests not and so I don’t feel quite so pathetic now.

Still, I had one of those moments the other day when I needed to perform a really simple text processing task – I needed to add 6 tab characters to the end of every line in a large (10’s of MB) text file. This kind of thing (modifying[*] a file that large) is somewhat unusual for me. Instinctively I opened the file in my (already running) Visual Studio and tried to work out how I was going to do it. The two options I would normally use are Find & Replace and a macro (which I then run repeatedly by holding the ‘run macro’ key down :-). Given the size of the file I didn’t have all day for the macro to run so it had to be a replace using a regex. The one I came up with replaced the \n character with \t\t\t\t\t\t\n and then I waited for VS to do its thing…

Whilst waiting I thought to myself how much easier that probably would have been with Sed and/or Awk. I could even hear the sniggers of those Unix programmers around me. But I haven’t used either tool in 20 years and I don’t have a copy installed by default because I’m running Windows of course. I remember trying ports of the major Unix tools way back when I started programming professionally and it was painful because of the fundamental difference between who is responsible for handling wildcard expansion (the shell in Unix vs the program in DOS). Plus the memory constraints of DOS meant they weren’t altogether reliable[#]. Time has obviously marched on but I’m still jaded by the experience of the _very_ distant past and I’ve also discovered various alternatives that have made up the shortfall in many respects.

And then I ran into another classic issue – trying to work out which SQL scripts had been saved in ASCII and which in Unicode (SQL Server Management Studio [annoyingly uses Unicode by default](http://www.finalint.com/2006/11/14/sql-management-studio-how-not-to-save-in-unicode-format/)). This was causing my colleague’s (Cygwin[^] based) grep not to match various files. Once again I remembered the old Unix ‘file’ tool that attempts to detect what format a file is and whist searching for a Windows port of that I came across the [UnxUtils](http://unxutils.sourceforge.net) project on SourceForge. This looked to be a native port of the most commonly found Unix tools such as awk, sed, grep, egrep etc. It didn’t contain a version of ‘file’ but I got one of those from somewhere else. Anyway, I unzipped the [UnxUtils](http://unxutils.sourceforge.net) package, added it to my PATH, and then waited for a moment to use them.

That moment came sooner than I expected. I needed to analyse our on disk trade repository and provide some idea of its size and daily growth. My instinct this time was somehow to use Excel as that is pretty much what the financial world uses for all its analysis and reporting. But we were running an old version that still has the 65K row limit and our repository was well over 100K files per day. So I Googled for an [Awk based solution](http://www.liamdelahunty.com/tips/linux_ls_awk_totals.php) which (adapted for Windows) initially became:-

`c:\> dir /s *.trade \| gawk “{ sum += $3 } END { print sum }”`\

This was pretty close, but I needed to strip the chod out of the dir listing for the daily comparison. Also, recursively searching the repository whilst I was getting this right was going to be way too slow so I captured the output from dir once and applied a sprinkling of Sed to remove the rubbish:-

```
c:\> dir /s *.trade > filelist.txt      ```
c:\> sed –n /^[0-9][0-9]/p < filelist.txt \| gawk “{ sum += $3 } END { print sum }”

And that was it for the current repository size. The day-on-day growth just involved extra calls to Sort and Diff to trim out the common items - it was a textbook example of pipeline processing!

Of course I got stuck for ages not knowing that Sed has a limited regex capability or that the ‘END’ in the gawk script had to be in uppercase. But it inspired me to put the effort in to learn the tools properly and so I popped onto Amazon and found a second hand copy of [Sed & Awk (2nd Edition) by Dougherty & Robbins](http://www.amazon.co.uk/sed-awk-2nd-Dale-Dougherty/dp/B00007FYIJ) for under £10 and also picked up the [O’Reilly Sed & Awk Pocket Reference](http://www.amazon.co.uk/sed-awk-Pocket-Reference-OReilly/dp/B0043EWV10) for a couple of quid to leave in my drawer at work.

In the last couple of months I’ve read the majority of the book so that I feel more equipped to notice when this pair of tools would be a better choice. One of the most useful features I discovered about Sed (that I don’t believe VS can do _easily_) is to apply a transformation to repeating sections of a file (which are specified by an ‘address range’, i.e. a pair of regex’s that denote the start and end of the region). I’ve also found it easier to use Awk to generate, say, SQL statements where I have the output from a query that then needs to be turned back into a bunch of stored procedure calls with the previous result set as the parameters. This is doable in VS with regex based search & replacing but it’s probably not the most efficient use of my time.

The only real problem I have is that the Sed regex syntax is a subset of the normal POSIX one, so some common features are not available. It’s also another regex syntax to learn (along with Visual Studio’s own warped variation).

By this point I suspect that I’m preaching to the converted and there is much nodding of heads. There has also probably been the quiet whispering of “the right tool for the job” and all that. So yes, I’m incredibly late to the party, but I’m most pleased with my re-acquaintance. I don’t expect to ever be writing multi-line scripts but even if it makes the one-liners easier it will have been ten quid well spent.



[*] I search and analyze much larger log files every day with [BareTail, BareGrep](http://www.baremetalsoft.com) and [LogParser](http://en.wikipedia.org/wiki/Logparser). It’s just that I don’t need to modify them or generate other files from them.

[#] When it came to searching my entire (400 MB) hard disk it was actually quicker to close Windows 3.1, reboot into Linux (0.91pl15 IIRC) and use find + grep, save the results and then reboot back into 16-bit Windows than it was to do the search directly in Windows (or via a DOS prompt) in the first place.

[^] I want my tools to behave naturally on Windows - I have no desire to simulate a Unix environment.


---
Original: <https://chrisoldwood.blogspot.com/2010/11/reacquainting-myself-with-sed-awk.html>\
Copyright: Chris Oldwood 2010\
Published: Tuesday, 23 November 2010 at 23:07\
Labels: tools
