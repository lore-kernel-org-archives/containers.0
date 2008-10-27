From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 10/10] Add support for multiple processes
Date: Mon, 27 Oct 2008 11:58:04 -0400
Message-ID: <4905E50C.8020803__2972.8538859219$1225123375$gmane$org@cs.columbia.edu>
References: <1224285098-573-1-git-send-email-major@openvz.org>	<1224285098-573-2-git-send-email-major@openvz.org>	<1224285098-573-3-git-send-email-major@openvz.org>	<1224285098-573-4-git-send-email-major@openvz.org>	<1224285098-573-5-git-send-email-major@openvz.org>	<1224285098-573-6-git-send-email-major@openvz.org>	<1224285098-573-7-git-send-email-major@openvz.org>	<1224285098-573-8-git-send-email-major@openvz.org>	<1224285098-573-9-git-send-email-major@openvz.org>	<1224285098-573-10-git-send-email-major@openvz.org>
	<1224285098-573-11-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224285098-573-11-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org



Andrey Mirkin wrote:
> The whole tree of processes can be checkpointed and restarted now.
> Shared objects are not supported yet.
> 
> Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> ---
>  checkpoint/cpt_image.h   |    2 +
>  checkpoint/cpt_process.c |   24 +++++++++++++
>  checkpoint/rst_process.c |   85 +++++++++++++++++++++++++++-------------------
>  3 files changed, 76 insertions(+), 35 deletions(-)
> 
> diff --git a/checkpoint/cpt_image.h b/checkpoint/cpt_image.h
> index e1fb483..f370df2 100644
> --- a/checkpoint/cpt_image.h
> +++ b/checkpoint/cpt_image.h
> @@ -128,6 +128,8 @@ struct cpt_task_image {
>  	__u64	cpt_nivcsw;
>  	__u64	cpt_min_flt;
>  	__u64	cpt_maj_flt;
> +	__u32	cpt_children_num;
> +	__u32	cpt_pad;
>  } __attribute__ ((aligned (8)));
>  
>  struct cpt_mm_image {
> diff --git a/checkpoint/cpt_process.c b/checkpoint/cpt_process.c
> index 1f7a54b..d73ec3c 100644
> --- a/checkpoint/cpt_process.c
> +++ b/checkpoint/cpt_process.c
> @@ -40,6 +40,19 @@ static unsigned int encode_task_flags(unsigned int task_flags)
>  		
>  }
>  
> +static int cpt_count_children(struct task_struct *tsk, struct cpt_context *ctx)
> +{
> +	int num = 0;
> +	struct task_struct *child;
> +
> +	list_for_each_entry(child, &tsk->children, sibling) {
> +		if (child->parent != tsk)
> +			continue;
> +		num++;
> +	}
> +	return num;
> +}
> +

I noticed that don't take the appropriate locks when browsing through
tasks lists (siblings, children, global list). Although I realize that
the container should be frozen at this time, I keep wondering if this
is indeed always safe.

For instance, are you protected against an OOM killer that might just
occur uninvited and kill one of those tasks ?

Can the administrator force an un-freeze of the container ?  Or perhaps
some error condition if the kernel cause that ?

>  int cpt_dump_task_struct(struct task_struct *tsk, struct cpt_context *ctx)
>  {
>  	struct cpt_task_image *t;
> @@ -102,6 +115,7 @@ int cpt_dump_task_struct(struct task_struct *tsk, struct cpt_context *ctx)
>  	t->cpt_egid = tsk->egid;
>  	t->cpt_sgid = tsk->sgid;
>  	t->cpt_fsgid = tsk->fsgid;
> +	t->cpt_children_num = cpt_count_children(tsk, ctx);
>  
>  	err = ctx->write(t, sizeof(*t), ctx);
>  
> @@ -231,6 +245,16 @@ int cpt_dump_task(struct task_struct *tsk, struct cpt_context *ctx)
>  		err = cpt_dump_fpustate(tsk, ctx);
>  	if (!err)
>  		err = cpt_dump_registers(tsk, ctx);
> +	if (!err) {
> +		struct task_struct *child;
> +		list_for_each_entry(child, &tsk->children, sibling) {
> +			if (child->parent != tsk)
> +				continue;
> +			err = cpt_dump_task(child, ctx);
> +			if (err)
> +				break;

Here too.

[...]

Oren.
