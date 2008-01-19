From: Szabolcs Szakacsits <szaka-IyvsvuGDJ8VAfugRpC6u6w@public.gmane.org>
Subject: Re: [patch] util-linux-ng: unprivileged mounts support
Date: Sat, 19 Jan 2008 23:42:33 +0200 (MET DST)
Message-ID: <Pine.LNX.4.61.0801192306420.4482@dhcppc1>
References: <E1JF7Xh-0003q3-Qv@pomaz-ex.szeredi.hu> <Pine.LNX.4.61.0801191745520.4482@dhcppc1>
 <E1JGKMY-00033X-FF@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1JGKMY-00033X-FF-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


On Sat, 19 Jan 2008, Miklos Szeredi wrote:
> 
> But 'fusermount -u /tmp/test' does work, doesn't it?

You're submitting patches to get rid of fusermount, aren't you?

Most users absolutely have no idea what fusermount is and they would 
__really__ like to see umount(8) working finally. 

	Szaka

--
NTFS-3G:  http://ntfs-3g.org
