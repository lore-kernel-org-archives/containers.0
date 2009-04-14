From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 00/30] C/R OpenVZ/Virtuozzo style
Date: Tue, 14 Apr 2009 18:58:30 +0400
Message-ID: <20090414145830.GA27461__5568.09679042107$1239721350$gmane$org@x200.localdomain>
References: <20090410023207.GA27788@x200.localdomain>
	<1239340031.24083.21.camel@nimitz>
	<20090413091423.GA19236@x200.localdomain>
	<49E4108A.8050201@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49E4108A.8050201-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 14, 2009 at 12:26:50AM -0400, Oren Laadan wrote:
> Alexey Dobriyan wrote:
> > On Thu, Apr 09, 2009 at 10:07:11PM -0700, Dave Hansen wrote:
> >> I'm curious how you see these fitting in with the work that we've been
> >> doing with Oren.  Do you mean to just start a discussion or are you
> >> really proposing these as an alternative to what Oren has been posting?
> > 
> > Yes, this is posted as alternative.
> > 
> > Some design decisions are seen as incorrect from here like:
> 
> A definition of "design" would help; I find most of your comments
> below either vague, cryptic, or technical nits...
> 
> > * not rejecting checkpoint with possible "leaks" from container
> 
> ...like this, for example.

Like checkpointing one process out of many living together.

If you allow this you consequently drop checks (e.g. refcount checks)
for "somebody else is using structure to be checkpointed".

If you drop these checks, you can't decipher legal sutiations like
"process genuinely doesn't care about routing table of netns it lives in"
from "illegal" situations like "process created shm segment but currently
doesn't use it so not checkpointing ipcns will result in breakagenlater".

You'll have to move responsibility to user, so user exactly knows what
app relies on and on what. And probably add flags like CKPT_SHM,
CKPT_NETNS_ROUTE ad infinitum.

And user will screw it badly and complain: "after restart my app
segfaulted". And user himself is screwed now: old running process is
already killed (it was checkpointed on purpose) and new process in image
segfaults every time it's restarted.

All of this in out opinion results in doing C/R unreliably and badly.

We are going to do it well and dig from the other side.

If "leak" (any "leak") is detected, C/R is aborted because kernel
doesn't know what app relies on and what app doesn't care about.

This protected from situations and failure modes described above.

This also protects to some extent from in-kernel changes where C/R code
should have been updated but wasn't. Person doing incomplete change won't
notice e.g refcount checks and won't try to "fix" them. But we'll notice it,
e.g. when running testsuite (amen) and update C/R code accordingly.

I'm talking about these checks so that everyone understands:

	for_each_cr_object(ctx, obj, CR_CTX_MM_STRUCT) {
                struct mm_struct *mm = obj->o_obj;
                unsigned int cnt = atomic_read(&mm->mm_users);

                if (obj->o_count != cnt) {
                        printk("%s: mm_struct %p has external references %lu:%u\n", __func__, mm, obj->o_count, cnt);
                        return -EINVAL;
                }
        }

They are like moving detectors, small, invisible, something moved, you don't
know what, but you don't care because you have to investigate anyway.

In this scheme, if user wants to checkpoint just one process, he should
start it alone in separate container. Right now, in posted patchset
as cloned process with
CLONE_NEWNS|CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWUSER|CLONE_NEWPID|CLONE_NEWNET

All of this by definition won't create situation "mom, where did my shm segment go?".

> Anything in the current design makes it impossible ?
> 
> Anything prohibiting your from adding this feature to the current
> patch-set ?
> 
> > * not having CAP_SYS_ADMIN on restart(2)
> 
> Surely you have read already on the containers mailing list that
> for the *time being* we attempt to get as far as possible without
> requiring root privileges, to identify security hot-spots.

More or less everything is hotspot.

> And surely you have read there the observation that for the general
> case root privileges will probably be inevitable.
> 
> And surely you don't seriously think that adding this check changes
> the "design"...

This is not about design now, this is about if you allow restart(2) for
everyone, you open kernel to very very high number of holes of all
types. I wrote about it in reply to your code.

Numbers of states described by any valid image as described by header
files is very much higher than number of states that can validly end up
in an image. Reducing set of states to only valid ones will require
many checks.

For example, just one structure: struct cr_hdr_cpu.

Segments are directly loaded regardless of RPL.

Debug registers are directly loaded regardless of to where breakpoint
points to.

If you don't understand scale of problem and insist on restart(2) not
having CAP_SYS_ADMIN, we'll just drop from discussion and write email
to bugtraq to warn sysadmins at least.

restart(2) for everyone sounds like excellent feature and is excellent
feature but simultaneusly is completely unrealistic for Unix-like kernel.

> > * having small (TASK_COMM_LEN) and bigger (objref[1]) image format
> >   misdesigns.
> 
> Eh ?

TASK_COMM_LEN is 16 bytes and is not going to change, so you do

	__u8 cr_comm[16];

and forget. If TASK_COMM_LEN changes you'll just bump size of
task_struct image and image version.

Saving ->comm as variable-sized string is complication out of nowhere.

As for objref, my apoligies, objection dropped, I understood how it can be useful.

> > * doing fork(2)+restart(2) per restarted task and whole orchestration
> >   done from userspace/future init task.
> 
> Why is it "incorrect" ?
> What makes it "better" to do it in the kernel ?
> Only because you say so is not convincing.
> 
> (also see my other post in this matter).
> 
> > * not seeing bigger picture (note, this is not equivalent to supporting
> >   everything at once, nobody is asking for everything at once) wrt shared
> >   objects and format and code changes because of that (note again, image
> >   format will change, but it's easy to design high level structure which
> >   won't change)
> 
> Why don't you describe the bigger picture so that the rest of can
> finally see it, too ?!
> (what a waste to have spent all this effort in vain...)

Sit and graph down all structures that you will eventually checkpoint and
relations about them. Things like "struct cr_hdr_pids" won't even be on
the radar.

> > * checking of unsupported features done at wrong place and wrong time
> >   and runtime overhead because of that on CR=y kernels.
> 
> Eh ?   Did you follow the code recently ?

Checks during dup_fd() were dropped? Good.

> > There are also low-level things, but it's cumulative effect.
> > 
> > [1] Do I inderstand correctly that cookie for shared object is an
> > address on kernel stack? This is obviously unreliable, if yes :-)
> 
> Ah... I see... you didn't look at it that hard, not even read the
> documentation with the code.
> 
> > 
> > 	int objref;
> > 		...
> > 	/* adding 'file' to the hash will keep a reference to it */
> > 	new = cr_obj_add_ptr(ctx, file, &objref, CR_OBJ_FILE, 0);
> > 					^^^^^^^
> 
> That said, there are more similarities than differences between your
> suggested template and the current patchset. With your expertise you
> can contribute tremendously if you decide to work together.

OK, totally misread code.
