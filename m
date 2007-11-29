From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [patch -mm 2/4] mqueue namespace : add unshare support
Date: Thu, 29 Nov 2007 15:14:14 -0500
Message-ID: <474F1D96.3060606@cs.columbia.edu>
References: <20071128163728.177495768@fr.ibm.com>>	<20071128164349.196734045@fr.ibm.com>>	<474DA61B.5030301@openvz.org>
	<474E944C.4020809@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <474E944C.4020809-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org



Cedric Le Goater wrote:
>>> Index: 2.6.24-rc3-mm2/include/linux/sched.h
>>> ===================================================================
>>> --- 2.6.24-rc3-mm2.orig/include/linux/sched.h
>>> +++ 2.6.24-rc3-mm2/include/linux/sched.h
>>> @@ -27,6 +27,7 @@
>>>  #define CLONE_NEWUSER		0x10000000	/* New user namespace */
>>>  #define CLONE_NEWPID		0x20000000	/* New pid namespace */
>>>  #define CLONE_NEWNET		0x40000000	/* New network namespace */
>>> +#define CLONE_NEWMQ		0x80000000	/* New posix mqueue namespace */
>> That's it :) We've run out of clone flags on 32-bit platforms :(
> 
> yes. 
> 
> I have been giving some thoughts to a clone2() to extend the flags but
> andrew is preparing to recycle CLONE_DETACHED and CLONE_STOPPED for
> 2.6.26. Some we might have some more time in front of us.

Two comments:

1) Does it ever make any sense to clone the IPC namespace *without* doing
so also for the MQ namespace or vice versa ?  Unless there is a good
reason for doing so, a single CLONE_IPCMQ flag would suffice.

2) Before coming up with a new clone2() or other solution, what about the
proposed (and debated) sys_indrect() -- if it gets merged it can provide
the solution.

Oren.

> 
> C.
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
