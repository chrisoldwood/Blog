## My ACCU Conference 2010 Lightning Talk

At this years [ACCU 2010 Conference](http://accu.org/index.php/conferences/accu_conference_2010) I decided to be brave and enter in for a Lightning Talk. These are 5 minute presentations on pretty much anything you like – although it helps to have some relevance to the hosting event :-) If you so desire you can provide a few background slides, but with only 5 minutes of talking time you probably won’t need many.

The premise of my talk was a homage to the [BBC 2 TV comedy show Room 101](http://en.wikipedia.org/wiki/Room_101_(TV_series)). Each week a different celebrity tries to convince the host ([Paul Merton](http://en.wikipedia.org/wiki/Paul_Merton)) that some things they dislike (physical, emotional or whatever) are truly appalling and should be banished from this Earth. Think “Crazy Frog” and you should get the general gist. For my talk I picked three of Microsoft’s products that have somehow managed to attain immortal status in the development world when they should have been retired years ago. The fact that they are all products from Microsoft should suggest nothing about _my_ opinions of Microsoft per se (after all I work solely on their platform through my own choice) but more about the mentality of the companies that have managed to tie themselves so inextricably to the products in question. Funnily enough [Udi Dahan](http://www.udidahan.com/2010/04/23/thoughts-on-microsoft-history-and-oss/) sort of covered similar ground himself a few weeks ago – though in a far more intelligent fashion of course.

Given that the slides are going to be up on the ACCU web site I decided that it might be worth adding a little prose to go alongside them and to try and diffuse any flames that might arise from my last slide – should the comment about [jQuery](http://jquery.com/) be taken at face value. So, if you want to play along at home you can pull up the slides on the ACCU website [here](http://accu.org/index.php/conferences/accu_conference_2010/accu2010_sessions#Lightning Talks), or you can just imagine these bullet points are some slick PowerPoint presentation. Obviously reading the text below won’t have anywhere near the same impact as me standing in front of an audience because what little intonation and comedy timing there was will be completely lost :-) I’m not sure exactly what I said but it went something like this…

<u>Visual SourceSafe</u>


* 10 Analyze.exe –F, 20 GOTO 10 
* More chatty than Alan Carr 
* Working Folder randomiser 

My first choice is the proverbial “Punch Bag” of Version Controls Systems. If you Google “Visual SourceSafe” you’ll quickly discover that the most common complaint is about how it has the ability to corrupt your source code database on a regular occurrence. One of the first automated tasks you learn to create is one to run analyze.exe to find and fix any errors - that assumes of course you can persuade Visual Studio to leave the repository alone long enough to actually run the tool.

One sure-fire way to corrupt your database is to use VSS over a VPN. If you don’t manage to kill your network with the excessive SMB traffic caused by the file-system based architecture you’ll eventually be greeted with the legendry “Invalid DOS handle” error message. At this point you’ll be executing the “20 GOTO 10” part of this slide as your entire team “downs tools” once more.

But not all weirdness is the result of repository corruption, sometimes tools like Visual Studio will try and “help you out” by explicitly setting the “Working Folder” for a project which you later moved to another more suitable location. Now your code lives in one part of the hierarchy in VSS but in the working copy it’s back where it started! So now you start deleting all those .scc files along with the usual .ncb and .suo files in hope that you’ll remove whatever it is that seems to link the project with its past life.

<u>Visual C++ 6</u>


* Visual Studio 1998 (10 is the new 6) 
* #if _MSC_VER < 1300 
* It’s _Visual_ C++ 

My second choice is Microsoft’s flagship C++ compiler. As you can see this was also know as Visual Studio 1998. Yes, that’s a year from another millennia! So, how many of you bought a copy of Andrei Alexandrescu’s seminal book “Modern C++ Design”? And how many of you put it straight back on the shelf when you discovered that you couldn’t even compile the first example because your compilers’ template support was so broken? This compiler was released before the current standard was finalised and it’s interesting to note that some Microsoft bloggers used the phrase “10 is the new 6” when writing about the upcoming Visual Studio 2010. This was a reference to the supposed performance enhancements going into making VS2010 as nippy as VC6, but it seems more amusing to point out that they are going to make the same mistake again and release a major C++ compiler version just before the next C++ standard is finalised.

Many developers think that Boost is incredibly complex because it uses lots of clever Template Meta-Programming. It’s not. It’s because every class has to be implemented twice. One inside an “#if _MSC_VER < 1300” guard for Visual C++ 6 users and another for every other compiler to use.

It’s interesting to note that many recruitment agencies ask for _Visual_ C++ experience, instead of just plain C++, as if somehow it’s a different language? Mind you, given the number of supposedly experienced C++ developers I’ve interviewed in recent years that still believe the default container type is CArray and not std::vector it makes me wonder if the recruitment consultants aren’t actually right on this one.

<u>Internet Explorer 6</u>


* The Corporate Standard 
* MDI is so 90’s 
* jQuery is fanning the flames 

My final choice is Internet Explorer 6. Despite what the cool kids think, this is still the standard web browser in many large corporations. Putting popup iframes on a web site that tells me I’m using a lame browser doesn’t help me fell any better either – if I could do something about it I would. In one organisation you get a virus warning if you try to install a more modern browser like Firefox.

I’ve come to believe that Tabbed Browsing is a right and not a privilege. How I am supposed to adhere to the company’s clean desk policy when IE litters my desktop with Windows and my taskbar with little ‘e’ icons?

I partially lay the blame for the continued existence of IE6 at the feet of jQuery. It used to be hard to support because you needed to know how to code around all its little quirks and foibles. jQuery now makes it easy to support again. Please stop doing that! We want it to be hard so that we have a reason to get off this merry-go-round.

<u>Epilogue</u>

Sadly all three products look like they’re going to be with us for some time yet. So, would anyone like to wager a bet on which we’ll see first - the death of one of these atrocities or the first Liberal Democrat government? [*]



[*] Apparently politics was out of bounds, but I felt this incredibly cheap shot was far too good to pass up :-)


---
Original: <https://chrisoldwood.blogspot.com/2010/05/my-accu-conference-2010-lightning-talk.html>\
Copyright: Chris Oldwood 2010\
Published: Saturday, 8 May 2010 at 20:02\
Labels: ACCU, rants
