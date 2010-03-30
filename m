From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Linux Checkpoint-Restart - v19
Date: Mon, 29 Mar 2010 22:05:35 -0500
Message-ID: <20100330030535.GA13362@us.ibm.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BC2CC354-59BA-465A-A863-0CDCD921A99A-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jiro SEKIBA <jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Jiro SEKIBA (jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org):
> Hi
> 
> On 2010/03/25, at 1:47, Serge E. Hallyn wrote:
> 
> > Quoting Jiro SEKIBA (jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org):
> >>> If it doesn't work, can you please describe again the exact order of
> >>> commands that you use and the reported error(s) ?
> >>> 
> >> I'll let you know in any cases.
> >> 
> >> Thank you very much for the advice
> > 
> > Hi Jiro,
> > 
> > Can you fetch the latest cr_tests
> > 	(git clone git://git.sr71.net/~hallyn/cr_tests)
> > 
> > and
> > 	cd cr_tests; make; cd simple
> > 	sh runtests.sh
> > 
> > and tell me whether the second (restart --self) test succeeds?
> > If it fails, can you send me the cr_*/log2 contents?
> > 
> 
> I've tried on ckpt-v20 and the above test looks OK.
> And looks like self_checkpointing is working fine so far.
> 
> However, I'm still not able to restart external checkpoint correctly.
> 
> Here are the program and scripts I used for the test.
> I used user-cr ckpt-v20 branch for checkpoint/restart program.
> 
> This time I disconnect the program from tty completely.
> 
> ----------8<----------8<----------test.c----------8<----------8<----------
> #include <stdio.h>
> #include <unistd.h>
> 
> int main(void)
> {
>   FILE *fp;
>   int i;
>   pid_t pid;
>   int st;
> 
>   if(fork()) {
>     return 0;

Odd thing to do, not sure if you had a reason for it.  Still,
should be fine :)

>   } else {
>     waitpid(getppid(), &st, NULL);
> 
>     close(0);
>     close(1);
>     close(2);
>     setsid();
> 
>     if(fork()) {
>       return 0;
>     } else 
>       waitpid(getppid(), &st, NULL);
>   }
> 
>   //unlink("/tmp/test.out");
>   fp = fopen("/tmp/test.out","w");
> 
>   for(i=0;i<10;i++) {
>     fprintf(fp,"%d\n",i);
>     fflush(fp);
>     sleep(1);
>   }
> 
>   fclose(fp);
>   return 0;
> }
> ----------8<----------8<----------test.c----------8<----------8<----------
> 
> ----------8<----------8<----------checkpoint.sh----------8<----------8<----------
> #!/bin/sh
> 
> CLOG=checkpoint.log
> RLOG=restart.log
> rm -f $CLOG $RLOG
> 
> ./test &
> sleep 1
> PID=$(ps x | grep test | grep -v grep |cut -f 2 -d' ')
> 
> sleep 2
> echo $PID > /cgroup/0/tasks
> 
> echo FROZEN > /cgroup/0/freezer.state
> ./checkpoint -l $CLOG -v $PID > ckpt.image
> 
> mv /tmp/test.out /tmp/test.out.orig
> cp /tmp/test.out.orig /tmp/test.out
> 
> echo THAWED > /cgroup/0/freezer.state
> 
> ./restart --pidns -l $RLOG -v -i ckpt.image;
> ----------8<----------8<----------checkpoint.sh----------8<----------8<----------
> 
> When I run the above script, I got following:
> 
> # mount -t cgroup -o freezer cgroup /cgroup
> # mkdir /cgroup/0
> # sh checkpoint.sh
> checkpoint id 8
> Success
> 
> Then, I'm expecting to see number 0 to 9 in /tmp/test.out, but
> I only got 0 to 3, which is the state I froze and checkpointed the process.
> 
> checkpoint.log and restart.log are empty.
> I guess it means the programs worked fine.
> 
> I attached the dmesg I got by the single session of the script.
> It looks the restart tries to reopen /tmp/test.out.
> 
> Could you give me any clues that I should check with?

Hmm, with ckpt-v20 of both kernel and user, on a powerpc system, I get:

elm3b203:/usr/src/jiro # sh checkpoint.sh
checkpoint id 146
Success
elm3b203:/usr/src/jiro # ls
checkpoint.log  checkpoint.sh  ckpt.image  restart.log  test  test.c
elm3b203:/usr/src/jiro # cat /tmp/test.out
0
1
2
3
4
5
6
7
8
9

> My environment is Virtualbox VM.
> I tried both with VT and without VT.
> No virtualbox guest module is installed.

What distro are you on?

Anyway, two things to do.  First, add '-d' to your restart flags, so

restart --pidns -l $RLOG -vd -i ckpt.image

That will give you debugging info.  For instance I get:

checkpoint id 147
<2507>number of tasks: 1
<2507>total tasks (including ghosts): 1
<2507>====== TASKS
<2507>  [0] pid 2497 ppid 1 sid 0 creator 0       
<2507>............
<2507>new pidns without init
<2507>forking coordinator in new pidns
<2508>====== PIDS ARRAY
<2508>[0] pid 2497 ppid 1 sid 0 pgid 0
<2508>............
<1>forking child vpid 2497 flags 0x1
<1>forked child vpid 2497 (asked 2497)
<2497>root task pid 2497
<2497>pid 2497: pid 2497 sid 0 parent 1
<2497>about to call sys_restart(), flags 0
<2508>c/r read input 16384
<2508>c/r read input 16384
<2508>c/r read input 16384
<2508>c/r read input 16384
<2508>c/r read input 16384
<2508>c/r read input 16384
<2508>c/r read input 16384
<2508>c/r read input 16384
<2508>c/r read input 16384
<2508>c/r read input 16384
<2508>c/r read input 16384
<2508>c/r read input 8336
<2508>c/r read input 0
Success
<1>restart succeeded
<1>SIGCHLD: already collected
<1>task exited with status 0
<1>mimic ret 0
<1>c/r succeeded
<2507>SIGCHLD: already collected
<2507>task exited with status 0


The other thing is to restart frozen and attach strace or gdb to the
restarted test before thawing.  So perhaps

# cc -g -o test test.c
# sh checkpoint.sh

Then when that has failed, do

# mkdir /cgroup/1
# restart -F /cgroup/1 -i ckpt.image

That will hang.  Then in another terminal, you can

# gdb -se test -p `pidof test`

and in a third terminal,

# echo THAWED > /cgroup/1/freezer.state

Now in gdb you can figure out where the task is and step through
to see where it dies.

thanks,
-serge
