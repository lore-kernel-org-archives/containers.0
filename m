From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 1/2] devices cgroup: allow can_attach() if ns_capable
Date: Tue, 23 Jul 2013 13:16:06 -0500
Message-ID: <20130723181606.GA6342@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

We allow a task to change its own devices cgroup, or to change other tasks'
cgroups if it has CAP_SYS_ADMIN.

Also allow task A to change task B's cgroup if task A has CAP_SYS_ADMIN
with respect to task B - meaning A is root in the same userns, or A
created B's userns.

Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 security/device_cgroup.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 9760ecb6..8f5386ea 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -74,11 +74,14 @@ struct cgroup_subsys devices_subsys;
 static int devcgroup_can_attach(struct cgroup *new_cgrp,
 				struct cgroup_taskset *set)
 {
-	struct task_struct *task = cgroup_taskset_first(set);
+	struct task_struct *t = cgroup_taskset_first(set);
+	int ret = 0;
 
-	if (current != task && !capable(CAP_SYS_ADMIN))
-		return -EPERM;
-	return 0;
+	rcu_read_lock();
+	if (current != t && !ns_capable(__task_cred(t)->user_ns, CAP_SYS_ADMIN))
+		ret = -EPERM;
+	rcu_read_unlock();
+	return ret;
 }
 
 /*
-- 
1.7.9.5
