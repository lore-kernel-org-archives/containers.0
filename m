From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/1] fix compile with CONFIG_CHECKPOINT_DEBUG=n
Date: Fri, 23 Oct 2009 14:52:55 -0400
Message-ID: <4AE1FB87.4050305@librato.com>
References: <20091022143238.GA31778@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091022143238.GA31778-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Serge E. Hallyn wrote:
> On the one hand, compiling without checkpoing debug saves a
> lot of kernel size:
> 
> with debug:
> -rwxrwxr-x  1 hallyn hallyn  62391508 Oct 21 22:08 vmlinux
> without debug:
> -rwxrwxr-x  1 hallyn hallyn  62298077 Oct 21 22:33 vmlinux
> 
> OTOH the need for this patch just proves my point that we don't
> want any more config options than we need (especially no
> CONFIG_CHECKPOINT_LOGGING in addition to _DEBUG).
> 
> So that begs the question - is there something we can do to
> avoid having to recompile the kernel to turn on debugging,
> but not take up 100k of space in vmlinux?  Maybe get rid of
> the ckpt_debugs altogether and instead provide pre-written
> kprobe sets to turn on debugging at specific places?

What is the reason for the increase - the strings ? the extra
inlined code ?  the passing of variables to printed ?

Turning on/off code at specific place requires that the code
still be there ...

do you intend to add a crdebug.ko module  hat will hold all
that code ?   (if so, you still need to pass the variables).

> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Meanwhile - pulled, thanks.

Oren

> ---
>  checkpoint/restart.c |   23 +++++++++++++----------
>  1 files changed, 13 insertions(+), 10 deletions(-)
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 32a9fc5..105dd0a 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -26,6 +26,15 @@
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
>  
> +#define RESTART_DBG_ROOT	(1 << 0)
> +#define RESTART_DBG_GHOST	(1 << 1)
> +#define RESTART_DBG_COORD	(1 << 2)
> +#define RESTART_DBG_TASK	(1 << 3)
> +#define RESTART_DBG_WAITING	(1 << 4)
> +#define RESTART_DBG_RUNNING	(1 << 5)
> +#define RESTART_DBG_EXITED	(1 << 6)
> +#define RESTART_DBG_FAILED	(1 << 7)
> +#define RESTART_DBG_SUCCESS	(1 << 8)
>  
>  #ifdef CONFIG_CHECKPOINT_DEBUG
>  
> @@ -44,15 +53,6 @@
>  
>  struct ckpt_task_status {
>  	pid_t pid;
> -#define RESTART_DBG_ROOT	(1 << 0)
> -#define RESTART_DBG_GHOST	(1 << 1)
> -#define RESTART_DBG_COORD	(1 << 2)
> -#define RESTART_DBG_TASK	(1 << 3)
> -#define RESTART_DBG_WAITING	(1 << 4)
> -#define RESTART_DBG_RUNNING	(1 << 5)
> -#define RESTART_DBG_EXITED	(1 << 6)
> -#define RESTART_DBG_FAILED	(1 << 7)
> -#define RESTART_DBG_SUCCESS	(1 << 8)
>  	int flags;
>  	int error;
>  	struct list_head list;
> @@ -178,7 +178,10 @@ void restore_debug_free(struct ckpt_ctx *ctx)
>  
>  #else
>  
> -static inline void restore_debug_task(struct ckpt_ctx *ctx, int flags) {}
> +static inline int restore_debug_task(struct ckpt_ctx *ctx, int flags)
> +{
> +	return 0;
> +}
>  static inline void restore_debug_error(struct ckpt_ctx *ctx, int err) {}
>  static inline void restore_debug_running(struct ckpt_ctx *ctx) {}
>  static inline void restore_debug_exit(struct ckpt_ctx *ctx) {}
