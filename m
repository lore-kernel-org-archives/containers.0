From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Fri, 20 Mar 2009 16:26:42 -0700
Message-ID: <m1d4cb3he5.fsf@fess.ebiederm.org>
References: <49C0B069.6060300@cs.columbia.edu>
	<20090318134932.GC22636@us.ibm.com>
	<878wn353mf.fsf@caffeine.danplanet.com> <49C1175F.9060600@free.fr>
	<49C1506C.1080500@google.com> <m1bprye5io.fsf@fess.ebiederm.org>
	<49C195CF.1080506@google.com> <m1ab7icodl.fsf@fess.ebiederm.org>
	<49C1A52D.4000503@google.com> <m1iqm6xkc7.fsf@fess.ebiederm.org>
	<20090320172616.GA7203@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090320172616.GA7203-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Fri\, 20 Mar 2009 12\:26\:17 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> Ok.  I see what you are trying to accomplish with this and honestly I
>> think it is silly.
>> 
>> We should start the threads we need in the kernel, and if we need to
>> run clone_pid fine.  I am not comfortable exporting clone_with_pid to
>> user space.
>
> Even if we create the task tree in userspace, I don't see why we
> can't have the parent of each nested pid_ns pass CLONE_NEWPID to
> clone_with_pid() instead of doing clone first and then unsharing
> the pidns?
>
> As for clone_with_pid(), I don't particularly like the semantics,
> but as was discussed over IRC, we could have clone_with_pid()
> return -EINVAL unless it is called while it is called from a task
> inside a restarting container.  (and -EPERM if setting a pid in
> a pid_ns which was not created as part of the container)  Eric
> do you dislike that any less?
>
>> As for the implementation of allocating a struct pid with a certain
>> set of pid values.  I expect we can do that easily enough by
>> refactoring the pid allocator to be passed in the min/max pid to
>> allocate from, and have a special case that passes in a different set
>> of min/max values so we can allocate just the pid we need.
>
> What is wrong with Alexey's patch, which simply passes in the values
> themselves?  Do you have another use in mind for the min/max pid
> values?

At an implementation level (and I need to look at Alexey's specific patch)
every patch I have seen to date creates their own version of alloc_pidmap.

alloc_pidmap already implicitly takes min/max and first value to try
as parameters.  RESERVED_PIDS, pid_max, and pid_ns->last_pid.  So
instead of rewriting alloc_pidmap we should just be able to refactor
alloc_pidmap to take the requisite values.  That should be less code
and easier to maintain.

Looking at the current implementation we also have the issue that
pid_max is not per pid namespace.  Where it seems to belong.

>> If the primary use for a userspace interface is restart I feel we are
>> doing it wrong.
>
> I think that's a good guideline, bad rule.  Certainly possible
> that you're right that this is just pointing to in-kernel
> recreation of process tree as the way to go.  I was getting
> that feeling myself, but then there are still very good reasons
> not to do that, as there are things which each task should do
> before completing sys_restart() which are best done in userspace.
> These include for instance creating virtual nics, and calling
> Oren's suggested 'cr_advise()' system calls.

You might be right.   I am behind on that part of the conversation.

My general concern is that dividing up the responsibilities between user space
and kernel space seems harder to maintain, and refactor if we don't get something
right the first time.


Eric
