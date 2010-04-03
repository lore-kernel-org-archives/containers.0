From: Jiro SEKIBA <jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org>
Subject: Re: Linux Checkpoint-Restart - v19
Date: Sat, 3 Apr 2010 18:03:34 +0900
Message-ID: <18557515-762E-4EE6-90D7-C8F782E487B2@dependable-os.net>
References: <4B83106C.7040203@cs.columbia.edu>
	<a1c54a921003150155q4a0c7fc1vb02ba0464b07f452@mail.gmail.com>
	<4B9EBAF2.1060304@cs.columbia.edu>
	<0B4E8136-FFC6-490D-B04A-23A6E1A924FF@dependable-os.net>
	<20100317205556.GA20750@us.ibm.com>
	<EF179F3A-4FBA-4776-B7A4-48F5EF73DC9C@dependable-os.net>
	<4BA39971.2080402@cs.columbia.edu>
	<FF5CB8EA-436D-4685-B7A2-946A83DF3F78@dependable-os.net>
	<20100324164758.GA21021@us.ibm.com>
	<BC2CC354-59BA-465A-A863-0CDCD921A99A@dependable-os.net>
	<20100330030535.GA13362@us.ibm.com>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: multipart/mixed; boundary=Apple-Mail-6--79561397
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100330030535.GA13362-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


--Apple-Mail-6--79561397
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi,

Sorry for the late replay

On 2010/03/30, at 12:05, Serge E. Hallyn wrote:

> Quoting Jiro SEKIBA (jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org):
>> Hi
>>=20
>> On 2010/03/25, at 1:47, Serge E. Hallyn wrote:
>>=20
>>> Quoting Jiro SEKIBA (jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org):
>>>>> If it doesn't work, can you please describe again the exact order =
of
>>>>> commands that you use and the reported error(s) ?
>>>>>=20
>>>> I'll let you know in any cases.
>>>>=20
>>>> Thank you very much for the advice
>>>=20
>>> Hi Jiro,
>>>=20
>>> Can you fetch the latest cr_tests
>>> 	(git clone git://git.sr71.net/~hallyn/cr_tests)
>>>=20
>>> and
>>> 	cd cr_tests; make; cd simple
>>> 	sh runtests.sh
>>>=20
>>> and tell me whether the second (restart --self) test succeeds?
>>> If it fails, can you send me the cr_*/log2 contents?
>>>=20
>>=20
>> I've tried on ckpt-v20 and the above test looks OK.
>> And looks like self_checkpointing is working fine so far.
>>=20
>> However, I'm still not able to restart external checkpoint correctly.
>>=20
>> Here are the program and scripts I used for the test.
>> I used user-cr ckpt-v20 branch for checkpoint/restart program.
>>=20
>> This time I disconnect the program from tty completely.
>>=20
>> =
----------8<----------8<----------test.c----------8<----------8<----------=

>> #include <stdio.h>
>> #include <unistd.h>
>>=20
>> int main(void)
>> {
>>  FILE *fp;
>>  int i;
>>  pid_t pid;
>>  int st;
>>=20
>>  if(fork()) {
>>    return 0;
>=20
> Odd thing to do, not sure if you had a reason for it.  Still,
> should be fine :)
>=20
>>  } else {
>>    waitpid(getppid(), &st, NULL);
>>=20
>>    close(0);
>>    close(1);
>>    close(2);
>>    setsid();
>>=20
>>    if(fork()) {
>>      return 0;
>>    } else=20
>>      waitpid(getppid(), &st, NULL);
>>  }
>>=20
>>  //unlink("/tmp/test.out");
>>  fp =3D fopen("/tmp/test.out","w");
>>=20
>>  for(i=3D0;i<10;i++) {
>>    fprintf(fp,"%d\n",i);
>>    fflush(fp);
>>    sleep(1);
>>  }
>>=20
>>  fclose(fp);
>>  return 0;
>> }
>> =
----------8<----------8<----------test.c----------8<----------8<----------=

