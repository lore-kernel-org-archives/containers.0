From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Thu, 10 Feb 2011 09:54:09 -0800
Message-ID: <20110210175409.GB1025@us.ibm.com>
References: <20101211033548.GA12584@us.ibm.com>
	<4D2BB78A.9090701@cs.columbia.edu>
	<4D4D9D1B.3000209@cs.columbia.edu>
	<20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<20110209120100.GD13323@hawkmoon.kerlabs.com>
	<20110209190216.GA17051@us.ibm.com>
	<20110210102312.GC6360@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110210102312.GC6360-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
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
| > I can reproduce a crash with 2.6.32 - where if container-init terminates
| > before a detached child, we get a crash when the detached child calls
| > proc_flush_mnt(). I suspected it was because do_wait_thread() skipped
| > over detached tasks (in 2.6.32).
| > 
| > The same test case does not crash on 2.6.37 - which includes the above commit.
| > The removes the check for detached tasks, my initial guess is that the above
| > commit, may have contributed to _fixing_ the crash in 2.6.37.
| 
| Hm, I don't see how this commit changed things for detached tasks, unless ptrace
| is involved. Detached tasks go atomically
| from ->exit_state == 0 to ->exit_state == EXIT_DEAD in exit_notify(),
| because tracehook_notify_death() returns DEATH_REAP for all not ptraced detached
| tasks.
| 
| What do you think has changed precisely?

Well, one of the changes in the commit is this:

@@ -1551,14 +1554,9 @@ static int do_wait_thread(struct wait_opts *wo, struct task_struct *tsk)
        struct task_struct *p;

        list_for_each_entry(p, &tsk->children, sibling) {
-               /*
-                * Do not consider detached threads.
-                */
-               if (!task_detached(p)) {
-                       int ret = wait_consider_task(wo, 0, p);
-                       if (ret)
-                               return ret;
-               }
+               int ret = wait_consider_task(wo, 0, p);
+               if (ret)
+                       return ret;
        }

        return 0;

---
If it was a detached task, do_wait_thread() skipped over it. In the C/R
kernel we were setting the ->exit_signal to -1 for a "ghost" process. 
I assumed that the container-init exited without waiting for the "ghost"
and we were getting the crash in proc_flush_mnt() when the ghost exited.

Sukadev
