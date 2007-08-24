From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] sys_getsid/sys_getpgid return wrong id for task from another
 ns
Date: Fri, 24 Aug 2007 12:41:10 +0400
Message-ID: <46CE99A6.6060100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763569AbXHXIom@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: Alexey Dobriyan <adobriyan@mail.ru>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@tv-sign.ru>, Sukadev Bhattiprolu <sukadev@us.ibm.com>
List-Id: containers.vger.kernel.org

When calling the sys_getsid/sys_getpgid for task, that actually
lives in another namespace (sub-namespace) the return value should
be not the id as this task sees it, but the id as the caller does.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

 kernel/sys.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index c7c4fa4..c827186 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -993,16 +995,17 @@ asmlinkage long sys_getpgid(pid_t pid)
 	else {
 		int retval;
 		struct task_struct *p;
+		struct pid_namespace *ns;
 
-		read_lock(&tasklist_lock);
-		p = find_task_by_pid_ns(pid,
-				current->nsproxy->pid_ns);
+		ns = current->nsproxy->pid_ns;
 
+		read_lock(&tasklist_lock);
+		p = find_task_by_pid_ns(pid, ns);
 		retval = -ESRCH;
 		if (p) {
 			retval = security_task_getpgid(p);
 			if (!retval)
-				retval = task_pgrp_vnr(p);
+				retval = task_pgrp_nr_ns(p, ns);
 		}
 		read_unlock(&tasklist_lock);
 		return retval;
@@ -1026,16 +1029,17 @@ asmlinkage long sys_getsid(pid_t pid)
 	else {
 		int retval;
 		struct task_struct *p;
+		struct pid_namespace *ns;
 
-		read_lock(&tasklist_lock);
-		p = find_task_by_pid_ns(pid,
-				current->nsproxy->pid_ns);
+		ns = current->nsproxy->pid_ns;
 
+		read_lock(&tasklist_lock);
+		p = find_task_by_pid_ns(pid, ns);
 		retval = -ESRCH;
 		if (p) {
 			retval = security_task_getsid(p);
 			if (!retval)
-				retval = task_session_vnr(p);
+				retval = task_session_nr_ns(p, ns);
 		}
 		read_unlock(&tasklist_lock);
 		return retval;
