From: Takuya Yoshikawa <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: [RFC][PATCH -mm] blktrace: adds ioprio to blktrace
Date: Wed, 10 Sep 2008 18:21:48 +0900
Message-ID: <48C791AC.1030305@oss.ntt.co.jp>
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
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

The following patch adds ioprio to blktrace.

Explanation:
As you know, I/O schedulers such as cfq use io_contexts of current
tasks to schedule block I/O. But recently, some are suggesting to
use more appropriate io_contexts obtained by, for example, doing
io-tracking, making struct bio have io_context member, etc. I thought
adding ioprio to blktrace output might be helpful.

Implementation:
1. I used req_get_ioprio() and [new]bio_get_ioprio() to get ioprio.
    Currently bio_get_ioprio just returns current->io_context->ioprio.


Appreciate any comments:
Does this kind of information helpful?


Thanks,
Takuya Yoshikawa



Example:
   8,16   0        1     0.000000000  2664  Q   R ioprio=16386 81920 + 8 [tiotest]
   8,16   0        2     0.000010493  2664  G   R ioprio=16386 81920 + 8 [tiotest]
   8,16   0        3     0.000013217  2664  P   N ioprio=    0 [tiotest]
   8,16   0        4     0.000014164  2664  I   R ioprio=    0 81920 + 8 [tiotest]
   8,16   0        5     0.000019738  2664  U   N ioprio=    0 [tiotest] 2
   8,16   0        6     0.000026737  2664  D   R ioprio=    0 81920 + 8 [tiotest]
   8,16   0        7     0.005455128  2670  Q   R ioprio=16389 327680 + 8 [tiotest]
   8,16   0        8     0.005459912  2670  G   R ioprio=16389 327680 + 8 [tiotest]
   8,16   0        9     0.005460425  2670  P   N ioprio=    0 [tiotest]
   8,16   0       10     0.005460703  2670  I   R ioprio=    0 327680 + 8 [tiotest]
   8,16   0       11     0.005462495  2670  U   N ioprio=    0 [tiotest] 7


