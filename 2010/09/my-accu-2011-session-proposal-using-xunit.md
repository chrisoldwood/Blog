## My ACCU 2011 Session Proposal - Using xUnit As a Swiss Army Testing Toolkit

I’ve decided to be brave and submit a session proposal for next year’s [ACCU Conference](http://accu.org/index.php/conferences/accu_conference_2011). I know if I get accepted that means I’ll have to curtail the relentless late nights in the bar – at least until I’ve given my presentation. Anyway, the catalyst for my proposal was my blog back in March titled [Integration Testing with NUnit](http://chrisoldwood.blogspot.com/2010/03/integration-testing-with-nunit.html). Not long after posting that I watched [Paul Grenyer](http://paulgrenyer.blogspot.com/) give a [presentation](http://accu.org/index.php/accu_branches/accu_london/accu_london_march_2010) to the London branch of the ACCU that touched on similar ground. My session is intended to take the idea further still and cover use of the xUnit style in other areas where perhaps custom test scripts and tools might have been written such as API exploration and verifying external systems.

<u>Session Summary</u>

Title: Using xUnit As a Swiss Army Testing Toolkit      
Type: Tutorial/Case Study       
Duration: 90 minutes       
Speaker: Chris Oldwood

<u>Speaker Biography</u>

Chris started out as a bedroom coder in the 80s writing assembler on 8-bit micros; these days it’s C++ and C# on Windows in big plush corporate offices. His career has covered both shrink wrapped applications and in-house systems with the past 5 years focusing on grid-based distributed systems in the Finance industry. When not attached to a keyboard and screen he has a wife and four children to entertain, dips his toe in the local swimming pool and provides the commentary for the annual Godmanchester Gala Day Duck Race.

<u>Session Description</u>

Modern Unit Testing practices act as a conduit for improved software designs that are more amenable to change and can be easily backed by automation for fast feedback on quality assurance. The necessity of reducing external dependencies forces us to design our modules with minimum coupling which can then be leveraged both at the module, component and subsystem levels in our testing. As we start to integrate our units into larger blocks and interface our resulting components with external systems we find ourselves switching nomenclature as we progress from Unit to Integration testing. But is a change in mindset and tooling really required?

The xUnit testing framework is commonly perceived as an aid to Unit Testing but the constraints that it imposes on the architecture mean that it is an excellent mechanism for invoking arbitrary code in a restricted context. Tests can be partitioned by categorisation at the test and fixture level and through physical packaging leading to a flexible test code structure. Throw in its huge popularity and you have a simplified learning curve for expressing more that just unit tests.

Using scenarios from his current system Chris aims to show how you can use a similar format and tooling for unit, component and integration level tests; albeit with a few liberties taken to work around the inherent differences with each methodology.


---
Original: <https://chrisoldwood.blogspot.com/2010/09/my-accu-2011-session-proposal-using.html>\
Copyright: Chris Oldwood 2010\
Published: Monday, 27 September 2010 at 23:12\
Labels: ACCU, personal
