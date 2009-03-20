From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/1] introduce user_ns inheritance in user-sched
Date: Thu, 19 Mar 2009 19:07:14 -0500
Message-ID: <20090320000714.GA25610@us.ibm.com>
References: <20090319211615.GA18383@us.ibm.com> <20090319235503.GA15844@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760137AbZCTAHn@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090319235503.GA15844@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Matt Helsley <matthltc@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, mingo@elte.hu, Bharata B Rao <bharata@linux.vnet.ibm.com>, peterz@infradead.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc@us.ibm.com):
> On Thu, Mar 19, 2009 at 04:16:15PM -0500, Serge E. Hallyn wrote:
> > In a kernel compiled with CONFIG_USER_SCHED=y, cpu shares are
> > allocated according to uid.  Shares are specifiable under
> > /sys/kernel/uids/<uid>/
> > 
> > In a kernel compiled with CONFIG_USER_NS=y, clone(2) with the
> > CLONE_NEWUSER flag creates a new user namespace, and the newly
> > cloned task will belong to uid 0 in the new user namespace.
> > 
> > Without this patch,  if uid 500 calls clone(CLONE_NEWUSER) (which
> > is possible using a program with the cap_sys_admin,cap_setuid,cap_setgid=pe
> > file capabilities), then the new task will get the cpu shares of
> > uid 0.
> > 
> > After this patch, if uid 500 calls clone(CLONE_NEWUSER), then even
> > though it is uid 0 in the new user namespace, it will be restricted to
> > the cpu shares of uid 500.
> > 
> > Currently there is no way to set shares for uids in user namespaces
> > other than the initial one.  That will be trivial to add when
> > sysfs tagging (or its functional equivalent, also needed to
> > expose network devices in network namespaces other than init)
> > becomes available.
> > 
> > Until cross-user-namespace file accesses are enforced, nothing
> > stops uid 0 in a child namespace from simply writing new values
> > into /sys/kernel/uids/500.
> > 
> > Here are results of some testing with and without the patch.
> > 
> > Cpu shares are initialized as follows::
> > 	user root:   2048
> > 	user hallyn: 1024
> > 	user serge:  512
> > 
> > Results are the 'real' part of time make -j4 > o 2>&1,
> > each time after a make clean.
> > 
> > =================================================================
> > UNPATCHED
> > User 1: user serge creates a child user_ns and runs as user root
> > User 2: hallyn runs as user hallyn
> > =================================================================
> >            User 1          User 2
> > run 1:   2m58.834s        3m0.609s
> > run 2:   2m59.248s        2m59.457s
> > 
> > =============================================================
> > PATCHED
> > User 1: user serge
> > User 2: user hallyn
> > =============================================================
> > 
> >            User 1          User 2
> > run 1:   3m6.337s        2m22.681s
> > run 2:   3m6.323s        2m21.855s
> > 
> > =============================================================
> > PATCHED
> > User 1: user serge setuid to user root
> > User 2: hallyn
> > =============================================================
> > 
> >            User 1          User 2
> > run 1:   2m17.782s       3m3.947s
> > run 2:   2m18.497s       3m7.961s
> > 
> > ==========================================================
> > PATCHED
> > User 1: user root inside userns created by userid serge
> > User 2: hallyn
> > ==========================================================
> > 
> >            User 1          User 2
> > run 1:   3m9.876s        2m8.428s
> > run 2:   3m8.539s        2m6.356s
> > 
> > Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> > Signed-off-by: Dhaval Giani <dhaval@linux.vnet.ibm.com>
> > Cc: mingo@elte.hu
> > Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>
> > Cc: peterz@infradead.org
> > ---
> >  kernel/user.c           |   12 +++++++++---
> >  kernel/user_namespace.c |    2 +-
> >  2 files changed, 10 insertions(+), 4 deletions(-)
> > 
> > diff --git a/kernel/user.c b/kernel/user.c
> > index 850e0ba..53aeea2 100644
> > --- a/kernel/user.c
> > +++ b/kernel/user.c
> > @@ -101,7 +101,12 @@ static int sched_create_user(struct user_struct *up)
> >  {
> >  	int rc = 0;
> > 
> > -	up->tg = sched_create_group(&root_task_group);
> > +	struct task_group *parent = &root_task_group;
> > +
> > +	if (up->user_ns != &init_user_ns)
> > +		parent = up->user_ns->creator->tg;
> > +
> > +	up->tg = sched_create_group(parent);
> >  	if (IS_ERR(up->tg))
> >  		rc = -ENOMEM;
> > 
> > @@ -434,11 +439,11 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
> >  		new->uid = uid;
> >  		atomic_set(&new->__count, 1);
> > 
> > +		new->user_ns = get_user_ns(ns);
> > +
> >  		if (sched_create_user(new) < 0)
> >  			goto out_free_user;
> > 
> > -		new->user_ns = get_user_ns(ns);
> > -
> >  		if (uids_user_create(new))
> >  			goto out_destoy_sched;
> > 
> > @@ -472,6 +477,7 @@ out_destoy_sched:
> >  	sched_destroy_user(new);
> >  	put_user_ns(new->user_ns);
> 
> Shouldn't this put_user_ns(new->user_ns) be removed? It looks like two 
> references to new->user_ns are being dropped if anything fails 
> after sched_create_user(new) succeeds yet as far as I can tell the
> patch does not introduce any new references to new->user_ns.

Ouch, yeah, thought I'd done that...

Thanks for catching that!  Will resend.

> Otherwise looks good to me.
> 
> Cheers,
> 	-Matt Helsley

thanks,
-serge
