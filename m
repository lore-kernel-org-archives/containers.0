From: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCHv3 1/2] procfs: show hierarchy of pid namespace
Date: Thu, 25 Sep 2014 09:45:41 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E5C471E@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <1411552827-31056-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<1411552827-31056-2-git-send-email-chenhanxiao@cn.fujitsu.com>
	<20140924174527.GF10474@mguzik>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140924174527.GF10474@mguzik>
Content-Language: zh-CN
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

> -----Original Message-----
> From: Mateusz Guzik [mailto:mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org]
> Sent: Thursday, September 25, 2014 1:45 AM
> On Wed, Sep 24, 2014 at 06:00:26PM +0800, Chen Hanxiao wrote:
> > +static int
> > +pidns_list_filter(void)
> > +{
> > +	struct pidns_list *pos, *pos_t;
> > +	struct pid_namespace *ns0, *ns1;
> > +	struct pid *pid0, *pid1;
> > +	int flag = 0;
> > +	int rc;
> > +
> > +	/* screen pid with relationship
> > +	 * in pidns_list, we may add pids like
> > +	 * ns0   ns1   ns2
> > +	 * pid1->pid2->pid3
> > +	 * we should screen pid1, pid2 and keep pid3
> > +	 */
> > +	list_for_each_entry(pos, &pidns_list, list) {
> > +		list_for_each_entry(pos_t, &pidns_list, list) {
> 
> In the previous thread I tried to note this will be terribly inefficient
> to use and adding a list of children to pid_namespace struct would deal
> with the problem.

If that, we had to add a children list, maybe another sibling list
in pid_namespace struct and maintain them.
That cost too much.

For this feature, I think we'd better not touch pid_namespace struct.
As we need not to know the hierarchy so frequently,
I think such kind of inefficient is acceptable.

> 
> > +			flag = 0;
> > +			pid0 = pos->pid;
> > +			pid1 = pos_t->pid;
> > +			ns0 = pid0->numbers[pid0->level].ns;
> > +			ns1 = pid1->numbers[pid1->level].ns;
> > +			if (pos->pid->level < pos_t->pid->level)
> > +				for (; ns1 != NULL; ns1 = ns1->parent)
> > +					if (ns0 == ns1) {
> > +						flag = 1;
> > +						break;
> > +					}
> > +			if (flag == 1)
> > +				break;
> > +		}
> > +
> > +		if (flag == 0) {
> > +			rc = pidns_list_add(pos->pid, &pidns_tree);
> > +			if (rc)
> > +				goto out;
> > +		}
> > +	}
> > +
> > +	/* Now all usefull stuff are in pidns_tree, free pidns_list*/
> > +	free_pidns_list(&pidns_list);
> > +
> > +	return 0;
> > +
> > +out:
> > +	free_pidns_list(&pidns_tree);
> > +	return rc;
> > +}
> > +
> > +/* collect pids in pidns_list,
> > + * then remove duplicated ones,
> > + * add the rest to pidns_tree
> > + */
> > +static int proc_pidns_list_refresh(void)
> > +{
> > +	struct pid *pid;
> > +	struct task_struct *p;
> > +	int rc;
> > +
> > +	/* collect pid in differet ns */
> > +	rcu_read_lock();
> > +	for_each_process(p) {
> > +		pid = task_pid(p);
> > +		if (pid && (pid->level > 0)) {
> > +			rc = pidns_list_add(pid, &pidns_list);
> > +			if (rc)
> > +				goto out;
> > +		}
> > +	}
> > +
> > +	/* screen duplicate pids from list pidns_list
> > +	* and form a new list pidns_tree
> > +	*/
> > +	rc = pidns_list_filter();
> > +	if (rc)
> > +		goto out;
> > +	rcu_read_unlock();
> > +
> > +	return 0;
> > +
> > +out:
> > +	free_pidns_list(&pidns_list);
> > +	rcu_read_unlock();
> > +	return rc;
> > +}
> > +
> > +static int nslist_proc_show(struct seq_file *m, void *v)
> > +{
> > +	struct pidns_list *pos;
> > +	struct pid_namespace *ns, *curr_ns;
> > +	struct pid *pid;
> > +	char pid_buf[32];
> > +	int i, curr_level;
> > +	int rc;
> > +
> > +	curr_ns = task_active_pid_ns(current);
> > +
> > +	mutex_lock(&pidns_list_lock);
> > +	rc = proc_pidns_list_refresh();
> > +	if (rc) {
> > +		mutex_unlock(&pidns_list_lock);
> > +		return rc;
> > +	}
> > +
> > +	/* print pid namespace hierarchy */
> > +	list_for_each_entry(pos, &pidns_tree, list) {
> 
> What keeps pid_namespace's safe to use? Similarly to previous patch,
> here we hit a place where the code is not protected with rcu and
> structures were just plugged into the list.
> 
Will fix.
All list should be protected by rcu lock.

> Recreating the list for each open seems quite unnecessary as well. 
> 
> One could work around that by caching generated output and having a
> generation counter for namespaces to know whether the content is stale.
> But that still does not seem right.
> 
That will bring another issue:
We had to *keep* that list and update it
even if we don't open pidns_hierarchy.

This patch try to solve this when open /proc/pidns_hierarchy by:
a) recreated the list when open
b) show it in a procfs text file
c) drop that list

> It looks like in the original thread someone suggested hooking this up
> under proc as a directory tree which sounds much better to me.

Dir trees provide the same information as proc text files did:
a symlink name like /proc/PID/ns/pid.

Refresh dir trees needs a lot of codes too.
So a procfs text file is a better choice.

Thanks,
- Chen

> 
> Just my $0,03.
> 
> > +		pid = pos->pid;
> > +		curr_level = -1;
> > +		ns = pid->numbers[pid->level].ns;
> > +		/* Check whether a pid has relationship with current ns */
> > +		for (; ns != NULL; ns = ns->parent)
> > +			if (ns == curr_ns)
> > +				curr_level = curr_ns->level;
> > +
> > +		if (curr_level == -1)
> > +			continue;
> > +
> > +		for (i = curr_level + 1; i <= pid->level; i++) {
> > +			ns = pid->numbers[i].ns;
> > +			/* show PID '1' in specific pid ns */
> > +			snprintf(pid_buf, 32, "/proc/%u/ns/pid",
> > +				pid_vnr(find_pid_ns(1, ns)));
> > +			seq_printf(m, "%s ", pid_buf);
> > +		}
> > +
> > +		seq_putc(m, '\n');
> > +	}
> > +
> > +	free_pidns_list(&pidns_tree);
> > +	mutex_unlock(&pidns_list_lock);
> > +
> > +	return 0;
> > +}
> 
> --
> Mateusz Guzik
