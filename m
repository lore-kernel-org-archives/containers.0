From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] protect cap_netlink_recv from user namespaces
Date: Tue, 8 Nov 2011 03:29:02 +0000
Message-ID: <20111108032902.GA29433@hallyn.com>
References: <1320445482-8459-1-git-send-email-serge@hallyn.com>
	<1320445482-8459-7-git-send-email-serge@hallyn.com>
	<1320694510.10093.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1320694510.10093.23.camel@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: richard-/L3Ra7n9ekc@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric Paris (eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> On Fri, 2011-11-04 at 22:24 +0000, Serge Hallyn wrote:
> > From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > 
> > cap_netlink_recv() was granting privilege if a capability is in
> > current_cap(), regardless of the user namespace.  Fix that by
> > targeting the capability check against the user namespace which
> > owns the skb.
> > 
> > Caller passes the user ns down because sock_net is static inline defined in
> > net/sock.h, which we'd rather not #include at the cap_netlink_recv function.
> 
> This is wrong at least in relation to audit.

You may well be right, but before I proceed, I want to make sure that
you do see the current code is even more wrong?  But I was (as with the other
patch I reverted) probably overzealous and should have switched this a
different way (see bottom).

Regarding audit:  if I create a new network namespace, I can't open a
netlink socket to talk to the kernel.  At least,

	unshare -n /bin/bash
	# strace -f auditctl -l

shows -ECONNREFUSED from the sendto.  So I'm really not sure that the
kernel/audit.c patch is wrong.  (I want to make sure it's understood,
below, that I'm proposing tightening down the checks because that's more
in keeping with the purpose of this patchset, not because I agree the
checks are or will be, in the end, wrong)

>   I don't know the other
> code well enough to know if I think it's ok there.  Lets say I have
> (CAP_SYS_ADMIN | CAP_SETUID | CAP_SETGID) and I create a new task with
> CLONE_NEWNAME.

(just to be sure, do you mean CLONE_NEWUSER?)

>   This task then immediately does the needful to remove
> all audit rules (which supposedly requires CAP_AUDIT_CONTROL).  That's
> going to succeed because the task is init in it's namespace, aka:
> 
>         /* The creator of the user namespace has all caps. */
>         if (targ_ns != &init_user_ns && targ_ns->creator == cred->user)
>                 return 0;

That will only happen if the current user created the target user_ns.
So if task p1 created task p2 through clone(CLONE_NEWUSER), then p1 would
pass this on access check to p2's user_ns, but p2 would not.

But that really isn't related to the issue you raise.

> But it just screwed with a global resource.  aka audit.  I don't know
> the meaning of these others, but it seems to me probably most or all of
> them should be against the init_user_ns, not the namespace the skb came
> from....
> 
> What am I missing?

I'm not sure, depends on how much we're misunderstanding each other :)

But, regardless, your point is valid in that I'm not tightening down as
much as I could.  So how about I don't change the security_netlink_recv()
and callers yet, and instead I change cap_netlink_recv() to do:

	if (!IN_ROOT_USER_NS && !cap_raised(current_cap(), cap))

?

thanks,
-serge
