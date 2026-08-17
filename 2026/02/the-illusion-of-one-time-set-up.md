## The Illusion of a One-Time Set-Up

One of the most laborious things about starting work at a new client / employer, can be getting your machine and user account configured so that you are able to work on their codebase. For me, the acid test of whether I’m in a good place is being able to build the code and run the necessary test suites locally that I’ll be relying on for the early feedback loop. But that’s the bare minimum.

There are often plenty of tools to install and configure, and I’m not just talking about light vs dark mode, but team and organisation level stuff once you need to reach out across the network to dev, test, and production services. The number of permissions for your user account can be extensive if you’re working on a system that has lots of tentacles that reach out to message queues, databases, APIs, etc. especially when the organisation doesn’t use single sign-on everywhere.

**One-Stop Shop**

  Sometimes this set-up process goes really smoothly and you can bootstrap yourself with very little effort, while other times it’s a long hard slog. In the corporate world there are typically more gates to go through as, for example, local admin rights are not conferred by default and your software choices are limited to what they grant access to. (See [Getting Personal](https://www.chrisoldwood.com/articles/in-the-toolbox-getting-personal.html) for a rant about where consistency in tooling actually matters.) Once you have access to the version control system, and the VCS tool installed, in theory you have the gateway to getting yourself set-up with a metaphorical “flick of the switch”…

  If only that _were_ always the case. Sadly it’s not unusual to be given little to nothing to work from. If the team uses a complex IDE like Visual Studio then it can often be assumed that once you have _that_ installed then you’re 99% of the way there. This is only the true if you believe software developers only “write code”.

Maybe you are given a wiki page which helpfully lists many of the tools you need (to request from the company’s software portal) but probably neglects to tell you how you need to configure them based on the team’s typical workflow and development environments. The kinds of things I’m talking about here are local / shared databases (including drivers and DSNs, or containers), the various Azure emulators for storage and queues (or shared cloud hosted instances), shared AWS resources, upstream and downstream in-house dependent services, etc. Okay, you may not have the required access up-front but getting the approval signed should be the only burden, once you have that you don’t need to be fumbling around trying to work out how to make use of your new found powers.

  **Once Upon a Time **

The reason typically given for not providing a _better_ DX (developer experience) is that this is a “one-time setup” and the cost _obviously_ isn’t worth it. But here’s the thing: while it may be a one-time set-up for that particular user and machine, it’s just one of many when you factor in _all_ the places where this kind of workflow will be needed in practice.

  Okay, so you don’t normally get people joining the team every few days, but configuring a local developer’s machine is the least interesting case, in my opinion. Where this blinkered one-time setup thinking really starts to cause a problem is once you factor in the build and deployment pipelines.

The whole “works on my machine” meme exists because it highlights the missing appreciation for what goes into turning a pending code change into a feature deployed across the real estate, or onto users desktops and/or phones. All the other machines that are required to build and run the same code and tests which you have on your machine also need to be set-up too.

**Automation Friendly**

While you might build a demo-able artefact on a developer’s machine, any release binaries or deployment packages will always be built in a “clean room” environment because a developer’s desktop is typically tainted with the results from experiments with ad-hoc code and tooling. While in the (not so) distant past we might have built and maintained the build and deployment pipeline servers, and dev, test, and production servers carefully by hand (aka snowflakes), those days should be long behind us. The rise in virtualisation and the purity gained from the “[immutable infrastructure](https://martinfowler.com/bliki/ImmutableServer.html)” movement means that the various steps in our once one-time set-up is now repeated, over and over again. This is even more apparent when the unit of delivery is an entire VM or container rather than just an application package. (Not seeing the similarities between how you build and test locally versus the entire delivery pipeline is a topic I covered way back in 2014 in [Building the Pipeline - Process Led or Product Led?](https://chrisoldwood.blogspot.com/2014/10/building-pipeline-process-led-or.html))

What this effectively boils down to is having an automation mindset. While the meme tells you to “automate _all_ the things”, and this is a venerable goal, I’ve seen the pendulum swing too far so prefer the more pragmatic _[Automate Only What You Need To](https://chrisoldwood.blogspot.com/2017/02/automate-only-what-you-need-to.html)_. Pedantry aside, the key point is that you think about how best to share the “process” you’re just about to discover. While it may be quicker for _you_ to use a UI to perform this particular task _now_, if there is any possibility that other people or _machines_ will need to perform it too, or it’ll be used as part of some automated process then it behooves you to spend a little bit of time looking at whether there is an automation-friendly approach which might be worth exploring instead.

**MVP – Minimum Viable Process**

Maybe you don’t have the time right now to write a nice little script that does “all the things” but have you considered whether there is an approach which at least leans into that? For example, instead of sharing a URL for downloading a tool that then has to be manually installed, see if it’s available via a package manager, which can later be scripted as part of the larger workflow.

While automation has always been Linux’s strong suit, Windows has improved hugely over the years such that many tasks which were once only accessible via the GUI can now be performed with a “one-liner”, if you ask your favourite search engine _the right question_. In essence instead of “how do I do X?” you need to append “from the command line” to access this Other World.

**Console-ation Prize**

Every time someone documents a process using a series of screenshots a kitten dies. Taking screenshots is labour intensive and far more likely to go out of date because vendors love to add new features and give their tools a facelift. In contrast a one-liner (or few lines) in a monospaced font on a wiki page is practically timeless in comparison and almost impossible for someone to mess up. It’s easy for someone else to then take on and turn into a script going forward.

You don’t need to be a DevOps kind of person to appreciate the simpler things in life, just someone who enjoys paying it forward when possible.


---
Original: <https://chrisoldwood.blogspot.com/2026/02/the-illusion-of-one-time-set-up.html>\
Copyright: Chris Oldwood 2026\
Published: Friday, 13 February 2026 at 09:05\
Labels: build, deployment, scripting, testing, tools
