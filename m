From: Stephen Smalley <sds-FVV4AS6k8l2W8mdqIt43Ew@public.gmane.org>
Subject: Re: [PATCH 3/5] cr: add generic LSM c/r support
Date: Mon, 31 Aug 2009 08:45:50 -0400
Message-ID: <1251722750.16143.31.camel@moss-pluto.epoch.ncsc.mil>
References: <20090828210041.GA27878@us.ibm.com>
	 <20090828210417.GC28048@us.ibm.com> <4A98AEDE.1000105@schaufler-ca.com>
	 <20090829224147.GA12549@hallyn.com> <4A99BC58.9040205@schaufler-ca.com>
	 <20090830135800.GC14699@hallyn.com>  <4A9ACD0A.9050004@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <owner-selinux-MESi4pFTnrejpDF0oNHs+n7yKkN/O5/Z@public.gmane.org>
In-Reply-To: <4A9ACD0A.9050004-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Sender: owner-selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Cc: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, SELinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, 2009-08-30 at 12:03 -0700, Casey Schaufler wrote:
> Serge E. Hallyn wrote:
> > Quoting Casey Schaufler (casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org):
> >   
> >> Serge E. Hallyn wrote:
> >>     
> >>> Quoting Casey Schaufler (casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org):
> >>>       
> >>>> But each can be expressed as a context, can't it?
> >>>>     
> >>>>         
> >>> A set of contexts (root_u:root_r:root_t:::system_u:system_r\
> >>> :system_t::...).
> >>>
> >>> There would be a problem if it were stored as a more
> >>> structured type, and if the ->restore handler wanted to
> >>> re-create an actual task_security_struct, ipc_security_struct,
> >>> etc.  So the last paragraph in the patch intro was just trying to
> >>> explain why the intermediate layer, storing a generic string on
> >>> the c/r object hash, needs to be there.  The thing that is
> >>> not possible is to place the actual void *security or a struct
> >>> task_security_struct on the objhash.
> >>>   
> >>>       
> >> Right. Now why do you need a set of contexts?
> >>     
> >
> > Because for SELinux, for instance, when checkpointing a security
> > context for a task, we want to checkpoint the actual context,
> > the fscreate context, the sockcreate context, keycreate context,
> > and the task create (exec_create) context.
> >   
> 
> My. That is quite a lot of contexts to keep track of.

Doesn't Smack also have at least one case where it supports multiple
distinct contexts for different purposes on a single object (e.g.
sockets)?

-- 
Stephen Smalley
National Security Agency
