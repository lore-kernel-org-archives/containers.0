From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 18/19] io-controller: Debug hierarchical IO scheduling
Date: Fri, 19 Jun 2009 14:26:06 +0800
Message-ID: <4A3B2F7E.10405__15874.7942456559$1245393030$gmane$org@cn.fujitsu.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
	<1244513342-11758-19-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244513342-11758-19-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
> +static inline void bfq_account_for_entity_addition(struct io_entity *entity)
> +{
> +	struct io_group *iog = io_entity_to_iog(entity);
> +
> +	if (iog) {
> +		struct elv_fq_data *efqd;
> +		char path[128];
> +
> +		/*
> +		 * Keep track of how many times a group has been removed
> +		 * from active tree because it did not have any active
> +		 * backlogged ioq under it
> +		 */
> +		iog->queue++;
> +		iog->queue_start = jiffies;
> +
> +		/* Log group addition event */
> +		rcu_read_lock();
> +		efqd = rcu_dereference(iog->key);
> +		if (efqd) {
> +			io_group_path(iog, path, sizeof(path));
> +			elv_log(efqd, "add group=%s weight=%ld", path,
> +					iog->entity.weight);

Since cgroup path is already cached, why not use it. :)

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index bfa79c9..1a397c3 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -183,7 +183,6 @@ static inline void bfq_account_for_entity_addition(struct io_entity *entity)
 
 	if (iog) {
 		struct elv_fq_data *efqd;
-		char path[128];
 
 		/*
 		 * Keep track of how many times a group has been removed
@@ -197,9 +196,8 @@ static inline void bfq_account_for_entity_addition(struct io_entity *entity)
 		rcu_read_lock();
 		efqd = rcu_dereference(iog->key);
 		if (efqd) {
-			io_group_path(iog, path, sizeof(path));
-			elv_log(efqd, "add group=%s weight=%ld", path,
-					iog->entity.weight);
+			elv_log(efqd, "add group=%s weight=%ld", iog->path,
+				iog->entity.weight);
 		}
 		rcu_read_unlock();
 	}
@@ -215,7 +213,6 @@ static inline void bfq_account_for_entity_deletion(struct io_entity *entity)
 
 	if (iog) {
 		struct elv_fq_data *efqd;
-		char path[128];
 
 		iog->dequeue++;
 		/* Keep a track of how long group was on active tree */
@@ -227,9 +224,8 @@ static inline void bfq_account_for_entity_deletion(struct io_entity *entity)
 		rcu_read_lock();
 		efqd = rcu_dereference(iog->key);
 		if (efqd) {
-			io_group_path(iog, path, sizeof(path));
-			elv_log(efqd, "del group=%s weight=%ld", path,
-					iog->entity.weight);
+			elv_log(efqd, "del group=%s weight=%ld", iog->path,
+				iog->entity.weight);
 		}
 		rcu_read_unlock();
 	}
-- 
1.5.4.rc3
