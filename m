From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Enable non-blocking writes to the cgroup
	freezer.state file
Date: Mon, 26 Oct 2009 08:57:43 -0700
Message-ID: <20091026155743.GE31446@count0.beaverton.ibm.com>
References: <1256570129-13107-2-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1256570129-13107-2-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Oct 26, 2009 at 08:15:30AM -0700, Matt Helsley wrote:

<snip>

> The change to the num_cant_freeze_now count enables blocking
> while the test of dont_block outside of all the locks re-enables
> non-blocking operations when O_NONBLOCK is set.

nit:

Oops, forgot to update the portion of the description above. Should
read:

The change to the num_cant_freeze_now count enables blocking 
while the test of f_flags & O_NONBLOCK outside of all the locks ...

<snip>

> @@ -356,10 +354,22 @@ static int freezer_write(struct cgroup *cgroup, struct cftype *cft,
>  	else
>  		return -EINVAL;
> 
> +retry:
>  	if (!cgroup_lock_live_group(cgroup))
>  		return -ENODEV;
>  	retval = freezer_change_state(cgroup, goal_state);
>  	cgroup_unlock();
> +
> +	if ((f_flags & O_NONBLOCK) || (retval != -EAGAIN))
> +		return retval;
> +
> +	/* block while we haven't changed the state to the goal state */
> +	set_current_state(TASK_INTERRUPTIBLE);
> +	schedule();
> +	__set_current_state(TASK_RUNNING);
> +	if (!signal_pending(current))
> +		goto retry;
> +	retval = -EINTR;
>  	return retval;
>  }

Cheers,
	-Matt Helsley
