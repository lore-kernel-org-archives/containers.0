From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 00/30] C/R OpenVZ/Virtuozzo style
Date: Tue, 14 Apr 2009 22:34:35 +0400
Message-ID: <20090414183435.GA28233__35008.6853527047$1239734495$gmane$org@x200.localdomain>
References: <20090410023207.GA27788@x200.localdomain>
	<1239340031.24083.21.camel@nimitz>
	<20090413091423.GA19236@x200.localdomain>
	<49E4108A.8050201@cs.columbia.edu>
	<20090414145830.GA27461@x200.localdomain>
	<49E4D115.5080601@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49E4D115.5080601-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

On Tue, Apr 14, 2009 at 02:08:21PM -0400, Oren Laadan wrote:
> 
> 
> Alexey Dobriyan wrote:
> > On Tue, Apr 14, 2009 at 12:26:50AM -0400, Oren Laadan wrote:
> >> Alexey Dobriyan wrote:
> >>> On Thu, Apr 09, 2009 at 10:07:11PM -0700, Dave Hansen wrote:
> >>>> I'm curious how you see these fitting in with the work that we've been
> >>>> doing with Oren.  Do you mean to just start a discussion or are you
> >>>> really proposing these as an alternative to what Oren has been posting?
> >>> Yes, this is posted as alternative.
> >>>
> >>> Some design decisions are seen as incorrect from here like:
> >> A definition of "design" would help; I find most of your comments
> >> below either vague, cryptic, or technical nits...
> >>
> >>> * not rejecting checkpoint with possible "leaks" from container
> >> ...like this, for example.
> > 
> > Like checkpointing one process out of many living together.
> 
> See the thread on creating tasks in userspace vs. kernel space:
> the argument here is that is an interesting enough use case for
> a checkpoint of not-an-entire-container.
> 
> Of course it will require more logic to it, so the user can choose
> what she cares or does not care about, and the kernel could alert
> the user about it.
> 
> The point is, that it is, IMHO, a desirable capability.
> 
> > 
> > If you allow this you consequently drop checks (e.g. refcount checks)
> > for "somebody else is using structure to be checkpointed".
> > 
> 
> From this point below, I totally agree with you that for the purpose
> of a whole-container-checkpoint this is certainly desirable. My point
> was that it can be easily added the existing patchset (not yours).
> Why not add it there ?
> 
> > If you drop these checks, you can't decipher legal sutiations like
> > "process genuinely doesn't care about routing table of netns it lives in"
> > from "illegal" situations like "process created shm segment but currently
> > doesn't use it so not checkpointing ipcns will result in breakagenlater".
> > 
> > You'll have to move responsibility to user, so user exactly knows what
> > app relies on and on what. And probably add flags like CKPT_SHM,
> > CKPT_NETNS_ROUTE ad infinitum.
> > 
> > And user will screw it badly and complain: "after restart my app
> > segfaulted". And user himself is screwed now: old running process is
> > already killed (it was checkpointed on purpose) and new process in image
> > segfaults every time it's restarted.
> > 
> > All of this in out opinion results in doing C/R unreliably and badly.
> > 
> > We are going to do it well and dig from the other side.
> > 
> > If "leak" (any "leak") is detected, C/R is aborted because kernel
> > doesn't know what app relies on and what app doesn't care about.
> > 
> > This protected from situations and failure modes described above.
> > 
> > This also protects to some extent from in-kernel changes where C/R code
> > should have been updated but wasn't. Person doing incomplete change won't
> > notice e.g refcount checks and won't try to "fix" them. But we'll notice it,
> > e.g. when running testsuite (amen) and update C/R code accordingly.
> > 
> > I'm talking about these checks so that everyone understands:
> > 
> > 	for_each_cr_object(ctx, obj, CR_CTX_MM_STRUCT) {
> >                 struct mm_struct *mm = obj->o_obj;
> >                 unsigned int cnt = atomic_read(&mm->mm_users);
> > 
> >                 if (obj->o_count != cnt) {
> >                         printk("%s: mm_struct %p has external references %lu:%u\n", __func__, mm, obj->o_count, cnt);
> >                         return -EINVAL;
> >                 }
> >         }
> > 
> > They are like moving detectors, small, invisible, something moved, you don't
> > know what, but you don't care because you have to investigate anyway.
> > 
> > In this scheme, if user wants to checkpoint just one process, he should
> > start it alone in separate container. Right now, in posted patchset
> > as cloned process with
> > CLONE_NEWNS|CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWUSER|CLONE_NEWPID|CLONE_NEWNET
> 
> So you suggest that to checkpoint a single process, say a cpu job that
> would run a week, which runs in the topmost pid_ns, I will need to
> checkpoint the entire topmost pid_ns (as a container, if at all possible
> - surely there will non-checkpointable tasks there) and then in
> user-space filter out the data and leave only one task, and then to
> restart I'll use a container again ?

No, you do little preparations and start CPU job in container from the very
beginning.

> Pffff ... why not just allow subtree checkpoint, not in a container,
> with its well known limitations -- would work the same, for very little
> additional implementation cost.
