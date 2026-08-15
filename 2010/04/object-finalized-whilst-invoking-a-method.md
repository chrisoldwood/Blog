## Object Finalized Whilst Invoking a Method

The JIT Compiler & Garbage Collector are wonders of the modern computer age. But if you’re an ex-C++ developer you should put aside what you think you might know about how your C# code runs because it appears their view of the world lacks some artificial barriers we’re used to. [Deterministic Destruction](http://stackoverflow.com/questions/173670/why-is-there-no-raii-in-net) such as that used in C++ has a double meaning, sort of. On the one hand it means that an object _will_ be deleted when it goes out of scope, and yet on the other hand it also means that an object is only destroyed by an _external_ influence[*]. Essentially this means that the lifetime of a root object or temporary is defined by the exiting of a scope which keeps life really simple. In the C# world scopes affect some similar aspects to C++ such as value type lifetimes and the visibility of local variables, but not the lifetime of reference types…

<u>The Scenario</u>

The C# bug that I’ve just been looking into involved an Access Violation caused by the finalizer thread trying to destroy an object whilst it was still executing an instance method. Effectively the object finalizer destroyed the native memory it was managing whilst it was also trying to persist that very same block of memory to disk. On the face of it that sounds insane. How can the CLR reach the conclusion that an object has no roots and is therefore garbage when you’re inside a method as surely at least the stack frame that is invoking the method has a reference to ‘this’?

Here is a bare bones snippet of the code:-

```
public class ResourceWrapper : IDisposable      ```
{       
 public void Save(string filename);       
}

`. . .`\

```
public class MyType      ```
{       
 public ResourceWrapper Data       
 {       
 get { return new ResourceWrapper(m_data); }       
 }       
      
 private byte[] m_data; // Serialized data in      
 // managed buffer.       
}

`. . .`\

```
public void WriteStuff(string filename)        ```
{         
 m_myType.Data.Save(filename);         
}         
      
Now, reduced to this simple form there are some glaring omissions relating to the ownership of the temporary ResourceWrapper instance. But that should only cause the process to be inefficient with its use of memory, I don’t believe there should be any other surprises in a simple single-threaded application. I certainly wouldn’t expect it to randomly crash on this line with an Access Violation:-

`m_myType.Data.Save(filename);`\

<u>The Object’s Lifetime</u>

Once again, putting aside the blatant disregard for correct application of the [Dispose Pattern](http://en.wikipedia.org/wiki/Dispose_pattern), how can the object, whilst inside the Save() method, be garbage collected? I was actually already aware of [this issue](http://www.devnewsgroups.net/group/microsoft.public.dotnet.framework/topic61459.aspx) after having read the blog post [“Lifetime, GC.KeepAlive, handle recycling”](http://blogs.msdn.com/cbrumme/archive/2003/04/19/51365.aspx) by [Chris Brumme](http://blogs.msdn.com/cbrumme/default.aspx) a while back but found it hard to imagine at the time how it could really affect me as it appeared somewhat academic. In my case I didn’t know how the Save() method was implemented, but I did know it was an incredibly thin wrapper around a native DLL, so I’ve guessed that it probably fitted Chris Brumme’s scenario nicely. If that’s the case then we can inline both the Data property access and the Save call so that in pseudo code it looks something like this:-

```
public void WriteStuff(string filename)      ```
{       
 ResourceWrapper tmp = new ResourceWrapper      
 (m_myType.data);       
 IntPtr handle = tmp.m_handle;       
      
 // tmp can now be garbage collected because we      
 // have a copy of m_handle. 
 ResourceWrapper.NativeSaveFunction(handle,      
 filename);       
}

What a C++ programmer would need to get out of their head is that ‘tmp’ is more like a ResourceWrapper* than a shared_ptr<ResourceWrapper> - the difference being that its lifetime ends way before the end of the scope.

<u>The Minimal Fix</u>

So, if I’ve understood Chris Brumme’s article correctly, then the code above is the JIT Compiler & Garbage Collector’s view. The moment we take a copy of the m_handle member from tmp it can be considered garbage because an [IntPtr](http://msdn.microsoft.com/en-us/library/system.intptr.aspx) is a value type, not a reference type, even though we know it actually represents a reference to a resource. In native code you manage handles and pointers using some sort of [RAII](http://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization) class like [shared_ptr](http://www.boost.org/doc/libs/release/libs/smart_ptr/shared_ptr.htm) with a custom deleter as each copy of a handle represents another reference, but within C# it seems that the answer is using [GC.KeepAlive](http://msdn.microsoft.com/en-us/library/system.gc.keepalive.aspx)() to force an objects lifetime to extend past the use of the resource handle. In my case, because we don’t own the ResourceWrapper type, we have to keep the temporary object alive ourselves, which leads to this solution:-

```
public void WriteStuff(string filename)      ```
{       
 ResourceWrapper tmp = m_myType.Data;       
 tmp.Save(filename);       
 GC.KeepAlive(tmp);       
}

From a robustness point of view I believe the KeepAlive() call should still be added to the Save() method to ensure correctness even when Dispose() has accidentally not been invoked - as in this case. Don’t get me wrong I’m a big fan of the [Fail Fast](http://en.wikipedia.org/wiki/Fail-fast) (and Loud) approach during development, but this kind of issue can easily evade testing and bite you in Production. To me this is where a Debug build comes into play and warns you that the finalizer performed cleanup at the last minute because you forgot to invoke Dispose(). But you don’t seem to hear anything about Debug builds in the C#/.Net world… 

<u>The Right Answer</u>

The more impatient among you will have no doubt been shouting “Dispose - You idiot!” for the last few paragraphs. But when I find a bug I like to know that I’ve really understood the beast. Yes I realised immediately that Dispose() was not being called, but that should not cause an Access Violation in this scenario so I felt there were other forces at work. If I had gone ahead and added the respective using() statement that would likely have fixed _my_ issue, but not have diagnosed the root cause. This way I get to inform the relevant team responsible for the component of a nasty edge case and we both get to sleep soundly.



[*I’m ignoring invoking delete, or destructors or calling Release() or any other manual method of releasing a resource. It’s 2010 and RAII, whether through [scoped_handle](http://www.stlsoft.org/doc-1.9/classstlsoft_1_1scoped__handle.html) or shared_ptr or whatever, has been the idiom of choice for managing resources in [an exception safe way](http://www.boost.org/community/exception_safety.html) for well over a decade]


---
Original: <https://chrisoldwood.blogspot.com/2010/04/object-finalized-whilst-invoking-method.html>\
Copyright: Chris Oldwood 2010\
Published: Friday, 9 April 2010 at 23:27\
Labels: .net, c#
