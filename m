From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/22] Change to the new enhanced error string format
Date: Mon, 2 Nov 2009 08:33:27 -0800
Message-ID: <20091102163327.GH14023@count0.beaverton.ibm.com>
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

Something for the future: It might be good to have "F: File" as well. It
may sometimes be useful to print out a file name instead of just the struct
file pointer. It'd be useful for epoll, file checkpoint ops in general, and
file-backed VMAs.

<snip>

> -char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt)
> +void ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
>  {
> -	char *format = ctx->fmt_buf;
> -	int i, j, len = 0;
> -
> -	static struct {
> -		char key;
> -		char *fmt;
> -	} prefmt_array[] = {
> -		{ 'E', "err %d" },
> -		{ 'O', "obj %d" },
> -		{ 'P', "ptr %p" },
> -		{ 'V', "sym %pS" },
> -		{ 'S', "str %s" },
> -		{ 0, "??? %pS" },
> -	};
> -
> -	format[len++] = '[';
> -
> -	if (fmt0[0] == 'T') {
> -		if (ctx->tsk)
> -			len = sprintf(format, "pid %d tsk %s ",
> +	char *s = ctx->fmt_buf;
> +	int len = 0;
> +	int first = 1;
> +
> +	for (; *fmt && len < CKPT_MSG_BUFSZ; fmt++) {
> +		if (*fmt != '%' || fmt[1] != '(' || fmt[2] == '\0' ||
> +							fmt[3] != ')') {
> +			s[len++] = *fmt;
> +			continue;
> +		}
> +		if (!first)
> +			s[len++] = ' ';
> +		else
> +			first = 0;
> +		switch (fmt[2]) {
> +		case 'E':
> +			len += sprintf(s+len, "[%s]", "err %d");

Why not use snprintf ? Maybe I'm misunderstanding the length check in
the for-loop but it doesn't look sufficient to avoid overrunning the
fmt_buf. Suppose len == CKPT_MSG_BUFSZ - 1 and fmt[2] is non-NUL. Then 
we're writing 8-9 more non-NUL bytes to fmt_buf ("[err %d]" in this
case).

You could avoid snprintf() by doing:

	for (; *fmt && len < (CKPT_MSG_BUFSZ - 9); fmt++) {

which won't allow you to completely fill fmt_buf but will ensure
you never run off the end. But I still think snprintf may be necessary
to handle the default case (below).

> +			break;
> +		case 'O':
> +			len += sprintf(s+len, "[%s]", "obj %d");
> +			break;
> +		case 'P':
> +			len += sprintf(s+len, "[%s]", "ptr %p");
> +			break;
> +		case 'V':
> +			len += sprintf(s+len, "[%s]", "sym %pS");
> +			break;
> +		case 'S':
> +			len += sprintf(s+len, "[%s]", "str %s");
> +			break;
> +		case 'T':
> +			if (ctx->tsk)
> +				len += sprintf(s+len, "[pid %d tsk %s]",
>  				      task_pid_vnr(ctx->tsk), ctx->tsk->comm);
> -		else if (warn_notask++ < 5)
> -			printk(KERN_ERR "c/r: no target task set\n");
> -		fmt0++;
> -	}
> +			else
> +				len += sprintf(s+len, "[pid -1 tsk NULL]");
> +			break;
> +		default:
> +			printk(KERN_ERR "c/r: bad format specifier %c\n",
> +					fmt[2]);
> +			BUG();

Perhaps BUG() isn't such a good idea since this will be used in
error-recovery paths. The printk looks fine. Perhaps just skip to the ')':

			while (*fmt && *fmt != ')')
				fmt++;

The problem is this breaks walking the valist because an argument has been
provided which won't be consumed. To fix this seems necessary to insert
strings indicating which arguments to use with each subsequent conversion
specifier:

	arg_num = 1; /* valist index starts at one. see man snprintf */
	for (...) {
		...
		case 'S':
			len += snprintf(s+len, CKPT_MSG_BUFSZ - len,
					"[str %%*%d$s]", arg_num);
			/* sample output:[str %*3$s]" */
			arg_num++;
			break;
		...
		default:
			printk(KERN_ERR "c/r: bad format specifier %c\n", fmt[2]);
			while (*fmt && *fmt != ')')
				fmt++;
			arg_num++;
			break;

which all but requires the use snprintf instead of sprintf.

Cheers,
	-Matt Helsley
