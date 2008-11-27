From: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC][PATCH 3/5] Determine if sender is from ancestor ns
Date: Thu, 27 Nov 2008 02:01:01 +0100
Message-ID: <20081127010101.GA13545@wavehammer.waldi.eu.org>
References: <20081126034242.GA23120@us.ibm.com>
	<20081126034611.GC23238@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081126034611.GC23238-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 25, 2008 at 07:46:11PM -0800, Sukadev Bhattiprolu wrote:
> +#ifdef CONFIG_PID_NS
> +#define SIG_FROM_USER  INT_MIN         /* MSB */

Is it really a wise idea to mix this into the signal number? Also this
definition looks odd. If you want the highest bit, you should mention
this explicitely with 1U<<31.

If I see this correctly this information is already covered in si_code
with SI_USER and SI_TKILL. SI_KERNEL is used for explicit kernel
generated signals.

> +static inline int siginfo_from_ancestor_ns(struct task_struct *t,
> +			siginfo_t *info)
> +{
> +	if (!is_si_special(info) && (info->si_signo & SIG_FROM_USER)) {
> +		/* if t can't see us we are from parent ns */

What?

>  static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
>  			int group)
>  {
>  	struct sigpending *pending;
>  	struct sigqueue *q;
> +	int from_ancestor_ns;
>  
>  	trace_sched_signal_send(sig, t);
>  
> +	from_ancestor_ns = siginfo_from_ancestor_ns(t, info);
> +

This is not used at all here?

Bastian

-- 
Those who hate and fight must stop themselves -- otherwise it is not stopped.
		-- Spock, "Day of the Dove", stardate unknown
