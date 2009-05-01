From: "IKEDA, Munehiro" <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Fri, 01 May 2009 18:04:39 -0400
Message-ID: <49FB71F7.90309__12652.8492816307$1241215909$gmane$org@ds.jp.nec.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>	<20090406143556.GK7082@balbir.in.ibm.com>
	<20090413134017.GC18007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090413134017.GC18007-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
>>> +TODO
>>> +====
>>> +- Lots of cleanups, testing, bug fixing, optimizations, benchmarking etc...
>>> +- Convert cgroup ioprio to notion of weight.
>>> +- Anticipatory code will need more work. It is not working properly currently
>>> +  and needs more thought.
>> What are the problems with the code?
> 
> Have not got a chance to look into the issues in detail yet. Just a crude run
> saw drop in performance. Will debug it later the moment I have got async writes
> handled...
> 
>>> +- Use of bio-cgroup patches.
>> I saw these posted as well
>>
>>> +- Use of Nauman's per cgroup request descriptor patches.
>>> +
>> More details would be nice, I am not sure I understand
> 
> Currently the number of request descriptors which can be allocated per
> device/request queue are fixed by a sysfs tunable (q->nr_requests). So
> if there is lots of IO going on from one cgroup then it will consume all
> the available request descriptors and other cgroup might starve and not
> get its fair share.
> 
> Hence we also need to introduce the notion of request descriptor limit per
> cgroup so that if request descriptors from one group are exhausted, then
> it does not impact the IO of other cgroup.

Unfortunately I couldn't find and I've never seen the Nauman's patches.
So I tried to make a patch below against this todo.  The reason why
I'm posting this despite this is just a quick and ugly hack (and it
might be a reinvention of wheel) is that I would like to discuss how
we should define the limitation of requests per cgroup.
This patch should be applied on Vivek's I/O controller patches
posted on Mar 11.

This patch temporarily distribute q->nr_requests to each cgroup.
I think the number should be weighted like BFQ's budget.  But in
this case, if the hierarchy of cgroup is deep, leaf cgroups are
allowed to allocate very few numbers of requests.  I don't think
this is reasonable...but I don't have specific idea to solve this
problem.  Does anyone have the good idea?

