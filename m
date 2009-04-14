From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: Creating tasks on restart: userspace vs kernel
Date: Tue, 14 Apr 2009 23:59:09 +0400
Message-ID: <20090414195909.GA28353@x200.localdomain>
References: <49E40662.2040508@cs.columbia.edu> <20090414163633.GE27461@x200.localdomain> <49E4D89D.9060903@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755168AbZDNT7K@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49E4D89D.9060903@cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.osdl.org, Dave Hansen <dave@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

> > In the end correctness of chopping will be equal to how good user
> > understands that two task_struct's are independent of each other.
> > 
> >> But it will still be a useful tool for many use cases, like batch cpu jobs,
> >> some servers, vnc sessions (if you want graphics) etc. Imagine you run
> >> 'octave' for a week and must reboot now - 'octave' wouldn't care if
> >> you checkpointed it and then restart with a different pid !
> >>
> >> <3> Clone with pid:
> >>
> >> To restart processes from userspace, there needs to be a way to
> >> request a specific pid--in the current pid_ns--for the child process
> >> (clearly, if it isn't in use).
> >>
> >> Why is it a disadvantage ?  to Linus, a syscall clone_with_pid()
> >> "sounds like a _wonderful_ attack vector against badly written
> >> user-land software...".  Actually, getting a specific pid is possible
> >> without this syscall.  But the point is that it's undesirable to have
> >> this functionality unrestricted.
> >>
> >> So one option is to require root privileges. Another option is to
> >> restrict such action in pid_ns created by the same user. Even more so,
> >> restrict to only containers that are being restarted.
> > 
> > You want to do small part in userspace and consequently end up with hacks
> > both userspace-visible and in-kernel.
> 
> I want to extend existing kernel interface to leverage fork/clone
> from user space, AND to allow the flexibility mentioned above (which
> you conveniently ignored).
> 
> All hacks are in-kernel, aren't they ?

mktree.c can be vieved as hack, why not?

The whole existence of these requirements. You want new syscall or SET_NEX_PID
or /proc file or something.

> As for asking for a specific pid from user space, it can be done by:
> * a new syscall (restricted to user-owned-namespace or CAP_SYS_ADMIN)
> * a sys_restart(... SET_NEXT_PID) interface specific for restart (ugh)
> * setting a special /proc/PID/next_id  file which is consulted by fork

/proc/*/next_id was disscussed and hopefully died, but no.

> and in all cases, limit this so it can only allowed in a restarting
> container, under the proper security model (again, e.g., Serge's
> suggestion).
> 
> > 
> > Pids aren't special, they are struct pid, dynamically allocated and
> > refcounted just like any other structtures.
> > 
> > They _become_ special for you intended method of restart.
> 
> They are special. And I allow them not to be restored, as well, if
> the use case so wishes.

The use case is to restore as much as possible to the same state as
equal as possible. Not going with fork_with_pid() in any form helps
kernel to ensure correctness of restore and helps to avoid surprise
failure modes from user POV.

> > You also have flags in nsproxy image (or where?) like "do clone with
> > CLONE_NEWUTS".
> 
> Nope. Read the code.

Which code?

	static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
	{
		...

		new_uts = cr_obj_add_ptr(ctx, nsproxy->uts_ns,
					&hh->uts_ref, CR_OBJ_UTSNS, 0);
		if (new_uts < 0) {
			ret = new_uts;
			goto out;
		}

		hh->flags = 0;
		if (new_uts)
	===>		hh->flags |= CLONE_NEWUTS;

		ret = cr_write_obj(ctx, &h, hh);
			...

> > This is unneeded!
> > 
> > nsproxy (or task_struct) image have reference (objref/position) to uts_ns image.
> > 
> > On restart, one lookups object by reference or restore it if needed,
> > takes refcount and glue. Just like with every other two structures.
> 
> That's exactly how it's done.

Not for uts_ns and future namespaces.

	ret = cr_restore_utsns(ctx, hh->uts_ref, hh->flags);
						 ^^^^^^^^^
						 comes from disk

> > No "what to do, what to do" logic.
