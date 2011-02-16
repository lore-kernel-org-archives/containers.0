From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Wed, 16 Feb 2011 12:10:20 -0800
Message-ID: <20110216201019.GA27698@us.ibm.com>
References: <4D2BB78A.9090701@cs.columbia.edu>
	<4D4D9D1B.3000209@cs.columbia.edu>
	<20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<4D520B78.9020300@cs.columbia.edu>
	<20110210024430.GA23167@us.ibm.com>
	<4D536154.8000900@cs.columbia.edu>
	<20110210061730.GA25432@us.ibm.com>
	<4D53FC9C.1050405@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D53FC9C.1050405-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| So instead, we can call __wake_up_parent() from exit_checkpoint()
| if indeed we are already reaped there:
| 
| exit_checkpoint()
| {
| 	...
| 	if (current->flags & PF_RESTARTING) {
| 		...
| 		/* either zombie or reaped ghost/dead */
| 		if (current->exit_state = EXIT_DEAD)
| 			__wake_up_parent(...);	  /* probably need lock */
| 		...
| 	}
| 	...
| }
| 
| and to avoid userspace misuse, disallow non-thread-group-leader ghosts.
| 
| ?

Well, I don't see a problem as such, but notice one inconsistency.

By the time the ghost task calls exit_checkpoint() it would have
gone through release_task()/__exit_signal()/__unhash_process() so
it is no longer on the parent's ->children list. We will be accessing
the task's ->parent pointer after this.

I am looking to see if anything prevents the parent from itself going
through release_task(), after the child does the release_task() but before
the child does the exit_checkpoint().

In 2.6.38, I don't see specifically where a task's ->parent pointer is
invalidated.  The task->parent and task->parent->signal are freed in the
final __put_task_struct(). So its probably safe to access them, even if the
parent itself is exiting and has gone through release_task().

But in 2.6.32 i.e RHEL5, tsk->signal is set to NULL in __exit_signal().
So, I am trying to rule out the following scenario:

	Child (may not be a ghost)			Parent
	-------------------------                       ------
- exit_notify(): is EXIT_DEAD 
- release_task():
	 - drops task_list_lock
	 					- itself proceeds to exit.
						- enters release_task()
						- sets own->signal = NULL
						  (in 2.6.32, __exit_signal())

- enters exit_checkpoint()
- __wake_up_parent()
	access parents->signal NULL ptr

Not sure if holding task_list_lock here is needed or will help.

Sukadev
