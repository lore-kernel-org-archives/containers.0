From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH] Disable CLONE_PARENT for init
Date: Wed, 1 Jul 2009 00:31:41 -0700
Message-ID: <20090701073140.GA14284@us.ibm.com>
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
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Disable CLONE_PARENT for init

When global or container-init processes use CLONE_PARENT, they create a
multi-rooted process tree. Besides, if the siblings of init exit, the
SIGCHLD is not sent to init process resulting in the zombies sticking
around indefinitely. So disable CLONE_PARENT for init.

Lightly tested, RFC patch :-)

Changelog[v2]:
	- Simplify patch description based on comments from Eric Biederman
	  and Oleg Nesterov.
	- [Oleg Nesterov] Use SIGNAL_UNKILLABLE instead of is_global_init()

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 kernel/fork.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

Index: linux-mmotm/kernel/fork.c
===================================================================
--- linux-mmotm.orig/kernel/fork.c	2009-06-30 23:01:06.000000000 -0700
+++ linux-mmotm/kernel/fork.c	2009-06-30 23:13:53.000000000 -0700
@@ -974,6 +974,17 @@ static struct task_struct *copy_process(
 	if ((clone_flags & CLONE_SIGHAND) && !(clone_flags & CLONE_VM))
 		return ERR_PTR(-EINVAL);
 
+	/*
+	 * Swapper process sets the handler for SIGCHLD to SIG_DFL. If init
+	 * creates a sibling and the sibling exits, the SIGCHLD is sent to
+	 * the swapper (since the swapper's handler for SIGCHLD is SIG_DFL).
+	 * But since the swapper does not reap its children, the zombie will
+	 * remain forever. So prevent init from using CLONE_PARENT.
+	 */
+	if ((clone_flags & CLONE_PARENT) &&
+				current->signal->flags & SIGNAL_UNKILLABLE)
+		return ERR_PTR(-EINVAL);
+
 	retval = security_task_create(clone_flags);
 	if (retval)
 		goto fork_out;
