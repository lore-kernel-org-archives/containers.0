From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 14/15] Destroy pid namespace on init's death
Date: Wed, 1 Aug 2007 23:48:11 +0400
Message-ID: <20070801194811.GA196@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B663.9040206@openvz.org>
	<20070729104145.GC120@tv-sign.ru> <46ADD202.9030502@openvz.org>
	<20070730154639.GA127@tv-sign.ru>
	<20070731061917.GB17013@us.ibm.com>
	<20070731090721.GA110@tv-sign.ru>
	<20070801061616.GA5405@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070801061616.GA5405-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/31, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>
> Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
> | >  
> | > @@ -925,9 +926,10 @@ fastcall NORET_TYPE void do_exit(long co
> | >  	if (unlikely(!tsk->pid))
> | >  		panic("Attempted to kill the idle task!");
> | >  	if (unlikely(tsk == task_child_reaper(tsk))) {
> | > -		if (task_active_pid_ns(tsk) != &init_pid_ns)
> | > -			task_active_pid_ns(tsk)->child_reaper =
> | > -					init_pid_ns.child_reaper;
> | > +		if (pid_ns != &init_pid_ns) {
> | > +			zap_pid_ns_processes(pid_ns);
> | > +			pid_ns->child_reaper = init_pid_ns.child_reaper;
> | > +		}
> | >  		else
> | >  			panic("Attempted to kill init!");
> | >  	}
> | 
> | Just to remind you, this is not right when init is multi-threaded,
> | we should do this only when the last thread exits.
> 
> Sorry, I needed to clarify somethings about the multi-threaded init. I
> got the impresssion that you were sending a patch for the existing bug,
> and meant to review/clarify in the context of the patch.

Ah, sorry, I forgot to send the patch to fix the bug in mainline.
Will try to do tomorrow, please feel free to do this if you wish.

> 	Our current definition of is_container_init() and task_child_reaper()
> 	refer only to the main-thread of the container-init (since they check
> 	for pid_t == 1)

Yes.

> 	If the main-thread is exiting and is the last thread in the group,
> 	we want terminate other processes in the pid ns (simple case).

Yes.

> 	If the main thread is exiting, but is not the last thread in the
> 	group, should we let it exit and let the next thread in the group
> 	the reaper of the pid ns ?

We can, but why? The main thread's task_struct can't go away until all
sub-threads exit. Its ->nsproxy will be NULL, but this doesn't matter.

> 	Then we would have the pid ns w/o a container-init (i.e reaper
> 	does not have a pid_t == 1, but probably does not matter).
> 
> 	And, when this last thread is exiting, we want to terminate other
> 	processes in the ns right ?

Yes, when this last thread is exiting, the entire process is exiting.

> | > +void zap_pid_ns_processes(struct pid_namespace *pid_ns)
> | > +{
> | > +	int nr;
> | > +	int rc;
> | > +	int options = WEXITED|__WALL;
> | > +
> | > +	/*
> | > +	 * We know pid == 1 is terminating. Find remaining pid_ts
> | > +	 * in the namespace, signal them and then wait for them
> | > +	 * exit.
> | > +	 */
> | > +	nr = next_pidmap(pid_ns, 1);
> | > +	while (nr > 0) {
> | > +		kill_proc_info(SIGKILL, SEND_SIG_PRIV, nr);
> | > +		nr = next_pidmap(pid_ns, nr);
> | > +	}
> | 
> | Without tasklist_lock held this is not reliable.
> 
> Ok. BTW, find_ge_pid() also walks the pidmap, but does not seem to hold
> the tasklist_lock. Is that bc its only used in /proc ?

Yes, but this is something different. With or without tasklist_lock,
find_ge_pid()/next_tgid() is not "reliable" (note that alloc_pid() doesn't
take tasklist), but this doesn't matter for /proc.

We should take tasklist_lock to prevent the new process creation.
We can have the "false positives" (copy_process() in progress, PGID/SID
pids), but this is OK. Note that copy_process() checks signal_pending()
after write_lock_irq(&tasklist_lock), that is why it helps.

Oleg.
