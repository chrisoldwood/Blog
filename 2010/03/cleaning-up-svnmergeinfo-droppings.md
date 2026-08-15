## Cleaning up svn:mergeinfo Droppings

I’ve been using Subversion for about 6 months now and the daily grind of Update/Edit/Commit is a breeze with TortoiseSVN and Ankh. Admittedly my team only has a small codebase at the moment but performance is generally very good. However one area that Subversion is already struggling with is merging. I don’t think this is news to anyone who has used Subversion for any period of time (or the developers for that matter) but it does taint the experience a little. It’s also obviously unfair to compare a free VCS like Subversion with something Enterprisey like ClearCase (that comes with an Enterprise price tag to match), but I’ll do it anyway because my only other real yardstick is Visual SourceSafe…

<u>The Merging Strategy</u>

We are 3 iterations into a new system and although we have made no formal delivery yet, I have nonetheless treated the end of each iteration as a formal release so that I can get used to the branching, merging and labelling techniques in Subversion. I was already aware that Subversion does not treat branches and labels as first-class concepts like ClearCase, so was keen to explore Subversion’s model to discover its limitations as early as possible. We are following a run-of-the-mill development model, with continuous integration into the trunk and branching for release, but due to the odd mishap we have needed to cherry-pick changes off the trunk for the release and also cherry-pick changes off the release back to the trunk. The former is just an education problem as some of the developers adjust to working with branches, whilst the latter is a necessity because releases are often not 100% correct at the point of branching and need nursing to get them production ready. In the past with ClearCase cherry-picking changes caused no side effects but with Subversion it creates an ever growing trail that affects subsequent merges in unpleasant manner.

<u>The svn:mergeinfo Property in Subversion</u>

Subversion uses a special property on files and folders to record when a merge has taken place called “svn:mergeinfo”. The value of the property is a list of the branches (and associated range of revisions) that have been merged to date – _irrespective of whether a physical change has been made to the item itself_, e.g.

```
/branches/releases/1.0:1-1000      ```
/branches/feature/cool_stuff:900-910       
/branches/releases/2.0:1100-2000

Generally speaking it’s a good idea to merge using the root of a branch to ensure that you don’t miss anything (unless you’re cherry-picking changes of course). In Subversion this means that only the branch roots then need to have their svn:mergeinfo properties updated which keeps things clean and tidy. But if you cherry-pick a change Subversion then needs to maintain a merge list on that file for ever more, and more importantly for every future merge where that file is a child and therefore a _potential_ candidate. The net outcome of this architecture is that you end up with a very noisy commit every time you merge because it is full of svn:mergeinfo property updates with the real code changes obscured.

ClearCase uses a similar technique (called hyperlinks) to achieve the same goal, but the difference is that it only records a link back to the single source version that contributed the changes – subsequent merges have no effect. Of course ClearCase is renowned for it’s slowness* and it’s possible that the Subversion architecture may improve the speed of merging at the cost of fidelity. The Revision Graph from TortoiseSVN doesn’t appear to have the wonderful merge arrows that the equivalent feature in ClearCase has and you can’t instigate merges from the TortoiseSVN Revision Graph – a feature I used heavily on a previous project - but maybe that says more about the quality of the Development Process than the tool…

<u>Deleting the MergeInfo Properties</u>

