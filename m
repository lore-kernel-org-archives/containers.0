From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 15/29] Restart multiple processes
Date: Tue, 7 Apr 2009 09:29:29 -0700
Message-ID: <20090407162928.GA21790@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-16-git-send-email-orenl@cs.columbia.edu>
	<20090407033315.GJ12316@us.ibm.com>
	<49DAE526.6010900@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49DAE526.6010900-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| Sukadev Bhattiprolu wrote:
| > 
| > Secondly, isn't pids_nr same as tasks_nr ? If so do we need both ?
| 
| As the comment says: one is used exclusively for checkpoint and the
| other exclusively for restart.
| So we don't strictly need both. I thought that for readability of it's
| useful to have @pids_nr (ok, @nr_pids ...) when dealing with a @pids_arr,
| and a @tasks_nr (ok .. @nr_tasks ...) when dealing with @tasks_arr.

| 
| > 
| > Or is this intended to address the issue of multiple pid_nr values that a
| > task in a nested container can have ? If so, pids_nr is > tasks_nr and that
| > brings up two comments :-)
| 
| Ugh. This topic is TBD.
| 
| > 
| > First, mktree.c and cr_next_task() are using 'ctx->pids_nr' to determine how
| > many tasks to start. If we are talking about nested containers, pids_nr
| > will be greater than tasks_nr so, mktree and cr_next_task() should be
| > use 'ctx->tasks_nr' to determine how many tasks to create. Also if
| > checkpointing a nested container we should view the multiple nested pid
| > values a process as an attribute of the task and maybe save them in
| > cr_write_task() rather than in cr_write_tree().
| 
| Lol .. who's talking about nested containers ?   ;)

:-) I guess the presence of both pids_nr and tasks_nr in the same structure
threw me off. Yes, ignoring nested containers for now is really good :-)

Maybe we can add a check in cr_may_checkpoint() to fail if any task in
the process tree has :

	pid->level != task_pid(current)->level + 1 

so nested containers fail cleanly.

| 
| (seriously: I'm not considering that now; my gut feeling is that it may
| be useful to do pid_ns in userspace, like task creation - and in that
| case it makes sense to keep it in cr_write_tree(). then again, I have
| not looked at it in depth).
| 
| > 
| > My second comment is more an orthogonal question. Suppose init_pid_ns = level
| >  0 and we have a container that is nested at level 3.  If we checkpoint just
| > this container, we would want to be able to restore this container at any level
| > 0 right ?
| 
| True. Do you see any limitation in the current code that prevents this ?

No I did not see anything. I mentioned it because the the number of pids
associated with the task will change and we have to discard some pids
during restart. But lets not worry about it now :-)

Sukadev
