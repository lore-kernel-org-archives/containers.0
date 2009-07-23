From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 3/4] Add a back-pointer from struct cg_cgroup_link to
	struct	cgroup
Date: Thu, 23 Jul 2009 14:44:41 +0800
Message-ID: <4A6806D9.8020004__40995.0512614616$1248331614$gmane$org@cn.fujitsu.com>
References: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>
	<20090722195040.7481.44939.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722195040.7481.44939.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
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
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Add a back-pointer from struct cg_cgroup_link to struct cgroup
> 
> Currently the cgroups code makes the assumption that the subsystem
> pointers in a struct css_set uniquely identify the hierarchy->cgroup
> mappings associated with the css_set; and there's no way to directly
> identify the associated set of cgroups other than by indirecting
> through the appropriate subsystem state pointers.
> 
> This patch removes the need for that assumption by adding a
> back-pointer from struct cg_cgroup_link object to its associated
> cgroup; this allows the set of cgroups to be determined by traversing
> the cg_links list in the struct css_set.
> 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 

Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

...

> +#define MAX_TASKS_SHOWN_PER_CSS 25
> +static int cgroup_css_links_read(struct cgroup *cont,
> +				 struct cftype *cft,
> +				 struct seq_file *seq)
> +{
> +	struct cg_cgroup_link *link;
> +

I think we need to cgroup_enable_task_cg_lists():

	if (!use_task_css_set_links)
		cgroup_enable_task_cg_lists();

Otherwise we'll see no tasks when reading this debug file
if use_task_css_set_links == 0.

> +	read_lock(&css_set_lock);
> +	list_for_each_entry(link, &cont->css_sets, cgrp_link_list) {
> +		struct css_set *cg = link->cg;
> +		struct task_struct *task;
> +		int count = 0;
> +		seq_printf(seq, "css_set %p\n", cg);
> +		list_for_each_entry(task, &cg->tasks, cg_list) {
> +			if (count++ > MAX_TASKS_SHOWN_PER_CSS) {
> +				seq_puts(seq, "  ...\n");
> +				break;
> +			} else {
> +				seq_printf(seq, "  task %d\n",
> +					   task_pid_vnr(task));
> +			}
> +		}
> +	}
> +	read_unlock(&css_set_lock);
> +	return 0;
> +}
