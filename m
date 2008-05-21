From: Cedric Le Goater <clg@fr.ibm.com>
Subject: [PATCH -mm] remove node_ prefix_from ns subsystem
Date: Wed, 21 May 2008 17:47:21 +0200
Message-ID: <48344409.9090903@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934898AbYEUPrj@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Paul Menage <menage@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

From: Cedric Le Goater <clg@fr.ibm.com>

This is a slight change in the namespace cgroup subsystem api.

Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
---
 kernel/cgroup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: 2.6.26-rc2-mm1/kernel/cgroup.c
===================================================================
--- 2.6.26-rc2-mm1.orig/kernel/cgroup.c
+++ 2.6.26-rc2-mm1/kernel/cgroup.c
@@ -2903,7 +2903,7 @@ int cgroup_clone(struct task_struct *tsk
 	cg = tsk->cgroups;
 	parent = task_cgroup(tsk, subsys->subsys_id);
 
-	snprintf(nodename, MAX_CGROUP_TYPE_NAMELEN, "node_%d", tsk->pid);
+	snprintf(nodename, MAX_CGROUP_TYPE_NAMELEN, "%d", tsk->pid);
 
 	/* Pin the hierarchy */
 	atomic_inc(&parent->root->sb->s_active);
