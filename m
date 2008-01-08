From: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Tue, 08 Jan 2008 23:42:20 +0100
Message-ID: <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080108214625.GE5050@ucw.cz>
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <20080108214625.GE5050-+ZI9xUNit7I@public.gmane.org> (message from Pavel Machek on Tue,
	8 Jan 2008 21:46:26 +0000)
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pavel-+ZI9xUNit7I@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> On Tue 2008-01-08 12:35:09, Miklos Szeredi wrote:
> > From: Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>
> > 
> > Use FS_SAFE for "fuse" fs type, but not for "fuseblk".
> > 
> > FUSE was designed from the beginning to be safe for unprivileged users.  This
> > has also been verified in practice over many years.  In addition unprivileged
> 
> Eh? So 'kill -9 no longer works' and 'suspend no longer works' is not
> considered important enough to even mention?

No.  Because in practice they don't seem to matter.  Also because
there's no way in which fuse could be done differently to address
these issues.

The 'kill -9' thing is basically due to VFS level locking not being
interruptible.  It could be changed, but I'm not sure it's worth it.

For the suspend issue, there are also no easy solutions.

> 'updatedb no longer works' is not a problem?

I haven't seen any problems with updatedb, and haven't had any bug
reports about it either.

> Are you ready to offer shell account for bugtraq people to see how
> long it survives?

Bugtraq people are free to install fuse on their machines and take it
apart.

AFAIR there were two security vulnerabilities in fuse's history, one
of them an information leak in the kernel module, and the other one an
mtab corruption issue in the fusermount utility.  I don't think this
is such a bad track record.

Miklos
