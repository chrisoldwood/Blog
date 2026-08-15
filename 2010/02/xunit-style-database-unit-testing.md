## xUnit Style Database Unit Testing

Like many small teams I find myself in the position of not only writing framework and application code but also occasionally for the back-end database. In most teams I’ve worked in there’s generally been a developer that tends to do far more of the core database work than the others, such as writing triggers, handling indexes (or is that indices :-) and optimising our poorly written stored procedures. During my last assignment I started getting more involved in the development process of the database code as I wanted to try and help streamline it to iron out some of the integration and deployment issues we were having. My thoughts weren’t exactly greeted with open arms by the DBAs, but in my new role I’m finding that I have an opportunity to test out my ideas as they are being taken on board by the team with an interest in developing them further.

<u>The Traditional Development Process</u>

Database development has always appeared to be treated differently to normal application development. With application code you have to write the source, compile it, test it and then deploy it to the application servers (let’s ignore dynamic languages for now). With SQL you can write the source, deploy it very simply and then test it. What’s even easier is that you can extract the source _from_ the database, make a change and redeploy without even saving the file anywhere else. Of course just because you can work this way, doesn’t mean you should. Some of the issues I’ve seen previously involved code which was running on the database but was not in the Version Control System (VCS) and regressions caused by code being written to work with the current data set instead of to a “specification”.

In my current role I wanted to see if we could adopt a more formalised process for database development. Essentially I want to see if we can treat database code almost exactly the same way as the application code:-


* The VCS acts as the master for all source code - you always start from what’s in the repository <u>not</u> a database 
* Unit tests exist for the public interfaces 
* Automated running of the unit tests on the build machine 
* Automated packaging of the scripts on the build machine ready for deployment 
* Automated deployment of the database code to a test environment 

The last three should be relatively simple – just a bit of scripting, but what does it mean to unit test database code? When considering stored procedures and user-defined functions the answer is straightforward because they map onto traditional unit testing of subroutines & functions. But what about triggers, views and constraints? Also how should the running of the test suite fit into the wider context of the whole database development process? Is a more structured development process too detrimental because fights against traditional practices and tooling?

<u>The Public Interface</u>

