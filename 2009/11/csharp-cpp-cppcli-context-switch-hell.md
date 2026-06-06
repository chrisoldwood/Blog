# C# + C++ + C++/CLI – Context Switch Hell

During the last week I’ve been doing some interop development at work. As you might expect from a financial institution the core analytics are written in C++ which is awkward for my team as our system is entirely C# based. Fortunately I got the chance to decide how we were going to communicate with the C++ library. Although new to C# I am aware of the various interop mechanisms available and went through them one-by-one to see which was the best fit. The C++ library only exposes a couple of functions and those only take an argument or two which take the form of a custom type that’s not a million miles away from a DataSet. Luckily there was already a Wrapper Facade available for this type so it really just came down to what was the easiest way to marshal this structure and deal with any exceptions.

<u>C API</u>

C is _the_ interop language - every language provides a C binding so it’s always a pretty safe bet. The P/Invoke mechanism built into the CLR was designed to allow interop with the underlying C based Windows Operating System, so there is a huge amount of support in the language for performing interop using declarative programming. Unfortunately I was calling a C++ API and I didn’t fancy the highly fragile option of binding to mangled function names, plus I still had to pick a C compatible type to serialize the data into. This meant either convincing the owners to expose (and more importantly maintain) the API themselves, or me writing a C based shim myself.

<u>COM Inproc Server</u>

Another common technique is to provide a COM based facade, perhaps via a Dual interface. If I was exposing a set of C++ objects this might be a good fit, but as it’s just a couple of free functions this seems like overkill. Plus the marshalling cost would have been significant as I would have marshalled the structure as a BSTR to get it over the COM interface and then constructed another copy on the C++ side. Given the volume of data being passed and the additional interop layer created by the Runtime Callable Wrapper this felt like a premature pessimisation, and a lot more work.

<u>C++/CLI</u>

The last choice I considered was similar in vein to the C based DLL, but using C++/CLI instead. I had a little play with the Managed Extensions when they first appeared and the code looked pretty ugly then, but as we are using VS2008 now I had the opportunity to use the far more palatable C++/CLI instead. You can freely mix-and-match native C++ and managed C++, even within catch blocks, so this looked pretty enticing on the exception handling front.

<u>Stick With What You Know</u>

As far as I could see it was a toss-up between exposing C++ code via extern “C” functions, marshalling the data as c-style strings and having to learn the P/Invoke syntax, or learning the managed C++ syntax and creating a mixed mode DLL. I really liked the idea of being able to mix native and managed C++ in the same translation unit as this would allow me to write one set of try/catch blocks to handle any native or managed errors which simplify the code. Also I felt that given the performance bias of C++ I would have far more opportunities to pass the large amount of data most efficiently with RAII to back me up.

<u>A Tale of ., ::, ^, –> & ()’s</u>

The following few days coding were somewhat amusing as I context switched constantly between the three slightly different C based syntaxes of C#, C++ and C++/CLI. Each is so incredibly similar to the other that I don’t think I managed to write a single line of code 100% correctly first time :-). The following is a list of some of the subtle differences that I ran into:-

<ul>   - C# uses the single keyword ‘foreach’ whereas in C++/CLI it’s separated into two as ‘for each’. 
    - C++ and C# use the ‘new’ keyword whereas C++/CLI uses ‘gcnew’. 
    - In C++ and C++/CLI you can invoke a no argument ctor without parenthesis, but in C# you have to provide them. 
    - When qualifying types with the enclosing class or namespace you use ‘::’ in C++ & C++/CLI, but just a ‘.’ in C# 
    - C# uses a ‘.’ to invoke methods, but C++/CLI follows C++ and uses the ‘->’ pointer syntax. This is made worse by the use of the term ‘reference type’ to refer to a type that you invoke with pointer, not reference syntax in C++/CLI! 
    - Forgetting the ^ either on the collection contained type, or the collection type itself. 
    - The _empty_ reference type is called ‘null’ in C#, ‘nullptr’ in C++/CLI and ‘NULL’ in plain C++. 
    - Conditional compilation uses ‘#ifdef’ or ‘#if defined’ in C++ and C++/CLI whereas C# uses the simpler ‘#if’ 
 </ul>  It only amounted to a couple hundred lines of code in total across all three languages, but I felt like I spent more time staring at the compiler output window than the text editor…


---
Original: <https://chrisoldwood.blogspot.com/2009/11/c-c-ccli-context-switch-hell.html>\
Copyright: Chris Oldwood 2009\
Published: Sunday, 22 November 2009 at 10:15\
Labels: c#, c++
