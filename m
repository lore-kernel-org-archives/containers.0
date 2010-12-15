From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 4/6] cgroups: Mark some subsystems bindable/unbindable
Date: Wed, 15 Dec 2010 17:36:05 +0800
Message-ID: <4D088C05.5060701__6941.22994686968$1292405795$gmane$org@cn.fujitsu.com>
References: <4D088BB5.30903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D088BB5.30903-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

For those subsystems (debug, cpuacct, net_cls and devices),
setting the bindable/unbindable flag is sufficient.

Set freezer subsystem as bindable but not unbindable, because
sub-cgroups' can be in FROZEN state.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c          |    6 +++++-
 kernel/cgroup_freezer.c  |    1 +
 kernel/sched.c           |    2 ++
 security/device_cgroup.c |    2 ++
 4 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 463575d..fa2c5de 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1063,6 +1063,8 @@ static int hierarchy_reset_css_refs(struct cgroup *cgrp, void *data)
 	int i;
 
 	for_each_set_bit(i, &removed_bits, CGROUP_SUBSYS_COUNT) {
+		struct cgroup_subsys_state *css = cgrp->subsys[i];
+
 		if (atomic_read(&css->refcnt) == 0)
 			atomic_set(&css->refcnt, 1);
 	}
@@ -1086,7 +1088,7 @@ static int hierarchy_clear_css_refs(struct cgroup *cgrp, void *data)
 	}
 	return 0;
 failed:
-	hierarchy_reset_css_refs(struct cgroup *cgrp, void *data);
+	hierarchy_reset_css_refs(cgrp, data);
 	return -EBUSY;
 }
 
@@ -5201,5 +5203,7 @@ struct cgroup_subsys debug_subsys = {
 	.destroy = debug_destroy,
 	.populate = debug_populate,
 	.subsys_id = debug_subsys_id,
+	.bindable = true,
+	.unbindable = true,
 };
 #endif /* CONFIG_CGROUP_DEBUG */
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index e7bebb7..213ecd9 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -393,4 +393,5 @@ struct cgroup_subsys freezer_subsys = {
 	.attach		= NULL,
 	.fork		= freezer_fork,
 	.exit		= NULL,
+	.bindable	= true,
 };
diff --git a/kernel/sched.c b/kernel/sched.c
index dc91a4d..930ee2e 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -9346,6 +9346,8 @@ struct cgroup_subsys cpuacct_subsys = {
 	.destroy = cpuacct_destroy,
 	.populate = cpuacct_populate,
 	.subsys_id = cpuacct_subsys_id,
+	.bindable = true,
+	.unbindable = true,
 };
 #endif	/* CONFIG_CGROUP_CPUACCT */
 
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 8d9c48f..51321e9 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -473,6 +473,8 @@ struct cgroup_subsys devices_subsys = {
 	.destroy = devcgroup_destroy,
 	.populate = devcgroup_populate,
 	.subsys_id = devices_subsys_id,
+	.bindable = true,
+	.unbindable = true,
 };
 
 int devcgroup_inode_permission(struct inode *inode, int mask)
-- 
1.6.3
