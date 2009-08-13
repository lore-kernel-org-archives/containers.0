From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] Expose may_setuid() in user.h
Date: Thu, 13 Aug 2009 18:11:09 -0500
Message-ID: <20090813231109.GC13219@us.ibm.com>
References: <1250191750-3864-1-git-send-email-danms@us.ibm.com>
	<1250191750-3864-3-git-send-email-danms@us.ibm.com>
	<20090813222837.GB13219@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090813222837.GB13219-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > Make this helper available to others.
> 
> No objection to exporting may_setuid, nor to creating may_setgid(),
> but I don't think may_setgid() is right.  See below
> 
> > Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  include/linux/user.h |    9 +++++++++
> >  kernel/user.c        |   16 +++++++++++++++-
> >  2 files changed, 24 insertions(+), 1 deletions(-)
> > 
> > diff --git a/include/linux/user.h b/include/linux/user.h
> > index 68daf84..713bae7 100644
> > --- a/include/linux/user.h
> > +++ b/include/linux/user.h
> > @@ -1 +1,10 @@
> > +#ifndef _LINUX_USER_H
> > +#define _LINUX_USER_H
> > +
> >  #include <asm/user.h>
> > +#include <linux/sched.h>
> > +
> > +extern int may_setuid(struct user_namespace *ns, uid_t uid);
> > +extern int may_setgid(struct group_info *groupinfo, gid_t gid);
> > +
> > +#endif
> > diff --git a/kernel/user.c b/kernel/user.c
> > index a535ed6..38b8b50 100644
> > --- a/kernel/user.c
> > +++ b/kernel/user.c
> > @@ -604,7 +604,7 @@ int checkpoint_user(struct ckpt_ctx *ctx, void *ptr)
> >  	return do_checkpoint_user(ctx, (struct user_struct *) ptr);
> >  }
> > 
> > -static int may_setuid(struct user_namespace *ns, uid_t uid)
> > +int may_setuid(struct user_namespace *ns, uid_t uid)
> >  {
> >  	/*
> >  	 * this next check will one day become
> > @@ -631,6 +631,20 @@ static int may_setuid(struct user_namespace *ns, uid_t uid)
> >  	return 0;
> >  }
> > 
> > +int may_setgid(struct group_info *groupinfo, gid_t gid)
> > +{
> > +	if (capable(CAP_SETGID))
> > +		return 1;
> 
> We should pass in a user_ns so we can eventually check for
> capable_to(ns, CAP_SETGID).  So the caller may not be
> CAP_SETGID in the root user namespace, but may have created
> the child user namespace and be privileged there.
> 
> > +	if (current_cred_xxx(group_info) != groupinfo)
> > +		return 0;
> 
> I think it's possible for two different group_info's to have the same
> member groups.
> 
> I think the thing to do is walk over all groups in group_info,
> and do in_egroup_p(g) for each.
> 
> It's also possible that groups 1, 4, and 5 are in current_group_info and 6 is
> current_egroup, while we're asking for a group_info with groups 1, 5 and 6, and
> egid of 4.  That would be legal, right?  Walking over the groups and doing
> in_egroup_p(g) should do that check.  Sure, it's n^2 on the # groups...  So
> we could eventually optimize it to exploit the fact that both groupinfos
> are sorted and keep last_used_g in both groupinfos...
> 
> > +	if (in_egroup_p(gid))
> > +		return 1;

Ah, nm - you don't actually much care about the groupinfos, that
was a sanity check?

You don't actually want to check the ctx->realcred.  I think you
just want to check in_egroup_p(gid), as that will chekc against
the credentials used to call sys_restart(), which is what you want.

-serge
