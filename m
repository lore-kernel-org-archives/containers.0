From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 3/5] cr: add generic LSM c/r support
Date: Sun, 30 Aug 2009 08:58:00 -0500
Message-ID: <20090830135800.GC14699@hallyn.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210417.GC28048@us.ibm.com> <4A98AEDE.1000105@schaufler-ca.com> <20090829224147.GA12549@hallyn.com> <4A99BC58.9040205@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A99BC58.9040205@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, Stephen Smalley <sds@epoch.ncsc.mil>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey@schaufler-ca.com):
> Serge E. Hallyn wrote:
> > Quoting Casey Schaufler (casey@schaufler-ca.com):
> >> But each can be expressed as a context, can't it?
> >>     
> >
> > A set of contexts (root_u:root_r:root_t:::system_u:system_r\
> > :system_t::...).
> >
> > There would be a problem if it were stored as a more
> > structured type, and if the ->restore handler wanted to
> > re-create an actual task_security_struct, ipc_security_struct,
> > etc.  So the last paragraph in the patch intro was just trying to
> > explain why the intermediate layer, storing a generic string on
> > the c/r object hash, needs to be there.  The thing that is
> > not possible is to place the actual void *security or a struct
> > task_security_struct on the objhash.
> >   
> 
> Right. Now why do you need a set of contexts?

Because for SELinux, for instance, when checkpointing a security
context for a task, we want to checkpoint the actual context,
the fscreate context, the sockcreate context, keycreate context,
and the task create (exec_create) context.

> > ...
> >
> >   
> >>> +	/* str will be alloc'ed for us by the LSM.  We will free it when
> >>> +	 * we clear out our hashtable */
> >>>   
> >>>       
> >> Why do you think that you need a copy? Sure, SELinux always gives you
> >> a copy, but Smack keeps "contexts" around and making a copy is not only
> >> unnecessary, but wasteful. If you free the "context" with the appropriate
> >> call (security_release_secctx) you will get the "free allocated memory"
> >> behavior desired by SELinux and the "do nothing" behavior of Smack. For
> >> free, assuming that you also fix your Smack hook so that it works in the
> >> way Smack deems "Correct".
> >>     
> >
> > Hmm, that should be doable.  Mind you these are not the same as
> > secctx's returned by secid_to_secctx.
> 
> Now why is that? If they are different things, what are they?
> 
> What is the difference between a secctx and a context?
> I got a bit confused because the word "context" has been
> used to refer to the thing represented by a secctx for a
> long time.

I know, I know,  I should come up with a better name.  But while
an selinux context would be

  root_u:root_r:root_t

the blob I have to checkpoint for a task would perhaps be

  root_u:root_r:root_t:::null:::null::null:::user_u:serge_r:serge_t:::null

thanks,
-serge
