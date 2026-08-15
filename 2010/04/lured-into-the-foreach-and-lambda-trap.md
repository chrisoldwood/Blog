## Lured Into the foreach + lambda Trap

I had read [Eric Lippert’s](http://blogs.msdn.com/ericlippert) blog [on the subject](http://blogs.msdn.com/ericlippert/archive/2009/11/12/closing-over-the-loop-variable-considered-harmful.aspx), I had commented on it, I had even mentioned it in passing to my colleagues the very same morning, but I still ended up writing:-

```
foreach(var task in tasks)      ```
{ 
. . . 
ThreadPool.QueueUserWorkItem(o => ExecuteTask(task));       
}

Then scratched my head as I tried to work out why the same task was suddenly being processed more than once, which was only an issue because the database was chucking seemingly random “Primary Key Violation” errors at me. Luckily I had only changed a few lines of code so I was pretty sure where it must lie, but it still wasn’t obvious to me and I had to fire up the debugger just to humour myself that the ‘tasks’ collection didn’t contain duplicates on entry to the loop as I had changed that logic slightly too.

Mentally the foreach construct looks to me like this:-

```
foreach(collection)      ```
{       
 var element = collection.MoveNext();       
 . . .       
}

The loop variable is scoped, just like in C++, and also immutable from the programmers perspective. Yes the variable is written before the opening ‘{‘ just like a traditional for loop and that I guess is where I shall I have to look for guidance [until the compiler starts warning me](http://blogs.msdn.com/ericlippert/archive/2009/11/16/closing-over-the-loop-variable-part-two.aspx) of my folly. Back in the days before all C++ compilers* had the correct for-loop scoping rules a common trick to simulate it was to place an extra pair of { } ‘s around the loop:-

```
{for(int i = 0; i != size; ++i)      ```
{       
 . . .       
}}

This is the mental picture I think I need to have in mind when using foreach in the future:-

```
{var element; foreach (collection)      ```
{       
 element = collection.MoveNext();       
 . . .       
}}

That’s all fine and dandy, but how should I rewrite my existing loop today to account for this behaviour? I feel I want to name the loop variable something obscure so that I’ll not accidentally use it within the loop. Names like ‘tmp’ are out because too many people do that to be lazy. A much longer name like ‘dontUseInLambdas’ is more descriptive but does shout a little too much for my taste. The most visually appealing solution (to me at least) has come from PowerShell’s $_ pipeline variable:-

```
foreach(var _ in tasks)      ```
{       
 var task = _;       
 . . .       
 ThreadPool.QueueUserWorkItem(o => ExecuteTask(task));       
}

It’s so non-descript you can’t use it by accident in the loop and the code still visually lines up the ‘var task’ and ‘in collection’ to a reasonable degree so it’s not wholly unnatural. I think I need to live with it a while (and more importantly my colleagues too) before drawing any conclusions. Maybe I’ll try a few different styles and see what works best.

So what about not falling into the trap in the first place? This is going to be much harder because I’ve got a misaligned mental model to correct, but questioning if a lambda variable is physically declared before the opening brace (instead of the statement) is probably a good start. Mind you this presupposes I don’t elide the braces on single-line loops - which I do :-)

```
foreach(var task in tasks)      ```
 ThreadPool.QueueUserWorkItem(o => ExecuteTask(task));

One final question on my mind is whether or not to try and write some unit tests for this behaviour. The entire piece of code is highly dependent on threads and processes and after you mock all that out there’s virtually nothing left but this foreach loop. It also got picked up immediately by my system tests. Still, I’ve always known the current code was a tactical choice, so as I implement the strategic version perhaps I can amortise the cost of refactoring in then.



[*Yes I’m pointing the finger squarely at Visual C++]


---
Original: <https://chrisoldwood.blogspot.com/2010/04/lured-into-foreach-lambda-trap.html>\
Copyright: Chris Oldwood 2010\
Published: Thursday, 1 April 2010 at 20:44\
Labels: c#
