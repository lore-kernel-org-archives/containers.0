From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 8/9] unprivileged mounts: propagation: inherit owner
	from parent
Date: Tue, 15 Jan 2008 15:37:37 +0100
Message-ID: <E1JEmv3-0001RN-6J@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113632.895453887@szeredi.hu> <20080114231340.GG6704@sergelap.austin.ibm.com> <E1JEjCG-0000wz-BS@pomaz-ex.szeredi.hu> <20080115142115.GC4453@sergelap.austin.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <20080115142115.GC4453@sergelap.austin.ibm.com>
	(serue@us.ibm.com)
Sender: linux-fsdevel-owner@vger.kernel.org
Cc: miklos@szeredi.hu, serue@us.ibm.com, akpm@linux-foundation.org, hch@infradead.org, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

> > > > On mount propagation, let the owner of the clone be inherited from the
> > > > parent into which it has been propagated.  Also if the parent has the
> > > > "nosuid" flag, set this flag for the child as well.
> > > 
> > > What about nodev?
> > 
> > Hmm, I think the nosuid thing is meant to prevent suid mounts being
> > introduced into a "suidless" namespace.  This doesn't apply to dev
> > mounts, which are quite safe in a suidless environment, as long as the
> > user is not able to create devices.  But that should be taken care of
> > by capability tests.
> > 
> > I'll update the description.
> 
> Hmm,
> 
> Part of me wants to say the safest thing for now would be to refuse
> mounts propagation from non-user mounts to user mounts.
> 
> I assume you're thinking about a fully user-mounted chroot, where
> the user woudl still want to be able to stick in a cdrom and have
> it automounted under /mnt/cdrom, propagated from the root mounts ns?

Right.

> But then are there no devices which the user could create on a floppy
> while inserted into his own laptop, owned by his own uid, then insert
> into this machine, and use the device under the auto-mounted /dev/floppy
> to gain inappropriate access?

I assume, that the floppy and cdrom are already mounted with
nosuid,nodev.

The problem case is I think is if a sysadmin does some mounting in the
initial namespace, and this is propagated into the fully user-mounted
namespace (or chroot), so that a mount with suid binaries slips in.
Which is bad, because the user may be able rearange the namespace, to
trick the suid program to something it should not do.

OTOH, a mount with devices can't be abused this way, since it is not
possible to gain privileges to files/devices just by rearanging the
mounts.

Miklos
