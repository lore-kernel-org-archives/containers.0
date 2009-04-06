From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: Add UTS support (v6)
Date: Sun, 05 Apr 2009 22:33:05 -0400
Message-ID: <49D969E1.5060605@cs.columbia.edu>
References: <1238533107-11796-1-git-send-email-danms@us.ibm.com>	<1238533107-11796-3-git-send-email-danms@us.ibm.com>	<20090402174451.GC9984@us.ibm.com>
	<87wsa32b7h.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87wsa32b7h.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> SH> One thing to note is that this will drive the ns cgroup bananas.
> SH> It might still be worthwhile collecting the flags for all the
> SH> to-be-unshared namespaces, and then doing all of the unsharing at
> SH> once.
> 
> Okay, that's fair.
> 
> SH> Futhermore, you do sys_unshare here, then further down you do
> SH> another copy_namespaces(CLONE_NEWUTS)?
> 
> That's in the case where our UTS namespace has already been created by
> a previous task.  We need to copy_namespaces() in order to get a new
> nsproxy (since our nsproxy must be copied if we no longer share all
> namespaces with our parent).  I have to pass a clone flag to it to get
> it to do anything.  I promptly drop my hold on that new UTS namespace
> and replace it in my new nsproxy with the one from the objhash that my
> predecessor created (which is kinda ugly).
> 
> SH> Finally, it seems to me every task will unshare(CLONE_NEWUTS), no?
> SH> Where is the check done (and stored) for whether this task has a
> SH> different utsns from its parent?
> 
> No, tasks only unshare() if their UTS namespace objref is not found in
> the objhash (thus indicating that they're the first of that namespace
> to be restarted).
> 
> Perhaps you're referring to the fact that all tasks call
> copy_namespaces() (if they're not the first).  You're correct there,
> but I'm not sure that a check to see if we need to
> (i.e. task->nsproxy->uts == uts) because at the time that the tasks
> were created, none of them had done their unshare() yet).
> 
> SH> Save identifiers for all of the namespaces at the top of the
> SH> checkpoint image; have restart create a set of dummy tasks, enough
> SH> to contain all of the new namespaces; have each unshare their
> SH> namespaces; then, as each real new task is restarted, manually
> SH> create a new nsproxy and link it to all of the required new
> SH> namespaces.
> 
> Well, that's an option I suppose.  Oren said he wanted to avoid an
> additional loop over all tasks during checkpoint and preferred that it
> all be stored with the task itself.  Oren?

First off, that's totally possible without a second loop: while filling
the pids_arr[] we can already collect the namespaces information and
fill the data in additional fields in pids_arr[]. That will make it also
available to userspace easily, and also in the kernel just as well.

I suppose you're aiming at doing the unshare() in userspace because you
anticipate headaches with net_ns, right ?

In that case, you don't even need to fork that many dummy tasks. You
could use a single task that would repeatedly unshare() and then call
[light bulb appears...] some form of cr_advise() to tell the kernel
that your current nsproxy (or uts_ns) should be used with objref X in
an upcoming restart.

Oren.
