## Debug & Release Database Schemas

In the C++ world it’s common to build at least two versions of your code - one Debug and one Release. In the debug version you enable lots of extra checking, diagnostics and instrumentation to make it easier to track down bugs. This is often done at the expense of speed, which is one reason why you might switch these features off in your production Release[*]. For example it’s all too easy to enter into ‘[Undefined Behaviour](http://en.wikipedia.org/wiki/Undefined_behavior)’ in C++ such as by indexing into a vector with an invalid index. In a release build you won’t get notified and you can easily get away with it if you’re only off-by-one, but in a debug build the code should complain loudly. This notion of Undefined Behaviour doesn’t seem to exist in the C# and SQL worlds, at least it’s not nearly as prevalent, so is there any need for a Debug C# build or Debug Database Schema? I think the answer to both is yes and this post focuses on the database side. 

<u>Why Have Separate Builds/Schemas</u>?

How many times have you debugged a problem only to find that it was due to some garbage data in your database? In theory this kind of thing shouldn’t happen because databases have support for all manner of ways of ensuring your data is valid, such as Check Constraints, Primary Keys and Foreign Keys. Perhaps ‘valid’ is too strong a word and ‘consistent’ is more appropriate. But even then, such as when you’re [mapping objects to tables](http://www.agiledata.org/essays/mappingObjects.html), your foreign keys can only partly protect you as there may be parent/child table relationships that depend on a ‘type’ column for discrimination. And sometimes it’s just too easy to screw the data up by running a dodgy query - such as forgetting the WHERE clause when doing an UPDATE… 

If the database provides all these wonderful features why do some developers avoid them? Putting ignorance to one side, it seems that performance is often a key reason. Some tables are hit very hard and you believe you just can’t afford to have a whole bucket load of triggers and constraints firing constantly to verify your data; especially when you _know_ it’s sound because your extensive system testing ‘proved’ it. So let’s just reiterate that:- you’re avoiding error checking features in your database to improve performance… and how exactly is that different from the scenario I’ve just described above about C++ development?

Perhaps instead of blindly disabling features that actually have value _during development_ to satisfy _a production_ requirement can we have our cake and eat it? Can we enable some features during development to aid with testing and safely turn them off in production because they are free from side-effects and therefore have no impact on the observable behaviour?

<u>Enable Everything by Default</u>

I believe the default position is that you should use whatever features you can to ensure your code is correct and your data remains sane and consistent. The only reason to start removing error checking should be because you have measured the performance and can demonstrate the benefits of removing _specific_ constraints. Intuition may tell you that with the volume of data you’re going to be dealing with in production you really can’t afford certain foreign key relationships or constraints; but remember that’s in _production_. During development, unit testing, integration testing and even initial end-to-end system testing you’ll likely be building small databases with only representative data of a much lower volume and so there are no performance concerns to worry about – only ones of correctness.

<u>Utilising Debug Specific Code</u>

The most common constraint I’ve heard of [causing problems](http://www.sqlservercentral.com/articles/Advanced/thepitfallsofforeignkeys/2290/) is Foreign Keys, but that’s not just restricted to performance issues. You can also implement complex validation logic in Check constraints and Triggers. It may seem that implementing such logic at the SQL level is far too inefficient or wasteful, especially if you’re going to be driving it with server code that has decent test coverage. And if you’re restricting yourself to using stored procedures for your public interface you may feel you have very tight control over what happens. However your SQL unit tests could have holes that might only show up during integration testing when another team uses your API in ways you never anticipated.

Using self-contained constraints or triggers is one technique, but there is also the opportunity to add others kinds of debug logic to your stored procedures such as by using [Asserts](http://en.wikipedia.org/wiki/Assertion_(computing)). For example you may specify that you cannot pass null as the input to an internal[+] stored procedure, and so to verify the contract you could add an assert at the start of the procedure:-

```
CREATE PROCEDURE FindCustomerByID (@CustomerID int)      ```
AS       
 AssertIntegerIsNotNull @CustomerID,       
 ```
“Customer ID”, ```
 OBJECT_NAME(@@PROCID)       
 . . .       
GO

Many SQL error messages can be incredibly terse which makes debugging issues even trickier; especially when you’ve created the mother of all queries. The use of additional debug code like this can allow you verify more state up front and therefore generate far more developer-friendly error messages. I know that cursors are often frowned upon (again for performance reasons) but they can be used effectively to iterate rowsets and provide finer grained debug messages.

<u>Isolating Debug Specific Code</u>

So how do you control what goes into a Debug or Release build? If you’re used to defining your database schemas and objects by using visual tools like SQL Server Enterprise Manager this isn’t going to fly. You need to be able to build your database from scratch[^] using scripts stored in a VCS, just like you would your client & server code; ideally building a database should not be seen as any different from building your assemblies. See my previous post “[xUnit Style Database Unit Testing](http://chrisoldwood.blogspot.com/2010/02/xunit-style-database-unit-testing.html)” for another compelling reason why you might want to work this way.

This means you probably have scripts with filenames like “Order_FK_Customer.sql” in, say, a “Foreign Keys” folder. One option would be to name your files with an additional suffix that distinguishes build type, e.g. “Order_FK_Customer.Debug.sql”. Alternatively you could create additional subfolders called “Debug” & “Release” with the build specific scripts. This implies that there are no dependency issues, which is solved by splitting out your constraints from your table creation scripts and using the ALTER TABLE construct.

Applying this technique where you just want to inject a little extra code into triggers and sprocs is not going to be maintainable if you have to have two copies of it, so an alternative would be to add a guard around the build specific code and use a function to control the flow of logic, e.g.

```
CREATE PROCEDURE FindCustomerByID (@CustomerID int)      ```
AS       
 IF (IsDebugBuild() = 1)       
 BEGIN       
 AssertIntegerIsNotNull @CustomerID,      
 “Customer ID”,      
 OBJECT_NAME(@@PROCID)       
 END       
 . . .       
GO

The implementation of the function IsDebugBuild() can be chosen at build time by applying either “IsDebugBuild.**Debug**.sql” or “IsDebugBuild.**Release**.sql”. I don’t know what the overhead of executing a simple function like IsDebugBuild() would be – it’s something I’ve yet to investigate but I would _hope_ it is dwarfed by the cost of whatever queries you end up executing. Another alternative would be to use a pre-processor such as a C compiler to strip code out, but then you lose the ability to write and test your code easily in a tool like SQL Server Management Studio which I would personally consider far more valuable[#].

<u>Use Schemas as Namespaces</u>

To help separate and highlight debug or test functions you can use a separate schema, such as ‘debug’, e.g. you would invoke **debug.**AssertIntegerIsNotNull. If you prefix your scripts with the schema name (I think SSMS does this when exporting) you can use this to your advantage when building your database. For example, when we build a database for our [Continuous Integration](http://martinfowler.com/articles/evodb.html) process that’s going to the run unit tests we’ll include all files in the ‘test’ schema, but when we’re building an integration testing or production database we leave them out.

<u>Verifying a Release Build with Unit Tests</u>

Earlier I said that it should be possible to remove all the debug code because it must be side-effect free. How can you verify that someone hasn’t inadvertently written code that violates this rule? Well, ideally, you should be able to at least run the unit tests. If you have good code coverage then that should give you a high degree of confidence. The problem is that your unit tests may need to mess about with the schema to get the job done, e.g. dropping an over zealous delete trigger to allow you to cleanup after each test is run. However there is nothing to stop you rebuilding the database again afterwards - after all that’s the point of automating all this stuff.

<u>Caveat Emptor</u>

Most of this stuff seems like common sense to me, but I’m a C++/C# developer by trade and it’s always possible that none/some/all this advice may go against a number of best practices or not scale well as the system grows. My current (greenfield) project has not reached the stage yet where we have performance concerns that require us to evaluate the use of these techniques, but until that moment comes we’ll be utilising every one of these techniques to ensure we continue to develop (and more importantly [refactor](http://www.agiledata.org/essays/databaseRefactoring.html)) with speed.



[*] Let’s leave out the debate about whether you should or shouldn’t leave your debug code in at release time and assume that we want/need to take it out.

[+] It seems a common practice to implement behemoth stored procedures that take gazillions of arguments and perform a dizzying array of similar but different requirements instead of writing a number of smaller, more focused procedures that use internal ‘helper’ functions and procedures instead.

[^] Yes, you may choose to deploy to production by [patching](http://stackoverflow.com/questions/502952/database-deployment-best-practices) your existing database, but once again the development and unit testing focus is better served by removing any residual effects.

[#] When I’m developing a stored procedure I like to have two query windows open, one with the stored procedure code and another with the unit tests. I can then edit the stored proc, apply it to my unit test database and then switch windows and run the unit tests to verify my changes. This makes for a nice fast feedback cycle. The unit test runner is the perfect example of debug specific code.


---
Original: <https://chrisoldwood.blogspot.com/2010/05/debug-release-database-schemas.html>\
Copyright: Chris Oldwood 2010\
Published: Sunday, 23 May 2010 at 09:00\
Labels: database, testing
