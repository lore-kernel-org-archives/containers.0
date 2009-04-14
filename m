From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 10/30] cr: core stuff
Date: Tue, 14 Apr 2009 23:00:32 +0400
Message-ID: <20090414190032.GA28267__8553.56810284338$1239735798$gmane$org@x200.localdomain>
References: <20090410023539.GK27788@x200.localdomain>
	<49E41D7B.8030003@cs.columbia.edu>
	<20090414160003.GD27461@x200.localdomain>
	<49E4D3A9.6020100@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49E4D3A9.6020100-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

> >> The ability to streamline the checkpoint image IMHO is invaluable.
> >> It's the unix way (TM) of doing things; it makes the process pipe-able.
> >>
> >> You can do many nice things when the checkpoint can be streamed: you
> >> can compress, sign, encrypt etc on the fly without taking additional
> >> diskspace. You can transfer over the network (e.g. for migration),
> >> or store remotely without explicit file system support. You can easily
> >> transform the stream from one c/r version to another etc.
> >>
> >> This should be a design principle. In my experience I never hit a wall
> >> that forced me to "sacrifice" this decision.
> >>
> >>>   sacrifised (read: child can ptrace parent)
> >> Hmmm... if all tasks are created in user space, then this specific
> >> becomes a no-brainer !
> > 
> > No!
> 
> Actually yes :)
> 
> > 
> > A ptraces B. Container is checkpointed.
> > 
> > Kernel realizes ptrace is going on. A and B in theory can have any
> > realitionship.
> > 
> > Consequently, kernel doesn't know in which order to dump A and B.
> > 
> > And there is no such order:
> > *) A can be parent of B (you dump A, B),
> > *) A can be child of B (you want to dump B, A, but this conflicts with
> >    ->real_parent order)
> > *) A and B just tasks (any order).
> 
> Current code does not support ptrace() - which has a multitude
> if tidy-bits issues to solve during restart regardless.
> 
> However, creating tasks in userspace uses (and will uses) only
> "real" process relationships, not ptrace-relationships, when it
> comes to decide on the fork/clone order.
> 
> Technically, that can be done in checkpoint (dumping the task tree)
> or in restart-user-space (rearranging the data before fork/clone).
> 
> > 
> > I'm showing that whole issue can be avoided:
> 
> If the issue can be avoided, then why would you need to sacrifice
> the stream-ability of the checkpoint image ?
> 
> > *) all tasks are simply created regardless of who is parent of whom
> >    (see kernel_thread())
> > *) Every task_struct image among other things contains references to
> >    ->real_parent and ->parent.
> > *) After every task is created it's time to change references:
> > 	**) lookup who is ->real_parent, change ->real_parent _by hand_
> > 		not with some "correct clone(2)" order.
> > 	**) lookup who is ->parent, change ->parent.
> > 
> > You're probably escaping all of this with object numbers?
> 
> (Will be) escaping this by arranging to fork/clone in the proper order.

task_struct and reparenting is just an example.

There is another loop:

	struct user_struct => struct user_namespace => struct user_namespace::creator

Before actual dump each struct user_struct gets unique id (objref, whatever)
and simply dumped regardless of order.

Image of struct user_namespace contains id of creator user and dumped.

On restart:
	restart user_ns
	restart user
	lookup object by creator id
	if found, rewrite ->creator
	if not found, restore creator user, and rewrite ->creator.

So, yes, if object number is dumped on disk, you get streamability in
presence of loops.

Clever. Just needs a way to quickly lookup file position by object id.

BTW, this is why OpenVZ code have "section concept.
I hoped it won't be needed.
