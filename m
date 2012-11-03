From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 8/9] cgroup_freezer: add ->post_create() and ->pre_destroy()
	and track online state
Date: Sat,  3 Nov 2012 01:38:34 -0700
Message-ID: <1351931915-1701-9-git-send-email-tj@kernel.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351931915-1701-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org
Cc: linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

A cgroup is online and visible to iteration between ->post_create()
and ->pre_destroy().  This patch introduces CGROUP_FREEZER_ONLINE and
toggles it from the newly added freezer_post_create() and
freezer_pre_destroy() while holding freezer->lock such that a
cgroup_freezer can be reilably distinguished to be online.  This will
be used by full hierarchy support.

ONLINE test is added to freezer_apply_state() but it currently doesn't
make any difference as freezer_write() can only be called for an
online cgroup.

Adjusting system_freezing_cnt on destruction is moved from
freezer_destroy() to the new freezer_pre_destroy() for consistency.

This patch doesn't introduce any noticeable behavior change.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup_freezer.c | 42 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 40 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index b8ad93c..4f12d31 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -23,6 +23,7 @@
 #include <linux/seq_file.h>
 
 enum freezer_state_flags {
+	CGROUP_FREEZER_ONLINE	= (1 << 0), /* freezer is fully online */
 	CGROUP_FREEZING_SELF	= (1 << 1), /* this freezer is freezing */
 	CGROUP_FREEZING_PARENT	= (1 << 2), /* the parent freezer is freezing */
 	CGROUP_FROZEN		= (1 << 3), /* this and its descendants frozen */
@@ -98,13 +99,45 @@ static struct cgroup_subsys_state *freezer_create(struct cgroup *cgroup)
 	return &freezer->css;
 }
 
-static void freezer_destroy(struct cgroup *cgroup)
+/**
+ * freezer_post_create - commit creation of a freezer cgroup
+ * @cgroup: cgroup being created
+ *
+ * We're committing to creation of @cgroup.  Mark it online.
+ */
+static void freezer_post_create(struct cgroup *cgroup)
 {
 	struct freezer *freezer = cgroup_freezer(cgroup);
 
+	spin_lock_irq(&freezer->lock);
+	freezer->state |= CGROUP_FREEZER_ONLINE;
+	spin_unlock_irq(&freezer->lock);
+}
+
+/**
+ * freezer_pre_destroy - initiate destruction of @cgroup
+ * @cgroup: cgroup being destroyed
+ *
+ * @cgroup is going away.  Mark it dead and decrement system_freezing_count
+ * if it was holding one.
+ */
+static void freezer_pre_destroy(struct cgroup *cgroup)
+{
+	struct freezer *freezer = cgroup_freezer(cgroup);
+
+	spin_lock_irq(&freezer->lock);
+
 	if (freezer->state & CGROUP_FREEZING)
 		atomic_dec(&system_freezing_cnt);
-	kfree(freezer);
+
+	freezer->state = 0;
+
+	spin_unlock_irq(&freezer->lock);
+}
+
+static void freezer_destroy(struct cgroup *cgroup)
+{
+	kfree(cgroup_freezer(cgroup));
 }
 
 /*
@@ -260,6 +293,9 @@ static void freezer_apply_state(struct freezer *freezer, bool freeze,
 	/* also synchronizes against task migration, see freezer_attach() */
 	lockdep_assert_held(&freezer->lock);
 
+	if (!(freezer->state & CGROUP_FREEZER_ONLINE))
+		return;
+
 	if (freeze) {
 		if (!(freezer->state & CGROUP_FREEZING))
 			atomic_inc(&system_freezing_cnt);
@@ -347,6 +383,8 @@ static struct cftype files[] = {
 struct cgroup_subsys freezer_subsys = {
 	.name		= "freezer",
 	.create		= freezer_create,
+	.post_create	= freezer_post_create,
+	.pre_destroy	= freezer_pre_destroy,
 	.destroy	= freezer_destroy,
 	.subsys_id	= freezer_subsys_id,
 	.attach		= freezer_attach,
-- 
1.7.11.7
