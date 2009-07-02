From: Adam Majer <adamm-+878OnfSgr5BDgjK7y7TUQ@public.gmane.org>
Subject: Re: [lxc-devel] segfault on shutdown if containers running
Date: Wed, 01 Jul 2009 23:29:45 -0500
Message-ID: <4A4C37B9.7080108@zombino.com>
References: <4A42D033.5060202@zombino.com> <4A432714.4040606@free.fr>
	<4A480F08.3040102@zombino.com> <4A48555E.9060607@free.fr>
	<4A491745.2050002@zombino.com> <4A491FDA.1050904@fr.ibm.com>
	<4A4AA6D6.2090308@zombino.com> <4A4B1AF7.8090009@fr.ibm.com>
	<20090702010424.GA28523@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702010424.GA28523-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
> Daniel Lezcano [dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>> Adam Majer wrote:
>>>>>>> chrdev_open + 0x148/0x167
>>>>>>> chrdev_open + 0x0/0x167
>>>>>>> __dentry_open + 0x148/0x260
>>>>>>> do_flip_open + 0x468/0x85a
>>>>>>> alloc_fd + ....
>>>>>>> do_sys_gen + ...
>>>>>>> system_call_fastpath + ....
>>>>>>>
>>>>>>> RIP tty_open
>>>>>> which kernel are you using ? could you run :
>>>>>>
>>>>>>     $ addr2line -e <vmlinux> ffffffff803b26f1
>>>>> Would setting this to yes produce a backtrace with line numbers?
>>>> Yes and maybe CONFIG_FRAME_POINTER too.
>>> Well, adding symbols didn't add line numbers to the backtrace. But now I
>>> can use addr2line with the vmlinux (all 78mb of it) to get you guys a
>>> backtrace with line numbers :)
>>> So,
>>> OOPS (NULL pointer deference) at
>>>   drivers/char/tty_io.c:1321  (tty_open)
>>> Backtrace,
>>>   fs/char_dev.c:397 (chrdev_open)
>>>   fs/char_dev.c:357 (chrdev_open)
>>>   fs/open.c:841     (__dentry_open)
>>>   arch/x86/include/asm/atomic_64.h:117 (do_flip_open)
>>>   fs/file.c:459     (alloc_fd)
>>>   ...
>> Excellent !
>>
>> Suka ? Isn't this oops related to the newpts instance ?
>>
> 
> 
> What version of the kernel are you running ? 
> 
> Could it be this bug: http://lkml.org/lkml/2009/1/26/274
> It was fixed by following commit and should be in 2.6.29.
> 
> 	commit 808ffa3d302257b9dc37b1412c1fcdf976fcddac
> 	Author: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 	Date:   Tue Jan 27 11:50:37 2009 +0000
> 
> Sukadev

It's a Debian stock 2.6.30-1 kernel, so the 2.6.30. The original OOPS
was on the AMD64, but I've also just had a very similar OOPS in a 686
(32-bit) version of the same kernel.

The original oops (above) occurred when I did,

  lxc-start -n container &
  poweroff (in root system)

segfault occurred each time after the prompt "attempting to kill all
processes...." then oops then a "failed" from the cleanup process. If
the container is shut down prior to poweroff, no oops.


The following is all a 686 2.6.30 stock debian kernel,

Another OOPS (same function, slightly different backtrace),

  1. ssh to root machine
  2. lxc-start -n container &
  3. lxc-console -n container -t 1 &
  4. close ssh on originating machine
  5. re-ssh into the machine

at this point I had a console into the container and to the root machine
(where I ssh in) that were intermixed. Then the segfault occurred with
the following backtrace. Debugging info not compiled into it, but it is
similar symbols,

  IP: tty_open + 0x1a5
      chrdev_open
      dput
      chrdev_open
      __dentry_open
      ....

Again, I had a prompt from within the container and from the parent
machine when I re-ssh into the parent machine. So some ttys got intermixed.


I've also managed to generate a hard lockup of the kernel from within
the container, but that seems to be related to networking. The process
for that was,

  1. bridge + veth interface
  2. start container and networking up from within container
  3. ssh into container
  4. ifdown in cantainer
  5. at this point the ssh session remained in spite of container
networking down!!
  6. ifup container (new IP)
  7. hard lockup occurred with the backtrace scrolled way off screen


- Adam

PS. Running lxc-checkconfig on the Debian kernel yields,

Found kernel config file /boot/config-2.6.30-1-686
--- Namespaces ---
Namespaces: enabled
Utsname namespace: enabled
Ipc namespace: enabled
Pid namespace: enabled
User namespace: enabled
Network namespace: enabled
Multiple /dev/pts instances: enabled

--- Control groups ---
Cgroup: enabled
Cgroup namespace: enabled
Cgroup device: enabled
Cgroup sched: enabled
Cgroup cpu account: enabled
Cgroup memory controller: disabled
Cgroup cpuset: enabled

--- Misc ---
Veth pair device: enabled
Macvlan: enabled

I can provide you with the complete kernel config if you want it.
