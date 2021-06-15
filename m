Received: from mout.kundenserver.de (mout.kundenserver.de [212.227.17.13])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8113A72
	for <containers@lists.linux.dev>; Tue, 15 Jun 2021 11:24:47 +0000 (UTC)
Received: from [192.168.1.155] ([95.115.9.120]) by mrelayeu.kundenserver.de
 (mreue106 [212.227.15.183]) with ESMTPSA (Nemesis) id
 1MxEYY-1l4SP348mu-00xa0B; Tue, 15 Jun 2021 13:24:26 +0200
Subject: Re: device namespaces
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christian Brauner <christian.brauner@ubuntu.com>,
 Hannes Reinecke <hare@suse.de>, gregkh@linuxfoundation.org,
 containers@lists.linux.dev, linux-kernel@vger.kernel.org
References: <YL9liW99Ytf6uBlu@kroah.com>
 <9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>
 <20210608142911.ievp2rpuquxjuyus@wittgenstein>
 <d956398e-7ee6-ba36-43cc-4cdcea34b5b9@suse.de> <877dj4ff9g.fsf@disp2133>
 <20210609063818.xnod4rzvti3ujkvn@wittgenstein>
 <b9ea9116-7120-b0a7-b739-dd8513e12c5e@suse.de>
 <20210609072108.ldhsxfnfql4pacqx@wittgenstein>
 <85a0d777-dea6-9574-8946-9fc8f912c1af@suse.de>
 <20210609080918.ma2klvxkjad4pjrn@wittgenstein> <87v96k1d65.fsf@disp2133>
 <c504a8c6-73f8-b45c-6d6b-6f5a1300ab3a@metux.net> <874ke0s60c.fsf@disp2133>
From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Message-ID: <2bee9206-ca4a-8456-fabf-9557db599545@metux.net>
Date: Tue, 15 Jun 2021 13:24:24 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.10.0
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <874ke0s60c.fsf@disp2133>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: tl
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:jCdrTdFTo3v1QFUiCmmyn5ZmBHRUiO4hgjDbjsiUDKcvFYQgVpG
 MzxaUBZTk15UO7N/emYKMKMYnFSY8RuOfJWfabJ6xepRixLqVedqJvVPF0Dv04u7oClqrWA
 Plzx5mjayWJIXPOZgNIoedYh9N45aM7Kzw+sIl7mRye8YLIHwHlJxLPCZkpH5LV1HpY0ftY
 DSjP/3NlGnzkmHosvNO7Q==
X-Spam-Flag: NO
X-UI-Out-Filterresults: notjunk:1;V03:K0:pxyFj5pv3CU=:saOJa9+d6IMozxJ/a2ZUm0
 LsWDty2f9E48uuSVi7iXXmA8Qq+6WpUrnI8MbYc4qOLf8Dm3gAJBzrgvEq4qSf5nbNxoPtfXc
 Hp9MOZxLyzR6FnmDwHiU65OrzZhoM9lplRMDyELPR9blkVMR8UuDg3nIwVxS3rxEhRlM0UmS2
 4aQqa5Ax86/XXjtss8CFqZfx37IwykKHiRp7XCDOBd1CWAD+QCNmFqYv9xZfJScVH3gpfmHcU
 W7713eWab8eJo91nQYTTUUF27cghK+rmqmXYBqi7sCsVa02mn0S7PcUfWpkzxilzgVJUPePL+
 Iu/dia1Nu2RQGvglwBYaIiSLzkFWh3a4nluSaCtyvv9nsZoDVjq8IOna+UAa4iY1UNzTMO9mk
 hWOtd1wKdpK6fhtTVfMgnPtBzDGcZxIGB5nzcGQ7fxQBazO6ZuO6EnYt+ldq+OjQrB7XgJqXs
 P2ovnrlWFlaoqh40aUeNGsQAMuQ0cqywxqI0uP5zB40hjkLE2d48i7BvPe1BxgXNhWNVQvbyI
 nbWn9VoEu0MMb56iae0niQ=

On 14.06.21 19:36, Eric W. Biederman wrote:

> By virtual devices I mean all devices that are not physical pieces
> of hardware.  For block devices I mean devices such as loopback
> devices that are created on demand.  Ramdisks that start this
> conversation could also be considered virtual devices.

Ok. Do you also count partitions in here ?

IMHO we've got another category to look up: devices that (can) create
more (sub)devices. Examples coming into my head are loopdev, ptmx,
partitions, etc.

