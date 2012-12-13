From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC][PATCH] Fix cap_capable to only allow owners in the parent
	user namespace to have caps.
Date: Thu, 13 Dec 2012 15:21:24 -0800
Message-ID: <CALCETrXLLcUu8Rajjx7+3N_6j5E0T0CR1h=hD+gcc5_r4Umyqw__45372.0994330526$1355440930$gmane$org@mail.gmail.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
	<87mwxhtxve.fsf@xmission.com> <87zk1hshk7.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87zk1hshk7.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Dec 13, 2012 at 2:39 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> Andy Lutomirski pointed out that the current behavior of allowing the
> owner of a user namespace to have all caps when that owner is not in a
> parent user namespace is wrong.
>
> This is a bug introduced by the kuid conversion which made it possible
> for the owner of a user namespace to live in a child user namespace.  I
> goofed and totally missed this implication.
>
> Serge and can you please take a look and see if my corrected cap_capable
> reads correctly to you.
>
> Andy or anyone else that wants to give me a second eyeball and double
> check me on this I would appreciate it.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
> ---
>
> diff --git a/security/commoncap.c b/security/commoncap.c
> index 6dbae46..4639f44 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -70,37 +70,44 @@ int cap_netlink_send(struct sock *sk, struct sk_buff *skb)
>   *
>   * NOTE WELL: cap_has_capability() cannot be used like the kernel's capable()
>   * and has_capability() functions.  That is, it has the reverse semantics:
>   * cap_has_capability() returns 0 when a task has a capability, but the
>   * kernel's capable() and has_capability() returns 1 for this case.
>   */
>  int cap_capable(const struct cred *cred, struct user_namespace *targ_ns,
>                 int cap, int audit)
>  {
>         for (;;) {
> -               /* The owner of the user namespace has all caps. */
> -               if (targ_ns != &init_user_ns && uid_eq(targ_ns->owner, cred->euid))
> -                       return 0;
> +               struct user_namespace *parent_ns;
>
>                 /* Do we have the necessary capabilities? */
>                 if (targ_ns == cred->user_ns)
>                         return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
>
>                 /* Have we tried all of the parent namespaces? */
>                 if (targ_ns == &init_user_ns)
>                         return -EPERM;
>
> +               parent_ns = targ_ns->parent;
> +
> +               /*
> +                * The owner of the user namespace in the parent user
> +                * namespace has all caps.
> +                */
> +               if ((parent_ns == cred->user_ns) && uid_eq(targ_ns->owner, cred->euid))
> +                       return 0;

This is confusing enough that I can't immediately tell whether it's
correct.  I think it's close but out of order.

Should this be transitive?  I.e. suppose uid 1 owns a child of
init_user_ns and uid 2 (mapped in the first ns as the identity) owns
an inner ns.  Does uid 2 in the root ns have all caps inside?  I'd say
no, but I don't have a great argument for that.  But uid 1 presumably
does have caps because it could enter the parent with setns, then
change uid, then enter the child.

How about (severely whitespace damaged):

int cap_capable(const struct cred *cred, struct user_namespace *targ_ns,
                int cap, int audit)
{
        struct user_namespace *here = targ_ns;

        /* Walk up the namespace hierarchy until we find our own namespace. */
        for (;;) {
                /* The owner of an ancestor namespace has all caps, if
that owner is in the parent ns. */
                if (cred->user_ns == here->parent &&
uid_eq(targ_ns->owner, cred->euid))
                        return 0;

                /* Do we have the necessary capabilities? */
                if (here == cred->user_ns)
                        return cap_raised(cred->cap_effective, cap) ?
0 : -EPERM;

                /* Have we tried all of the parent namespaces? */
                if (here == &init_user_ns)
                        return -EPERM;
                else
                        here = targ_ns->parent;
        }
}

--Andy
