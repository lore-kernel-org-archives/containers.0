From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH linux-cr] put file_ops->checkpoint under CONFIG_CHECKPOINT
Date: Tue, 30 Mar 2010 18:23:38 -0700
Message-ID: <20100331012338.GR3345@count0.beaverton.ibm.com>
References: <20100330235856.GA24963@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100330235856.GA24963-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 30, 2010 at 06:58:56PM -0500, Serge E. Hallyn wrote:
> It is a matter of preference, and what we had before was correct,
> but we've been asked to just put the method under #ifdef
> CONFIG_CHECKPOINT.  So do so, and get rid of the #else dummy
> defines.
> 
> I did quite a bit of find . -type f -print0 | xargs -0 grep -Hn and
> hope I found all cases.  Even a make allyesconfig didn't point to
> anything I might have missed.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Looks good to me. I don't know if we should add:

Cc: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

or merely list it in a changelog for the f_ops patch(es).

Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  drivers/char/mem.c          |    4 ++++
>  drivers/char/random.c       |    4 ++++
>  drivers/char/tty_io.c       |    7 ++++---
>  fs/adfs/dir.c               |    2 ++
>  fs/adfs/file.c              |    2 ++
>  fs/affs/dir.c               |    2 ++
>  fs/affs/file.c              |    2 ++
>  fs/befs/linuxvfs.c          |    2 ++
>  fs/bfs/dir.c                |    2 ++
>  fs/bfs/file.c               |    2 ++
>  fs/btrfs/file.c             |    2 ++
>  fs/btrfs/inode.c            |    2 ++
>  fs/btrfs/super.c            |    2 ++
>  fs/cramfs/inode.c           |    2 ++
>  fs/ecryptfs/file.c          |    4 ++++
>  fs/ecryptfs/miscdev.c       |    2 ++
>  fs/efs/dir.c                |    2 ++
>  fs/eventfd.c                |    4 ++--
>  fs/eventpoll.c              |    5 ++---
>  fs/exofs/dir.c              |    2 ++
>  fs/exofs/file.c             |    4 +++-
>  fs/ext2/dir.c               |    2 ++
>  fs/ext2/file.c              |    4 ++++
>  fs/ext3/dir.c               |    2 ++
>  fs/ext3/file.c              |    2 ++
>  fs/ext4/dir.c               |    2 ++
>  fs/ext4/file.c              |    2 ++
>  fs/fat/dir.c                |    2 ++
>  fs/fat/file.c               |    2 ++
>  fs/freevxfs/vxfs_lookup.c   |    2 ++
>  fs/hfs/dir.c                |    2 ++
>  fs/hfs/inode.c              |    2 ++
>  fs/hfsplus/dir.c            |    2 ++
>  fs/hfsplus/inode.c          |    2 ++
>  fs/hostfs/hostfs_kern.c     |    8 ++++++--
>  fs/hpfs/dir.c               |    2 ++
>  fs/hpfs/file.c              |    2 ++
>  fs/hppfs/hppfs.c            |    4 ++++
>  fs/isofs/dir.c              |    2 ++
>  fs/jffs2/dir.c              |    2 ++
>  fs/jffs2/file.c             |    2 ++
>  fs/jfs/file.c               |    2 ++
>  fs/jfs/namei.c              |    2 ++
>  fs/minix/dir.c              |    2 ++
>  fs/minix/file.c             |    2 ++
>  fs/nfs/dir.c                |    2 ++
>  fs/nfs/file.c               |    2 ++
>  fs/nilfs2/dir.c             |    2 ++
>  fs/nilfs2/file.c            |    4 +++-
>  fs/ntfs/dir.c               |    2 ++
>  fs/ntfs/file.c              |    2 ++
>  fs/omfs/dir.c               |    2 ++
>  fs/omfs/file.c              |    2 ++
>  fs/openpromfs/inode.c       |    4 ++++
>  fs/pipe.c                   |    9 ++++++---
>  fs/qnx4/dir.c               |    2 ++
>  fs/ramfs/file-mmu.c         |    2 ++
>  fs/ramfs/file-nommu.c       |    2 ++
>  fs/read_write.c             |    2 ++
>  fs/reiserfs/dir.c           |    2 ++
>  fs/reiserfs/file.c          |    2 ++
>  fs/romfs/mmap-nommu.c       |    2 ++
>  fs/romfs/super.c            |    2 ++
>  fs/squashfs/dir.c           |    2 ++
>  fs/sysv/dir.c               |    2 ++
>  fs/sysv/file.c              |    2 ++
>  fs/ubifs/debug.c            |    4 +++-
>  fs/ubifs/dir.c              |    2 ++
>  fs/ubifs/file.c             |    2 ++
>  fs/udf/dir.c                |    2 ++
>  fs/udf/file.c               |    2 ++
>  fs/ufs/dir.c                |    2 ++
>  fs/ufs/file.c               |    2 ++
>  fs/xfs/linux-2.6/xfs_file.c |    4 ++++
>  include/linux/fs.h          |    4 ++--
>  mm/filemap.c                |    2 --
>  mm/mmap.c                   |    2 --
>  77 files changed, 177 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/char/mem.c b/drivers/char/mem.c
> index 57e3443..c5e23a9 100644
> --- a/drivers/char/mem.c
> +++ b/drivers/char/mem.c
> @@ -763,7 +763,9 @@ static const struct file_operations null_fops = {
>  	.read		= read_null,
>  	.write		= write_null,
>  	.splice_write	= splice_write_null,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  #ifdef CONFIG_DEVPORT
> @@ -780,7 +782,9 @@ static const struct file_operations zero_fops = {
>  	.read		= read_zero,
>  	.write		= write_zero,
>  	.mmap		= mmap_zero,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  /*
> diff --git a/drivers/char/random.c b/drivers/char/random.c
> index c082789..f1b9ade 100644
> --- a/drivers/char/random.c
> +++ b/drivers/char/random.c
> @@ -1169,7 +1169,9 @@ const struct file_operations random_fops = {
>  	.poll  = random_poll,
>  	.unlocked_ioctl = random_ioctl,
>  	.fasync = random_fasync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct file_operations urandom_fops = {
> @@ -1177,7 +1179,9 @@ const struct file_operations urandom_fops = {
>  	.write = random_write,
>  	.unlocked_ioctl = random_ioctl,
>  	.fasync = random_fasync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  /***************************************************************
> diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
> index 86946af..1262597 100644
> --- a/drivers/char/tty_io.c
> +++ b/drivers/char/tty_io.c
> @@ -155,9 +155,6 @@ static int tty_fasync(int fd, struct file *filp, int on);
>  #ifdef CONFIG_CHECKPOINT
>  static int tty_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
>  static int tty_file_collect(struct ckpt_ctx *ctx, struct file *file);
> -#else
> -#define tty_file_checkpoint NULL
> -#define tty_file_collect NULL
>  #endif /* CONFIG_CHECKPOINT */
>  static void release_tty(struct tty_struct *tty, int idx);
>  static void __proc_set_tty(struct task_struct *tsk, struct tty_struct *tty);
> @@ -425,8 +422,10 @@ static const struct file_operations tty_fops = {
>  	.open		= tty_open,
>  	.release	= tty_release,
>  	.fasync		= tty_fasync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= tty_file_checkpoint,
>  	.collect	= tty_file_collect,
> +#endif
>  };
> 
>  static const struct file_operations console_fops = {
> @@ -449,8 +448,10 @@ static const struct file_operations hung_up_tty_fops = {
>  	.unlocked_ioctl	= hung_up_tty_ioctl,
>  	.compat_ioctl	= hung_up_tty_compat_ioctl,
>  	.release	= tty_release,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= tty_file_checkpoint,
>  	.collect	= tty_file_collect,
> +#endif
>  };
> 
>  static DEFINE_SPINLOCK(redirect_lock);
> diff --git a/fs/adfs/dir.c b/fs/adfs/dir.c
> index 7106f32..c205b40 100644
> --- a/fs/adfs/dir.c
> +++ b/fs/adfs/dir.c
> @@ -198,7 +198,9 @@ const struct file_operations adfs_dir_operations = {
>  	.llseek		= generic_file_llseek,
>  	.readdir	= adfs_readdir,
>  	.fsync		= simple_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static int
> diff --git a/fs/adfs/file.c b/fs/adfs/file.c
> index 97bd298..09ce6c7 100644
> --- a/fs/adfs/file.c
> +++ b/fs/adfs/file.c
> @@ -30,7 +30,9 @@ const struct file_operations adfs_file_operations = {
>  	.write		= do_sync_write,
>  	.aio_write	= generic_file_aio_write,
>  	.splice_read	= generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations adfs_file_inode_operations = {
> diff --git a/fs/affs/dir.c b/fs/affs/dir.c
> index 6cc5e43..02511bf 100644
> --- a/fs/affs/dir.c
> +++ b/fs/affs/dir.c
> @@ -22,7 +22,9 @@ const struct file_operations affs_dir_operations = {
>  	.llseek		= generic_file_llseek,
>  	.readdir	= affs_readdir,
>  	.fsync		= affs_file_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  /*
> diff --git a/fs/affs/file.c b/fs/affs/file.c
> index d580a12..22577fa 100644
> --- a/fs/affs/file.c
> +++ b/fs/affs/file.c
> @@ -36,7 +36,9 @@ const struct file_operations affs_file_operations = {
>  	.release	= affs_file_release,
>  	.fsync		= affs_file_fsync,
>  	.splice_read	= generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations affs_file_inode_operations = {
> diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
> index b97f79b..71488ba 100644
> --- a/fs/befs/linuxvfs.c
> +++ b/fs/befs/linuxvfs.c
> @@ -67,7 +67,9 @@ static const struct file_operations befs_dir_operations = {
>  	.read		= generic_read_dir,
>  	.readdir	= befs_readdir,
>  	.llseek		= generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static const struct inode_operations befs_dir_inode_operations = {
> diff --git a/fs/bfs/dir.c b/fs/bfs/dir.c
> index d78015e..18bea30 100644
> --- a/fs/bfs/dir.c
> +++ b/fs/bfs/dir.c
> @@ -80,7 +80,9 @@ const struct file_operations bfs_dir_operations = {
>  	.readdir	= bfs_readdir,
>  	.fsync		= simple_fsync,
>  	.llseek		= generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  extern void dump_imap(const char *, struct super_block *);
> diff --git a/fs/bfs/file.c b/fs/bfs/file.c
> index 7f61ed6..844ff41 100644
> --- a/fs/bfs/file.c
> +++ b/fs/bfs/file.c
> @@ -29,7 +29,9 @@ const struct file_operations bfs_file_operations = {
>  	.aio_write	= generic_file_aio_write,
>  	.mmap		= generic_file_mmap,
>  	.splice_read	= generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static int bfs_move_block(unsigned long from, unsigned long to,
> diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
> index 281a2b8..14d7fdf 100644
> --- a/fs/btrfs/file.c
> +++ b/fs/btrfs/file.c
> @@ -1164,5 +1164,7 @@ const struct file_operations btrfs_file_operations = {
>  #ifdef CONFIG_COMPAT
>  	.compat_ioctl	= btrfs_ioctl,
>  #endif
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 606c31d..5141ac0 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -5971,7 +5971,9 @@ static const struct file_operations btrfs_dir_file_operations = {
>  #endif
>  	.release        = btrfs_release_file,
>  	.fsync		= btrfs_sync_file,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static struct extent_io_ops btrfs_extent_io_ops = {
> diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
> index 7a28ac5..a8f6427 100644
> --- a/fs/btrfs/super.c
> +++ b/fs/btrfs/super.c
> @@ -718,7 +718,9 @@ static const struct file_operations btrfs_ctl_fops = {
>  	.unlocked_ioctl	 = btrfs_control_ioctl,
>  	.compat_ioctl = btrfs_control_ioctl,
>  	.owner	 = THIS_MODULE,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  static struct miscdevice btrfs_misc = {
> diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
> index 0927503..01ee36d 100644
> --- a/fs/cramfs/inode.c
> +++ b/fs/cramfs/inode.c
> @@ -532,7 +532,9 @@ static const struct file_operations cramfs_directory_operations = {
>  	.llseek		= generic_file_llseek,
>  	.read		= generic_read_dir,
>  	.readdir	= cramfs_readdir,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static const struct inode_operations cramfs_dir_inode_operations = {
> diff --git a/fs/ecryptfs/file.c b/fs/ecryptfs/file.c
> index a8973ef..f6555aa 100644
> --- a/fs/ecryptfs/file.c
> +++ b/fs/ecryptfs/file.c
> @@ -305,7 +305,9 @@ const struct file_operations ecryptfs_dir_fops = {
>  	.fsync = ecryptfs_fsync,
>  	.fasync = ecryptfs_fasync,
>  	.splice_read = generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct file_operations ecryptfs_main_fops = {
> @@ -323,7 +325,9 @@ const struct file_operations ecryptfs_main_fops = {
>  	.fsync = ecryptfs_fsync,
>  	.fasync = ecryptfs_fasync,
>  	.splice_read = generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  static int
> diff --git a/fs/ecryptfs/miscdev.c b/fs/ecryptfs/miscdev.c
> index 9fd9b39..f62d066 100644
> --- a/fs/ecryptfs/miscdev.c
> +++ b/fs/ecryptfs/miscdev.c
> @@ -481,7 +481,9 @@ static const struct file_operations ecryptfs_miscdev_fops = {
>  	.read    = ecryptfs_miscdev_read,
>  	.write   = ecryptfs_miscdev_write,
>  	.release = ecryptfs_miscdev_release,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  static struct miscdevice ecryptfs_miscdev = {
> diff --git a/fs/efs/dir.c b/fs/efs/dir.c
> index da344b8..ff08a3b 100644
> --- a/fs/efs/dir.c
> +++ b/fs/efs/dir.c
> @@ -13,7 +13,9 @@ const struct file_operations efs_dir_operations = {
>  	.llseek		= generic_file_llseek,
>  	.read		= generic_read_dir,
>  	.readdir	= efs_readdir,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations efs_dir_inode_operations = {
> diff --git a/fs/eventfd.c b/fs/eventfd.c
> index f2785c0..e412a02 100644
> --- a/fs/eventfd.c
> +++ b/fs/eventfd.c
> @@ -337,8 +337,6 @@ struct file *eventfd_restore(struct ckpt_ctx *ckpt_ctx,
>  	}
>  	return evfile;
>  }
> -#else
> -#define eventfd_checkpoint NULL
>  #endif
> 
>  static const struct file_operations eventfd_fops = {
> @@ -346,7 +344,9 @@ static const struct file_operations eventfd_fops = {
>  	.poll		= eventfd_poll,
>  	.read		= eventfd_read,
>  	.write		= eventfd_write,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint     = eventfd_checkpoint,
> +#endif
>  };
> 
>  /**
> diff --git a/fs/eventpoll.c b/fs/eventpoll.c
> index 7f1a091..c197e91 100644
> --- a/fs/eventpoll.c
> +++ b/fs/eventpoll.c
> @@ -677,17 +677,16 @@ static unsigned int ep_eventpoll_poll(struct file *file, poll_table *wait)
>  #ifdef CONFIG_CHECKPOINT
>  static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file);
>  static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file);
> -#else
> -#define ep_eventpoll_checkpoint NULL
> -#define ep_file_collect NULL
>  #endif
> 
>  /* File callbacks that implement the eventpoll file behaviour */
>  static const struct file_operations eventpoll_fops = {
>  	.release	= ep_eventpoll_release,
>  	.poll		= ep_eventpoll_poll,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint 	= ep_eventpoll_checkpoint,
>  	.collect 	= ep_file_collect,
> +#endif
>  };
> 
>  /* Fast test to see if the file is an evenpoll file */
> diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
> index f6693d3..62347ff 100644
> --- a/fs/exofs/dir.c
> +++ b/fs/exofs/dir.c
> @@ -667,5 +667,7 @@ const struct file_operations exofs_dir_operations = {
>  	.llseek		= generic_file_llseek,
>  	.read		= generic_read_dir,
>  	.readdir	= exofs_readdir,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/exofs/file.c b/fs/exofs/file.c
> index 257e9da..ec7e15a 100644
> --- a/fs/exofs/file.c
> +++ b/fs/exofs/file.c
> @@ -73,7 +73,6 @@ static int exofs_flush(struct file *file, fl_owner_t id)
> 
>  const struct file_operations exofs_file_operations = {
>  	.llseek		= generic_file_llseek,
> -	.checkpoint	= generic_file_checkpoint,
>  	.read		= do_sync_read,
>  	.write		= do_sync_write,
>  	.aio_read	= generic_file_aio_read,
> @@ -85,6 +84,9 @@ const struct file_operations exofs_file_operations = {
>  	.flush		= exofs_flush,
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations exofs_file_inode_operations = {
> diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
> index 84c17f9..cdcb065 100644
> --- a/fs/ext2/dir.c
> +++ b/fs/ext2/dir.c
> @@ -722,5 +722,7 @@ const struct file_operations ext2_dir_operations = {
>  	.compat_ioctl	= ext2_compat_ioctl,
>  #endif
>  	.fsync		= ext2_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index b38d7b9..b963b3a 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -75,7 +75,9 @@ const struct file_operations ext2_file_operations = {
>  	.fsync		= ext2_fsync,
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif /* CONFIG_CHECKPOINT */
>  };
> 
>  #ifdef CONFIG_EXT2_FS_XIP
> @@ -91,7 +93,9 @@ const struct file_operations ext2_xip_file_operations = {
>  	.open		= generic_file_open,
>  	.release	= ext2_release_file,
>  	.fsync		= ext2_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif /* CONFIG_CHECKPOINT */
>  };
>  #endif
> 
> diff --git a/fs/ext3/dir.c b/fs/ext3/dir.c
> index 65f98af..a4ef201 100644
> --- a/fs/ext3/dir.c
> +++ b/fs/ext3/dir.c
> @@ -48,7 +48,9 @@ const struct file_operations ext3_dir_operations = {
>  #endif
>  	.fsync		= ext3_sync_file,	/* BKL held */
>  	.release	= ext3_release_dir,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
> 
> diff --git a/fs/ext3/file.c b/fs/ext3/file.c
> index bcd9b88..8e51282 100644
> --- a/fs/ext3/file.c
> +++ b/fs/ext3/file.c
> @@ -67,7 +67,9 @@ const struct file_operations ext3_file_operations = {
>  	.fsync		= ext3_sync_file,
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations ext3_file_inode_operations = {
> diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
> index f69404c..a6aeba1 100644
> --- a/fs/ext4/dir.c
> +++ b/fs/ext4/dir.c
> @@ -48,7 +48,9 @@ const struct file_operations ext4_dir_operations = {
>  #endif
>  	.fsync		= ext4_sync_file,
>  	.release	= ext4_release_dir,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
> 
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index 93a129b..6540205 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -149,7 +149,9 @@ const struct file_operations ext4_file_operations = {
>  	.fsync		= ext4_sync_file,
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations ext4_file_inode_operations = {
> diff --git a/fs/fat/dir.c b/fs/fat/dir.c
> index e3fa353..4a4c7bb 100644
> --- a/fs/fat/dir.c
> +++ b/fs/fat/dir.c
> @@ -841,7 +841,9 @@ const struct file_operations fat_dir_operations = {
>  	.compat_ioctl	= fat_compat_dir_ioctl,
>  #endif
>  	.fsync		= fat_file_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static int fat_get_short_entry(struct inode *dir, loff_t *pos,
> diff --git a/fs/fat/file.c b/fs/fat/file.c
> index e5aecc6..38132c2 100644
> --- a/fs/fat/file.c
> +++ b/fs/fat/file.c
> @@ -162,7 +162,9 @@ const struct file_operations fat_file_operations = {
>  	.ioctl		= fat_generic_ioctl,
>  	.fsync		= fat_file_fsync,
>  	.splice_read	= generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static int fat_cont_expand(struct inode *inode, loff_t size)
> diff --git a/fs/freevxfs/vxfs_lookup.c b/fs/freevxfs/vxfs_lookup.c
> index 3a09132..41dfea9 100644
> --- a/fs/freevxfs/vxfs_lookup.c
> +++ b/fs/freevxfs/vxfs_lookup.c
> @@ -58,7 +58,9 @@ const struct inode_operations vxfs_dir_inode_ops = {
> 
>  const struct file_operations vxfs_dir_operations = {
>  	.readdir =		vxfs_readdir,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint =		generic_file_checkpoint,
> +#endif
>  };
> 
>   
> diff --git a/fs/hfs/dir.c b/fs/hfs/dir.c
> index 0eef6c2..f4dafc5 100644
> --- a/fs/hfs/dir.c
> +++ b/fs/hfs/dir.c
> @@ -329,7 +329,9 @@ const struct file_operations hfs_dir_operations = {
>  	.readdir	= hfs_readdir,
>  	.llseek		= generic_file_llseek,
>  	.release	= hfs_dir_release,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations hfs_dir_inode_operations = {
> diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
> index bf8950f..2c74875 100644
> --- a/fs/hfs/inode.c
> +++ b/fs/hfs/inode.c
> @@ -607,7 +607,9 @@ static const struct file_operations hfs_file_operations = {
>  	.fsync		= file_fsync,
>  	.open		= hfs_file_open,
>  	.release	= hfs_file_release,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static const struct inode_operations hfs_file_inode_operations = {
> diff --git a/fs/hfsplus/dir.c b/fs/hfsplus/dir.c
> index 41fbf2d..7656143 100644
> --- a/fs/hfsplus/dir.c
> +++ b/fs/hfsplus/dir.c
> @@ -497,5 +497,7 @@ const struct file_operations hfsplus_dir_operations = {
>  	.ioctl          = hfsplus_ioctl,
>  	.llseek		= generic_file_llseek,
>  	.release	= hfsplus_dir_release,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
> index 19abd7e..43a6da2 100644
> --- a/fs/hfsplus/inode.c
> +++ b/fs/hfsplus/inode.c
> @@ -286,7 +286,9 @@ static const struct file_operations hfsplus_file_operations = {
>  	.open		= hfsplus_file_open,
>  	.release	= hfsplus_file_release,
>  	.ioctl          = hfsplus_ioctl,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  struct inode *hfsplus_new_inode(struct super_block *sb, int mode)
> diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
> index 67e2356..25a3d9e 100644
> --- a/fs/hostfs/hostfs_kern.c
> +++ b/fs/hostfs/hostfs_kern.c
> @@ -417,7 +417,6 @@ int hostfs_fsync(struct file *file, struct dentry *dentry, int datasync)
> 
>  static const struct file_operations hostfs_file_fops = {
>  	.llseek		= generic_file_llseek,
> -	.checkpoint	= generic_file_checkpoint,
>  	.read		= do_sync_read,
>  	.splice_read	= generic_file_splice_read,
>  	.aio_read	= generic_file_aio_read,
> @@ -427,13 +426,18 @@ static const struct file_operations hostfs_file_fops = {
>  	.open		= hostfs_file_open,
>  	.release	= NULL,
>  	.fsync		= hostfs_fsync,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static const struct file_operations hostfs_dir_fops = {
>  	.llseek		= generic_file_llseek,
> -	.checkpoint	= generic_file_checkpoint,
>  	.readdir	= hostfs_readdir,
>  	.read		= generic_read_dir,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  int hostfs_writepage(struct page *page, struct writeback_control *wbc)
> diff --git a/fs/hpfs/dir.c b/fs/hpfs/dir.c
> index dcde10f..33897ad 100644
> --- a/fs/hpfs/dir.c
> +++ b/fs/hpfs/dir.c
> @@ -322,5 +322,7 @@ const struct file_operations hpfs_dir_ops =
>  	.readdir	= hpfs_readdir,
>  	.release	= hpfs_dir_release,
>  	.fsync		= hpfs_file_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/hpfs/file.c b/fs/hpfs/file.c
> index f1211f0..7a78261 100644
> --- a/fs/hpfs/file.c
> +++ b/fs/hpfs/file.c
> @@ -139,7 +139,9 @@ const struct file_operations hpfs_file_ops =
>  	.release	= hpfs_file_release,
>  	.fsync		= hpfs_file_fsync,
>  	.splice_read	= generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations hpfs_file_iops =
> diff --git a/fs/hppfs/hppfs.c b/fs/hppfs/hppfs.c
> index e3c3bd3..1482113 100644
> --- a/fs/hppfs/hppfs.c
> +++ b/fs/hppfs/hppfs.c
> @@ -546,7 +546,9 @@ static const struct file_operations hppfs_file_fops = {
>  	.read		= hppfs_read,
>  	.write		= hppfs_write,
>  	.open		= hppfs_open,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  struct hppfs_dirent {
> @@ -598,7 +600,9 @@ static const struct file_operations hppfs_dir_fops = {
>  	.readdir	= hppfs_readdir,
>  	.open		= hppfs_dir_open,
>  	.fsync		= hppfs_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static int hppfs_statfs(struct dentry *dentry, struct kstatfs *sf)
> diff --git a/fs/isofs/dir.c b/fs/isofs/dir.c
> index 848059d..b0ea24a 100644
> --- a/fs/isofs/dir.c
> +++ b/fs/isofs/dir.c
> @@ -273,7 +273,9 @@ const struct file_operations isofs_dir_operations =
>  {
>  	.read = generic_read_dir,
>  	.readdir = isofs_readdir,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  /*
> diff --git a/fs/jffs2/dir.c b/fs/jffs2/dir.c
> index c7c4dcb..482e34a 100644
> --- a/fs/jffs2/dir.c
> +++ b/fs/jffs2/dir.c
> @@ -41,7 +41,9 @@ const struct file_operations jffs2_dir_operations =
>  	.unlocked_ioctl=jffs2_ioctl,
>  	.fsync =	jffs2_fsync,
>  	.llseek =	generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint =	generic_file_checkpoint,
> +#endif
>  };
> 
> 
> diff --git a/fs/jffs2/file.c b/fs/jffs2/file.c
> index f01038d..fb1e45b 100644
> --- a/fs/jffs2/file.c
> +++ b/fs/jffs2/file.c
> @@ -50,7 +50,9 @@ const struct file_operations jffs2_file_operations =
>  	.mmap =		generic_file_readonly_mmap,
>  	.fsync =	jffs2_fsync,
>  	.splice_read =	generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint =	generic_file_checkpoint,
> +#endif
>  };
> 
>  /* jffs2_file_inode_operations */
> diff --git a/fs/jfs/file.c b/fs/jfs/file.c
> index 3bd7114..71e7281 100644
> --- a/fs/jfs/file.c
> +++ b/fs/jfs/file.c
> @@ -116,5 +116,7 @@ const struct file_operations jfs_file_operations = {
>  #ifdef CONFIG_COMPAT
>  	.compat_ioctl	= jfs_compat_ioctl,
>  #endif
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/jfs/namei.c b/fs/jfs/namei.c
> index 585a7d2..9a99a97 100644
> --- a/fs/jfs/namei.c
> +++ b/fs/jfs/namei.c
> @@ -1556,7 +1556,9 @@ const struct file_operations jfs_dir_operations = {
>  	.compat_ioctl	= jfs_compat_ioctl,
>  #endif
>  	.llseek		= generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static int jfs_ci_hash(struct dentry *dir, struct qstr *this)
> diff --git a/fs/minix/dir.c b/fs/minix/dir.c
> index 74b6fb4..715dd03 100644
> --- a/fs/minix/dir.c
> +++ b/fs/minix/dir.c
> @@ -23,7 +23,9 @@ const struct file_operations minix_dir_operations = {
>  	.read		= generic_read_dir,
>  	.readdir	= minix_readdir,
>  	.fsync		= simple_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static inline void dir_put_page(struct page *page)
> diff --git a/fs/minix/file.c b/fs/minix/file.c
> index 2048d09..8e8f6a9 100644
> --- a/fs/minix/file.c
> +++ b/fs/minix/file.c
> @@ -21,7 +21,9 @@ const struct file_operations minix_file_operations = {
>  	.mmap		= generic_file_mmap,
>  	.fsync		= simple_fsync,
>  	.splice_read	= generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations minix_file_inode_operations = {
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 7d9d22a..765f7fb 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -63,7 +63,9 @@ const struct file_operations nfs_dir_operations = {
>  	.open		= nfs_opendir,
>  	.release	= nfs_release,
>  	.fsync		= nfs_fsync_dir,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations nfs_dir_inode_operations = {
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 4437ef9..08563a6 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -78,7 +78,9 @@ const struct file_operations nfs_file_operations = {
>  	.splice_write	= nfs_file_splice_write,
>  	.check_flags	= nfs_check_flags,
>  	.setlease	= nfs_setlease,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations nfs_file_inode_operations = {
> diff --git a/fs/nilfs2/dir.c b/fs/nilfs2/dir.c
> index 18b2171..8eaea21 100644
> --- a/fs/nilfs2/dir.c
> +++ b/fs/nilfs2/dir.c
> @@ -702,5 +702,7 @@ const struct file_operations nilfs_dir_operations = {
>  	.compat_ioctl	= nilfs_ioctl,
>  #endif	/* CONFIG_COMPAT */
>  	.fsync		= nilfs_sync_file,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
> index 4d585b5..9306d6f 100644
> --- a/fs/nilfs2/file.c
> +++ b/fs/nilfs2/file.c
> @@ -136,7 +136,6 @@ static int nilfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>   */
>  const struct file_operations nilfs_file_operations = {
>  	.llseek		= generic_file_llseek,
> -	.checkpoint	= generic_file_checkpoint,
>  	.read		= do_sync_read,
>  	.write		= do_sync_write,
>  	.aio_read	= generic_file_aio_read,
> @@ -150,6 +149,9 @@ const struct file_operations nilfs_file_operations = {
>  	/* .release	= nilfs_release_file, */
>  	.fsync		= nilfs_sync_file,
>  	.splice_read	= generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations nilfs_file_inode_operations = {
> diff --git a/fs/ntfs/dir.c b/fs/ntfs/dir.c
> index 4fe3759..32a86b1 100644
> --- a/fs/ntfs/dir.c
> +++ b/fs/ntfs/dir.c
> @@ -1572,5 +1572,7 @@ const struct file_operations ntfs_dir_ops = {
>  	/*.ioctl	= ,*/			/* Perform function on the
>  						   mounted filesystem. */
>  	.open		= ntfs_dir_open,	/* Open directory. */
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
> index 32a43f5..3d389e4 100644
> --- a/fs/ntfs/file.c
> +++ b/fs/ntfs/file.c
> @@ -2234,7 +2234,9 @@ const struct file_operations ntfs_file_ops = {
>  						    on the ntfs partition.  We
>  						    do not need to care about
>  						    the data source. */
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations ntfs_file_inode_ops = {
> diff --git a/fs/omfs/dir.c b/fs/omfs/dir.c
> index e924e33..3b08c84 100644
> --- a/fs/omfs/dir.c
> +++ b/fs/omfs/dir.c
> @@ -502,5 +502,7 @@ const struct file_operations omfs_dir_operations = {
>  	.read = generic_read_dir,
>  	.readdir = omfs_readdir,
>  	.llseek = generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/omfs/file.c b/fs/omfs/file.c
> index 83e63ef..fb5fa02 100644
> --- a/fs/omfs/file.c
> +++ b/fs/omfs/file.c
> @@ -331,7 +331,9 @@ const struct file_operations omfs_file_operations = {
>  	.mmap = generic_file_mmap,
>  	.fsync = simple_fsync,
>  	.splice_read = generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations omfs_file_inops = {
> diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
> index d1f0677..f5e4649 100644
> --- a/fs/openpromfs/inode.c
> +++ b/fs/openpromfs/inode.c
> @@ -160,7 +160,9 @@ static const struct file_operations openpromfs_prop_ops = {
>  	.read		= seq_read,
>  	.llseek		= seq_lseek,
>  	.release	= seq_release,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= NULL,
> +#endif
>  };
> 
>  static int openpromfs_readdir(struct file *, void *, filldir_t);
> @@ -169,7 +171,9 @@ static const struct file_operations openprom_operations = {
>  	.read		= generic_read_dir,
>  	.readdir	= openpromfs_readdir,
>  	.llseek		= generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static struct dentry *openpromfs_lookup(struct inode *, struct dentry *, struct nameidata *);
> diff --git a/fs/pipe.c b/fs/pipe.c
> index 8c79493..7f00e58 100644
> --- a/fs/pipe.c
> +++ b/fs/pipe.c
> @@ -1056,9 +1056,6 @@ struct file *fifo_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
> 
>  	return file;
>  }
> -#else
> -#define pipe_file_checkpoint  NULL
> -#define fifo_file_checkpoint  NULL
>  #endif /* CONFIG_CHECKPOINT */
> 
>  /*
> @@ -1077,7 +1074,9 @@ const struct file_operations read_pipefifo_fops = {
>  	.open		= pipe_read_open,
>  	.release	= pipe_read_release,
>  	.fasync		= pipe_read_fasync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= pipe_file_checkpoint,
> +#endif
>  };
> 
>  const struct file_operations write_pipefifo_fops = {
> @@ -1090,7 +1089,9 @@ const struct file_operations write_pipefifo_fops = {
>  	.open		= pipe_write_open,
>  	.release	= pipe_write_release,
>  	.fasync		= pipe_write_fasync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= pipe_file_checkpoint,
> +#endif
>  };
> 
>  const struct file_operations rdwr_pipefifo_fops = {
> @@ -1104,7 +1105,9 @@ const struct file_operations rdwr_pipefifo_fops = {
>  	.open		= pipe_rdwr_open,
>  	.release	= pipe_rdwr_release,
>  	.fasync		= pipe_rdwr_fasync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= pipe_file_checkpoint,
> +#endif
>  };
> 
>  struct pipe_inode_info * alloc_pipe_info(struct inode *inode)
> diff --git a/fs/qnx4/dir.c b/fs/qnx4/dir.c
> index fa14c55..3414bf8 100644
> --- a/fs/qnx4/dir.c
> +++ b/fs/qnx4/dir.c
> @@ -80,7 +80,9 @@ const struct file_operations qnx4_dir_operations =
>  	.read		= generic_read_dir,
>  	.readdir	= qnx4_readdir,
>  	.fsync		= simple_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations qnx4_dir_inode_operations =
> diff --git a/fs/ramfs/file-mmu.c b/fs/ramfs/file-mmu.c
> index 4430239..34dc7f2 100644
> --- a/fs/ramfs/file-mmu.c
> +++ b/fs/ramfs/file-mmu.c
> @@ -47,7 +47,9 @@ const struct file_operations ramfs_file_operations = {
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
>  	.llseek		= generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations ramfs_file_inode_operations = {
> diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
> index 9cd6208..208f592 100644
> --- a/fs/ramfs/file-nommu.c
> +++ b/fs/ramfs/file-nommu.c
> @@ -45,7 +45,9 @@ const struct file_operations ramfs_file_operations = {
>  	.splice_read		= generic_file_splice_read,
>  	.splice_write		= generic_file_splice_write,
>  	.llseek			= generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint		= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations ramfs_file_inode_operations = {
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 65371e1..8d8c6de 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -27,7 +27,9 @@ const struct file_operations generic_ro_fops = {
>  	.aio_read	= generic_file_aio_read,
>  	.mmap		= generic_file_readonly_mmap,
>  	.splice_read	= generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  EXPORT_SYMBOL(generic_ro_fops);
> diff --git a/fs/reiserfs/dir.c b/fs/reiserfs/dir.c
> index 8681419..76be931 100644
> --- a/fs/reiserfs/dir.c
> +++ b/fs/reiserfs/dir.c
> @@ -24,7 +24,9 @@ const struct file_operations reiserfs_dir_operations = {
>  #ifdef CONFIG_COMPAT
>  	.compat_ioctl = reiserfs_compat_ioctl,
>  #endif
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  static int reiserfs_dir_fsync(struct file *filp, struct dentry *dentry,
> diff --git a/fs/reiserfs/file.c b/fs/reiserfs/file.c
> index b6008f3..3073dec 100644
> --- a/fs/reiserfs/file.c
> +++ b/fs/reiserfs/file.c
> @@ -297,7 +297,9 @@ const struct file_operations reiserfs_file_operations = {
>  	.splice_read = generic_file_splice_read,
>  	.splice_write = generic_file_splice_write,
>  	.llseek = generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations reiserfs_file_inode_operations = {
> diff --git a/fs/romfs/mmap-nommu.c b/fs/romfs/mmap-nommu.c
> index 03c24d9..f488a8a 100644
> --- a/fs/romfs/mmap-nommu.c
> +++ b/fs/romfs/mmap-nommu.c
> @@ -72,5 +72,7 @@ const struct file_operations romfs_ro_fops = {
>  	.splice_read		= generic_file_splice_read,
>  	.mmap			= romfs_mmap,
>  	.get_unmapped_area	= romfs_get_unmapped_area,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint		= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/romfs/super.c b/fs/romfs/super.c
> index 476ea8e..6a07e29 100644
> --- a/fs/romfs/super.c
> +++ b/fs/romfs/super.c
> @@ -282,7 +282,9 @@ error:
>  static const struct file_operations romfs_dir_operations = {
>  	.read		= generic_read_dir,
>  	.readdir	= romfs_readdir,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static const struct inode_operations romfs_dir_inode_operations = {
> diff --git a/fs/squashfs/dir.c b/fs/squashfs/dir.c
> index b0c5336..69d04f9 100644
> --- a/fs/squashfs/dir.c
> +++ b/fs/squashfs/dir.c
> @@ -232,5 +232,7 @@ failed_read:
>  const struct file_operations squashfs_dir_ops = {
>  	.read = generic_read_dir,
>  	.readdir = squashfs_readdir,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/sysv/dir.c b/fs/sysv/dir.c
> index 53acd29..e1030d4 100644
> --- a/fs/sysv/dir.c
> +++ b/fs/sysv/dir.c
> @@ -25,7 +25,9 @@ const struct file_operations sysv_dir_operations = {
>  	.read		= generic_read_dir,
>  	.readdir	= sysv_readdir,
>  	.fsync		= simple_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static inline void dir_put_page(struct page *page)
> diff --git a/fs/sysv/file.c b/fs/sysv/file.c
> index aee556d..78b7e65 100644
> --- a/fs/sysv/file.c
> +++ b/fs/sysv/file.c
> @@ -28,7 +28,9 @@ const struct file_operations sysv_file_operations = {
>  	.mmap		= generic_file_mmap,
>  	.fsync		= simple_fsync,
>  	.splice_read	= generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations sysv_file_inode_operations = {
> diff --git a/fs/ubifs/debug.c b/fs/ubifs/debug.c
> index e4f23c6..b3936e8 100644
> --- a/fs/ubifs/debug.c
> +++ b/fs/ubifs/debug.c
> @@ -2623,8 +2623,10 @@ static ssize_t write_debugfs_file(struct file *file, const char __user *buf,
>  static const struct file_operations dfs_fops = {
>  	.open = open_debugfs_file,
>  	.write = write_debugfs_file,
> -	.checkpoint = generic_file_checkpoint,
>  	.owner = THIS_MODULE,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint = generic_file_checkpoint,
> +#endif
>  };
> 
>  /**
> diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
> index 89ab2aa..eb43e87 100644
> --- a/fs/ubifs/dir.c
> +++ b/fs/ubifs/dir.c
> @@ -1228,5 +1228,7 @@ const struct file_operations ubifs_dir_operations = {
>  #ifdef CONFIG_COMPAT
>  	.compat_ioctl   = ubifs_compat_ioctl,
>  #endif
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint     = generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
> index 254a4d9..dea0d6c 100644
> --- a/fs/ubifs/file.c
> +++ b/fs/ubifs/file.c
> @@ -1582,5 +1582,7 @@ const struct file_operations ubifs_file_operations = {
>  #ifdef CONFIG_COMPAT
>  	.compat_ioctl   = ubifs_compat_ioctl,
>  #endif
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint     = generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/udf/dir.c b/fs/udf/dir.c
> index 6586dbe..27e6229 100644
> --- a/fs/udf/dir.c
> +++ b/fs/udf/dir.c
> @@ -211,5 +211,7 @@ const struct file_operations udf_dir_operations = {
>  	.readdir		= udf_readdir,
>  	.ioctl			= udf_ioctl,
>  	.fsync			= simple_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint		= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/udf/file.c b/fs/udf/file.c
> index e671552..cbdf2a0 100644
> --- a/fs/udf/file.c
> +++ b/fs/udf/file.c
> @@ -215,7 +215,9 @@ const struct file_operations udf_file_operations = {
>  	.fsync			= simple_fsync,
>  	.splice_read		= generic_file_splice_read,
>  	.llseek			= generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint		= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct inode_operations udf_file_inode_operations = {
> diff --git a/fs/ufs/dir.c b/fs/ufs/dir.c
> index 29c9396..c0af8f6 100644
> --- a/fs/ufs/dir.c
> +++ b/fs/ufs/dir.c
> @@ -668,5 +668,7 @@ const struct file_operations ufs_dir_operations = {
>  	.readdir	= ufs_readdir,
>  	.fsync		= simple_fsync,
>  	.llseek		= generic_file_llseek,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/ufs/file.c b/fs/ufs/file.c
> index 15c8616..35d5efe 100644
> --- a/fs/ufs/file.c
> +++ b/fs/ufs/file.c
> @@ -43,5 +43,7 @@ const struct file_operations ufs_file_operations = {
>  	.open           = generic_file_open,
>  	.fsync		= simple_fsync,
>  	.splice_read	= generic_file_splice_read,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> diff --git a/fs/xfs/linux-2.6/xfs_file.c b/fs/xfs/linux-2.6/xfs_file.c
> index 926f377..94cf9b8 100644
> --- a/fs/xfs/linux-2.6/xfs_file.c
> +++ b/fs/xfs/linux-2.6/xfs_file.c
> @@ -259,7 +259,9 @@ const struct file_operations xfs_file_operations = {
>  #ifdef HAVE_FOP_OPEN_EXEC
>  	.open_exec	= xfs_file_open_exec,
>  #endif
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  const struct file_operations xfs_dir_file_operations = {
> @@ -272,7 +274,9 @@ const struct file_operations xfs_dir_file_operations = {
>  	.compat_ioctl	= xfs_file_compat_ioctl,
>  #endif
>  	.fsync		= xfs_file_fsync,
> +#ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
> +#endif
>  };
> 
>  static const struct vm_operations_struct xfs_file_vm_ops = {
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index a1525aa..c7f2427 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1513,8 +1513,10 @@ struct file_operations {
>  	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
>  	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
>  	int (*setlease)(struct file *, long, struct file_lock **);
> +#ifdef CONFIG_CHECKPOINT
>  	int (*checkpoint)(struct ckpt_ctx *, struct file *);
>  	int (*collect)(struct ckpt_ctx *, struct file *);
> +#endif
>  };
> 
>  struct inode_operations {
> @@ -2330,8 +2332,6 @@ void inode_set_bytes(struct inode *inode, loff_t bytes);
> 
>  #ifdef CONFIG_CHECKPOINT
>  extern int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
> -#else
> -#define generic_file_checkpoint NULL
>  #endif
> 
>  extern int vfs_readdir(struct file *, filldir_t, void *);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 4ea28e6..bc98a15 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1678,8 +1678,6 @@ int filemap_restore(struct ckpt_ctx *ctx,
>  	}
>  	return ret;
>  }
> -#else /* !CONFIG_CHECKPOINT */
> -#define filemap_checkpoint NULL
>  #endif
> 
>  const struct vm_operations_struct generic_file_vm_ops = {
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 0e8ef05..7d41cd2 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2423,8 +2423,6 @@ int special_mapping_restore(struct ckpt_ctx *ctx,
> 
>  	return ret;
>  }
> -#else /* !CONFIG_CHECKPOINT */
> -#define special_mapping_checkpoint NULL
>  #endif
> 
>  static const struct vm_operations_struct special_mapping_vmops = {
> -- 
> 1.6.1
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
