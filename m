From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 25/43] userns: Store uid and gid types in vfs
	structures with kuid_t and kgid_t types
Date: Wed, 18 Apr 2012 18:57:17 +0000
Message-ID: <20120418185717.GB5186__23743.0977439091$1334775400$gmane$org@mail.hallyn.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-25-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333862139-31737-25-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Beiderman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> The conversion of all of the users is not done yet there are too many to change
> in one go and leave the code reviewable. For now I change just the header and
> a few trivial users and rely on CONFIG_UIDGID_STRICT_TYPE_CHECKS not being set
> to ensure that the code will still compile during the transition.
> 
> Helper functions i_uid_read, i_uid_write, i_gid_read, i_gid_write are added
> so that in most cases filesystems can avoid the complexities of multiple user
> namespaces and can concentrate on moving their raw numeric values into and
> out of the vfs data structures.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> ---
>  fs/inode.c         |    6 +++---
>  include/linux/fs.h |   36 +++++++++++++++++++++++++++++++-----
>  2 files changed, 34 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index f0c4ace..deb72f6 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -135,8 +135,8 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
>  	inode->i_fop = &empty_fops;
>  	inode->__i_nlink = 1;
>  	inode->i_opflags = 0;
> -	inode->i_uid = 0;
> -	inode->i_gid = 0;
> +	i_uid_write(inode, 0);
> +	i_gid_write(inode, 0);
>  	atomic_set(&inode->i_writecount, 0);
>  	inode->i_size = 0;
>  	inode->i_blocks = 0;
> @@ -1732,7 +1732,7 @@ EXPORT_SYMBOL(inode_init_owner);
>   */
>  bool inode_owner_or_capable(const struct inode *inode)
>  {
> -	if (current_fsuid() == inode->i_uid)
> +	if (uid_eq(current_fsuid(), inode->i_uid))
>  		return true;
>  	if (inode_capable(inode, CAP_FOWNER))
>  		return true;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index a6c5efb..797eb26 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -402,6 +402,7 @@ struct inodes_stat_t {
>  #include <linux/atomic.h>
>  #include <linux/shrinker.h>
>  #include <linux/migrate_mode.h>
> +#include <linux/uidgid.h>
>  
>  #include <asm/byteorder.h>
>  
> @@ -469,8 +470,8 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
>  struct iattr {
>  	unsigned int	ia_valid;
>  	umode_t		ia_mode;
> -	uid_t		ia_uid;
> -	gid_t		ia_gid;
> +	kuid_t		ia_uid;
> +	kgid_t		ia_gid;
>  	loff_t		ia_size;
>  	struct timespec	ia_atime;
>  	struct timespec	ia_mtime;
> @@ -761,8 +762,8 @@ struct posix_acl;
>  struct inode {
>  	umode_t			i_mode;
>  	unsigned short		i_opflags;
> -	uid_t			i_uid;
> -	gid_t			i_gid;
> +	kuid_t			i_uid;
> +	kgid_t			i_gid;
>  	unsigned int		i_flags;
>  
>  #ifdef CONFIG_FS_POSIX_ACL
> @@ -927,6 +928,31 @@ static inline void i_size_write(struct inode *inode, loff_t i_size)
>  #endif
>  }
>  
> +/* Helper functions so that in most cases filesystems will
> + * not need to deal directly with kuid_t and kgid_t and can
> + * instead deal with the raw numeric values that are stored
> + * in the filesystem.
> + */
> +static inline uid_t i_uid_read(const struct inode *inode)
> +{
> +	return from_kuid(&init_user_ns, inode->i_uid);
> +}
> +
> +static inline gid_t i_gid_read(const struct inode *inode)
> +{
> +	return from_kgid(&init_user_ns, inode->i_gid);
> +}
> +
> +static inline void i_uid_write(struct inode *inode, uid_t uid)
> +{
> +	inode->i_uid = make_kuid(&init_user_ns, uid);
> +}
> +
> +static inline void i_gid_write(struct inode *inode, gid_t gid)
> +{
> +	inode->i_gid = make_kgid(&init_user_ns, gid);
> +}
> +
>  static inline unsigned iminor(const struct inode *inode)
>  {
>  	return MINOR(inode->i_rdev);
> @@ -943,7 +969,7 @@ struct fown_struct {
>  	rwlock_t lock;          /* protects pid, uid, euid fields */
>  	struct pid *pid;	/* pid or -pgrp where SIGIO should be sent */
>  	enum pid_type pid_type;	/* Kind of process group SIGIO should be sent to */
> -	uid_t uid, euid;	/* uid/euid of process setting the owner */
> +	kuid_t uid, euid;	/* uid/euid of process setting the owner */
>  	int signum;		/* posix.1b rt signal to be delivered on IO */
>  };
>  
> -- 
> 1.7.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
