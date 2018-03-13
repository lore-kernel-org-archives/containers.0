From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/4 v5] devpts: hoist out check for DEVPTS_SUPER_MAGIC
Date: Tue, 13 Mar 2018 11:34:55 -0500
Message-ID: <87h8pk2ats.fsf@xmission.com>
References: <20180313121713.32551-1-christian.brauner@ubuntu.com>
	<20180313121713.32551-2-christian.brauner@ubuntu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180313121713.32551-2-christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> (Christian
	Brauner's message of "Tue, 13 Mar 2018 13:17:10 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:

> Hoist the check whether we have already found a suitable devpts filesystem
> out of devpts_ptmx_path() in preparation for the devpts bind-mount
> resolution patch. This is a non-functional change.

Reviewed-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

>
> Signed-off-by: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> ---
> ChangeLog v4->v5:
> * dput() dentry
> ChangeLog v3->v4:
> * patch unchanged
> ChangeLog v2->v3:
> * patch unchanged
> ChangeLog v1->v2:
> * patch added
> ChangeLog v0->v1:
> * patch not present
> ---
>  fs/devpts/inode.c | 26 +++++++++++++++-----------
>  1 file changed, 15 insertions(+), 11 deletions(-)
>
> diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
> index e31d6ed3ec32..71b901936113 100644
> --- a/fs/devpts/inode.c
> +++ b/fs/devpts/inode.c
> @@ -138,10 +138,6 @@ static int devpts_ptmx_path(struct path *path)
>  	struct super_block *sb;
>  	int err;
>  
> -	/* Has the devpts filesystem already been found? */
> -	if (path->mnt->mnt_sb->s_magic == DEVPTS_SUPER_MAGIC)
> -		return 0;
> -
>  	/* Is a devpts filesystem at "pts" in the same directory? */
>  	err = path_pts(path);
>  	if (err)
> @@ -159,21 +155,25 @@ static int devpts_ptmx_path(struct path *path)
>  struct vfsmount *devpts_mntget(struct file *filp, struct pts_fs_info *fsi)
>  {
>  	struct path path;
> -	int err;
> +	int err = 0;
>  
>  	path = filp->f_path;
>  	path_get(&path);
>  
> -	err = devpts_ptmx_path(&path);
> +	/* Has the devpts filesystem already been found? */
> +	if (path.mnt->mnt_sb->s_magic != DEVPTS_SUPER_MAGIC)
> +		err = devpts_ptmx_path(&path);
>  	dput(path.dentry);
>  	if (err) {
>  		mntput(path.mnt);
>  		return ERR_PTR(err);
>  	}
> +
>  	if (DEVPTS_SB(path.mnt->mnt_sb) != fsi) {
>  		mntput(path.mnt);
>  		return ERR_PTR(-ENODEV);
>  	}
> +
>  	return path.mnt;
>  }
>  
> @@ -182,15 +182,19 @@ struct pts_fs_info *devpts_acquire(struct file *filp)
>  	struct pts_fs_info *result;
>  	struct path path;
>  	struct super_block *sb;
> -	int err;
>  
>  	path = filp->f_path;
>  	path_get(&path);
>  
> -	err = devpts_ptmx_path(&path);
> -	if (err) {
> -		result = ERR_PTR(err);
> -		goto out;
> +	/* Has the devpts filesystem already been found? */
> +	if (path.mnt->mnt_sb->s_magic != DEVPTS_SUPER_MAGIC) {
> +		int err;
> +
> +		err = devpts_ptmx_path(&path);
> +		if (err) {
> +			result = ERR_PTR(err);
> +			goto out;
> +		}
>  	}
>  
>  	/*
