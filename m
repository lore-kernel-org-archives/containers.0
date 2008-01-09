From: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Subject: Re: [patch 6/9] unprivileged mounts: allow unprivileged mounts
Date: Wed, 09 Jan 2008 13:41:40 +0100
Message-ID: <E1JCaFY-0005iK-LM@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113629.192719163@szeredi.hu> <20080109111120.GI3926@petra.dvoda.cz>
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <20080109111120.GI3926-CxBs/XhZ2BtHjqfyn1fVYA@public.gmane.org> (message from Karel Zak on
	Wed, 9 Jan 2008 12:11:20 +0100)
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> On Tue, Jan 08, 2008 at 12:35:08PM +0100, Miklos Szeredi wrote:
> > Define a new fs flag FS_SAFE, which denotes, that unprivileged mounting of
> > this filesystem may not constitute a security problem.
> > 
> > Since most filesystems haven't been designed with unprivileged mounting in
> > mind, a thorough audit is needed before setting this flag.
> > 
> > For "safe" filesystems also allow unprivileged forced unmounting.
> 
>  What about to list "safe" filesystems anywhere in /proc/fs/ ? I think
>  it's very important information for admins.

Makes sense.  I'll cook up something.

>  Note, your patch for mount(8) is always trying to use unprivileged
>  mount(2) for non-root users. It's overkill when unprivileged mounts are
>  supported for bind mounts and fuse only. It would be nice to check
>  if FS is "safe" before switch to unprivileged mode.

I think the little gain in performance is not worth the added
complexity.  Especially if the added complexity is in the privileged
part, and itself can be a source of security holes.

>  The "safe" definition is also very subjective and it depends on your
>  level of paranoia. There should be a way (e.g. /proc) how control and
>  modify the list of "safe" filesystems. For example I have no problem
>  to mark cifs as "safe" for my home server.

OK, also makes some sense.  Pavel's examples do point out that fuse
isn't as safe as I'd like it to be, so perhaps it would make sense to
default to just bind mounts being allowed, and having to explicity
enable unprivileged fuse mounts with a sysctl or whatever.

Miklos
