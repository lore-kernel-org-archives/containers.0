From: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [C/R v20][PATCH 37/96] c/r: introduce new 'file_operations':
	->checkpoint, ->collect()
Date: Mon, 22 Mar 2010 17:34:28 +1100
Message-ID: <20100322063428.GE17637__27067.5134067007$1269239798$gmane$org@laptop>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-3-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1268960401-16680-3-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 18, 2010 at 08:59:46PM -0400, Oren Laadan wrote:
> While we assume all normal files and directories can be checkpointed,
> there are, as usual in the VFS, specialized places that will always
> need an ability to override these defaults. Although we could do this
> completely in the checkpoint code, that would bitrot quickly.
> 
> This adds a new 'file_operations' function for checkpointing a file.
> It is assumed that there should be a dirt-simple way to make something
> (un)checkpointable that fits in with current code.
> 
> As you can see in the ext[234] patches down the road, all that we have
> to do to make something simple be supported is add a single "generic"
> f_op entry.
> 
> Also adds a new 'file_operations' function for 'collecting' a file for
> leak-detection during full-container checkpoint. This is useful for
> those files that hold references to other "collectable" objects. Two
> examples are pty files that point to corresponding tty objects, and
> eventpoll files that refer to the files they are monitoring.
> 
> Finally, this patch introduces vfs_fcntl() so that it can be called
> from restart (see patch adding restart of files).
> 
> Changelog[v17]
>   - Introduce 'collect' method
> Changelog[v17]
>   - Forward-declare 'ckpt_ctx' et-al, don't use checkpoint_types.h
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/fcntl.c         |   21 +++++++++++++--------
>  include/linux/fs.h |    7 +++++++
>  2 files changed, 20 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/fcntl.c b/fs/fcntl.c
> index 97e01dc..e1f02ca 100644
> --- a/fs/fcntl.c
> +++ b/fs/fcntl.c
> @@ -418,6 +418,18 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
>  	return err;
>  }
>  
> +int vfs_fcntl(int fd, unsigned int cmd, unsigned long arg, struct file *filp)
> +{
> +	int err;
> +
> +	err = security_file_fcntl(filp, cmd, arg);
> +	if (err)
> +		goto out;
> +	err = do_fcntl(fd, cmd, arg, filp);
> + out:
> +	return err;
> +}
> +
>  SYSCALL_DEFINE3(fcntl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
>  {	
>  	struct file *filp;
> @@ -427,14 +439,7 @@ SYSCALL_DEFINE3(fcntl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
>  	if (!filp)
>  		goto out;
>  
> -	err = security_file_fcntl(filp, cmd, arg);
> -	if (err) {
> -		fput(filp);
> -		return err;
> -	}
> -
> -	err = do_fcntl(fd, cmd, arg, filp);
> -
> +	err = vfs_fcntl(fd, cmd, arg, filp);
>   	fput(filp);
>  out:
>  	return err;

There is no point combining these two logically distinct patches.


> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 6c08df2..65ebec5 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -394,6 +394,7 @@ struct kstatfs;
>  struct vm_area_struct;
>  struct vfsmount;
>  struct cred;
> +struct ckpt_ctx;
>  
>  extern void __init inode_init(void);
>  extern void __init inode_init_early(void);
> @@ -1093,6 +1094,8 @@ struct file_lock {
>  
>  #include <linux/fcntl.h>
>  
> +extern int vfs_fcntl(int fd, unsigned cmd, unsigned long arg, struct file *fp);
> +
>  extern void send_sigio(struct fown_struct *fown, int fd, int band);
>  
>  #ifdef CONFIG_FILE_LOCKING
> @@ -1504,6 +1507,8 @@ struct file_operations {
>  	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
>  	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
>  	int (*setlease)(struct file *, long, struct file_lock **);
> +	int (*checkpoint)(struct ckpt_ctx *, struct file *);
> +	int (*collect)(struct ckpt_ctx *, struct file *);
>  };
>  
>  struct inode_operations {

You didn't add any documentation for this (unless it is in a following
patch, which it shouldn't be).

> @@ -2313,6 +2318,8 @@ void inode_sub_bytes(struct inode *inode, loff_t bytes);
>  loff_t inode_get_bytes(struct inode *inode);
>  void inode_set_bytes(struct inode *inode, loff_t bytes);
>  
> +#define generic_file_checkpoint NULL
> +
>  extern int vfs_readdir(struct file *, filldir_t, void *);
>  
>  extern int vfs_stat(char __user *, struct kstat *);

Hmm, what does generic_file_checkpoint mean? A NULL checkpoint op means
that checkpointing is allowed, and no action is required? Shouldn't it
be an opt-in operation, where NULL means not allowed?

Either way, I don't know if you need to have this #define, provided you
have sufficient documentation.
