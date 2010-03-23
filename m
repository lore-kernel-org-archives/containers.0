From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH] linux-cr: nested pid namespaces (v3)
Date: Tue, 23 Mar 2010 08:52:44 -0500
Message-ID: <20100323135244.GA20910@hallyn.com>
References: <20100323051839.GA16123@us.ibm.com>
 <20100323071431.GC4242@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100323071431.GC4242@localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Louis Rilling <Louis.Rilling@kerlabs.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Quoting Louis Rilling (Louis.Rilling@kerlabs.com):

Hi Louis, thanks again for reviewing.

> To me the real reason is to anticipate pid namespace unsharing. And this
> together with setns() will need to re-consider much of the namespace C/R
> logic imho. For instance, checkpoint could be done from a foreign task
> having entered the container, leak detection should take such foreign
> tasks into account (see example below), etc.

...

> >  
> > @@ -293,10 +295,15 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
> >  		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
> >  		ret = -EPERM;
> >  	}
> > -	/* no support for >1 private pidns */
> > -	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
> > -		_ckpt_err(ctx, -EPERM, "%(T)Nested pid_ns unsupported\n");
> > -		ret = -EPERM;
> > +	/* pidns must be descendent of root_nsproxy */
> > +	pidns = nsproxy->pid_ns;
> 
> In case of unshared pid namespace, task_active_pid_ns(t) should be checked
> instead of t->nsproxy->pid_ns: we can't checkpoint a foreign task.

Unsharing can only be done to a child ns, so it wouldn't be foreign.
Though of course that depends on which one ends up being the original
pid_ns (see below).

Now, regarding supporting unshared pid_ns, I think that (1) it will
be a simple matter of separately doing
	pid_pidns = checkpoint_obj(task_active_pid_ns(task));
	nsp_pidns = checkpoint_obj(task->nsproxy->pid_ns);
since we will need to record both.  In addition, (2) the most
recent emails I see on the topics are still unsure about whether
we want to have the unshared pid_ns be reflected in 
ns_of_pid(task_pid(task)) or task->nsproxy->pid_ns, so I think
we'll just have to handle them when they are implemented.

-serge