The big problem here: fist we'd need to be clear on the actual
semantics in namespaced context, for example:

* what happens when you talk to /dev/loop0 and create a new loopdev
   inside a container - shall it be ever visible on the host ?

* what if you want to create an loopdev on some file thats only visible
   to the host, but that loopdev shall appear inside a container ?
   ("virtual disk" scenario)

>> How would you skip the virtual devices from sysfs ? Adding some filter
>> into sysfs that looks at the device class (or some flag within it) ?
> 
> I would just not run the code to create sysfs entries when the virtual
> devices are created.

Oh, that would most likely make userland unhappy.

Besides, that won't be so trivial due to the way sysfs works. Because
sysfs more or less just presents kobj's. Each kobj may have attributes,
a parent, and a list of childs. A device is n kobj, and it needs to
be registered into the device hierarchy to work at all. Sysfs itself
doesn't really know whether something is a virtual device (or a device
at all) - it just calls some functions from kobject_type for things like
reading/writing attributes, etc. But I don't see anything where
kobject_type's can implement their own iterators.

As things are right now, not registering a device in sysfs means not
registering it at all.

By the way: i'm just wondering whether it would make sense to give
kobject_type it's own iteration and lookup functions. Unless I'm fully
mistaken, that could help solving several other problems, e.g. device
renaming (currently *very* tricky and only works to some extend for
network devices).

IMHO, we could then eg. fetch the device names (/sys/devices/...)
directly from the struct device instead of the kset (perhaps a simple
list instead of kset would also do here), and also create the symlinks
(e.g. /sys/class/.../) on the fly. Once that's done, renaming a device
should become rather simple.

At that point, adding multiple views or certain parts of sysfs (e.g. the
devices hierarchy) could perhaps be done by implementing special
iterators take take the view criteria into account.

@Greg: what's your take on that iterator idea ?

> If you have virtual devices showing up in their own filesystem they
> don't even need major or minor numbers.  You can just have files
> that accept ioctls like device nodes.  In principle it is
> possible to skip a lot of the historical infrastructure.  If the
> infrastructure is not needed it is worth skipping.

Ah, I see where you're going. You wanna completely drop these virtual 
devices and replace them by a synthentic fs that *looks* like it
contains devices ? Well, theoretically it should be possible, since fs'
may handle opening device nodes completely own, instead of calling 
generic code (is there any that actually does ?).

BUT: in that case we have to really make sure that processes inside the
container cannot ever open any device node outside that special fs.

> I haven't dug into the block layer recently enough to say what is needed
> or not.  I think there are some thing such as stat on a mounted
> filesystem that need a major and minor numbers.  Which probably means
> you have to use major and minor numbers.  By virtue of using common
> infrastructure that implies showing up in sysfs and devtmpfs.  Things
> would be limited just by not mounting devtmpfs in a container.

Note that this approach also needs to support things like dynamically
creating new device nodes (inside the container), udev, ... otherwise
you'd need very special handling in userland again (lxc folks would
become very unhappy ;-))

> It is worth checking how much of the common infrastructure you need when
> you start creating virtual devices.

s/virtual devices/synthetic filesystems/;

You approach goes much into the Plan9 direction (which in generally I'd
love to see). But whatever we gonna do here needs to remain compatible
with what existing userland expects - we've got a lot of Unix tradition
to keep here.

OR: we had to declare that (once inside the devns) we throw it all alway
and it create something entirely new that's more like an Plan9 subsystem
than an Linux container. Also interesting, but not what i've started
this discussion for.

> The only reason the network devices need changes to sysfs is to allow
> different network devices with the same name to show up in different
> network namespaces.
> 
> If you can fundamentally avoid the problem of devices with the same
> name needing to show up in sysfs and devtmpfs by using filesystems
> then sysfs and devtmpfs needs no changes.

Well, that's only for the sysfs part. Network devices still need to
be namespaced in other places (socket, etc) - what's already done by
netns.

But yes, it sounds nice if we had entirely different namespaces for
network device names (e.g. any of the hosts network devices could
appear simply as "eth0" inside a container, if you want to)


--mtx

-- 
---
Hinweis: unverschlüsselte E-Mails können leicht abgehört und manipuliert
werden ! Für eine vertrauliche Kommunikation senden Sie bitte ihren
GPG/PGP-Schlüssel zu.
---
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
