From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net
	device sysfs entries
Date: Wed, 22 Oct 2008 14:24:17 -0700
Message-ID: <20081022212417.GA10265__41565.9389961094$1224711140$gmane$org@suse.de>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<20081022201601.GC24959@suse.de>
	<m17i80l4mt.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m17i80l4mt.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
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
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Dave Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Oct 22, 2008 at 02:08:26PM -0700, Eric W. Biederman wrote:
> Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> writes:
> 
> > On Wed, Oct 22, 2008 at 05:21:44PM +0200, Benjamin Thery wrote:
> >> Network devices from sub-network namespaces appear in sysfs
> >> with a name that looks like this: device_name@netns_id
> >> eg: lo@3, eth0@4e
> >
> > How does the default udev rules as shipped by most distros handle the
> > renaming of the network device if the MAC address is duplicated like it
> > will be for these eth devices?
> 
> The mac address is not duplicated.

Ah, ok, I really don't think I want to know more :)

> Further devices like eth0@4e are completely unusable to the udev
> rules in the initial network namespace because they can not talk
> to or affect them.

Oh, good point.

> As I read it Ben's ``solution'' puts entries in sysfs that are
> completely unusable to udev.

That's not a good thing to do, if udev can't see them, than HAL can't
see them, then the rest of userspace usually has no idea they are
present either.

thanks,

greg k-h
