From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 0/8] a start to credentials c/r
Date: Wed, 27 May 2009 07:37:28 -0500
Message-ID: <20090527123728.GA27160@us.ibm.com>
References: <20090526173242.GA13757@us.ibm.com> <4A1CAE03.7090005@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A1CAE03.7090005@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey@schaufler-ca.com):
> Serge E. Hallyn wrote:
> > Following is the next version of the credentials c/r patchset,
> > on top of the c/r patchset at
> > git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git
> >
> > It implements checkpoint and restart of user, user namespaces,
> > groups, supplementary groups, and struct cred.
> >
> > There is a question as to what to do about LSM data at
> > restart.  Right now I'm ignoring it, which means that
> > prepare_creds() should ensure that the restart tasks get
> > the context of the task calling sys_restart().  I
> > suspect the right thing to do is to add two new LSM
> > hooks, one which checks current's authorization to
> > restart from the checkpoint file,
> 
> How would that work? Based on information in the file?
> You have to assume that some number of checkpoint files
> have been hand written by Elbonian ne'er do wells.

Not based on information in the file, but based on the
credentials of the task which created the file, and
whether an unprivileged task could have hand-edited the
file before feeding it to sys_restart().

So some example decisions in terms of selinux contexts might be,
	1. a task of user_u may restart a file of type user_u
	if the checkpointed context is user_u
	2. a task of user_u may NOT restart a file of type user_u
	if the checkpointed context is root_u
	3. a task of root_u may restart a file of type root_u
	if the checkpointed context is user_u

Uh, so yes, bsaed on info in the file as well  :)  Except
of course the LSM would just be fed the checkpointed context
and the checkpoint file context (and can deduce current's context).

> >  and one which determines
> > the task->cred->security filed based upon any of:
> > 	1. current_security() of the task calling sys_restart()
> > 	2. the task->cred->security checkpointed in the ckpt file
> > 	3. the ->security of the checkpoint file
> >   
> 
> For Smack the correct behavior would be:
> 
>     1. for sys_restart() callers without CAP_MAC_ADMIN
>     2. for sys_restart() callers with CAP_MAC_ADMIN
>     3. never

That makes sense, and is basically analagous (if I'm thinking
right) to how I'm doing capabilities.

So the first (authorization hook) for smack would just always
return TRUE?

I can hook that up right now...

> sys_restart() callers running with CAP_MAC_ADMIN would have to be
> very very careful about the files they restart. But that's nothing
> new in the MAC world.

Yup.

Mind you eventually I expect a setup where some privileged program
is asked (by privileged or unprivilegd tasks) to create a checkpoint
and ask the TPM to sign it.  No unprivileged program can sign an
image directly, so then a restart of a task with privilege can be
restricted to anything with a valid signature.  In that case, it
may be safe to have the checkpointed task's credentials completely
restored, including LSM labels.

But that's a ways off.

thanks,
-serge