>>=20
>> =
----------8<----------8<----------checkpoint.sh----------8<----------8<---=
-------
>> #!/bin/sh
>>=20
>> CLOG=3Dcheckpoint.log
>> RLOG=3Drestart.log
>> rm -f $CLOG $RLOG
>>=20
>> ./test &
>> sleep 1
>> PID=3D$(ps x | grep test | grep -v grep |cut -f 2 -d' ')
>>=20
>> sleep 2
>> echo $PID > /cgroup/0/tasks
>>=20
>> echo FROZEN > /cgroup/0/freezer.state
>> ./checkpoint -l $CLOG -v $PID > ckpt.image
>>=20
>> mv /tmp/test.out /tmp/test.out.orig
>> cp /tmp/test.out.orig /tmp/test.out
>>=20
>> echo THAWED > /cgroup/0/freezer.state
>>=20
>> ./restart --pidns -l $RLOG -v -i ckpt.image;
>> =
----------8<----------8<----------checkpoint.sh----------8<----------8<---=
-------
>>=20
>> When I run the above script, I got following:
>>=20
>> # mount -t cgroup -o freezer cgroup /cgroup
>> # mkdir /cgroup/0
>> # sh checkpoint.sh
>> checkpoint id 8
>> Success
>>=20
>> Then, I'm expecting to see number 0 to 9 in /tmp/test.out, but
>> I only got 0 to 3, which is the state I froze and checkpointed the =
process.
>>=20
>> checkpoint.log and restart.log are empty.
>> I guess it means the programs worked fine.
>>=20
>> I attached the dmesg I got by the single session of the script.
>> It looks the restart tries to reopen /tmp/test.out.
>>=20
>> Could you give me any clues that I should check with?
>=20
> Hmm, with ckpt-v20 of both kernel and user, on a powerpc system, I =
get:
>=20
> elm3b203:/usr/src/jiro # sh checkpoint.sh
> checkpoint id 146
> Success
> elm3b203:/usr/src/jiro # ls
> checkpoint.log  checkpoint.sh  ckpt.image  restart.log  test  test.c
> elm3b203:/usr/src/jiro # cat /tmp/test.out
> 0
> 1
> 2
> 3
> 4
> 5
> 6
> 7
> 8
> 9

Nhh, OK, thank you very much for the testing the script.
 So what I'm doing is not a pointless so far..

>> My environment is Virtualbox VM.
>> I tried both with VT and without VT.
>> No virtualbox guest module is installed.
>=20
> What distro are you on?
>=20
I'm using ubuntu 9.10.
And I found that this ubuntu is using eglibc instead of glibc.
version is eglibc-2.10.1

> Anyway, two things to do.  First, add '-d' to your restart flags, so
>=20
> restart --pidns -l $RLOG -vd -i ckpt.image
>=20

I got following.. looks like somehow getting SEGV right after =
restarting.
I attached the whole log.

--------8<--------8<--------8<--------8<--------8<--------
<6113>number of tasks: 1
<6113>total tasks (including ghosts): 1
<6113>=3D=3D=3D=3D=3D=3D TASKS
<6113>  [0] pid 6102 ppid 1 sid 0 creator 0      =20
<6113>............
<6114>=3D=3D=3D=3D=3D=3D PIDS ARRAY
<6114>[0] pid 6102 ppid 1 sid 0 pgid 0
<6114>............
<6113>new pidns without init
<6113>forking coordinator in new pidns
<1>forking child vpid 6102 flags 0x1
<6102>root task pid 6102
<6102>pid 6102: pid 6102 sid 0 parent 1
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6102>about to call sys_restart(), flags 0
<1>forked child vpid 6102 (asked 6102)
<6114>c/r read input 16384
<6114>c/r read input 16384
...
<6114>c/r read input 16384
<6114>c/r read input 3605
<6114>c/r read input 0
<1>restart succeeded
<1>SIGCHLD: already collected
<1>task terminated with signal 11
<1>mimic sig 11
<1>c/r succeeded
<6113>SIGCHLD: already collected
<6113>task exited with status 0
--------8<--------8<--------8<--------8<--------8<--------


