From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 3/3] user namespaces: reset task's credentials on
	CLONE_NEWUSER
Date: Fri, 3 Oct 2008 20:37:31 -0500
Message-ID: <20081004013731.GB2272@us.ibm.com>
References: <20081004013644.GA24104@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754117AbYJDBhn@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081004013644.GA24104@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: James Morris <jmorris@redhat.com>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>, Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
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

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>

---

 kernel/user_namespace.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

4a159b503ed06f6d999b80680538a51ee39d6bd5
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index d59f193..3fbf520 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -9,6 +9,7 @@
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
+#include <linux/init_task.h>
 
 /*
  * Clone a new ns copying an original user ns, setting refcount to 1
@@ -47,6 +48,17 @@ int create_new_userns(int flags, struct 
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
1.1.6
