From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/1] cr: lsm: restore LSM contexts for ipc objects
Date: Tue, 23 Jun 2009 14:57:03 -0500
Message-ID: <20090623195703.GA25469@us.ibm.com>
References: <20090620013216.GA4435@us.ibm.com> <1245779751.27538.14.camel@localhost.localdomain> <20090623181810.GA23644@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090623181810.GA23644@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Stephen Smalley <sds@epoch.ncsc.mil>
Cc: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, Alexey Dobriyan <adobriyan@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue@us.ibm.com):
> Quoting Stephen Smalley (sds@epoch.ncsc.mil):
> > On Fri, 2009-06-19 at 20:32 -0500, Serge E. Hallyn wrote:
> > > diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
> > > index 51385b0..ca55339 100644
> > > --- a/ipc/checkpoint_msg.c
> > > +++ b/ipc/checkpoint_msg.c
> > <snip>
> > > @@ -175,11 +183,26 @@ static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
> > >  			    struct msg_queue *msq)
> > >  {
> > >  	int ret = 0;
> > > +	int secid = 0;
> > >  
> > >  	ret = restore_load_ipc_perms(&h->perms, &msq->q_perm);
> > >  	if (ret < 0)
> > >  		return ret;
> > >  
> > > +	if (h->perms.secref) {
> > > +		struct sec_store *s;
> > > +		s = ckpt_obj_fetch(ctx, h->perms.secref, CKPT_OBJ_SECURITY);
> > > +		if (IS_ERR(s))
> > > +			return PTR_ERR(s);
> > > +		secid = s->secid;
> > > +	}
> > > +	ret = security_msg_queue_alloc(msq);
> > > +	if (ret)
> > > +		return ret;
> > > +	ret = security_msg_queue_restore(msq, secid);
> > > +	if (ret < 0)
> > > +		return ret;
> > 
> > I don't think you want to call security_msg_queue_alloc() here, as that
> > both allocates the security struct and performs the create check.  So I
> > would just call the _restore() function, and let it internally call
> > ipc_alloc_security() to allocate the struct but then apply its own
> > distinct restore check.  Likewise for the rest of them.
> 
> Ok, will change that.

Hmm, but that means that if there is some new LSM which allocates memory
in security_msg_queue_alloc(), but which does not define
security_msg_queue_restore() (for some stupid reason), it'll end up
causing a bug.

It's something we can certainly catch through code review, but do we
want to set such a scenario up at all?

Speaking just for SELinux, the security_msg_queue_alloc() hook would
return -EPERM only if the task calling sys_restart() wasn't allowed
to create a msg queue with its own type, right?  Is that something
which is often disallowed?

I suppose we could have the default (cap_msg_queue_restore) call
security_ops->msg_queue_alloc() - feels frail, but maybe it's ok...

thanks,
-serge
