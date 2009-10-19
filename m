From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] epoll: Add support for restoring many epoll items
Date: Mon, 19 Oct 2009 10:04:33 -0700
Message-ID: <8e4344b801150b95cd54f2d09b660525601de256.1255971848.git.matthltc@us.ibm.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This completes the work necessary to make checkpoint/restart of
thousands of epoll items more reliable when higher order kmallocs
would fail. We grab a piece of memory suitable to store a "chunk"
of items for input. Read the input one chunk at a time and add
epoll items for each item in the chunk.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/eventpoll.c |   58 +++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 37 insertions(+), 21 deletions(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 2506b40..c261263 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1594,7 +1594,7 @@ static int ep_items_restore(void *data)
 	struct ckpt_eventpoll_item *items = NULL;
 	struct eventpoll *ep;
 	struct file *epfile = NULL;
-	int ret, num_items, i = 0;
+	int ret, num_items, nchunk;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_EPOLL_ITEMS);
 	if (IS_ERR(h))
@@ -1611,34 +1611,50 @@ static int ep_items_restore(void *data)
 	if (!num_items)
 		return 0;
 
-	ret = ckpt_read_payload(ctx, (void**)&items, num_items*sizeof(*items),
-				CKPT_HDR_BUFFER);
+	ret = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_BUFFER);
+	if (ret < 0)
+		return ret;
+	/* Make sure the items match the size we expect */
+	if (num_items != (ret / sizeof(*items)))
+		return -EINVAL;
+
+	nchunk = num_items;
+	do {
+		items = kzalloc(sizeof(*items)*nchunk, GFP_KERNEL);
+		if (items)
+			break;
+		nchunk = nchunk/2;
+	} while (nchunk > 0);
 	if (!items)
 		return -ENOMEM;
 
-	/* Make sure the items match the size we expect */
-	if (num_items != (ret / sizeof(*items))) {
-		ret = -EINVAL;
-		goto out;
-	}
-
 	ep = epfile->private_data;
 
-	/* Restore the epoll items/watches */
-	for (ret = 0, i = 0; !ret && i < num_items; i++) {
-		struct epoll_event epev;
-		struct file *tfile;
+	while (num_items > 0) {
+		int n = min(num_items, nchunk);
+		int j;
 
-		tfile = ckpt_obj_fetch(ctx, items[i].file_objref,
-				       CKPT_OBJ_FILE);
-		if (IS_ERR(tfile)) {
-			ret = PTR_ERR(tfile);
+		ret = ckpt_kread(ctx, items, n*sizeof(*items));
+		if (ret < 0)
 			break;
+
+		/* Restore the epoll items/watches */
+		for (j = 0; !ret && j < n; j++) {
+			struct epoll_event epev;
+			struct file *tfile;
+
+			tfile = ckpt_obj_fetch(ctx, items[j].file_objref,
+					       CKPT_OBJ_FILE);
+			if (IS_ERR(tfile)) {
+				ret = PTR_ERR(tfile);
+				goto out;
+			}
+			epev.events = items[j].events;
+			epev.data = items[j].data;
+			ret = do_epoll_ctl(EPOLL_CTL_ADD, items[j].fd,
+					   epfile, tfile, &epev);
 		}
-		epev.events = items[i].events;
-		epev.data = items[i].data;
-		ret = do_epoll_ctl(EPOLL_CTL_ADD, items[i].fd,
-				   epfile, tfile, &epev);
+		num_items -= n;
 	}
 out:
 	kfree(items);
-- 
1.5.6.3
