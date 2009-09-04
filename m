From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 3/5] cr: add generic LSM c/r support
Date: Fri, 4 Sep 2009 08:38:55 -0500
Message-ID: <20090904133855.GA11203@us.ibm.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210417.GC28048@us.ibm.com> <4A98AEDE.1000105@schaufler-ca.com> <20090829224147.GA12549@hallyn.com> <4A99BC58.9040205@schaufler-ca.com> <20090830135800.GC14699@hallyn.com> <4A9ACD0A.9050004@schaufler-ca.com> <1251722750.16143.31.camel@moss-pluto.epoch.ncsc.mil> <4A9CB5F9.3000509@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A9CB5F9.3000509@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Stephen Smalley <sds@epoch.ncsc.mil>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey@schaufler-ca.com):
> Stephen Smalley wrote:
> > On Sun, 2009-08-30 at 12:03 -0700, Casey Schaufler wrote:
> >   
> >> Serge E. Hallyn wrote:
> >>     
> >>> Quoting Casey Schaufler (casey@schaufler-ca.com):
> >>>   
> >>>       
> >>>> Serge E. Hallyn wrote:
> >>>>     
> >>>>         
> >>>>> Quoting Casey Schaufler (casey@schaufler-ca.com):
> >>>>>       
> >>>>>           
> >>>>>> But each can be expressed as a context, can't it?
> >>>>>>     
> >>>>>>         
> >>>>>>             
> >>>>> A set of contexts (root_u:root_r:root_t:::system_u:system_r\
> >>>>> :system_t::...).
> >>>>>
> >>>>> There would be a problem if it were stored as a more
> >>>>> structured type, and if the ->restore handler wanted to
> >>>>> re-create an actual task_security_struct, ipc_security_struct,
> >>>>> etc.  So the last paragraph in the patch intro was just trying to
> >>>>> explain why the intermediate layer, storing a generic string on
> >>>>> the c/r object hash, needs to be there.  The thing that is
> >>>>> not possible is to place the actual void *security or a struct
> >>>>> task_security_struct on the objhash.
> >>>>>   
> >>>>>       
> >>>>>           
> >>>> Right. Now why do you need a set of contexts?
> >>>>     
> >>>>         
> >>> Because for SELinux, for instance, when checkpointing a security
> >>> context for a task, we want to checkpoint the actual context,
> >>> the fscreate context, the sockcreate context, keycreate context,
> >>> and the task create (exec_create) context.
> >>>   
> >>>       
> >> My. That is quite a lot of contexts to keep track of.
> >>     
> >
> > Doesn't Smack also have at least one case where it supports multiple
> > distinct contexts for different purposes on a single object (e.g.
> > sockets)?
> >   
> 
> Smack does support associating labels with incoming and/or
> outgoing packets from a particular socket. I haven't looked
> carefully at how the checkpoint/restart scheme is handling
> sockets in general, so I couldn't say if its going to get the

So far there is only unix socket support, and I haven't touched
that with the LSM c/r code yet as it's very new.

> rest of it right, either. In any case, that's something that
> is strictly in the realm of privileged processes for which
> checkpoint/restart is going to be one hairy potato.

The point however is that to c/r the full socket state for
smack, we'll need to stuff three labels into the checkpoint
image.  So we'll need to do something similar to the selinux
code, allocating memory, which we'll need to free.  So if
we're to use smack_release_secctx we need to be able to
tell the difference between a context we have to free, and
one we don't have to free.  We could do that by prepending
the socket ones with '-' (which is not a valid label according
to smack_access.c), and have release_secctx kfree anything
starting with '-'?

> Processes that use this mechanism will be quite rare. The
> Smack port multiplexer (smackpolyport) that I'll be talking
> about in Portland and a small set of security enforcing
> applications should be about it.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
