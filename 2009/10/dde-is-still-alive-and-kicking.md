# DDE Is Still Alive & Kicking

Dynamic Data Exchange (DDE) is an ancient inter-process communication (IPC) mechanism carried over from the 16-bit Windows days. Post millennium Windows programmers are probably more used to a diet of COM, but there still seems to be life in the old dog yet. Maybe there are less people around to answer questions on DDE, or perhaps the other old timers are ignoring them in the hope they'll go away because I seem to have had more emails on the subject this year than ever. 

I presume the reason the questions are still coming my way is because I have a number of freeware tools on [my website](http://www.cix.co.uk/~gort) aimed at working with DDE Servers that are still actively supported:-


* [DDE Query](http://www.cix.co.uk/~gort/win32.htm#ddequery) is my oldest tool and is a GUI based utility for sending requests and creating advise loops on items. It was written as the main test harness for my [DDE library](http://www.cix.co.uk/~gort/win32.htm#ncl).
* In contrast [DDE Command](http://www.cix.co.uk/~gort/win32.htm#ddecommand) is my most recent addition and is the console based counterpart to DDE Query. It also provides the ability to invoke XTYP_EXECUTE transactions.
* In between the two is my [DDE COM Client](http://www.cix.co.uk/~gort/win32.htm#ddecomclient) - an automation compatible inproc COM component that can be used as a DDE Client for scripting scenarios, such as VBScript.
* The final, and second oldest utility I provide, is a [Network Bridge](http://www.cix.co.uk/~gort/win32.htm#netdde) to allow DDE Servers to be accessed remotely. It is entirely transparent to the client and server, unlike the built-in Windows NetDDE service.

These all use my own C++ DDE library which in turn is based on the [DDEML](http://msdn.microsoft.com/en-us/library/ms648712(VS.85).aspx) C-API library that Microsoft provides. Under the covers DDE is just a message based protocol that uses Windows messages to encapsulate a connection between two applications – known as a Conversation. Data is passed by allocating it with the old GlobalAlloc() API, and the format is determined by either using a standard clipboard format, such as CF_TEXT or a custom one via RegisterClipboardFormat(). The fact that it is message based is also its biggest limitation as it means you cannot share data between machines – you can't even share data across desktops on the same machine. The only book I came across on the subject was [Ole 2.0 and Dde Distilled by Al Williams](http://www.amazon.com/Ole-2-0-Dde-Distilled-Programmers/dp/020140639X), but it covers the topic pretty thoroughly.

Before working in finance the only time I had come across DDE was when writing an installer back the mid 90's. Under Windows 3.x you used DDE to communicate with Program Manager (the shell that today is known as Explorer) so that you could create a "Program Group" and the icons for your application. You can still see this legacy today if you fire up DDE Query and use the "Server | Connect…" option, where you will spot a server called PROGMAN with a single topic also called PROGMAN. If you open this conversation and request the item "Accessories" you will be shown a CSV formatted text block with the programs from the Accessories Start Menu folder.

Once I started working in finance I discovered that Excel was the traders tool of choice. Excel can pull data from a number of sources, but the legacy option for real-time data was DDE. The big providers like Reuters, Telerate & Bloomberg all provided tools to allow you to feed their financial data into a spreadsheet and the in-house software we developed followed the same architecture. Although COM was probably Microsoft's promoted technology, DDE felt far simpler to implement.

These days I don't work with that kind of real-time feed, but the questions I do get on DDE always seem to have [RIC](http://en.wikipedia.org/wiki/Reuters_Instrument_Code)'s in the examples, so I guess that it's the financial industry that is keeping this prehistoric mechanism alive.


---
Original: <https://chrisoldwood.blogspot.com/2009/10/dde-is-still-alive-kicking.html>\
Copyright: Chris Oldwood 2009\
Published: Monday, 19 October 2009 at 23:40\
Labels: 16-bit windows, history
