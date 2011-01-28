From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: udev in containers
Date: Fri, 28 Jan 2011 12:18:47 -0800
Message-ID: <m1pqrgvl20.fsf@fess.ebiederm.org>
References: <20110128144827.GA4981@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110128144827.GA4981@localhost> (Serge E. Hallyn's message of
	"Fri, 28 Jan 2011 08:48:27 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> Hi,
>
> Now that we are allowing udev to run in containers, Daniel has
> noticed that updates to sysfs uevent files will trigger a flurry
> of activity in all containers on the host.  While not a problem
> with just a few containers, this can severaly impact performance
> with hundreds or more containers.
>
> (Daniel, would it be possible for you to get some measurements
> on host and in a container versus # of active containers, with
> and without udev?  Do you have a otehrwise unused machien you
> could try that on?)
>
> Is there anything we can/should do about this?
>
> Two approaches, neither sufficiently thought out yet, would be
> to generalize the directory tagging currently used for
> /sys/class/net, and full-fledged implementation of a device
> namespace.
>
> The directory tagging would probably only work if we can assign
> multiple tags to a device, but we could for instance make
> /sys/block tagged, and really no container probably needs to see
> /sys/block/sda.
>
> The device namespace would be similar, except I suspect it
> would not only hide certain devices from certain namespaces,
> but it would actually virtualize the device major:minor
> mapping, for checkpoint/restart, so that /dev/sda could be
> redirected to another device more completely than simply
> fudging the nodes under /dev.
>
> Comments?  Designs?  Plans?

To answer you earlier question: What did I expect the device namespace
to look like.

- Only purely virtual devices like  /dev/pts, /dev/null, /dev/nbd and /dev/loop0 present.
- Fully virtualized major/minor look up preventing us from even talking
  about devices in other namespaces.
- Support from the user/security namespace so that mknod and mount are safe.

I get a certain uncomfortable feeling about mknod and mount running free
in a container without restrictions that make container without restrictions...

Eric
