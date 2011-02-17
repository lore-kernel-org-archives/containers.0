From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 17 Feb 2011 22:50:10 +0900
Message-ID: <20110217225010.7f79b412.kamezawa.hiroyu__36950.7323754535$1297951023$gmane$org@jp.fujitsu.com>
References: <20110217133152.4043.94951.stgit@rabbit.intern.cm-ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110217133152.4043.94951.stgit-Rjmu19FXx3rR8JxBgnUBv+rzNCUFrscg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 17 Feb 2011 14:31:52 +0100
Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org> wrote:

> Can limit the number of fork()/clone() calls in a cgroup.  It is
> useful as a safeguard against fork bombs.
> 

brief comments below.


> Signed-off-by: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
<snip>

> +static int
> +cgroup_fork_remaining_write(struct cgroup *cgroup, struct cftype *cft,
> +			    s64 value)
> +{
> +	struct cgroup_fork *t = cgroup_fork_group(cgroup);
> +
> +	if (value < -1 || value > (1L << 30))
> +		return -EINVAL;
> +
> +	spin_lock_irq(&t->lock);
> +	t->remaining = (int)value;
> +	spin_unlock_irq(&t->lock);
> +
> +	return 0;
> +}

I wonder allowing to set the limit to Root cgroup may imply the system death.
How about disabling to set value to Root cgroup ?


> +
> +static const struct cftype cgroup_fork_files[] =  {
> +	{
> +		.name = "remaining",
> +		.read_s64 = cgroup_fork_remaining_read,
> +		.write_s64 = cgroup_fork_remaining_write,
> +	},
> +};
> +
> +static int
> +cgroup_fork_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
> +{
> +	if (cgroup->parent == NULL)
> +		/* cannot limit the root cgroup */
> +		return 0;
> +
> +	return cgroup_add_files(cgroup, ss, cgroup_fork_files,
> +				ARRAY_SIZE(cgroup_fork_files));
> +}
> +
> +struct cgroup_subsys fork_subsys = {
> +	.name = "fork",
> +	.create = cgroup_fork_create,
> +	.destroy = cgroup_fork_destroy,
> +	.fork = cgroup_fork_fork,
> +	.populate = cgroup_fork_populate,
> +	.subsys_id = fork_subsys_id,
> +};
> +
> +int
> +cgroup_fork_pre_fork(void)
> +{
> +	struct cgroup_fork *t;
> +	int err = 0;
> +
> +	rcu_read_lock();
> +
> +	t = cgroup_fork_current();
> +	while (t->css.cgroup->parent != NULL && err == 0) {
> +		spin_lock_irq(&t->lock);
> +
> +		if (t->remaining == 0)
> +			err = -EPERM;

IIRC, fork()'s error code is EAGAIN or ENOMEM. The exisiting limit of
rlimit() returns EAGAIN.

How about -EAGAIN here ? I think it's not good to add new error code for
system calls.

Thanks,
-Kame
