From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Tue, 15 Jan 2008 07:35:04 -0600
Message-ID: <20080115133504.GA4453@sergelap.austin.ibm.com>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080114232419.GH6704@sergelap.austin.ibm.com> <E1JEj3N-0000vj-QA@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <E1JEj3N-0000vj-QA-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Miklos Szeredi (miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org):
> > Sounds like a sysctl to enable FS_SAFE for fuse will make this patch
> > acceptable to everyone?
> 
> I think the most generic approach, is to be able to set "safeness" for
> any fs type, not just fuse (Karel's suggestion).
> 
> E.g:
> 
>   echo 1 > /proc/sys/fs/types/cifs/safe
> 
> This would also provide a way to query the FS_SAFE flag.

That sounds good.

-serge
