From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: Thoughts on tightening up user namespace creation
Date: Wed, 9 Mar 2016 10:14:39 -0800
Message-ID: <CAGXu5jLB5==RAs9YrsPi4m6ZBPn3UtbCzagu_+gr-rtSgKzB1Q@mail.gmail.com>
References: <CALCETrU4+zTKABz1foEA=an3XYbe_UXxn_w9=1GjVzMe5DXXPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 7, 2016 at 9:15 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> Hi all-
>
> There are several users and distros that are nervous about user
> namespaces from an attack surface point of view.
>
>  - RHEL and Arch have userns disabled.
>
>  - Ubuntu requires CAP_SYS_ADMIN
>
>  - Kees periodically proposes to upstream some sysctl to control
> userns creation.

And here's another ring0 escalation flaw, made available to
unprivileged users because of userns:

https://code.google.com/p/google-security-research/issues/detail?id=758

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

The change in attack surface is _substantial_. We must have a way to
globally disable userns.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
