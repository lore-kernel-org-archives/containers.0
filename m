From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: Device Namespaces
Date: Wed, 25 Sep 2013 22:33:20 -0700
Message-ID: <20130926053320.GB3725@kroah.com>
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
Content-Disposition: inline
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Sep 25, 2013 at 02:34:54PM -0700, Eric W. Biederman wrote:
> So the big issues for a device namespace to solve are filtering which
> devices a container has access to and being able to dynamically change
> which devices those are at run time (aka hotplug).

As _all_ devices are hotpluggable now (look, there's no CONFIG_HOTPLUG
anymore, because it was redundant), I think you need to really think
this through better (pci, memory, cpus, etc.) before you do anything in
the kernel.

> After having thought about this for a bit I don't know if a pure
> userspace solution is sufficient or actually a good idea.
> 
> - We can manually manage a tmpfs with device nodes in userspace.
>   (But that is deprecated functionality in the mainstream kernel).

Yes, but I'm not going to namespace devtmpfs, as that is going to be an
impossible task, right?

And remember, udev doesn't create device nodes anymore...

> - We can manually export a subset of sysfs with bind mounts.
>   (But that feels hacky, and is essentially incompatible with hotplug).

True.

> - We can relay a call of /sbin/hotplug from outside of a container
>   to inside of a container based on policy.
>   (But no one uses /sbin/hotplug anymore).

That's right, they should be listening to libudev events, so why can't
your daemon shuffle them off to the proper container, all in userspace?

> - There is no way to fake netlink uevents for a container to see them.
>   (The best we could do is replace udev everywhere with something that
>    listens on a unix domain socket).

You shouldn't need to do this.

> - It would be nice to replace the device cgroup with a comprehensive
>   solution that really works. (Among other things the device cgroup
>   does not work in terms of struct device the underlying kernel
>   abstraction for devices).

I didn't even know there was a device cgroup.

Which means that if there is one, odds are it's useless.

> We must manage sysfs entries as well device nodes because:
> - Seeing more than we should has the real potential to confuse
>   userspace, especially a userspace that replays uevents.

You should never replay uevents.  If you don't do that, why can't you
see all of sysfs?

> - Some device control must happens through writing to sysfs files and
>   if we don't remove all root privileges from a container only by
>   exporting a subset of sysfs to that container can we limit which
>   sysfs nodes can be written to.

But you have the issue of controlling devices in a "shared" way, which
isn't going to be usable for almost all devices.

> The current kernel tagged sysfs entry support does not look like a good
> match for the impelementing device filtering.   The common case will
> be allowing devices like /dev/zero, and /dev/null that live in
> /sys/devices/virtual and are the devices we are most likely to care
> about.  Those devices need to live in multiple device namespaces so
> everyone can use them.  Perhaps exclusive assignment will be the more
> common paradigm for device namespaces like it is for network devices in
> the network namespace but from what little I can of this problem right now I
> don't think so.
> 
> I definitely think we should hold off on a kernel level implementation
> until we really understand the issues and are ready to implement device
> namespaces correctly.

I agree, especially as I don't think this will ever work.

> A userspace implementation looks like it can only do about 95% of what
> is really needed, but at the same time looks like an easy way to
> experiment until the problem is sufficiently well understood.

95% is probably way better than what you have today, and will fit the
needs of almost everyone today, so why not do it?

I'd argue that those last 5% either are custom solutions that never get
merged, or candidates for true virtulization.

> In summary the situation with device hoptlug and containers sucks today,
> and we need to do something.  Running a linux desktop in a container is
> a reasonably good example use case.

No it isn't.  I'd argue that this is a horrible use case, one that you
shouldn't do.  Why not just use multi-head machines like people do who
really want to do this, relying on user separation?  That's a workable
solution that is quite common and works very well today.

> Having one standard common maintainable implementation would be very
> useful and the most logical place for that would be in the kernel.
> For now we should focus on simple device filtering and hotplug.

Just listen for libudev stuff, don't try to filter them, or ever
"replay" them, that way lies madness, and lots of nasty race conditions
that is guaranteed to break things.

good luck,

greg k-h
