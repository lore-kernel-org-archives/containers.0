From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [patch 1/9] unprivileged mounts: add user mounts to the kernel
Date: Tue, 8 Jan 2008 21:47:22 +0000
Message-ID: <20080108214721.GF5050@ucw.cz>
References: <20080108113502.184459371@szeredi.hu> <20080108113619.213519920@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080108113619.213519920-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


On Tue 2008-01-08 12:35:03, Miklos Szeredi wrote:
> From: Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>
> 
> This patchset adds support for keeping mount ownership information in the
> kernel, and allow unprivileged mount(2) and umount(2) in certain cases.
> 
> The mount owner has the following privileges:
> 
>   - unmount the owned mount
>   - create a submount under the owned mount

- create traps for updatedb, etc?

Is there Doc* file somewhere describing dangers of allowing this?
							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
