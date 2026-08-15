## Implementing Constants & Enumerations in a Database

How often have you come across this kind of code in a stored procedure:-

```
select abc      ```
from xyz       
where Status = 3

…or if you’re lucky (or perhaps unlucky if the comment is out-of-date):-

```
select abc      ```
from xyz       
where Status = 3 --Failed

One of the downsides of SQL (at least with T-SQL) is a lack of support for constants, and by extension enumerations.

<u>No Magic Numbers</u>

It’s long been a best practice that you avoid the use of so called Magic Numbers like the ‘3’ in the examples above in favour if some more symbolic name. This aids both readability and maintainability because you don’t have to go and lookup what the number represents (in the case of an enumeration) and if the enumeration value needs to change you only have to change the relationship with the symbol and not the code where the symbol is referenced.

<u>Local Constants</u>

If you only need a constant for use within a single stored procedure then you can just use a normal variable:-

```
declare @Failed int      ```
set @Failed = 3       
. . .       
select abc       
from xyz       
where Status = @Failed

This will make the latter SQL more readable and hopefully more maintainable - it should be far easier to grep for “Failed” than “3” if the numeric value does need to change[*].

<u>Global Constants</u>

Sadly the need for one-off constants is pretty rare. What is more likely is the need for a globally defined constant so that we don’t violate the [DRY](http://en.wikipedia.org/wiki/Don't_repeat_yourself)/[SPOT](http://en.wikipedia.org/wiki/Single_Point_of_Truth) principle by defining local constants in every procedure where it’s used. The best solution I could come up with[#] was to use a User Defined Function:-

```
create function Failed() ```
 returns int       
as 
 return 3       
go

This means that you can use it like so:-

```
select abc      ```
from xyz       
where Status = Failed()

However it’s not always possible to use a UDF in the same place that you can a constant or variable (I’ve yet to read up on why) and so sometimes in a stored procedure you still need to use a local variable as well:-

```
declare @Failed int      ```
set @Failed = Failed()       
. . .       
exec SomeOtherProc @Status = @Failed

<u>Lack of Namespaces</u>

Although some databases have support for schemas, they are often quite simplistic and not designed for nesting like you would in C++ and C#. This means that to avoid conflicts we need to resort to the old style of using some form of prefix or suffix on the name:-

```
select abc      ```
from xyz       
where Status = TaskStatus_Failed()

This becomes a little less distracting with enumerations as in C# you are forced to prefix the enumeration value with it’s type name anyway (unlike C++, although may people nest C++ enumerations within a separate struct to get the same effect) so it’s not too unnatural to read. Of course you could still create a separate namespace, called say ‘constants’, in which you put all these UDFs if you felt that it helped matters.

<u>An Alternative - Lookup Tables</u>

The main thing I like about the UDF solution is that the function name means the symbol appears as code rather than data. One alternative I’ve seen is to use a small lookup table that has the integer value and a string for the symbol. This makes the numbers less ‘magic’ but it means you have invoke a query to get the enumeration value:-

```
declare @Failed int      ```
select @Failed = EnumValue from TaskStatusEnum      
 `where EnumSymbol = ‘Failed’`\

I’ll be honest and admit that I’ve done no performance comparisons between this and the UDF idea. It also still feels to me like you’re expressing the enumeration with data rather than code though but that’s probably nonsense.

<u>Client-Side Use</u>

The other benefit of using a UDF is that you can also use it client side should you happen to need to embed queries within your code so your magic numbers don’t leak further afield. We use proper enumerations in our C# code that are kept in sync manually but tested automatically as part of a build. Ideally we should generate the UDF’s and C# enum’s from a single source, but for the moment the automated tests acts as a nice safety net.



[*] Of course in the real world you would never rely on the consistent use constants like this and would actually search for all references to the table and/or column name instead, but hey this is theory :-)

[#] Remembering that I’m not a SQL expert by any stretch of the imagination.


---
Original: <https://chrisoldwood.blogspot.com/2010/09/implementing-constants-enumerations-in.html>\
Copyright: Chris Oldwood 2010\
Published: Friday, 10 September 2010 at 07:46\
Labels: database
