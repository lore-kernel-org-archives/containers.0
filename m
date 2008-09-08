From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: [RFC v3][PATCH 1/9] Create syscalls: sys_checkpoint,
	sys_restart
Date: Mon, 08 Sep 2008 18:07:56 +0200
Message-ID: <48C54DDC.3090704@fr.ibm.com>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>	<Pine.LNX.4.64.0809040401320.5982@takamine.ncl.cs.columbia.edu>	<20080904144223.GA19364@us.ibm.com>
	<200809081902.33709.amirkin@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200809081902.33709.amirkin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <amirkin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

>>> --- /dev/null
>>> +++ b/checkpoint/sys.c
>>> @@ -0,0 +1,35 @@
>>> +/*
>>> + *  Generic container checkpoint-restart
>>> + *
>>> + *  Copyright (C) 2008 Oren Laadan
>>> + *
>>> + *  This file is subject to the terms and conditions of the GNU General
>>> Public + *  License.  See the file COPYING in the main directory of the
>>> Linux + *  distribution for more details.
>>> + */
>>> +
>>> +#include <linux/sched.h>
>>> +#include <linux/kernel.h>
>>> +
>>> +/**
>>> + * sys_checkpoint - checkpoint a container
>>> + * @pid: pid of the container init(1) process
>>> + * @fd: file to which dump the checkpoint image
>>> + * @flags: checkpoint operation flags
>>> + */
>>> +asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
>>> +{
>>> +	pr_debug("sys_checkpoint not implemented yet\n");
>>> +	return -ENOSYS;
>>> +}
>>> +/**
>>> + * sys_restart - restart a container
>>> + * @crid: checkpoint image identifier
>> So can we compare your api to Andrey's?

Jumping in the API thread : how will this API interact with the namespaces ? 

I think the exact question is how are we seeing the restart sequence ?
shall we (1) restart from inside a set of pre established namespaces or 
(2) restore the state of the namespaces upon restart ? 

I think (1) is the best option in semantic, because it's closer to what
the kernel does:  create a directory (a container) and then fill it with
files (tasks). That's how the cgroup framework works and I have the
feeling we will be using this framework to build the 'super' container
object. nop ?

This direction has an impact on the API because the restart sequence 
will depend on a set of preliminary settings to create an 'empty' 
container which can then be used to exec() tasks or restart() tasks. This 
is a very different API than a magical restart() syscall creating 
hundreds of namespaces and zillions of tasks from scratch using an 
opaque binary blob. less attractive for sure but it feels more kernel 
friendly :)


But, may be you have addressed this topic at the summit and the question
is closed ?

C. 
