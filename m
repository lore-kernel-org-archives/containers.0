From: Szabolcs Szakacsits <szaka-IyvsvuGDJ8VAfugRpC6u6w@public.gmane.org>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Wed, 9 Jan 2008 11:19:04 +0200 (MET DST)
Message-ID: <Pine.LNX.4.61.0801091106010.4441@dhcppc1>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu>
 <20080108214625.GE5050@ucw.cz> <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu>
 <47840DAC.5000108@nigel.suspend2.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47840DAC.5000108-MhVfhJ0qHmuWn91e4EydUaxOck334EZe@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Nigel Cunningham <nigel-MhVfhJ0qHmuWn91e4EydUaxOck334EZe@public.gmane.org>
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, pavel-+ZI9xUNit7I@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Hi,

On Wed, 9 Jan 2008, Nigel Cunningham wrote:
> On Tue 2008-01-08 12:35:09, Miklos Szeredi wrote:
> >
> > For the suspend issue, there are also no easy solutions.
> 
> What are the non-easy solutions?

A practical point of view I've seen only fuse rootfs mounts to be a 
problem. I remember Ubuntu patches for this (WUBI and some other distros 
install NTFS root). But this probably also depends on the used suspend 
implementation.

Personally I've never had fuse related suspend problem with ordinary mounts 
during heavy use under development, nor NTFS user problem was tracked down 
to it in the last one and half year.

Regards,
	    Szaka

-- 
NTFS-3G:  http://ntfs-3g.org
