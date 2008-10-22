From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device
	sysfs entries
Date: Wed, 22 Oct 2008 12:59:29 -0700
Message-ID: <m1d4hso0ym.fsf__14061.6699275144$1224706134$gmane$org@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081022152144.351965414-4vkkeT0zb4ZEtYaxpPmRp1aPQRlvutdw@public.gmane.org> (Benjamin Thery's
	message of "Wed, 22 Oct 2008 17:21:44 +0200")
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
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Dave Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org> writes:

> Support for network namespaces in mainline is pretty complete for
> some time now, but there is still this issue with sysfs that prevents 
> more people to use it easily.

Ben your patchset is completely inappropriate.

Temporarily adding elements to the ABI that we intend to remove
is not a proper solution to this problem.

That user space visible ida you add is a namespace identifier that breaks
nested containers and migration.  It is very very very wrong.

Eric
