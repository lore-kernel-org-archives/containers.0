From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Controlling devices and device namespaces
Date: Sun, 16 Sep 2012 03:31:08 +0000
Message-ID: <20120916033108.GA13073@mail.hallyn.com>
References: <20120913205827.GO7677@google.com>
	<20120914183641.GA2191@cathedrallabs.org>
	<20120915022037.GA6438@mail.hallyn.com>
	<87wqzv7i08.fsf_-_@xmission.com>
	<20120915220520.GA11364@mail.hallyn.com>
	<87y5kazuez.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87y5kazuez.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Aristeu Rozanski <aris-moeOTchvdi7YtjvyW6yDsg@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 
> Thinking about this a bit more I think we have been asking the wrong
> question.
> 
> I think the correct question should be: How do we safely allow for
> unprivileged creation of device nodes and devices?
> 
> One piece of the puzzle is that we should be able to allow unprivileged
> device node creation and access for any device on any filesystem
> for which it unprivileged access is safe.
> 
> Something like the current device control group hooks but
> with the whitelist implemented like:
> 
> static bool unpriv_mknod_ok(struct device *dev)
> {
> 	char *tmp, *name;
> 	umode_t mode = 0;
> 
> 	name = device_get_devnode(dev, &mode, &tmp);
> 	if (!name)
>         	return false;
> 	kfree(tmp);
>         return mode == 0666;
> }
> 
> Are there current use cases where people actually want arbitrary
> access to hardware devices?  I really want to say no and get
> udev and sysfs out of the picture as much as possible.

Other devices I'm pretty sure people will be asking for include audio
and video devices, input devices, usb drives, LVM volumes and probably
volume groups and PVs as well.  I do believe people want to dedicate
drives to containers.

Of course there is also /dev/random, and /dev/kmsg which I think
needs to be tied to the also sorely missing syslog namespace.

> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> >> 
> >> > Quoting Aristeu Rozanski (aris-moeOTchvdi7YtjvyW6yDsg@public.gmane.org):
> >> >> Tejun,
> >> >> On Thu, Sep 13, 2012 at 01:58:27PM -0700, Tejun Heo wrote:
> >> >> >   memcg can be handled by memcg people and I can handle cgroup_freezer
> >> >> >   and others with help from the authors.  The problematic one is
> >> >> >   blkio.  If anyone is interested in working on blkio, please be my
> >> >> >   guest.  Vivek?  Glauber?
> >> >> 
> >> >> if Serge is not planning to do it already, I can take a look in device_cgroup.
> >> >
> >> > That's fine with me, thanks.
> >> >
> >> >> also, heard about the desire of having a device namespace instead with
> >> >> support for translation ("sda" -> "sdf"). If anyone see immediate use for
> >> >> this please let me know.
> >> >
> >> > Before going down this road, I'd like to discuss this with at least you,
> >> > me, and Eric Biederman (cc:d) as to how it relates to a device
> >> > namespace.
> >> 
> >> 
> >> The problem with devices.
> >> 
> >> - An unrestricted mknod gives you access to effectively any device in
> >>   the system.
> >> 
> >> - During process migration if the device number changes using
> >>   stat to file descriptors can fail on the same file descriptor.
> >> 
> >> - Devices coming from prexisting filesystems that we mount
> >>   as unprivileged users are as dangerous as mknod but show
> >>   that the problem is not limited to mknod.
> >> 
> >> - udev thinks mknod is a system call we can remove from the kernel.
> >
> > Also,
> >
> >  - udevadm trigger --action=add
> >
> > causes all the devices known on the host to be re-sent to
> > everyone (all namespaces).  Which floods everyone and causes the
> > host to reset some devices.
> 
> I think this is all userspace activity,

Well the uevents are sent from the kernel, and cause a flurry
of userspace activity.  (But not sending uevents to the containers
as you suggest below would work)

> and should be largely
> fixed by not begin root in a container.

That doesn't fit with our goal, which is to run the same, unmodified
userspace on hardware, virtualization (kvm/vmware), and containers.
This is important - the more we have to have different init and userspace
in containers (there are a few things we have to special-case still
at the moment) the more duplicated testing and otherwise avoidable
bugs we'll have.

Or did you just mean not being GLOBAL_ROOT_UID in a container?

