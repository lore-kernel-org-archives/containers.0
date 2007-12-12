From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 4/4] pid: Limit cap_set_all to the current pid namespace
Date: Wed, 12 Dec 2007 06:56:14 -0700
Message-ID: <m1ir34uidd.fsf_-_@ebiederm.dsl.xmission.com>
References: <m13au8ytos.fsf@ebiederm.dsl.xmission.com>
	<m1y7c0xezt.fsf@ebiederm.dsl.xmission.com>
	<m1tzmoxexb.fsf_-_@ebiederm.dsl.xmission.com>
	<m1prxcxeum.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lk80xeps.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcioxenh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4tcxelu.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x40xeg6.fsf_-_@ebiederm.dsl.xmission.com>
	<m13au8xe8m.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7c0vzm4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odcwvz3d.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir34vyaj.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejdsvy54.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abogvy39.fsf_-_@ebiederm.dsl.xmission.com>
	<m163z4vxzs.fsf_-_@ebiederm.dsl.xmission.com>
	<m11w9svxeb.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ve74uio4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6hsuime.fsf_-_@ebiederm.dsl.xmission.com>
	<m1mysguijx.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1mysguijx.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Wed, 12 Dec 2007 06:52:18 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


Use find_ge_pid in cap_set_all we only consider tasks in the current
pid namespace. 

This doesn't walk the task_list so on a good day in a
pid namespace it should be more scalable, more importantly
this is the same idiom used in proc and kill_pid_ns_info so it
should be reasonably maintainable.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/capability.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/kernel/capability.c b/kernel/capability.c
index 652a2c5..a11bb24 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -198,12 +198,19 @@ static inline int cap_set_all(kernel_cap_t *effective,
 			       kernel_cap_t *inheritable,
 			       kernel_cap_t *permitted)
 {
-	struct task_struct *g, *target;
+	struct pid_namespace *ns = task_active_pid_ns(current);
+	struct task_struct *target;
 	int ret = -EPERM;
 	int found = 0;
+	struct pid *pid;
+	int nr;
 
-	do_each_thread(g, target) {
-		if (target == current || is_container_init(target->group_leader))
+	nr = 0;
+	while ((pid = find_ge_pid(nr + 1, ns))) {
+		nr = pid_nr_ns(pid, ns);
+		target = pid_task(pid, PIDTYPE_PID);
+
+		if (target == current || task_tgid(target) == ns->child_reaper)
 			continue;
 		found = 1;
 		if (security_capset_check(target, effective, inheritable,
@@ -211,7 +218,7 @@ static inline int cap_set_all(kernel_cap_t *effective,
 			continue;
 		ret = 0;
 		security_capset_set(target, effective, inheritable, permitted);
-	} while_each_thread(g, target);
+	}
 
 	if (!found)
 		ret = 0;
-- 
1.5.3.rc6.17.g1911
