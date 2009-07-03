From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/9] [RFC] Allow cgroup hierarchies to be created with
	no	bound subsystems
Date: Fri, 03 Jul 2009 15:57:24 +0800
Message-ID: <4A4DB9E4.9060500__39382.9971937977$1246608137$gmane$org@cn.fujitsu.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021113.14469.2703.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702021113.14469.2703.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

> +#define MAX_TASKS_SHOWN_PER_CSS 25
> +static int cgroup_css_links_read(struct cgroup *cont,
> +				 struct cftype *cft,
> +				 struct seq_file *seq)
> +{
> +	struct cg_cgroup_link *link, *saved_link;

need a newline

> +	write_lock_irq(&css_set_lock);

can be read_lock(&css_set_lock);

> +	list_for_each_entry_safe(link, saved_link, &cont->css_sets,

can be list_for_each_entry()

> +				 cgrp_link_list) {
> +		struct css_set *cg = link->cg;
> +		struct task_struct *task, *saved_task;
> +		int count = 0;
> +		seq_printf(seq, "css_set %p\n", cg);
> +		list_for_each_entry_safe(task, saved_task, &cg->tasks,

ditto

> +					 cg_list) {
> +			if (count++ > MAX_TASKS_SHOWN_PER_CSS) {
> +				seq_puts(seq, "  ...\n");
> +				break;
> +			} else {
> +				seq_printf(seq, "  task %d\n",
> +					   task_pid_vnr(task));
> +			}
> +		}
> +	}
> +	write_unlock_irq(&css_set_lock);
> +	return 0;
> +}