> That will give you debugging info.  For instance I get:
>=20
> checkpoint id 147
> <2507>number of tasks: 1
> <2507>total tasks (including ghosts): 1
> <2507>=3D=3D=3D=3D=3D=3D TASKS
> <2507>  [0] pid 2497 ppid 1 sid 0 creator 0      =20
> <2507>............
> <2507>new pidns without init
> <2507>forking coordinator in new pidns
> <2508>=3D=3D=3D=3D=3D=3D PIDS ARRAY
> <2508>[0] pid 2497 ppid 1 sid 0 pgid 0
> <2508>............
> <1>forking child vpid 2497 flags 0x1
> <1>forked child vpid 2497 (asked 2497)
> <2497>root task pid 2497
> <2497>pid 2497: pid 2497 sid 0 parent 1
> <2497>about to call sys_restart(), flags 0
> <2508>c/r read input 16384
> <2508>c/r read input 16384
> <2508>c/r read input 16384
> <2508>c/r read input 16384
> <2508>c/r read input 16384
> <2508>c/r read input 16384
> <2508>c/r read input 16384
> <2508>c/r read input 16384
> <2508>c/r read input 16384
> <2508>c/r read input 16384
> <2508>c/r read input 16384
> <2508>c/r read input 8336
> <2508>c/r read input 0
> Success
> <1>restart succeeded
> <1>SIGCHLD: already collected
> <1>task exited with status 0
> <1>mimic ret 0
> <1>c/r succeeded
> <2507>SIGCHLD: already collected
> <2507>task exited with status 0
>=20
>=20
> The other thing is to restart frozen and attach strace or gdb to the
> restarted test before thawing.  So perhaps
>=20
> # cc -g -o test test.c
> # sh checkpoint.sh
>=20
> Then when that has failed, do
>=20
> # mkdir /cgroup/1
> # restart -F /cgroup/1 -i ckpt.image
>=20
> That will hang.  Then in another terminal, you can
>=20
> # gdb -se test -p `pidof test`
>=20
> and in a third terminal,
>=20
> # echo THAWED > /cgroup/1/freezer.state
>=20
> Now in gdb you can figure out where the task is and step through
> to see where it dies.

I attached restarted process and found where I got SEGV,=20
here are the corresponding gdb log:

