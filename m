From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH 1/2][v2] pid: Implement ns_of_pid
Date: Tue, 16 Dec 2008 16:02:57 -0800
Message-ID: <20081217000257.GA810@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759072AbYLQAEH@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Oleg Nesterov <oleg@tv-sign.ru>, bastian@waldi.eu.org, Pavel Emelyanov <xemul@openvz.org>, roland@redhat.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Resending patch with correct "From", "Signed-off-by" and a note
in function header of ns_of_pid().

---
From: Eric Biederman <ebiederm@xmission.com>
Subject: [PATCH] pid: Implement ns_of_pid

A current problem with the pid namespace is that it is
easy to do pid related work after exit_task_namespaces which
drops the nsproxy pointer.

However if we are doing pid namespace related work we are
always operating on some struct pid which retains the pid_namespace
pointer of the pid namespace it was allocated in.

So provide ns_of_pid which allows us to find the pid
namespace a pid was allocated in.

Using this we have the needed infrastructure to do pid
namespace related work at anytime we have a struct pid,
removing the chance of accidentally having a NULL
pointer dereference when accessing current->nsproxy.

Changelog[v2]:
	- Add a note in function header of ns_of_pid() re: NULL pid.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 include/linux/pid.h |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/pid.h b/include/linux/pid.h
index d7e98ff..da6f174 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -122,6 +122,24 @@ int next_pidmap(struct pid_namespace *pid_ns, int last);
 extern struct pid *alloc_pid(struct pid_namespace *ns);
 extern void free_pid(struct pid *pid);
 
+/* 
+ * ns_of_pid() returns the pid namespace in which the specified pid was
+ * allocated.
+ *
+ * NOTE:
+ * 	ns_of_pid() is expected to be called for a process (task) that has
+ * 	an attached 'struct pid' (see attach_pid(), detach_pid()) i.e @pid
+ * 	is expected to be non-NULL. If @pid is NULL, caller should handle
+ * 	the resulting NULL pid-ns.
+ */
+static inline struct pid_namespace *ns_of_pid(struct pid *pid)
+{
+	struct pid_namespace *ns = NULL;
+	if (pid)
+		ns = pid->numbers[pid->level].ns;
+	return ns;
+}
+
 /*
  * the helpers to get the pid's id seen from different namespaces
  *
-- 
1.5.2.5
