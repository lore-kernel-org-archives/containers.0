From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] userns: honour no_new_privs for cap_bset during user ns
	creation/switch
Date: Fri, 22 Dec 2017 02:51:49 +0100
Message-ID: <CAHo-OoxoTEZuQ0ZXa9a2BnjAv83y0UWC0eqn-ok9hS31LkiiSA__46008.4412633025$1513907421$gmane$org@mail.gmail.com>
References: <20171221210605.181720-1-zenczykowski@gmail.com>
	<87wp1foiwa.fsf@xmission.com>
	<CAHo-OoyrOr5jXwU-j4Z4qYdWo40+qAdAk0r+OpfMUZ6LgbS-RA@mail.gmail.com>
	<87fu83lfw5.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fu83lfw5.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mahesh Bandewar <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

> Good point about CAP_DAC_OVERRIDE on files you own.
>
> I think there is an argument that you are playing dangerous games with
> the permission system there, as it isn't effectively a file you own if
> you can't read it, and you can't change it's permissions.

Append-only files are useful - particularly for logging.
It could also simply be a non-readable file on a R/O filesystem.

> Given little things like that I can completely see no_new_privs meaning
> you can't create a user namespace.  That seems consistent with the
> meaning and philosophy of no_new_privs.  So simple it is hard to get
> wrong.

Yes, I could totally buy the argument that no_new_privs should prevent
creating a user ns.

However, there's also setns() and that's a fair bit harder to reason about.
Entirely deny it?  But that actually seems potentially useful...
Allow it but cap it?  That's what this does...

> We could do more clever things like plug this whole in user namespaces,
> and that would not hurt my feelings.

Sure, this particular one wouldn't be all that easy I think... and how
many such holes are there?
I found this particular one *after* your first reply in this thread.

> However unless that is our only
> choice to avoid badly breaking userspace I would have to have to depend
> on user namespaces being perfect for no_new_privs to be a proper jail.

This stuff is ridiculously complex to get right from userspace. :-(

> As a general rule user namespaces are where we tackle the subtle scary
> things that should work, and no_new_privs is where we implement a simple
> hard to get wrong jail.  Most of the time the effect is the same to an
> outside observer (bounded permissions), but there is a real difference
> in difficulty of implementation.

So, where to now...

Would you accept patches that:

- make no_new_priv block user ns creation?

- make no_new_priv block user ns transition?

Or perhaps we can assume that lack of create privs is sufficient, and
if there's a pre-existing user ns for you to enter, then that's
acceptable...
Although this implies you probably always want to combine no_new_privs
with a leaf user ns, or no_new_privs isn't all that useful for root in
root ns...
This added complexity, probably means it should be blocked...

- inherits bset across user ns creation/transition based on X?
[this is the one we care about, because there are simply too many bugs
in the kernel wrt. certain caps]
X could be:
- a new flag similar to no_new_priv
- a new securebit flag (w/lockbit)  [provided securebits survive a
userns transition, haven't checked]
- or perhaps a new capability
- something else?

How do we make forward progress?
