From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] dcache: extrace and use d_unlinked()
Date: Fri, 8 May 2009 14:28:00 -0500
Message-ID: <20090508192800.GC28885__16328.5607741729$1241811044$gmane$org@us.ibm.com>
References: <20090503233203.GK16631@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090503233203.GK16631-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> d_unlinked() will be used in middle-term to ban checkpointing when opened
> but unlinked file is detected, and in long term, to detect such situation
> and special case on it.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Well I see no errors.

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Though is it just me, or  do d_unhashed and d_unlinked seem too close to
not end up getting confused at some point?

-serge

> ---
>  fs/dcache.c            |    7 +++----
>  fs/namespace.c         |    8 ++++----
>  include/linux/dcache.h |    5 +++++
>  3 files changed, 12 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 1fcffeb..86cb34f 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1910,7 +1910,7 @@ char *__d_path(const struct path *path, struct path *root,
> 
>  	spin_lock(&vfsmount_lock);
>  	prepend(&end, &buflen, "\0", 1);
> -	if (!IS_ROOT(dentry) && d_unhashed(dentry) &&
> +	if (d_unlinked(dentry) &&
>  		(prepend(&end, &buflen, " (deleted)", 10) != 0))
>  			goto Elong;
> 
> @@ -2035,7 +2035,7 @@ char *dentry_path(struct dentry *dentry, char *buf, int buflen)
> 
>  	spin_lock(&dcache_lock);
>  	prepend(&end, &buflen, "\0", 1);
> -	if (!IS_ROOT(dentry) && d_unhashed(dentry) &&
> +	if (d_unlinked(dentry) &&
>  		(prepend(&end, &buflen, "//deleted", 9) != 0))
>  			goto Elong;
>  	if (buflen < 1)
> @@ -2097,9 +2097,8 @@ SYSCALL_DEFINE2(getcwd, char __user *, buf, unsigned long, size)
>  	read_unlock(&current->fs->lock);
> 
>  	error = -ENOENT;
> -	/* Has the current directory has been unlinked? */
>  	spin_lock(&dcache_lock);
> -	if (IS_ROOT(pwd.dentry) || !d_unhashed(pwd.dentry)) {
> +	if (!d_unlinked(pwd.dentry)) {
>  		unsigned long len;
>  		struct path tmp = root;
>  		char * cwd;
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 4119620..b2bd687 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1417,7 +1417,7 @@ static int graft_tree(struct vfsmount *mnt, struct path *path)
>  		goto out_unlock;
> 
>  	err = -ENOENT;
> -	if (IS_ROOT(path->dentry) || !d_unhashed(path->dentry))
> +	if (!d_unlinked(path->dentry))
>  		err = attach_recursive_mnt(mnt, path, NULL);
>  out_unlock:
>  	mutex_unlock(&path->dentry->d_inode->i_mutex);
> @@ -1599,7 +1599,7 @@ static int do_move_mount(struct path *path, char *old_name)
>  	if (IS_DEADDIR(path->dentry->d_inode))
>  		goto out1;
> 
> -	if (!IS_ROOT(path->dentry) && d_unhashed(path->dentry))
> +	if (d_unlinked(path->dentry))
>  		goto out1;
> 
>  	err = -EINVAL;
> @@ -2162,9 +2162,9 @@ SYSCALL_DEFINE2(pivot_root, const char __user *, new_root,
>  	error = -ENOENT;
>  	if (IS_DEADDIR(new.dentry->d_inode))
>  		goto out2;
> -	if (d_unhashed(new.dentry) && !IS_ROOT(new.dentry))
> +	if (d_unlinked(new.dentry))
>  		goto out2;
> -	if (d_unhashed(old.dentry) && !IS_ROOT(old.dentry))
> +	if (d_unlinked(old.dentry))
>  		goto out2;
>  	error = -EBUSY;
>  	if (new.mnt == root.mnt ||
> diff --git a/include/linux/dcache.h b/include/linux/dcache.h
> index 1515636..f8488bd 100644
> --- a/include/linux/dcache.h
> +++ b/include/linux/dcache.h
> @@ -351,6 +351,11 @@ static inline int d_unhashed(struct dentry *dentry)
>  	return (dentry->d_flags & DCACHE_UNHASHED);
>  }
> 
> +static inline int d_unlinked(struct dentry *dentry)
> +{
> +	return d_unhashed(dentry) && !IS_ROOT(dentry);
> +}
> +
>  static inline struct dentry *dget_parent(struct dentry *dentry)
>  {
>  	struct dentry *ret;
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
