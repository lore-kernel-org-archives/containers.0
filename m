From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] fs: allow dev accesses in userns in controlled
	situations
Date: Fri, 15 Mar 2013 09:20:45 -0500
Message-ID: <20130315142045.GD3782__45620.224873028$1363357291$gmane$org@sergelap>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
	<1363338823-25292-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1363338823-25292-3-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> So far, unless the filesystem explicitly marks it (and most don't),
> processes running in user namespaces won't be allowed to access any
> devices. Although this makes sense, this is a quite restrictive rule,
> since a lot of those accesses would be perfectly safe: aside from the
> simple char devices in /dev/ like null, zero, etc, it is perfectly
> possible to assign a device for usage inside a namespace if we can
> establish trust in that operation.

Yeah we've talked about that too - as Eric pointed out it's not
strictly necessary as we can set that up with bind mounts from the
host's /dev.  So if he wants to nack - especially temporarily while
other things fall into place - I won't argue, but I'm happy with this.

> We will do that by marking the mount as MNT_NODEV_NS instead of
> MNT_NODEV. This is because if the mount operation explicitly asked for
> nodev, we ought to respect it. MNT_NODEV_NS will forbid accesses if the
> task is not on a device cgroup. If it is, we will rely on the control
> rules in devcg to intermediate the access an tell us what those tasks
> can or cannot do.

Well the devcg was meant to be a temporary stopgap solution until we
have device namespaces, and this seems to entrench them further, but
it does make sense.

> There is precedence for that with memcg: although we don't explicitly
> test it like I am doing it here, we are allowing tmpfs mounts to happen
> in user namespaces because memcg will contain them.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> ---
>  fs/namei.c            | 4 ++++
>  fs/namespace.c        | 2 +-
>  include/linux/mount.h | 2 ++
>  3 files changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 57ae9c8..8a34d79 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -2356,6 +2356,10 @@ static int may_open(struct path *path, int acc_mode, int flag)
>  	case S_IFCHR:
>  		if (path->mnt->mnt_flags & MNT_NODEV)
>  			return -EACCES;
> +
> +		if ((path->mnt->mnt_flags & MNT_NODEV_NS) &&
> +			!task_in_child_devcgroup(current))
> +			return -EACCES;
>  		/*FALLTHRU*/
>  	case S_IFIFO:
>  	case S_IFSOCK:
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 50ca17d..fe8127e 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1935,7 +1935,7 @@ static int do_new_mount(struct path *path, const char *fstype, int flags,
>  		 */
>  		if (!(type->fs_flags & FS_USERNS_DEV_MOUNT)) {
>  			flags |= MS_NODEV;
> -			mnt_flags |= MNT_NODEV;
> +			mnt_flags |= MNT_NODEV_NS;
>  		}
>  	}
>  
> diff --git a/include/linux/mount.h b/include/linux/mount.h
> index d7029f4..8d190e4 100644
> --- a/include/linux/mount.h
> +++ b/include/linux/mount.h
> @@ -32,6 +32,8 @@ struct mnt_namespace;
>  #define MNT_SHRINKABLE	0x100
>  #define MNT_WRITE_HOLD	0x200
>  
> +#define MNT_NODEV_NS	0x400   /* userns mount, and nodev not explicit */
> +
>  #define MNT_SHARED	0x1000	/* if the vfsmount is a shared mount */
>  #define MNT_UNBINDABLE	0x2000	/* if the vfsmount is a unbindable mount */
>  /*
> -- 
> 1.8.1.2
> 
