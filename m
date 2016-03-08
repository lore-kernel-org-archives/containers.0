From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Thoughts on tightening up user namespace creation
Date: Tue, 08 Mar 2016 10:31:09 -0600
Message-ID: <874mch2ape.fsf@x220.int.ebiederm.org>
References: <CALCETrU4+zTKABz1foEA=an3XYbe_UXxn_w9=1GjVzMe5DXXPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrU4+zTKABz1foEA=an3XYbe_UXxn_w9=1GjVzMe5DXXPw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Lutomirski's message of "Mon, 7 Mar 2016 21:15:25 -0800")
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
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:

> Hi all-

[Snip strange things distros do]

Distros do strange things from other peoples perspectives.  Sometimes we
can help with that sometimes we can't.  In general producing kernel code
that is reliable and well maintained is what we can do.  Distro folks
can decide what they are comfortable beyond that.

Frankly I find it heartening that not all distros enable everything all
of the time, are are showing some modicum of restraint and judgement.

If folks don't think a feature like user namespaces is ready and they
don't need that feature I am quite happy for them not to enable that
feature in their kernel.

> Since I doubt we'll ever fully address the attack surface issue at
> least, would it make sense to try to come up with an upstreamable way
> to limit who can create new user namespaces and/or do various
> dangerous things with them?

Even without user namespaces the kernel has attack surface issues.  The
kernel is big and bugs happen.  That surface is only bigger when you are
root in a user namespace so the probability of a finding an exploitable
bug goes up.

> I'll divide the rest of the email into the "what" and the "who".
>
> +++ What does the privilege of creating a user namespace entail? +++
>
> This could be an all-or-nothing thing.  It would certainly be possible
> for appropriately privileged tasks to be able to unshare namespaces
> and use their facilities exactly like any task can in a current
> user-ns-enabled kernel and for other tasks to be unable to unshare
> anything.
>
> Finer gradations are, in principle, possible.  For example, it could
> be possible for a given task to unshare its userns but to have limited
> caps inside or to be unable to unshare certain other namespaces.  For
> example, maybe a task could unshare userns and mount ns but not net
> ns.  I don't think this would be particularly useful.

I am actually inclined to think just the opposite.  There was a period
where would have been much less susceptible to problems if just
unprivileged create to the mount namespace could have been implemented.

When I look at this from a resource consumption point of view I
definitely see arguments for limiting things by resource type.  As it
can be very easy to know I need no more than X of some specific resource
type but that I don't know how much memory that will take.

> It might be more interesting to allow a task to unshare all
> namespaces, hold all capabilities in them, but to still be unable to
> use certain privileged facilities.  For example, maybe denying
> administrative control over iptables, creation of exotic network
> interface types, or similar would make sense.  I don't know how we'd
> specify this type of constraint.

That does seem to start approaching lsm territory.  And there is a funny
balance between reducing attack surface and adding attack surface to
reduce attack surface.

> +++ Who can create user namespaces (possibly with restrictions)? +++
>
> I can think of a few formulations.
>
> A simpler approach would be to add a per-namespace setting listing
> users and/or groups that can unshare their userns.  A userns starts
> out allowing everyone to unshare userns, and anyone with CAP_SYS_ADMIN
> can change the setting.
>
> A fancier approach would be to have an fd that represents the right to
> unshare your userns.  Some privilege broker could give out those fds
> to apps that need them and meet whatever criteria are set.  If you try
> to unshare your userns without the fd, it falls back to some simpler
> policy.
>
> I think I prefer the simpler one.  It's simple, and I haven't come up
> with a concrete problem with it yet.

Agreed.  Your simple scheme is roughly what I was proposing earlier of
having a per user limit on the number of user namespaces they can
create.

I am a little partial to having it be a resource limit as that covers
more use cases with less code.

That said the really important case to cover is the case where some
subset of applications are denied access to resources (for sandboxing)
and another subset is allowed.

Eric
