From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 2/9] unprivileged mounts: allow unprivileged umount
Date: Mon, 14 Jan 2008 15:48:41 -0600
Message-ID: <20080114214841.GB6704@sergelap.austin.ibm.com>
References: <20080108113502.184459371@szeredi.hu> <20080108113620.664824939@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080108113620.664824939-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Miklos Szeredi (miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org):
> From: Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>
> 
> The owner doesn't need sysadmin capabilities to call umount().
> 
> Similar behavior as umount(8) on mounts having "user=UID" option in /etc/mtab.
> The difference is that umount also checks /etc/fstab, presumably to exclude
> another mount on the same mountpoint.
> 
> Signed-off-by: Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
> 
> Index: linux/fs/namespace.c
> ===================================================================
> --- linux.orig/fs/namespace.c	2008-01-03 20:52:38.000000000 +0100
> +++ linux/fs/namespace.c	2008-01-03 21:14:16.000000000 +0100
> @@ -894,6 +894,27 @@ static int do_umount(struct vfsmount *mn
>  	return retval;
>  }
> 
> +static bool is_mount_owner(struct vfsmount *mnt, uid_t uid)
> +{
> +	return (mnt->mnt_flags & MNT_USER) && mnt->mnt_uid == uid;
> +}
> +
> +/*
> + * umount is permitted for
> + *  - sysadmin
> + *  - mount owner, if not forced umount
> + */
> +static bool permit_umount(struct vfsmount *mnt, int flags)
> +{
> +	if (capable(CAP_SYS_ADMIN))
> +		return true;
> +
> +	if (flags & MNT_FORCE)
> +		return false;
> +
> +	return is_mount_owner(mnt, current->fsuid);
> +}
> +
>  /*
>   * Now umount can handle mount points as well as block devices.
>   * This is important for filesystems which use unnamed block devices.
> @@ -917,7 +938,7 @@ asmlinkage long sys_umount(char __user *
>  		goto dput_and_out;
> 
>  	retval = -EPERM;
> -	if (!capable(CAP_SYS_ADMIN))
> +	if (!permit_umount(nd.path.mnt, flags))
>  		goto dput_and_out;
> 
>  	retval = do_umount(nd.path.mnt, flags);
> 
> --
