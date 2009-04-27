From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: define CHECKPOINT_SUBTREE flag and sysctl
Date: Mon, 27 Apr 2009 13:07:17 -0500
Message-ID: <20090427180717.GA28476@us.ibm.com>
References: <20090424210608.GA16973@us.ibm.com> <m3vdotk34g.fsf@pobox.com>
	<20090425024515.GA4534@hallyn.com> <m3y6tmt3wb.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m3y6tmt3wb.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> > Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> >> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> >> > +	cnt = ref->users + 1;
> >> > +	switch (ref->type) {
> >> > +	case CR_OBJ_UTSNS:
> >> > +		utsns = ref->ptr;
> >> > +		cnt2 = (unsigned long) atomic_read(&utsns->kref.refcount);
> >> > +		if (cnt != cnt2) {
> >> > +			cr_debug("uts namespace leak\n");
> >> 
> >> I'm struggling to understand what guarantee a check such as this is
> >> supposed to be making.  I see that it will catch *some* undesirable
> >> cases.  But "current refcount equals old refcount" does not imply that
> >> "refcount has not changed in the meantime".
> >
> > It's got nothing to do with the refcounts changing.
> >
> > It ensures that, at the end of the checkpoint, the resources (utsns
> > in this case) had no users not accounted for by a checkpointed task.
> > In other words, there was no information leak.
> 
> Okay, I had mistakenly believed this code was running in the
> subtree/non-container case.  I reread your patch description and it
> indicates that these checks are made only in the case of container
> checkpoint.  If I'm (finally) understanding the patch correctly, my
> concern is lessened.  Comparing refcounts is still... unconventional.

Yes, and there are cases where it won't be usable - for instance if
opening a procfile increments the resource->use count.  That should
not be an issue for utsns, ipcns, files, or vmas, afaik.

> > Now it's possible that at the *start* of the checkpoint there was
> > another task, not being checkpointed and not frozen, in the utsns,
> > and it exited before the leaks check took place.
> 
> [Please excuse the obtuse queries below]
> 
> In which case the check would fail, yes?  Can this scenario actually
> occur?  I'm of the understanding that a container must be frozen before
> proceeding with checkpoint.  If that's correct, how could a task in the
> container exit in the meantime?

Heh, because there is no such thing as a 'container'.  There is a set of
tasks in the same freezer control group, and it's possible that there is
a task not in that cgroup which is in the same utsname as the rest of
the tasks in that freezer cgroup.

Now from my POV the important thing is that:  (1) when userspace does
the right thing, then it gets the right thing, and (2) when userspace
does the wrong thing, the kernel doesn't crash.  This goes beyond that,
aiming for something which probably isn't fully achievable, but still
may be useful even if only mostly achievable:  namely, warn the user
when they do the wrong thing, in the believe that not doing so makes
the implementation "a toy."  While I don't agree with that analysis,
in the end the only person whose opinion on that matters is the user's :)
So I'm not opposed to giving them the option.

-serge
