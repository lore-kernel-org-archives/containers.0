From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/6][lxc][v3] Link LXC with USERCR
Date: Thu, 1 Apr 2010 22:54:18 -0700
Message-ID: <20100402055418.GA8990@us.ibm.com>
References: <20100331070440.GA21570@us.ibm.com> <4BB3A981.4020709@fr.ibm.com>
	<20100331201240.GA26773@us.ibm.com> <4BB3B7E1.8080608@free.fr>
	<20100331212359.GA18934@us.ibm.com> <4BB3BF02.7060402@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BB3BF02.7060402-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano [daniel.lezcano-GANU6spQydw@public.gmane.org] wrote:
> Sukadev Bhattiprolu wrote:
>> Daniel Lezcano [daniel.lezcano-GANU6spQydw@public.gmane.org] wrote:
>>   
>>> But most of the simple test programs I run, exit right after the 
>>> restart  was marked successful instead of continuing their execution.
>>>
>>> In the kernel I see the traces:
>>>
>>> [26108:3:c/r:restore_debug_free:145] active pid was 3, ctx->errno 0
>>> [26108:3:c/r:restore_debug_free:147] kflags 6 uflags 0 oflags 3
>>> [26108:3:c/r:restore_debug_free:149] task[0] to run 1
>>> [26108:3:c/r:restore_debug_free:149] task[1] to run 2
>>> [26108:3:c/r:restore_debug_free:149] task[2] to run 3
>>> [26108:3:c/r:restore_debug_free:174] pid 26104 type Coord state Success
>>> [26108:3:c/r:restore_debug_free:174] pid 26106 type Root state Success
>>> [26108:3:c/r:restore_debug_free:174] pid 26107 type Task state Success
>>> [26108:3:c/r:restore_debug_free:174] pid 26108 type Task state Success
>>> [26108:3:c/r:pgarr_release_pages:102] total pages 0
>>> [26108:3:c/r:do_restart:1446] sys_restart returns -516
>>>
>>> What does mean -516 ? an error ?
>>>     
>>
>> Could it be ERESTART_RESTARTBLOCK ? Also, can you let us know what application
>> causes this ? Are any signals generated ?
>>   
> That happens with sleep.

Oh, I misread earlier and thought both checkpoint and restat of sleep worked.

Anyway, when I run C/R a simple program with sleep(), I see the above errors
too, but I think they are expected if the checkpoint happened during sleep -
the system call returned prematurely and after restart the syscall returns
-ERESTART_RESTARTBLOCK which I think causes libc to repeat the syscall.

I get the above ERESTART* error in dmesg, when I lxc-checkpoint/lxc-restart
the following simple program, but, application restarts correctly and
continues to write to /tmp/foo.

If fd == 1, however, the writes to stdout do not show up on stdout
even though the application continues to run (you can strace and
see that 'i' continues to get incremented). I am chasing the stdout
problem.

Sukadev
---
#include <stdio.h>
#include <string.h>
#include <sys/fcntl.h>

main()
{
        int i, n, fd;
        char buf[256];

        fd = open("/tmp/foo", O_CREAT|O_RDWR|O_TRUNC, 0666);
        if (fd < 0) {
                perror("open()");
                exit(1);
        }

        for (i = 0; i < 1000; i++) {
                sprintf(buf, "i %d\n", i);
                n = write(fd, buf, strlen(buf));
                if (n != strlen(buf))
                        perror("write()");
                sleep(1);
        }
}
