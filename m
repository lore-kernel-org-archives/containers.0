From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [C/R]: mktree.c: cr_set_creator() question
Date: Sat, 11 Apr 2009 23:14:23 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0904112312040.22353@takamine.ncl.cs.columbia.edu>
References: <20090409044348.GA19748@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090409044348.GA19748-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 8 Apr 2009, Sukadev Bhattiprolu wrote:

Indeed the bug was that cr_placeholder_task() forgot to also set
'session->phantom = holder'. This fixes the crash (added to next
version).

diff --git a/mktree.c b/mktree.c
index 08cd56a..2e0705d 100644
--- a/mktree.c
+++ b/mktree.c
@@ -540,6 +540,10 @@ static int cr_set_creator(struct cr_ctx *ctx, struct task *task)
 		/* dead: creator is session leader */
 		cr_dbg("pid %d: task is dead\n", task->pid);
 		creator = session;
+	} else if (task->sid == parent->sid) {
+		/* (non-session-leader) inherit: creator is parent */
+		cr_dbg("pid %d: inherit sid %d\n", task->pid, task->sid);
+		creator = parent;
 	} else if (task->ppid == 1) {
 		/* (non-session-leader) orphan: creator is dummy */
 		cr_dbg("pid %d: orphan session %d\n", task->pid, task->sid);
@@ -547,10 +551,6 @@ static int cr_set_creator(struct cr_ctx *ctx, struct task *task)
 			if (cr_placeholder_task(ctx, task) < 0)
 				return -1;
 		creator = session->phantom;
-	} else if (task->sid == parent->sid) {
-		/* (non-session-leader) inherit: creator is parent */
-		cr_dbg("pid %d: inherit sid %d\n", task->pid, task->sid);
-		creator = parent;
 	} else {
 		/* first make sure we know the session's creator */
 		if (!session->creator && session != cr_init_task(ctx)) {
@@ -643,6 +643,7 @@ static int cr_placeholder_task(struct cr_ctx *ctx, struct task *task)
 		session->children->prev_sib = holder;
 	}
 	session->children = holder;
+	session->phantom = holder;
 
 	/* reparent entry if necssary */
 	if (task->next_sib)


> Oren:
> 
> I was trying to run the ptree test I had posted earlier with v14-rc3
> and get a SIGSEGV in mktree (when restarting a simple process tree).
> 
> The SIGSEGV is due to 'creator' being NULL @ mktree.c:585.
> 
> I debugged it a bit and was not clear on the following 'task-ppid == 1'
> check. It seems to check for orphaned processes using 'ppid == 1',
> but 'ppid == 1' could be 1 if the 'task' was an actual child of the
> container-init right ?
> 

Yes, a process with ppid==1 and session id like the container-init 
can be viewed either an orphan task or as a child of containter-init.

> Also, 'phantom' does not seem to be set anywhere and so 'creator'
> ends up being NULL.

This was the bug :(

> 
> Since in my case, 'task' refers to an actual child of container-init,
> I reversed the order of the following two checks as a quick hack, and
> it seems to fix the SIGSEGV. 

It fixed the crash because it was a child of the session leader. If
wouldn't work for an orphan with a different session id... (the fix
above does).

You are definitely right in observing that a "phantom" task is not
needed (although it doesn't break either) if an orphan has the same 
session id as the container root.

Oren.

> 
> [v14-rc3] mktree.c: cr_set_creator() (lines 543-553)
> 
>         } else if (task->ppid == 1) {
>                 /* (non-session-leader) orphan: creator is dummy */
>                 cr_dbg("pid %d: orphan session %d\n", task->pid, task->sid);
>                 if (!session->phantom)
>                         if (cr_placeholder_task(ctx, task) < 0)
>                                 return -1;
>                 creator = session->phantom;
>         } else if (task->sid == parent->sid) {
>                 /* (non-session-leader) inherit: creator is parent */
>                 cr_dbg("pid %d: inherit sid %d\n", task->pid, task->sid);
>                 creator = parent;
> 
> 
> Sukadev
> 
> 
