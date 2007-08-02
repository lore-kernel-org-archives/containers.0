From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 14/15] Destroy pid namespace on init's death
Date: Thu, 2 Aug 2007 10:20:33 -0700
Message-ID: <20070802172033.GA8011@us.ibm.com>
References: <46A8B663.9040206@openvz.org> <20070729104145.GC120@tv-sign.ru>
	<46ADD202.9030502@openvz.org> <20070730154639.GA127@tv-sign.ru>
	<20070731061917.GB17013@us.ibm.com>
	<20070731090721.GA110@tv-sign.ru>
	<20070801061616.GA5405@us.ibm.com>
	<20070801194811.GA196@tv-sign.ru> <20070802072958.GA729@us.ibm.com>
	<20070802154018.GA93@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070802154018.GA93-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
| On 08/02, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
| >
| > Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
| > | On 07/31, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
| > | >
| > | > Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
| > | > | >  
| > | > | > @@ -925,9 +926,10 @@ fastcall NORET_TYPE void do_exit(long co
| > | > | >  	if (unlikely(!tsk->pid))
| > | > | >  		panic("Attempted to kill the idle task!");
| > | > | >  	if (unlikely(tsk == task_child_reaper(tsk))) {
| > | > | > -		if (task_active_pid_ns(tsk) != &init_pid_ns)
| > | > | > -			task_active_pid_ns(tsk)->child_reaper =
| > | > | > -					init_pid_ns.child_reaper;
| > | > | > +		if (pid_ns != &init_pid_ns) {
| > | > | > +			zap_pid_ns_processes(pid_ns);
| > | > | > +			pid_ns->child_reaper = init_pid_ns.child_reaper;
| 
| OOPS. I didn't notice this before, but this is not right too (regardless
| of multi-threaded init problems).
| 
| We should not "reset" ->child_reaper here, we may have exiting tasks
| which will re-parent their ->children to global init.
| 
| No, we are still /sbin/init of this namespace even if we are exiting,
| ->child_reaper should point to us, at least until zap_pid_ns_processes()
| completes.

Yes, we are resetting the reaper _after_ zap_pid_ns_processes() completes
right ? (all other processes in the namespace must have exited).


| 
| > | > 	Our current definition of is_container_init() and task_child_reaper()
| > | > 	refer only to the main-thread of the container-init (since they check
| > | > 	for pid_t == 1)
| > | 
| > | Yes.
| > 
| > This means that we cannot have a check like "tsk == task_child_reaper(tsk)"
| > to properly detect the child reaper process right ? 
| 
| Yes, we should use "tsk->group_leader == task_child_reaper(tsk)"

Ok.

| 
| > Its basically a very dumb question - How do we detect a container_init()
| > in the multi-threaded case ?
| 
| Good point. I think is_container_init(tsk) needs a fix:
| 
| 	-	pid = task_pid(tsk);
| 	+	pid = task_pid(tsk->group_leader);
| 

Ok.

| Or, perhaps better, change the callers to use tsk->group_leader.

Ok.
| 
| > Should we use "task->tgid == 1" ?
| 
| No, no, "task->tgid == 1" means "global" init.

Grr. I got that mixed up bw my implm and Pavel's :-) task->pid and
task->tgid referred to "active-pid-ns pid" in mine.

| 
| > IOW to identify if the last thread of a child reaper is exiting, should we
| > check "task->tgid == 1" and the "group_dead" flag  in do_exit() ?
| 
| See above, but yes, as I said before I think we should do this under
| the "if (group_dead)" check below.
| 
| > | > 	If the main thread is exiting, but is not the last thread in the
| > | > 	group, should we let it exit and let the next thread in the group
| > | > 	the reaper of the pid ns ?
| > | 
| > | We can, but why? The main thread's task_struct can't go away until all
| > | sub-threads exit. Its ->nsproxy will be NULL, but this doesn't matter.
| > 
| > After the main thread exits task_child_reaper() would still refer to
| > the main thread right ? So when one of the other processes in the
| > namespace calls forget_original_parent(), it would reparent the process
| > to the main thread - no ? The main thread still has a valid task_struct,
| > but it has exited and cannot adapt children...
| 
| Yes it can't, and yes, this is somewhat against the rules.
| 
| But, afaics, this should work. Because do_wait() from the alive sub-thread
| still can reap the child, note that do_wait() iterates over all sub-threads
| ->children lists. Please note also that do_notify_parent() uses group
| signal, so it will wake up some alive sub-thread.
| 
| This is wrong for the "normal" process (because when the last thread exits
| main_thread->children is lost), but this seems to be OK for the /sbin/init,
| exactly because we are doing zap_pid_ns_processes().
| 
| Sukadev, may I ask you to add a fat comment about this in your patch?

Sure.

| 
| > BTW, are there any actual users of multi-threaded init ? Or is this
| > something that can be considered outside the "core" patchset and
| > addressed soon, but separately like the signalling-container-init issue ?
| 
| Well, I don't know. Please also see the reply to Kirill's message...
| 
| Oleg.
