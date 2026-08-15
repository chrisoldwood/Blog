## Integration Testing with NUnit

Back near the start of my current project I came across a number of tests in one of our unit test assemblies that touched the file-system. My gut reaction was to cry foul and point out that unit tests are not allowed to have any external dependencies. In fact just the other day on the [accu-general mailing list](http://accu.org/index.php/mailinglists) someone was trying to locate the definition of a Unit Test that Kevlin Henney used in his [ACCU 2008 Conference session](http://accu.org/content/conf2008/Henney-Know%20Your%20Units.pdf):-

>    A unit test is a test of behaviour (normally functional) whose success or failure is wholly determined by the correctness of the test and the correctness of the unit under test. Thus the unit under test has no external dependencies across boundaries of trust or control, which could introduce other sources of failure. Such external dependencies include networks, databases, files, registries, clocks and user interfaces.

  <u>Test Code Structure</u>

The author of the tests agreed that they weren’t really unit tests, but defended his position by saying that he just wanted an easy way to invoke his code. He was using [Resharper](http://www.jetbrains.com/resharper)* which allows you to run a unit test incredibly easy due to it having its only NUnit compatible test runner. Being new to NUnit I also didn’t know that you can categorise tests with string labels that can be passed to the test runner to ensure only a subset of the tests are run:-

```
[TestFixture, Category(“MyCategory”)]      ```
public class MyClassTests       
{       
. . .

`C:\> nunit-console /include=”MyCategory” MyAssembly.Tests.dll`\

He had created a number of categories including “UnitTest” and “IntegrationTest”. It felt wrong to include Integration Tests inside what had historically been our Unit Test assemblies so we agreed to split them out at a later date. This meant we could use the assembly itself as a coarse grained grouping mechanism and save NUnit categories for a more functional grouping.

It didn’t take long before it became apparent that we were heading into assembly hell as we had already decided to partition the code so that production logic sat in one assembly, the unit tests in another and a further one for related hand-crafted mocks and stubs that would be used by any test utilities. Adding an integration tests assembly as well would mean a ratio of 1 production assembly to 3 test assemblies. The Visual Studio solution was already creaking even with Solution Folders used to group components.

Instead we decided to keep a ratio of 1:1 with production and test assemblies and use his original test categories and then adjust the build scripts to only run a certain type of test from each test assembly. This also didn’t upset Resharper as it already provides support for running tests of different categories.

NUnit allows you to [categorise tests](http://www.nunit.org/index.php?p=category&r=2.5.2) either at the Test or TestFixture level. I didn’t like seeing the two mixed together in the same source file and found the Category attribute added quite a bit of extra noise to the individual tests so we elected to use separate fixtures for each category. This also means that should we decide to go back to using separate assemblies for unit and integration tests we can. So our fixture headings currently look like this:-

In MyClassUnitTests.cs

```
[TestFixture, Category(Test.Category.UnitTest)]      ```
public class MyClassUnitTests       
{       
. . .       
}

In MyClassIntegrationTests.cs

```
[TestFixture, Category(Test.Category.IntegrationTest)]      ```
public class MyClassIntegrationTests       
{       
. . .       
}

The nature of integration tests is such that you should be testing your interaction with some external dependency and therefore it is that dependency that more naturally lends itself to the test fixture name and avoids this kind of clash:-

```
[TestFixture, Category(Test.Category.IntegrationTest)]      ```
public class TheirBackEndIntegrationTests       
{       
. . .

Of course this may work for a simple Gateway style component, like a web service with a couple of methods, but when you write tests for your Data Access Layer classes you may well just be writing tests that either use a mock or real database connection and so the distinction may appear to be only the test type and database dependency. Mind you, perhaps that’s a smell indicating your testing efforts are not optimal?

<u>Test Configuration</u>

By Kevlin’s definition there must be an external dependency and in the initial cases there was – the file-system. However looking forward we also had plenty of database code to come and it would be neat if we could test that the same way. We now do and I’ll describe that in a follow-up post.

Fortunately the nature of the components that we were initially testing were such that they serve up data from the file-system in a read-only manner. This meant that we could create a cut-down copy of the service data repository inside the VCS structure and always keep the folder layout and data format in step with the code. It also means that multiple simultaneous builds will not interfere with each other.

The build process uses some pretty run-of-the-mill batch files, so the question was how to pass the path of the test data folder via nunit-console.exe onto the test code assembly. I didn’t find any obvious mechanism during my searches – mostly people seemed to be trying to use the standard .Net .config mechanism and running into issues with AppDomains and suchlike. I decided that given the core folder structure was pretty much settled, and it’s already part of the VCS repository, what’s wrong with hard-coding a relative path?

`const string REPOSITORY_ROOT = “..\..\..\IntegrationTests\Data\MyService”`\

Yes I know it feels unclean, but is it any different to hard-coding the same path in the .bat file that invokes nunit-console? At least it’s a _relative_ path and I would hope that we would find out pretty quickly if this breaks or our [Continuous Integration](http://en.wikipedia.org/wiki/Continuous_integration) process is worthless.

This is all fine and dandy for read-only integration tests (which the vast majority of ours are at the moment) but what about if they also have to write to the file-system? For this we are using the Temp directory. The .Net API has methods for [generating a temporary file](http://msdn.microsoft.com/en-us/library/system.io.path.gettempfilename.aspx) with a unique name or you can use the Process ID and Thread ID if you want to something a little more user-friendly as this will still be safe with multiple simultaneous builds running. In retrospect I guess you could create a Temp folder within the VCS working copy and treat it like the ‘obj’ and ‘bin’ output folders. In Subversion you can use the [‘svn:ignore’](http://www.petefreitag.com/item/662.cfm) property to exclude a file or folder from being treated as unversioned and keep your “SVN Commit…” window clean.

<u>Test Results</u>

You still write your tests in the exact same was as unit tests, it’s just that you may have to be a little more creative in what it is that you are asserting. If you’re not round-tripping the data and cannot use Assert.AreEqual() you may instead just be satisfied with checking for a files existence and/or length:-

`Assert.IsTrue(System.IO.File.Exists(filename));`\

Alternatively you can use the absence of exceptions to indicate success by finishing the test with Assert.Pass()** or Assert.IsTrue(true). Sometimes it’s just not possible to completely verify the results of this kind of test and the ROI to achieve that may be small; it may be worth putting that effort into System Tests instead. At the very least you’ll end up with an easy way to invoke the code under a debugger should the need arise.

<u>Component Level Tests</u>

Integration testing appears to be quite a loose term with the definition of ‘external’ being applied to everything from another class, to another team, to another organisation. In his book [Code Craft](http://nostarch.com/codecraft.htm), [Pete Goodliffe](http://www.goodliffe.net/) describes Component Testing (p138) as something that sits between Unit and Integration Testing. Having not made this distinction in the past I’m not sure quite where the ‘external dependency’ line is drawn, but my guess is that it’s probably closer to Unit than Integration. Hopefully someone will add a comment that points out a really good book/article on testing as [Code Complete’s](http://www.cc2e.com/) chapter on Integration/System Testing talks a lot about methodology and little about the testing mechanics.





[*The reason why I’m procrastinating over installing Resharper will have to wait for another day, but [Thomas Guest](http://wordaligned.org/) touched nicely on the subject [just recently](http://wordaligned.org/articles/beware-the-march-of-ides).]

[**It seems that Resharper doesn’t like Assert.Pass() - maybe I’m using it incorrectly? The uglier Assert.IsTrue(true) satisfies my need to always finish a test with an Assert.]


---
Original: <https://chrisoldwood.blogspot.com/2010/03/integration-testing-with-nunit.html>\
Copyright: Chris Oldwood 2010\
Published: Tuesday, 30 March 2010 at 22:05\
Labels: testing
