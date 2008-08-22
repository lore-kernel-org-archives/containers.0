From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 03/10] user namespaces: reset task's credentials on
	CLONE_NEWUSER
Date: Fri, 22 Aug 2008 14:45:58 -0500
Message-ID: <20080822194558.GC10360@us.ibm.com>
References: <20080822194513.GA10262@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080822194513.GA10262-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Currently, creating a new user namespace does not reset
the task's uid or gid.  Since generally that is done as
root because it requires CAP_SYS_ADMIN, and since the
first uid in the new namespace is 0, one usually doesn't
notice.  However, if one does

	capset cap_sys_admin=ep ns_exec
	su - hallyn
	  ns_exec -U /bin/sh
	  id

then one will see hallyn's userid, and all preexisting
groups.

With this patch, cloning a new user namespace will set
the task's uid and gid to 0, and reset the group_info to
the empty set assigned to init.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/user_namespace.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 0045dd0..39aea7b 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -11,6 +11,9 @@
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
 
+/* defined in kernel/sys.c */
+extern struct group_info init_groups;
+
 /*
  * Clone a new ns copying an original user ns, setting refcount to 1
  * @old_ns: namespace to clone
@@ -48,6 +51,17 @@ int create_new_userns(int flags, struct task_struct *tsk)
 	put_user_ns(ns);
 
 	task_switch_uid(tsk, ns->root_user);
+	tsk->uid = tsk->euid = tsk->suid = tsk->fsuid = 0;
+	tsk->gid = tsk->egid = tsk->sgid = tsk->fsgid = 0;
+
+	/* this can't be safe for unshare, can it?  it's safe
+	 * for fork, though.  I'm tempted to limit clone_newuser to
+	 * fork only */
+	task_lock(tsk);
+	put_group_info(tsk->group_info);
+	tsk->group_info = &init_groups;
+	get_group_info(tsk->group_info);
+	task_unlock(tsk);
 
 	return 0;
 }
-- 
1.5.4.3
