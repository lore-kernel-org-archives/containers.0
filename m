Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 649F629CA
	for <containers@lists.linux.dev>; Tue,  8 Jun 2021 14:29:17 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 17552610C7;
	Tue,  8 Jun 2021 14:29:14 +0000 (UTC)
Date: Tue, 8 Jun 2021 16:29:11 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Hannes Reinecke <hare@suse.de>
Cc: gregkh@linuxfoundation.org, containers@lists.linux.dev,
	linux-kernel@vger.kernel.org, lkml@metux.net
Subject: Re: device namespaces
Message-ID: <20210608142911.ievp2rpuquxjuyus@wittgenstein>
References: <YL9liW99Ytf6uBlu@kroah.com>
 <9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>

On Tue, Jun 08, 2021 at 04:10:08PM +0200, Hannes Reinecke wrote:
> On Tue, Jun 08, 2021 Greg-KH wrote:
> > On Tue, Jun 08, 2021 at 02:30:50PM +0200, Christian Brauner wrote:
> >> On Tue, Jun 08, 2021 at 11:38:16AM +0200, Enrico Weigelt,
> >> metux IT consult wrote:
> >>> Hello folks,
> >>>
> >>>
> >>> I'm going to implement device namespaces, where containers can get
> >>> an entirely different view of the devices in the machine (usually
> >>> just a specific subset, but possibly additional virtual devices).
> >>>
> [ .. ]
> >>> Is this a good way to go ? Or what would be a better one ?
> >>
> >> Ccing Greg. Without adressing specific problems, I should warn you
> >> that this idea is not new and the plan is unlikely to go anywhere.
> >> Especially not without support from Greg.
> >
> > Hah, yeah, this is a non-starter.
> >
> > Enrico, what real problem are you trying to solve by doing this?  And
> > have you tried anything with this yet?  We almost never talk about
> > "proposals" without seeing real code as it's pointless to discuss
> > things when you haven't even proven that it can work.
> >
> > So let's see code before even talking about this...
> >
> > And as Christian points out, you can do this today without any kernel
> > changes, so to think you need to modify the kernel means that you
> > haven't even tried this at all?
> >
> Curious, I had been looking into this, too.
> And I have to side with Greg and Christian that your proposal should
> already be possible today (cf device groups, which curiously has a
> near-identical interface to what you proposed).
> Also, I think that a generic 'device namespace' is too broad a scope;
> some subsystems like net already inherited namespace support, and it
> turns out to be not exactly trivial to implement.
> 
> What I'm looking at, though, is to implement 'block' namespaces, to
> restrict access to _new_ block devices to any give namespace.
> Case in point: if a container creates a ramdisk it's questionable
> whether other containers should even see it. iSCSI devices are a similar
> case; when starting iSCSI devices from containers their use should be
> restricted to that container.
> And that's not only the device node in /dev, but would also entail sysfs
> access, which from my understanding is not modified with the current code.

Hey Hannes. :)

It isn't and we likely shouldn't. You'd likely need to get into the
business of namespacing devtmpfs one way or the other which Seth Forshee
and I once did. But that's really not needed anymore imho. Device
management, i.e. creating device nodes should be the job of a container
manager. We already do that for example (Hotplugging devices ranging
from net devices, to disks, to GPUs.) and it works great.

To make this really clean you will likely have to significanly rework
sysfs too and I don't think that churn is worth it and introduces a
layer of complexity I find outright nakable. And ignoring sysfs or
hacking around it is also not an option I find tasteful.

> 
> uevent redirection would help here, but from what I've seen it's only
> for net devices; feels a bit awkward to have a network namespace to get
> uevents for block devices, but then I'll have to test.

Just to move everyone on the same page. This is not specific to network
devices actually.

You are right though that network devices are correctly namespaced.
Specifically you only get uevents in the network namespace that network
device is moved into. The sysfs permissions for network devices were
correct if you created that network device in the network namespace but
they were wrong when you moved a network device between network
namespaces (with different owning user namespaces). That lead to all
kinds of weird issues. I fixed that a while back.

Uevent messages (and therefore injection of uevents) are not tied to
network devices. They are tied to network namespaces simply because the
transport layer is Netlink but that's about it.
