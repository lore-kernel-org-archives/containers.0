From: Paul Jackson <pj@sgi.com>
Subject: [PATCH] task containersv11 add tasks file interface fix for cpusets
Date: Wed, 03 Oct 2007 01:42:41 -0700
Message-ID: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757777AbXJCIm5@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Serge E. Hallyn" <serue@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, containers@lists.osdl.org, Paul Jackson <pj@sgi.com>, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

From: Paul Jackson <pj@sgi.com>

The code in kernel/cgroup.c attach_task() which skips the
attachment of a task to the group it is already in has to be
removed.  Cpusets depends on reattaching a task to its current
cpuset, in order to trigger updating the cpus_allowed mask in the
task struct.

The dependency of cpusets on this is a hack, granted, but an
important one.  It lets us avoid checking for a changed cpuset
'cpus' setting in critical scheduler code paths.

Signed-off-by: Paul Jackson <pj@sgi.com>
Cc: Paul Menage <menage@google.com>

---

Andrew - this patch applies directly following the patch:
    task-containersv11-add-tasks-file-interface.patch

 kernel/cgroup.c |    3 ---
 1 file changed, 3 deletions(-)

--- 2.6.23-rc8-mm1.orig/kernel/cgroup.c	2007-10-02 20:24:11.078925442 -0700
+++ 2.6.23-rc8-mm1/kernel/cgroup.c	2007-10-02 20:25:41.352279374 -0700
@@ -739,10 +739,7 @@ static int attach_task(struct cgroup *co
 
 	get_first_subsys(cont, NULL, &subsys_id);
 
-	/* Nothing to do if the task is already in that cgroup */
 	oldcont = task_cgroup(tsk, subsys_id);
-	if (cont == oldcont)
-		return 0;
 
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
