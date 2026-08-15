## Stored Procedures Are About More Than Just Performance

A colleague who is new to the team and working on a new GUI project asked me whether we should be using an [ORM](http://en.wikipedia.org/wiki/Object-relational_mapping) tool like [Entity Framework](http://en.wikipedia.org/wiki/ADO.NET_Entity_Framework) for the impending GUI Data Access Layer. Our existing services all invoke stored procedures via manually[*] crafted ADO .Net code which is largely due to our inexperience with ORM tools, but also because we hardly have any DB code so it’s not a burden – unlike what the GUI is likely to need. This in turn led to a question about why we use stored procedures in the first place when the performance of modern SQL query optimisers is such that the benefits are less considerable. What I found interesting about this question was that we had never chose to communicate with the database through stored procedures for performance reasons; on the contrary it has always been about creating an abstraction over the database to ease maintenance.

<u>OO Data Models</u>

I have been practising OO for long enough that I naturally see rows in a table as instances of objects and stored procedures as their methods. You can use OO techniques with procedural languages [like C](http://www.eventhelix.com/RealtimeMantra/basics/object_oriented_programming_in_c.htm) and SQL, it just takes a little artistic license in the naming scheme to work around some of the inherent limitations - although simulating virtual functions is a little trickier :-). There are a number of patterns available to deal with the ORM problem (the oldest ones I know of were in [James Rumbaugh’s book Object-Orientated Modelling and Design](http://www.amazon.co.uk/Object-oriented-Modeling-Design-James-Rumbaugh/dp/0136300545) from 1991) and in particular the problem of mapping polymorphic types to tables but I find the vast majority of cases fall into the simple Table == Type category.

A classic example would be a table of customers with ‘methods’ to add a new customer or find an existing one by its unique ID:-

```
create table Customer      ```
 Id int not null,       
 Name varchar(100) not null

```
exec Customer_Insert 1234, ‘name’      ```
exec Customer_FindById 1234

The most common scheme I’ve seen is to just prefix procedures with the ‘type’ name, which can seem a little odd to long term SQL’ists and so sometimes it’s feels more natural to them to treat the prefix as a namespace and repeat the ‘type’ in the ‘method’ name:-

```
exec Customer_InsertCustomer 1234, ‘name’      ```
exec Customer_FindCustomerById 123

This prefix also has the nice side-effect of causing related procedures to be grouped together within the file-system/VCS and database IDEs like SQL Server Management Studio (SSMS).

Of course for simple INSERTs and SELECTs this probably feels like overkill as all you’ve done is to wrap a one-line query and make more work for yourself. But where it starts to pay off is when your one-liner turns into a two or three-liner, requires tuning because the query optimiser needs help or you want to weave in other aspects such as debug code (which I covered recently in [Debug & Release Database Schemas](http://chrisoldwood.blogspot.com/2010/05/debug-release-database-schemas.html)).

<u>Where’s the Public Interface?</u>

In another post about database development, [xUnit Style Database Unit Testing](http://chrisoldwood.blogspot.com/2010/02/xunit-style-database-unit-testing.html), I briefly referred to the ‘Public Interface’ of the database and what might constitute it. Obviously in SQL there is no direct equivalent of ‘public’ and ‘private’ that you can use to restrict access to objects on a logical level, but there is a real security mechanism instead that you can leverage. By following the “Principle of Least Privilege” and only granting access (e.g. EXECUTE permissions) on those objects that the client _needs_ to use you can enforce a real public/private barrier.

Sadly this is not altogether intuitive from a maintenance perspective and can easily lead to the erroneous exposure of private procedures without some other convention to highlight the intended accessibility of the code. Even if you also follow the principle that you only write unit tests that target the public interface, it’s still not enough. One option would be to adorn the names of private procedures with another prefix or suffix, e.g.

```
exec **__**Customer_VerifyState @current, @intended       ```
exec Customer_VerifyState**_private** @current, @intended       
exec Customer_**internal**_VerifyState @current, @intended 

Using a prefix disrupts the nice grouping in the IDE/file-system, whilst a suffix may be invisible if it’s too subtle. Placing it between the ‘Type’ and ‘Method’ names adds a little speed bump that could provide enough of a clue without adversely affecting readability, although it feels more intrusive than the suffix. If you are purely relying on naming conventions then a more intrusive adornment may be better as you can then use a tool like grep to find violations in your sever and client code.

The only other option I see available would be to use schemas, e.g.

`exec **private**.Customer_VerifyState @current, @intended `\

I’ve not played much with schemas and on my current project we have already used them to distinguish between the core production code and other procedures that aid in unit testing (via a ‘test’ schema) or support utilities (via a ‘util’ schema). Our inexperience with schemas has also meant that we’ve run into a few minor permissioning issues with temporary tables and user-defined types that makes us a little wary of sprinkling them too liberally.

<u>SQL Maintenance</u>

All the teams I’ve worked in during the last dozen or so years have had developers whose _main_ role is to maintain the database code. That doesn’t mean that they didn’t have other skills as well, but effectively they were hired to maintain the SQL side of the codebase. That also doesn’t mean that other developers did not contribute to the SQL code (although in some cases a more rigid structure was in place) as SQL is often a core skill, but the quality of SQL generated by the generalists may not be sufficiently high enough for the volume of data being manipulated.

I definitely put myself in the category of developers that can write basic SQL queries and stored procedures and can handle many table joins, but when it comes to concepts like nested sub-queries I start to question whether I’m writing an efficient query or not. I’ve also read around the subject enough to know that cursors have their place and it’s not usually in the kinds of queries I write so having a SQL expert around to turn my functional query into an efficient one really helps.

Of course the query optimisers built into SQL databases now are way more advanced that when I first started using them, but there still seems to be a need for SQL experts who can tweak a query to correct the optimisers bad judgment calls and give orders of magnitude performance gains, or add some hints to avoid deadlocks caused by lock escalation. This kind of maintenance is so much easier if the SQL is contained within stored procedures as you can leverage the faster deployment mechanism.



[*] Naturally much of the boiler-plate code has been refactored out by wrapping the underlying SQL classes and using [Execute Around Method](http://c2.com/cgi/wiki?ExecuteAroundMethod) so that it has minimal excess baggage.


---
Original: <https://chrisoldwood.blogspot.com/2010/08/stored-procedures-are-about-more-than.html>\
Copyright: Chris Oldwood 2010\
Published: Monday, 9 August 2010 at 19:15\
Labels: database
