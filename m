From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] Fix cap_capable to only allow owners in the parent
	user namespace to have caps.
Date: Thu, 13 Dec 2012 18:33:27 -0800
Message-ID: <876245jrbc.fsf__373.95980111814$1355452444$gmane$org@xmission.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
	<87mwxhtxve.fsf@xmission.com> <87zk1hshk7.fsf_-_@xmission.com>
	<CALCETrXLLcUu8Rajjx7+3N_6j5E0T0CR1h=hD+gcc5_r4Umyqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrXLLcUu8Rajjx7+3N_6j5E0T0CR1h=hD+gcc5_r4Umyqw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Lutomirski's message of "Thu, 13 Dec 2012 15:21:24 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


Andy thank you for your review.

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
> This is confusing enough that I can't immediately tell whether it's
> correct.  I think it's close but out of order.

Yeah.  That is the trick. Figuring out how to write that code so it is
correct and obvious.

I have added a comment at the top and removed the extra variable I was
adding.

The order except for verifying a user_ns->parent is valid by checking
for targ_ns == &init_user_ns doesn't make a difference.  Because
cred->user_ns can only be one of targ_ns or targ_ns->parent.

> Should this be transitive?

Yes.
>  I.e. suppose uid 1 owns a child of
> init_user_ns and uid 2 (mapped in the first ns as the identity) owns
> an inner ns.  Does uid 2 in the root ns have all caps inside?  I'd say
> no, but I don't have a great argument for that. 

I also say no.  It is more code and it doesn't fit my nice small
definition.  You have to be the owner and you have to be in the parent
of the target user namespace.  Being able to remember the rules in
your head is important.

> But uid 1 presumably
> does have caps because it could enter the parent with setns, then
> change uid, then enter the child.

Yes. uid 1 does have caps.

> How about (severely whitespace damaged):

You know that makes the termination condition a bit clearer.  But it
looses the nice place to put a comment when we loop again.  This loop
is just subtle enough that I want to preserve my comments.

I think I must have put -EPERM towards the end for the same reason to
make it clear that is the termination condition.

In practice I think it is important to have the cap_raised case first,
as that is the common case, and if we can be clear and still test that
case first it means the code will be faster.  With my reordering it is
obvious that nothing strange happens in the initial user namespace with
the owner test after the exit when we are the initial user namespace.

> int cap_capable(const struct cred *cred, struct user_namespace *targ_ns,
>                 int cap, int audit)
> {
>         struct user_namespace *here = targ_ns;
>
>         /* Walk up the namespace hierarchy until we find our own namespace. */
>         for (;;) {
>                 /* The owner of an ancestor namespace has all caps, if
> that owner is in the parent ns. */
>                 if (cred->user_ns == here->parent &&
> uid_eq(targ_ns->owner, cred->euid))
>                         return 0;

This would have needed a check that (here != &init_user_ns).  Because
the init_user_ns does not have a parent.

>                 /* Do we have the necessary capabilities? */
>                 if (here == cred->user_ns)
>                         return cap_raised(cred->cap_effective, cap) ?
> 0 : -EPERM;
>
>                 /* Have we tried all of the parent namespaces? */
>                 if (here == &init_user_ns)
>                         return -EPERM;
>                 else
>                         here = targ_ns->parent;
>         }
> }
