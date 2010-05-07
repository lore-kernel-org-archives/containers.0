From: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2] wait: use wrapper functions
Date: Fri,  7 May 2010 14:33:26 +0800
Message-ID: <1273214006-2979-1-git-send-email-xiaosuo__32518.8879775398$1273222576$gmane$org@gmail.com>
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
Cc: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Davide Libenzi <davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

use wrapper functions

epoll should not touch flags in wait_queue_t. This patch introduces a new
function __add_wait_queue_excl(), for the users, who use wait queue as a
LIFO queue.

__add_wait_queue_tail_excl() is introduced too instead of
add_wait_queue_exclusive_locked(). remove_wait_queue_locked() is removed, as
it is a duplicate of __remove_wait_queue(), disliked by users, and with less
users.

Signed-off-by: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
----
 fs/eventpoll.c       |    3 +--
 include/linux/wait.h |   35 +++++++++++++++--------------------
 kernel/cgroup.c      |    2 +-
 kernel/sched.c       |    3 +--
 4 files changed, 18 insertions(+), 25 deletions(-)
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index bd056a5..a6ba470 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1140,8 +1140,7 @@ retry:
 		 * ep_poll_callback() when events will become available.
 		 */
 		init_waitqueue_entry(&wait, current);
-		wait.flags |= WQ_FLAG_EXCLUSIVE;
-		__add_wait_queue(&ep->wq, &wait);
+		__add_wait_queue_excl(&ep->wq, &wait);
 
 		for (;;) {
 			/*
diff --git a/include/linux/wait.h b/include/linux/wait.h
index a48e16b..4db4147 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -127,12 +127,26 @@ static inline void __add_wait_queue(wait_queue_head_t *head, wait_queue_t *new)
 /*
  * Used for wake-one threads:
  */
+static inline void __add_wait_queue_excl(wait_queue_head_t *q,
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
 
+static inline void __add_wait_queue_tail_excl(wait_queue_head_t *q,
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
index 6af210a..c5c998d 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4039,8 +4039,7 @@ do_wait_for_common(struct completion *x, long timeout, int state)
 	if (!x->done) {
 		DECLARE_WAITQUEUE(wait, current);
 
-		wait.flags |= WQ_FLAG_EXCLUSIVE;
-		__add_wait_queue_tail(&x->wait, &wait);
+		__add_wait_queue_tail_excl(&x->wait, &wait);
 		do {
 			if (signal_pending_state(state, current)) {
 				timeout = -ERESTARTSYS;
