From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace related fix for v4.11-rc2
Date: Mon, 06 Mar 2017 17:08:36 -0600
Message-ID: <87tw76ype3.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, JongHwan Kim <zzoru007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 040757f738e13caaa9c5078bca79aa97e11dde88 ucount: Remove the atomicity from ucount->count

This fixes a race between put_ucounts and get_ucounts that can cause
a use after free.  The fix works by simplifying the code and so there
is not even a temptation to be clever and play spinlock vs atomic
reference games.

Eric


From 040757f738e13caaa9c5078bca79aa97e11dde88 Mon Sep 17 00:00:00 2001
From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date: Sun, 5 Mar 2017 15:03:22 -0600
Subject: [PATCH] ucount: Remove the atomicity from ucount->count

Always increment/decrement ucount->count under the ucounts_lock.  The
increments are there already and moving the decrements there means the
locking logic of the code is simpler.  This simplification in the
locking logic fixes a race between put_ucounts and get_ucounts that
could result in a use-after-free because the count could go zero then
be found by get_ucounts and then be freed by put_ucounts.

A bug presumably this one was found by a combination of syzkaller and
KASAN.  JongWhan Kim reported the syzkaller failure and Dmitry Vyukov
spotted the race in the code.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Fixes: f6b2db1a3e8d ("userns: Make the count of user namespaces per user")
Reported-by: JongHwan Kim <zzoru007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reported-by: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/user_namespace.h |  2 +-
 kernel/ucount.c                | 18 +++++++++++-------
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index be765234c0a2..32354b4b4b2b 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -72,7 +72,7 @@ struct ucounts {
 	struct hlist_node node;
 	struct user_namespace *ns;
 	kuid_t uid;
-	atomic_t count;
+	int count;
 	atomic_t ucount[UCOUNT_COUNTS];
 };
 
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 62630a40ab3a..b4eeee03934f 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -144,7 +144,7 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
 
 		new->ns = ns;
 		new->uid = uid;
-		atomic_set(&new->count, 0);
+		new->count = 0;
 
 		spin_lock_irq(&ucounts_lock);
 		ucounts = find_ucounts(ns, uid, hashent);
@@ -155,8 +155,10 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
 			ucounts = new;
 		}
 	}
-	if (!atomic_add_unless(&ucounts->count, 1, INT_MAX))
+	if (ucounts->count == INT_MAX)
 		ucounts = NULL;
+	else
+		ucounts->count += 1;
 	spin_unlock_irq(&ucounts_lock);
 	return ucounts;
 }
@@ -165,13 +167,15 @@ static void put_ucounts(struct ucounts *ucounts)
 {
 	unsigned long flags;
 
-	if (atomic_dec_and_test(&ucounts->count)) {
-		spin_lock_irqsave(&ucounts_lock, flags);
+	spin_lock_irqsave(&ucounts_lock, flags);
+	ucounts->count -= 1;
+	if (!ucounts->count)
 		hlist_del_init(&ucounts->node);
-		spin_unlock_irqrestore(&ucounts_lock, flags);
+	else
+		ucounts = NULL;
+	spin_unlock_irqrestore(&ucounts_lock, flags);
 
-		kfree(ucounts);
-	}
+	kfree(ucounts);
 }
 
 static inline bool atomic_inc_below(atomic_t *v, int u)
-- 
2.10.1
