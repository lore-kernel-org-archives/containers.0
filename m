From: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Subject: Re: [patch] util-linux-ng: unprivileged mounts support
Date: Sat, 19 Jan 2008 21:32:22 +0100
Message-ID: <E1JGKMY-00033X-FF@pomaz-ex.szeredi.hu>
References: <E1JF7Xh-0003q3-Qv@pomaz-ex.szeredi.hu> <Pine.LNX.4.61.0801191745520.4482@dhcppc1>
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <Pine.LNX.4.61.0801191745520.4482@dhcppc1> (message from Szabolcs
	Szakacsits on Sat, 19 Jan 2008 18:05:15 +0200 (MET DST))
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: szaka-IyvsvuGDJ8VAfugRpC6u6w@public.gmane.org
Cc: miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

> > This is an experimental patch for supporing unprivileged mounts and
> > umounts.  
> 
> User unmount unfortunately still doesn't work if the kernel doesn't have 
> the unprivileged mount support but as we discussed this in last July that 
> shouldn't be needed for this case.
> 
>   % mount -t ntfs-3g /dev/hda10 /tmp/test
>   % cat /proc/mounts | grep /tmp/test                                                                         
>   /dev/hda10 /tmp/test fuseblk rw,nosuid,nodev,user_id=501,group_id=501,allow_other 0 0
>   % mount | grep /tmp/test
>   /dev/hda10 on /tmp/test type fuseblk (rw,nosuid,nodev,allow_other,blksize=1024,user=szaka)
>   % umount /tmp/test
>   umount: /dev/hda10: not mounted
>   umount: /tmp/test: must be superuser to umount
>   umount: /dev/hda10: not mounted
>   umount: /tmp/test: must be superuser to umount

But 'fusermount -u /tmp/test' does work, doesn't it?

Yes, this should probably be fixed in umount(8), but it's an (almost)
completely separate issue.

Miklos
