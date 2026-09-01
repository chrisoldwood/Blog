## WMI Performance Anomaly: Querying the Number of CPU Cores

As one of the few devs that both likes and is reasonably well-versed in PowerShell I became the point of contact for a colleague that was bemused by a performance oddity when querying the number of cores on a host. He was introducing Ninja into the build and needed to throttle its expectations around how many actual cores there were because hyperthreading was enabled and our compilation intensive build was being slowed by its bad guesswork [1].

The PowerShell query for the number of cores (rather than logical processors) was pulled straight from the Internet and seemed fairly simple:

```
(Get-WmiObject Win32_Processor \|     ```
 measure -Property NumberOfCores -Sum).Sum

However when he ran this it took a whopping 4 seconds! Although he was using a Windows VM running on QEMU/KVM, I knew from benchmarking a while back this setup added very little overhead, i.e. only a percentage or two, and even on my work PC I observed a similar tardy performance. Here’s how we measured it:

```
Measure-Command {     ```
 (Get-WmiObject Win32_Processor \|      
 measure -Property NumberOfCores -Sum).Sum      
} \| % TotalSeconds      <br style="box-sizing: inherit;">4.0867539

(As I write my HP laptop running Windows 11 is still showing well over a second to run this command.)

My first instinct was that this was some weird overhead with PowerShell, what with it being .Net based so I tried the classic native `wmic`\ tool under the Git Bash to see how that behaved:

`$ time WMIC CPU Get //Format:List \| grep NumberOfCores <wbr style="box-sizing: inherit;">\| cut -d '=' -f 2 \| awk '{ sum += $1 } END{ print sum }'      <br style="box-sizing: inherit;">4      <br style="box-sizing: inherit;">      <br style="box-sizing: inherit;">real <wbr style="box-sizing: inherit;"> <wbr style="box-sizing: inherit;">0m4.138s`\

As you can see there was no real difference so that discounted the .Net theory. For kicks I tried `lscpu`\ under the WSL based Ubuntu 20.04 and that returned a far more sane time:

`$ time lscpu > /dev/null`\

`real 0m0.064s`\

I presume that `lscpu`\ will do some direct spelunking but even so the added machinery of WMI should not be adding the kind of ridiculous overhead that we were seeing. I even tried my own [C++ based WMICmd](http://www.chrisoldwood.com/win32.htm#wmicmd) tool as I knew that was talking directly to WMI with no extra cleverness going on behind the scenes, but I got a similar outcome.

On a whim I decided to try pushing more work onto WMI by passing a custom query instead so that it only needed to return the one value I cared about:

```
Measure-Command {     ```
 (Get-WmiObject -Query 'select NumberOfCores from Win32_Processor' \|      
 measure -Property NumberOfCores -Sum).Sum      
} \| % TotalSeconds      
0.0481644

Lo-and-behold that gave a timing in the _tens of milliseconds _range which was far closer to `lscpu`\ and definitely more like what we were expecting.

While my office machine has some “industrial strength” [2] anti-virus software that could easily be to blame, my colleague’s VM didn’t, only the default of MS Defender. So at this point I’m none the wiser about what was going on although my personal laptop suggests that the native tools of `wmic`\ and `wmicmd`\ are both returning times more in-line with `lscpu`\ so something funky is going on somewhere.



[1] Hyper-threaded cores meant Ninja was scheduling too much concurrent work.

[2] Read that as “massively interfering”!




---
Original: <https://chrisoldwood.blogspot.com/2022/10/wmi-performance-anomaly-querying-number.html>\
Copyright: Chris Oldwood 2022\
Published: Monday, 31 October 2022 at 00:12\
Labels: scripting, tools
