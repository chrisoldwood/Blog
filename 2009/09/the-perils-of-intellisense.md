# The Perils of Intellisense

Work on my WMI library has been a little erratic during my recent time off, but I came across a bug recently which I lay squarely at the door of Intellisense. Of course, it's really a case of user error, but Intellisense lulls you into a false sense of security...

I had just started the library and added the initial unit test for creating a connection. I decided that I could get away with talking to the WMI service on the local machine as it's pretty much a standard piece of Windows technology and the unit tests would still run quickly. I started the implementation in the Connection class by adding the some private typedefs and members:-

`typedef WCL::ComPtr<iwbemlocator> IWbemLocatorPtr;</iwbemlocator>`\
`typedef WCL::ComPtr<iwbemservices> IWbemServicesPtr;</iwbemservices>`\
` `\
`IWbemLocatorPtr m_locator;`\
`IWbemServicesPtr m_services;`\

As one would expect, Intellisense did it's thing during the typing of the typedefs by showing me a list of types, and after typing just "IWbem", I could see the ones I wanted listed and so went with them.

In the implementation file I proceeded to write the Connection::open() method by declaring local variables for the underlying Locator and Connection using the typedefs declared earlier. The WMI Locator is the root object and is a singleton so requires no arguments during or after its construction. Once again Intellisense shows its productivity enhancing ability by showing me a list of relevant CLSID's after I type the initial portion, which I know to be "CLSID_Wbem". Seeing a CLSID that has 'Wbem' and 'Locator' in it's name I dutifully click it and get on with the hard part of actually writing the method logic - after all I "[Lean on the Compiler](http://www.amazon.co.uk/Working-Effectively-Legacy-Robert-Martin/dp/0131177052)" as it's much better at spotting errors than me...

`IWbemServicesPtr services;`\
`IWbemLocatorPtr locator(CLSID_WbemAdministrativeLocator);`\
`WCL::ComStr path(host + nmspace);`\

`HRESULT result = locator->ConnectServer(path.Get(), nullptr, nullptr, nullptr, 0, nullptr, nullptr, AttachTo(services));`\

`if (FAILED(result))`\
`throw Exception(result, locator, TXT("Failed to connect to the local WMI provider"));`\

`m_locator = locator;`\
`m_services = services;`\

This works a treat - my unit test passes. I can open and close a connection, so without delay I get on with writing the next set of tests and code to perform a simple WMI query.

After a few distractions, such as going on holiday, I decide to start implementing my WMICmd tool which is a simple command line tool for executing WMI queries. It will also do very nicely as a vehicle for thoroughly testing the WMI library. I get the shell of the application up and running and add support for running a query. The first query is the same as the unit test, and it works. I do some work on the output format and try a few other simple queries for good measure. It's working a treat and so I move onto more the more useful features like being able to query a remote computer. I add the command line support for providing a remote host and give it a whirl...

It fails. The error is "Invalid Parameter". I read the MSDN help and surmise that maybe you can't use 'localhost' as it suggests you use '.' for local connections. I need to allow a separate login and password to be provided anyway so I skip straight onto the full solution by refactoring the Connection::open() code to allow a username and password to be provided. I don't have any unit tests for this (for obvious reasons) but the other tests pass, so I know I haven't broken anything. It sill fails. Huh? "Invalid Parameter" again...

I guess that I've forgotten something COM security related, perhaps I need to call CoInitialiseSecurity() - but I'm sure I don't. I know it can't be the call to CoSetProxyBlanket() as that comes after. I pull Keith Brown's "Programming Windows Security" off the bookshelf in search of enlightenment. Nothing obvious. I try a few 'random tweaks' in the hope of getting a different error. Still nothing. I go over it in my head again and again - "Invalid Parameter" means I must have got one of the arguments to the ConnectServer() method wrong. So I carefully read the documentation a number of times and this raises a few questions about my assumptions in my implementation. But none of them are the cause.

I stare at the code for ages trying to work out what to do next. I compare it line for line with the example code in the WMI SDK documentation. Only I don't. I've been skipping the 'trivial' initialisation code before the call to ConnectServer(). Finally I decide to double-check the CLSID for the Locator COM object and I spot a difference... It's not CLSID_WbemAdministrativeLocator in the example, it's CLSID_WbemLocator! I make the relevant code change...

`IWbemServicesPtr services;`\
`IWbemLocatorPtr locator(CLSID_WbemLocator);`\

I run the unit tests. Good, they still pass. I run my WMICmd tool, and bingo, it now works. I go back and try 'localhost' to prove to myself that I was obviously wrong with my assumption about having to use "." for a local query, and of course it also works.

So, by accident, I've been instantiating the wrong COM object, and that object just happens to implement the interface I need - IWbemLocator! As [Harry Hill](http://en.wikipedia.org/wiki/Harry_Hill) would say "What are the chances of that happening?". I'm blaming Intellisense for the hair that I've torn out trying to fix this issue, but that's not exactly fair. I could have cut-and-pasted the code from the WMI documentation, and we all know how fallible documentation is. I'm sure the fact that I've implemented something like this before for a client some years ago lead me to become complacent. And the unit tests, which constantly passed, deflected me away from the existing code and instead lead me to believe I was missing something else. Useful though unit testing is, I need to remind myself that they are not a panacea.

I've not forgiven the Intellisense window yet, but at least we're on speaking terms again...


---
Original: <https://chrisoldwood.blogspot.com/2009/09/perils-of-intellisense.html>\
Copyright: Chris Oldwood 2009\
Published: Wednesday, 23 September 2009 at 16:54\
Labels: visual c++
