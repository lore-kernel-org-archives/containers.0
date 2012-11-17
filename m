From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/3] netcls_cgroup: introduce cgroup_cls_state->is_local
Date: Fri, 16 Nov 2012 19:31:01 -0800
Message-ID: <1353123062-23193-3-git-send-email-tj@kernel.org>
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

cs->is_local will be used to indicate whether the cgroup has its own
configuration or inherited from the parent.  It's set when classid is
configured by writing a positive value to cgroup file
"net_cls.classid" and cleared when a negative value is written.

is_local is visible to userland via cgroup file "net_cls.is_local" so
that userland can know whether a cgroup has its config or not.

This patch doesn't yet change hierarchy behavior.  The next patch will
use is_local to implement proper hierarchy.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/net/cls_cgroup.h |  1 +
 net/sched/cls_cgroup.c   | 23 ++++++++++++++++++++---
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index b6a6eeb..5759d98 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -22,6 +22,7 @@ struct cgroup_cls_state
 {
 	struct cgroup_subsys_state css;
 	u32 classid;
+	bool is_local;	/* class id is explicitly configured for this cgroup */
 };
 
 extern void sock_update_classid(struct sock *sk);
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 80a80c4..6e3ef64 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -70,19 +70,36 @@ static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
 	return cgrp_cls_state(cgrp)->classid;
 }
 
-static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
+static int write_classid(struct cgroup *cgrp, struct cftype *cft,
+			 const char *buf)
 {
+	struct cgroup_cls_state *cs = cgrp_cls_state(cgrp);
+	s64 v;
+
+	if (sscanf(buf, "%lld", &v) != 1)
+		return -EINVAL;
+
 	mutex_lock(&netcls_mutex);
-	cgrp_cls_state(cgrp)->classid = (u32) value;
+	cs->classid = clamp_val(v, 0, UINT_MAX);
+	cs->is_local = v >= 0;
 	mutex_unlock(&netcls_mutex);
 	return 0;
 }
 
+static u64 read_is_local(struct cgroup *cgrp, struct cftype *cft)
+{
+	return cgrp_cls_state(cgrp)->is_local;
+}
+
 static struct cftype ss_files[] = {
 	{
 		.name = "classid",
 		.read_u64 = read_classid,
-		.write_u64 = write_classid,
+		.write_string = write_classid,
+	},
+	{
+		.name = "is_local",
+		.read_u64 = read_is_local,
 	},
 	{ }	/* terminate */
 };
-- 
1.7.11.7
