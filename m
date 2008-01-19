From: Szabolcs Szakacsits <szaka-IyvsvuGDJ8VAfugRpC6u6w@public.gmane.org>
Subject: Re: [patch] util-linux-ng: unprivileged mounts support
Date: Sat, 19 Jan 2008 18:05:15 +0200 (MET DST)
Message-ID: <Pine.LNX.4.61.0801191745520.4482@dhcppc1>
References: <E1JF7Xh-0003q3-Qv@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1JF7Xh-0003q3-Qv-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


On Wed, 16 Jan 2008, Miklos Szeredi wrote:

> This is an experimental patch for supporing unprivileged mounts and
> umounts.  

User unmount unfortunately still doesn't work if the kernel doesn't have 
the unprivileged mount support but as we discussed this in last July that 
shouldn't be needed for this case.

  % mount -t ntfs-3g /dev/hda10 /tmp/test
  % cat /proc/mounts | grep /tmp/test                                                                         
  /dev/hda10 /tmp/test fuseblk rw,nosuid,nodev,user_id=501,group_id=501,allow_other 0 0
  % mount | grep /tmp/test
  /dev/hda10 on /tmp/test type fuseblk (rw,nosuid,nodev,allow_other,blksize=1024,user=szaka)
  % umount /tmp/test
  umount: /dev/hda10: not mounted
  umount: /tmp/test: must be superuser to umount
  umount: /dev/hda10: not mounted
  umount: /tmp/test: must be superuser to umount

	Szaka

--
NTFS-3G:  http://ntfs-3g.org
