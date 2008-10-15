From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Date: Wed, 15 Oct 2008 17:13:21 +0200
Message-ID: <48F60891.1070807__20501.1863531128$1224083776$gmane$org@fr.ibm.com>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>	<20081009124658.GE2952@elte.hu>
	<1223557122.11830.14.camel@nimitz>	<20081009131701.GA21112@elte.hu>
	<1223559246.11830.23.camel@nimitz>	<20081009134415.GA12135@elte.hu>
	<1223571036.11830.32.camel@nimitz>
	<20081010153951.GD28977@elte.hu> <48F30315.1070909@fr.ibm.com>
	<48F3737B.6070904@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48F3737B.6070904-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

>> the self checkpoint and self restore syscalls, like Oren is proposing, are 
>> simpler but they require the process cooperation to be triggered. we could
>> image doing that in a special signal handler which would allow us to jump
>> in the right task context. 
> 
> This description is not accurate:
> 
> For checkpoint, both implementations use an "external" task to read the state
> from other tasks. (In my implementation that "other" task can be self).

which is good, since some applications want to checkpoint themselves and that's
a way to provide them a generic service.
 
> For restart, both implementation expect the restarting process to restore its
> own state. They differ in that Andrew's patchset also creates that process
> while mine (at the moment) relies on the existing (self) task.

hmm, 

It seems that your patchset relies on the fact that the tasks are checkpointed 
and restarted at a syscall boundary. right ? I'm might be completely wrong
on that :)

> In other words, none of them will require any cooperation on part of the
> checkpointed tasks, and both will require cooperation on part of the restarting
> tasks (the latter is easy since we create and fully control these tasks).

yes.

>> I don't have any preference but looking at the code of the different patchsets
>> there are some tricky areas and I'm wondering which path is easier, safer, 
>> and portable. 
> 
> I am thinking which path is preferred: create the processes in kernel space
> (like Andrew's patch does) or in user space (like Zap does). In the mini-summit
> we agreed in favor of kernel space, but I can still see arguments why user space
> may be better.

I'm more familiar with the second algorithm, restarting the process tree in
user space and let each task restart itself with the sys_restart syscall. But
that's because I've been working on a C/R framework which freezes tasks on 
a syscall boundary, which makes a developer's life easy for restart. 

But as you know, a restarted process resumes its execution where it was 
checkpointed. So i'm wondering what are the hidden issues with a in-kernel 
checkpoint and in-kernel restart. To be more precise, why Andrey needs a 
i386_ret_from_resume  trampoline in : 

	http://lkml.org/lkml/2008/9/3/181

and why don't you ? 

> (note: I refer strictly to the creation of the processes during restart, not 
>  how their state is restored).

OK 

> any thoughts ?

thanks Oren,

C.
