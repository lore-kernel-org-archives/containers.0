From: Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>
Subject: Re: Thoughts on tightening up user namespace creation
Date: Wed, 09 Mar 2016 13:51:07 -0500
Message-ID: <1457549467.650797.544465346.49653120__22269.7481666275$1457549891$gmane$org@webmail.messagingengine.com>
References: <CALCETrU4+zTKABz1foEA=an3XYbe_UXxn_w9=1GjVzMe5DXXPw@mail.gmail.com>
	<CAGXu5jLB5==RAs9YrsPi4m6ZBPn3UtbCzagu_+gr-rtSgKzB1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5jLB5==RAs9YrsPi4m6ZBPn3UtbCzagu_+gr-rtSgKzB1Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 9, 2016, at 01:14 PM, Kees Cook wrote:
> On Mon, Mar 7, 2016 at 9:15 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> > Hi all-
> >
> > There are several users and distros that are nervous about user
> > namespaces from an attack surface point of view.
> >
> >  - RHEL and Arch have userns disabled.
> >
> >  - Ubuntu requires CAP_SYS_ADMIN
> >
> >  - Kees periodically proposes to upstream some sysctl to control
> > userns creation.
> 
> And here's another ring0 escalation flaw, made available to
> unprivileged users because of userns:
> 
> https://code.google.com/p/google-security-research/issues/detail?id=758

Looks like Andy won't have to eat his hat ;)

> The change in attack surface is _substantial_. We must have a way to
> globally disable userns.

No one would object if it was enabled but only accessible to
CAP_SYS_ADMIN though, right?  This could be useful for 
writing setuid binaries that expose some of the features, but e.g. not
CAP_NET_ADMIN.

Andy's suggestion of having this be a per-namespace setting makes
sense to me.  Currently some container tools that do use userns
are by default denying it to be recursive (Sandstorm.io and Docker 1.10 at least)
by using a seccomp filter on clone().  If we had this setting that
filter wouldn't be necessary, and would solve the issue that seccomp filters
aren't robust against the kernel adding new API, e.g. a new CLONE_NEWUSER_NONEWPRIVS
which might enable chroot() but not CAP_NET_ADMIN.
