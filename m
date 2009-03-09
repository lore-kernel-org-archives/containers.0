From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 09/11] check files for checkpointability
Date: Mon, 9 Mar 2009 10:38:37 -0700
Message-ID: <20090309173837.GC7561__5757.87509228594$1236881631$gmane$org@us.ibm.com>
References: <20090305163910.5960D190@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090305163910.5960D190@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 05, 2009 at 08:39:10AM -0800, Dave Hansen wrote:
> 
> Introduce a files_struct counter to indicate whether a particular
> file_struct has ever contained a file which can not be
> checkpointed.  This flag is a one-way trip; once it is set, it may
> not be unset.
> 
> We assume at allocation that a new files_struct is clean and may
> be checkpointed.  However, as soon as it has had its files filled
> from its parent's, we check it for real in __scan_files_for_cr().
> At that point, we mark it if it contained any uncheckpointable
> files.
> 
> We also check each 'struct file' when it is installed in a fd
> slot.  This way, if anyone open()s or managed to dup() an
> unsuppored file, we can catch it.
> 
> Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
> 
>  linux-2.6.git-dave/fs/file.c                  |   19 +++++++++++++++++++
>  linux-2.6.git-dave/fs/open.c                  |    5 +++++
>  linux-2.6.git-dave/include/linux/checkpoint.h |   13 +++++++++++++
>  linux-2.6.git-dave/include/linux/fdtable.h    |    3 +++
>  4 files changed, 40 insertions(+)
> 
> diff -puN fs/file.c~242c7afafb1a81c0d9a41085536f2197d81146e7 fs/file.c
> --- linux-2.6.git/fs/file.c~242c7afafb1a81c0d9a41085536f2197d81146e7	2009-03-05 08:37:04.000000000 -0800
> +++ linux-2.6.git-dave/fs/file.c	2009-03-05 08:37:04.000000000 -0800
> @@ -15,6 +15,7 @@
>  #include <linux/file.h>
>  #include <linux/fdtable.h>
>  #include <linux/bitops.h>
> +#include <linux/checkpoint.h>
>  #include <linux/interrupt.h>
>  #include <linux/spinlock.h>
>  #include <linux/rcupdate.h>
> @@ -285,6 +286,20 @@ static int count_open_files(struct fdtab
>  	return i;
>  }
> 
> +static void __scan_files_for_cr(struct files_struct *files)
> +{
> +	int i;
> +
> +	for (i = 0; i < files->fdtab.max_fds; i++) {
> +		struct file *f = fcheck_files(files, i);
> +		if (!f)
> +			continue;
> +		if (cr_file_supported(f))
> +			continue;
> +		files_deny_checkpointing(files);

At this point couldn't we skip the rest of the loop iterations?

Might it also be useful to print a path to f here? So not only would
the log show the location in the kernel source but we'd also get some
idea of which file caused the problem? Of course "f" isn't always
available everywhere we call files_deny_checkpointing()..

> +	}
> +}
> +
>  /*
>   * Allocate a new files structure and copy contents from the
>   * passed in files structure.
> @@ -303,6 +318,9 @@ struct files_struct *dup_fd(struct files
>  		goto out;
> 
>  	atomic_set(&newf->count, 1);
> +#ifdef CONFIG_CHECKPOINT_RESTART
> +	newf->may_checkpoint = 1;
> +#endif
> 
>  	spin_lock_init(&newf->file_lock);
>  	newf->next_fd = 0;
> @@ -396,6 +414,7 @@ struct files_struct *dup_fd(struct files
> 
>  	rcu_assign_pointer(newf->fdt, new_fdt);
> 
> +	__scan_files_for_cr(newf);
>  	return newf;
> 
>  out_release:
> diff -puN fs/open.c~242c7afafb1a81c0d9a41085536f2197d81146e7 fs/open.c
> --- linux-2.6.git/fs/open.c~242c7afafb1a81c0d9a41085536f2197d81146e7	2009-03-05 08:37:04.000000000 -0800
> +++ linux-2.6.git-dave/fs/open.c	2009-03-05 08:37:04.000000000 -0800
> @@ -29,6 +29,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/audit.h>
>  #include <linux/falloc.h>
> +#include <linux/checkpoint.h>
> 
>  int vfs_statfs(struct dentry *dentry, struct kstatfs *buf)
>  {
> @@ -1015,6 +1016,10 @@ void fd_install(unsigned int fd, struct 
>  {
>  	struct files_struct *files = current->files;
>  	struct fdtable *fdt;
> +
> +	if (!cr_file_supported(file))
> +		files_deny_checkpointing(files);
> +
>  	spin_lock(&files->file_lock);
>  	fdt = files_fdtable(files);
>  	BUG_ON(fdt->fd[fd] != NULL);
> diff -puN include/linux/checkpoint.h~242c7afafb1a81c0d9a41085536f2197d81146e7 include/linux/checkpoint.h
> --- linux-2.6.git/include/linux/checkpoint.h~242c7afafb1a81c0d9a41085536f2197d81146e7	2009-03-05 08:37:04.000000000 -0800
> +++ linux-2.6.git-dave/include/linux/checkpoint.h	2009-03-05 08:37:04.000000000 -0800
> @@ -12,6 +12,7 @@
> 
>  #include <linux/path.h>
>  #include <linux/fs.h>
> +#include <linux/fdtable.h>
> 
>  #ifdef CONFIG_CHECKPOINT_RESTART
> 
> @@ -101,11 +102,23 @@ extern int cr_read_files(struct cr_ctx *
> 
>  #define pr_fmt(fmt) "[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__
> 
> +static inline void __files_deny_checkpointing(struct files_struct *files,
> +		char *file, int line)
> +{
> +	if (!test_and_clear_bit(0, &files->may_checkpoint))
> +		return;
> +	printk(KERN_INFO "process performed an action that can not be "
> +			"checkpointed at: %s:%d\n", file, line);
> +}
> +#define files_deny_checkpointing(f)  \
> +	__files_deny_checkpointing(f, __FILE__, __LINE__)
> +

<snip>
