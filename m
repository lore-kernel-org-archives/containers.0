From: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
Subject: [PATCH 1/3] cgroup_freezer: Unnecessary test in
	cgroup_freezing_or_frozen
Date: Thu, 12 Aug 2010 11:45:21 +0200
Message-ID: <1281606323-16245-2-git-send-email-tomasz.buchert__34977.434462826$1281606394$gmane$org@inria.fr>
References: <1281470001-14320-1-git-send-email-tomasz.buchert@inria.fr>
	<1281606323-16245-1-git-send-email-tomasz.buchert@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1281606323-16245-1-git-send-email-tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
List-Id: containers.vger.kernel.org

The root freezer_state is always CGROUP_THAWED so we can remove
the special case from the code. The test itself can be handy
and is extracted to static function.

Signed-off-by: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
---
 kernel/cgroup_freezer.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index ce71ed5..321e2a0 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -48,20 +48,19 @@ static inline struct freezer *task_freezer(struct task_struct *task)
 			    struct freezer, css);
 }
 
-int cgroup_freezing_or_frozen(struct task_struct *task)
+static inline int __cgroup_freezing_or_frozen(struct task_struct *task)
 {
-	struct freezer *freezer;
-	enum freezer_state state;
+	enum freezer_state state = task_freezer(task)->state;
+	return (state == CGROUP_FREEZING) || (state == CGROUP_FROZEN);
+}
 
+int cgroup_freezing_or_frozen(struct task_struct *task)
+{
+	int result;
 	task_lock(task);
-	freezer = task_freezer(task);
-	if (!freezer->css.cgroup->parent)
-		state = CGROUP_THAWED; /* root cgroup can't be frozen */
-	else
-		state = freezer->state;
+	result = __cgroup_freezing_or_frozen(task);
 	task_unlock(task);
-
-	return (state == CGROUP_FREEZING) || (state == CGROUP_FROZEN);
+	return result;
 }
 
 /*
-- 
1.6.3.3
