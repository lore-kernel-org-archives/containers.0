From: Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RESEND][PATCHv2 1/2] procfs: show hierarchy of pid namespace
Date: Mon, 22 Sep 2014 16:16:24 +0200
Message-ID: <20140922141623.GA10474@mguzik>
References: <1411379614-30665-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<1411379614-30665-2-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1411379614-30665-2-git-send-email-chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Sep 22, 2014 at 05:53:33PM +0800, Chen Hanxiao wrote:
> This patch will show the hierarchy of pid namespace
> by /proc/pidns_hierarchy like:
> 
> [root@localhost ~]#cat /proc/pidns_hierarchy
> /proc/18060/ns/pid /proc/18102/ns/pid /proc/1534/ns/pid
> /proc/18060/ns/pid /proc/18102/ns/pid /proc/1600/ns/pid
> /proc/1550/ns/pid
> 

I don't really know the area, just had a quick look and the patch does
not seem right.

> +/*
> + *  /proc/pidns_hierarchy
> + *  show the hierarchy of pid namespace
> + */
> +
> +#define NS_HIERARCHY	"pidns_hierarchy"
> +
> +static LIST_HEAD(pidns_list);
> +static LIST_HEAD(pidns_tree);
> +static DEFINE_MUTEX(pidns_list_lock);
> +
> +/* list for host pid collection */
> +struct pidns_list {
> +	struct list_head list;
> +	struct pid *pid;
> +};
> +
> +static void free_pidns_list(struct list_head *head)
> +{
> +	struct pidns_list *tmp, *pos;
> +
> +	list_for_each_entry_safe(pos, tmp, head, list) {
> +		list_del(&pos->list);
> +		kfree(pos);
> +	}
> +}
> +
> +/*
> + * Only add init pid in different namespaces
> + */
> +static int
> +pidns_list_really_add(struct pid *pid, struct list_head *list_head)
> +{
> +	struct pidns_list *tmp, *pos;
> +
> +	if (!is_child_reaper(pid))
> +		return 0;
> +
> +	list_for_each_entry_safe(pos, tmp, list_head, list)
> +		if (ns_of_pid(pid) == ns_of_pid(pos->pid))
> +			return 0;
> +
> +	return 1;
> +}
> +
> +static int
> +pidns_list_add(struct pid *pid, struct list_head *list_head)
> +{
> +	struct pidns_list *ent;
> +
> +	ent = kmalloc(sizeof(*ent), GFP_KERNEL);
> +	if (!ent)
> +		return -ENOMEM;
> +

A call from proc_pidns_list_refresh will enter with rcu read-locked.
Is it really ok to sleep in such case?

> +	ent->pid = pid;
> +	if (pidns_list_really_add(pid, list_head))
> +		list_add_tail(&ent->list, list_head);
> +

Does not this leak memory if pidns_list_really_add returns 0?

Also, you just add stuff to the list and don't ref it in any way, so for
instance in proc_pidns_list_refresh below...

> +static void
> +pidns_list_filter(void)
> +{
> +	struct pidns_list *tmp, *pos;
> +	struct pidns_list *tmp_t, *pos_t;
> +	struct pid_namespace *ns0, *ns1;
> +	struct pid *pid0, *pid1;
> +	int flag = 0;
> +
> +	/* screen pid with relationship
> +	 * in pidns_list, we may add pids like
> +	 * ns0   ns1   ns2
> +	 * pid1->pid2->pid3
> +	 * we should keep pid3 and screen pid1, pid2
> +	 */
> +	list_for_each_entry_safe(pos, tmp, &pidns_list, list) {
> +		list_for_each_entry_safe(pos_t, tmp_t, &pidns_list, list) {

At this point maybe it would be beneficial to have a list of children
namespaces in pid_namespace?

> +			flag = 0;
> +			pid0 = pos->pid;
> +			pid1 = pos_t->pid;
> +			ns0 = pid0->numbers[pid0->level].ns;
> +			ns1 = pid1->numbers[pid1->level].ns;
> +			if (pos->pid->level < pos_t->pid->level)
> +				for (; ns1 != NULL; ns1 = ns1->parent)
> +					if (ns0 == ns1) {
> +						flag = 1;
> +						break;
> +					}
> +			if (flag == 1)
> +				break;
> +		}
> +
> +		if (flag == 0)
> +			pidns_list_add(pos->pid, &pidns_tree);
> +	}
> +
> +	free_pidns_list(&pidns_list);
> +}
> +

> +/* collect pids in pidns_list,
> + * then remove duplicated ones,
> + * add the rest to pidns_tree
> + */
> +static void proc_pidns_list_refresh(void)
> +{
> +	struct pid *pid;
> +	struct task_struct *p;
> +
> +	/* collect pid in differet ns */
> +	rcu_read_lock();
> +	for_each_process(p) {
> +		pid = task_pid(p);
> +		if (pid && (pid->level > 0))
> +			pidns_list_add(pid, &pidns_list);
> +	}
> +	rcu_read_unlock();
> +
> +	/* screen duplicate pids */
> +	pidns_list_filter();

What makes it safe to traverse the list after rcu_read_unlock?

> +}
> +
> +static int nslist_proc_show(struct seq_file *m, void *v)
> +{
> +	struct pidns_list *tmp, *pos;
> +	struct pid_namespace *ns, *curr_ns;
> +	struct pid *pid;
> +	char pid_buf[32];
> +	int i, curr_level;
> +
> +	curr_ns = task_active_pid_ns(current);
> +
> +	mutex_lock(&pidns_list_lock);
> +	proc_pidns_list_refresh();
> +

So this reiterates everything for each open? Maybe a generation counter
could be employed here to avoid unnecessary work.

> +	/* print pid namespace hierarchy */
> +	list_for_each_entry_safe(pos, tmp, &pidns_tree, list) {
> +		pid = pos->pid;
> +		curr_level = -1;
> +		ns = pid->numbers[pid->level].ns;
> +		/* Check whether pid has relationship with current ns */
> +		for (; ns != NULL; ns = ns->parent)
> +			if (ns == curr_ns)
> +				curr_level = curr_ns->level;
> +
> +		if (curr_level == -1)
> +			continue;
> +
> +		for (i = curr_level + 1; i <= pid->level; i++) {
> +			ns = pid->numbers[i].ns;
> +			/* PID 1 in specific pid ns */
> +			snprintf(pid_buf, 32, "/proc/%u/ns/pid",
> +				pid_vnr(find_pid_ns(1, ns)));
> +			seq_printf(m, "%s ", pid_buf);
> +		}
> +
> +		seq_putc(m, '\n');
> +	}
> +
> +	free_pidns_list(&pidns_tree);
> +	mutex_unlock(&pidns_list_lock);
> +
> +	return 0;
> +}
> +

-- 
Mateusz Guzik
