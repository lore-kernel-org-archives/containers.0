From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/1] cr: lsm: restore LSM contexts for ipc objects
Date: Tue, 23 Jun 2009 13:18:10 -0500
Message-ID: <20090623181810.GA23644@us.ibm.com>
References: <20090620013216.GA4435@us.ibm.com> <1245779751.27538.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1245779751.27538.14.camel@localhost.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
To: Stephen Smalley <sds@epoch.ncsc.mil>
Cc: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, Alexey Dobriyan <adobriyan@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

Quoting Stephen Smalley (sds@epoch.ncsc.mil):
> On Fri, 2009-06-19 at 20:32 -0500, Serge E. Hallyn wrote:
> > diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
> > index 51385b0..ca55339 100644
> > --- a/ipc/checkpoint_msg.c
> > +++ b/ipc/checkpoint_msg.c
> <snip>
> > @@ -175,11 +183,26 @@ static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
> >  			    struct msg_queue *msq)
> >  {
> >  	int ret = 0;
> > +	int secid = 0;
> >  
> >  	ret = restore_load_ipc_perms(&h->perms, &msq->q_perm);
> >  	if (ret < 0)
> >  		return ret;
> >  
> > +	if (h->perms.secref) {
> > +		struct sec_store *s;
> > +		s = ckpt_obj_fetch(ctx, h->perms.secref, CKPT_OBJ_SECURITY);
> > +		if (IS_ERR(s))
> > +			return PTR_ERR(s);
> > +		secid = s->secid;
> > +	}
> > +	ret = security_msg_queue_alloc(msq);
> > +	if (ret)
> > +		return ret;
> > +	ret = security_msg_queue_restore(msq, secid);
> > +	if (ret < 0)
> > +		return ret;
> 
> I don't think you want to call security_msg_queue_alloc() here, as that
> both allocates the security struct and performs the create check.  So I
> would just call the _restore() function, and let it internally call
> ipc_alloc_security() to allocate the struct but then apply its own
> distinct restore check.  Likewise for the rest of them.

Ok, will change that.

> Also, where do we get to veto attempts to checkpoint the task in the
> first place?  If ptrace, I think we'd want it treated as a
> PTRACE_MODE_ATTACH (also used for /proc/pid/mem) rather than just
> PTRACE_MODE_READ (reading other /proc/pid info).

The checkpointing of ipc objects goes through an ipcperms(perm, S_IROTH)
check in ipc/checkpoint (at top of
http://git.ncl.cs.columbia.edu/?p=linux-cr.git;a=blob;f=ipc/checkpoint.c;h=88996e2b7abf328bd1b263400798ed5bd4924f48;hb=HEAD
)

But yes, for the task itself we check PTRACE_MODE_READ (line 280 in
http://git.ncl.cs.columbia.edu/?p=linux-cr.git;a=blob;f=checkpoint/checkpoint.c;h=a6dee4fb1085a47095f24443c48683a7fbc8ac59;hb=HEAD )
I had thought that PTRACE_MODE_ATTACH implied the permission to
actually modify the task.  If it also can imply a "very invasive" read 
then changing it certainly seems right.

thanks,
-serge
