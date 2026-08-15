## WCF Weirdy – NetTcpBinding, EndpointIdentity and Programmatic Configuration

We are now using WCF for our inter-process communication (IPC) mechanism, and as you might expect the development and testing on a single machine worked a treat. However once we deployed it to our test environment in a proper remote client/server scenario it stopped working. I wasn’t involved in the main work, but as it appeared to be security related and I’ve done a fair bit in the past with DCOM and security I thought I’d see if I could lend a hand.

The architecture is (as [Juval Lowry](http://www.oreillynet.com/pub/au/741) describes in his [WCF Programming](http://www.amazon.co.uk/Programming-WCF-Services-Juval-Lowy/dp/0596521308) book) a classic Intranet setup, i.e. a client and server talking using the WCF NetTcpBinding and with all settings at their defaults. This meant that in our environment I expected it to pretty much mirror the run-of-the-mill DCOM model, except that we hadn’t got quite as far as running the service end under a “system” account yet – both client and server were still running under the same user account. The error we got from the client end was:-

`“A call to SSPI failed…The target principal name is incorrect”`\

The initial Google search for this error threw up a very useful post from [Scott Klueppel](http://offroadcoder.com/2009/10/29/NetTcpBindingAndSecurityNegotiationExceptionACallToSSPIFailed.aspx). The only problem was that we weren’t using configuration files, we were configuring the endpoints programmatically. Whilst I was googling my colleague ploughed through the MSDN documentation and found that using the constructor overload of EndpointAddress that takes an EndpointIdentity also seemed to do the trick:-

`EndpointAddress endpoint = new EndpointAddress(uri, EndpointIdentity.CreateSpnIdentity("MACHINE\ACCOUNT"));`\

This tied up nicely with what Scott said is his post about _needing an identity_, but not entirely, because he mentioned that an empty identity will suffice. However the MSDN docs and many other Internet posts go intro great detail about crafting a service name string and using [SetSPN](http://technet.microsoft.com/en-us/library/cc773257(WS.10).aspx) to publish it to Active Directory. Naturally he followed the official documentation and it worked. To humour ourselves we also tried an empty string and that worked too! In fact it didn’t matter what we passed as the string to CreateSpnIdentity() – it worked. This just seemed way too random for my liking so I dug a little deeper to see if I could find out why this was happening. After all, if the contents of the string don’t matter, why bother passing it? And although it may not matter now, will it later down the line when we’ve all forgotten about this episode? That’s not the kind of maintenance nightmare I want to be responsible for.

Fortunately I discovered the answer via a couple of MSDN articles about WCF and Authentication – [Overriding the Identity of a Service for Authentication](http://msdn.microsoft.com/en-us/library/bb628618.aspx) and [Service Identity and Authentication](http://msdn.microsoft.com/en-us/library/ms733130.aspx). The latter contained the following crucial note:-

>    “When you use NT LanMan (NTLM) for authentication, the service identity is not checked because, under NTLM, the client is unable to authenticate the server. NTLM is used when computers are part of a Windows workgroup, or when running an older version of Windows that does not support Kerberos authentication.”

  I’ve yet to work in an Enterprise that relies on Kerberos across the board. I’ve seen it used in some parts of my clients’ network* but by-and-large NTLM still lives. I did search for a utility that might help confirm my suspicions, but I didn’t find anything. I know it’s famous last words, but I don’t see any reason to doubt this as the answer.

Long term the whole SetSPN thing seems like the way to go, but it will complicate our deployment procedure so I wanted to see if the articles had any other useful nuggets that might guide us towards some middle ground. As a footnote to Scott’s advice the MDSN articles have this to say about empty Identity strings:-

>    <u>When SPN or UPN Equals the Empty String</u>

If you set the SPN or UPN equal to an empty string, a number of different things happen, depending on the security level and authentication mode being used:


* If you are using transport level security, NT LanMan (NTLM) authentication is chosen. 
* If you are using message level security, authentication may fail, depending on the authentication mode: 
* If you are using spnego mode and the AllowNtlm attribute is set to false, authentication fail. 
* If you are using spnego mode and the AllowNtlm attribute is set to true, authentication fails if the UPN is empty, but succeeds if the SPN is empty. 
* If you are using Kerberos direct (also known as "one-shot"), authentication fails. 

  We’ve temporarily gone for the first option and filed a JIRA task to revisit this before our deployment procedures need finalising. This also gives me more time to read up on the subject of WCF authentication. I own a copy of [Keith Browns Programming Windows Security](http://www.amazon.co.uk/Programming-Windows-Security-Developers-DevelopMentor/dp/0201604426) which has served me well, but it’s finally starting to look a little dated.



* It’s a good way of find out if your clock is in sync or not. I once investigated a bunch of authentication failures on some of our VMware test boxes and it turned out to be because the clocks had drifted outside the [5 minute window](http://www.cmf.nrl.navy.mil/ccs/people/kenh/kerberos-faq.html#syncclock) that Kerberos allows.


---
Original: <https://chrisoldwood.blogspot.com/2010/02/wcf-weirdy-nettcpbinding.html>\
Copyright: Chris Oldwood 2010\
Published: Sunday, 7 February 2010 at 20:43\
Labels: .net, c#