Signed-off-by: Munehiro "Muuhh" Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
---
 block/blk-core.c    |   36 +++++++--
 block/blk-sysfs.c   |   22 ++++--
 block/elevator-fq.c |  133 ++++++++++++++++++++++++++++++++--
 block/elevator-fq.h |  201 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 371 insertions(+), 21 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 29bcfac..21023f7 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -705,11 +705,15 @@ static void ioc_set_batching(struct request_queue *q, struct io_context *ioc)
 static void __freed_request(struct request_queue *q, int rw)
 {
 	struct request_list *rl = &q->rq;
-
-	if (rl->count[rw] < queue_congestion_off_threshold(q))
+	struct io_group *congested_iog, *full_iog;
+	
+	congested_iog = io_congested_io_group(q, rw);
+	if (rl->count[rw] < queue_congestion_off_threshold(q) &&
+	    !congested_iog)
 		blk_clear_queue_congested(q, rw);
 
-	if (rl->count[rw] + 1 <= q->nr_requests) {
+	full_iog = io_full_io_group(q, rw);
+	if (rl->count[rw] + 1 <= q->nr_requests && !full_iog) {
 		if (waitqueue_active(&rl->wait[rw]))
 			wake_up(&rl->wait[rw]);
 
@@ -721,13 +725,16 @@ static void __freed_request(struct request_queue *q, int rw)
  * A request has just been released.  Account for it, update the full and
  * congestion status, wake up any waiters.   Called under q->queue_lock.
  */
-static void freed_request(struct request_queue *q, int rw, int priv)
+static void freed_request(struct request_queue *q, struct io_group *iog,
+			  int rw, int priv)
 {
 	struct request_list *rl = &q->rq;
 
 	rl->count[rw]--;
 	if (priv)
 		rl->elvpriv--;
+	if (iog)
+		io_group_dec_count(iog, rw);
 
 	__freed_request(q, rw);
 
@@ -746,16 +753,21 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
 {
 	struct request *rq = NULL;
 	struct request_list *rl = &q->rq;
+	struct io_group *iog;
 	struct io_context *ioc = NULL;
 	const int rw = rw_flags & 0x01;
 	int may_queue, priv;
 
+	iog = __io_get_io_group(q);
+
 	may_queue = elv_may_queue(q, rw_flags);
 	if (may_queue == ELV_MQUEUE_NO)
 		goto rq_starved;
 
-	if (rl->count[rw]+1 >= queue_congestion_on_threshold(q)) {
-		if (rl->count[rw]+1 >= q->nr_requests) {
+	if (rl->count[rw]+1 >= queue_congestion_on_threshold(q) ||
+	    io_group_congestion_on(iog, rw)) {
+		if (rl->count[rw]+1 >= q->nr_requests ||
+		    io_group_full(iog, rw)) {
 			ioc = current_io_context(GFP_ATOMIC, q->node);
 			/*
 			 * The queue will fill after this allocation, so set
@@ -789,8 +801,15 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
 	if (rl->count[rw] >= (3 * q->nr_requests / 2))
 		goto out;
 
+	if (iog)
+		if (io_group_count(iog, rw) >=
+		   (3 * io_group_nr_requests(iog) / 2))
+			goto out;
+
 	rl->count[rw]++;
 	rl->starved[rw] = 0;
+	if (iog)
+		io_group_inc_count(iog, rw);
 
 	priv = !test_bit(QUEUE_FLAG_ELVSWITCH, &q->queue_flags);
 	if (priv)
@@ -808,7 +827,7 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
 		 * wait queue, but this is pretty rare.
 		 */
 		spin_lock_irq(q->queue_lock);
-		freed_request(q, rw, priv);
+		freed_request(q, iog, rw, priv);
 
 		/*
 		 * in the very unlikely event that allocation failed and no
@@ -1073,12 +1092,13 @@ void __blk_put_request(struct request_queue *q, struct request *req)
 	if (req->cmd_flags & REQ_ALLOCED) {
 		int rw = rq_data_dir(req);
 		int priv = req->cmd_flags & REQ_ELVPRIV;
+		struct io_group *iog = io_request_io_group(req);
 
 		BUG_ON(!list_empty(&req->queuelist));
 		BUG_ON(!hlist_unhashed(&req->hash));
 
 		blk_free_request(q, req);
-		freed_request(q, rw, priv);
+		freed_request(q, iog, rw, priv);
 	}
 }
 EXPORT_SYMBOL_GPL(__blk_put_request);
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 0d98c96..af5191c 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -40,6 +40,7 @@ queue_requests_store(struct request_queue *q, const char *page, size_t count)
 {
 	struct request_list *rl = &q->rq;
 	unsigned long nr;
+	int iog_congested[2], iog_full[2];
 	int ret = queue_var_store(&nr, page, count);
 	if (nr < BLKDEV_MIN_RQ)
 		nr = BLKDEV_MIN_RQ;
@@ -47,27 +48,32 @@ queue_requests_store(struct request_queue *q, const char *page, size_t count)
 	spin_lock_irq(q->queue_lock);
 	q->nr_requests = nr;
 	blk_queue_congestion_threshold(q);
+	io_group_set_nrq_all(q, nr, iog_congested, iog_full);
 
-	if (rl->count[READ] >= queue_congestion_on_threshold(q))
+	if (rl->count[READ] >= queue_congestion_on_threshold(q) ||
+	    iog_congested[READ])
 		blk_set_queue_congested(q, READ);
-	else if (rl->count[READ] < queue_congestion_off_threshold(q))
+	else if (rl->count[READ] < queue_congestion_off_threshold(q) &&
+		 !iog_congested[READ])
 		blk_clear_queue_congested(q, READ);
 
-	if (rl->count[WRITE] >= queue_congestion_on_threshold(q))
+	if (rl->count[WRITE] >= queue_congestion_on_threshold(q) ||
+	    iog_congested[WRITE])
 		blk_set_queue_congested(q, WRITE);
-	else if (rl->count[WRITE] < queue_congestion_off_threshold(q))
+	else if (rl->count[WRITE] < queue_congestion_off_threshold(q) &&
+		 !iog_congested[WRITE])
 		blk_clear_queue_congested(q, WRITE);
 
-	if (rl->count[READ] >= q->nr_requests) {
+	if (rl->count[READ] >= q->nr_requests || iog_full[READ]) {
 		blk_set_queue_full(q, READ);
-	} else if (rl->count[READ]+1 <= q->nr_requests) {
+	} else if (rl->count[READ]+1 <= q->nr_requests && !iog_full[READ]) {
 		blk_clear_queue_full(q, READ);
 		wake_up(&rl->wait[READ]);
 	}
 
-	if (rl->count[WRITE] >= q->nr_requests) {
+	if (rl->count[WRITE] >= q->nr_requests || iog_full[WRITE]) {
 		blk_set_queue_full(q, WRITE);
-	} else if (rl->count[WRITE]+1 <= q->nr_requests) {
+	} else if (rl->count[WRITE]+1 <= q->nr_requests && !iog_full[WRITE]) {
 		blk_clear_queue_full(q, WRITE);
 		wake_up(&rl->wait[WRITE]);
 	}
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index df53418..3b021f3 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -924,6 +924,111 @@ struct io_group *io_lookup_io_group_current(struct request_queue *q)
 }
 EXPORT_SYMBOL(io_lookup_io_group_current);
 
+/*
+ * TODO
+ * This is complete dupulication of blk_queue_congestion_threshold()
+ * except for the argument type and name.  Can we merge them?
+ */
+static void io_group_nrq_congestion_threshold(struct io_group_nrq *nrq)
+{
+	int nr;
+
+	nr = nrq->nr_requests - (nrq->nr_requests / 8) + 1;
+	if (nr > nrq->nr_requests)
+		nr = nrq->nr_requests;
+	nrq->nr_congestion_on = nr;
+
+	nr = nrq->nr_requests - (nrq->nr_requests / 8)
+		- (nrq->nr_requests / 16) - 1;
+	if (nr < 1)
+		nr = 1;
+	nrq->nr_congestion_off = nr;
+}
+
+static void io_group_set_nrq(struct io_group_nrq *nrq, int nr_requests,
+			 int *congested, int *full)
+{
+	int i;
+
+	BUG_ON(nr_requests < 0);
+
+	nrq->nr_requests = nr_requests;
+	io_group_nrq_congestion_threshold(nrq);
+
+	for (i=0; i<2; i++) {
+		if (nrq->count[i] >= nrq->nr_congestion_on)
+			congested[i] = 1;
+		else if (nrq->count[i] < nrq->nr_congestion_off)
+			congested[i] = 0;
+
+		if (nrq->count[i] >= nrq->nr_requests)
+			full[i] = 1;
+		else if (nrq->count[i]+1 <= nrq->nr_requests)
+			full[i] = 0;
+	}
+}
+
+void io_group_set_nrq_all(struct request_queue *q, int nr,
+			    int *congested, int *full)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+	struct hlist_head *head = &efqd->group_list;
+	struct io_group *root = efqd->root_group;
+	struct hlist_node *n;
+	struct io_group *iog;
+	struct io_group_nrq *nrq;
+	int nrq_congested[2];
+	int nrq_full[2];
+	int i;
+
+	for (i=0; i<2; i++)
+		*(congested + i) = *(full + i) = 0;
+
+	nrq = &root->nrq;
+	io_group_set_nrq(nrq, nr, nrq_congested, nrq_full);
+	for (i=0; i<2; i++) {
+		*(congested + i) |= nrq_congested[i];
+		*(full + i) |= nrq_full[i];
+	}
+
+	hlist_for_each_entry(iog, n, head, elv_data_node) {
+		nrq = &iog->nrq;
+		io_group_set_nrq(nrq, nr, nrq_congested, nrq_full);
+		for (i=0; i<2; i++) {
+			*(congested + i) |= nrq_congested[i];
+			*(full + i) |= nrq_full[i];
+		}
+	}
+}
+
+struct io_group *io_congested_io_group(struct request_queue *q, int rw)
+{
+	struct hlist_head *head = &q->elevator->efqd.group_list;
+	struct hlist_node *n;
+	struct io_group *iog;
+
+	hlist_for_each_entry(iog, n, head, elv_data_node) {
+		struct io_group_nrq *nrq = &iog->nrq;
+		if (nrq->count[rw] >= nrq->nr_congestion_off)
+			return iog;
+	}
+	return NULL;
+}
+
+struct io_group *io_full_io_group(struct request_queue *q, int rw)
+{
+	struct hlist_head *head = &q->elevator->efqd.group_list;
+	struct hlist_node *n;
+	struct io_group *iog;
+
+	hlist_for_each_entry(iog, n, head, elv_data_node) {
+		struct io_group_nrq *nrq = &iog->nrq;
+		if (nrq->count[rw] >= nrq->nr_requests)
+			return iog;
+	}
+	return NULL;
+}
+
 void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
 {
 	struct io_entity *entity = &iog->entity;
@@ -934,6 +1039,12 @@ void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
 	entity->my_sched_data = &iog->sched_data;
 }
 
+static void io_group_init_nrq(struct request_queue *q, struct io_group_nrq *nrq)
+{
+	nrq->nr_requests = q->nr_requests;
+	io_group_nrq_congestion_threshold(nrq);
+}
+
 void io_group_set_parent(struct io_group *iog, struct io_group *parent)
 {
 	struct io_entity *entity;
@@ -1053,6 +1164,8 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
 		io_group_init_entity(iocg, iog);
 		iog->my_entity = &iog->entity;
 
+		io_group_init_nrq(q, &iog->nrq);
+
 		if (leaf == NULL) {
 			leaf = iog;
 			prev = leaf;
@@ -1176,7 +1289,7 @@ struct io_group *io_find_alloc_group(struct request_queue *q,
  * Generic function to make sure cgroup hierarchy is all setup once a request
  * from a cgroup is received by the io scheduler.
  */
-struct io_group *io_get_io_group(struct request_queue *q)
+struct io_group *__io_get_io_group(struct request_queue *q)
 {
 	struct cgroup *cgroup;
 	struct io_group *iog;
@@ -1192,6 +1305,19 @@ struct io_group *io_get_io_group(struct request_queue *q)
 	return iog;
 }
 
+struct io_group *io_get_io_group(struct request_queue *q)
+{
+	struct io_group *iog;
+	unsigned long flags;
+
+	spin_lock_irqsave(q->queue_lock, flags);
+	iog = __io_get_io_group(q);
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	BUG_ON(!iog);
+
+	return iog;
+}
+
 void io_free_root_group(struct elevator_queue *e)
 {
 	struct io_cgroup *iocg = &io_root_cgroup;
@@ -1220,6 +1346,7 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
 	iog->entity.parent = NULL;
 	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
 		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
+	io_group_init_nrq(q, &iog->nrq);
 
 	iocg = &io_root_cgroup;
 	spin_lock_irq(&iocg->lock);
@@ -1533,15 +1660,11 @@ void elv_fq_set_request_io_group(struct request_queue *q,
 						struct request *rq)
 {
 	struct io_group *iog;
-	unsigned long flags;
 
 	/* Make sure io group hierarchy has been setup and also set the
 	 * io group to which rq belongs. Later we should make use of
 	 * bio cgroup patches to determine the io group */
-	spin_lock_irqsave(q->queue_lock, flags);
 	iog = io_get_io_group(q);
-	spin_unlock_irqrestore(q->queue_lock, flags);
-	BUG_ON(!iog);
 
 	/* Store iog in rq. TODO: take care of referencing */
 	rq->iog = iog;
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index fc4110d..f8eabd4 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -187,6 +187,22 @@ struct io_queue {
 
 #ifdef CONFIG_GROUP_IOSCHED
 /**
+ * struct io_group_nrq - structure to store allocated requests info
+ * @nr_requests: maximun num of requests for the io_group
+ * @nr_congestion_on: threshold to determin the io_group is cogested.
+ * @nr_congestion_off: threshold to determin the io_group is not congested.
+ * @count: num of allocated requests.
+ *
+ * All fields are protected by queue_lock.
+ */
+struct io_group_nrq {
+	unsigned long nr_requests;
+	unsigned int nr_congestion_on;
+	unsigned int nr_congestion_off;
+	int count[2];
+};
+
+/**
  * struct bfq_group - per (device, cgroup) data structure.
  * @entity: schedulable entity to insert into the parent group sched_data.
  * @sched_data: own sched_data, to contain child entities (they may be
@@ -235,6 +251,8 @@ struct io_group {
 
 	/* Single ioq per group, used for noop, deadline, anticipatory */
 	struct io_queue *ioq;
+
+	struct io_group_nrq nrq;
 };
 
 /**
@@ -469,6 +487,11 @@ extern int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
 extern void elv_fq_unset_request_ioq(struct request_queue *q,
 					struct request *rq);
 extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q);
+extern void io_group_set_nrq_all(struct request_queue *q, int nr,
+			    int *congested, int *full);
+extern struct io_group *io_congested_io_group(struct request_queue *q, int rw);
+extern struct io_group *io_full_io_group(struct request_queue *q, int rw);
+extern struct io_group *__io_get_io_group(struct request_queue *q);
 
 /* Returns single ioq associated with the io group. */
 static inline struct io_queue *io_group_ioq(struct io_group *iog)
@@ -486,6 +509,52 @@ static inline void io_group_set_ioq(struct io_group *iog, struct io_queue *ioq)
 	iog->ioq = ioq;
 }
 
+static inline struct io_group *io_request_io_group(struct request *rq)
+{
+	return rq->iog;
+}
+
+static inline unsigned long io_group_nr_requests(struct io_group *iog)
+{
+	BUG_ON(!iog);
+	return iog->nrq.nr_requests;
+}
+
+static inline int io_group_inc_count(struct io_group *iog, int rw)
+{
+	BUG_ON(!iog);
+	return iog->nrq.count[rw]++;
+}
+
+static inline int io_group_dec_count(struct io_group *iog, int rw)
+{
+	BUG_ON(!iog);
+	return iog->nrq.count[rw]--;
+}
+
+static inline int io_group_count(struct io_group *iog, int rw)
+{
+	BUG_ON(!iog);
+	return iog->nrq.count[rw];
+}
+
+static inline int io_group_congestion_on(struct io_group *iog, int rw)
+{
+	BUG_ON(!iog);
+	return iog->nrq.count[rw] + 1 >= iog->nrq.nr_congestion_on;
+}
+
+static inline int io_group_congestion_off(struct io_group *iog, int rw)
+{
+	BUG_ON(!iog);
+	return iog->nrq.count[rw] < iog->nrq.nr_congestion_off;
+}
+
+static inline int io_group_full(struct io_group *iog, int rw)
+{
+	BUG_ON(!iog);
+	return iog->nrq.count[rw] + 1 >= iog->nrq.nr_requests;
+}
 #else /* !GROUP_IOSCHED */
 /*
  * No ioq movement is needed in case of flat setup. root io group gets cleaned
@@ -537,6 +606,71 @@ static inline struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
 	return NULL;
 }
 
+static inline void io_group_set_nrq_all(struct request_queue *q, int nr,
+					int *congested, int *full)
+{
+	int i;
+	for (i=0; i<2; i++)
+		*(congested + i) = *(full + i) = 0;
+}
+
+static inline struct io_group *
+io_congested_io_group(struct request_queue *q, int rw)
+{
+	return NULL;
+}
+
+static inline struct io_group *
+io_full_io_group(struct request_queue *q, int rw)
+{
+	return NULL;
+}
+
+static inline struct io_group *__io_get_io_group(struct request_queue *q)
+{
+	return NULL;
+}
+
+static inline struct io_group *io_request_io_group(struct request *rq)
+{
+	return NULL;
+}
+
+static inline unsigned long io_group_nr_requests(struct io_group *iog)
+{
+	return 0;
+}
+
+static inline int io_group_inc_count(struct io_group *iog, int rw)
+{
+	return 0;
+}
+
+static inline int io_group_dec_count(struct io_group *iog, int rw)
+{
+	return 0;
+}
+
+static inline int io_group_count(struct io_group *iog, int rw)
+{
+	return 0;
+}
+
+static inline int io_group_congestion_on(struct io_group *iog, int rw)
+{
+	return 0;
+}
+
+static inline int io_group_congestion_off(struct io_group *iog, int rw)
+{
+	return 1;
+}
+
+static inline int io_group_full(struct io_group *iog, int rw)
+{
+	return 0;
+}
+
 #endif /* GROUP_IOSCHED */
 
 /* Functions used by blksysfs.c */
@@ -589,6 +723,9 @@ extern void elv_free_ioq(struct io_queue *ioq);
 
 #else /* CONFIG_ELV_FAIR_QUEUING */
 
+struct io_group {
+};
+
 static inline int elv_init_fq_data(struct request_queue *q,
 					struct elevator_queue *e)
 {
@@ -655,5 +792,69 @@ static inline struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
 	return NULL;
 }
 
+static inline void io_group_set_nrq_all(struct request_queue *q, int nr,
+					int *congested, int *full)
+{
+	int i;
+	for (i=0; i<2; i++)
+		*(congested + i) = *(full + i) = 0;
+}
+
+static inline struct io_group *
+io_congested_io_group(struct request_queue *q, int rw)
+{
+	return NULL;
+}
+
+static inline struct io_group *
+io_full_io_group(struct request_queue *q, int rw)
+{
+	return NULL;
+}
+
+static inline struct io_group *__io_get_io_group(struct request_queue *q)
+{
+	return NULL;
+}
+
+static inline struct io_group *io_request_io_group(struct request *rq)
+{
+	return NULL;
+}
+
+static inline unsigned long io_group_nr_requests(struct io_group *iog)
+{
+	return 0;
+}
+
+static inline int io_group_inc_count(struct io_group *iog, int rw)
+{
+	return 0;
+}
+
+static inline int io_group_dec_count(struct io_group *iog, int rw)
+{
+	return 0;
+}
+
+static inline int io_group_count(struct io_group *iog, int rw)
+{
+	return 0;
+}
+
+static inline int io_group_congestion_on(struct io_group *iog, int rw)
+{
+	return 0;
+}
+
+static inline int io_group_congestion_off(struct io_group *iog, int rw)
+{
+	return 1;
+}
+
+static inline int io_group_full(struct io_group *iog, int rw)
+{
+	return 0;
+}
 #endif /* CONFIG_ELV_FAIR_QUEUING */
 #endif /* _BFQ_SCHED_H */
-- 
1.5.4.3


-- 
IKEDA, Munehiro
 NEC Corporation of America
   m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
