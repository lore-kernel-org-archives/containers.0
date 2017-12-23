From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/11] block_dev: Support checking inode permissions in
	lookup_bdev()
Date: Fri, 22 Dec 2017 21:03:11 -0600
Message-ID: <20171223030311.GA6837__24607.143624644$1513998104$gmane$org@mail.hallyn.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<ef5e609602df6d7e2b4aa07b92600f04b6851902.1512041070.git.dongsu@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <ef5e609602df6d7e2b4aa07b92600f04b6851902.1512041070.git.dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Cc: linux-bcache-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Jan Kara <jack-IBi9RG/b67k@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 22, 2017 at 03:32:25PM +0100, Dongsu Park wrote:
> From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> When looking up a block device by path no permission check is
> done to verify that the user has access to the block device inode
> at the specified path. In some cases it may be necessary to
> check permissions towards the inode, such as allowing
> unprivileged users to mount block devices in user namespaces.
> 
> Add an argument to lookup_bdev() to optionally perform this
> permission check. A value of 0 skips the permission check and
> behaves the same as before. A non-zero value specifies the mask
> of access rights required towards the inode at the specified
> path. The check is always skipped if the user has CAP_SYS_ADMIN.
> 
> All callers of lookup_bdev() currently pass a mask of 0, so this
> patch results in no functional change. Subsequent patches will
> add permission checks where appropriate.
> 
> Patch v4 is available: https://patchwork.kernel.org/patch/8943601/
> 
> Cc: dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
> Cc: linux-bcache-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> Cc: Jan Kara <jack-IBi9RG/b67k@public.gmane.org>
> Cc: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>

Acked-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>

> Signed-off-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
> ---
>  drivers/md/bcache/super.c |  2 +-
>  drivers/md/dm-table.c     |  2 +-
>  drivers/mtd/mtdsuper.c    |  2 +-
>  fs/block_dev.c            | 13 ++++++++++---
>  fs/quota/quota.c          |  2 +-
>  include/linux/fs.h        |  2 +-
>  6 files changed, 15 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/md/bcache/super.c b/drivers/md/bcache/super.c
> index b4d28928..acc9d56c 100644
> --- a/drivers/md/bcache/super.c
> +++ b/drivers/md/bcache/super.c
> @@ -1967,7 +1967,7 @@ static ssize_t register_bcache(struct kobject *k, struct kobj_attribute *attr,
>  				  sb);
>  	if (IS_ERR(bdev)) {
>  		if (bdev == ERR_PTR(-EBUSY)) {
> -			bdev = lookup_bdev(strim(path));
> +			bdev = lookup_bdev(strim(path), 0);
>  			mutex_lock(&bch_register_lock);
>  			if (!IS_ERR(bdev) && bch_is_open(bdev))
>  				err = "device already registered";
> diff --git a/drivers/md/dm-table.c b/drivers/md/dm-table.c
> index 88130b5d..bca5eaf4 100644
> --- a/drivers/md/dm-table.c
> +++ b/drivers/md/dm-table.c
> @@ -410,7 +410,7 @@ dev_t dm_get_dev_t(const char *path)
>  	dev_t dev;
>  	struct block_device *bdev;
>  
> -	bdev = lookup_bdev(path);
> +	bdev = lookup_bdev(path, 0);
>  	if (IS_ERR(bdev))
>  		dev = name_to_dev_t(path);
>  	else {
> diff --git a/drivers/mtd/mtdsuper.c b/drivers/mtd/mtdsuper.c
> index e43fea89..4a4d40c0 100644
> --- a/drivers/mtd/mtdsuper.c
> +++ b/drivers/mtd/mtdsuper.c
> @@ -180,7 +180,7 @@ struct dentry *mount_mtd(struct file_system_type *fs_type, int flags,
>  	/* try the old way - the hack where we allowed users to mount
>  	 * /dev/mtdblock$(n) but didn't actually _use_ the blockdev
>  	 */
> -	bdev = lookup_bdev(dev_name);
> +	bdev = lookup_bdev(dev_name, 0);
>  	if (IS_ERR(bdev)) {
>  		ret = PTR_ERR(bdev);
>  		pr_debug("MTDSB: lookup_bdev() returned %d\n", ret);
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 4a181fcb..5ca06095 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -1662,7 +1662,7 @@ struct block_device *blkdev_get_by_path(const char *path, fmode_t mode,
>  	struct block_device *bdev;
>  	int err;
>  
> -	bdev = lookup_bdev(path);
> +	bdev = lookup_bdev(path, 0);
>  	if (IS_ERR(bdev))
>  		return bdev;
>  
> @@ -2052,12 +2052,14 @@ EXPORT_SYMBOL(ioctl_by_bdev);
>  /**
>   * lookup_bdev  - lookup a struct block_device by name
>   * @pathname:	special file representing the block device
> + * @mask:	rights to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC)
>   *
>   * Get a reference to the blockdevice at @pathname in the current
>   * namespace if possible and return it.  Return ERR_PTR(error)
> - * otherwise.
> + * otherwise.  If @mask is non-zero, check for access rights to the
> + * inode at @pathname.
>   */
> -struct block_device *lookup_bdev(const char *pathname)
> +struct block_device *lookup_bdev(const char *pathname, int mask)
>  {
>  	struct block_device *bdev;
>  	struct inode *inode;
> @@ -2072,6 +2074,11 @@ struct block_device *lookup_bdev(const char *pathname)
>  		return ERR_PTR(error);
>  
>  	inode = d_backing_inode(path.dentry);
> +	if (mask != 0 && !capable(CAP_SYS_ADMIN)) {
> +		error = __inode_permission(inode, mask);
> +		if (error)
> +			goto fail;
> +	}
>  	error = -ENOTBLK;
>  	if (!S_ISBLK(inode->i_mode))
>  		goto fail;
> diff --git a/fs/quota/quota.c b/fs/quota/quota.c
> index 43612e2a..e5d47955 100644
> --- a/fs/quota/quota.c
> +++ b/fs/quota/quota.c
> @@ -807,7 +807,7 @@ static struct super_block *quotactl_block(const char __user *special, int cmd)
>  
>  	if (IS_ERR(tmp))
>  		return ERR_CAST(tmp);
> -	bdev = lookup_bdev(tmp->name);
> +	bdev = lookup_bdev(tmp->name, 0);
>  	putname(tmp);
>  	if (IS_ERR(bdev))
>  		return ERR_CAST(bdev);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 2995a271..fce19c49 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2551,7 +2551,7 @@ static inline void unregister_chrdev(unsigned int major, const char *name)
>  #define BLKDEV_MAJOR_MAX	512
>  extern const char *__bdevname(dev_t, char *buffer);
>  extern const char *bdevname(struct block_device *bdev, char *buffer);
> -extern struct block_device *lookup_bdev(const char *);
> +extern struct block_device *lookup_bdev(const char *, int mask);
>  extern void blkdev_show(struct seq_file *,off_t);
>  
>  #else
> -- 
> 2.13.6
