## Refactoring – Do You Tell Your Boss?

_[This is one of the posts that I’ve thought long and hard about whether I should publish. I’ve edited it a few of times to try and ensure that it comes across in the spirit that was intended – to illustrate that it’s a complex issue that often fosters an “Us and Them” style attitude which often leads to resentment on the part of the programmer. Stack Overflow once again comes to my rescue with two beautifully titles questions:- _[_“How do you justify Refactoring work to your penny-pinching boss?”_](http://stackoverflow.com/questions/77193/how-do-you-justify-refactoring-work-to-your-penny-pinching-boss)_ and _[_“How can I convince skeptical management and colleagues to allow refactoring of awful code?”_](http://stackoverflow.com/questions/38144/how-can-i-convince-skeptical-management-and-colleagues-to-allow-refactoring-of-aw)_]_

I want to be as transparent as possible about my work; if I’m doing something I want that to happen with my boss’ approval. I hope that they trust me to be do the right thing, but will also challenge me to ensure that I’m still being as effective as possible. Although I like to think of myself as being pretty pragmatic, I’m only human and so can get sidetracked or incorrectly prioritise tasks like anyone else.

When it comes to refactoring I’ve found this to be a double-edged sword. Those managers who have a technical background and/or a modern outlook on software development will probably already be aware of concepts like [Technical Debt](http://www.martinfowler.com/bliki/TechnicalDebt.html) and be willing to allocate time for it in the schedule. But there are also those managers who are are less technical, often described as ‘more aligned with the business’, and for them it’s a much harder sell. To a less technical manager refactoring either sounds like ‘rewriting’ or ‘gold-plating’ and may be dismissed as unnecessary because you are essentially taking something that works and making it continue to work - but in a different way. Given a choice between ‘New Feature X’ and a ‘Better Implemented Feature Y’ they’ll always pick the former - that’s only natural. I’m sure if we software developers were salesman (much like the business people we develop for) we’d have no trouble getting it accepted as a necessary practice, but most of us aren’t and that means we often resort to one of the following choices:-

<u>Don’t do it at all</u>

This isn’t really a choice. If your codebase is already getting you down, doing nothing with only cause you more pain if you care. In the end it’ll win and you’ll be forced to leave and find another job. Hopefully with a more understanding team.

<u>Do it in Your Own Time</u>

Using your own time to improve the codebase might be viable if it’s quite small and could lead to you showing your boss what difference it makes in the long run to adding new features. But even then they may still not ‘get it’. In a larger team and with a larger project this is just an arms race – can you clean up faster than your colleagues can make more mess? If you can’t then you’ll just resent the fact that it’s your own time you’re wasting and in the end be forced to leave and find another job. Hopefully with a more understanding team.

<u>Do it By Stealth</u>

That just leaves doing it by stealth as part of your normal working day. But that means inflating your timescales and lying about what you’re actually doing. This may have the desired effect on the codebase but won’t make you feel at ease inside. You’ll also have to be careful what you email and say to avoid embarrassing questions. Without your teammates behind you, you can only survive like this for so long, eventually it’ll wear you down as you’ll never get the time to tackle the really big issues. In the end you’ll be forced to leave and find another job. Hopefully with…

I’ve been fortunate enough to mostly work for managers that have trusted me to do the right thing; but I’ve also had occasions where I’ve had to hide some refactoring to do what I felt was fundamentally important and always getting sidelined. Not unsurprisingly this seems to be more symptomatic in Big Corporations, at least according to the developers I’ve spoken to about this, but that’s not exactly a statistically valid sample.

One person I asked at the recent [ACCU Conference](http://accu.org/index.php/conferences/accu_conference_2010) was [Roy Osherove](http://weblogs.asp.net/rosherove/) because he was speaking about team leading; and he suggested that refactoring is a natural part of the development process so why do I consider it such an issue? In principle I agree with this sentiment, but it I think it misses a key point which is the effect it can have on the project schedule - which is something I do not own. When implementing a feature there is often a quicker way that may incur Technical Debt, and a slower way that avoids any new debt or maybe even allow it to be reduced, plus other variations in between. This implies a sliding timescale for the answer to “How long will it take?” and so that is not something I can always answer with a single figure. I can advise and provide options, but ultimately the choice must surely lie with the customer. Failing that (perhaps the customer isn’t in the right position to make such a decision or doesn’t care) it must be my boss or his boss etc. as they are the ones juggling the budget, schedule and resources balls.

So what is a poor programmer to do? Those people who I feel should make a judgement call on when the opportunity is ripe for refactoring (instead of always picking the ‘crowd pleasing’ items) aren’t inclined to do so; and although I’m probably empowered to do so I feel duty bound to give them first refusal on how I go about my job to ensure I’m acting responsibly and making pragmatic choices to the benefit of the customer.


---
Original: <https://chrisoldwood.blogspot.com/2010/05/refactoring-do-you-tell-your-boss.html>\
Copyright: Chris Oldwood 2010\
Published: Tuesday, 11 May 2010 at 21:54\
Labels: programming
