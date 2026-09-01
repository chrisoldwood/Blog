## Unpacking Code Ownership

This post was prompted by a document I read which was presented as a development guide. While the rest of it was about style, the section that particularly piqued my interest was one involving code ownership. For those of us who’ve been around the block, the term “code ownership” can bring with it connotations of protectionism. If you’ve never worked with people who are incredibly guarded about the code they write may I recommend my 2017 blog post [_Fallibility_](https://chrisoldwood.blogspot.com/2017/12/fallibility.html) which contains two examples of work colleagues that erected a wall around themselves and their code.

  While I initially assumed the use of the term was a proxy for accountability, some comments to my suggestion that [_Relentless Refactoring_](https://chrisoldwood.blogspot.com/2014/11/relentless-refactoring.html) was an established practice in many teams hinted that there might be more to it than that. What came out of an online meeting of the team was that the term was carrying the weight of two different characteristics.

  (I should point out that I’m always wary of this kind of discussion verging into [bike-shedding](https://en.wikipedia.org/wiki/Law_of_triviality) territory. I like to try and ensure that language is only as precise as necessary, so when I suspect there may be confusion or suboptimal behaviour as a consequence, do I feel it’s worth digging deeper. In this instance I think “ownership” was referring to the following attributes and not about gatekeeping or protectionism for selfish reasons, e.g. job security.)

  **Accountability / Responsibility**

  When people talk about “owning your mistakes” what they’re referring to is effectively being accountable, nay responsible, for them. While there might be a legal aspect in the cases of Machiavellian behaviour, for the most part what we’re really after is some indication that changes were not made simply because “you felt like it”. Any code change should be justifiable which implies that there is an air of objectivity around your rationale.

  For example, reformatting the code simply because you _personally_ prefer a different brace placement is not objective [1]. In contrast, reformatting to meet the pre-agreed in-house style is. Likewise applying any refactoring that brings old code back in line with the team’s preferred idioms is inherently sound. Moreover, neither of these should even require any debate as the guide automatically confers agreement [2].

  Where it might get more contentious is when it _appears_ to be superfluous, but as long as you can justify your actions with a sense of objectivity I think the team should err on the side of acceptance [3]. The reason I think this kind of change can end up being rejected by default is when there is nothing in the development process to allow the status quo to be challenged. A healthy development process should include time for retrospection (e.g. a formal retrospective) and this is probably the place for further debate if it cannot quickly be resolved. (You should not build “inventory” in the form of open PRs simply because of unresolved conflict [4].)

  One scenario where this can be less objective is when trying to introduce new idioms, i.e. experimental changes that may or may not set a _new_ precedent. I would expect this to solicit at least some up-front discussion or proactive reviewing / pairing to weed out the obvious chaff. Throwing “weird” code into the codebase without consulting your teammates is disrespectful and can lead to unnecessary turf wars.

  Being accountable also implies that you are mature enough to deal with the consequences if the decision doesn’t go your way, aka Egoless Programming [5]. That may involve seeing your work rejected or rewritten, either immediately or in the future which can feel like a personal attack, but shouldn’t.

  **Experience / Expertise**

  While accountability looks at ownership from the perspective of the person wanting to change the code, the flipside of ownership is about those people best placed to evaluate change. When we look for someone to act as a reviewer we look for those who have the most experience either directly with the code itself, or from working on similar problems. There may also be different people that can provide a technical or business focused viewpoint if there are both elements at play which deserve special attention, for example when touching code where the previous authors have left and you need help validating your assumptions.

  In this instance what we’re talking about are Subject Matter Experts. These people are no more “owners” of the code in question than we are but that doesn’t mean they can’t provide useful insights. If anything having people unrelated to the code reviewing it can be more useful because you know they will have no emotional attachment to it. If the change makes sense feature-wise, and does it in a simple, easy to understand way, does anything else really matter?

  These days we have modern tooling like version control products which, assuming we put the right level of metadata in, allow us to see the evolution of the codebase along with the rationale even when the authors have long gone. Ownership doesn’t have to be conferred simply because you’re the only one that remembers how and why the code ended up the way it did. This leads into territory around fear of change which is not a sustainable approach to software delivery. In this day-and-age “consulting the elders” should really be a last resort for times when the record of events is lost in the sands of time. Approval should be a function based on knowledge of the subject matter rather than simply years of service [6].

   

**Shepherds, Not Owners**

Ultimately what I find slightly distasteful about the term “shared ownership” is that it still conveys a sense of protectionism, especially for those currently “outside the team”.

From a metaphorical point of view what I think I described above is more a sense of shepherding. The desire should be to nurture contributors to understand the culture of the codebase and product to the extent that the conversations can focus on the essential, rather than accidental complexity. 

I wonder if “shared mentorship” would work as a substitute?

            

           



         [1] This is a good argument for using a standard code formatting tool as it can make these debates moot. 



    [2] If the code is _that_ performance sensitive it should not be touched without consultation then there should either be some performance tests or at a minimum some comments to make that obvious.



  [3] The late Pieter Hintjens makes a compelling case in [Why Optimistic Merging Works Better](http://hintjens.com/blog:106).

  [4] There is where I favour the optimism of [Trust, but Verify](http://www.chrisoldwood.com/articles/afterwood-trust-but-verify.html) as an approach, or pairing / ensemble programming to reach early consensus.

  [5] The Psychology of Computer Programming – Gerry Weinberg, 1971.

[6] One needs to be mindful of not falling into the [Meritocracy](https://en.wikipedia.org/wiki/Meritocracy) trap though.


---
Original: <https://chrisoldwood.blogspot.com/2023/10/unpacking-code-ownership.html>\
Copyright: Chris Oldwood 2023\
Published: Wednesday, 4 October 2023 at 10:53\
Labels: development process
