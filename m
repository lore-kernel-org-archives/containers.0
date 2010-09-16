From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/3] nit: Spelling fix
Date: Thu, 16 Sep 2010 09:55:32 -0400
Message-ID: <4C9221D4.2090008@cs.columbia.edu>
References: <c6fe338914cc217649cf15e9b518027420342e44.1281234417.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c6fe338914cc217649cf15e9b518027420342e44.1281234417.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


All three taken for ckpt-v22-dev.

Oren.

On 08/07/2010 10:27 PM, Matt Helsley wrote:
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint_types.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> index ceaa671..cb4beac 100644
> --- a/include/linux/checkpoint_types.h
> +++ b/include/linux/checkpoint_types.h
> @@ -41,7 +41,7 @@ struct ckpt_ctx {
>  	struct task_struct *root_freezer;	/* [container] root task */
>  	char lsm_name[SECURITY_NAME_MAX + 1];   /* security module at ckpt */
>  
> -	unsigned long kflags;	/* kerenl flags */
> +	unsigned long kflags;	/* kernel flags */
>  	unsigned long uflags;	/* user flags */
>  	unsigned long oflags;	/* restart: uflags from checkpoint */
>  
