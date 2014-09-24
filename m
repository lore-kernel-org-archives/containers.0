From: Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv3 1/2] procfs: show hierarchy of pid namespace
Date: Wed, 24 Sep 2014 19:45:28 +0200
Message-ID: <20140924174527.GF10474@mguzik>
References: <1411552827-31056-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<1411552827-31056-2-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1411552827-31056-2-git-send-email-chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Wed, Sep 24, 2014 at 06:00:26PM +0800, Chen Hanxiao wrote:
> +static int
> +pidns_list_filter(void)
> +{
> +	struct pidns_list *pos, *pos_t;
> +	struct pid_namespace *ns0, *ns1;
> +	struct pid *pid0, *pid1;
> +	int flag = 0;
> +	int rc;
> +
> +	/* screen pid with relationship
> +	 * in pidns_list, we may add pids like
> +	 * ns0   ns1   ns2
> +	 * pid1->pid2->pid3
> +	 * we should screen pid1, pid2 and keep pid3
> +	 */
> +	list_for_each_entry(pos, &pidns_list, list) {
> +		list_for_each_entry(pos_t, &pidns_list, list) {

In the previous thread I tried to note this will be terribly inefficient
to use and adding a list of children to pid_namespace struct would deal
with the problem.

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
> +		if (flag == 0) {
> +			rc = pidns_list_add(pos->pid, &pidns_tree);
> +			if (rc)
> +				goto out;
> +		}
> +	}
> +
> +	/* Now all usefull stuff are in pidns_tree, free pidns_list*/
> +	free_pidns_list(&pidns_list);
> +
> +	return 0;
> +
> +out:
> +	free_pidns_list(&pidns_tree);
> +	return rc;
> +}
> +
> +/* collect pids in pidns_list,
> + * then remove duplicated ones,
> + * add the rest to pidns_tree
> + */
> +static int proc_pidns_list_refresh(void)
> +{
> +	struct pid *pid;
> +	struct task_struct *p;
> +	int rc;
> +
> +	/* collect pid in differet ns */
> +	rcu_read_lock();
> +	for_each_process(p) {
> +		pid = task_pid(p);
> +		if (pid && (pid->level > 0)) {
> +			rc = pidns_list_add(pid, &pidns_list);
> +			if (rc)
> +				goto out;
> +		}
> +	}
> +
> +	/* screen duplicate pids from list pidns_list
> +	* and form a new list pidns_tree
> +	*/
> +	rc = pidns_list_filter();
> +	if (rc)
> +		goto out;
> +	rcu_read_unlock();
> +
> +	return 0;
> +
> +out:
> +	free_pidns_list(&pidns_list);
> +	rcu_read_unlock();
> +	return rc;
> +}
> +
> +static int nslist_proc_show(struct seq_file *m, void *v)
> +{
> +	struct pidns_list *pos;
> +	struct pid_namespace *ns, *curr_ns;
> +	struct pid *pid;
> +	char pid_buf[32];
> +	int i, curr_level;
> +	int rc;
> +
> +	curr_ns = task_active_pid_ns(current);
> +
> +	mutex_lock(&pidns_list_lock);
> +	rc = proc_pidns_list_refresh();
> +	if (rc) {
> +		mutex_unlock(&pidns_list_lock);
> +		return rc;
> +	}
> +
> +	/* print pid namespace hierarchy */
> +	list_for_each_entry(pos, &pidns_tree, list) {

What keeps pid_namespace's safe to use? Similarly to previous patch,
here we hit a place where the code is not protected with rcu and
structures were just plugged into the list.

Recreating the list for each open seems quite unnecessary as well.

One could work around that by caching generated output and having a
generation counter for namespaces to know whether the content is stale.
But that still does not seem right.

It looks like in the original thread someone suggested hooking this up
under proc as a directory tree which sounds much better to me.

Just my $0,03.

> +		pid = pos->pid;
> +		curr_level = -1;
> +		ns = pid->numbers[pid->level].ns;
> +		/* Check whether a pid has relationship with current ns */
> +		for (; ns != NULL; ns = ns->parent)
> +			if (ns == curr_ns)
> +				curr_level = curr_ns->level;
> +
> +		if (curr_level == -1)
> +			continue;
> +
> +		for (i = curr_level + 1; i <= pid->level; i++) {
> +			ns = pid->numbers[i].ns;
> +			/* show PID '1' in specific pid ns */
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

-- 
Mateusz Guzik
