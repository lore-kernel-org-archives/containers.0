Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AEFA370
	for <containers@lists.linux.dev>; Wed,  9 Jun 2021 06:38:23 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 3FB4B61185;
	Wed,  9 Jun 2021 06:38:21 +0000 (UTC)
Date: Wed, 9 Jun 2021 08:38:18 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Hannes Reinecke <hare@suse.de>, gregkh@linuxfoundation.org,
	containers@lists.linux.dev, linux-kernel@vger.kernel.org,
	lkml@metux.net
Subject: Re: device namespaces
Message-ID: <20210609063818.xnod4rzvti3ujkvn@wittgenstein>
References: <YL9liW99Ytf6uBlu@kroah.com>
 <9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>
 <20210608142911.ievp2rpuquxjuyus@wittgenstein>
 <d956398e-7ee6-ba36-43cc-4cdcea34b5b9@suse.de>
 <877dj4ff9g.fsf@disp2133>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <877dj4ff9g.fsf@disp2133>

On Tue, Jun 08, 2021 at 12:16:43PM -0500, Eric W. Biederman wrote:
> Hannes Reinecke <hare@suse.de> writes:
> 
> > On 6/8/21 4:29 PM, Christian Brauner wrote:
> >> On Tue, Jun 08, 2021 at 04:10:08PM +0200, Hannes Reinecke wrote:
> >>> On Tue, Jun 08, 2021 Greg-KH wrote:
> >>>> On Tue, Jun 08, 2021 at 02:30:50PM +0200, Christian Brauner wrote:
> >>>>> On Tue, Jun 08, 2021 at 11:38:16AM +0200, Enrico Weigelt,
> >>>>> metux IT consult wrote:
> >>>>>> Hello folks,
> >>>>>>
> >>>>>>
> >>>>>> I'm going to implement device namespaces, where containers can get
> >>>>>> an entirely different view of the devices in the machine (usually
> >>>>>> just a specific subset, but possibly additional virtual devices).
> >>>>>>
> >>> [ .. ]
> >>>>>> Is this a good way to go ? Or what would be a better one ?
> >>>>>
> >>>>> Ccing Greg. Without adressing specific problems, I should warn you
> >>>>> that this idea is not new and the plan is unlikely to go anywhere.
> >>>>> Especially not without support from Greg.
> >>>>
> >>>> Hah, yeah, this is a non-starter.
> >>>>
> >>>> Enrico, what real problem are you trying to solve by doing this?  And
> >>>> have you tried anything with this yet?  We almost never talk about
> >>>> "proposals" without seeing real code as it's pointless to discuss
> >>>> things when you haven't even proven that it can work.
> >>>>
> >>>> So let's see code before even talking about this...
> >>>>
> >>>> And as Christian points out, you can do this today without any kernel
> >>>> changes, so to think you need to modify the kernel means that you
> >>>> haven't even tried this at all?
> >>>>
> >>> Curious, I had been looking into this, too.
> >>> And I have to side with Greg and Christian that your proposal should
> >>> already be possible today (cf device groups, which curiously has a
> >>> near-identical interface to what you proposed).
> >>> Also, I think that a generic 'device namespace' is too broad a scope;
> >>> some subsystems like net already inherited namespace support, and it
> >>> turns out to be not exactly trivial to implement.
> >>>
> >>> What I'm looking at, though, is to implement 'block' namespaces, to
> >>> restrict access to _new_ block devices to any give namespace.
> >>> Case in point: if a container creates a ramdisk it's questionable
> >>> whether other containers should even see it. iSCSI devices are a similar
> >>> case; when starting iSCSI devices from containers their use should be
> >>> restricted to that container.
> >>> And that's not only the device node in /dev, but would also entail sysfs
> >>> access, which from my understanding is not modified with the current code.
> >> 
> >> Hey Hannes. :)
> >> 
> >> It isn't and we likely shouldn't. You'd likely need to get into the
> >> business of namespacing devtmpfs one way or the other which Seth Forshee
> >> and I once did. But that's really not needed anymore imho. Device
> >> management, i.e. creating device nodes should be the job of a container
> >> manager. We already do that for example (Hotplugging devices ranging
> >> from net devices, to disks, to GPUs.) and it works great.
> >> 
> > Right; clearly you can do that within the container.
> > But my main grudge here is not the container but rather the system
> > _hosting_ the container.
> > That is typically using devtmpfs and hence will see _all_ devices, even
> > those belonging to the container.
> > This is causing grief to no end if eg the host system starts activating
> > LVM on devices which are passed to the qemu instance running within a
> > container ...
> >
> >> To make this really clean you will likely have to significantly rework
> >> sysfs too and I don't think that churn is worth it and introduces a
> >> layer of complexity I find outright nakable. And ignoring sysfs or
> >> hacking around it is also not an option I find tasteful.
> >> 
> > Network namespaces already have the bits and pieces to modify sysfs, so
> > we should be able to leverage that for block, too.
> > And I think by restricting it to 'block' devices we should be to keep
> > the required sysfs modifications in a manageable level.
> >
> >>>
> >>> uevent redirection would help here, but from what I've seen it's only
> >>> for net devices; feels a bit awkward to have a network namespace to get
> >>> uevents for block devices, but then I'll have to test.
> >> 
> >> Just to move everyone on the same page. This is not specific to network
> >> devices actually.
> >> 
> >> You are right though that network devices are correctly namespaced.
> >> Specifically you only get uevents in the network namespace that network
> >> device is moved into. The sysfs permissions for network devices were
> >> correct if you created that network device in the network namespace but
> >> they were wrong when you moved a network device between network
> >> namespaces (with different owning user namespaces). That lead to all
> >> kinds of weird issues. I fixed that a while back.
> >> 
> > Granted, modifying sysfs layout is not something for the faint-hearted,
> > and one really has to look closely to ensure you end up with a
> > consistent layout afterwards.
> >
> > But let's see how things go; might well be that it turns out to be too
> > complex to consider. Can't tell yet.
> 
> I would suggest aiming for something like devptsfs without the
> complication of /dev/ptmx.
> 
> That is a pseudo filesystem that has a control node and virtual block
> devices that were created using that control node.

Also see android/binder/binderfs.c

> 
> That is the cleanest solution I know and is not strictly limited to use
> with containers so it can also gain greater traction.  The interaction
> with devtmpfs should be simply having devtmpfs create a mount point for
> that filesystem.
> 
> This could be a new cleaner api for things like loopback devices.

I sent a patchset that implemented this last year.
