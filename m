From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Wed, 9 Jan 2008 15:00:51 +0100
Message-ID: <20080109140051.GB12784@elf.ucw.cz>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080108214625.GE5050@ucw.cz> <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu> <20080108225820.GA9735@elf.ucw.cz> <E1JCWxm-0005Fn-36@pomaz-ex.szeredi.hu> <20080109113325.GC9735@elf.ucw.cz> <E1JCan7-0005mP-UE@pomaz-ex.szeredi.hu> <20080109133506.GI9735@elf.ucw.cz> <E1JCbIb-0005rA-5O@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <E1JCbIb-0005rA-5O-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 2008-01-09 14:48:53, Miklos Szeredi wrote:
> > I'm not saying fuse is worthless. It is a nice toy for single-user
> > systems. But I do not think we should be merging "allow ordinary users
> > to mount their own fuse's" before issues above are fixed.
> 
> I think multi user systems are not all that interesting.  And I
> suspect very few of them want reliably working suspend/hibernate
> (which they wouldn't get due to other issues anyway), or have weird
> shutdown scripts which stop when they are unable to umount
> filesystems.

Weird shutdown scripts? I believe all shutdown scripts have this issue
-- if you want to [cleanly] unmount your / filesystem, you need all
the opens for write closed, right...? Which self-deadlocked fused
holding files open will prevent.

> For paranoid sysadmins, I suggest not enabling fuse for unprivileged
> users, which is pretty easy to do: just don't set /dev/fuse to be
> world read-writable (which is the default BTW).
> 
> So your reasons just don't warrant a big effort involving VFS hacking,
> etc.  Patches are of course welcome.

Well, I believe code with obscure, but almost impossible to fix
problems should not be merged... because that means it will not be
fixed and we'll just have to live with broken kill -9 forever.

Anyway, I believe it would be fair to mention kill -9 no longer
working and shutdown/hibernation/multiuser problems it implies in the
changelogs and probably sysctl documentation or how is this enabled.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
