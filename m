From: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] list.h: add debug version of list_empty
Date: Tue, 15 Mar 2011 15:08:42 +0200
Message-ID: <1300194523-19325-2-git-send-email-ext-phil.2.carmody__44886.9971013211$1300195147$gmane$org@nokia.com>
References: <1300194523-19325-1-git-send-email-ext-phil.2.carmody@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1300194523-19325-1-git-send-email-ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Heed the notice in list_del: "Note: list_empty() on entry does not
return true after this, the entry is in an undefined state.", and
check for precisely that condition.

There are currently a few instances in the code of this sequence:
    if(!list_empty(pnode))
        list_del(pnode);
which seems to be useless or dangerous if intended to protect from
repeated del's. And given that I've seen an oops pointing to a
dereference of poison in such a list_empty, I'm veering towards
dangerous. This patch would make such errors obvious.

Nothing is changed in the non-DEBUG_LIST build.

Signed-off-by: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
---
 include/linux/list.h |    4 ++++
 lib/list_debug.c     |   18 ++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index 3a54266..59bebd1 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -183,10 +183,14 @@ static inline int list_is_last(const struct list_head *list,
  * list_empty - tests whether a list is empty
  * @head: the list to test.
  */
+#ifndef CONFIG_DEBUG_LIST
 static inline int list_empty(const struct list_head *head)
 {
 	return head->next == head;
 }
+#else
+extern int list_empty(const struct list_head *head);
+#endif
 
 /**
  * list_empty_careful - tests whether a list is empty and not being modified
diff --git a/lib/list_debug.c b/lib/list_debug.c
index b8029a5..aaba728 100644
--- a/lib/list_debug.c
+++ b/lib/list_debug.c
@@ -73,3 +73,21 @@ void list_del(struct list_head *entry)
 	entry->prev = LIST_POISON2;
 }
 EXPORT_SYMBOL(list_del);
+
+/**
+ * list_empty - tests whether a list is empty
+ * @head: the list to test.
+ */
+int list_empty(const struct list_head *head)
+{
+	if ((head->prev == LIST_POISON2) || (head->prev == LIST_POISON1))
+		WARN(1, "list_empty performed on a node "
+		     "at %p removed from a list.\n", head);
+	else
+		WARN((head->prev == head) != (head->next == head),
+		     "list_empty corruption. %p<-%p->%p is half-empty.\n",
+		     head->prev, head, head->next);
+
+	return head->next == head;
+}
+EXPORT_SYMBOL(list_empty);
-- 
1.7.2.rc1.37.gf8c40
