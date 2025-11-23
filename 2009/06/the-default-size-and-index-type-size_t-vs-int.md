# The Default 'Size' & 'Index' Type: size_t vs int

I started out writing applications in C on 16-bit Windows. The company I worked for favoured using the Windows SDK functions instead of the C-Runtime, so for example I would use lstrlen() instead of strlen(). Unfortunately, the Windows SDK is biased towards using int instead of size_t for parameters and return values that represent counts and indices. As I moved into working on MFC based applications the habit continued as MFC has it's own container types, such as CArray, which also favoured int, as does the popular common controls, like the CListCtrl. The final bias towards int was the use of -1 as an error code when using controls such as the combo and listboxes through constants such as CB_ERR and LB_ERR.

Unfortunately this habit got carried over into [my own framework](http://chrisoldwood.blogspot.com/2009/05/potted-history-of-my-windows-framework.html) because I also had my own string and container classes and my wrapper facade is very thin in many places. So it wasn't much of an issue until I finally junked my clunky containers and started using the STL in preference...

All of a sudden the compiler was constantly complaining about signed/unsigned comparisons which would ripple through my code as loops where changed from,

<span style="font-family:courier new;">for (**int** i = 0; i < v.**Size**(); ++i)

initially to,

<span style="font-family:courier new;">for (**int** i = 0; i < v.**size**(); ++i)

and finally to,

<span style="font-family:courier new;">for (**size_t** i = 0; i != v.**size**(); ++i)

(Changing the code structure to use iterators instead - the correct solution - was going to be an exercise for another day.)

I realised that a large part of my codebase was int-based instead of size_t-based and the number of uses of static_cast was growing and making the code even uglier so I decided to bite the bullet and go size_t across the board. The entire codebase isn't massive (160,000 LOC or 45,000 SLOC according to the excellent [Source Monitor](http://www.campwoodsw.com/sourcemonitor.html)) and it took a few train journeys but it felt good. However one subsequent annoyance was with the comparisons to CB_ERR etc as they are just #define's for -1 so I followed the STL string type (which returns -1 as a result for some of the find() methods) and declared a global constant,

<span style="font-family:courier new;">namespace Core
{
static const size_t npos = static_cast<size_t>(-1);
}

In retrospect I realise I should have declared an 'npos' in each class, such as CComboBox and CListBox, instead of globally, but there was quite a bit of code that just had "= -1" as an argument default and I got lazy trying to resolve all the issues quickly.

Now my codebase felt more wholesome because of the large scale refactoring of int to size_t and I felt more aligned to the C++ world. So I decided to see what happened when I ran the 64-bit cross compiler from the Platform SDK over it....

Yup, lots of errors about truncation from a 64-bit value to a 32-bit value (I always compile with /W4 /Wx) , i.e. conversions from a size_t to an int or DWORD! It appears that functions like GetWindowText() still traffic in int's and many of the I/O functions that specified sizes for buffers still use DWORD's. So, more static_casts went in.

And now the feeling of wholesomeness is gone again as I contemplate the impedance mismatch between the Windows API and the C/C++ standard libraries. My framework is largely a Wrapper Facade and is therefore thin, but I don't believe it should expose the use of int or DWORD to its clients. I also have use of my own 'uint' type in various places where I knew an int was undesirable, but that now also requires a cast when the source is a size_t. I even started a thread on one of the [ACCU](http://www.accu.org/) channels to see if other people felt that size_t was overused and if it would be a good idea to at least use an index_t typedef for [] operators and index style parameters.

For now the possibly excessive use of size_t stays whilst I chew the fat. I also want to deal with the nastiness that WPARAM and LPARAM has created in the framework due to the documentation using these types without describing what a suitable type would be (e.g. the Character Code - for WM_CHAR) as I want to use richer typedefs instead of the limited set the Windows API uses (e.g. WCL::TimerID instead of UINT_PTR).



---
Published: Monday, 22 June 2009 at 14:28\
Labels: 64-bit windows, c++
