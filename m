From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/7][v4] Protect init from unwanted signals more
Date: Wed, 24 Dec 2008 17:35:03 +0100
Message-ID: <20081224163503.GF11593@redhat.com>
References: <20081224114414.GA7879@us.ibm.com>
	<20081224115047.GB8020@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081224115047.GB8020-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/24, Sukadev Bhattiprolu wrote:
>
> -static int sig_ignored(struct task_struct *t, int sig)
> +static int sig_task_ignored(struct task_struct *t, int sig)
>  {
>  	void __user *handler;
>
> +	handler = sig_handler(t, sig);
> +
> +	if (unlikely(t->signal->flags & SIGNAL_UNKILLABLE) &&
> +			(handler == SIG_IGN || handler == SIG_DFL))
> +		return 1;
> +	
> +	return sig_handler_ignored(handler, sig);

Well, really minor nit, but can't resist ;)

if we check both SIG_IGN and SIG_DFL, then why do we call
sig_handler_ignored() ? We can do

	if (unlikely(t->signal->flags & SIGNAL_UNKILLABLE))
		return handler == SIG_IGN || handler == SIG_DFL;
	return sig_handler_ignored(handler, sig);

Or, we can do

	if (unlikely(t->signal->flags & SIGNAL_UNKILLABLE) &&
			 handler == SIG_DFL)
		return 1;
	return sig_handler_ignored(handler, sig);

because sig_handler_ignored() checks SIG_IGN too.

Of course, this is a matter of taste only...

Oleg.
