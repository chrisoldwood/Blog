## Simple Database Build & Deployment With SQLCMD

The SQL Server client tools has shipped for years with a console based utility for executing SQL. Historically this was OSQL.EXE, but that has been replaced more recently by SQLCMD.EXE which supports pretty much the same syntax. It’s also available [as a stand-alone component](http://www.microsoft.com/downloads/details.aspx?familyid=d09c1d60-a13c-4479-9b91-9e8b9d835cdc&displaylang=en) that requires no shenanigans like COM registration and so could be stored in the 3rd party area of your VCS and packaged along with your SQL scripts during deployment[+].

So, what’s the difference between osql and sqlcmd? Not a great deal when running simple scripts from batch files or the occasional one liner. The big one I see is the ability to pass Environment Variables into the script which can then be referenced as “$(variable)” in the SQL. This is ideal for passing in flags, e.g. [Debug/Release](http://chrisoldwood.blogspot.com/2010/05/debug-release-database-schemas.html). Here’s [a blog post](http://mshehadeh.blogspot.com/2006/09/sqlcmd-vs-osql.html) this lists further differences.

<u>Examples</u>

If you want to see the full set of switches you can do “sqlcmd –?”; however I’m just going to point out the handful that I use regularly so the later examples make sense. You should be aware that SQLCMD’s switches are case-sensitive, so “–Q” is not the same as “–q”, but fortunately the behaviour of the ‘overloads’ is usually very similar.

<table border="0" cellspacing="0" cellpadding="2" width="539"><tbody>     <tr>       <td valign="top" width="141">-E</td>        <td valign="top" width="396">Use Windows authentication[*]</td>     </tr>      <tr>       <td valign="top" width="141">-S <server\instance></td>        <td valign="top" width="396">The hostname (and instance) of SQL Server</td>     </tr>      <tr>       <td valign="top" width="141">-d <database></td>        <td valign="top" width="396">The database name</td>     </tr>      <tr>       <td valign="top" width="141">-Q <query></td>        <td valign="top" width="396">The query to execute</td>     </tr>      <tr>       <td valign="top" width="141">-i <filename></td>        <td valign="top" width="396">The name of a file containing the query to execute</td>     </tr>   </tbody></table>  So putting these to work, here are a few common examples, starting with dropping a database:-

C:\> sqlcmd –E -S MYSERVER\SQLEXPRESS –Q “drop database MYDB”

Creating a database:-

C:\> sqlcmd –E -S MYSERVER\SQLEXPRESS –Q “create database MYDB”

Executing a query stored in a file against the “MYDB” database:-

C:\> sqlcmd –E -S MYSERVER\SQLEXPRESS –d MYDB –i “C:\SQL\My Script.sql”

Because it’s a command line tool you can pipe the output to other command line tools. Here’s how you can see what connections are open to your database (that are stopping you from dropping it perhaps):-

C:\> sqlcmd –E -S MYSERVER\SQLEXPRESS –Q “sp_who2” \| findstr “MYDB”

If you want to toast those connections, this will do the trick (you need the SPID from the previous query results):-

C:\> sqlcmd –E -S MYSERVER\SQLEXPRESS –Q “kill <spid>”

<u>SQL Code Structure</u>

If you’re storing your SQL scripts in a VCS then you may have a structure somewhat similar to this:-

\Src      
 . . .       
 \ForeignKeys       
 \Indexes       
 \StoredProcs       
 \Tables       
 . . .

(An obvious alternative would be to store the object type in the extension, e.g. Customer.table.sql, Orders_Customer.ForeignKey.sql. Just so long as the objects are grouped in some way that you can easily discover via folders or file wildcards.)

One of the biggest problems when building a database is dealing with all the dependencies. Tables can have foreign keys into other tables which means that they need to be created in a particular order or SQL Server will complain. The alternatives are to not use foreign keys at all (which seems a little excessive) or split them out into separate scripts as shown above. There is a still _an order_, but it is far more manageable because it’s at the object ‘type’ level not at the individual script level. But then we already had to consider that if we’re defining users, user-defined types, schemas etc.

What this means is that we can (re)build our database from scratch using the following plan:-


* drop existing database 
* create new database 
* . . . 
* create Tables 
* create Foreign Keys 
* create Stored Procedures 
* . . . 
* apply permissions 
* . . . 

The drop and create[#] were shown above. The schema and object scripts could be done with a sprinkling of simple FOR magic:-

C:\> for /r %i in (*.sql) do sqlcmd –E -S MYSERVER\SQLEXPRESS –d MYDB –i “%i”

Obviously this is too general as we have no control over the order that scripts will be executed, but with a little repetition we can:-

C:\> for /r %i in (Tables\*.sql) do sqlcmd –E -S MYSERVER\SQLEXPRESS –d MYDB –i “%i”      
C:\> for /r %i in (ForeignKeys\*.sql) do sqlcmd –E -S MYSERVER\SQLEXPRESS –d MYDB –i “%i”       
C:\> for /r %i in (StoredProcs\*.sql) do sqlcmd –E -S MYSERVER\SQLEXPRESS –d MYDB –i “%i”

(Or if you choose to encode the object type in the filenames your ‘in’ wildcards would be (*.Table.sql), (*.ForeignKey.sql) etc.)

Also, don’t forget that %i at the command line becomes %%i when used in a batch file and to enclose the loop variable in quotes (“%i”) to cope with filenames with spaces in.

However, If you just have a big ball of scripts then a more painful way would be to create a text file with a list of relative paths in that defines the order. Naturally this would be horrendous to maintain, but maybe you have an easy way of generating it? Then you could use an alternate form of the FOR statement to read the text file and pass those lines (i.e. the filenames) to sqlcmd, e.g.

filelist.txt:-

Scripts\Customer.sql      
Scripts\Orders.sql       
Scripts\Customer to Orders.sql (the foreign keys)

C:\> for /f “delims=” %i in (filelist.txt) do sqlcmd –E -S MYSERVER\SQLEXPRESS –d MYDB –i “%i”

Once again you’ll need to watch out for filenames with spaces as the FOR /F statement will by default use the space and tab characters as field separators (which would cause the filename to be split across the variables %i, %j, %k etc) so we use “delims=” to treat each line as a whole filename.

<u>Deployment From an Application Server</u>

Your Continuous Integration server can happily invoke a script to run the automated tests on the build server using a local copy of SQL Express with the source code applied directly from the VCS view/working copy. But when it comes to Continuous Deployment to something like a DEV environment you really want to be packaging this code up (along with SQLCMD and the scripts) and installing from another box. This way you have a solid record of what was deployed (which hopefully ties up with the label in your VCS) and you’re also not tempted to patch code directly in the build server views.

I’ve found that a simple .zip file does the job nicely and there are plenty of command line tools for generating these, such as 7-Zip. You can use the same techniques you used to invoke SQLCMD to invoke the archiver to add the scripts to your package. The built-in Windows unzipper is painfully slow (and only available via the GUI I believe) so I would also publish the archiver alongside the SQL package so that you don’t have another server configuration issue to think about.

<u>A Cautionary Tale </u>

There is one rather nasty gotcha that you should be wary of with sqlcmd[^]. If the native SQL driver is not installed then you’ll not know about it – in the sense that you’ll get no errors reported. So, if your scripts just create objects and execute no queries you’ll be none the wiser. Running a simple query like this:-

C:\> sqlcmd –E -S MYSERVER\SQLEXPRESS –Q “select getdate()”

Will result in no output whatsoever. I somewhat naively assumed that the native SQL driver would be part of our standard application server build, if not Windows itself. Fortunately you can still download an MSI with just the driver from [Microsoft Downloads here](http://www.microsoft.com/downloads/details.aspx?familyid=d09c1d60-a13c-4479-9b91-9e8b9d835cdc&displaylang=en).



[+] I don’t know what _your_ licensing agreement says (IANAL) but I would hope it allows you to use it with your Continuous Integration server to allow it to run your automated unit tests and additionally bundle it along with your scripts in your package to act as your deployment mechanism.

[*] Does anyone still use username/password (or mixed mode) authentication with SQL Server? I would expect anyone using SQL Server to be a Windows ‘shop’ and therefore be all Active Directory and single sign-on these days…

[#] It’s possible that for your UAT and Production databases your “create database” will involve custom hardware configuration stuff like where you put the data files and other careful tuning, but for automated unit testing purposes letting SQL Server use the defaults is perfectly adequate.

[^] I don’t think this affects osql because it uses a different transport (db-library?).




---
Original: <https://chrisoldwood.blogspot.com/2010/07/simple-database-build-deployment-with.html>\
Copyright: Chris Oldwood 2010\
Published: Monday, 19 July 2010 at 18:12\
Labels: build, database, tools
