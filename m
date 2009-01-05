From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/6][v5] Define siginfo_from_ancestor_ns()
Date: Mon, 5 Jan 2009 13:42:56 +0100
Message-ID: <20090105124256.GB3313@redhat.com>
References: <20081227204658.GA27197@us.ibm.com>
	<20081227205222.GB27337@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081227205222.GB27337-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On 12/27, Sukadev Bhattiprolu wrote:
>
> +static inline int siginfo_from_ancestor_ns(struct task_struct *t,
> +                       siginfo_t *info)
> +{
> +	struct pid_namespace *ns;
> +
> +	/*
> +	 * Ensure signal is from user-space before checking pid namespace.
> +	 * (We maybe called from interrupt context and dereferencing
> +	 * pid namespace would be safe).
> +	 */
> +	if (siginfo_from_user(info)) {
> +		/*
> +		 * If we do not have a pid in the receiver's namespace,
> +		 * we must be from an ancestor namespace.
> +		 *
> +		 * Note:
> +		 * 	If receiver is exiting, ns == NULL,

Confused. I thought we alread have the patch which ensures
task_active_pid_ns() is never NULL?

If not, we can get ns from task_pid(t). See also below.

>                       signal will be
> +		 * 	queued but eventually ignored anyway (wants_signal()
> +		 * 	is FALSE).

This is only true for thread-specific signals, please remove
this comment,

> +		ns = task_active_pid_ns(t);
> +		if (!ns || task_pid_nr_ns(current, ns) <= 0)
> +			return 1;

See above. In any case, we shouldn't return 1 if ns == NULL.
But afaics we always can know its namespace.

Oleg.
