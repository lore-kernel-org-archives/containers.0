From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/6] Container Freezer: Rename check_if_frozen()
Date: Tue, 19 Aug 2008 16:22:37 -0700
Message-ID: <20080819232234.999956217__11442.4721491107$1219189399$gmane$org@us.ibm.com>
References: <20080819232232.432973784@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

check_if_frozen() sounds like it should return something when in fact it's just
updating the freezer state.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---
 kernel/cgroup_freezer.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

Index: linux-2.6.27-rc1-mm1/kernel/cgroup_freezer.c
===================================================================
--- linux-2.6.27-rc1-mm1.orig/kernel/cgroup_freezer.c
+++ linux-2.6.27-rc1-mm1/kernel/cgroup_freezer.c
@@ -201,8 +201,8 @@ static void freezer_fork(struct cgroup_s
 /*
  * caller must hold freezer->lock
  */
-static void check_if_frozen(struct cgroup *cgroup,
-			     struct freezer *freezer)
+static void update_freezer_state(struct cgroup *cgroup,
+				 struct freezer *freezer)
 {
 	struct cgroup_iter it;
 	struct task_struct *task;
@@ -222,6 +222,10 @@ static void check_if_frozen(struct cgrou
 	 */
 	if (nfrozen == ntotal)
 		freezer->state = CGROUP_FROZEN;
+	else if (nfrozen > 0)
+		freezer->state = CGROUP_FREEZING;
+	else
+		freezer->state = CGROUP_THAWED;
 	cgroup_iter_end(cgroup, &it);
 }
 
@@ -240,7 +244,7 @@ static int freezer_read(struct cgroup *c
 	if (state == CGROUP_FREEZING) {
 		/* We change from FREEZING to FROZEN lazily if the cgroup was
 		 * only partially frozen when we exitted write. */
-		check_if_frozen(cgroup, freezer);
+		update_freezer_state(cgroup, freezer);
 		state = freezer->state;
 	}
 	spin_unlock_irq(&freezer->lock);
@@ -301,7 +305,7 @@ static int freezer_change_state(struct c
 
 	freezer = cgroup_freezer(cgroup);
 	spin_lock_irq(&freezer->lock);
-	check_if_frozen(cgroup, freezer); /* may update freezer->state */
+	update_freezer_state(cgroup, freezer);
 	if (goal_state == freezer->state)
 		goto out;
 	switch (freezer->state) {

-- 
