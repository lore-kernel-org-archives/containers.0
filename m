From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: define CHECKPOINT_SUBTREE flag and sysctl
Date: Fri, 24 Apr 2009 21:45:15 -0500
Message-ID: <20090425024515.GA4534@hallyn.com>
References: <20090424210608.GA16973@us.ibm.com> <m3vdotk34g.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m3vdotk34g.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> > Define a CHECKPOINT_SUBTREE flag for sys_checkpoint() which
> > says it's ok if the the checkpointed set of tasks are not
> > a fully isolated container without leaks.
> >
> > Define a sysctl 'ckpt_subtree_allowed' which determines
> > whether subtree checkpoints are ok.  If that sysctl,
> > ckpt_subtree_allowed, is 0, then the CHECKPOINT_SUBTREE flag
> > may not be used.  Also, if that sysctl is 0, then both
> > sys_checkpoint() and sys_restart() always require
> > CAP_SYS_ADMIN.
> 
> Whether subtree checkpoint is allowed and whether non-admin checkpoint
> is allowed are independent constraints, no?  Should this really be a
> single flag?

Well it's not about the flag, it's about the sysctl.  So actually
I don't have that right at checkpoint (but do at restart).  It
should just be:

	if (!ckpt_subtree_allowed && !capable(CAP_SYS_ADMIN))
		return -EPERM;

for both.

As for making it two sysctls, I don't really care.  Fine by me...

> > +static int check_obj_isolated(struct cr_ctx *ctx, struct cr_objref *ref)
> > +{
> > +	struct uts_namespace *utsns;
> > +	struct ipc_namespace *ipcns;
> > +	struct file *file;
> > +	struct mm_struct *mm;
> > +	unsigned long cnt, cnt2;
> > +	int ret = 1;
> > +
> > +	/* note - one might think it worthwhile to put the ns
> > +	 * ones under #ifdefs for the CONFIG_X_NS, but instead
> > +	 * it CONFIG_CHECKPOINT should depend on all of those
> > +	 */
> > +	/* note2: the objhash has taken a reference, so we account
> > +	 * for that */
> > +
> > +	cnt = ref->users + 1;
> > +	switch (ref->type) {
> > +	case CR_OBJ_UTSNS:
> > +		utsns = ref->ptr;
> > +		cnt2 = (unsigned long) atomic_read(&utsns->kref.refcount);
> > +		if (cnt != cnt2) {
> > +			cr_debug("uts namespace leak\n");
> 
> I'm struggling to understand what guarantee a check such as this is
> supposed to be making.  I see that it will catch *some* undesirable
> cases.  But "current refcount equals old refcount" does not imply that
> "refcount has not changed in the meantime".

It's got nothing to do with the refcounts changing.

It ensures that, at the end of the checkpoint, the resources (utsns
in this case) had no users not accounted for by a checkpointed task.
In other words, there was no information leak.

Now it's possible that at the *start* of the checkpoint there was
another task, not being checkpointed and not frozen, in the utsns,
and it exited before the leaks check took place.  But we're not
trying to prevent malice here, so I think that's not worth worrying
about.

-serge
