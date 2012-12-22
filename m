From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 1/3] pidns: Outlaw thread creation after
	unshare(CLONE_NEWPID)
Date: Fri, 21 Dec 2012 20:57:34 -0800
Message-ID: <877goaela9.fsf@xmission.com>
References: <87d2y2elbi.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2y2elbi.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Fri, 21 Dec 2012 20:56:49 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


The sequence:
unshare(CLONE_NEWPID)
clone(CLONE_THREAD|CLONE_SIGHAND|CLONE_VM)

Creates a new process in the new pid namespace without setting
pid_ns->child_reaper.  After forking this results in a NULL
pointer dereference.

Avoid this and other nonsense scenarios that can show up after
creating a new pid namespace with unshare by adding a new
check in copy_prodcess.

Pointed-out-by:  Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/fork.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index a31b823..65ca6d2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1166,6 +1166,14 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 				current->signal->flags & SIGNAL_UNKILLABLE)
 		return ERR_PTR(-EINVAL);
 
+	/*
+	 * If the new process will be in a different pid namespace
+	 * don't allow the creation of threads.
+	 */
+	if ((clone_flags & (CLONE_VM|CLONE_NEWPID)) &&
+	    (task_active_pid_ns(current) != current->nsproxy->pid_ns))
+		return ERR_PTR(-EINVAL);
+
 	retval = security_task_create(clone_flags);
 	if (retval)
 		goto fork_out;
-- 
1.7.5.4