===

Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
---
diff -uprN linux-2.6.27-rc5-mm1/block/blktrace.c linux-2.6.27-rc5-mm1-blktrace/block/blktrace.c
--- linux-2.6.27-rc5-mm1/block/blktrace.c	2008-09-10 19:27:44.000000000 +0900
+++ linux-2.6.27-rc5-mm1-blktrace/block/blktrace.c	2008-09-11 00:44:52.000000000 +0900
@@ -120,7 +120,8 @@ static u32 ddir_act[2] __read_mostly = {
   * blk_io_trace structure and places it in a per-cpu subbuffer.
   */
  void __blk_add_trace(struct blk_trace *bt, sector_t sector, int bytes,
-		     int rw, u32 what, int error, int pdu_len, void *pdu_data)
+		     int rw, u32 what, int error, unsigned short ioprio,
+		     int pdu_len, void *pdu_data)
  {
  	struct task_struct *tsk = current;
  	struct blk_io_trace *t;
@@ -168,6 +169,7 @@ void __blk_add_trace(struct blk_trace *b
  		t->device = bt->dev;
  		t->cpu = cpu;
  		t->error = error;
+		t->ioprio = ioprio;
  		t->pdu_len = pdu_len;

  		if (pdu_len)
diff -uprN linux-2.6.27-rc5-mm1/include/linux/bio.h linux-2.6.27-rc5-mm1-blktrace/include/linux/bio.h
--- linux-2.6.27-rc5-mm1/include/linux/bio.h	2008-09-10 19:27:46.000000000 +0900
+++ linux-2.6.27-rc5-mm1-blktrace/include/linux/bio.h	2008-09-11 00:53:15.000000000 +0900
@@ -186,6 +186,18 @@ static inline void *bio_data(struct bio
  }

  /*
+ * TODO: replace this with io-tracking version
+ */
+static inline unsigned short bio_get_ioprio(struct bio *bio)
+{
+	struct task_struct *tsk = current;
+	if (tsk->io_context)
+		return tsk->io_context->ioprio;
+
+	return 0;
+}
+
+/*
   * will die
   */
  #define bio_to_phys(bio)	(page_to_phys(bio_page((bio))) + (unsigned long) bio_offset((bio)))
diff -uprN linux-2.6.27-rc5-mm1/include/linux/blktrace_api.h linux-2.6.27-rc5-mm1-blktrace/include/linux/blktrace_api.h
--- linux-2.6.27-rc5-mm1/include/linux/blktrace_api.h	2008-09-10 19:27:46.000000000 +0900
+++ linux-2.6.27-rc5-mm1-blktrace/include/linux/blktrace_api.h	2008-09-11 00:54:35.000000000 +0900
@@ -103,6 +103,7 @@ struct blk_io_trace {
  	u32 cpu;		/* on what cpu did it happen */
  	u16 error;		/* completion error */
  	u16 pdu_len;		/* length of data after this trace */
+	u16 ioprio;		/* priority of this io */
  };

  /*
@@ -153,7 +154,7 @@ struct blk_user_trace_setup {
  #if defined(CONFIG_BLK_DEV_IO_TRACE)
  extern int blk_trace_ioctl(struct block_device *, unsigned, char __user *);
  extern void blk_trace_shutdown(struct request_queue *);
-extern void __blk_add_trace(struct blk_trace *, sector_t, int, int, u32, int, int, void *);
+extern void __blk_add_trace(struct blk_trace *, sector_t, int, int, u32, int, unsigned short, int, void *);
  extern int do_blk_trace_setup(struct request_queue *q,
  	char *name, dev_t dev, struct blk_user_trace_setup *buts);
  extern void __trace_note_message(struct blk_trace *, const char *fmt, ...);
@@ -194,6 +195,7 @@ static inline void blk_add_trace_rq(stru
  {
  	struct blk_trace *bt = q->blk_trace;
  	int rw = rq->cmd_flags & 0x03;
+	unsigned short ioprio = req_get_ioprio(rq);

  	if (likely(!bt))
  		return;
@@ -203,10 +205,10 @@ static inline void blk_add_trace_rq(stru

  	if (blk_pc_request(rq)) {
  		what |= BLK_TC_ACT(BLK_TC_PC);
-		__blk_add_trace(bt, 0, rq->data_len, rw, what, rq->errors, sizeof(rq->cmd), rq->cmd);
+		__blk_add_trace(bt, 0, rq->data_len, rw, what, rq->errors, ioprio, sizeof(rq->cmd), rq->cmd);
  	} else  {
  		what |= BLK_TC_ACT(BLK_TC_FS);
-		__blk_add_trace(bt, rq->hard_sector, rq->hard_nr_sectors << 9, rw, what, rq->errors, 0, NULL);
+		__blk_add_trace(bt, rq->hard_sector, rq->hard_nr_sectors << 9, rw, what, rq->errors, ioprio, 0, NULL);
  	}
  }

@@ -224,11 +226,12 @@ static inline void blk_add_trace_bio(str
  				     u32 what)
  {
  	struct blk_trace *bt = q->blk_trace;
+	unsigned short ioprio = bio_get_ioprio(bio);

  	if (likely(!bt))
  		return;

-	__blk_add_trace(bt, bio->bi_sector, bio->bi_size, bio->bi_rw, what, !bio_flagged(bio, BIO_UPTODATE), 0, NULL);
+	__blk_add_trace(bt, bio->bi_sector, bio->bi_size, bio->bi_rw, what, !bio_flagged(bio, BIO_UPTODATE), ioprio, 0, NULL);
  }

  /**
@@ -253,7 +256,7 @@ static inline void blk_add_trace_generic
  	if (bio)
  		blk_add_trace_bio(q, bio, what);
  	else
-		__blk_add_trace(bt, 0, 0, rw, what, 0, 0, NULL);
+		__blk_add_trace(bt, 0, 0, rw, what, 0, 0, 0, NULL);
  }

  /**
@@ -274,14 +277,17 @@ static inline void blk_add_trace_pdu_int
  {
  	struct blk_trace *bt = q->blk_trace;
  	__be64 rpdu = cpu_to_be64(pdu);
+	unsigned short ioprio = 0;

  	if (likely(!bt))
  		return;

-	if (bio)
-		__blk_add_trace(bt, bio->bi_sector, bio->bi_size, bio->bi_rw, what, !bio_flagged(bio, BIO_UPTODATE), sizeof(rpdu), &rpdu);
-	else
-		__blk_add_trace(bt, 0, 0, 0, what, 0, sizeof(rpdu), &rpdu);
+	if (bio) {
+		ioprio = bio_get_ioprio(bio);
+		__blk_add_trace(bt, bio->bi_sector, bio->bi_size, bio->bi_rw, what, !bio_flagged(bio, BIO_UPTODATE), ioprio, sizeof(rpdu), &rpdu);
+	} else {
+		__blk_add_trace(bt, 0, 0, 0, what, 0, ioprio, sizeof(rpdu), &rpdu);
+	}
  }

  /**
@@ -302,6 +308,7 @@ static inline void blk_add_trace_remap(s
  {
  	struct blk_trace *bt = q->blk_trace;
  	struct blk_io_trace_remap r;
+	unsigned short ioprio = bio_get_ioprio(bio);

  	if (likely(!bt))
  		return;
@@ -310,7 +317,7 @@ static inline void blk_add_trace_remap(s
  	r.device_from = cpu_to_be32(bio->bi_bdev->bd_dev);
  	r.sector = cpu_to_be64(to);

-	__blk_add_trace(bt, from, bio->bi_size, bio->bi_rw, BLK_TA_REMAP, !bio_flagged(bio, BIO_UPTODATE), sizeof(r), &r);
+	__blk_add_trace(bt, from, bio->bi_size, bio->bi_rw, BLK_TA_REMAP, !bio_flagged(bio, BIO_UPTODATE), ioprio, sizeof(r), &r);
  }

  extern int blk_trace_setup(struct request_queue *q, char *name, dev_t dev,
