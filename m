From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 3/9] [RFC] Add a back-pointer from struct cg_cgroup_link
	to	struct cgroup
Date: Fri, 03 Jul 2009 15:07:13 +0800
Message-ID: <4A4DAE21.4000806__49688.9120703146$1246605193$gmane$org@cn.fujitsu.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021108.14469.39645.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702021108.14469.39645.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
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

> +static int current_css_set_cg_links_read(struct cgroup *cont,
> +					 struct cftype *cft,
> +					 struct seq_file *seq)
> +{
> +	struct cg_cgroup_link *link, *saved_link;
> +	struct css_set *cg;

call for a newline

> +	write_lock_irq(&css_set_lock);

can be read_lock(&css_set_lock);

> +	task_lock(current);
> +	cg = current->cgroups;
> +	list_for_each_entry_safe(link, saved_link, &cg->cg_links,
> +				 cg_link_list) {
> +		struct cgroup *c = link->cgrp;
> +		const char *name;

call for a newline

> +		rcu_read_lock();
> +		if (c->dentry)
> +			name = c->dentry->d_name.name;
> +		else
> +			name = "?";
> +		seq_printf(seq, "Root %lu group %s\n",
> +			   c->root->subsys_bits, name);
> +		rcu_read_unlock();
> +	}
> +	task_unlock(current);
> +	write_unlock_irq(&css_set_lock);
> +	return 0;
> +}
> +
