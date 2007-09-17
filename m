From: Paul Menage <menage@google.com>
Subject: [PATCH 09/33] task containersv11 shared container subsystem group arrays include fix
Date: Mon, 17 Sep 2007 14:03:16 -0700
Message-ID: <20070917210427.557868000@menage.corp.google.com>
References: <20070917210307.116234000@menage.corp.google.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756656AbXIQVIB@vger.kernel.org>
Content-Disposition: inline; filename=task-containersv11-shared-container-subsystem-group-arrays-include-fix.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linuxfoundation.org, balbir@linux.vnet.ibm.com, "Serge E. Hallyn" <serue@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, pj@sgi.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

kernel/cgroup.c: In function 'cgroup_new_inode':
kernel/cgroup.c:573: error: variable 'cgroup_backing_dev_info' has initializer but incomplete type
kernel/cgroup.c:574: error: unknown field 'capabilities' specified in initializer
kernel/cgroup.c:574: error: 'BDI_CAP_NO_ACCT_DIRTY' undeclared (first use in this function)
kernel/cgroup.c:574: error: (Each undeclared identifier is reported only once)


Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Paul Menage <menage@google.com>

---

 kernel/cgroup.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN kernel/cgroup.c~task-cgroupsv11-shared-cgroup-subsystem-group-arrays-include-fix kernel/cgroup.c
--- a/kernel/cgroup.c~task-cgroupsv11-shared-cgroup-subsystem-group-arrays-include-fix
+++ a/kernel/cgroup.c
@@ -36,6 +36,7 @@
 #include <linux/proc_fs.h>
 #include <linux/rcupdate.h>
 #include <linux/sched.h>
+#include <linux/backing-dev.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
 #include <linux/magic.h>
_

--
