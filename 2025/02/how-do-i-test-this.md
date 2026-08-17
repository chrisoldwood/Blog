## How Do I Test This?

I’ve no idea where I first came across the following premise for when starting a new code change:

  “First ask yourself, how do I test this?”

  I had assumed it was Steve Maguire’s [Writing Solid Code](https://www.amazon.co.uk/Writing-Solid-Code-Techniques-Programming/dp/1556155514) or [Debugging the Development Process](https://www.amazon.co.uk/Debugging-Development-Process-Steve-Maguire/dp/1556156502) as these are two of the earliest books I read as a professional developer. He has some excellent advice in “step through your code in the debugger” and “how could I have prevented / automatically detected this”. But it wasn’t either of those. No matter, I just like to remember my sources of inspiration.

  Naturally, one shouldn’t take this advice too literally as there are _other_ questions that really need answering first, such as whether this feature is even needed. The point is that once writing code is part of the solution, then thinking about how you’re going to test it should be right up there on your list. One behaviour that is common in those just starting out in their programmer journey is the desire to jump right in and start writing code without any thought for how they are going to answer the eventual question “does it work?”. And, by extension, “does it solve the customer’s problem?”

For a bug-fix, that might seem obvious, if the bug is easy to reproduce, though there is still the follow-up question of “have I broken anything _else_ by accident?” Discovering up-front what you _might_ break can have a sobering impact on your approach. 

  For new features the question can be much harder to answer, especially if the change is buried deep inside some complex system. It’s all very well being able to change some code and _assume_ it works because the dry-run in your head suggests it will, but it’s another thing to be able to show that it works by running it in an observable way. This is doubly true when you factor in that famous quote from Edsger Dijkstra:

  “Testing can prove the presence of bugs, but not their absence!”

  **Design for Testability**

  What both of these quotes try and convey is that testing requires a change in mindset, it’s not just some activity you throw in when it’s “code complete”. I’d hope in this modern era of software development that we’d all recognise the folly of believing that you can just bash out some code in a non-trivial codebase and assume it’ll work first time. Or even that you’ll obviously be able to see all the potential edge cases up front. (The average developer only spends 2-3 years in a role so we’re constantly putting ourselves back in the position of “new joiner”.)

  To be clear, I’m not specifically talking about TDD (Test Driven Development) here, at least, not in the formal unit test / Red-Green-Refactor sense. I’m talking about it in a more _general_ sense of how thinking about how you’re going to test something will affect how you approach the task at hand.

  Plenty of what I do on a day-to-day basis does not have any formal automated tests produced as a by-product of it. For example, I am often heavily involved in the build, deployment, and support side of software delivery as much as writing code for the main product. While the latter will have a barrage of automated tests to help validate every change, the former often relies on an amount of manual testing. That’s because the cost benefit of introducing automated testing to a bunch of ad-hoc Bash glue scripts which rarely change is typically very high in comparison to the cost of testing them manually.

  However, what makes the cost of testing them manually much lower is not the inherent nature of them, but the mindset used in how they were written – they were [designed with testability](https://en.wikipedia.org/wiki/Design_for_testing) in mind. What that means in practice is that instead of writing only the bare minimum to solve the problem at hand, some additional effort is made to allow it to be tested safely and quickly, both now and when future changes are made. It’s just another trade-off we have to be cognisant of and weigh up whether it’s worth the extra effort up-front – is being easier to test worth it? If so, how much easier is enough? (There is always an XKCD, and [_Is it Worth the Time_](https://xkcd.com/1205/) along with _[Automation](https://xkcd.com/1319/)__are_ well worth the time revisiting every now and then to remind yourself of the potential costs and pay-off, and delusions of grandeur.)

  **Risk / Confidence**

  When I say “easier” you shouldn’t just assume I mean “quicker” either. Testing is about risk, and developing confidence. The goal is to deliver the highest level of confidence with the lowest amount of effort. Printing out a log message saying that you would have deleted a particular file gives you confidence that you’d have deleted the _correct_ file, but can’t point out that the entire process aborted because another process typically has it locked and now you might need to add logic to cater for retries and partial success. The principle of YAGNI (You ‘Aint Gonna Need It) is a strong force for reining in purely speculative requirements but can also be weaponised as an excuse for why anything outside the happy path was ignored.

  My point here is that you _consciously_ consider how you’re going to gain confidence and weigh up the options. Maybe when staring at that log message you’ll ask yourself “what would happen if that file is locked?” and consequently you go and adjust the code to allow you to target a different folder where you can create a locked file and test your hypothesis. Is that a temporary hack or do you introduce a command line switch / config setting [1]? If you’re going to keep hacking the code every time you test new changes then you run a higher risk of committing that hack by accident and breaking production [2].

**Scope**

We could very easily expand that original phrase “test this” to the more specific “test what happens when it fails”. Only testing the happy paths is such a common malaise, although I suspect it is largely borne out of naivety rather than short-sightedness. The cost of debugging code that fails in a horrible way is huge, and frequently occurs as the result of a production incident when time is of the essence. Taking the time up-front to think about failure scenarios and test how they will manifest will really help reduce stress levels when the inevitable happens. (Stack Traces are a crutch we lean on far too often when a good error message could provide better value.)

Another tweak would be to replace the “I” with “we” in the original proposition. The person who finds the code difficult to test in future might still be you, or it might be a colleague. I don’t particularly like that analogy of writing code as if some psychopath will hunt you down later, and prefer instead to try and promote “paying it forward” as simply the right thing to do. The ultimate outcome is a healthier team, and codebase, and a faster, more sustainable delivery pace. Doing it right actually benefits the business in the long run.

  **Always be Testing**

  The question “how do I test this?” doesn’t necessarily stop being asked once the code has been delivered either. As one of my earlier posts ([_Validate in Production_](https://chrisoldwood.blogspot.com/2019/11/validate-in-production.html)) shows, Dijkstra was right, and we need to be more pessimistic about our ability to get things right, first time, every time. Remember though there is a balance here. If you take Dijkstra at his word then you’ll never deliver anything as you’ll spend your entire time trying prove the absence of any bugs. (Formal Methods might be the exception here but I have no experience of that, or know anybody that has.)

It’s also only a short hop from that question to a closely related one – “how do I support this?” Ideally any separate support or operations team are already recognised as stakeholders in the system and their interests are explicitly factored in [3].

  Taking this yet another step further leads you into the whole world of [observability](https://en.wikipedia.org/wiki/Observability_(software)) and ultimately around testing the business hypothesis of whether building that new feature delivered the benefits expected. Having _that_ mindset where you can work backwards from “how to test the business impact” has yet more benefits that can be reaped.

Remember [_Overthinking is not Overengineering_](https://chrisoldwood.blogspot.com/2018/12/overthinking-is-not-overengineering.html).

  

[1] See _[Testing Drives the Need for Flexible Configuration](http://www.chrisoldwood.com/articles/testing-drives-the-need-for-flexible-configuration.html) _for further thoughts on that approach.

  [2] This is one of the many things in my mental [_Commit Checklist_](http://www.chrisoldwood.com/articles/in-the-toolbox-commit-checklist.html) which has come from making these mistakes myself in the past.

[3] Both _[Support-Friendly Tooling](https://chrisoldwood.blogspot.com/2018/07/support-friendly-tooling.html)_ and the much older _[From Test Harness To Support Tool](https://chrisoldwood.blogspot.com/2012/11/from-test-harness-to-support-tool.html)_ look at this angle.


---
Original: <https://chrisoldwood.blogspot.com/2025/02/how-do-i-test-this.html>\
Copyright: Chris Oldwood 2025\
Published: Thursday, 20 February 2025 at 10:37\
Labels: design, development process, scripting, testing
