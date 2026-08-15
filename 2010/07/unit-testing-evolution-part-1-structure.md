## Unit Testing Evolution Part I - Structure

[_This post has been under construction for over 6 months. Every time I think I’ve got it sorted I gain some new insight from somewhere and feel the need to re-evaluate my strategy. The last of these was [Kevlin Henney’s ACCU London](http://accu.org/index.php/accu_branches/accu_london/accu_london_may_2010) session which covers similar ground to this post but naturally in a far more intelligent fashion; this post essentially covers my journey towards similar conclusions._]

I’ll be perfectly honest and admit that the unit testing strategy employed within _my <u>personal</u>_ class libraries can leave much to be desired. As I indicated in my previous post [“My Unit Testing Epiphany”](http://chrisoldwood.blogspot.com/2010/02/my-unit-testing-epiphany.html) I see this whole area of the development process as a Rite of Passage. Just like many others I have written my own Unit Testing framework, mostly because I saw the standard xUnit ports as too verbose, but also because I wanted to derive the practices myself from first principles. I’ve no doubt also made many of the same errors and trodden the same paths in a mistaken belief that I can somehow ‘short-circuit’ the process by using a simpler style. Sadly “Real Time” has to pass for many of the consequences of these actions to sink in and the lessons to be learnt.

<u>Genesis - Test Chaos</u>

Initially I saw the essence of unit testing as the act of having tests in place to verify behaviour. In effect it was the regression testing aspect that grabbed me most due to my previous faux pas. Hence I slipped into the habit of just writing a bunch of asserts, which works adequately for very simple free functions with a blindingly obvious interface. The following example are tests from my template based string parsing function:-

```
TEST_EQUALS(parse<int>(“1234”), 1234);      ```
TEST_EQUALS(parse<int>(“-1234”), -1234);       
TEST_THROWS(parse<int>(“9999999999”));       
. . .       
TEST_THROWS(parse<double>(“XYZ”));       
. . .

They should require no explanation as they have no setup, teardown or state. They are grouped by the template instantiation <type> and the tests run in a fairly obvious order: correct input first, then the edge cases like MAX and MAX+1, additional whitespace and finally malformed input. Every time I’ve gone back to read them I can understand what is going on in little to no time.

However, the same cannot be said for my CommandLineParser class tests. These fall straight into the “write-only” category because they only made sense at the time I wrote them. Here is the simplest example:-

```
{      ```
 static const char* args[] = { “test”, “--switch” };

` CommandLineParser parser(args);`\

```
 TEST_TRUE(parser.isSwitchSet(FLAG_SWITCH));      ```
}

For testing class methods I used scopes to break the tests up rather than write separate functions as I felt that writing a function came with the burden of coming up with useful test function names[#]. I knew that each test needed to avoid side effects so using scopes also allowed me to ensure the test object was recreated each time and that I could use copy-and-paste to write the tests as the variable names could be reused without clashing. At the time I really believed this was a more efficient strategy. Probably the worst CommandLineParser test I wrote was this:-

```
{      ```
 static const char* args[] = { “test”,      
 ```
“--single”, “value”, “/s:value”,     ```
 “--multi”, “value”, “value”, “-f” };

` CommandLineParser parser(args);`\

```
 TEST_TRUE(parser.isSwitchSet(SINGLE_SWITCH);      ```
 TEST_TRUE(parser.isSwitchSet(MULTI_SWITCH);       
 TEST_TRUE(parser.isSwitchSet(FLAG_SWITCH));       
 TEST_TRUE(parser.arguments[SINGLE_SWITCH].size() == 1);       
 . . .       
}

This single test highlights the biggest problem with my strategy - that it’s impossible to tell what features are _intentionally_ being tested. This means that changing it would be incredibly difficult as I may accidentally remove unobvious test paths; no wonder I can’t think of a name for the test method! It’s the Single Responsibility Principle again - each test should only test one feature at a time[#].

Just as an aside these are the behaviours that the test was verifying (I think!):-


* A switch can be provided using the Windows “/switch” style
* A switch can be provided using the Unix “--switch” style (with full switch name)
* A switch can be provided using the Unix “-s” style (with short switch name)
* A switch and it’s value can be separated by whitespace
* A switch and it’s value can be separated by a “:” if provided using the Windows “/switch” style
* A switch can be defined as single value but multiple occurrence (hence --single)
* A switch can be defined as multi value (hence --multi)
* A switch defined as allowing multiple values consumes all values up to the next switch or end of input.

As a final note the original test did not contain the trailing “-f” parameter. It was added when I discovered the implementation contained a bug in the handling of switches that took a list values. In the rush to get a test in place through which I could fix the code I performed the unforgiveable crime of extending an existing test with yet more responsibilities.

<u>Using Comments to Document Tests</u>

My initial reaction when revisiting these tests some time later was to use the natural tool for documenting code – the comment. This hardest part about this refactoring was working out what each test was supposed to be doing. However once again I was pleased that I had avoided introducing separate functions for each test as I felt that naming functions would be far more limiting that a free text comment and redundant in many simpler cases. Here’s how that earlier test now looked:-

```
{      ```
 // Boolean switches shouldn’t need a value.       
 static const char* args[] = { “test”, “--switch” };

` CommandLineParser parser(args);`\

```
 TEST_TRUE(parser.isSwitchSet(FLAG_SWITCH));      ```
}

Strangely I still thought it was ok to test multiple features because I believed the comments would add the necessary documentation for when the time came to deal with a test failure. Of course sometimes the comments still ended up being terse because I struggled to describe succinctly what it was doing[#].

The comments wouldn’t appear on the test output without more macro magic. But I wasn’t really bothered because if a failure does occur the first thing I do is to run the test runner under the debugger and wait for the failing ASSERT to trigger it. Eyeballing the test and code seems pointless when one of the key benefits of unit tests is that they run very quickly.

<u>Decomposing the Big Ball of Mud</u>

As the collection of tests started to grow I ran into a few niggling problems. The first was that each test was not protected with it’s own try/catch block so one stray exception caused the entire set of tests to fail. Although not a massive problem because I would fix every failure ASAP, it did feel as though each test should be better isolated. The second was that as I started practicing TDD I felt it would be beneficial to use the command line to restrict the set of tests run on each change to just those of the class I was developing. I wasn’t sure, but I suspected (for debugging reasons) that I may even want to limit the run to an even smaller subset of tests. This lead to the following new style test definition:-

```
TEST_SET(StringUtils)      ```
{       
 const tstring MAGIC_VALUE = “<something common>”;       
 . . .       
TEST_CASE(StringUtils, intFormatAndParse)       
{       
 TEST_TRUE(Core::format<int>(INT_MIN)      
 == TXT("-2147483648"));       
 TEST_TRUE(Core::parse<int>(TXT(" -2147483648 "))      
 == INT_MIN);       
 . . .       
 TEST_THROWS(Core::parse<int>(TXT("1nv4l1d")));       
}       
TEST_CASE_END       
. . .       
TEST_CASE(StringUtils, skipWhitespace)       
{       
 . . .       
}       
TEST_CASE_END       
. . .       
}

The TEST_CASE/_END macros added a try/catch block around each test so each set would always run to completion now. Although you might think it, TEST_CASE does not declare a function, it still just defines a scope which means that you can declare all your common immutable test variables at the top and they will be useable throughout the entire set of tests – still no separate SetUp/TearDown needed. This also gets around the restrictions in C++ when declaring and initializing static const members in class declarations[*].

The example above shows the new smaller grouping of tests. The TEST_CASE macro takes two arguments which I thought could be used as subcategories to help both in the filtering at runtime and to aid in the format of the output. I still wasn’t sure that I wouldn’t need to turn these into real functions at some point (as that’s what most other frameworks seem to do), so the TEST_CASE arguments are short and still adhere to class/function conventions. The multi-paradigm nature of C++ meant that whatever naming scheme I came up with I felt it would need to suit both free function and class/method based uses.

One other thing this refactoring sorted out was a minor problem of accounting. I counted test results based on the number of passed and failed asserts, rather than the number of actual test cases as individual cases weren’t defined originally. This meant the summary at the bottom could give you a much exaggerated view of how many tests you were writing (not that “number of tests” should be seen as a good measure of test coverage).

<u>No Assert Macro Changes</u>

I originally created only three assert macros out of laziness. I decided that the bare minimum would be TEST_TRUE() and TEST_THROWS(); I added TEST_FALSE() purely for symmetry. I know other test frameworks have a plethora of assert functions and support fluent syntaxes for writing clearer asserts, but with C & C++ you can capture the assert expression with the pre-processor with is also powerful. Given that I never really paid much attention to the output for each test anyway I was happy just dumping the raw assert expression out. Plus, as I said before, I go straight for the debugger the moment a failure occurs instead of staring at the console output looking for inspiration.



And so this is how things stayed whilst I started getting the hang of TDD at which point some more ‘test smells’ started developing and that’s the focus of part II.



[#] This will be the focus of part II.      
[*] I’m not sure what the exact rules are but I believe you’re effectively limited to a subset of the primitive types, e.g.float and double is also excluded.


---
Original: <https://chrisoldwood.blogspot.com/2010/07/unit-testing-evolution-part-i-structure.html>\
Copyright: Chris Oldwood 2010\
Published: Monday, 12 July 2010 at 17:14\
Labels: testing
