From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 3/5] Container Freezer: Implement freezer cgroup
	subsystem
Date: Wed, 30 Apr 2008 14:28:25 -0700
Message-ID: <1209590905.29759.38.camel__31470.4647208147$1209591046$gmane$org@localhost.localdomain>
References: <20080424064756.643890130@us.ibm.com>
	<20080424064757.526468716@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080424064757.526468716-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


On Wed, 2008-04-23 at 23:47 -0700, Matt Helsley wrote:

<snip>

> +static ssize_t freezer_write(struct cgroup *cgroup,
> +			     struct cftype *cft,
> +			     struct file *file,
> +			     const char __user *userbuf,
> +			     size_t nbytes, loff_t *unused_ppos)
> +{
> +	char *buffer;
> +	int retval = 0;
> +	enum freezer_state goal_state;
> +
> +	if (nbytes >= PATH_MAX)
> +		return -E2BIG;
> +
> +	/* +1 for nul-terminator */
> +	buffer = kmalloc(nbytes + 1, GFP_KERNEL);
> +	if (buffer == NULL)
> +		return -ENOMEM;
> +
> +	if (copy_from_user(buffer, userbuf, nbytes)) {
> +		retval = -EFAULT;
> +		goto free_buffer;
> +	}
> +	buffer[nbytes] = 0;	/* nul-terminate */
> +	strstrip(buffer);
> +	if (strcmp(buffer, "RUNNING") == 0)
> +		goal_state = STATE_RUNNING;
> +	else if (strcmp(buffer, "FROZEN") == 0)
> +		goal_state = STATE_FROZEN;
> +	else {
> +		retval = -EIO;
> +		goto free_buffer;
> +	}
> +
> +	cgroup_lock();
> +
> +	if (cgroup_is_removed(cgroup)) {
> +		retval = -ENODEV;
> +		goto unlock;
> +	}

I think this was copy/paste'd from cgroup_common_file_write() which
modifies the cgroup hierarchy. However this function does not modify the
cgroup hierarchy and we're not getting the cgroup from the task. So I
don't think cgroup_lock()/unlock() are needed here. Paul, do you agree?

> +	retval = freezer_freeze(cgroup, goal_state);
> +	if (retval == 0)
> +		retval = nbytes;
> +unlock:
> +	cgroup_unlock();
> +free_buffer:
> +	kfree(buffer);
> +	return retval;
> +}

Cheers,
	-Matt Helsley
