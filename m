From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Fix build break when CONFIG_CHECKPOINT=n
Date: Wed, 29 Sep 2010 19:19:05 -0400
Message-ID: <4CA3C969.7080106@cs.columbia.edu>
References: <1285260484-17134-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1285260484-17134-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Applied to ckpt-v22-dev - thanks.

Oren.

On 09/23/2010 12:48 PM, Dan Smith wrote:
> This was introduced in my sem_undo patch.  Oops.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  ipc/sem.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/ipc/sem.c b/ipc/sem.c
> index 9e3e463..2e54c21 100644
> --- a/ipc/sem.c
> +++ b/ipc/sem.c
> @@ -1478,6 +1478,7 @@ static int sysvipc_sem_proc_show(struct seq_file *s, void *it)
>  }
>  #endif
>  
> +#ifdef CONFIG_CHECKPOINT
>  static int __get_semids(struct sem_undo_list *ulp, int *semids, int max)
>  {
>  	int count = 0;
> @@ -1786,6 +1787,7 @@ static const struct ckpt_obj_ops ckpt_obj_sem_undo_ops = {
>  	.checkpoint = checkpoint_sem_undo,
>  	.restore = restore_sem_undo,
>  };
> +#endif
>  
>  void __init sem_init (void)
>  {
> @@ -1794,9 +1796,11 @@ void __init sem_init (void)
>  				"       key      semid perms      nsems   uid   gid  cuid  cgid      otime      ctime\n",
>  				IPC_SEM_IDS, sysvipc_sem_proc_show);
>  
> +#ifdef CONFIG_CHECKPOINT
>  	/* sem_undo_list uses a short but we write a __s16 */
>  	CKPT_BUILD_BUG_ON_MISMATCH(*CKPT_STRUCT_MEMBER(sem_undo, semadj),
>  				   __s16);
>  
>  	register_checkpoint_obj(&ckpt_obj_sem_undo_ops);
> +#endif
>  }
