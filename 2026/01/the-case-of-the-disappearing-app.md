## The Case of the Disappearing App

[_Despite being almost 30 years ago, and the finer details being lost in the mists of time, the punchline has always stayed with me – it’s scar tissue I guess :o)._]

I was contracting in a team which had taken over a codebase from another company, to try and improve the performance, as it was far below what was needed for even the smaller use cases they had in mind.

The front-end was a PowerBuilder based GUI and I was a C developer working on the in-process back-end library which was a scheduling engine (think: travelling salesman problem). To be more precise, the actual scheduling engine was written in Pascal which was then translated into C and statically linked into the back-end library which acted as the infrastructure code – reading & writing to the database, a large caching layer, providing the C API for PowerBuilder to interact with engine, etc.

One day there was a report from the QA team (which was effectively one guy – the same guy I mentioned before in [A Not So Minor Hardware Revision](https://chrisoldwood.blogspot.com/2019/03/a-not-so-minor-hardware-revision.html)) about the application just “disappearing”. There was no error message from the application, and no UAE / GPF style crash dialog from the OS either, which was Windows NT 4 at the time.

We could reproduce the problem fairly easily. It basically involved importing a new set of orders and running the scheduling engine. This was pretty much what we had been doing all along to profile the application and address the various performance issues we ran across. We had some nice test datasets that we kept using across the entire team and I suspect (now) he was probably using a newer one [1].

What was weird was that there no trace of the application terminating. If it _was_ crashing Windows would have told us, and allowed us to attach the debugger. I even ran the application under the debugger and made sure I’d enabled “first chance exceptions” in case any Structured Exception Handling was being triggered and swallowed (it was C, not C++ so there would be no exceptions per-se). There was no mention in the event log either of anything unusual.

In the end I resorted to single stepping into the back-end and slowly drilling down into the code to see if I could work out if there was something in our code causing this. The core engine used a [Tabu Search](https://en.wikipedia.org/wiki/Tabu_search) and called back out repeatedly to get various bit of data like product details, driving time between two points, etc. It was dying somewhere inside the core engine, but due to the cyclic nature of the execution it was hard to put a breakpoint anywhere useful. (This was Visual C++ 2.0 and conditional breakpoints had a habit of slowing things right down which added to the debugging burden as it didn’t trigger that quickly as-is.)

During my debugging attempts I began to notice that the memory footprint was spiking and had a suspicion that ultimately the cause was an out-of-memory problem. Native applications typically behave pretty badly when they run out of memory as it tends to lead to dereferencing a `NULL`\ pointer and the process unceremoniously crashing. But, as pointed out earlier the Windows crash handler was not being invoked so something else was going on.

Eventually I decided to put conditional breakpoints on the prologue of the CRT functions `malloc()`\ and `calloc()`\ in the hope that I could catch it returning a `NULL`\ pointer. It worked, and as I slowly walked back up the function stack I could see why the application simply disappeared – the error handling simply called `abort()`\! Although this was quite an abrupt termination from a users perspective, from a Windows OS point of view the process had exited gracefully and therefore no crash handler was needed. Under the covers I suspect `abort()`\ called `TerminateProcess()`\ and so the PowerBuilder GUI would not have been able to catch the process’ impending doom either. If I remember correctly we found a couple of these calls to `abort()`\ and removed them so that the error could attempt to bubble back up the stack and at least the user would get notified one way or another of the unstable nature.

As an aside, this wasn’t the only memory issue we had on that project. Not counting the bizarre performance issue in [A Not So Minor Hardware Revision](https://chrisoldwood.blogspot.com/2019/03/a-not-so-minor-hardware-revision.html) we also suffered badly from heap fragmentation because this was before the days of the [low-fragmentation heap](https://learn.microsoft.com/en-us/windows/win32/memory/low-fragmentation-heap). The knowledge I learned along the way debugging these, and other memory and heap issues elsewhere, paved the way for my first proper ACCU article [Utilising More Than 4GB of Memory in a 32-bit Windows Process](https://www.chrisoldwood.com/articles/utilising-more-than-4gb.html).



[1] I also seem to remember running Oracle _locally_ so that each developer had their own database for testing which would have affected the overall memory footprint for the machine.


---
Original: <https://chrisoldwood.blogspot.com/2026/01/the-case-of-disappearing-app.html>\
Copyright: Chris Oldwood 2026\
Published: Monday, 26 January 2026 at 20:55\
Labels: 32-bit windows, bugs, history, visual c++
