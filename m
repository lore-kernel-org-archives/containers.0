From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/3] Checkpoint/restart epoll sets
Date: Fri, 23 Oct 2009 19:41:48 -0400
Message-ID: <4AE23F3C.9010306@librato.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> Save/restore epoll items during checkpoint/restart respectively.
> kmalloc failures should be dealt with more kindly than just error-out
> because epoll is made to poll many thousands of file descriptors.
> Subsequent patches will change epoll c/r to "chunk" its output/input
> respectively.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

See one comment below (fixed).
Also fixed is the BUG_ON pointed out by Serge.

Oren.

> 
> Changelog:
> 
> v5:
> 	Fix potential recursion during collect.
> 	Replace call to ckpt_obj_collect() with ckpt_collect_file().
> 		[Oren]
> 	Fix checkpoint leak detection when there are more items than
> 		expected.
> 	Cleanup/simplify error write paths. (will complicate in a later
> 		patch) [Oren]
> 	Remove files_deferq bits. [Oren]
> 	Remove extra newline. [Oren]
> 	Remove aggregate check on number of watches added. [Oren]
> 		This is OK since these will be done individually anyway.
> 	Remove check for negative objrefs during restart. [Oren]
> 	Fixup comment regarding race that indicates checkpoint leaks.
> 		[Oren]
> 	s/ckpt_read_obj/ckpt_read_buf_type/ [Oren]
> 		Patch for lots of epoll items follows.
> 	Moved sys_close(epfd) right under fget(). [Oren]
> 	Use CKPT_HDR_BUFFER rather than custome ckpt_read/write_*
> 		This makes it more similar to the pid array code. [Oren]
> 		It also simplifies the error recovery paths.
> 	Tested polling a pipe and 50,000 UNIX sockets.
> 
> v4:	ckpt-v18
> 	Use files_deferq as submitted by Dan Smith
> 		Cleanup to only report >= 1 items when debugging.
> 
> v3: [unposted]
> 	Removed most of the TODOs -- the remainder will be removed by
> 		subsequent patches.
> 	Fixed missing ep_file_collect() [Serge]
> 	Rather than include checkpoint_hdr.h declare (but do not define)
> 		the two structs needed in eventpoll.h [Oren]
> 	Complain with ckpt_write_err() when we detect checkpoint obj
> 		leaks. [Oren]
> 	Remove redundant is_epoll_file() check in collect. [Oren]
> 	Move epfile_objref lookup to simplify error handling. [Oren]
> 	Simplify error handling with early return in
> 		ep_eventpoll_checkpoint(). [Oren]
> 	Cleaned up a comment. [Oren]
> 	Shorten CKPT_HDR_FILE_EPOLL_ITEMS (-FILE) [Oren]
> 		Renumbered to indicate that it follows the file table.
> 	Renamed the epoll struct in checkpoint_hdr.h [Oren]
> 		Also renamed substruct.
> 	Fixup return of empty ep_file_restore(). [Oren]
> 	Changed some error returns. [Oren]
> 	Changed some tests to BUG_ON(). [Oren]
> 	Factored out watch insert with epoll_ctl() into do_epoll_ctl().
> 		[Cedric, Oren]
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/files.c             |    8 +
>  fs/eventpoll.c                 |  308 ++++++++++++++++++++++++++++++++++++----
>  include/linux/checkpoint_hdr.h |   18 +++
>  include/linux/eventpoll.h      |   17 ++-
>  4 files changed, 322 insertions(+), 29 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index f6de07e..6ea2389 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -22,6 +22,7 @@
>  #include <linux/deferqueue.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> +#include <linux/eventpoll.h>
>  #include <net/sock.h>
>  
>  
> @@ -607,6 +608,13 @@ static struct restore_file_ops restore_file_ops[] = {
>  		.file_type = CKPT_FILE_TTY,
>  		.restore = tty_file_restore,
>  	},
> +#ifdef CONFIG_EPOLL
> +	{
> +		.file_name = "EPOLL",
> +		.file_type = CKPT_FILE_EPOLL,
> +		.restore = ep_file_restore,
> +	},
> +#endif

There must be an entry here even if CONFIG_EPOLL isn't selected. And
indeed you define ep_file_restore() for this case to return -ENOSYS
(toward the end of this patch). So I dropped the #ifdef/#endif pair.

[...]

> diff --git a/include/linux/eventpoll.h b/include/linux/eventpoll.h
> index f6856a5..34538be 100644
> --- a/include/linux/eventpoll.h
> +++ b/include/linux/eventpoll.h
> @@ -56,6 +56,9 @@ struct file;
>  
>  
>  #ifdef CONFIG_EPOLL
> +struct ckpt_ctx;
> +struct ckpt_hdr_file;
> +
>  
>  /* Used to initialize the epoll bits inside the "struct file" */
>  static inline void eventpoll_init_file(struct file *file)
> @@ -95,11 +98,23 @@ static inline void eventpoll_release(struct file *file)
>  	eventpoll_release_file(file);
>  }
>  
> -#else
>  
> +#ifdef CONFIG_CHECKPOINT
> +extern struct file* ep_file_restore(struct ckpt_ctx *ctx,
> +				    struct ckpt_hdr_file *h);
> +#endif
> +#else
> +/* !defined(CONFIG_EPOLL) */
>  static inline void eventpoll_init_file(struct file *file) {}
>  static inline void eventpoll_release(struct file *file) {}
>  
> +#ifdef CONFIG_CHECKPOINT
> +static inline struct file* ep_file_restore(struct ckpt_ctx *ctx,
> +					   struct ckpt_hdr_file *ptr)
> +{
> +	return ERR_PTR(-ENOSYS);
> +}
> +#endif
>  #endif
>  
>  #endif /* #ifdef __KERNEL__ */
