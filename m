From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [v2][PATCH 3/5] Move common mknod_ptmx() calls into caller
Date: Wed, 4 Feb 2009 18:26:55 -0600
Message-ID: <20090205002655.GD17354@us.ibm.com>
References: <20090204043516.GB25963@us.ibm.com>
	<20090204043732.GC26202@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090204043732.GC26202-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, hch-jcswGhMUV9g@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Wed, 28 Jan 2009 18:54:25 -0800
> Subject: [v2][PATCH 3/5] Move common mknod_ptmx() calls into caller
> 
> We create 'ptmx' node in both single-instance and multiple-instance
> mounts. So devpts_get_sb() can call mknod_ptmx() once rather than
> have both modes calling mknod_ptmx() separately.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

And now I see, you could get rid of update_ptmx() because
mknod_ptmx() will be called again anyway.  So if you
haven't replied yet pls ignore my previous email where I
asked about that :)

thanks,
-serge

> ---
>  fs/devpts/inode.c |   36 +++++++++++++++++-------------------
>  1 files changed, 17 insertions(+), 19 deletions(-)
> 
> diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
> index 9b24de8..f7e887c 100644
> --- a/fs/devpts/inode.c
> +++ b/fs/devpts/inode.c
> @@ -343,17 +343,7 @@ static int new_pts_mount(struct file_system_type *fs_type, int flags,
>  	fsi = DEVPTS_SB(mnt->mnt_sb);
>  	memcpy(&fsi->mount_opts, opts, sizeof(opts));
> 
> -	err = mknod_ptmx(mnt->mnt_sb);
> -	if (err)
> -		goto fail;
> -
>  	return 0;
> -
> -fail:
> -	dput(mnt->mnt_sb->s_root);
> -	up_write(&mnt->mnt_sb->s_umount);
> -	deactivate_super(mnt->mnt_sb);
> -	return err;
>  }
> 
>  /*
> @@ -421,13 +411,6 @@ static int init_pts_mount(struct file_system_type *fs_type, int flags,
>  	if (err)
>  		return err;
> 
> -	err = mknod_ptmx(mnt->mnt_sb);
> -	if (err) {
> -		dput(mnt->mnt_sb->s_root);
> -		up_write(&mnt->mnt_sb->s_umount);
> -		deactivate_super(mnt->mnt_sb);
> -	}
> -
>  	return err;
>  }
> 
> @@ -445,9 +428,24 @@ static int devpts_get_sb(struct file_system_type *fs_type,
>  	}
> 
>  	if (opts.newinstance)
> -		return new_pts_mount(fs_type, flags, data, &opts, mnt);
> +		error = new_pts_mount(fs_type, flags, data, &opts, mnt);
>  	else
> -		return init_pts_mount(fs_type, flags, data, &opts, mnt);
> +		error = init_pts_mount(fs_type, flags, data, &opts, mnt);
> +
> +	if (error)
> +		return error;
> +
> +	error = mknod_ptmx(mnt->mnt_sb);
> +	if (error)
> +		goto out_dput;
> +
> +	return 0;
> +
> +out_dput:
> +	dput(mnt->mnt_sb->s_root);
> +	up_write(&mnt->mnt_sb->s_umount);
> +	deactivate_super(mnt->mnt_sb);
> +	return error;
>  }
> 
>  #else
> -- 
> 1.5.2.5
