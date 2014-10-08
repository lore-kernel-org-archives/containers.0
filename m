From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv4] procfs: show hierarchy of pid namespace
Date: Wed, 8 Oct 2014 17:13:28 +0200
Message-ID: <20141008151328.GB4835@redhat.com>
References: <1412762198-21825-1-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1412762198-21825-1-git-send-email-chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Sorry if this was already discussed, I have to admit that I ignored
the previous discussion ;) And it is possible I misread this patch
completely.

On 10/08, Chen Hanxiao wrote:
>
> This patch will show the hierarchy of pid namespace
> by /proc/pidns_hierarchy like:
>
> [root@localhost ~]#cat /proc/pidns_hierarchy
> /proc/18060/ns/pid /proc/18102/ns/pid /proc/1534/ns/pid
> /proc/18060/ns/pid /proc/18102/ns/pid /proc/1600/ns/pid
> /proc/1550/ns/pid

Well, personally I too think that the filenames look a bit strange,
can't it just print the numbers?

And, iiuc what this patch does... perhaps in this case we should
simply add "struct list_head children" into struct pid_namespace?
In this case the patch will be really simple. I dunno.

> +pidns_list_add(struct pid *pid, struct list_head *list_head,
> +		struct pid_namespace *curr_ns)
> +{
> +	struct pidns_list *ent;
> +	struct pid_namespace *ns;
> +
> +	if (is_child_reaper(pid)) {
> +		ent = kmalloc(sizeof(*ent), GFP_KERNEL);

GFP_KERNEL under rcu_read_lock(). This is not safe without
CONFIG_PREEMPT_RCU.

> +		if (!ent)
> +			return -ENOMEM;
> +
> +		ent->pid = pid;
> +		ns = pid->numbers[pid->level].ns;
> +		if (curr_ns) {
> +			/* add pids who is the child of curr_ns */
> +			for (; ns != NULL; ns = ns->parent)
> +				if (ns == curr_ns)
> +					list_add_tail(&ent->list, list_head);

afaics, it doesn't make sense to continue after list_add() ?

> +static int proc_pidns_list_refresh(struct pid_namespace *curr_ns)
> +{
> +	struct pid *pid;
> +	struct task_struct *p;
> +	int rc;
> +
> +	/* collect pid in differet ns */
> +	for_each_process(p) {

Hmm. We only want the tasks from our namespace, yes? Perhaps find_ge_pid()
makes more sense?

> +		pid = task_pid(p);

Well, in theory you need barrier() here. Or perhaps we should add
ACCESS_ONCE() into task_pid()...

And imho it would be better to declare pidns_list/pidns_tree locally
in nslist_proc_show() and pass them to the callees.

Oleg.
