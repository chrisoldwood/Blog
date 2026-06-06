# Adjusting to the C#/.Net Ecosystem

So I’ve been on The Dark Side (as my C++ biased ex-work colleagues call it) for a little under 2 months now. Most of the first few weeks were spent going over the potential architecture and doing a little up-front modelling to decide what areas, if any, needed prototyping. Now I’m finally into the real thrust of C# development and as a consequence various new names have entered my consciousness. The old stalwarts of the C++ world such as Andrei Alexandrescu, Scott Meyers and Herb Sutter have been consigned “To Tape” to make room for the new kids such as [Jon Skeet](http://msmvps.com/blogs/jon_skeet/default.aspx) (and Tony the Pony, natch), [Bill Wagner](http://srtsolutions.com/blogs/billwagner/), [Udi Dahan](http://www.udidahan.com/) and [Ayende Rahien](http://ayende.com/blog). The first two are authors of books I was advised to seek out as they seem to be treading the same path as Scott Meyers and Herb Sutter, but in the C# space. Udi is someone who’s articles I have read on previous occasions (such as in MSDN Magazine) and works in a not too dissimilar field. Finally, Ayende has a blog that seems well read. It was his opinions on Unit Testing that caught my eye during the height of the Duct Tape Programmer catfight. I’m hoping his blog will give me further leads and a good background in the popular tools, technologies and sites that a long-standing C# dev will have already acquired.

Although C++ (and Java which I’ve also dabbled with on occasion) is pretty similar to C#, there are a number of gaffs I’ve made, and continued make, right out of the stalls. The most common so far is forgetting to actually allocate the object and consequently being assaulted with a null pointer exception the moment I run a unit test,

`Dictionary<string, string> configuration;`\

In C++ this would work, but in C# I have to remember to do this:-

`Dictionary<string, string> configuration** = new Dictionary<string, string>**;`\

Well, not quite, because as the compiler will _then_ remind me, I have to append parenthesis, even though I’m not providing any arguments:-

`Dictionary<string, string> configuration = new Dictionary<string, string>**()**;`\

I seem to have been fortunate enough to have started C# at v3.0, with Generics already well established. I don’t pity those poor souls who had to cope with the v1.0 collections. Anyone, such as myself, who had the misfortune to use MFC (or some of the other big frameworks) before the days of a C++ compiler that supported Templates will feel your pain. Actually there are probably many in the embedded C++ world who are still suffering…

Nice though Generics are (and I have only used the collections so far) what I really, really miss is to be able to Typedef an instantiation* to avoid the DRY (Don’t Repeat Yourself) spots. Of course, in C++ the template type names pervade the code base because of the iterator model; and not using typedefs is asking for impenetrable code – especially once you have nested containers or introduce std::pair.

The other main area that I’ve been getting used to is the tool chain. Naturally we’re using Visual Studio 2008, which I’m somewhat comfortable with having used it since v1.0, in fact I still use the Visual C++ 1.0 key bindings (although they call them Visual C++ 2.0 in the UI). For unit testing we’re using NUnit which is a pleasure after many years of macro abuse. The same goes for the mocking framework – Rhino Mocks. I’ve only ever hand-rolled mocks before. Well, technically most of them were just stubs because hand-rolling is so tedious. There is a list of other stuff which I’ve yet to get my teeth into that completes the full development process, such as, CruiseControl, FxCop, StyleCop, NCover etc. When it comes to C# (and Java is probably the same) there is a plethora of tools out there, much of them Open Source, and trying to compare them and make an informed choice about what to pick for the long road ahead is difficult. The main barrier to those kind of tools in the C++ world has historically been cost as a recent comment to an earlier post of mine will testify.

Refactoring is something that C# lends itself to very nicely and although I’ve only briefly played with these features in Visual Studio 2008 (and have a Resharper license waiting for me) I feel I’m going to enjoy using them. I’m holding off on Resharper until I know how to do things myself first as not every client uses the same tools and Visual Studio itself may satisfy most of my needs. One prevalent C# practice that is frowned upon in C++ is the use of ‘using’ directives** to bring entire namespaces into scope and Resharper appears to promote this practice. The reason is no doubt due to the different use of namespaces in C#. They tend to be much longer (unlike std and boost) and partitioned much smaller (again unlike std) so the chance for conflict is presumably far less. It still feels dirty.

Although I’ve only scratched the surface of the language and tools so far, I’m already beginning to feel at home.



*I know they aren’t called instantiations in C# and that the compilation model is different to C++, but the name for what a generic is where the closed types are known escapes me at present. Sorry Jon, all I can remember from your book at the moment is the names Open and Closed as referring to the types at _definition_ and _instantiation_.

**That’s the C++ name, I’m not sure of the terminology of using declarations and directives in C# yet. I shouldn’t have brought my 3G dongle with me!


---
Original: <https://chrisoldwood.blogspot.com/2009/11/adjusting-to-cnet-ecosystem.html>\
Copyright: Chris Oldwood 2009\
Published: Thursday, 12 November 2009 at 22:51\
Labels: c#, personal
