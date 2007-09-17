From: Paul Menage <menage@google.com>
Subject: [PATCH 15/33] task-containersv11-add-container_clone-interface-cgroups-fix-refcount-bug
Date: Mon, 17 Sep 2007 14:03:22 -0700
Message-ID: <20070917210428.544334000@menage.corp.google.com>
References: <20070917210307.116234000@menage.corp.google.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932288AbXIQVKA@vger.kernel.org>
Content-Disposition: inline; filename=fixoops2.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linuxfoundation.org, balbir@linux.vnet.ibm.com, "Serge E. Hallyn" <serue@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, pj@sgi.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Updates cgroup_clone() to use lookup_one_len() rather than
cgroup_get_dentry(). Originally part of
task-cgroupsv11-basic-task-cgroup-framework-cgroups-fix-refcount-bug
but split out by akpm for the -mm tree.

Signed-off-by: Paul Menage <menage@google.com>

---
 kernel/cgroup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.23-rc4-mm1-new/kernel/cgroup.c
===================================================================
--- linux-2.6.23-rc4-mm1-new.orig/kernel/cgroup.c
+++ linux-2.6.23-rc4-mm1-new/kernel/cgroup.c
@@ -2577,7 +2577,7 @@ int cgroup_clone(struct task_struct *tsk
 	/* Hold the parent directory mutex across this operation to
 	 * stop anyone else deleting the new cgroup */
 	mutex_lock(&inode->i_mutex);
-	dentry = cgroup_get_dentry(parent->dentry, nodename);
+	dentry = lookup_one_len(nodename, parent->dentry, strlen(nodename));
 	if (IS_ERR(dentry)) {
 		printk(KERN_INFO
 		       "Couldn't allocate dentry for %s: %ld\n", nodename,

--
