From: Jiro SEKIBA <jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org>
Subject: Re: Linux Checkpoint-Restart - v19
Date: Tue, 6 Apr 2010 11:54:20 +0900
Message-ID: <39FCECBC-BFE3-4328-BCFC-CBACA3CB442E@dependable-os.net>
References: <0B4E8136-FFC6-490D-B04A-23A6E1A924FF@dependable-os.net>
	<20100317205556.GA20750@us.ibm.com>
	<EF179F3A-4FBA-4776-B7A4-48F5EF73DC9C@dependable-os.net>
	<4BA39971.2080402@cs.columbia.edu>
	<FF5CB8EA-436D-4685-B7A2-946A83DF3F78@dependable-os.net>
	<20100324164758.GA21021@us.ibm.com>
	<BC2CC354-59BA-465A-A863-0CDCD921A99A@dependable-os.net>
	<20100330030535.GA13362@us.ibm.com>
	<18557515-762E-4EE6-90D7-C8F782E487B2@dependable-os.net>
	<20100405140629.GG32049@us.ibm.com>
	<20100405143157.GX3345@count0.beaverton.ibm.com>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100405143157.GX3345-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi

On 2010/04/05, at 23:31, Matt Helsley wrote:

> On Mon, Apr 05, 2010 at 09:06:29AM -0500, Serge E. Hallyn wrote:
>> Quoting Jiro SEKIBA (jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org):
>>> I'm using ubuntu 9.10.
>>> And I found that this ubuntu is using eglibc instead of glibc.
>>> version is eglibc-2.10.1
>> 
>> Interesting.
>> 
>>> (gdb) p errno
>>> Cannot find thread-local variables on this target
>> 
>> I guess I'll take a look at the eglibc source code.
> 
> Perhaps the thread db isn't loading properly. gdb uses the thread db
> library, or so I've heard, from glibc to help debug the program.
> Unfortunately, I haven't been following eglibc and I'm not familiar with
> how either loads the thread db library. But it sounds like there may be
> a problem there. A wild guess -- perhaps a subtle difference in eglibc
> is breaking its gdb support.
> 
Nhh, I see.  I tried to attach the program without checkpoint/restart.
And I got same error, gdb cannot find thread-locale variables on this target.
So it would be something wrong with eglibc build.

here I quick googled and found that it says, it requires linking with pthread library
to display thread-local variables. 
This time I could display the errno with normal execution by linking with pthread.

--------8<--------8<--------8<--------8<--------
# ldd test
	linux-gate.so.1 =>  (0xb771a000)
	libpthread.so.0 => /lib/tls/i686/cmov/libpthread.so.0 (0xb76ef000)
	libc.so.6 => /lib/tls/i686/cmov/libc.so.6 (0xb75aa000)
	/lib/ld-linux.so.2 (0xb771b000)
# ./test 
# ps axuw |grep test
root      8255  0.0  0.0   1768   364 ?        S    11:46   0:00 ./test
root      8257  0.0  0.1   2800   804 pts/1    S+   11:46   0:00 grep test
# gdb -se ./test -d /home/jir/work/deb/glibc/eglibc-2.10.1/stdio-common/ -p 8255
GNU gdb (GDB) 7.0-ubuntu
Copyright (C) 2009 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "i486-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>...
Reading symbols from /home/jir/cp/external/test...done.
Attaching to program: /home/jir/cp/external/test, process 8255
Reading symbols from /lib/tls/i686/cmov/libpthread.so.0...Reading symbols from /usr/lib/debug/lib/tls/i686/cmov/libpthread-2.10.1.so...done.
[Thread debugging using libthread_db enabled]
(no debugging symbols found)...done.
Loaded symbols for /lib/tls/i686/cmov/libpthread.so.0
Reading symbols from /lib/tls/i686/cmov/libc.so.6...Reading symbols from /usr/lib/debug/lib/tls/i686/cmov/libc-2.10.1.so...done.
(no debugging symbols found)...done.
Loaded symbols for /lib/tls/i686/cmov/libc.so.6
Reading symbols from /lib/ld-linux.so.2...Reading symbols from /usr/lib/debug/lib/ld-2.10.1.so...done.
(no debugging symbols found)...done.
Loaded symbols for /lib/ld-linux.so.2
0xb7863430 in __kernel_vsyscall ()
(gdb) n
Single stepping until exit from function __kernel_vsyscall, 
which has no line number information.
0xb7789a50 in __nanosleep_nocancel () from /lib/tls/i686/cmov/libc.so.6
(gdb) 
Single stepping until exit from function __nanosleep_nocancel, 
which has no line number information.
__sleep (seconds=0) at ../sysdeps/unix/sysv/linux/sleep.c:139
139	  if (result == 0 && seconds != 0)
(gdb) 
148	}
(gdb) 
main () at test.c:36
36	  for(i=0;i<10;i++) {
(gdb) 
37	    fprintf(fp,"%d\n",i);
(gdb) s
__fprintf (stream=0x82cd008, format=0x80488a1 "%d\n") at fprintf.c:27
27	__fprintf (FILE *stream, const char *format, ...)
(gdb) s
33	  done = vfprintf (stream, format, arg);
(gdb) s
_IO_vfprintf_internal (s=0x82cd008, format=0x80488a1 "%d\n", ap=0xbff87e48 "\a") at vfprintf.c:210
210	{
(gdb) 
245	  int save_errno = errno;
(gdb) p errno
$1 = 10
(gdb) n
210	{
(gdb) 
245	  int save_errno = errno;
(gdb) 
1288	  ORIENT;
(gdb) 
1292	  ARGCHECK (s, format);
--------8<--------8<--------8<--------8<--------

I tried checkpointing/restarting with this binary, but still get SEGV at the same point, 
still get same gdb warning(Cannot find thread-local variables on this target)

I also tried to link 'restart' program with pthread (dunno it helps or not),
but again same result.

Does anybody try on ubuntu(or eglibc) and get correct result?

thanks,

regards,


> Cheers,
> 	-Matt Helsley
> 
