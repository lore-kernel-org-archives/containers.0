From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] Add socket list helper functions
Date: Wed,  7 Oct 2009 09:29:04 -0700
Message-ID: <1254932945-12578-2-git-send-email-danms@us.ibm.com>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1254932945-12578-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

The INET patch needs to maintain a list of listening sockets in order to
support post-restart socket hashing.  The ckpt_ctx_free() function thus
needs to clean up that list after processing the deferqueue, and needs to
know something about what is on that list.  Instead of calling into a
single cleanup function in the checkpoint code, I decided to just make
the list itself a little more abstract and separate it here.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h |    5 +++++
 net/checkpoint.c           |   42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index dd75bc2..89e41c2 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -100,6 +100,11 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 			      struct socket *socket,
 			      struct sockaddr *loc, unsigned *loc_len,
 			      struct sockaddr *rem, unsigned *rem_len);
+int sock_list_add(struct list_head *list, struct sock *sk);
+typedef int (*sock_compare_fn)(struct sock *, struct sock *);
+struct sock *sock_list_find(struct list_head *list, struct sock *sk,
+			    sock_compare_fn cmp);
+void sock_list_free(struct list_head *list);
 
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 9a72aae..e7e8e75 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -758,3 +758,45 @@ struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 
 	return file;
 }
+
+struct ckpt_sock_list_item {
+       struct sock *sk;
+       struct list_head list;
+};
+
+int sock_list_add(struct list_head *list, struct sock *sk)
+{
+	struct ckpt_sock_list_item *item;
+
+	item = kmalloc(sizeof(*item), GFP_KERNEL);
+	if (!item)
+		return -ENOMEM;
+
+	item->sk = sk;
+	list_add(&item->list, list);
+
+	return 0;
+}
+
+void sock_list_free(struct list_head *list)
+{
+	struct ckpt_sock_list_item *item, *tmp;
+
+	list_for_each_entry_safe(item, tmp, list, list) {
+		list_del(&item->list);
+		kfree(item);
+	}
+}
+
+struct sock *sock_list_find(struct list_head *list, struct sock *sk,
+			    sock_compare_fn cmp)
+{
+	struct ckpt_sock_list_item *item;
+
+	list_for_each_entry(item, list, list) {
+		if (cmp(sk, item->sk))
+			return item->sk;
+	}
+
+	return NULL;
+}
-- 
1.6.2.5
