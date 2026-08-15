## WCF Service Refusing Connections

I spent the majority of the day looking into a WCF issue with our system whereby the same request submitted in bulk against the same WCF service would fail indeterminately:-

>    System.ServiceModel.EndpointNotFoundException: Could not connect to http://localhost:8000/MyService. TCP error code 10061: No connection could be made because the target machine actively refused it 127.0.0.1:8000

  I had noticed by log inspection that _about_ 10 of the requests would succeed and the majority of the others would fail, this led me to believe that there was a default setting somewhere inside the WCF configuration that was having a throttling effect. When I finally got to the bottom of the issue I was somewhat annoyed with myself as it was a classic socket issue - not a WCF specific one. Therein I guess lies the problem with dealing with ever higher layers of abstraction – you begin to forget about the low-level details that underpin it ([and which eventually leaks through](http://en.wikipedia.org/wiki/Leaky_abstraction)). Fortunately my copy of [Programming WCF Services by Juval Lowy](http://oreilly.com/catalog/9780596526993) arrived the other day so I had a chance to do some reading to see what possible setting could be having an effect.

<u>ServiceThrottling “maxConcurrent*'”</u>

Lowy dedicates an entire chapter to service request throttling. There are 3 settings:- maxConcurrentSessions, maxConcurrentCalls and maxConcurrentInstances described for the [Service Throttling Behaviour](http://msdn.microsoft.com/en-us/library/system.servicemodel.description.servicethrottlingbehavior.maxconcurrentsessions.aspx) that allow the maximum load on each service to be controlled. The effects of these settings are dependent on the transport and concurrency mode of the service, but it’s all spelt out clearly in the book. The most interesting of the lot for me was the number of concurrent sessions - which [defaults to 10](http://www.danrigsby.com/blog/index.php/2008/02/20/how-to-throttle-a-wcf-service-help-prevent-dos-attacks-and-maintain-wcf-scalability/) under a Per-Session model which is what we are using.

I bumped the setting up to 1000 (way over the 100 needed to service my test harness load), but it had no effect. To humour myself I dropped all three settings to 1 to ensure it had some impact. It did. Oh.

<u>NetTcpBinding “MaxConnections”</u>

Back to the drawing board, or more accurately Google and the book. So convinced was I that I had discovered the cause that I never bothered to read on to the end of the chapter, where I would have discovered another setting that limits the maximum number of TCP connections for the binding:- [maxConnections](http://kennyw.com/work/indigo/181). This setting, which also has a [default of 10](http://msdn.microsoft.com/en-us/library/system.servicemodel.nettcpbinding.maxconnections.aspx), goes hand-in-hand with the previous settings as the smaller of it and maxConcurrentSessions becomes the effective throttle.

Once again I changed my service config only to become immediately disappointed as it also failed to have the desired result.

<u>NetTcpBinding “listenBacklog”</u>

Switching back to Google I read various posts about firewall issues which didn’t apply as I was running on the same machine. However I did start to pay closer attention to some of the settings that were being included in the App.config files. One in particular caught my eye – [listenBacklog](http://msdn.microsoft.com/en-us/library/system.servicemodel.nettcpbinding.listenbacklog.aspx). Anyone who has done any raw sockets programming will know that when you create a server-side socket and start listening on it you need to specify [how many pending connections](http://stackoverflow.com/questions/114874/socket-listen-backlog-parameter-how-to-determine-this-value) you’re willing to buffer. I quickly Googled again to see what the default value was – [yup another 10](http://msdn.microsoft.com/en-us/library/ee377061(BTS.10).aspx)!

I quickly plugged my ridiculous value into the .config file and bingo! This time it worked. So, a new twist on a very old problem…




---
Original: <https://chrisoldwood.blogspot.com/2010/03/wcf-service-refusing-connections.html>\
Copyright: Chris Oldwood 2010\
Published: Monday, 8 March 2010 at 21:30\
Labels: .net, c#
