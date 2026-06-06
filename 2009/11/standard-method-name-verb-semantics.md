# Standard Method Name Verb Semantics

Something that I’ve always taken for granted when programming is that certain verbs imply certain behaviours. I thought it would be useful to find a set of these on the web and link to it on our development wiki, as although I think it is common sense to native speakers, that is not true of team members for which English is a second language. However I’m struggling to track one down. I’ve seen plenty of posts about the format of interface, class, method and variable names, but not one that attempts to list the expected semantics of the really common verbs we use like get, create and find. To date I’ve only come across the [PowerShell documentation](http://msdn.microsoft.com/en-us/library/ms714428(VS.85,loband).aspx) as they’ve always made a concerted effort to try and standardise both the format of their commands:- verb-followed-by-noun, and also the semantics of the most common verbs.

One other useful resource I discovered was on Ward Cunningham's Wiki. There is a fair bit of discussion about naming conventions (across the board, not just methods) culminating in a concept know as [Language Orientated Programming](http://c2.com/cgi/wiki?ThelopLanguage). The Wiki also attempts to establish a lexicon of common terms based on some existing naming conventions, such as the ‘str’ prefix used in the C runtime library for all the narrow version C-style string manipulation functions. However there is a major bias towards abbreviations in the pages I read which is not what I’m looking for.

So, until I find that resource I’m going to present my own list of common method name verbs and describe what connotations each one conjures up in my mind:-

<u>Create & Delete</u>

These should be an easy ones :-) Creation is about making new things, commonly objects, and are often used to implement the Factory Method or Abstract Factory patterns. The objects they create may be fully constructed, but more often they are only default initialised and the caller has to perform further actions on it. A common example would be a factory function for creating database connections, where the connection still needs to be opened after creation. Common alternatives would be Allocate and Construct.

`IDatabaseConnection connection = DatabaseFactory.CreateConnection(connectionString);`\

If Create is how we bring objects into this world, then Delete is the Grim Reaper. Deletion is final and absolute, no trace should be left of the object afterwards. Any attempt to use something after deletion must surely be a logical error. Common alternatives are Dispose and Destroy.

`directory.DeleteFile(filename);`\

#### <u>Acquire & Release</u>

  Using Create in the name of a method, based on the above definition, could be seen to be leaking the abstraction. Acquire has more of a vagueness that could be interpreted only as “I’ll give you something you can play with, I may create it or I may reuse an existing object, either way you shouldn’t care”. The implication is that the object may be in a more complete state of initialisation. Using the previous example the database connection would already have been opened. Object pools are the prime example here.

`IDatabaseConnection connection = ConnectionPool.AcquireConnection();`\

If you’ve acquired something, there is a feeling of only partial ownership. It’s not really yours to do with as you wish. This means that you’re not in a position to delete it, the best you can do is _let go_. Releasing suggests that the object may live on with another unrelated owner, or perhaps it’s going to be returned to storage to await a new owner at some point later. COM interfaces are the canonical example here as memory allocation is outside the remit of the caller.

`connection.Release();`\

#### <u>Open & </u><u>Close</u>

  The use of Open and Close on an object is an incredibly common one, generally with real resources like files and database connections. They are very explicit actions, like Create and Delete, and also leak the abstraction to some degree. I find they are useful when you have a heavy resource that needs careful management, but you don’t feel you can hide that responsibility from the caller. Like Acquire and Release, they are slightly more woolly, but whereas Acquire and Release are about construction, Open and Close are actions an object performs (maybe on itself).

`connection.Open();`\

`connection.Close();`\

I have rarely seen these two verbs used alongside a noun in OO, even helper free functions would use overloading on type because the noun would only repeat the type.

#### <u>Find & Get</u>

  When I go shopping I often have two things in mind, there is stuff I would like and stuff I need. The stuff I would like is optional, or maybe I can choose from various brands and sizes, e.g. cereal*. In contrast the stuff I need is mandatory, maybe something doesn’t work without it, e.g. petrol. Find is analogous to the first case. It says “I think you might have this, and if you don’t I can do something else”, in short, you know that it could fail and you are willing to handle that failure responsibly. One common alternative verb is Lookup.

`Image image = cache.Find(url);`\

Get is like buying petrol from an oil refinery. You absolutely know that they must have some, and if they don’t then they better raise an exception because if the refinery is out you don’t stand much luck getting any from a petrol station either. Get is sometimes used for construction, such as in the composite verb GetOrCreate. I don’t personally like this use, to me, Acquire is far more pleasing.

`String name = product.GetName();`\

Get has unfortunately become such an overused verb because of its association with Getters and Setters. This has the side effect of people becoming blind to it to make property accessors read more naturally, e.g. `filename.getLength()`\ would subconsciously just be read as `filename.length()`\. I think most people these days would be surprised to find a Get method doing much more than just returning a private member.

#### <u>Request, Retrieve & Locate</u>

  The word Find is so quick to read and say, and with that I feel that it often implies a quick scan rather than a long drawn out search. For remote calls I like to try and use a verb that has for more complex connotations. Retrieve and Locate both sound like more serious work is involved in the hunt. Likewise Request always feels like something a remote service will be called upon to handle. 

`Book book = library.RetrieveBook(title);`\

Unfortunately the ubiquitous nature of HTTP means that Request is probably more commonly used as a noun, such in the inseparable pairing Request/Response.

#### <u>Read & Write/Send & Receive</u>

  When it comes to I/O a very common naming convention appears to be the use of Read and Write - as least as far as _file_ I/O goes. However when we’re talking about _network_ I/O the old Berkley Sockets API kicks in and and we find the use of Send & Receive favoured instead. If we’re restricted to discussing the transfer of small buffers of data this is fine, but once we begin to widen the picture to the overall topic of OO data persistence a few new terms come into play. The posh sounding pair is Serialize and Deserialize, which I find incredibly difficult to type (like all American APIs), but I tend to think of it as transport agnostic. The lower-class sounding variant is Load & Save, which evoke memories of floppy disks for me, and I usually expect it to be applied to large objects such as whole documents.

`Buffer buffer = textfile.ReadLine();`\

`uint count = socket.SendMessage(message);`\

`Image image = document.LoadImage();`\



I readily accept that these can be seen to be very literal interpretations - I’m a very literal kind of chap - but I think that most frameworks I’ve dealt with tend to follow along similar lines and I rarely get surprised. But in application code the story is often different, especially when working in a multi-cultural team. What would be nice is to have a global programmers dictionary and thesaurus. The dictionary could ensure that you’ve not picked something contradictory, while the thesaurus would grant you some latitude without you picking esoteric words that only Shakespeare would stand a chance of understanding.

*_Cereal shopping is actually a major event in our house, and as my wife (who will no doubt cast her eye over this post) will point out, does not allow for any deviation to shop own brands or other lesser substitutes…_


---
Original: <https://chrisoldwood.blogspot.com/2009/11/standard-method-name-verb-semantics.html>\
Copyright: Chris Oldwood 2009\
Published: Monday, 9 November 2009 at 20:13\
Labels: programming
