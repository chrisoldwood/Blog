# BCS Talk - An Introduction to F#

Last night I attended a BCS talk for the [Advanced Programming Specialist Group](http://www.bcs.org/server.php?show=nav.9813) by Don Syme of Microsoft Research about F#, a new language addition to the Visual Studio family as of VS2010, but also available as a separate download for VS2008. F# is a Functional Programming language at heart, but also has the ability to support both OO and traditional imperative styles as well, which is hugely important for interop with the other .Net languages. Don is the designer of F#, and although I went to [Oliver Sturm's](http://accu.org/index.php/conferences/accu_conference_2009/accu2009_speakers) ACCU 2009 conference session [Functional Programming in F#](http://accu.org/index.php/conferences/accu_conference_2009/accu2009_sessions#Functional), I felt getting the lowdown on F# straight from the horses mouth was too good to miss. Oh yeah and a trip to the pub after to chat with fellow BCS members is always a worthy pursuit.

Don's talk lasted just under 90 mins and started by covering the background, such as the design goals; Simplicity, Economy & Programmer Productivity. The former allowed him to compare some verbose C# code and the equivalently succinct F# version. With it being a .Net language the JIT compiler should allow for efficient code generation, and the static typing also helps the IDE to use IntelliSense. Don pretty much skipped over any discussion of syntax and headed straight for the meat to show how you can write using different paradigms, giving some nice demonstrations such as graph plotting and web crawling. These also gave him a good opportunity to show how easily it interops with the rest of the .Net class libraries.

The reason I was aware of F# was because I had read an article about it in [MSDN Magazine](http://msdn.microsoft.com/en-us/magazine/cc164244.aspx) , and the pipelining and parallel processing aspects really caught my eye. Don had just enough time to take the original single-threaded web crawler example and show how it could be changed to use an asynchronous style, but without making the code unreadable, in fact there were hardly any changes at all.

I've never studied or done any Functional Programming, but this was a key theme at last years [ACCU Conference [2008]](http://accu.org/index.php/conferences/accu_conference_2008), and the change in hardware due to multiple-cores and NUMA architectures has prompted quite a bit of discussion around the mutability of data and it's effects on scalability. Also in this months [C Vu](http://accu.org/index.php/aboutus/aboutjournals) magazine [ACCU], Andrei Alexandrescu in his article "The Case for D", touches quite a bit on this subject and explains the FP aspects of D which look very interesting. It looks like I can't ignore this area of Computer Science any longer.


---
Original: <https://chrisoldwood.blogspot.com/2009/05/bcs-talk-introduction-to-f.html>\
Copyright: Chris Oldwood 2009\
Published: Thursday, 28 May 2009 at 15:57\
Labels: BCS
