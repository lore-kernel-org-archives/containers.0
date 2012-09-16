From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Controlling devices and device namespaces
Date: Sun, 16 Sep 2012 11:15:38 -0500
Message-ID: <5055FB2A.1020103@hallyn.com>
References: <20120913205827.GO7677@google.com>
	<20120914183641.GA2191@cathedrallabs.org>
	<20120915022037.GA6438@mail.hallyn.com>
	<87wqzv7i08.fsf_-_@xmission.com>
	<20120915220520.GA11364@mail.hallyn.com>
	<87y5kazuez.fsf@xmission.com>
	<20120916122112.3f16178d@pyramind.ukuu.org.uk>
	<87sjaiuqp5.fsf@xmission.com> <87d31mupp3.fsf@xmission.com>
	<5055D4D1.3070407@hallyn.com> <87k3vuqc5l.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k3vuqc5l.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Aristeu Rozanski <aris-moeOTchvdi7YtjvyW6yDsg@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/16/2012 09:23 AM, Eric W. Biederman wrote:
> Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
>
>> On 09/16/2012 07:17 AM, Eric W. Biederman wrote:
>>> ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:
>>>
>>>> Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org> writes:
>>>>
>>>>>> One piece of the puzzle is that we should be able to allow unprivileged
>>>>>> device node creation and access for any device on any filesystem
>>>>>> for which it unprivileged access is safe.
>>>>>
>>>>> Which devices are "safe" is policy for all interesting and useful cases,
>>>>> as are file permissions, security tags, chroot considerations and the
>>>>> like.
>>>>>
>>>>> It's a complete non starter.
>>>
>>> Come to think of it mknod is completely unnecessary.
>>>
>>> Without mknod.  Without being able to mount filesystems containing
>>> device nodes.
>>
>> Hm?  That sounds like it will really upset init/udev/upgrades in the
>> container.
>
> udev does not create device nodes.  For an older udev the worst
> I can see it doing is having mknod failing with EEXIST because
> the device node already exists.
>
> We should be able to make it look to init like a ramdisk mounted the
> filesystems.
>
> Why should upgrades care?  Package installation shouldn't be calling
> mknod.
>
> At least with a recent modern distro I can't imagine this to be an
> issue.  I expect we could have a kernel build option that removed the
> mknod system call and a modern distro wouldn't notice.
>
>> Are you saying all filesystems containing device nodes will need to be
>> mounted in advance by the process setting up the container?
>
> As a general rule.
>
> I think in practice there is wiggle room for special cases
> like mounting a fresh devpts.  devpts at least in always create a new
> instance on mount mode seems safe, as it can not give you access to
> any existing devices.
>
> You can also do a lot of what would normally be done with mknod
> with bind mounts to the original devices location.
>
>>> The mount namespace is sufficient to prevent all of the
>>> cases that the device control group prevents (open and mknod on device
>>> nodes).
>>>
>>> So I honestly think the device control group is superflous, and it is
>>> probably wise to deprecate it and move to a model where it does not
>>> exist.
>>>
>>> Eric
>>>
>>
>> That's what I said a few emails ago :)  The device cgroup was meant as
>> a short-term workaround for lack of user (and device) namespaces.
>
> I am saying something stronger.  The device cgroup doesn't seem to have
> a practical function now.

"Now" is wrong.  The user namespace is not complete and not yet usable 
for a full system container.  We still need the device control group.

I'd like us to have a sprint (either a day at UDS in person, or a few 
days with a virtual sprint) with the focus of getting a full system 
container working the way you envision it, as cleanly as possible.  I 
can take two or three consecutave days sometime in the next 2-3 weeks, 
we can sit on irc and share a few instances on which to experiment?

>  That for the general case we don't need any
> kernel support.  That all of this should be a matter of some user space
> glue code, and just the tiniest bit of sorting out how hotplug events are
> sent.
>
> The only thing I can think we would need a device namespace for is
> for migration.
 >
> For migration with direct access to real hardware devices we must treat
> it as hardware hotunplug.  There is nothing else we can do.
>
> If there is any other case where we need to preserve device numbers
> etc we have the example of devpts.
>
> So at this point I really don't think we need a device namespace or a
> device control group.  (Just emulate devtmpfs, sysfs and uevents).
>
> Eric
>
