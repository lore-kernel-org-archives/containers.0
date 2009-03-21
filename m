From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Fri, 20 Mar 2009 21:38:35 -0500
Message-ID: <20090321023834.GA21064@hallyn.com>
References: <878wn353mf.fsf@caffeine.danplanet.com> <49C1175F.9060600@free.fr>
	<49C1506C.1080500@google.com> <m1bprye5io.fsf@fess.ebiederm.org>
	<49C195CF.1080506@google.com> <m1ab7icodl.fsf@fess.ebiederm.org>
	<49C1A52D.4000503@google.com> <m1iqm6xkc7.fsf@fess.ebiederm.org>
	<20090320172616.GA7203@us.ibm.com>
	<m1d4cb3he5.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1d4cb3he5.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> > What is wrong with Alexey's patch, which simply passes in the values
> > themselves?  Do you have another use in mind for the min/max pid
> > values?
> 
> At an implementation level (and I need to look at Alexey's specific patch)
> every patch I have seen to date creates their own version of alloc_pidmap.

You're right, Alexey's patch creates a new one.

> alloc_pidmap already implicitly takes min/max and first value to try
> as parameters.  RESERVED_PIDS, pid_max, and pid_ns->last_pid.  So
> instead of rewriting alloc_pidmap we should just be able to refactor
> alloc_pidmap to take the requisite values.  That should be less code
> and easier to maintain.

Yeah, that sounds good actually.  Thanks.

> Looking at the current implementation we also have the issue that
> pid_max is not per pid namespace.  Where it seems to belong.

Eh.  It does seem to, but otoh why give userspace knobs it has no use
for...  Or, can you think of a case where it'd be useful?

> >> If the primary use for a userspace interface is restart I feel we are
> >> doing it wrong.
> >
> > I think that's a good guideline, bad rule.  Certainly possible
> > that you're right that this is just pointing to in-kernel
> > recreation of process tree as the way to go.  I was getting
> > that feeling myself, but then there are still very good reasons
> > not to do that, as there are things which each task should do
> > before completing sys_restart() which are best done in userspace.
> > These include for instance creating virtual nics, and calling
> > Oren's suggested 'cr_advise()' system calls.
> 
> You might be right.   I am behind on that part of the conversation.
> 
> My general concern is that dividing up the responsibilities between user space
> and kernel space seems harder to maintain, and refactor if we don't get something
> right the first time.

So far we're actually still at the point where the code (Oren's set)
could go either way.  A small patch from Alexey can make it swing toward
kernel, while Oren's mktree.c userspace restart program swings the other
way.

And since we're punting on any nested namespaces it actually may stay that way
for awhile.

thanks,
-serge
