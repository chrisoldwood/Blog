## Naming Functions: When Intent and Implementation Differ

Most of the time these days when I get into a conversation about naming it tends to be about tweaking the language, perhaps because I think there is a much better term available, or the author is a non-native speaker and they’ve transliterated the name and it’s ended being quite jarring, or worse, ambiguous. I’m also on somewhat of a personal crusade to try and vastly reduce the lazy use of “get” in codebases by replacing it with far more descriptive names. (For a more humorous take on the overuse of “get” try my [Overload](https://accu.org/journals/nonmembers/overload_issue_members/) back-pager “[Acquire Carter](https://accu.org/journals/overload/27/154/oldwood_2721/)”. Alternatively my [C Vu](https://accu.org/journals/nonmembers/cvu_issue_neutered/) article “[In The Toolbox – Dictionary & Thesaurus](http://www.chrisoldwood.com/articles/in-the-toolbox-dictionary-and-thesaurus.html)” tackles the issue a little more traditionally.)

  However, more recently I ended up in a conversation where I felt the the whole point of “naming to reveal intent” had gone out of the window and the author and other reviewer were far too fixated on reflecting the implementation instead. Normally the intent and implementation align very closely, but in this instance they didn’t because it was the first step towards formalising a _new_ feature, which was implemented temporarily [1] using a different one.

To anyone who’s read [Arlo Belshee](https://arlobelshee.com/)’s writings on [Naming as a Process](https://www.digdeeproots.com/articles/naming-process/) I think you’ll recognise what follows as a case of “Honest Naming” instead of “Naming for Intent”, and that comes at a cost to the reader.

  **Background**

  I currently work on a system used to generate a variety of different reports. When some of the reporting code runs it generates log messages which warn about missing data, which means it’s had to substitute something else instead. When the code was initially written it was being run interactively and so the missing data would get addressed quickly. However, now that it’s automated nobody sees these messages anymore, except when the code fails and anything written to `stdout`\ gets included in the failure alert.

  Naturally, there should really be some better way of surfacing these anomalies, even if the report generation succeeds, and there will be, eventually. However, in the meantime we discovered there is a way of hooking into the report scheduler so that those warnings could at least be surfaced in a completion status email instead. This mechanism involved a bit of abuse though – using the “critical” log level instead of merely logging the missing data as a “warning”, because serious errors during runtime were still highlighted at completion.

  **First Attempt: Confusion Through Dishonesty**

  The simplest thing that could possibly work, and the initial change that was presented, was to directly change any log lines like this:

  `print(“WARNING: Missing data for ‘XYZ’”)`\

``\  to use an alternative logging function like this:

  `logCritical(“Missing data for ‘XYZ’”)`\

``\  My immediate reaction to this was one of “No, now the code is lying to us!”. The code previously made it clear that this condition was just an inconvenience but now it appears to be far more serious.

  While the elevation in severity was unfortunate my real problem was that it was missing the reason _why_ the logging call was being made in the first place. Even in the original code the use of `print()`\ was a means to another end, and ultimately we should make _that _end more obvious.

While I’m a fan of doing the simplest thing by default, that does not also mean doing something overly naïve. The cost of adding an extra level of indirection at this point in time was not onerous and would very likely minimise rework in the future as we evolved the real implementation.

  **Second Attempt: Too Honest**

  I thought I had expressed my opinion fairly clearly and there appeared to be agreement on the way forward so I was somewhat surprised when the code came back like this:

  `enrichEmailWithWarning(“Missing data for ‘XYZ’”)`\

``\  At this point I pulled out [Arlo Belshee’s classic naming infographic](https://x.com/arlobelshee/status/636605852984545280) to try and show how we were still a way off getting to the point where the code was saying what was _really_ going on at a business level.

  What makes this particularly confusing is the code where this appears runs in a child process and so has no knowledge of the parent scheduler. Hence the function being invoked is talking about some obscure mechanism totally outside itself. The name of the function in this instance is _too_ honest, it says what is going under the covers but not what it really means. If you run this interactively again what email is it even talking about?

  On the plus side though we have at least encapsulated the underlying mechanism to stop lying about the severity, and we can reimplement this later to use a separate file, database, or whatever without touching all the call sites. Or can we?

  Well, the problem with honest naming is that when the implementation changes, then so does the name. This means all the call sites will have to be updated yet again each time we reimplement it. Every time we update the code we run the risk of breaking it [2], and it adds unnecessary noise to the file’s history because the real intent hasn’t changed.

  **Third Attempt: Revealing Intent**

  Let’s take a step back and ask ourselves what this line of code is really trying to achieve:

  `print(“WARNING: Missing data for ‘XYZ’”)`\

``\  While you might say that it’s printing or logging, that is just the implementation bleeding through. A more general way of saying that might be “recording”. You could argue that “notifying” might be better because the information is included in a status email but I’d suggest that is being _too _specific at this point because in the future it may only get written somewhere and the retrieval mechanism is totally up for grabs and could easily involve not sending yet more emails.

  Okay, so we’re recording something, but that’s not much better than `print()`\ or `log()`\ if we are just going to pass an arbitrary text string. We need to think more about _what_ we’re recording to see if that can be included in the name too, or broken down into separate arguments.

  The whole reason this conversation started was because the messages about missing data were not being seen and therefore we needed to surface them in some way. Hence what we’re recording is “missing data” and that record ideally needs to be different from the diagnostic trace messages and other more general logging output. Hence the function name / API I proposed was:

  `recordMissingData(“XYZ”)`\

``\  To me this now expresses far better what the original author intended all along. The implementation has the ability to vary quite widely from simply printing to `stdout`\, logging to a file, writing to a queue / database, and yet the same name will continue to reflect _all_ those possibilities. By elevating the text “missing data” from the log message to the function name we are also being more explicit about the fact that handling missing data is formally recognised as a feature and _can_ be given special treatment, unlike the general logging output.

Anyone not involved in this conversation who runs across the code and has a similar requirement stands a better chance of using it correctly too, meaning less rework. When it’s missing, future readers may try to “second guess” what’s going on and then apply the same mechanism for different, inappropriate reasons and now, as they say, you have _two_ problems.

I can’t say for sure we won’t need to revisit this again as we learn more about the nature of _what_ data is missing and whether with more context we can automatically triage and notify the right people, but for now it feels like the cost / benefit ratio of “talking versus doing” is about right.



[1] Describing anything as “temporary” is a fools errand, we all know it will live far longer than planned :o).

[2] This is code written in a dynamic language so even a simple typo can go undetected unless it’s tested properly.




---
Original: <https://chrisoldwood.blogspot.com/2024/04/naming-functions-when-intent-and.html>\
Copyright: Chris Oldwood 2024\
Published: Monday, 22 April 2024 at 09:42\
Labels: design
