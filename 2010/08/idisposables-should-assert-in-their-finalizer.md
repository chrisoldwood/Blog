## IDisposable’s Should Assert In Their Finalizer

Paradoxically[*] I’m finding that C# makes resource management much harder than C++. In C++ life is so much easier because you always have to deal with resource management and [RAII](http://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization) is the tool that makes it a no-brainer – you either use stack based variables or heap allocated variables and a smart-pointer class such as scoped_ptr/shared_ptr. C# on the other hand makes resource management ‘optional’ through the use of the IDisposable interface[%].

<u>What Is and Isn’t Disposable?</u>

And that is my first problem, you don’t always know what does and doesn’t need disposing – you have to go and find out. Of course IntelliSense can help you out here a little but it still means checking every object to see if it has a Dispose() method[#]. The other alternative is to hope you get it right and rely on a static analysis tool like [FxCop](http://en.wikipedia.org/wiki/FxCop) to point out those ‘occasional’ mistakes. Personally I’ve yet to get anything really useful out of FxCop outside the usual stylistic faux pas’ which seems to be more the domain of [StyleCop](http://code.msdn.microsoft.com/sourceanalysis).

<u>IDisposable is Viral</u>

OK, that’s a little harsh on FxCop as I’m still learning to use it effectively. But after years of using C++ tools like [Lint](http://www.gimpel.com/) and [BoundsChecker](http://en.wikipedia.org/wiki/BoundsChecker) to watch my back I was more than a little disappointed. It does seem to point out if I aggregate a type that needs disposing and I haven’t implemented the Dispose pattern, which is nice. However Dispose() is like ‘const correctness’ in C++ - it’s viral - once you start correctly applying IDisposable to your types it then mushrooms and you now need to fix the types that aggregated those and so on.

<u>Should Interfaces Inherit IDisposable?</u>

This leads me to my first question – should interfaces inherit from IDisposable if you know that at least one implementation needs it? On the face of it the answer seems to be no as disposing is purely an implementation detail; but the whole point of interfaces is to avoid ‘programming to an implementation’. If the answer _is_ no then the moment you cast down to an interface you hide the disposing behaviour. COM essentially has to deal with the same problem and its solution is to make AddRef() and Release() a fundamental requirement of every interface. Of course C# has [RTTI](http://en.wikipedia.org/wiki/Run-time_type_information) built in through the use of the ‘as’ and ‘is’ keywords and so you can always _attempt_ a cast to IDisposable from any other interface. However surely this way lies madness as your code would be littered with seemingly random ‘usings’ just in case an implementation later needed it. Here’s an example where this issues has cropped up most often to date…

We are using the [Gateway Pattern](http://martinfowler.com/eaaCatalog/gateway.html) extensively in our middle tier services to talk to other systems and so the gateway implementation often requires a WCF proxy which requires calling Close() (or a Socket, database connection etc). So, do I expose the disposing requirement through the gateway interface?

```
```
public interface ITradeGateway : IDisposable          ``````
{           
. . .           
}           
        
```
public class TheirBackEnd : ITradeGateway        ```
{         
. . .         
}

…or just implement IDisposable on the concrete type?

```
public interface ITradeGateway      ```
{       
. . .       
}       
```
     ```
public class TheirBackEnd : ITradeGateway, IDisposable       
{       
. . .       
}

In my mind the first is more ‘discoverable’ than the second and it gives any static code analysis tools a fighting chance in pointing out where you might have forgotten to call Dispose(). Some might argue that at the point of creation you know the answer anyway as you have the concrete type so why does it matter? Well, I tend to wrap the creation of these kinds of services behind a factory method that returns the object via the intended interface so that you are not inclined to rely on the concrete type unnecessarily:-

```
public static TradeGatewayFactory      ```
{       
 public ITradeGateway CreateTradeGateway()       
 {       
 return new TheirBackEnd();       
 }       
}

Most of our factory methods are not quite this simple as they tend to take a configuration object that further controls the construction so that they can hide whether the ‘service’ is hosted in-proc (which is useful for testing and debugging) or remotely via a proxy[+].

<u>Does It Matter If You Forget?</u>

I mostly work on distributed systems where scalability and reliability are major concerns and perhaps I’m being overly pessimistic about the memory consumption of my services but I think it’s important that for certain kinds of resources that their lifetime is managed optimally[$]. At the moment I’m dealing with a managed wrapper over an in-house native library that is used to manipulate the key custom data container that the organisation traffics in. The underlying native implementation uses reference-counted smart pointers for efficiency and naturally this has leaked out into the managed wrappers so that many aspects of the API return objects that implement IDisposable. In fact it’s all too easy to use one of the helper methods (such as an index property) and find yourself leaking a temporary that you didn’t know about and bang goes your careful attempts to control the lifetime of the container, e.g.

```
// Good. ```
using (var section = container.GetSection(“Wibble”)) 
{ 
 var entry = section.Value; 
 . . . 
 } 
      
 // Leaky. 
 var entry = container[“Wibble”].Value; 
 . . .       


I definitely think this scenario should be picked up by a static analysis tool and if I’ve read the blurb on FxCop 10.0 (that ships with VS2010) correctly then I have [high hopes](http://msdn.microsoft.com/en-us/library/ms182289.aspx) it will watch more of my back.

<u>Assert In The Finalizer</u>

So can we do anything else than rely on tooling? I think we can and that would be to put a Debug.Assert in the Finalizer - after all if the object is being consumed correctly then you should honour the contract and call Dispose() at the relevant point in time. I think it’s safe to say that the Garbage Collector does a pretty good job of hiding most mistakes by running frequently enough, but as [Raymond Chen](http://blogs.msdn.com/b/oldnewthing/) points out on [his blog last week](http://blogs.msdn.com/b/oldnewthing/archive/2010/08/09/10047586.aspx) (which is “CLR Week”) - you should not rely on the Garbage Collector running at all.

For my own types that don’t manage any native resources themselves it could be implemented like this:-

```
public class ResourceManager : IDisposable      ```
{       
#ifdef DEBUG       
 ~ResourceManager()       
 {       
 Debug.Assert(false);       
 }       
#endif       
 . . .       
 public void Dispose()       
 {       
 m_member.Dispose();       
      
#ifdef DEBUG       
 GC.SuppressFinalize(this);       
#endif       
 }       
}

So basically we’re saying that if Dispose() is not invoked, then, when a Garbage Collection does finally occur at least we’ll know we forgot to do it. Sadly we can’t rely on being able to inspect the members in the debugger to work out which instance of an object was forgotten because finalizers can be run in any order; but maybe we’ll get lucky.

If you start from a clean slate then you can write a unit or integration test that forces a full garbage collection right after exercising your code to ensure any errant finalizers run and get instant feedback about your mistake:-      
      
```
[Test]      ```
public void should_not_leak_resources()       
{       
 var consumer = new ResourceConsumer();       
      
 consumer.consumeResources();       
      
 GC.Collect();       
 GC.WaitForPendingFinalizers();       
}

I’ll be honest and point out that I’ve put off actually trying this out in earnest until I have had time to investigate how to tap into the Asserting mechanism so that I can avoid hanging the test runner with a message box unless I’m running under the debugger. I’ve done this plenty of times with the [Debug MS CRT](http://msdn.microsoft.com/en-us/library/zh712wwf.aspx) ([_CrtSetReportHook](http://msdn.microsoft.com/en-us/library/0yysf5e6.aspx)) so I’m sure there must be a way (I’ve only scratched the surface of the TraceListener class but I’m guessing it plays a part). 

<u>Debug Builds – Not The Done Thing?</u>

Back in an earlier post [Debug & Release Database Schemas](http://chrisoldwood.blogspot.com/2010/05/debug-release-database-schemas.html) I suggested there must be times when a debug build is used in the C#/.Net world. Unlike the C++ world, this beast does not seem to be at all prevalent. In fact I’ve yet to come across any 3rd party (or in-house teams) promoting a debug build. Visual Studio and C# supports the concept, but I wonder if teams only expect it to be used for internal testing? [Jeffrey Richter](http://www.wintellect.com/cs/blogs/jeffreyr/default.aspx) briefly mentioned “[Managed Debugging Assistants](http://msdn.microsoft.com/en-us/magazine/cc163606.aspx)” in his book [CLR via C#](http://www.amazon.co.uk/CLR-Via-Applied-Framework-Programming/dp/0735621632) but I’ve yet to read up on how you use them effectively, i.e. tap into the mechanism programmatically so that I can log these failures whenever the services are running unattended; not just under the debugger.



[*] It’s not really a paradox as 15 years C++ vs 1 year C# isn’t exactly a fair comparison.

[%] Optional in the sense that not every type requires it.

[#] or Close() in the case of the thread synchronization types [which is a nice inconsistency](http://blogs.msdn.com/b/kimhamil/archive/2008/03/15/the-often-non-difference-between-close-and-dispose.aspx).

[+] I’m still not convinced by the use of an off-the-shelf [Inversion of Control (IoC) framework](http://martinfowler.com/articles/injection.html) as it only seems to save the odd line or two of code at the expense of managing another 3rd party dependency. I also much prefer creating immutable types that are fully constructed via the ctor than providing multi-phase construction via mutators which IoC frameworks seem to require. Maybe I just don’t work on the kind of systems they’re aimed at?

[$] The obvious question here I suppose is “Why are you using C# then?”. And the answer [for now] is “because we are”. I was expecting this to to [_scale-up_](http://weblogs.java.net/blog/2006/07/19/scale-vs-scale-out) further that it has, but we can still scale-_out_ further if needs be.


---
Original: <https://chrisoldwood.blogspot.com/2010/08/idisposables-should-assert-in-their.html>\
Copyright: Chris Oldwood 2010\
Published: Wednesday, 18 August 2010 at 08:02\
Labels: .net, c#
