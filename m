From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Controlling devices and device namespaces
Date: Sat, 15 Sep 2012 17:24:36 -0700
Message-ID: <87y5kazuez.fsf@xmission.com>
References: <20120913205827.GO7677@google.com>
	<20120914183641.GA2191@cathedrallabs.org>
	<20120915022037.GA6438@mail.hallyn.com>
	<87wqzv7i08.fsf_-_@xmission.com>
	<20120915220520.GA11364@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120915220520.GA11364-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Sat, 15 Sep 2012 22:05:20 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Aristeu Rozanski <aris-moeOTchvdi7YtjvyW6yDsg@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Thinking about this a bit more I think we have been asking the wrong
question.

I think the correct question should be: How do we safely allow for
unprivileged creation of device nodes and devices?

One piece of the puzzle is that we should be able to allow unprivileged
device node creation and access for any device on any filesystem
for which it unprivileged access is safe.

Something like the current device control group hooks but
with the whitelist implemented like:

static bool unpriv_mknod_ok(struct device *dev)
{
	char *tmp, *name;
	umode_t mode = 0;

	name = device_get_devnode(dev, &mode, &tmp);
	if (!name)
        	return false;
	kfree(tmp);
        return mode == 0666;
}

Are there current use cases where people actually want arbitrary
access to hardware devices?  I really want to say no and get
udev and sysfs out of the picture as much as possible.

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > Quoting Aristeu Rozanski (aris-moeOTchvdi7YtjvyW6yDsg@public.gmane.org):
>> >> Tejun,
>> >> On Thu, Sep 13, 2012 at 01:58:27PM -0700, Tejun Heo wrote:
>> >> >   memcg can be handled by memcg people and I can handle cgroup_freezer
>> >> >   and others with help from the authors.  The problematic one is
>> >> >   blkio.  If anyone is interested in working on blkio, please be my
>> >> >   guest.  Vivek?  Glauber?
>> >> 
>> >> if Serge is not planning to do it already, I can take a look in device_cgroup.
>> >
>> > That's fine with me, thanks.
>> >
>> >> also, heard about the desire of having a device namespace instead with
>> >> support for translation ("sda" -> "sdf"). If anyone see immediate use for
>> >> this please let me know.
>> >
>> > Before going down this road, I'd like to discuss this with at least you,
>> > me, and Eric Biederman (cc:d) as to how it relates to a device
>> > namespace.
>> 
>> 
>> The problem with devices.
>> 
>> - An unrestricted mknod gives you access to effectively any device in
>>   the system.
>> 
>> - During process migration if the device number changes using
>>   stat to file descriptors can fail on the same file descriptor.
>> 
>> - Devices coming from prexisting filesystems that we mount
>>   as unprivileged users are as dangerous as mknod but show
>>   that the problem is not limited to mknod.
>> 
>> - udev thinks mknod is a system call we can remove from the kernel.
>
> Also,
>
>  - udevadm trigger --action=add
>
> causes all the devices known on the host to be re-sent to
> everyone (all namespaces).  Which floods everyone and causes the
> host to reset some devices.

I think this is all userspace activity, and should be largely
fixed by not begin root in a container.

>> ---
>> 
>> The use cases seem comparitively simple to enumerate.
>> 
>> - Giving unfiltered access to a device to someone not root.
>> 
>> - Virtual devices that everyone uses and have no real privilege
>>   requirements: /dev/null /dev/tty /dev/zero etc.
>> 
>> - Dynamically created devices /dev/loopN /dev/tun /dev/macvtapN,
>>   nbd, iscsi, /dev/ptsN, etc
>
> and
>
>  - per-namespace uevent filtering.

One possible solution there is to just send the kernel uevents (except
for the network ones) into the initial network namespace.

