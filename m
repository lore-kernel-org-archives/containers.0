From: "Kyle Moffett" <kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org>
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device
	sysfs entries
Date: Thu, 23 Oct 2008 00:14:19 -0400
Message-ID: <f73f7ab80810222114k7caffd16wbeb464c4739bfc77__25512.9185076386$1224735403$gmane$org@mail.gmail.com>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<m1d4hso0ym.fsf@frodo.ebiederm.org> <20081022203045.GA4633@us.ibm.com>
	<m18wsgmji0.fsf@frodo.ebiederm.org> <20081022145507.2d1ea86c@extreme>
	<m11vy8jl5s.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11vy8jl5s.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>, Dave Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Oct 22, 2008 at 6:54 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> writes:
>>> The well-known user space tools don't use /sys at all.  Modern
>>> network tools use rtnetlink (ip) old network tools use /proc/net.
>>>
>>> Very few things actually use /sys and for those things lo@1 or
>>> eth0@1 are completely useless except for implementing a FUSE
>>> mock up of sysfs.  But you don't need anything in sysfs to do
>>> that as all of the interesting information is available through
>>> /proc/net or rtnetlink.
>>
>> Lots of scripts are starting use /sys for things. It is easier to
>> parse /sys/class/net than the output of ifconfig or ip
>
> Yes.  So we need the correct values in /sys/class/net.
>
> Which is why sysfs and network namespaces do not coexist currently.

I definitely agree that "eth0@1" is a bad ide. I know for sure that a
relatively large number of system init scripts poke about in
/sys/class/net/$IFACE, as well as a number of the system installation
scripts.  Those scripts include some that my company has written for
internal use and others supplied by distributions.

Daemons and such mostly use netlink, but for anything written in shell
it's much easier to do things like this:

for devpath in /sys/class/net/*; do
    dev="${dev##/sys/class/net/}"
    case "${dev}" in
        [....]
    esac
    if [ "x${mac}" = "x$(cat ${devpath}/address)" ]; then
        echo "Found MAC '${mac}': ${dev}"
    fi
done

If I wanted to perform similar things with the output of ifconfig, it
would involve some much more fragile manual text parsing of the output
of the "ip" or "ifconfig" commands.  And sometimes the "ifconfig"
command is outright wrong.  If you have an interface name longer than
7 characters or so then some versions of ifconfig will truncate it
internally and display garbage.

While the "show only the root namespace" interim solution is
problematic for processes in network namespaces, I think it's more
important not to break things for admin tools in the root namespace.

Cheers,
Kyle Moffett