> >> The use cases seem comparitively simple to enumerate.
> >> 
> >> - Giving unfiltered access to a device to someone not root.
> >> 
> >> - Virtual devices that everyone uses and have no real privilege
> >>   requirements: /dev/null /dev/tty /dev/zero etc.
> >> 
> >> - Dynamically created devices /dev/loopN /dev/tun /dev/macvtapN,
> >>   nbd, iscsi, /dev/ptsN, etc
> >
> > and
> >
> >  - per-namespace uevent filtering.
> 
> One possible solution there is to just send the kernel uevents (except
> for the network ones) into the initial network namespace.

We'd also want storage (especially usb but not just) passed in,
and audio, video and input - but maybe those should be faked from
userspace from the host (or parent container)?

Also, there *are* containers which are not in private network
namespaces.  Now I'm not sure how much we worry about those,
as they generally need custom init anyway (so as not to reconfigure
the host's networking etc).

> >> There are a couple of solution to these problems.
> >> 
> >> - The classic solution of creating a /dev for a container
> >>   before starting it.
> >> 
> >> - The devpts filesystem.  This works well for unprivileged access
> >>   to ptys.  Except for the /dev/ptmx sillines I very like how
> >>   things are handled today with devpts.
> >> 
> >> - Device control groups.  I am not quite certain what to make
> >>   of them.  The only case I see where they are better than
> >>   a prebuilt static dev is if there is a hotppluged device
> >>   that I want to push into my container.
> >> 
> >>   I think the only problem with device control groups and
> >>   hierarchies is that removing a device from a whitelist
> >>   does not recurse down the hierarchy.
> >
> > That's going to be fixed soon thanks to Aristeu  :)
> >
> >>   Can a process inside of a device control group create
> >>   a child group that has access to a subset of it's
> >>   devices?  The actually checks don't need to be hierarchical
> >>   but the presence of device nodes should be.
> >
> > If I understand your question right, yes.
> 
> I should also have asked can we do this without any capabilities
> and without our uid being 0?

Currently you need CAP_SYS_ADMIN to update device cgroup permissions.

> >> I see a couple of holes in the device control picture.
> >> 
> >> - How do we handle hotplug events?
> >> 
> >>   I think we can do this by relaying events trough userspace,
> >>   upating the device control groups etc.
> >> 
> >> - Unprivileged processess interacting with all of this.
> >>   (possibly with privilege in their user namespace)
> >>   What I don't know how to do is how to create a couple of different
> >>   subhierarchies each for different child processes.
> >> 
> >> - Dynamically created devices.
> >> 
> >>   My gut feel is that we should replicate the success of devpts
> >>   and give each type of dynamically created device it's own
> >>   filesystem and mount point under /dev, and just bend
> >>   the handful of userspace users into that model.
> >
> > Phew.  Maybe.  Had not considered that.  But seems daunting.
> 
> I think the list of device types that we care about here is pretty
> small.  Please correct me if I am wrong.
> 
> loop nbd iscsi macvtap

I assume you're asking only about devices that need virtualized
instances, with the instances either unique or mapped between
namespaces.  (and I assume the hope is that we can get away with them
being unique, as with devpts, and mappable with bind mounts)  I can't
think of any others offhand.

Common devices used in containers include tty*, rtc, fuse, tun, hpet,
kvm.  /dev/tty and /dev/console are special anyway.  The tty*  in
containers are always bind mounted with devpts.  So I don't think any
of those fit the criteria - no work needed.

> And if we want it to be safe to use these devices in a user namespace
> without global root privileges we need to go through the code anyway.

Agreed.

> So I think it is the gradual safe and sane approach assume we don't
> run into something like the devpts /dev/ptmx silliness that stalled
> devpts.

Agreed.

> >> - Sysfs
> >> 
> >>   My gut says for the container use case we should aim to
> >>   simply not have dynamically created devices in sysfs
> >>   and then we can simply not care.
> 
> I guess what I keep thinking for sysfs is that it should be for real
> hardware backed devices.  If we can get away with that like we do with
> ptys it just makes everyone's life simpler.

You've brought up /sys and /proc, does devtmpfs further complicate
things?

> Primarily sysfs and uevents are for allowing the system to take
> automatic action when a new device is created.  Do we have an actual
> need for hotplug support in containers?

As I argue above, I claim we need them for the event-drive init
systems to see NICs and other devices brought up, and to handle
passing in usb devices etc.

-serge
