From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [C/R]: mktree.c: cr_set_creator() question
Date: Wed, 8 Apr 2009 21:43:48 -0700
Message-ID: <20090409044348.GA19748@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren:

I was trying to run the ptree test I had posted earlier with v14-rc3
and get a SIGSEGV in mktree (when restarting a simple process tree).

The SIGSEGV is due to 'creator' being NULL @ mktree.c:585.

I debugged it a bit and was not clear on the following 'task-ppid == 1'
check. It seems to check for orphaned processes using 'ppid == 1',
but 'ppid == 1' could be 1 if the 'task' was an actual child of the
container-init right ?

Also, 'phantom' does not seem to be set anywhere and so 'creator'
ends up being NULL.

Since in my case, 'task' refers to an actual child of container-init,
I reversed the order of the following two checks as a quick hack, and
it seems to fix the SIGSEGV. 

[v14-rc3] mktree.c: cr_set_creator() (lines 543-553)

        } else if (task->ppid == 1) {
                /* (non-session-leader) orphan: creator is dummy */
                cr_dbg("pid %d: orphan session %d\n", task->pid, task->sid);
                if (!session->phantom)
                        if (cr_placeholder_task(ctx, task) < 0)
                                return -1;
                creator = session->phantom;
        } else if (task->sid == parent->sid) {
                /* (non-session-leader) inherit: creator is parent */
                cr_dbg("pid %d: inherit sid %d\n", task->pid, task->sid);
                creator = parent;


Sukadev