--------8<--------8<--------8<--------8<--------8<--------
0xb77eba50 in __nanosleep_nocancel () from /lib/tls/i686/cmov/libc.so.6
(gdb) n
Single stepping until exit from function __nanosleep_nocancel,=20
which has no line number information.
__sleep (seconds=3D0) at ../sysdeps/unix/sysv/linux/sleep.c:139
139       if (result =3D=3D 0 && seconds !=3D 0)
(gdb) n
148     }
(gdb)=20
main () at test.c:33
33        for(i=3D0;i<10;i++) {
(gdb)=20
34          fprintf(fp,"%d\n",i);
(gdb) s
__fprintf (stream=3D0x93b3008, format=3D0x8048801 "%d\n") at =
fprintf.c:27
27      __fprintf (FILE *stream, const char *format, ...)
(gdb)=20
33        done =3D vfprintf (stream, format, arg);
(gdb) s
_IO_vfprintf_internal (s=3D0x93b3008, format=3D0x8048801 "%d\n", =
ap=3D0xbf9c5448 "\004") at vfprintf.c:210
210     {
(gdb)=20
245       int save_errno =3D errno;
(gdb)=20
210     {
(gdb) n
245       int save_errno =3D errno;
(gdb) p save_errno
$1 =3D 2
(gdb) p errno
Cannot find thread-local variables on this target
(gdb) n

Program received signal SIGSEGV, Segmentation fault.
_IO_vfprintf_internal (s=3D0x93b3008, format=3D0x8048801 "%d\n", =
ap=3D0xbf9c5448 "\004") at vfprintf.c:245
245       int save_errno =3D errno;
--------8<--------8<--------8<--------8<--------8<--------

looks like errno is missing.  nhh.
I also attached the whole log of gdb.

Thanks,

regards,

>=20
> thanks,
> -serge


--Apple-Mail-6--79561397
Content-Disposition: attachment;
	filename=gdb.log
Content-Type: application/octet-stream;
	name="gdb.log"
Content-Transfer-Encoding: 7bit

# ps axuww |grep test
root      6177  0.6  0.0   1664    68 pts/0    D    18:58   0:00 ./test
root      6180  0.0  0.1   2800   800 pts/1    S+   18:58   0:00 grep test
# gdb -se ./test -d ~/work/deb/glibc/eglibc-2.10.1/stdio-common/ -p 6177
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
Attaching to program: /home/jir/cp/external/test, process 6177
Reading symbols from /lib/tls/i686/cmov/libc.so.6...Reading symbols from /usr/lib/debug/lib/tls/i686/cmov/libc-2.10.1.so...done.
(no debugging symbols found)...done.
Loaded symbols for /lib/tls/i686/cmov/libc.so.6
Reading symbols from /lib/ld-linux.so.2...Reading symbols from /usr/lib/debug/lib/ld-2.10.1.so...done.
(no debugging symbols found)...done.
Loaded symbols for /lib/ld-linux.so.2
0xb78ac430 in __kernel_vsyscall ()
(gdb) n
Single stepping until exit from function __kernel_vsyscall, 
which has no line number information.
0xb77eba50 in __nanosleep_nocancel () from /lib/tls/i686/cmov/libc.so.6
(gdb) n
Single stepping until exit from function __nanosleep_nocancel, 
which has no line number information.
__sleep (seconds=0) at ../sysdeps/unix/sysv/linux/sleep.c:139
139	  if (result == 0 && seconds != 0)
(gdb) n
148	}
(gdb) 
main () at test.c:33
33	  for(i=0;i<10;i++) {
(gdb) 
34	    fprintf(fp,"%d\n",i);
(gdb) s
__fprintf (stream=0x93b3008, format=0x8048801 "%d\n") at fprintf.c:27
27	__fprintf (FILE *stream, const char *format, ...)
(gdb) 
33	  done = vfprintf (stream, format, arg);
(gdb) s
_IO_vfprintf_internal (s=0x93b3008, format=0x8048801 "%d\n", ap=0xbf9c5448 "\004") at vfprintf.c:210
210	{
(gdb) 
245	  int save_errno = errno;
(gdb) 
210	{
(gdb) n
245	  int save_errno = errno;
(gdb) p save_errno
$1 = 2
(gdb) p errno
Cannot find thread-local variables on this target
(gdb) n

Program received signal SIGSEGV, Segmentation fault.
_IO_vfprintf_internal (s=0x93b3008, format=0x8048801 "%d\n", ap=0xbf9c5448 "\004") at vfprintf.c:245
245	  int save_errno = errno;
(gdb) 

--Apple-Mail-6--79561397
Content-Disposition: attachment;
	filename=restart-error.log
Content-Type: application/octet-stream;
	name="restart-error.log"
Content-Transfer-Encoding: 7bit

<6113>number of tasks: 1
<6113>total tasks (including ghosts): 1
<6113>====== TASKS
<6113>	[0] pid 6102 ppid 1 sid 0 creator 0       
<6113>............
<6114>====== PIDS ARRAY
<6114>[0] pid 6102 ppid 1 sid 0 pgid 0
<6114>............
<6113>new pidns without init
<6113>forking coordinator in new pidns
<1>forking child vpid 6102 flags 0x1
<6102>root task pid 6102
<6102>pid 6102: pid 6102 sid 0 parent 1
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6102>about to call sys_restart(), flags 0
<1>forked child vpid 6102 (asked 6102)
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 16384
<6114>c/r read input 3605
<6114>c/r read input 0
<1>restart succeeded
<1>SIGCHLD: already collected
<1>task terminated with signal 11
<1>mimic sig 11
<1>c/r succeeded
<6113>SIGCHLD: already collected
<6113>task exited with status 0

--Apple-Mail-6--79561397
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii



--Apple-Mail-6--79561397
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--Apple-Mail-6--79561397--
