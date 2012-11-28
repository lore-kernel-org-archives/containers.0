From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/13] cpuset: introduce CS_ONLINE
Date: Wed, 28 Nov 2012 13:34:11 -0800
Message-ID: <1354138460-19286-5-git-send-email-tj__35085.2122800008$1354138514$gmane$org@kernel.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1354138460-19286-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Add CS_ONLINE which is set from css_online() and cleared from
css_offline().  This will enable using generic cgroup iterator while
allowing decoupling cpuset from cgroup internal locking.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cpuset.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 70197ba..22b521d 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -138,6 +138,7 @@ static inline bool task_has_mempolicy(struct task_struct *task)
 
 /* bits in struct cpuset flags field */
 typedef enum {
+	CS_ONLINE,
 	CS_CPU_EXCLUSIVE,
 	CS_MEM_EXCLUSIVE,
 	CS_MEM_HARDWALL,
@@ -154,6 +155,11 @@ enum hotplug_event {
 };
 
 /* convenient tests for these bits */
+static inline bool is_cpuset_online(const struct cpuset *cs)
+{
+	return test_bit(CS_ONLINE, &cs->flags);
+}
+
 static inline int is_cpu_exclusive(const struct cpuset *cs)
 {
 	return test_bit(CS_CPU_EXCLUSIVE, &cs->flags);
@@ -190,7 +196,8 @@ static inline int is_spread_slab(const struct cpuset *cs)
 }
 
 static struct cpuset top_cpuset = {
-	.flags = ((1 << CS_CPU_EXCLUSIVE) | (1 << CS_MEM_EXCLUSIVE)),
+	.flags = ((1 << CS_ONLINE) | (1 << CS_CPU_EXCLUSIVE) |
+		  (1 << CS_MEM_EXCLUSIVE)),
 };
 
 /*
@@ -1822,6 +1829,7 @@ static int cpuset_css_online(struct cgroup *cgrp)
 	if (!parent)
 		return 0;
 
+	set_bit(CS_ONLINE, &cs->flags);
 	if (is_spread_page(parent))
 		set_bit(CS_SPREAD_PAGE, &cs->flags);
 	if (is_spread_slab(parent))
@@ -1871,6 +1879,7 @@ static void cpuset_css_offline(struct cgroup *cgrp)
 		update_flag(CS_SCHED_LOAD_BALANCE, cs, 0);
 
 	number_of_cpusets--;
+	clear_bit(CS_ONLINE, &cs->flags);
 
 	cgroup_unlock();
 }
-- 
1.7.11.7
