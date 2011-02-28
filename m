From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/3] block: introduce REQ_DIRECT to track direct io bio
Date: Mon, 28 Feb 2011 11:15:03 +0100
Message-ID: <1298888105-3778-2-git-send-email-arighi__28794.9009718888$1298888402$gmane$org@develer.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298888105-3778-1-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Introduce a new flag to identify if a bio has been generated for a
direct IO operation.

This flag is used by the blkio controller to identify if a write IO
request has been issued by the current task and can be limited directly
or if it has been generated from another IO context, as a result of a
buffered IO operation.

Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
---
 fs/direct-io.c            |    1 +
 include/linux/blk_types.h |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index b044705..fe364a4 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -361,6 +361,7 @@ static void dio_bio_submit(struct dio *dio)
 	unsigned long flags;
 
 	bio->bi_private = dio;
+	bio->bi_rw |= REQ_DIRECT;
 
 	spin_lock_irqsave(&dio->bio_lock, flags);
 	dio->refcount++;
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 46ad519..2f98c03 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -130,6 +130,7 @@ enum rq_flag_bits {
 	/* bio only flags */
 	__REQ_UNPLUG,		/* unplug the immediately after submission */
 	__REQ_RAHEAD,		/* read ahead, can fail anytime */
+	__REQ_DIRECT,		/* direct io request */
 	__REQ_THROTTLED,	/* This bio has already been subjected to
 				 * throttling rules. Don't do it again. */
 
@@ -173,6 +174,7 @@ enum rq_flag_bits {
 #define REQ_UNPLUG		(1 << __REQ_UNPLUG)
 #define REQ_RAHEAD		(1 << __REQ_RAHEAD)
 #define REQ_THROTTLED		(1 << __REQ_THROTTLED)
+#define REQ_DIRECT		(1 << __REQ_DIRECT)
 
 #define REQ_SORTED		(1 << __REQ_SORTED)
 #define REQ_SOFTBARRIER		(1 << __REQ_SOFTBARRIER)
-- 
1.7.1
