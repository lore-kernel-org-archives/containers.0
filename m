From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/22] Change to the new enhanced error string format
Date: Mon, 2 Nov 2009 09:34:02 -0800
Message-ID: <20091102173402.GJ14023@count0.beaverton.ibm.com>
References: <1256943629-4531-1-git-send-email-serue@us.ibm.com>
	<1256943629-4531-5-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1256943629-4531-5-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Oct 30, 2009 at 06:00:26PM -0500, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---

<snip>

> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 8810576..e2c01df 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -345,83 +345,83 @@ int walk_task_subtree(struct task_struct *root,
>  }
> 
>  /*
> - * ckpt_generate_fmt - generate standard checkpoint error message
> + * ckpt_generate_fmt - handle the special flags in the enhanced format
> + * strings used by checkpoint/restart error messages.
>   * @ctx: checkpoint context
> - * @fmt0: c/r-format string
>   * @fmt: message format
>   *
> - * This generates a unified format of checkpoint error messages, to
> - * ease (after the failure) inspection by userspace tools. It converts
> - * the (printf) message @fmt into a new format: "[PREFMT]: fmt".
> + * The special flags are surrounded by %() to help them visually stand
> + * out.  For instance, %(O) means an objref.  The following special
> + * flags are recognized:
> + *	E: error
> + *	O: objref
> + *	P: pointer
> + *	T: task
> + *	S: string
> + *	V: variable
>   *
> - * PREFMT is constructed from @fmt0 by subtituting format snippets
> - * according to the contents of @fmt0.  The format characters in
> - * @fmt0 can be E (error), O (objref), P (pointer), S (string) and
> - * V (variable/symbol). For example, E will generate a "err %d" in
> - * PREFMT (see prefmt_array below).
> - *
> - * If @fmt0 begins with T, PREFMT will begin with "pid %d tsk %s"
> - * with the pid and the tsk->comm of the currently checkpointed task.
> - * The latter is taken from ctx->tsk, and is it the responsbilility of
> - * the caller to have a valid pointer there (in particular, functions
> - * that iterate on the processes: collect_objects, checkpoint_task,
> - * and tree_count_tasks).
> + * %(E) will be expanded to "[err %d]".  Likewise O, P, S, and V, will
> + * also expand to format flags requiring an argument to the subsequent
> + * sprintf or printk.  T will be expanded to a string with no flags,
> + * requiring no further arguments.
>   *
>   * The caller of ckpt_write_err() and _ckpt_write_err() must provide
> - * the additional variabes, in order, to match the @fmt0 (except for
> + * the additional variabes, in order, to match the @fmt (except for
>   * the T key), e.g.:
>   *
> - *   ckpt_writ_err(ctx, "TEO", "FILE flags %d", err, objref, flags);
> - *
> - * Here, T is simply passed, E expects an integer (err), O expects an
> - * integer (objref), and the last argument matches the format string.
> + *	ckpt_write_err(ctx, "%(T)FILE flags %d %O %E\n", flags, objref, err);
>   *
>   * Must be called with ctx->fmt_buf_lock held.  The expanded format
>   * will be placed in ctx->fmt_buf.

It might also be good to note that, unlike normal conversion
specifications, these do not allow any flags, minimum field width,
precision, length modifiers, or argument numbers ("%*" or "%*m$").
This keeps these portions of the log(s) somewhat uniform and also
simplifies the code.

<snip>

Cheers,
	-Matt Helsley
