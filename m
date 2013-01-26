From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH review 4/6] userns: Allow the userns root to mount of
	devpts
Date: Sat, 26 Jan 2013 21:22:02 +0000
Message-ID: <20130126212202.GF11274@mail.hallyn.com>
References: <87ehh8it9s.fsf@xmission.com>
 <87obgchecv.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87obgchecv.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 
> - The context in which devpts is mounted has no effect on the creation
>   of ptys as the /dev/ptmx interface has been used by unprivileged
>   users for many years.
> 
> - Only support unprivileged mounts in combination with the newinstance
>   option to ensure that mounting of /dev/pts in a user namespace will
>   not allow the options of an existing mount of devpts to be modified.
> 
> - Create /dev/pts/ptmx as the root user in the user namespace that
>   mounts devpts so that it's permissions to be changed.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> ---
>  fs/devpts/inode.c |   18 ++++++++++++++++++
>  1 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
> index 472e6be..073d30b 100644
> --- a/fs/devpts/inode.c
> +++ b/fs/devpts/inode.c
> @@ -243,6 +243,13 @@ static int mknod_ptmx(struct super_block *sb)
>  	struct dentry *root = sb->s_root;
>  	struct pts_fs_info *fsi = DEVPTS_SB(sb);
>  	struct pts_mount_opts *opts = &fsi->mount_opts;
> +	kuid_t root_uid;
> +	kgid_t root_gid;
> +
> +	root_uid = make_kuid(current_user_ns(), 0);
> +	root_gid = make_kgid(current_user_ns(), 0);
> +	if (!uid_valid(root_uid) || !gid_valid(root_gid))
> +		return -EINVAL;
>  
>  	mutex_lock(&root->d_inode->i_mutex);
>  
> @@ -273,6 +280,8 @@ static int mknod_ptmx(struct super_block *sb)
>  
>  	mode = S_IFCHR|opts->ptmxmode;
>  	init_special_inode(inode, mode, MKDEV(TTYAUX_MAJOR, 2));
> +	inode->i_uid = root_uid;
> +	inode->i_gid = root_gid;
>  
>  	d_add(dentry, inode);
>  
> @@ -438,6 +447,12 @@ static struct dentry *devpts_mount(struct file_system_type *fs_type,
>  	if (error)
>  		return ERR_PTR(error);
>  
> +	/* Require newinstance for all user namespace mounts to ensure
> +	 * the mount options are not changed.
> +	 */
> +	if ((current_user_ns() != &init_user_ns) && !opts.newinstance)
> +		return ERR_PTR(-EINVAL);
> +
>  	if (opts.newinstance)
>  		s = sget(fs_type, NULL, set_anon_super, flags, NULL);
>  	else
> @@ -491,6 +506,9 @@ static struct file_system_type devpts_fs_type = {
>  	.name		= "devpts",
>  	.mount		= devpts_mount,
>  	.kill_sb	= devpts_kill_sb,
> +#ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
> +	.fs_flags	= FS_USERNS_MOUNT | FS_USERNS_DEV_MOUNT,
> +#endif
>  };
>  
>  /*
> -- 
> 1.7.5.4
