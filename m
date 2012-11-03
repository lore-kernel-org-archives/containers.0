From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/9] cgroup_freezer: prepare freezer_change_state() for full
	hierarchy support
Date: Sat,  3 Nov 2012 01:38:31 -0700
Message-ID: <1351931915-1701-6-git-send-email-tj@kernel.org>
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

* Make freezer_change_state() take bool @freeze instead of enum
  freezer_state.

* Separate out freezer_apply_state() out of freezer_change_state().
  This makes freezer_change_state() a rather silly thin wrapper.  It
  will be filled with hierarchy handling later on.

This patch doesn't introduce any behavior change.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup_freezer.c | 48 ++++++++++++++++++++++++++++++------------------
 1 file changed, 30 insertions(+), 18 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 975b3d8..2690830 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -247,45 +247,57 @@ static void unfreeze_cgroup(struct freezer *freezer)
 	cgroup_iter_end(cgroup, &it);
 }
 
-static void freezer_change_state(struct freezer *freezer,
-				 enum freezer_state goal_state)
+/**
+ * freezer_apply_state - apply state change to a single cgroup_freezer
+ * @freezer: freezer to apply state change to
+ * @freeze: whether to freeze or unfreeze
+ */
+static void freezer_apply_state(struct freezer *freezer, bool freeze)
 {
 	/* also synchronizes against task migration, see freezer_attach() */
-	spin_lock_irq(&freezer->lock);
+	lockdep_assert_held(&freezer->lock);
 
-	switch (goal_state) {
-	case CGROUP_THAWED:
-		if (freezer->state != CGROUP_THAWED)
-			atomic_dec(&system_freezing_cnt);
-		freezer->state = CGROUP_THAWED;
-		unfreeze_cgroup(freezer);
-		break;
-	case CGROUP_FROZEN:
+	if (freeze) {
 		if (freezer->state == CGROUP_THAWED)
 			atomic_inc(&system_freezing_cnt);
 		freezer->state = CGROUP_FREEZING;
 		freeze_cgroup(freezer);
-		break;
-	default:
-		BUG();
+	} else {
+		if (freezer->state != CGROUP_THAWED)
+			atomic_dec(&system_freezing_cnt);
+		freezer->state = CGROUP_THAWED;
+		unfreeze_cgroup(freezer);
 	}
+}
 
+/**
+ * freezer_change_state - change the freezing state of a cgroup_freezer
+ * @freezer: freezer of interest
+ * @freeze: whether to freeze or thaw
+ *
+ * Freeze or thaw @cgroup according to @freeze.
+ */
+static void freezer_change_state(struct freezer *freezer, bool freeze)
+{
+	/* update @freezer */
+	spin_lock_irq(&freezer->lock);
+	freezer_apply_state(freezer, freeze);
 	spin_unlock_irq(&freezer->lock);
 }
 
 static int freezer_write(struct cgroup *cgroup, struct cftype *cft,
 			 const char *buffer)
 {
-	enum freezer_state goal_state;
+	bool freeze;
 
 	if (strcmp(buffer, freezer_state_strs[CGROUP_THAWED]) == 0)
-		goal_state = CGROUP_THAWED;
+		freeze = false;
 	else if (strcmp(buffer, freezer_state_strs[CGROUP_FROZEN]) == 0)
-		goal_state = CGROUP_FROZEN;
+		freeze = true;
 	else
 		return -EINVAL;
 
-	freezer_change_state(cgroup_freezer(cgroup), goal_state);
+	freezer_change_state(cgroup_freezer(cgroup), freeze);
 	return 0;
 }
 
-- 
1.7.11.7