Now, if I interpret this post “[Subversion merge reintegrate](http://blogs.open.collab.net/svn/2008/07/subversion-merg.html)” correctly then the point of the mergeinfo property is so that Subversion knows what contributions have already been taken from other branches. The fact that Subversion keeps updating the upper revision in the property after each branch is merged reinforces my belief that this is an optimisation of some sort. In theory then you could remove those entries in the merginfo properties which reference dead branches. The only fly-in-the-ointment is that you probably won’t find a mergeinfo property with a single reference exactly because of the behaviour outlined above. So what about deleting the whole mergeinfo property on each file and folder?

`C:\> svn propdel svn:mergeinfo –R`\

Obviously you can’t do this on the source branch as it’s the _target_ of the branch that gets updated on a merge. So it would really have to be done on the trunk. If you know that you are never going to do a _large scale_ merge again from any release branches (i.e. trunk is the only active branch) then I think wiping out all the svn:mergeinfo properties could be the quick solution. And you still have the ability to cherry-pick changes from an old branch should the need arise.

When I say _all_ properties, there is one folder you should leave untouched – the root folder of the branch, e.g. /trunk or /branches/Release/0.1 or whatever. I believe that this advice is sound as long as you have not deleted any properties from files or sub-folders that have revisions _outside_ the range specified at the root folder. The svn:mergeinfo property _appears_ to be ‘inherited’ by its children so the act of deleting the property from the children doesn’t seem to stop Subversion from correctly inferring the merge set as long as a parent folder back up the tree has the right information.

<u>Faking a Merge</u>

One of the features I’ve seen in the TortoiseSVN UI that I’ve not yet used is the ability to record a merge without making any actual content changes. I’ve used similar features in the past when you have files you want to reconcile but the target version doesn’t physically need to change. The canonical example of this is a file that just contains the version number – it is different on every release branch but fixed to, say, 0.0.0 on the trunk. Merging these files will always cause a conflict so you only want to record the fact that the file has been ‘logically’ merged to ensure the entire merge is clean, i.e. no changes are left unaccounted for on the source branch.

I reckon this feature gives us a clean(ish) way to resolve the issue at strategic points in our development cycle – as long as we don’t perform long term development outside of the trunk. Here’s how I think it goes:-


* Feature branches are created, then merged (reintegrated) at their roots and discarded. This means only the root folder needs to have its svn:mergeinfo up-to-date. Once discarded the merge information in the root serves no further purpose, but also causes no problems. 
* Release branches on the other hand may have changes cherry-picked off the trunk and other temporary branches and the reverse may also occur when the release is patched. This is where we start accumulating svn:mergeinfo properties on the child files and folders. 
* Once we reach a stable point where we no longer expect to take <u>old</u> contributions from our previous release branches we delete all the child svn:mergeinfo properties on the trunk (leaving one at the root) and record merges at the trunk root for each branch that we cherry-picked from. The net result should be the trunk root having merge records accurate up to today. Fixes made after today on the release branches should still show up in future merges as candidates. 

I was going to add an additional condition on point 3 that there must be no open feature branches. My reservation is that Subversion may undo all this hard work when it comes to reintegrate a feature branch as there will be svn:mergeinfo properties on one branch but not the other. I haven’t done any experiments yet to see how Subversion handles this kind of property merging, but I will when a suitable opportunity arises.

<u>It’s Easy To Google The Answer Once You Know It</u>

When I first started looking into this issue, I didn’t really know what to search for and so didn’t find much. I then read bits of the [SVN Book](http://svnbook.red-bean.com/) and started writing this post based on what I thought might be the answer. Once I’d finished it I went back and Googled “[mergeinfo propdel](http://www.google.co.uk/search?hl=en&q=mergeinfo+propdel&meta=)” and what do you know? Yup, more posts about this issue than you can shake a stick at! I’m still publishing it though because I’ve not really seen one that explains _why_ you can use svn propdel and many of them don’t mention keeping the mergeinfo intact at the branch root. In fact [this](http://snipt.net/turnbullm/svn-delete-mergeinfo-on-tree-except-root-the-merge-target) is the most succinct answer I came across…



[*Personally I’ve never found the time waiting for ClearCase to generate the merge set on some 30,000 file views that excessive. At least not compared to the time you actually spend trying to decipher what code people have written to verify whether the merge is valid]




---
Original: <https://chrisoldwood.blogspot.com/2010/03/cleaning-up-svnmergeinfo-droppings.html>\
Copyright: Chris Oldwood 2010\
Published: Friday, 12 March 2010 at 22:48\
Labels: tools, version control
