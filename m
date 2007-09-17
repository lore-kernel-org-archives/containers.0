From: Paul Menage <menage@google.com>
Subject: [PATCH 02/33] task containersv11 basic task container framework fix
Date: Mon, 17 Sep 2007 14:03:09 -0700
Message-ID: <20070917210426.415625000@menage.corp.google.com>
References: <20070917210307.116234000@menage.corp.google.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760567AbXIQVJ3@vger.kernel.org>
Content-Disposition: inline; filename=task-containersv11-basic-task-container-framework-fix.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linuxfoundation.org, balbir@linux.vnet.ibm.com, "Serge E. Hallyn" <serue@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, pj@sgi.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Handle reading /proc/self/cpuset when cpusets isn't mounted.

Signed-off-by: Paul Menage <menage@google.com>

---

 kernel/cgroup.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff -puN kernel/cgroup.c~task-cgroupsv11-basic-task-cgroup-framework-fix kernel/cgroup.c
--- a/kernel/cgroup.c~task-cgroupsv11-basic-task-cgroup-framework-fix
+++ a/kernel/cgroup.c
@@ -683,6 +683,15 @@ int cgroup_path(const struct containe
 {
 	char *start;
 
+	if (cont == dummytop) {
+		/*
+		 * Inactive subsystems have no dentry for their root
+		 * cgroup
+		 */
+		strcpy(buf, "/");
+		return 0;
+	}
+
 	start = buf + buflen;
 
 	*--start = '\0';
_

--
