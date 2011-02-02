From: jacob pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH, v3 2/2] cgroups: introduce timer slack subsystem
Date: Wed, 2 Feb 2011 14:56:05 -0800
Message-ID: <20110202145605.6c9006fa__13915.6889440075$1296688400$gmane$org@putvin>
References: <1296679656-31163-1-git-send-email-kirill@shutemov.name>
	<1296679656-31163-3-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1296679656-31163-3-git-send-email-kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutsemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed,  2 Feb 2011 22:47:36 +0200
"Kirill A. Shutsemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:

> From: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> 
> Provides a way of tasks grouping by timer slack value. Introduces per
> cgroup max and min timer slack value. When a task attaches to a
> cgroup, its timer slack value adjusts (if needed) to fit min-max
> range.
> 
> It also provides a way to set timer slack value for all tasks in the
> cgroup at once.
> 
> This functionality is useful in mobile devices where certain
> background apps are attached to a cgroup and minimum wakeups are
> desired.
> 
> Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> Idea-by: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> ---
>  include/linux/cgroup_subsys.h |    6 +
>  include/linux/init_task.h     |    4 +-
>  init/Kconfig                  |   10 ++
>  kernel/Makefile               |    1 +
>  kernel/cgroup_timer_slack.c   |  242
> +++++++++++++++++++++++++++++++++++++++++

> +
> +static int cgroup_timer_slack_check(struct task_struct *task,
> +		unsigned long slack_ns)
> +{
> +	struct cgroup_subsys_state *css;
> +	struct timer_slack_cgroup *tslack_cgroup;
> +

use rcu_read_lock()/unlock?
lockdep complains unprotected rcu dereference check.

> +	css = task_subsys_state(task, timer_slack_subsys.subsys_id);
> +	tslack_cgroup = container_of(css, struct timer_slack_cgroup,
> css); +
> +	if (slack_ns < tslack_cgroup->min_slack_ns)
> +		return -EPERM;
> +	if (slack_ns > tslack_cgroup->max_slack_ns)
> +		return -EPERM;
> +	return 0;
> +}
> +

> +
> +static struct cftype files[] = {
> +	{
> +		.name = "set_slack_ns",
> +		.write_u64 = tslack_write_set_slack_ns,
> +	},
should we also allow reading of the current slack_ns?


> +	{
> +		.name = "min_slack_ns",
> +		.private = TIMER_SLACK_MIN,
> +		.read_u64 = tslack_read_range,
> +		.write_u64 = tslack_write_range,
> +	},
> +	{
> +		.name = "max_slack_ns",
> +		.private = TIMER_SLACK_MAX,
> +		.read_u64 = tslack_read_range,
> +		.write_u64 = tslack_write_range,
> +	},
> +};
> +
