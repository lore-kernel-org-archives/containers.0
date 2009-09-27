From: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Sun, 27 Sep 2009 18:42:36 +0200
Message-ID: <20090927164235.GA23126__36693.3297286325$1254069901$gmane$org@kernel.dk>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<4ABC28DE.7050809@datenparkplatz.de>
	<20090925202636.GC15007@redhat.com>
	<1253976676.7005.40.camel@marge.simson.net>
	<1254034500.7933.6.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254034500.7933.6.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Sep 27 2009, Mike Galbraith wrote:
> My dd vs load non-cached binary woes seem to be coming from backmerge.
> 
> #if 0 /*MIKEDIDIT sand in gearbox?*/
>         /*
>          * See if our hash lookup can find a potential backmerge.
>          */
>         __rq = elv_rqhash_find(q, bio->bi_sector);
>         if (__rq && elv_rq_merge_ok(__rq, bio)) {
>                 *req = __rq;
>                 return ELEVATOR_BACK_MERGE;
>         }
> #endif

It's a given that not merging will provide better latency. We can't
disable that or performance will suffer A LOT on some systems. There are
ways to make it better, though. One would be to make the max request
size smaller, but that would also hurt for streamed workloads. Can you
try whether the below patch makes a difference? It will basically
disallow merges to a request that isn't the last one.

We should probably make the merging logic a bit more clever, since the
below wont work well for two (or more) streamed cases. I'll think a bit
about that.

Note this is totally untested!

diff --git a/block/elevator.c b/block/elevator.c
index 1975b61..d00a72b 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -497,9 +497,17 @@ int elv_merge(struct request_queue *q, struct request **req, struct bio *bio)
 	 * See if our hash lookup can find a potential backmerge.
 	 */
 	__rq = elv_rqhash_find(q, bio->bi_sector);
-	if (__rq && elv_rq_merge_ok(__rq, bio)) {
-		*req = __rq;
-		return ELEVATOR_BACK_MERGE;
+	if (__rq) {
+		/*
+		 * If requests are queued behind this one, disallow merge. This
+		 * prevents streaming IO from continually passing new IO.
+		 */
+		if (elv_latter_request(q, __rq))
+			return ELEVATOR_NO_MERGE;
+		if (elv_rq_merge_ok(__rq, bio)) {
+			*req = __rq;
+			return ELEVATOR_BACK_MERGE;
+		}
 	}
 
 	if (e->ops->elevator_merge_fn)

-- 
Jens Axboe
