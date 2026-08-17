## Codurance AI Hackathon

_This is quite a long post (15 mins) and if you’re only interested in my final musings, and not the day itself, just skip to the last two sections._

  Last Saturday I got to attend an event at Codurance’s offices in London around the use of AI based tooling to aid software delivery. I did not have much experience with these kinds of tools, in part because my current client uses their own in-house programming language [1]. Hence, my experiences to date have been limited to some messing around in VS Code with Copilot on some fairly simple C# katas.

  **Event Format**

  There were about twenty of us spread across a range of ages but, generally speaking, all fairly experienced programmers. We were split into two teams (A and B) and got to tackle two problems – one in the morning, and another in the afternoon. We got to spend 2 hours on each problem, with one team allowed to use AI tooling and the other not. Then, in the afternoon, we switched roles so that both teams got to try with and without AI assistance across the day. We also worked in pairs or threes. Both problems were very similar: effectively a web based service consisting of a backend API, that used some kind of database, and a frontend UI. If you’re thinking: an online clothing store / IMDB, then you’d be pretty close to the two exercises.

  There were some questions about AI in the context of search engines as Google, for instance, puts its AI spin on the result. This was clarified as meaning no _direct_ use of AI tooling for code generation and tooling suggestions. The non-AI teams had to rely on search engines / Stack Overflow, blog posts, docs, etc.

  Another question (from yours truly) was about how much of a “hackathon” this really was, or whether we should approach it more like we were building something for real. The answer was that we should try and treat it more like a real project than something discardable like a prototype.

  **The Non-AI Exercise**

  I was in Team B, and for the morning session we weren’t allowed to use any AI tooling for our online clothing store. Ironically, trying to disable it to avoid biasing proved non-trivial, while still leaving the traditional IntelliSense and refactoring tools enabled. (Where does one end and the other begin…) 

  Our group of three had assembled because we all had C# in common. I’ve not done any non-trivial web UI work for twenty years, and it’s also been 5 years since I’ve done any production C# [1] so I wasn’t exactly up on the in-vogue architecture choices. Consequently I left it to the other two to suggest a Blazor based approach, which suited me as I had at least done _some_ work with Razor 8 years ago, so was familiar with the underlying concepts.

  The dataset we were given was hosted by [Kaggle](https://www.kaggle.com/) and came as a ZIP file that included a CSV file and some images. Trying to obtain this without having to sign-up to their service was another small barrier, eventually overcome when I unearthed the CURL instructions which thankfully didn’t require any authentication.

  We all agreed to start by creating a walking skeleton that was a simple Blazor app. With some guidance from my colleagues, I used VS Code to knock that up and we were off with a basic web page in the browser.

  We then looked at the dataset in a little more detail to see what shape it was in, and there was some discussion about next steps, such as pulling that entire CSV file in. That came off the back of the initial discussion about the model we should use to back the service. Yes, the categories aspect was an interesting modelling problem but I wanted to just to create a simple model with ID, Description, and Price, then hardcode a list of three items, and get that visible on the page to complete our skeleton. That idea was accepted and we got that working quite quickly.

  At this point we all got a bit nervous as we hadn’t got any tests in our skeleton. Luckily one of us already had some experience with bUnit (a testing framework for Blazor), so we managed to get a test project and initial test in place relatively easily that checked for one of our hard-coded items being on the page.

  This paved the way for starting to add new features in a test-first manner and, with what time we had left of the two hours, we started to work on the test for the product details page which comes from selecting an item on the products page. We had the failing test in place when the metaphorical whistle blew for half-time.

  **The AI Assisted Exercise**

  After lunch, where we had a chance to mingle and chat to others about their experiences so far, we tackled the IMDB clone with the addition of AI assistance.

  _We_ chose to remain in the same group, while others paired up with different people. We also thought it would be useful to use the same stack as that seemed like a useful comparison, although we did switch laptop and consequently from VS Code to JetBrain’s Rider. Once again there was some fiddling about with settings.

  None of us had ever tried creating an entire project from scratch using an AI tool so we threw the README into the chat window prefixed by a sentence that asked it to create the entire solution and projects using Blazor as the stack.

  The chat window started spewing out snippets of code which we then started to look at. I think we were all quite surprised about how plausible the code looked. We had some minor concerns about some of its design choices but it all looked pretty sane as a starting point. We hadn’t asked it to generate any tests, preferring instead to let this become an additional change later.

  Trying to turn the suggested code in the chat window into an actual solution structure in Rider turned out to be our first time-sink. The UI was a little confusing and the laptop owner hadn’t toggled a setting which we later discovered allowed it to automatically create the files itself. Instead, to make progress in the meantime, we ended up creating the basic solution and project files ourselves, just like before. By the time we found the necessary setting we already had that aspect in place. However, once we enabled it we could at least take the suggestions for the model and Razor pages from the AI output.

  This was the point when we discovered what looked plausible wasn’t entirely correct. For example, the code comment suggesting the relative path of the file didn’t match the file it created and it didn’t quite follow the Blazor convention. Hence, we moved a couple of files to follow the expected layout.

  However, that said, when we built the code it worked first time and the web page appeared and looked totally sane. One of us remarked immediately that just getting the Bootstrap (UI) set-up right can be a real pain in practice and that alone was a real blessing.

  Once we tried to interact with the page though we found it didn’t work. Cue the next time-sink, which was getting the filter feature to actually work. Naturally, we asked the AI tool what was wrong and it _very confidently_ told us what was wrong and how to fix it. But, when I looked closely at the fix I pointed out that it had just re-written the existing code in a more complex manner but left it functionally the same. We went with it anyway but of course it didn’t work.

Another pointless suggestion from the AI tool about how to fix _that_ didn’t inspire confidence at this point, so we resorted to using the debugger to see if the code was even being triggered. It wasn’t, although inspecting the DOM in the browser looked correct. I had raised a question earlier about session state management which didn’t initially sink in until a little later when our Blazor expert realised the page was missing some “interactive server” declaration at the top of the Razor page. Once that was added things started working.

  It’s hard to know if the impedance mismatch was because we manually created the project files and the AI generated ones _would_ have been correct for the code _it_ was producing, or if it would still have been wrong.

  Sadly, all this friction meant we had little time left to really explore the AI tool in the context of making changes to the existing codebase to add new features or refactor the code. We asked it a few cursory questions to see what it would suggest and it would always reply in a very confident way but would include changes that would revert some of our changes we made during our debugging attempts. I don’t know if that was a result of us not resetting the “context window” because those changes were ones it had originally suggested right at the beginning.

  **Reflections on the Experience**

  First up, I don’t know about how the others in my little group felt, but _I_ was woefully underprepared for this day. With only two hours for each exercise we should have been in a position to hit the ground running and I just didn’t have enough experience with configuring or using the AI tool to make the most effective use of the little time available for the exercises.

  Related to that, the problem domain wasn’t something I have any real experience of either. While this might have been useful for the “AI as a learning tool” aspect, I’m not sure it helps when trying to compare the two approaches.

  With any day like this where you are working with other people you’ve never met before some element of “team dynamics” is going to distort the picture. My preference is to work in small steps, _really_ small steps, and deciding whether to assert that or “go with the flow” is a much bigger side-quest than in an established team where you already know everyone’s favoured approach and politeness levels are well calibrated.

  When you only have two hours there is a clear conflict between doing what you really would on a real project versus trying to explore the goals of the exercise. For example, due to my C# being a little rusty I wrote a classic POCO style class for the model instead using the more modern record types in C#, which I was aware of but had never actually used in practice. This prompted a short conversation about our feelings around immutability and anaemic models which is something a real team needs to resolve, but we simply don’t have time for that despite the “not really a hackathon” premise. Likewise, I have opinions on naming, design, etc. which I just have to put to one side this time.

  However, I forgot this when writing our second test (in the first exercise) and naturally wrote a test name which opened a discussion about whether we were testing the navigation aspect or the state of the resulting page. Again, I think the approach to testing – the _kinds_ of tests we want to write – is important in a real project. It would have been interesting to see what kinds of tests the AI tool would have generated as I see that being touted as a big use case, but given how poorly tests are commonly written I’m sceptical it has the corpus available to have “good taste”.

  As I’ve already said above, I think we were all impressed with how much the tool churned out from the README, but are also aware that online stores and review sites are a well trodden path, with potentially a lot of example code to draw from. Other attendees got a lot further than we did, with one pair (using NodeJS) completing the exercise and having time to make up new features! In the post-exercise discussion one of that pair questioned how it would fair for, say, some embedded software where there are far less examples to train on. 

  The over confidence in the replies when we were trying to fix the code were scary. I think we were all sceptical and seeing it behave like this did not endear itself to us at all. Plus, trying to revert our code changes and only change the code it should _need_ to when adding new features went against our agreed approach of only changing one thing at a time. Maybe _we_ are being too rigid here and should cede more control in those early moments before we “hit production”?

We only got to work on producing code _we_ had helped to write. It might have been interesting to have swapped at half-time and continue working on one of the _other_ team’s AI generated codebases to see what it might be like to pick-up one of those as that is surely the future situation we’ll be finding ourselves in fairly soon.

  **Epilogue**

  I really enjoyed the day and am most grateful for the experience, but I don’t think I contributed that much personally to the experiment because of my current lack of knowledge around using these kinds of tools in practice.

  I’ve only used Copilot integrated into VS Code on my laptop but would like to try some others based on the other group’s experiences, as long as they have tight integration into an IDE. I like baby steps and an “always be ready to ship” mentality which I’d feel uncomfortable giving up at this point in time. This is more like enhanced auto-complete based on what I’m already typing directly in the code than trying to write external prompts in a separate window which feels like unnecessary context switching when writing code.

  Once I _am_ more used to these new tools I’d like to try the exercise again and go “all in” and see what it chucks out, and then spend some significant time trying to work with that codebase to get a better feel for how much the AI tool wants to change each time. Automating the boilerplate stuff has to be worth exploring, but the question is how much leash to give it?

  There is definitely a difference between building a disposable prototype and making changes in a large mature codebase. I think I’ve got more of a taste of the former now (coupled with my own fumblings beforehand) but I’m going to need more time to explore how this fits in with the latter as that’s my day job. At least I feel a lot more informed now than I did a week ago.

  

  [1] My client has their own pure, functional, dynamic language which is used for much of the company’s reporting, scripting, and general gluing together of business workflows.




---
Original: <https://chrisoldwood.blogspot.com/2025/05/codurance-ai-hackathon.html>\
Copyright: Chris Oldwood 2025\
Published: Friday, 2 May 2025 at 09:42\
Labels: development process, meetup, tools
