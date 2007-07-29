From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 10/15] Make each namespace has its own proc tree
Date: Sun, 29 Jul 2007 19:58:41 +0400
Message-ID: <20070729155841.GI120@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B59E.7050009@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46A8B59E.7050009-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/26, Pavel Emelyanov wrote:
>
> static int proc_get_sb(struct file_system_type *fs_type,
> 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
> {
> [...snip...]
>
> +	if (!sb->s_root) {
> +		sb->s_flags = flags;
> +		err = proc_fill_super(sb);
> +		if (err) {
> +			up_write(&sb->s_umount);
> +			deactivate_super(sb);
> +			return err;
> +		}
> +
> +		ei = PROC_I(sb->s_root->d_inode);
> +		if (!ei->pid) {
> +			rcu_read_lock();
> +			ei->pid = get_pid(find_pid_ns(1, ns));

Where do we "put" this pid?

> void release_task(struct task_struct * p)
> {
> +	struct pid *pid;
> 	struct task_struct *leader;
> 	int zap_leader;
> repeat:
> @@ -160,6 +161,20 @@ repeat:
> 	write_lock_irq(&tasklist_lock);
> 	ptrace_unlink(p);
> 	BUG_ON(!list_empty(&p->ptrace_list) || 
> 	!list_empty(&p->ptrace_children));
> +	/*
> +	 * we have to keep this pid till proc_flush_task() to make
> +	 * it possible to flush all dentries holding it. pid will
> +	 * be put ibidem
> +	 *
> +	 * however if the pid belogs to init namespace only, we can
> +	 * optimize this out
> +	 */
> +	pid = task_pid(p);
> +	if (pid->level != 0)
> +		get_pid(pid);
> +	else
> +		pid = NULL;
> +
> 	__exit_signal(p);
> 
> 	/*
> @@ -184,7 +199,8 @@ repeat:
> 	}
> 
> 	write_unlock_irq(&tasklist_lock);
> -	proc_flush_task(p, NULL);
> +	proc_flush_task(p, pid);
> +	put_pid(pid);

Oh, this is not nice...

Look, proc_flush_task() doesn't need pid, it can use active pid_ns
to iterate the ->parent chain and do proc_flush_task_mnt(), and it
can check "ns->child_reaper == current" for mntput(), yes?

So, can't we do instead

	release_task()
	{
		struct pid_namespace *my_ns = ...; // get it from pid;

		...

		write_unlock_irq(&tasklist_lock);

		// __exit_signal()->...->put_pid() drops the reference,
		// but this ns should still be valid because /proc itself
		// holds a reference to it, even if we are /sbin/init.
		proc_flush_task(p, my_ns);
		...
	}

No?

Oleg.