When unit testing object-orientated code it is often asked [if you should test private methods](http://stackoverflow.com/questions/250692/how-do-you-unit-test-private-methods). I don’t believe so because they are implementation details and should be tested only as a by-product of exercising the public interface. If they are not invoked via the public interface, then what purpose do they serve (Reflection and [Active Objects](http://en.wikipedia.org/wiki/Active_object) notwithstanding)? _Trying_ to test private methods also leads you to exposing them or writing hacks to facilitate this goal which only ends up leading to the need to refactor tests when the implementation changes which seems anathema to the cause.

So what constitutes the Public Interface of a database? Obviously Stored Procedures and User Defined Functions fall into this category, but what about tables? This depends on your access model. If you’re allowing your client code full access to your tables then your schema changes can directly affect your clients, whereas if you follow the model of all access via Stored Procedures then they’re not public. Views are also public as they’re often created with the very purpose of encapsulating the base tables they draw from.

We have chosen this latter model and have agreed that all implementation details such as Constraints and Triggers should only be tested as a by-product of testing the Stored Procedures that drive them. For example, if the specification says that the `SubmitOrder`\() procedure should default the order status to ‘Pending’, then it matters not whether that happens explicitly in the sp code itself, by a default value on the table or via an insert trigger – they all achieve the same _externally_ visible goal.

<u>The xUnit Model</u>

With the decision made about what to test, the next step is finding a way to do it. The most popular unit testing model these days seems to be [xUnit](http://en.wikipedia.org/wiki/XUnit). In an OO language you implement a test as a class method that includes an Assert to perform a comparison after invoking the required behaviour. Each test only tests one thing, is not dependent on any other, should be free from side-effects and is carefully named to reflect the intended behaviour (nay specification). The model also supports the ability to define common pre and post-test code in methods called `SetUp()`\ and `TearDown()`\ at both the Test and Fixture (set of related tests) levels to remove repetitive code and make the test intent clearer.

So how can we map these concepts onto database code? The side-effect free behaviour is a no-brainer as we can just use transactions. Databases do not support a declarative model that allows you to use Attributes to indicate tests, fixtures etc, but they do have their own internal tables that can be used in a reflection-like manner to invoke procedures based on their names. For example you could use a prefix such as “test” or “utsp_” to separate unit test code from production code. Then to distinguish between the actual tests and the initialisation and cleanup functions you could use “`<sp>_Should<expectation>`\” as an indicator of a test, and “`<sp>_SetUp`\” and “`<sp>_TearDown`\” for the other two. The fact that all test procedures take no arguments and return no values means that they can be invoked easily by reflection.

This leads to a SQL unit test script structured something like so:-

```
CREATE PROCEDURE testSubmitOrder_SetUp      ```
AS       
 INSERT Customer(CustomerId, CustomerName)       
 VALUES(1, ‘TestCustomer’)       
GO

```
CREATE PROCEDURE testSubmitOrder_TearDown      ```
 . . .       
GO

```
CREATE PROCEDURE testSubmitOrder_ShouldSetStatusPending      ```
AS       
 DECLARE @OrderId int       
 EXEC SubmitOrder ‘TestCustomer’, ‘widget’, 2,       
 @OrderId OUTPUT       
 IF NOT EXIST (SELECT 1 FROM Order       
 WHERE OrderId = @OrderId       
 AND OrderStatus = ‘Pending’)       
 RAISERROR (‘Order should be inserted with Pending status’, 16, 1)       
GO

```
CREATE PROCEDURE testSubmitOrder_ShouldUpdateInventory      ```
 . . .       
GO

This leads you to a physical layout where one .sql file contains all the test code for a single Stored Procedure, much like a single source file containing all the tests for a class.

I’ll be honest and admit that the details of mocking and supporting a [Fluent Interface](http://en.wikipedia.org/wiki/Fluent_interface) style for asserting far exceeds my knowledge of SQL and databases. I know (because I’ve done it by mistake in the past!) that procedures of the same name can belong to different users, so perhaps this mechanism can be exploited? For the moment the style above serves our purpose.

<u>Executing The Test Suite</u>

My initial thoughts about the way that the test suite would be executed were somewhat grandiose. I thought that the Test Fixture could be used to only load the database objects needed to run the tests and therefore also provide a mechanism though which mocks could be injected. I fear that this is a maintenance nightmare in the making if the dependencies are not automated. The simpler option is to recreate the database from scratch and then run the unit test scripts on that. Because each unit test is responsible for its own test data we can avoid taking the “restore” option which ensures that we are guaranteed a truly clean database - one free from developer detritus.

The wonderful knock-on effect of formulating this process is that it can be executed on the build machine as part of the [Continuous Integration](http://martinfowler.com/articles/continuousIntegration.html) process. [SQL Server Express](http://www.microsoft.com/express/Database/) is just the ticket for the database role as it gives us all the features of it’s bigger brother, but can easily cope with the trivial workload we throw at it. This also feeds into the daily database development cycle as I can use a local installation of SQL Server Express as my sandbox where I only require the schema, objects and minimal test data because I’m focusing on the functional aspects of the problem, not performance testing.

This technique also gives us a path to the goal of continuous integration testing of database and application code and then continuous deployment to the system test environment. Here we can automatically rebuild a database from scratch, populate it with real data, deploy the code to the application servers and push the big green button. If this is done during the night, then by the morning we will have exercised a significant number of code paths and have a high degree of confidence that the environment is stable and ready for further integration/system testing.

<u>Scalability</u>

One of the conventions in unit testing is to reduce your dependencies so that the [tests run really quickly](http://www.artima.com/weblogs/viewpost.jsp?thread=126923), then you have no excuse not to run them at every opportunity. Unfortunately, due to the nature of the toolchain (an out-of-process database) running tests is not as instantaneous as with application code. Running the individual tests isn’t too expensive, but rebuilding the database from scratch can take a while so I would keep that for when you do a “Clean Build” prior to check-in.

<u>TSQLUnit</u>

As I mentioned in a previous post “[Company-Wide IRC Style Chat & Messaging](http://chrisoldwood.blogspot.com/2010/01/company-wide-irc-style-chat-messaging.html)” I first started thinking about this some years ago, and a colleague at the time pointed me to [TSQLUnit](http://sourceforge.net/apps/trac/tsqlunit/). I had a very brief look back then and it seemed pretty useful as it followed a similar model. I haven’t had time to go back and look at it in more detail. None of what I’ve said is rocket science though, if anything the hardest part is writing the Windows Batch files to trawl the VCS repository and invoke the relevant .sql scripts – a whole “[FOR /R %%I](http://www.robvanderwoude.com/batchfiles.php)” loop with a “SQLCMD –i %%I” body. Even [PowerShell](http://www.robvanderwoude.com/powershell.php) seems overkill for this job :-)



Phew, I didn’t expect this post to turn into War and Peace! At the moment this is working out really well for my current team, but I’m aware that as a greenfield project we currently don’t have a very large schema or number of objects. However, it’s going to be a large system in the end so it will be really interesting to see how all this scales up.




---
Original: <https://chrisoldwood.blogspot.com/2010/02/xunit-style-database-unit-testing.html>\
Copyright: Chris Oldwood 2010\
Published: Saturday, 27 February 2010 at 23:12\
Labels: database, testing
