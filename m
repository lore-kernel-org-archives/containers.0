From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] x86_86 support of checkpoint/restart (Re: Checkpoint
	/ Restart)
Date: Mon, 09 Feb 2009 21:14:24 +0100
Message-ID: <49908EA0.2080901@fr.ibm.com>
References: <20090207001609.8168.14884.stgit@lahore.corp.google.com>	<f4192e520902090953x43a98134hfaa8443d586a32a6@mail.gmail.com>
	<49908323.3090606@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49908323.3090606-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org, Jim Winget <winget-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Mike Waychison wrote:
> Jim Winget wrote:
>> Any way to use a delayed checkpoint signal (perhaps somewhat
>> non-deterministic, e.g. "do it now" really means "do it pretty soon") that
>> is only taken on return to user space thus allowing a deterministic
>> solution?
> 
> Ya, I'm thinking that a 'checkpoint' signal would be advisory, with the 
> SIG_DFL action performing the checkpoint itself.
> 
> Considering that we'd need to cleanly get access to all registers, the 
> checkpoint itself needs to be a well defined path from 
> userland->kernelland.  I'm wondering if sys_checkpoint could be this 
> well-defined path using the PTREGSCALL stub macro.
> 
> For tasks that aren't checkpoint-aware, SIG_DFL could possibly be done 
> by having the vsyscall page/vdso implement the userland sighandler that 
> calls sys_checkpoint.
> 
> What this means though is that we won't be able to freeze or SIGSTOP 
> tasks before checkpoint. 

the sys_checkpoint() in the userland sighandler you are proposing, is how 
you would freeze all the tasks of a container. Once all the tasks have 
entered sys_checkpoint() and are blocked on a wait queue, you can start 
gathering states. 

This means that you need to count how many tasks should enter sys_checkpoint(). 
The cgroup fork callback can be used to signal new comers and maintain
a coherent count of tasks. But we would also need an exit callback, which
is not available.  

> Both of these paths can be entered via a 
> variety of kernel entry points and unless we start dumping the full 
> ptregs on each entry point, we'll never be able to reliably get access 
> to all registers.
> 
> sys_checkpoint itself would have to have it's own method to quiesce all 
> the tasks (basically wait for all tasks to enter sys_checkpoint so that 
> a multi-task checkpoint is self-consistent).  

yes.

sys_restart() works the same, all the tasks are signalled in advance how 
many should enter the wait queue. once the task state is restored, you 
let each task restart from its signal handler using the cpu state that 
was saved on user stack at checkpoint time.

> The nice thing about a signal too is that userland can block it and 
> ignore it in a deterministic way.

yes and 

The *very* nice thing about a signal handler is that you don't have to
worry about your cpu state. I don't think it's a good idea to duplicate 
this code in the C/R framework. it is *very* arch dependent.

> The failure logic for ignored or blocked-for-a-long time can be pushed 
> back down to userland.
> 
> This is all a dramatic shift from the current way things are done, so 
> we'd be best getting a better feel for our options though..

I think that the current way of doing things is work in progress and needs
to be reviewed. The way checkpoint/restart is triggered has always been
controversial among the stakeholders.

We've been maintaining a C/R solution on ppc32, ppc64, x86, x86_64, ia64, 
s390, s390x since 2002 working on the above principles you are describing.
UNICOS and later IRIX used similar principles, following the POSIX draft
on checkpoint/restart.

For the signal, we have 'hijacked' SIGSTOP but new signals SIGCKPT and 
SIGRESTART would definitely be a nicer solution for a mainline solution.

Cheers,

C.
