From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH pm-freezer 1/4] cgroup_freezer: fix freezer->state setting
	bug in freezer_change_state()
Date: Wed, 31 Aug 2011 12:21:07 +0200
Message-ID: <20110831102100.GA2828__38230.7291300551$1314908666$gmane$org@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

d02f52811d0e "cgroup_freezer: prepare for removal of TIF_FREEZE" moved
setting of freezer->state into freezer_change_state(); unfortunately,
while doing so, when it's beginning to freeze tasks, it sets the state
to CGROUP_FROZEN instead of CGROUP_FREEZING ending up skipping the
whole freezing state.  Fix it.

-v2: Oleg pointed out that re-freezing FROZEN cgroup could increment
     system_freezing_cnt.  Fixed.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reported-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
---
I'm in the process of moving and can only use a quite old laptop.  I
tested compile but couldn't really do much else, so please proceed
with caution.  Oleg, can you please ack the patches if you agree with
the updated versions?

Thanks.

 kernel/cgroup_freezer.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

Index: work/kernel/cgroup_freezer.c
===================================================================
--- work.orig/kernel/cgroup_freezer.c
+++ work/kernel/cgroup_freezer.c
@@ -308,24 +308,26 @@ static int freezer_change_state(struct c
 	spin_lock_irq(&freezer->lock);
 
 	update_if_frozen(cgroup, freezer);
-	if (goal_state == freezer->state)
-		goto out;
-
-	freezer->state = goal_state;
 
 	switch (goal_state) {
 	case CGROUP_THAWED:
-		atomic_dec(&system_freezing_cnt);
-		unfreeze_cgroup(cgroup, freezer);
+		if (freezer->state != CGROUP_THAWED) {
+			freezer->state = CGROUP_THAWED;
+			atomic_dec(&system_freezing_cnt);
+			unfreeze_cgroup(cgroup, freezer);
+		}
 		break;
 	case CGROUP_FROZEN:
-		atomic_inc(&system_freezing_cnt);
-		retval = try_to_freeze_cgroup(cgroup, freezer);
+		if (freezer->state == CGROUP_THAWED) {
+			freezer->state = CGROUP_FREEZING;
+			atomic_inc(&system_freezing_cnt);
+			retval = try_to_freeze_cgroup(cgroup, freezer);
+		}
 		break;
 	default:
 		BUG();
 	}
-out:
+
 	spin_unlock_irq(&freezer->lock);
 
 	return retval;
