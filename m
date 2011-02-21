From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Mon, 21 Feb 2011 12:40:58 -0800
Message-ID: <20110221204058.GC14377@us.ibm.com>
References: <20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<4D520B78.9020300@cs.columbia.edu>
	<20110210024430.GA23167@us.ibm.com>
	<4D536154.8000900@cs.columbia.edu>
	<20110210061730.GA25432@us.ibm.com>
	<4D53FC9C.1050405@cs.columbia.edu>
	<20110216201019.GA27698@us.ibm.com>
	<20110217152116.GM518@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110217152116.GM518-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
| > But in 2.6.32 i.e RHEL5, tsk->signal is set to NULL in __exit_signal().
| > So, I am trying to rule out the following scenario:
| > 
| > 	Child (may not be a ghost)			Parent
| > 	-------------------------                       ------
| > - exit_notify(): is EXIT_DEAD 
| > - release_task():
| > 	 - drops task_list_lock
| > 	 					- itself proceeds to exit.
| > 						- enters release_task()
| > 						- sets own->signal = NULL
| > 						  (in 2.6.32, __exit_signal())
| > 
| > - enters exit_checkpoint()
| > - __wake_up_parent()
| > 	access parents->signal NULL ptr
| > 
| > Not sure if holding task_list_lock here is needed or will help.
| 
| Giving my 2 cents since I've been Cc'ed.

Thanks, appreciate the input :-)

| 
| AFAICS, holding tasklist_lock prevents __exit_signal() from setting
| parent->signal to NULL in your back. So something like this should be safe:
| 
| 	read_lock(&tasklist_lock);
| 	if (current->parent->signal)
| 		__wake_up_parent(...);
| 	read_unlock(&tasklist_lock);

Yes, checking the parent->signal with task_list_lock would work.

| 
| I haven't looked at the context, but of course this also requires that some
| get_task_struct() on current->parent has been done somewhere else before current
| has passed __exit_signal().
| 
| By the way, instead of checking current->parent->signal,
| current->parent->exit_state would look cleaner to me. current->parent is not
| supposed to wait on ->wait_chldexit after calling do_exit(), right?
                                                    ^^^^^^^

Hmm, do you mean exit_notify() here ?

If so, yes checking the exit_state is cleaner.

If the parent's exit_state is set, then it can't be waiting for the ghost,
so no need to wake_up_parent(). If exit state is not set, then it is safe
to wake_up_parent() (parent->signal would not yet have been cleared for
instance).

The one case where a parent in do_exit() could still wait for the child is 
the container-init which waits on wait_chldexit in do_exit() ->
zap_pid_ns_processes() - but even in that case the __wake_up_parent()
call would be safe.

Sukadev
