From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: netns34
Date: Wed, 08 Aug 2007 08:57:20 -0600
Message-ID: <m1y7gmdqgf.fsf@ebiederm.dsl.xmission.com>
References: <m11wefgfl0.fsf@ebiederm.dsl.xmission.com>
	<m1wsw7f0r0.fsf@ebiederm.dsl.xmission.com> <46B9A620.4050906@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46B9A620.4050906-6ktuUTfB/bM@public.gmane.org> (Benjamin Thery's message of "Wed, 08
	Aug 2007 13:16:48 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-juSfH4iHXoxBDgjK7y7TUQ@public.gmane.org>, "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org> writes:

> Hi Eric,
>
> I've cloned the repository and built the kernel.
>
> Unshare support is broken. It misses a small change in sys_unshare()
> to accept the CLONE_NEWNET flag.
> I guess it should be added in commit "net: Add network namespace
> clone & unshare support." (See attached patch below)
>
> Also, have you removed the "sysfs interface support for moving devices between
> namespaces" on purpose?

More or less.

> Is there another way to move interfaces now?

I'm half way through the switch to using /bin/ip, and following of the
work the Patrick McHardy et all have doe.  The kernel side is there
(or it should be) but I haven't gotten the user space side built
and tested.

Migrating by exiting the namespace has worked well enough for testing
so I haven't worried about getting the user space side of things
working again.


Eric
