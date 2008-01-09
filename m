From: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Wed, 09 Jan 2008 09:47:31 +0100
Message-ID: <E1JCWax-0005Ck-Kg@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080108214625.GE5050@ucw.cz> <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu> <47840DAC.5000108@nigel.suspend2.net>
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <47840DAC.5000108-MhVfhJ0qHmuWn91e4EydUaxOck334EZe@public.gmane.org> (message from Nigel
	Cunningham on Wed, 09 Jan 2008 10:56:28 +1100)
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: nigel-MhVfhJ0qHmuWn91e4EydUaxOck334EZe@public.gmane.org
Cc: pavel-+ZI9xUNit7I@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> >> On Tue 2008-01-08 12:35:09, Miklos Szeredi wrote:
> >>> From: Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>
> >>>
> >>> Use FS_SAFE for "fuse" fs type, but not for "fuseblk".
> >>>
> >>> FUSE was designed from the beginning to be safe for unprivileged users.  This
> >>> has also been verified in practice over many years.  In addition unprivileged
> >> Eh? So 'kill -9 no longer works' and 'suspend no longer works' is not
> >> considered important enough to even mention?
> > 
> > No.  Because in practice they don't seem to matter.  Also because
> > there's no way in which fuse could be done differently to address
> > these issues.
> 
> Could you clarify, please? I hope I'm getting the wrong end of the stick
> - it sounds to me like you and Pavel are saying that this patch breaks
> suspending to ram (and hibernating?) but you want to push it anyway
> because you haven't been able to produce an instance, don't think
> suspending or hibernating matter and couldn't fix fuse anyway?

This patch has nothing to do with suspend or hibernate.  What this
patchset does, is help get rid of fusermount, a suid-root mount
helper.  It also opens up new possibilities, which are not fuse
related.

Fuse has bad interactions with the freezer, theoretically.  In
practice, I remember just one bug report (that sparked off this whole
"do we need freezer, or don't we" flamefest), that actually got fixed
fairly quickly, ...maybe.  Rafael probably remembers better.

> > The 'kill -9' thing is basically due to VFS level locking not being
> > interruptible.  It could be changed, but I'm not sure it's worth it.
> > 
> > For the suspend issue, there are also no easy solutions.
> 
> What are the non-easy solutions?

The ability to freeze tasks in uninterruptible sleep, or more
generally at any preempt point (except when drivers are poking
hardware).

I know this doesn't play well with userspace hibernate, and I don't
think it can be resolved without going the kexec way.

Miklos
