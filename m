From: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Subject: Re: [RFC PATCH ghak32 V2 05/13] audit: add containerid support for
	ptrace and signals
Date: Wed, 18 Apr 2018 20:32:15 -0400
Message-ID: <CAHC9VhTy4fX1hYfD5tppbP-fRaVRMXOfeJ=Et96J_rc7Jw12Bw__45597.2268399366$1524097829$gmane$org@mail.gmail.com>
References: <cover.1521179281.git.rgb@redhat.com>
	<8c7ff567377f4a83edac48e962c1b5b824b523c8.1521179281.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8c7ff567377f4a83edac48e962c1b5b824b523c8.1521179281.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Mar 16, 2018 at 5:00 AM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> Add container ID support to ptrace and signals.  In particular, the "op"
> field provides a way to label the auxiliary record to which it is
> associated.
>
> Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/audit.h | 16 +++++++++++-----
>  kernel/audit.c        | 12 ++++++++----
>  kernel/audit.h        |  2 ++
>  kernel/auditsc.c      | 19 +++++++++++++++----
>  4 files changed, 36 insertions(+), 13 deletions(-)

...

> diff --git a/kernel/audit.c b/kernel/audit.c
> index a12f21f..b238be5 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -142,6 +142,7 @@ struct audit_net {
>  kuid_t         audit_sig_uid = INVALID_UID;
>  pid_t          audit_sig_pid = -1;
>  u32            audit_sig_sid = 0;
> +u64            audit_sig_cid = INVALID_CID;
>
>  /* Records can be lost in several ways:
>     0) [suppressed in audit_alloc]
> @@ -1438,6 +1439,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>                         memcpy(sig_data->ctx, ctx, len);
>                         security_release_secctx(ctx, len);
>                 }
> +               sig_data->cid = audit_sig_cid;
>                 audit_send_reply(skb, seq, AUDIT_SIGNAL_INFO, 0, 0,
>                                  sig_data, sizeof(*sig_data) + len);
>                 kfree(sig_data);
> @@ -2051,20 +2053,22 @@ void audit_log_session_info(struct audit_buffer *ab)
>
>  /*
>   * audit_log_container_info - report container info
> - * @tsk: task to be recorded
>   * @context: task or local context for record
> + * @op: containerid string description
> + * @containerid: container ID to report
>   */
> -int audit_log_container_info(struct task_struct *tsk, struct audit_context *context)
> +int audit_log_container_info(struct audit_context *context,
> +                             char *op, u64 containerid)
>  {
>         struct audit_buffer *ab;
>
> -       if (!audit_containerid_set(tsk))
> +       if (!cid_valid(containerid))
>                 return 0;
>         /* Generate AUDIT_CONTAINER_INFO with container ID */
>         ab = audit_log_start(context, GFP_KERNEL, AUDIT_CONTAINER_INFO);
>         if (!ab)
>                 return -ENOMEM;
> -       audit_log_format(ab, "contid=%llu", audit_get_containerid(tsk));
> +       audit_log_format(ab, "op=%s contid=%llu", op, containerid);
>         audit_log_end(ab);
>         return 0;
>  }

Let's get these changes into the first patch where
audit_log_container_info() is defined.  Why?  This inserts a new field
into the record which is a no-no.  Yes, it is one single patchset, but
they are still separate patches and who knows which patches a given
distribution and/or tree may decide to backport.

> diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> index 2bba324..2932ef1 100644
> --- a/kernel/auditsc.c
> +++ b/kernel/auditsc.c
> @@ -113,6 +113,7 @@ struct audit_aux_data_pids {
>         kuid_t                  target_uid[AUDIT_AUX_PIDS];
>         unsigned int            target_sessionid[AUDIT_AUX_PIDS];
>         u32                     target_sid[AUDIT_AUX_PIDS];
> +       u64                     target_cid[AUDIT_AUX_PIDS];
>         char                    target_comm[AUDIT_AUX_PIDS][TASK_COMM_LEN];
>         int                     pid_count;
>  };
> @@ -1422,21 +1423,27 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
>         for (aux = context->aux_pids; aux; aux = aux->next) {
>                 struct audit_aux_data_pids *axs = (void *)aux;
>
> -               for (i = 0; i < axs->pid_count; i++)
> +               for (i = 0; i < axs->pid_count; i++) {
> +                       char axsn[sizeof("aux0xN ")];
> +
> +                       sprintf(axsn, "aux0x%x", i);
>                         if (audit_log_pid_context(context, axs->target_pid[i],
>                                                   axs->target_auid[i],
>                                                   axs->target_uid[i],
>                                                   axs->target_sessionid[i],
>                                                   axs->target_sid[i],
> -                                                 axs->target_comm[i]))
> +                                                 axs->target_comm[i])
> +                           && audit_log_container_info(context, axsn, axs->target_cid[i]))

Shouldn't this be an OR instead of an AND?

>                                 call_panic = 1;
> +               }
>         }
>
>         if (context->target_pid &&
>             audit_log_pid_context(context, context->target_pid,
>                                   context->target_auid, context->target_uid,
>                                   context->target_sessionid,
> -                                 context->target_sid, context->target_comm))
> +                                 context->target_sid, context->target_comm)
> +           && audit_log_container_info(context, "target", context->target_cid))

Same question.

>                         call_panic = 1;
>
>         if (context->pwd.dentry && context->pwd.mnt) {

-- 
paul moore
www.paul-moore.com
