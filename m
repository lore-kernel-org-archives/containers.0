From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [Fwd: Re: [PATCH][RFC] freezer: Add CHECKPOINTING state to safeguard
	container checkpoint]
Date: Fri, 29 May 2009 14:43:53 -0400
Message-ID: <4A202CE9.1090602@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
List-Id: containers.vger.kernel.org


----
Sorry for the double post - I got Pavel's email incorrect earlier.
Pavel: your email under FREEZER in MAINTAINERS is out of date...
----


Matt Helsley wrote:
> The CHECKPOINTING state prevents userspace from unfreezing tasks until
> sys_checkpoint() is finished. When doing container checkpoint userspace
> will do:

[...]

>  /*
> + * cgroup freezer state changes made without the aid of the cgroup filesystem
> + * must go through this function to ensure proper locking is observed.
> + */
> +static int freezer_checkpointing(struct task_struct *task,
> +				 enum freezer_state next_state)
> +{
> +	struct freezer *freezer;
> +	enum freezer_state state;
> +
> +	task_lock(task);
> +	freezer = task_freezer(task);
> +	spin_lock_irq(&freezer->lock);
> +	state = freezer->state;

After "echo FROZEN > /freezer/0/freezer_state", it is likely that
freezer->state remains CGROUP_FREEZING --

Then, looking at freezer_read():

...
  if (state == CGROUP_FREEZING) {
	/* We change from FREEZING to FROZEN lazily if the cgroup was
	 * only partially frozen when we exitted write. */
	update_freezer_state(cgroup, freezer);
	state = freezer->state;
  }
...

IOW, usually, only if someone reads the freezer_state file will
the freezer->status reliably reflect the state.

So, I searched for where else freezer->state is consulted, and found:

  int cgroup_frozen(struct task_struct *task)
  {
	struct freezer *freezer;
	enum freezer_state state;

	task_lock(task);
	freezer = task_freezer(task);
	state = freezer->state;
	task_unlock(task);

	return state == CGROUP_FROZEN;
  }

Which is called (only?) from kernel/power/process.c:thaw_tasks().
Here, too, unless some read from the freezer_state file, this
test will incorrectly fail.

Perhaps introduce a freezer_unlazy_state(freezer) helper, or a
a freezer_get_state(freezer) helper to use in those places ?

> +	if ((state == CGROUP_FROZEN && next_state == CGROUP_CHECKPOINTING) ||
> +	    (state == CGROUP_CHECKPOINTING && next_state == CGROUP_FROZEN))
> +		freezer->state = next_state;
> +	spin_unlock_irq(&freezer->lock);
> +	task_unlock(task);
> +
> +	return state;
> +}

[...]

Oren.
