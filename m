From: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Subject: Re: [patch 07/10] unprivileged mounts: add sysctl tunable for
	"safe" property
Date: Mon, 21 Jan 2008 22:37:49 +0100
Message-ID: <E1JH4Kz-0006gt-MC@pomaz-ex.szeredi.hu>
References: <20080116123147.466284860@szeredi.hu> <20080116123433.126167584@szeredi.hu> <20080121203249.GB5536@sergelap.austin.rr.com>
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <20080121203249.GB5536-6s5zFf/epYLPQpwDFJZrxFMas7LaWZ9n@public.gmane.org> (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org)
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> What do you think about doing this only if FS_SAFE is also set,
> so for instance at first only FUSE would allow itself to be
> made user-mountable?
> 
> A safe thing to do, or overly intrusive?

It goes somewhat against the "no policy in kernel" policy ;).  I think
the warning in the documentation should be enough to make sysadmins
think twice before doing anything foolish:

> +Care should be taken when enabling this, since most
> +filesystems haven't been designed with unprivileged mounting
> +in mind.
> +

BTW, filesystems like 'proc' and 'sysfs' should also be safe, although
the only use for them being marked safe is if the users are allowed to
umount them from their private namespace (otherwise a 'mount --bind'
has the same effect as a new mount).

Thanks,
Miklos
