From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device
	sysfs entries
Date: Wed, 22 Oct 2008 15:54:23 -0700
Message-ID: <m11vy8jl5s.fsf__49283.9447259486$1224716819$gmane$org@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<m1d4hso0ym.fsf@frodo.ebiederm.org> <20081022203045.GA4633@us.ibm.com>
	<m18wsgmji0.fsf@frodo.ebiederm.org> <20081022145507.2d1ea86c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081022145507.2d1ea86c@extreme> (Stephen Hemminger's message of
	"Wed, 22 Oct 2008 14:55:07 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Dave Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> writes:

>> The well-known user space tools don't use /sys at all.  Modern
>> network tools use rtnetlink (ip) old network tools use /proc/net.
>> 
>> Very few things actually use /sys and for those things lo@1 or
>> eth0@1 are completely useless except for implementing a FUSE
>> mock up of sysfs.  But you don't need anything in sysfs to do
>> that as all of the interesting information is available through
>> /proc/net or rtnetlink.
>
> Lots of scripts are starting use /sys for things. It is easier to
> parse /sys/class/net than the output of ifconfig or ip 

Yes.  So we need the correct values in /sys/class/net.

Which is why sysfs and network namespaces do not coexist currently.

Which is why I recommend only placing devices in the initial network
namespace in sysfs for the short term.

Which is why we need to get all of the details correct when we
handle multiple network namespaces and sysfs.

I should have something working and should be sending patches out
shortly.  Cleaning up sysfs and the device model enough so the changes
are not spooky is a long hard road unfortunately.

Eric
