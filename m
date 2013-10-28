From: Andrey Wagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Device Namespaces
Date: Tue, 29 Oct 2013 03:31:17 +0400
Message-ID: <CANaxB-x0tqoxh+oELSfXXFao0hOX3xo3hxBSR0BZGqymbwUDmg@mail.gmail.com>
References: <CAA4jN2aw4zEW=UfKCyqaOvXnbiRb_J9srfCn4OXTFzc6vWBM4A@mail.gmail.com>
	<20130822182118.GA28331@sergelap>
	<CAA4jN2YL7Lfu2+DW-i+MovFxWEhJfT4aBBKREU_vy7JX9TKGHA@mail.gmail.com>
	<8761udlu0d.fsf@xmission.com>
	<CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
	<871u4yddg4.fsf@xmission.com>
	<CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
	<CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw@mail.gmail.com>
	<87bo3gshz5.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bo3gshz5.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

2013/9/26 Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
>
> From conversations at Linux Plumbers Converence it became fairly clear
> that one if not the roughest edge on containers today is dealing with
> devices.
>
> - Hotplug does not work.
> - There seems to be no implementation that does a much beyond creating
>   setting up a static set of /dev entries today.
> - Containers do not see the appropriate uevents for their container.
>
> One of the more compelling cases I heard was of someone who was running
> the a Linux Desktop in container and wanted to just let that container
> see the devices needed for his desktop, and not everything else.

I had experience of implementing this functionality in OpenVZ kernel.
I had requirements to not modify user-space tools, so that
implementations looks as dirty hack, but even hotplug of devices are
workin there.

....

>
> So the big issues for a device namespace to solve are filtering which
> devices a container has access to and being able to dynamically change
> which devices those are at run time (aka hotplug).
>
> After having thought about this for a bit I don't know if a pure
> userspace solution is sufficient or actually a good idea.

I would prefer to think a bit more about userspace solution. We can
try to expand udev functionality.

>
> - We can manually manage a tmpfs with device nodes in userspace.
>   (But that is deprecated functionality in the mainstream kernel).
> - We can manually export a subset of sysfs with bind mounts.
>   (But that feels hacky, and is essentially incompatible with hotplug).
> - We can relay a call of /sbin/hotplug from outside of a container
>   to inside of a container based on policy.
>   (But no one uses /sbin/hotplug anymore).
> - There is no way to fake netlink uevents for a container to see them.
>   (The best we could do is replace udev everywhere with something that
>    listens on a unix domain socket).

or we can teach udev to listens on a unix domain socket.

The host udev listens netlink. When it gets an event about a new
device, it decides for which containers it must be avaliable, does all
required actions and sends events in containers. Probably the protocol
of notifications must be unified for all udev-like services.

>
> - It would be nice to replace the device cgroup with a comprehensive
>   solution that really works. (Among other things the device cgroup
>   does not work in terms of struct device the underlying kernel
>   abstraction for devices).
>
> We must manage sysfs entries as well device nodes because:
> - Seeing more than we should has the real potential to confuse
>   userspace, especially a userspace that replays uevents.
> - Some device control must happens through writing to sysfs files and
>   if we don't remove all root privileges from a container only by
>   exporting a subset of sysfs to that container can we limit which
>   sysfs nodes can be written to.

Sorry if a following idea will sound crazy. Can we use fuse
filesystems for filtering sysfs and devtmpfs? When a CT mounts sysfs,
it will mount fuse-sysfs, which is implemented by userspace program on
host system.

* This way allows to emulate the behavior of uevent files in
containers, if we will use unix sockets between udev services.
* Probably a userspace daemon will be more flexible and customizable
than something in kernel

Do we have a use case when a perfomance of sysfs is critical?

Thanks,
Andrey
