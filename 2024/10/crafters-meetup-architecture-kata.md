## Crafters Meetup: Architecture Kata

Last time I wrote about the monthly [Cambridge Software Crafters Meetup](https://chrisoldwood.blogspot.com/2024/09/cambridge-software-crafters-meetup.html) which I started attending almost a year ago. In that post I briefly mentioned the Architecture Kata session which I found particularly interesting as I’ve never done anything like that before.

  I’ve been aware of katas for a long time, but they’ve tended to focus on solving simple problems in code, usually with a test-first bias, but this is the first time I’ve seen it applied to other aspects of software delivery.

  **Session Format**

  The attendees divided into groups of four or so people and were given a problem statement to design a system. We then spent an hour or so discussing it before presenting our design and approach to the other teams at the end. One of the organisers acted as a sort of product owner who we could ask for further background or clarification.

  The problem we were given revolved around the overnight charging of a fleet of electric vehicles. The statement contained a fair bit of information about the charging rates and prices, along with other bits about the scale and monitoring.

  Each team had a large sheet of white paper and a pack of sticky notes and pens to use.

  **Big Picture or Small Picture?**

  One of the things I’m trying to get out of these meetup sessions is to sit back and see how other people approach problems. Having 30 years of experience means you have plenty of biases to overcome, but at the same time I’m not going to sit there and watch my team spin its wheels stuck in Analysis Paralysis or get lost down in the weeds. Hence I was prepared to try and nudge when I felt it was appropriate as we had limited time, but mostly I wanted to avoid appearing to take control of the group and drive the direction.

  To me, architecture is generally about big picture stuff. In this particular case: what is a suitable overall shape for the solution, such as computation, storage, network connections, etc? For example, the problem statement suggested that efficient charging was desirable from a cost perspective, which implied to us some kind of scheduling component which could drive the remote charging stations. The potential for failures (of vehicles, charging stations, etc.) also implied to us that this scheduling must be dynamic. However, that’s as far as our team went, aside from noting the need to store tariffs somewhere and perhaps historical data if charging was not effectively uniform to allow the system to be adaptive.

  One other team also looked at the problem at roughly the same “scale” we did, although they went as far picking specific technology choices as they had a firmer idea of exactly what services they were building and how they wanted to connect them.

  Somewhat surprising to me, two other teams focused deeply on the algorithmic element of how to efficiently charge the vehicles. Their presentation was all about what we had simply called “the scheduler”, and then ignored all the other stuff that sits around it. In _my_ mind these were implementation details rather than software architecture.

  Clearly the point of the session was to learn, so there were no right or wrong answers, but what in retrospect I’d be interested in knowing now is what the other teams think software architecture _is_ about. The other thing that occurred to me is that maybe I drove the direction of our team’s solution more than I thought, despite trying hard not to.

  **Actors**

  What also surprised me, and maybe this was one of the reasons why we ended up focusing on the big picture, was that our team was the only one which had any actors (i.e. users) in it. This was an early suggestion of mine as we were talking about the problem statement but nobody seemed to be looking at it from the user’s point of view. After all, software development is about solving people’s problems and it’s not always obvious who those people are at first.

There weren’t many users mentioned in the problem statement per-se, but I was trying to use that question to open up a wider discussion about who the stakeholders really are, and how those might affect the shape of the system. And not just the shape, but also the evolution of it as it grows from a walking skeleton to a fully-fledged system – the journey is often far more important than the destination, which we know _will_ change over time.

  **Design Surface**

  One thing I did do early on was to draw my actor on a post-it note and stick _that_ on the sheet of paper after I noticed someone was about to draw directly onto the sheet. The other teams sketched elsewhere and then drew up a final diagram and notes on their large sheet. Our final presentation was essentially a sheet covered in sticky notes.

  I’ll be honest, I love sticky notes :o), but I think one of the lessons of the architecture kata is that it should be fluid, and in the early days a system can be incredibly fluid, aka emergent design, therefore the temporary nature of sticky notes helps to explore and convey that. Once we had positioned some of the key actors (which weren’t necessarily people) at the edges we could then break down and refine what happens in the middle without having to re-draw from scratch or squeeze things in. (You don’t _need_ an electronic drawing board at this level could have been another lesson.)

  One of our team got some scissors and started cutting up the problem statement into little sections and attached them to the relevant part of the diagram. I really liked this as it gave a physical manifestation to the decomposition of the problem. It also helped us keep track of what we had covered and what we needed more detail on.

  **Epilogue**

  I really enjoyed this session, mostly because greenfield architecture is something which we rarely get to do as software developers. The vast majority of what we do is maintenance on existing systems and, even when adding new services, we are still designing within a space that is largely already well-defined. In my 30+ year career I’ve only been in this greenfield situation for real maybe three or four times.

  My background is largely in financial systems so the problem setting was new to me, although once you break it down you find that dashboards, scheduling, etc. are all smaller problems I’ve met before so have other experiences I could apply to this particular scenario.

  One consequence of the problem setting – the physical nature of chargers and electric vehicles – and my lack of knowledge of this technology, meant that these were big risks to me; so my general thoughts were around how to address _those_ and whether that might have an impact on the architecture. Ever since reading [Waltzing with Bears: Managing Risk on Software Projects](https://www.amazon.co.uk/Waltzing-Bears-Managing-Software-Projects/dp/0932633609) I have tried to factor the identification and mitigation of risks early on in my design thinking.

  I really forward to another architecture kata session. One point of katas is to solve the _same_ problem multiple times but by using different approaches. I’d love to do that but I suspect the desire of the meetup group would be to do something new each time.

Our team definitely didn’t make enough use of the product owner, which may have been because we weren’t sure whether that was really the role being played, or they were just there to provide some basic clarity. In the exercise I described in [Choosing a Supplier: The Hackathon](https://chrisoldwood.blogspot.com/2015/09/choosing-supplier-hackathon.html) we had a literal product owner shared amongst teams so that was more like what I was expecting. 

It would also be nice if we could find a little time to discuss what we even think “software architecture” means these days, and also reflect more on how we approach it as this session raised some interesting questions for me around the very nature of this level of design.


---
Original: <https://chrisoldwood.blogspot.com/2024/10/crafters-meetup-architecture-kata.html>\
Copyright: Chris Oldwood 2024\
Published: Saturday, 5 October 2024 at 11:08\
Labels: architecure, design, meetup
