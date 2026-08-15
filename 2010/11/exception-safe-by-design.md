## Exception Safe By Design

I’ve recently gone back to my simple [database query tool](http://www.cix.co.uk/~gort/win32.htm#pqt) to add a few essential usability features and like any legacy codebase there were a couple of surprises in store. Now, I’m not making excuses for myself, but most of the code is the best part of 10 years old and like any [journeyman](http://en.wikipedia.org/wiki/Journeyman) I’ve learnt a lot since that was written. Also the recent episodes of [Matthew Wilson’s](http://en.wikipedia.org/wiki/Matthew_Wilson_(author)) Quality Matters column in Overload (one of the [ACCU journals](http://accu.org/index.php/aboutus/aboutjournals)) focused on exception handing and so these two examples became even more prominent.

<u>Resource Management</u>

One of the new features I added was to properly support non-query type statements, i.e. INSERT/DELETE (it was originally written to be a query tool but it’s been useful to run ad-hoc SQL as well). This involved me digging into the ODBC facade and eventually I came across this piece of code:-

```
CSQLCursor* CODBCSource::ExecQuery(...)      ```
{ 
 CODBCCursor* pCursor = new CODBCCursor(*this);

```
 try ```
 { 
 ExecQuery(pszQuery, *pCursor); 
 } 
 catch (const CODBCException&) 
 { 
 delete pCursor; 
 throw; 
 } 
      
 return pCursor;       
}       


Now clearly you’ll have to put aside your disgust of [Hungarian Notation](http://ootips.org/hungarian-notation.html) for a moment and focus on the real issue which is the shear verbosity of the code. It’s also wrong. On the one hand I’ve been a good boy and only caught what I can knowingly recover from (a specific `CODBCException`\ type exception) but I’ve also missed the point that any _other_ exception type will cause a memory leak. Clearly I should have used catch(…) because the exception type is irrelevant in this case.

Only I shouldn’t, because the try/catch block is entirely unnecessary. Although _now_ I’m firmly in the camp that believes [RAII](http://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization) is probably the single most important idiom within C++, I obviously wasn’t then. I try really hard to write code that ensures there are no memory leaks and I use tools like the [Debug CRT Heap](http://msdn.microsoft.com/en-us/library/974tc9t1(VS.80).aspx) in Visual C++ and [BoundsChecker](http://en.wikipedia.org/wiki/BoundsChecker) to point out my mistakes. And yet this piece of code highlights how hard it is to do that, especially in the face of exceptions; if you don’t have 100% code coverage in your testing it’s just too easy to miss something. What is all the more ridiculous though is that the correct solution is less work anyway:- 

```
CSQLCursor* CODBCSource::ExecQuery(...)      ```
{ 
 Core::UniquePtr<CODBCCursor> pCursor(new CODBCCur…);

` ExecQuery(pszQuery, *pCursor);`\

```
 return pCursor.detach();      ```
}

Assuming I can make no changes to the method signature this ticks the box of being exception safe by design. The `Core::UniquePtr`\ smart pointer class is analogous to [boost::scoped_ptr](http://www.boost.org/doc/libs/1_39_0/libs/smart_ptr/scoped_ptr.htm)``\ which ensures single ownership until it’s given away at the end. But there’s still a bad code smell which is that the method returns a bald pointer so the callee could still leak it. What we should return instead is the smart pointer object so that we explicitly transfer ownership to the callee:-

```
Core::SharedPtr<CSQLCursor> CODBCSource::ExecQuery(..)      ```
{ 
 Core::SharedPtr<CODBCCursor> pCursor(new CODBCCur…);

` ExecQuery(pszQuery, *pCursor);`\

```
 return pCursor;      ```
}

One unpleasant taste in the mouth is that because of the change in scope we cannot just return a `Core::UniquePtr`\ because that would require temporarily copying the object[*] so instead we use a smart pointer that allows shared ownership – `Core::SharedPtr`\. Funnily enough this [transfer of ownership from caller to callee](http://www.gotw.ca/publications/using_auto_ptr_effectively.ht) is actually right up `std::auto_ptr`\’s street and for the knowledgeable this would be preferable from a performance perspective. But sadly you end up worrying about the caller and whether they know the pitfalls of `auto_ptr`\ and so perhaps you go back to the safer option.

<u>Side Effects</u>

Another feature I wanted to added was to avoid requesting credentials when the connection doesn’t need them and this put me right into the client method responsible for opening a new database connection:-

```
void CAppCmds::Connect(. . .)      ```
{ 
 try 
 { 
 OnDBDisconnect(); 
 . . . 
 App.m_oConnection.Open(strConnection); 
 . . . 
 } 
 catch(CSQLException& e) [#] 
 { 
 App.AlertMsg(TXT("%s"), e.m_strError); 
 OnDBDisconnect(); 
 }       
}

This piece of code I found puzzling because I couldn’t obviously see why it called `OnDBDisconnect()`\ both at the start of the method and also in the exception handler as the connection will either open successfully or throw, in which case we had already cleaned up earlier. So I looked at what `OnDBDisconnect()`\ did to see why it might be necessary:-

```
void CAppCmds::OnDBDisconnect()      ```
{ 
 if (App.m_oConnection.IsOpen()) 
 App.m_oConnection.Close(); 
      
 App.m_pCurrConn = NULL; 
 . . .       
}

Nothing earth shattering there – just run-of-the-mill cleanup code. And so I went back to the `Connect()`\ method and looked more closely. And then I spotted it:-

```
 OnDBDisconnect(); ```
 . . . 
 App.m_pCurrConn = App.m_apConConfigs[nConnection]; 
 . . . 
 App.m_oConnection.Open(strConnection);

There are side-effects that occur between the point when the previous connection is closed and when we attempt to open a new one. A quick scoot back through the version control repository[+] to see what changes have been made to this method and I see that it was checked in as a fix for another problem after failing to open a connection. Clearly my mindset was “fix the broken exception handling” instead of “fix the poorly written method”. The first rule of writing exception safe code is to [perform all side-effects off to one side](http://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Copy-and-swap) and then use exception safe mechanisms like `[std::swap()](http://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Non-throwing_swap)`\[^] to “commit” the changes.

So, for my example code above we need to introduce some temporaries to hold the unstable state, perform the Open and then persist the new state:-

```
 OnDBDisconnect(); ```
 . . . 
 Core::SharedPtr<…> pConfig(App.m_apConConfigs[…]); 
 Core::SharedPtr<…> pConnection(new CODBCConnection); 
 . . . 
 pConnection.Open(strConnection); 
 . . . 
 App.m_oConnection.swap(pConnection); 
 App.m_pCurrConn.swap(pConfig);

Taking a cue from the preceding section about resource management I have used my `Core::SharedPtr`\[$] smart pointer type as the connection will live on after this method returns. The catch handler remains but only to report the error message to the user, no cleanup now needs to be performed.

But we can do even better. If we take a closer look at what happens as a result of using swap() we see that the call to `OnDBDisconnect()`\ may actually be superfluous. In fact it may be better not to do it all. The call to `swap()`\ effectively means that the new connection will live on as `App.m_oConnection`\ and the old one will get destroyed at the end of the scope (the try/catch block). Now if we look at what `OnDBDisconnect()`\ does:-

```
void CAppCmds::OnDBDisconnect()      ```
{ 
 App.m_oConnection.Close(); 
 App.m_pCurrConn = NULL;

```
 UpdateScriptsMenu(); ```
 UpdateUI();       
}

It closes the existing connection and resets `m_pCurrConn`\ (these both now happen automatically near the end of `Connect()`\) and it resets the UI. If we look at the tail end of the `Connect()`\ method we see this:-

```
 UpdateScriptsMenu(); ```
 UpdateUI();

What this all means is that if an exception _is_ thrown then the user loses their current connection as well. If we perform all the work off to the side and don’t modify any state (i.e. don’t call `OnDBDisconnect()`\) up front then the user at least gets to keep their current connection as a consolation prize. If the new connection does work then we just save the new state and let the old one disappear at the end of the try/catch block. Is that just being clever or an attempt to write the simplest code possible? A topic for another day…



[*] I need to go back and read up on the new `[std::unique_ptr](http://www.devx.com/cplus/10MinuteSolution/39071/1954)`\ type in C++0X as I’m sure this was designed for this kind of scenario – and also the `std::vector<std::auto_ptr<T>>`\ gotcha.

[#] Using an exception to signal failure when opening a database connection falls right into the [“Using Exceptions For Flow Control”](http://c2.com/cgi/wiki?DontUseExceptionsForFlowControl) category in Matthew Wilsons Quality Matters column and would almost certainly fall into the real of “Not Exceptional” for Kernighan & Pike too. In this case [I’m inclined to agree](http://chrisoldwood.blogspot.com/2010/09/whats-exceptional-depends-on-context.html) and will be adding a `TryOpen()`\ method at the next opportunity.

[+] Lone developers need Source Configuration Management (SCM/VCS) too. At least, if you want to perform any [software archaeology](http://en.wikipedia.org/wiki/Software_versioning) to avoid regressions, that is.

[^] It would be great if `std::swap`\() had a ‘nothrow’ <u>guarantee</u> as that would make it excellent for this idiom. But I’m not sure it is guaranteed by the standard - is it just a convention like not throwing exceptions from destructors? My Google skills found lots of chatter but no quote citing chapter & verse.

[$] Naturally you wouldn’t use the full type name everywhere but use a typedef instead. Given how prevalent the use of the `SharedPtr`\ type is (especially with types stored in containers) I tend to [add a typedef](http://stackoverflow.com/questions/2717436/whats-your-convention-for-typedefing-shared-ptr) right after a new entity class declaration for the smart pointer wrapper, e.g. `class Xxx { . . . }; typedef Core::SharedPtr<Xxx> XxxPtr;`\


---
Original: <https://chrisoldwood.blogspot.com/2010/11/exception-safe-by-design.html>\
Copyright: Chris Oldwood 2010\
Published: Saturday, 27 November 2010 at 10:28\
Labels: c++
