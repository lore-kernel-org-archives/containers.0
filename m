From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: sysvipc: don't break compilation
	with	CONFIG_SYSVIPC=n
Date: Fri, 29 May 2009 06:20:42 -0400
Message-ID: <4A1FB6FA.3060805@cs.columbia.edu>
References: <20090528195923.GA24595@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090528195923.GA24595-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Thanks.

Applied on ckpt-v16-dev.


Serge E. Hallyn wrote:
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint.h |    2 +-
>  include/linux/shm.h        |    2 +-
>  init/Kconfig               |    6 ++++++
>  ipc/Makefile               |    2 +-
>  4 files changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 0c03ac7..812a444 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -95,7 +95,7 @@ extern int restore_ipc_ns(struct ckpt_ctx *ctx, int ns_objref, int flags);
>  static inline int checkpoint_ipc_ns(struct ckpt_ctx *ctx,
>  				    struct ipc_namespace *ipc_ns)
>  { return 0; }
> -static inline int restore_ipc_ns(struct ckpt_ctx *ctx)
> +static inline int restore_ipc_ns(struct ckpt_ctx *ctx, int ns_objref, int flags)
>  { return 0; }
>  #endif /* CONFIG_SYSVIPC */
>  
> diff --git a/include/linux/shm.h b/include/linux/shm.h
> index 97972eb..6edc26e 100644
> --- a/include/linux/shm.h
> +++ b/include/linux/shm.h
> @@ -127,7 +127,7 @@ extern int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
>  extern int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
>  			  struct ckpt_hdr_vma *h);
>  #else
> -define ipcshm_restart NULL
> +#define ipcshm_restore NULL
>  #endif
>  #endif
>  
> diff --git a/init/Kconfig b/init/Kconfig
> index adb4260..3befc07 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -186,6 +186,12 @@ config SYSVIPC
>  	  section 6.4 of the Linux Programmer's Guide, available from
>  	  <http://www.tldp.org/guides.html>.
>  
> +config SYSVIPC_CHECKPOINT
> +	bool
> +	depends on SYSVIPC
> +	depends on CHECKPOINT
> +	default y
> +
>  config SYSVIPC_SYSCTL
>  	bool
>  	depends on SYSVIPC
> diff --git a/ipc/Makefile b/ipc/Makefile
> index 81af168..6d4c92e 100644
> --- a/ipc/Makefile
> +++ b/ipc/Makefile
> @@ -9,6 +9,6 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
>  obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
>  obj-$(CONFIG_IPC_NS) += namespace.o
>  obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
> -obj-$(CONFIG_CHECKPOINT) += checkpoint.o \
> +obj-$(CONFIG_SYSVIPC_CHECKPOINT) += checkpoint.o \
>  			checkpoint_shm.o checkpoint_msg.o checkpoint_sem.o
>  
