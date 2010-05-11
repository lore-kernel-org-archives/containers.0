From: tip-bot for Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [tip:sched/core] sched, wait: Use wrapper functions
Date: Tue, 11 May 2010 18:30:41 GMT
Message-ID: <tip-a93d2f1744206827ccf416e2cdc5018aa503314e__30176.0802198716$1273602753$gmane$org@git.kernel.org>
References: <1273214006-2979-1-git-send-email-xiaosuo@gmail.com>
Reply-To: mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org,
        containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org,
        tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1273214006-2979-1-git-send-email-xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
To: linux-tip-commits-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org
List-Id: containers.vger.kernel.org

Commit-ID:  a93d2f1744206827ccf416e2cdc5018aa503314e
Gitweb:     http://git.kernel.org/tip/a93d2f1744206827ccf416e2cdc5018aa503314e
Author:     Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
AuthorDate: Fri, 7 May 2010 14:33:26 +0800
Committer:  Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
CommitDate: Tue, 11 May 2010 17:43:58 +0200

sched, wait: Use wrapper functions

epoll should not touch flags in wait_queue_t. This patch introduces a new
function __add_wait_queue_exclusive(), for the users, who use wait queue as a
LIFO queue.

__add_wait_queue_tail_exclusive() is introduced too instead of
add_wait_queue_exclusive_locked(). remove_wait_queue_locked() is removed, as
it is a duplicate of __remove_wait_queue(), disliked by users, and with less
users.

Signed-off-by: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Davide Libenzi <davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org>
Cc: <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
LKML-Reference: <1273214006-2979-1-git-send-email-xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
---
 fs/eventpoll.c       |    3 +--
 include/linux/wait.h |   35 +++++++++++++++--------------------
 kernel/cgroup.c      |    2 +-
 kernel/sched.c       |    3 +--
 4 files changed, 18 insertions(+), 25 deletions(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index bd056a5..3817149 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1140,8 +1140,7 @@ retry:
 		 * ep_poll_callback() when events will become available.
 		 */
 		init_waitqueue_entry(&wait, current);
-		wait.flags |= WQ_FLAG_EXCLUSIVE;
-		__add_wait_queue(&ep->wq, &wait);
+		__add_wait_queue_exclusive(&ep->wq, &wait);
 
 		for (;;) {
 			/*
diff --git a/include/linux/wait.h b/include/linux/wait.h
index a48e16b..76d96d0 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -127,12 +127,26 @@ static inline void __add_wait_queue(wait_queue_head_t *head, wait_queue_t *new)
 /*
  * Used for wake-one threads:
  */
+static inline void __add_wait_queue_exclusive(wait_queue_head_t *q,
+					      wait_queue_t *wait)
+{
+	wait->flags |= WQ_FLAG_EXCLUSIVE;
+	__add_wait_queue(q, wait);
+}
+
 static inline void __add_wait_queue_tail(wait_queue_head_t *head,
-						wait_queue_t *new)
+					 wait_queue_t *new)
 {
 	list_add_tail(&new->task_list, &head->task_list);
 }
 
+static inline void __add_wait_queue_tail_exclusive(wait_queue_head_t *q,
+					      wait_queue_t *wait)
+{
+	wait->flags |= WQ_FLAG_EXCLUSIVE;
+	__add_wait_queue_tail(q, wait);
+}
+
 static inline void __remove_wait_queue(wait_queue_head_t *head,
 							wait_queue_t *old)
 {
@@ -404,25 +418,6 @@ do {									\
 })
 
 /*
- * Must be called with the spinlock in the wait_queue_head_t held.
- */
-static inline void add_wait_queue_exclusive_locked(wait_queue_head_t *q,
-						   wait_queue_t * wait)
-{
-	wait->flags |= WQ_FLAG_EXCLUSIVE;
-	__add_wait_queue_tail(q,  wait);
-}
-
-/*
- * Must be called with the spinlock in the wait_queue_head_t held.
- */
-static inline void remove_wait_queue_locked(wait_queue_head_t *q,
-					    wait_queue_t * wait)
-{
-	__remove_wait_queue(q,  wait);
-}
-
-/*
  * These are the old interfaces to sleep waiting for an event.
  * They are racy.  DO NOT use them, use the wait_event* interfaces above.
  * We plan to remove these interfaces.
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e2769e1..4a07d05 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3010,7 +3010,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 	unsigned long flags = (unsigned long)key;
 
 	if (flags & POLLHUP) {
-		remove_wait_queue_locked(event->wqh, &event->wait);
+		__remove_wait_queue(event->wqh, &event->wait);
 		spin_lock(&cgrp->event_list_lock);
 		list_del(&event->list);
 		spin_unlock(&cgrp->event_list_lock);
diff --git a/kernel/sched.c b/kernel/sched.c
index 39aa9c7..b531d79 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -3983,8 +3983,7 @@ do_wait_for_common(struct completion *x, long timeout, int state)
 	if (!x->done) {
 		DECLARE_WAITQUEUE(wait, current);
 
-		wait.flags |= WQ_FLAG_EXCLUSIVE;
-		__add_wait_queue_tail(&x->wait, &wait);
+		__add_wait_queue_tail_exclusive(&x->wait, &wait);
 		do {
 			if (signal_pending_state(state, current)) {
 				timeout = -ERESTARTSYS;
