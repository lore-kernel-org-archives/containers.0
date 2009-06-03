From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/4] cgroup freezer: Avoid lazy state changes when convenient
Date: Wed,  3 Jun 2009 02:31:19 -0700
Message-ID: <03412f8681d89c99ac575330381ab49f6e5e61ba.1244019829.git.matthltc@us.ibm.com>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<91260d5797bcf233ca54c7b41da8278e99b4ca66.1244019829.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <91260d5797bcf233ca54c7b41da8278e99b4ca66.1244019829.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1244019829.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <cover.1244019829.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

 When all the tasks of a cgroup were successfully frozen we can avoid
 the lazy FREEZING -> FROZEN transition and move into FROZEN during the
 write to freezer.state.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup_freezer.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 765e2c1..19702ac 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -286,7 +286,10 @@ static int try_to_freeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
 	}
 	cgroup_iter_end(cgroup, &it);
 
-	return num_cant_freeze_now ? -EBUSY : 0;
+	if (num_cant_freeze_now)
+		return -EBUSY;
+	freezer->state = CGROUP_FROZEN;
+	return 0;
 }
 
 static void unfreeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
-- 
1.5.6.3
