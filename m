From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/3] netcls_cgroup: introduce netcls_mutex
Date: Fri, 16 Nov 2012 19:31:00 -0800
Message-ID: <1353123062-23193-2-git-send-email-tj@kernel.org>
References: <1353123062-23193-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353123062-23193-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

Introduce netcls_mutex to synchronize modifications to
cgroup_cls_state.  New cgrp now inherits classid from ->css_online()
and write_classid() updates classid while holdin netcls_mutex.

As write_classid() doesn't propagate new configuration downwards, this
currently doesn't make any userland-visible difference, but will help
implementing proper hierarchy support.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 net/sched/cls_cgroup.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 8cdc18e..80a80c4 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -17,11 +17,14 @@
 #include <linux/skbuff.h>
 #include <linux/cgroup.h>
 #include <linux/rcupdate.h>
+#include <linux/mutex.h>
 #include <net/rtnetlink.h>
 #include <net/pkt_cls.h>
 #include <net/sock.h>
 #include <net/cls_cgroup.h>
 
+static DEFINE_MUTEX(netcls_mutex);
+
 static inline struct cgroup_cls_state *cgrp_cls_state(struct cgroup *cgrp)
 {
 	return container_of(cgroup_subsys_state(cgrp, net_cls_subsys_id),
@@ -42,12 +45,21 @@ static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 	if (!cs)
 		return ERR_PTR(-ENOMEM);
 
-	if (cgrp->parent)
-		cs->classid = cgrp_cls_state(cgrp->parent)->classid;
-
 	return &cs->css;
 }
 
+/* @cgrp coming online, inherit the parent's classid */
+static int cgrp_css_online(struct cgroup *cgrp)
+{
+	if (!cgrp->parent)
+		return 0;
+
+	mutex_lock(&netcls_mutex);
+	cgrp_cls_state(cgrp)->classid = cgrp_cls_state(cgrp->parent)->classid;
+	mutex_unlock(&netcls_mutex);
+	return 0;
+}
+
 static void cgrp_css_free(struct cgroup *cgrp)
 {
 	kfree(cgrp_cls_state(cgrp));
@@ -60,7 +72,9 @@ static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
 
 static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
 {
+	mutex_lock(&netcls_mutex);
 	cgrp_cls_state(cgrp)->classid = (u32) value;
+	mutex_unlock(&netcls_mutex);
 	return 0;
 }
 
@@ -76,6 +90,7 @@ static struct cftype ss_files[] = {
 struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
 	.css_alloc	= cgrp_css_alloc,
+	.css_online	= cgrp_css_online,
 	.css_free	= cgrp_css_free,
 	.subsys_id	= net_cls_subsys_id,
 	.base_cftypes	= ss_files,
-- 
1.7.11.7
