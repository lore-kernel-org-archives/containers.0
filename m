From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 4/7] cgroups: Mark some subsystems bindable
Date: Fri, 22 Oct 2010 16:11:08 +0800
Message-ID: <4CC1471C.9070403__30152.6939533234$1287735101$gmane$org@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC146A4.9090505-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

For those subsystems (debug, cpuacct, net_cls and devices),
setting the can_bind flag is sufficient.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c          |    1 +
 kernel/sched.c           |    1 +
 net/sched/cls_cgroup.c   |    1 +
 security/device_cgroup.c |    1 +
 4 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9ce3fdb..6364bb5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5124,5 +5124,6 @@ struct cgroup_subsys debug_subsys = {
 	.destroy = debug_destroy,
 	.populate = debug_populate,
 	.subsys_id = debug_subsys_id,
+	.can_bind = 1,
 };
 #endif /* CONFIG_CGROUP_DEBUG */
diff --git a/kernel/sched.c b/kernel/sched.c
index 51944e8..cae104f 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -9329,6 +9329,7 @@ struct cgroup_subsys cpuacct_subsys = {
 	.destroy = cpuacct_destroy,
 	.populate = cpuacct_populate,
 	.subsys_id = cpuacct_subsys_id,
+	.can_bind = 1,
 };
 #endif	/* CONFIG_CGROUP_CPUACCT */
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 37dff78..020ddfe 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -38,6 +38,7 @@ struct cgroup_subsys net_cls_subsys = {
 #define net_cls_subsys_id net_cls_subsys.subsys_id
 #endif
 	.module		= THIS_MODULE,
+	.can_bind	= 1,
 };
 
 
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 8d9c48f..b8136fc 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -473,6 +473,7 @@ struct cgroup_subsys devices_subsys = {
 	.destroy = devcgroup_destroy,
 	.populate = devcgroup_populate,
 	.subsys_id = devices_subsys_id,
+	.can_bind = 1,
 };
 
 int devcgroup_inode_permission(struct inode *inode, int mask)
-- 
1.7.0.1
