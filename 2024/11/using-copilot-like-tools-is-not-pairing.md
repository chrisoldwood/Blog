## Using CoPilot-Like Tools is Not Pairing

Ever since the rise of LLM based tools like ChatGPT and CoPilot there have been quips made about how great it makes as a pairing partner. The joke is because these tools are passive and won’t trash your code, or disagree with your approach, or smell of garlic.

  I get the joke.

  The problem for me is that these jokes are suggesting that using tools like CoPilot are akin to pairing, but they’re not. And, as a consequence, they are continuing to perpetuate misconceptions about what pairing is really about. This topic came up one Tuesday at a [Cambridge Software Crafters meet-up](https://chrisoldwood.blogspot.com/2024/09/cambridge-software-crafters-meetup.html) when we were discussing mentoring & coaching and how to adopt pairing in companies that are hostile towards it, likely for these very reasons.

  (If you’re after a longer read on this subject I can offer you my 2018 C Vu article [To Mob, Pair, or Fly Solo](http://www.chrisoldwood.com/articles/to-mob-pair-or-fly-solo.html)__, or if you’re a video kind of person then you might want to watch the talky version I gave at the ACCU 2024 Conference, also titled [Mob, Pair, or Fly Solo](https://www.youtube.com/watch?v=W_oIq1hqWwE).)

  Tools like CoPilot are there to help you with the “mechanics” of writing code [1]. They complement the traditional tools like compilers and linters which help avoid a bunch of annoying problems that come with creating software as part of a solution. Your pairing partner may help you avoid these mistakes too, especially if you’re new to the language or tool, but that’s not _primarily_ what they are there for.

  Their input should focus on helping you to solve the actual problem. That might be at a design level, such as how best to represent the solution using common idioms or patterns, because they can see where it might be heading. They can also help come up with potential problems or edge cases that need to be factored in, and help decide how and when that might happen in the evolution of the feature you’re working on.

  I’ve never paired in the strict navigator-driver sense, it’s always tended to be far more free-flowing, likewise when ensemble programming too. The keyboard tends to go back-and-forth with “type, don’t talk” being the trigger to switch, when it’s not blindingly obvious what my partner(s) are trying to convey.

  Hence, in a TDD style loop the other half of the pair might already be thinking about the next test or where the design might be going for the refactoring step after the test passes. Sometimes one half is on a roll and it’s better to maintain momentum, other times both minds need to focus on the exact problem at hand, such as when the test fails unexpectedly. (If you _both_ missed it then that is a smell worth exploring because something is clearly amiss somewhere.)

  With modern IDEs and syntax highlighting the typist knows when there is a typo, they don’t need to be told by their partner. However the way they drive the IDE and other tools can often be a point of discussion as there are often many shortcuts and extensions that provide easy wins. High-end tooling often has an ability to try and point out other features you might find useful, and ChatGPT like tools could probably summarise related features in popular tools if asked.

  Humans often remember things better when the correction happens at the point of triggering, and what your partner can see that your tooling can’t, is whether or not it’s an appropriate moment to make a suggestion. There is a time and a place to share knowledge and part of the art of pairing is to read the mood and only interject if it’s likely to be beneficial now, or note it for a retrospective conversation later. It may even resolve itself automatically, later.

  Sharing knowledge takes practice. For instance, sharing the right level of detail or techniques and idioms, to avoid overwhelming your partner while they are trying to focus on the problem at hand. The new generation of coding tools might be well versed in programming language details and common patterns but they don’t know anything about your organisation, team, or design principles. They might help with the small picture but they can’t help with the medium and bigger pictures, and that is the bit that makes software delivery hard. That is also the area where your partner should be adding the most value to the exercise.

  Programming is so much more than just writing code, and programming in pairs and groups is about _active_ participation to triangulate on a _sustainable _solution far quicker than working with passive tools and feedback.



[1] Maybe one day they’ll be able to consume your entire codebase, along with the VCS history, so that they can tell what’s old and what’s new and make better design suggestions too based on evolving trends. We’ll see…




---
Original: <https://chrisoldwood.blogspot.com/2024/11/using-copilot-like-tools-is-not-pairing.html>\
Copyright: Chris Oldwood 2024\
Published: Thursday, 28 November 2024 at 09:03\
Labels: development process, programming, rants
