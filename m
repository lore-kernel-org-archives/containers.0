From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Thoughts on tightening up user namespace creation
Date: Tue, 8 Mar 2016 00:06:57 -0600
Message-ID: <20160308060657.GA3565@mail.hallyn.com>
References: <CALCETrU4+zTKABz1foEA=an3XYbe_UXxn_w9=1GjVzMe5DXXPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrU4+zTKABz1foEA=an3XYbe_UXxn_w9=1GjVzMe5DXXPw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 07, 2016 at 09:15:25PM -0800, Andy Lutomirski wrote:
> Hi all-
> 
> There are several users and distros that are nervous about user
> namespaces from an attack surface point of view.
> 
>  - RHEL and Arch have userns disabled.
> 
>  - Ubuntu requires CAP_SYS_ADMIN

No, it does not.  It has temporarily re-added a sysctl which can enable
that behavior, but it's not set by default.  The reason for providing it
is not a distrust of user namespaces in general, but because we're enabling
some bleeding edge patches which haven't been accepted upstream yet.  Once
they're accepted upstream I expect that patch to be dropped again, unless
it has gone upstream.

Debian does afaik still have a version of a patch I'd originally written
before user namespaces were upstream which defaulted unprivileged userns
cloning to off.  Did you mean Debian here?

>  - Kees periodically proposes to upstream some sysctl to control
> userns creation.
> 
> I think there are three main types of concerns.  First, there might be
> some as-yet-unknown semantic issues that would allow privilege
> escalation by users who create user namespaces and then confuse
> something else in the system.  Second, enabling user namespaces
> exposes a lot of attack surface to unprivileged users.  Third,
> allowing tasks to create user namespaces exposes the kernel to various
> resource exhaustion attacks that wouldn't be possible otherwise.
> 
> Since I doubt we'll ever fully address the attack surface issue at
> least, would it make sense to try to come up with an upstreamable way
> to limit who can create new user namespaces and/or do various
> dangerous things with them?
> 
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
> 
> It might be more interesting to allow a task to unshare all
> namespaces, hold all capabilities in them, but to still be unable to
> use certain privileged facilities.  For example, maybe denying
> administrative control over iptables, creation of exotic network
> interface types, or similar would make sense.  I don't know how we'd
> specify this type of constraint.
> 
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
> 
> 
> 
> 
> Thoughts?
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