>> ---
>> 
>> There are a couple of solution to these problems.
>> 
>> - The classic solution of creating a /dev for a container
>>   before starting it.
>> 
>> - The devpts filesystem.  This works well for unprivileged access
>>   to ptys.  Except for the /dev/ptmx sillines I very like how
>>   things are handled today with devpts.
>> 
>> - Device control groups.  I am not quite certain what to make
>>   of them.  The only case I see where they are better than
>>   a prebuilt static dev is if there is a hotppluged device
>>   that I want to push into my container.
>> 
>>   I think the only problem with device control groups and
>>   hierarchies is that removing a device from a whitelist
>>   does not recurse down the hierarchy.
>
> That's going to be fixed soon thanks to Aristeu  :)
>
>>   Can a process inside of a device control group create
>>   a child group that has access to a subset of it's
>>   devices?  The actually checks don't need to be hierarchical
>>   but the presence of device nodes should be.
>
> If I understand your question right, yes.

I should also have asked can we do this without any capabilities
and without our uid being 0?

>> ---
>> 
>> I see a couple of holes in the device control picture.
>> 
>> - How do we handle hotplug events?
>> 
>>   I think we can do this by relaying events trough userspace,
>>   upating the device control groups etc.
>> 
>> - Unprivileged processess interacting with all of this.
>>   (possibly with privilege in their user namespace)
>>   What I don't know how to do is how to create a couple of different
>>   subhierarchies each for different child processes.
>> 
>> - Dynamically created devices.
>> 
>>   My gut feel is that we should replicate the success of devpts
>>   and give each type of dynamically created device it's own
>>   filesystem and mount point under /dev, and just bend
>>   the handful of userspace users into that model.
>
> Phew.  Maybe.  Had not considered that.  But seems daunting.

I think the list of device types that we care about here is pretty
small.  Please correct me if I am wrong.

loop nbd iscsi macvtap

And if we want it to be safe to use these devices in a user namespace
without global root privileges we need to go through the code anyway.

So I think it is the gradual safe and sane approach assume we don't
run into something like the devpts /dev/ptmx silliness that stalled
devpts.

>> - Sysfs
>> 
>>   My gut says for the container use case we should aim to
>>   simply not have dynamically created devices in sysfs
>>   and then we can simply not care.

I guess what I keep thinking for sysfs is that it should be for real
hardware backed devices.  If we can get away with that like we do with
ptys it just makes everyone's life simpler.

Primarily sysfs and uevents are for allowing the system to take
automatic action when a new device is created.  Do we have an actual
need for hotplug support in containers?

>> - Migration
>> 
>>   Either we need block device numbers that can migrate with us,
>>   (possibly a subset of the entire range ala devpts) or we need to send
>>   hotplug events to userspace right after a migration so userspace
>>   processes that care can invalidate their caches of stat data.
>> 
>> ---
>> 
>> With the code in my userns development tree I can create a user
>> namespace, create a new mount namespace, and then if I have
>> access to any block devices mount filesystems, all without
>> needing to have any special privileges.  What I haven't
>> figured out is what it would take to get the the device
>> control group into the middle that.
>
> I'm really not sure that's a question we want to ask.  The
> device control group, like the ns cgroup, was meant as a
> temporary workaround to not having user and device namespaces.
>
> If we can come up with a device cgroup model that works to
> fill all the requirements we would have for a devices ns, then
> great.  But I don't want us to be constrained by that.
>
>> It feels like it should be possible to get the checks straight
>> and use the device control group hooks to control which devices
>> are usable in a user namespace.  Unfortunately when I try and work
>> it out the independence of the user namespace and the device
>> control group seem to make that impossible.
>> 
>> Shrug there is most definitely something missing from our
>> model on how to handle devices well.  I am hoping we can
>> sprinkling some devpts derived pixie dust at the problem
>> migrate userspace to some new interfaces and have life
>> be good.
>> 
>> Eric
>
> Me too!
>
> I'm torn between suggesting that we have a session at UDS to
> discuss this, and not wanting to so that we can focus on the
> remaining questions with the user namespace.

Eric
