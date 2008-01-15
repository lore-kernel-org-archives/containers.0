From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 8/9] unprivileged mounts: propagation: inherit owner
	from parent
Date: Tue, 15 Jan 2008 08:21:15 -0600
Message-ID: <20080115142115.GC4453@sergelap.austin.ibm.com>
References: <20080108113502.184459371@szeredi.hu> <20080108113632.895453887@szeredi.hu> <20080114231340.GG6704@sergelap.austin.ibm.com> <E1JEjCG-0000wz-BS@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <E1JEjCG-0000wz-BS-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Miklos Szeredi (miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org):
> > Quoting Miklos Szeredi (miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org):
> > > From: Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>
> > > 
> > > On mount propagation, let the owner of the clone be inherited from the
> > > parent into which it has been propagated.  Also if the parent has the
> > > "nosuid" flag, set this flag for the child as well.
> > 
> > What about nodev?
> 
> Hmm, I think the nosuid thing is meant to prevent suid mounts being
> introduced into a "suidless" namespace.  This doesn't apply to dev
> mounts, which are quite safe in a suidless environment, as long as the
> user is not able to create devices.  But that should be taken care of
> by capability tests.
> 
> I'll update the description.

Hmm,

Part of me wants to say the safest thing for now would be to refuse
mounts propagation from non-user mounts to user mounts.

I assume you're thinking about a fully user-mounted chroot, where
the user woudl still want to be able to stick in a cdrom and have
it automounted under /mnt/cdrom, propagated from the root mounts ns?

But then are there no devices which the user could create on a floppy
while inserted into his own laptop, owned by his own uid, then insert
into this machine, and use the device under the auto-mounted /dev/floppy
to gain inappropriate access?

-serge
