From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device
	sysfs entries
Date: Wed, 22 Oct 2008 14:01:59 -0700
Message-ID: <m18wsgmji0.fsf__31678.7237338305$1224709707$gmane$org@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<m1d4hso0ym.fsf@frodo.ebiederm.org> <20081022203045.GA4633@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081022203045.GA4633-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Wed, 22 Oct 2008 15:30:45 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Dave Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org> writes:
>> 
>> > Support for network namespaces in mainline is pretty complete for
>> > some time now, but there is still this issue with sysfs that prevents 
>> > more people to use it easily.
>> 
>> Ben your patchset is completely inappropriate.
>> 
>> Temporarily adding elements to the ABI that we intend to remove
>> is not a proper solution to this problem.
>> 
>> That user space visible ida you add is a namespace identifier that breaks
>> nested containers and migration.  It is very very very wrong.
>
> I disagree (not surprising :) completely.  The well-known userspace
> tools (ifconfig, ip, etc) will not see the lo@1, they'll see lo.
> Userspace in a container can either umount /sys completely, or do

The well-known user space tools don't use /sys at all.  Modern
network tools use rtnetlink (ip) old network tools use /proc/net.

Very few things actually use /sys and for those things lo@1 or
eth0@1 are completely useless except for implementing a FUSE
mock up of sysfs.  But you don't need anything in sysfs to do
that as all of the interesting information is available through
/proc/net or rtnetlink.

>
> 	mount -t tmpfs none /sys/class/net
> 	mount --bind /sys/devices/virtual/net/lo@1 /sys/class/net/lo
>
> if they really want to, in which case only their view
> of /sys/devices/virtual/net would be different.
>
> Eric, would you hate this less if it was under some
>
> 	CONFIG_SYSFS_NETNS_HACK
>
> config variable?

No.  ABI decisions are almost certainly irreversible.

If we need an immediate hack please see the patch I sent
in follow up.  We can achieve everything Ben is doing by simply
keeping virtual devices out of the kobject tree.  Keeping them
from showing up in sysfs.

Eric
