## Unravelling Conflict

An interesting question came up at a meet-up I recently attended, where they were discussing approaches to coaching and mentoring. The question was not overly interesting by itself, but the roller-coaster of a journey as we got to the essence of the real problem, was. The initial framing of the question by one of the attendees was this: 

“How do I tell someone to optimise their code?”

  The wording here immediately made me feel a little uncomfortable because I generally dislike the notion of telling anybody what they should do or how they should behave. This was a session about coaching and mentoring and I felt that before we could answer the question we first needed to talk about the question itself, and the language used to express it. It helps immensely if you don’t go into the process assuming you are inherently right. But maybe it was _me_ that misread the tone of the question?

  One of the most useful guidelines for navigating life (not just the work environment), I first heard from [Jeffrey Snover](https://en.wikipedia.org/wiki/Jeffrey_Snover) – Chief Architect of PowerShell. He often used to tweet this saying:

  “When faced with conflict, respond with curiosity.”

  In this instance I’m the one facing conflict. The tone of question is at odds with how I feel people should behave towards others. In the past I have occasionally had the misfortune to work with some people that had very different ideas about collaboration (see [_Fallibility_](https://chrisoldwood.blogspot.com/2017/12/fallibility.html)) and so I also know that sometimes the answer is simply to walk away.

  However, the attendee was very likely not a native English speaker, and so there was every possibility the choice of words was simply unfortunate. They also seemed like a nice person from previous conversations I’d had, so this really felt like there was something much deeper going on that was worth pursuing.

  Unfortunately, the situation got slightly worse, before it got better. Some of the other attendees immediately started to challenge the assumption that anything might even need optimising. After all, the general wisdom on this topic is “don’t do it”. And, for experts only, the second rule is “don’t do it, yet”. I was happy to see where this line of questioning went and even added my own typical questions, such as, “have you measured it?” and “what business value would rewriting it bring?” Ultimately this lead to the even more uncomfortable statement:

  “I just don’t like _how_ it’s written.”

  I’ve worked on a few codebases where there is a lot of noise in the history because people decided to arbitrarily rewrite code simply because it didn’t fit their personal preferences. In the worst case code flip-flops between two styles as any chance to touch the module becomes an opportunity to rewrite it, yet again. Doing this just creates conflict within the team and is ultimately very wasteful. In contrast, _genuine_ refactoring, that brings to code _forward_ to adhere to the team’s current preferred principles and practices does have some merit. (See [_Sympathetic Change_](http://www.chrisoldwood.com/articles/afterwood-sympathetic-change.html) for more thoughts on this.)

  Anyway, this is going badly as I’m finding it harder to empathise with the speaker and my opinion of them shouldn’t really cloud my decision to help them. After all, they’ve come to this meet-up because they want to learn, like the rest of us, and we should fully embrace that.

  And then the magic starts to happen.

  Someone asks what it is about the code that they dislike, and we find out that the code was written using some very poor choices. The speaker continues to describe how there are more modern idioms which are inherently more performant and in-keeping with how code tends to be written in that language nowadays. Hence, this isn’t so much about _personal_ preference as de-facto standards.

  Now we’re on a roll.

  Further questioning reveals that this code was written by a relative newcomer, i.e. a more junior programmer. The original question _was_ badly phrased and the real question was about how to approach a more junior member of the team and mentor them on how to write better code – code which will perform better out-of-the-box, and also fits in with the industry norms. (Writing incredibly naively is known as pessimisation – the _opposite_ of optimisation – and we shouldn’t make poor design choices purely to avoid being seen to be prematurely optimising.) 

  Hence, what had seemed at first like a somewhat selfish question was actually altruistic in nature, and entirely within the community spirit the meet-up wants to promote.

  In retrospect I realised this was effectively an application of the classic [Five Whys](https://en.wikipedia.org/wiki/Five_whys) technique often used during incidents and post mortems to get to the “root” cause [1]. It’s easier to apply that technique to an incident because it’s less personal, whereas the continued questioning of a single person can feel more like an interrogation, so you need to be very careful not to appear to be attacking the person. Responding with curiosity is key to enabling that process as it allows you to create a warmer, safer space and therefore allow the other person to open up and become more reflective.    





[1] There are problems with the notion of there ever being a single cause of a issue, hence the use of quotes. [_How Complex Systems Fail_](https://www.adaptivecapacitylabs.com/HowComplexSystemsFail.pdf) is mandatory reading on this topic.




---
Original: <https://chrisoldwood.blogspot.com/2024/12/unravelling-conflict.html>\
Copyright: Chris Oldwood 2024\
Published: Wednesday, 4 December 2024 at 09:21\
Labels: meetup, people
