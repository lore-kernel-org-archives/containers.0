From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Device Namespaces
Date: Wed, 25 Sep 2013 14:34:54 -0700
Message-ID: <87bo3gshz5.fsf_-_@xmission.com>
References: <CAA4jN2aw4zEW=UfKCyqaOvXnbiRb_J9srfCn4OXTFzc6vWBM4A@mail.gmail.com>
	<20130822182118.GA28331@sergelap>
	<CAA4jN2YL7Lfu2+DW-i+MovFxWEhJfT4aBBKREU_vy7JX9TKGHA@mail.gmail.com>
	<8761udlu0d.fsf@xmission.com>
	<CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
	<871u4yddg4.fsf@xmission.com>
	<CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
	<CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Janne Karhunen's message of "Wed, 25 Sep 2013 14:05:32 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From conversations at Linux Plumbers Converence it became fairly clear
that one if not the roughest edge on containers today is dealing with
devices.

- Hotplug does not work.
- There seems to be no implementation that does a much beyond creating
  setting up a static set of /dev entries today.
- Containers do not see the appropriate uevents for their container.

One of the more compelling cases I heard was of someone who was running
the a Linux Desktop in container and wanted to just let that container
see the devices needed for his desktop, and not everything else.

Talking with the OpenVZ folks it appears that preserving device numbers
across checkpoint/restart is not currently an issue.  However they reuse
the same loopback minor number when they can which would hide this
issue.   So while it is clear we don't need to worry about migrating
an application that cares about major/minor numbers of filesystems right
now as the set of application that are migrated increases that situation
may change.  As the case with the network device ifindex has shown it is
possible to implement filtering now and later when there is a usecase it
is possible to expand filtering to actual namespace local identifiers.

Thinking about it for the case of container migration the simplest
solution for the rare application that needs something more may be to
figure out how to send a kernel hotplug event.  Something to think about
when we encounter them.

So the big issues for a device namespace to solve are filtering which
devices a container has access to and being able to dynamically change
which devices those are at run time (aka hotplug).

After having thought about this for a bit I don't know if a pure
userspace solution is sufficient or actually a good idea.

- We can manually manage a tmpfs with device nodes in userspace.
  (But that is deprecated functionality in the mainstream kernel).
- We can manually export a subset of sysfs with bind mounts.
  (But that feels hacky, and is essentially incompatible with hotplug).
- We can relay a call of /sbin/hotplug from outside of a container
  to inside of a container based on policy.
  (But no one uses /sbin/hotplug anymore).
- There is no way to fake netlink uevents for a container to see them.
  (The best we could do is replace udev everywhere with something that
   listens on a unix domain socket).
- It would be nice to replace the device cgroup with a comprehensive
  solution that really works. (Among other things the device cgroup
  does not work in terms of struct device the underlying kernel
  abstraction for devices).

We must manage sysfs entries as well device nodes because:
- Seeing more than we should has the real potential to confuse
  userspace, especially a userspace that replays uevents.
- Some device control must happens through writing to sysfs files and
  if we don't remove all root privileges from a container only by
  exporting a subset of sysfs to that container can we limit which
  sysfs nodes can be written to.

The current kernel tagged sysfs entry support does not look like a good
match for the impelementing device filtering.   The common case will
be allowing devices like /dev/zero, and /dev/null that live in
/sys/devices/virtual and are the devices we are most likely to care
about.  Those devices need to live in multiple device namespaces so
everyone can use them.  Perhaps exclusive assignment will be the more
common paradigm for device namespaces like it is for network devices in
the network namespace but from what little I can of this problem right now I
don't think so.

I definitely think we should hold off on a kernel level implementation
until we really understand the issues and are ready to implement device
namespaces correctly.

A userspace implementation looks like it can only do about 95% of what
is really needed, but at the same time looks like an easy way to
experiment until the problem is sufficiently well understood.

At the end of the day we need to filter the devices a set of userspace
processes can use and be able to change that set of devices dynamically.
All of the rest of the infrastructure for that lives in the kernel, and
keeping all of the infrastructure in one place where it can be
maintained together is likely to be most maintainable.  It looks like
the code is just complicated enough and the use cases just boring enough
that spreading the code to perform container device hotplug and
container device filtering between a dozen userspace tools, and a hadful
of userspace device managers will not be particularly managable at the
end of the day.

In summary the situation with device hoptlug and containers sucks today,
and we need to do something.  Running a linux desktop in a container is
a reasonably good example use case.  Having one standard common
maintainable implementation would be very useful and the most logical
place for that would be in the kernel.  For now we should focus on
simple device filtering and hotplug.

Eric
