From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 9/9] unprivileged mounts: add "no submounts" flag
Date: Mon, 14 Jan 2008 17:39:10 -0600
Message-ID: <20080114233910.GI6704@sergelap.austin.ibm.com>
References: <20080108113502.184459371@szeredi.hu> <20080108113634.382855604@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080108113634.382855604-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Miklos Szeredi (miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org):
> From: Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>
> 
> Add a new mount flag "nomnt", which denies submounts for the owner.
> This would be useful, if we want to support traditional /etc/fstab
> based user mounts.
> 
> In this case mount(8) would still have to be suid-root, to check the
> mountpoint against the user/users flag in /etc/fstab, but /etc/mtab
> would no longer be mandatory for storing the actual owner of the
> mount.

Ah, I see, so the floppy drive could be mounted as a MNT_NOMNT but
MNT_USER mount with mnt_owner set.  Makes sense.  I'd ask for a better
name than 'nomnt', but I can't think of one myself.

> Signed-off-by: Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
> 
> Index: linux/fs/namespace.c
> ===================================================================
> --- linux.orig/fs/namespace.c	2008-01-04 13:49:52.000000000 +0100
> +++ linux/fs/namespace.c	2008-01-04 13:50:28.000000000 +0100
> @@ -694,6 +694,7 @@ static int show_vfsmnt(struct seq_file *
>  		{ MNT_NOATIME, ",noatime" },
>  		{ MNT_NODIRATIME, ",nodiratime" },
>  		{ MNT_RELATIME, ",relatime" },
> +		{ MNT_NOMNT, ",nomnt" },
>  		{ 0, NULL }
>  	};
>  	struct proc_fs_info *fs_infop;
> @@ -1044,6 +1045,9 @@ static bool permit_mount(struct nameidat
>  	if (S_ISLNK(inode->i_mode))
>  		return false;
> 
> +	if (nd->path.mnt->mnt_flags & MNT_NOMNT)
> +		return false;
> +
>  	if (!is_mount_owner(nd->path.mnt, current->fsuid))
>  		return false;
> 
> @@ -1888,9 +1892,11 @@ long do_mount(char *dev_name, char *dir_
>  		mnt_flags |= MNT_RELATIME;
>  	if (flags & MS_RDONLY)
>  		mnt_flags |= MNT_READONLY;
> +	if (flags & MS_NOMNT)
> +		mnt_flags |= MNT_NOMNT;
> 
> -	flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | MS_ACTIVE |
> -		   MS_NOATIME | MS_NODIRATIME | MS_RELATIME| MS_KERNMOUNT);
> +	flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | MS_ACTIVE | MS_NOATIME |
> +			MS_NODIRATIME | MS_RELATIME | MS_KERNMOUNT | MS_NOMNT);
> 
>  	/* ... and get the mountpoint */
>  	retval = path_lookup(dir_name, LOOKUP_FOLLOW, &nd);
> Index: linux/include/linux/fs.h
> ===================================================================
> --- linux.orig/include/linux/fs.h	2008-01-04 13:49:12.000000000 +0100
> +++ linux/include/linux/fs.h	2008-01-04 13:49:58.000000000 +0100
> @@ -130,6 +130,7 @@ extern int dir_notify_enable;
>  #define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
>  #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
>  #define MS_SETUSER	(1<<24) /* set mnt_uid to current user */
> +#define MS_NOMNT	(1<<25) /* don't allow unprivileged submounts */
>  #define MS_ACTIVE	(1<<30)
>  #define MS_NOUSER	(1<<31)
> 
> Index: linux/include/linux/mount.h
> ===================================================================
> --- linux.orig/include/linux/mount.h	2008-01-04 13:45:45.000000000 +0100
> +++ linux/include/linux/mount.h	2008-01-04 13:49:58.000000000 +0100
> @@ -30,6 +30,7 @@ struct mnt_namespace;
>  #define MNT_NODIRATIME	0x10
>  #define MNT_RELATIME	0x20
>  #define MNT_READONLY	0x40	/* does the user want this to be r/o? */
> +#define MNT_NOMNT	0x80
> 
>  #define MNT_SHRINKABLE	0x100
>  #define MNT_IMBALANCED_WRITE_COUNT	0x200 /* just for debugging */
> 
> --
