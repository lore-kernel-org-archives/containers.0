From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Fri, 8 May 2009 09:37:40 -0400
Message-ID: <20090508133740.GD7293@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A014619.1040000@cn.fujitsu.com>
	<20090506161012.GC8180@redhat.com>
	<4A027348.6000808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A027348.6000808-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, May 07, 2009 at 01:36:08PM +0800, Li Zefan wrote:
> Vivek Goyal wrote:
> > On Wed, May 06, 2009 at 04:11:05PM +0800, Gui Jianfeng wrote:
> >> Vivek Goyal wrote:
> >>> Hi All,
> >>>
> >>> Here is the V2 of the IO controller patches generated on top of 2.6.30-rc4.
> >>> First version of the patches was posted here.
> >> Hi Vivek,
> >>
> >> I did some simple test for V2, and triggered an kernel panic.
> >> The following script can reproduce this bug. It seems that the cgroup
> >> is already removed, but IO Controller still try to access into it.
> >>
> > 
> > Hi Gui,
> > 
> > Thanks for the report. I use cgroup_path() for debugging. I guess that
> > cgroup_path() was passed null cgrp pointer that's why it crashed.
> > 
> > If yes, then it is strange though. I call cgroup_path() only after
> > grabbing a refenrece to css object. (I am assuming that if I have a valid
> > reference to css object then css->cgrp can't be null).
> > 
> 
> Yes, css->cgrp shouldn't be NULL.. I doubt we hit a bug in cgroup here.
> The code dealing with css refcnt and cgroup rmdir has changed quite a lot,
> and is much more complex than it was.
> 
> > Anyway, can you please try out following patch and see if it fixes your
> > crash.
> ...
> > BTW, I tried following equivalent script and I can't see the crash on 
> > my system. Are you able to hit it regularly?
> > 
> 
> I modified the script like this:
> 
> ======================
> #!/bin/sh
> echo 1 > /proc/sys/vm/drop_caches
> mkdir /cgroup 2> /dev/null
> mount -t cgroup -o io,blkio io /cgroup
> mkdir /cgroup/test1
> mkdir /cgroup/test2
> echo 100 > /cgroup/test1/io.weight
> echo 500 > /cgroup/test2/io.weight
> 
> dd if=/dev/zero bs=4096 count=128000 of=500M.1 &
> pid1=$!
> echo $pid1 > /cgroup/test1/tasks
> 
> dd if=/dev/zero bs=4096 count=128000 of=500M.2 &
> pid2=$!
> echo $pid2 > /cgroup/test2/tasks
> 
> sleep 5
> kill -9 $pid1
> kill -9 $pid2
> 
> for ((;count != 2;))
> {
>         rmdir /cgroup/test1 > /dev/null 2>&1
>         if [ $? -eq 0 ]; then
>                 count=$(( $count + 1 ))
>         fi
> 
>         rmdir /cgroup/test2 > /dev/null 2>&1
>         if [ $? -eq 0 ]; then
>                 count=$(( $count + 1 ))
>         fi
> }
> 
> umount /cgroup
> rmdir /cgroup
> ======================
> 
> I ran this script and got lockdep BUG. Full log and my config are attached.
> 
> Actually this can be triggered with the following steps on my box:
> # mount -t cgroup -o blkio,io xxx /mnt
> # mkdir /mnt/0
> # echo $$ > /mnt/0/tasks
> # echo 3 > /proc/sys/vm/drop_cache
> # echo $$ > /mnt/tasks
> # rmdir /mnt/0
> 
> And when I ran the script for the second time, my box was freezed
> and I had to reset it.
> 

Thanks Li and Gui for pointing out the problem. With you script, I could
also produce lock validator warning as well as system freeze. I could
identify at least two trouble spots. With following patch things seems
to be fine on my system. Can you please give it a try.


---
 block/elevator-fq.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

Index: linux11/block/elevator-fq.c
===================================================================
--- linux11.orig/block/elevator-fq.c	2009-05-08 08:47:45.000000000 -0400
+++ linux11/block/elevator-fq.c	2009-05-08 09:27:37.000000000 -0400
@@ -942,6 +942,7 @@ void entity_served(struct io_entity *ent
 	struct io_service_tree *st;
 
 	for_each_entity(entity) {
+		BUG_ON(!entity->on_st);
 		st = io_entity_service_tree(entity);
 		entity->service += served;
 		entity->total_service += served;
@@ -1652,6 +1653,14 @@ static inline int io_group_has_active_en
 			return 1;
 	}
 
+	/*
+	 * Also check there are no active entities being served which are
+	 * not on active tree
+	 */
+
+	if (iog->sched_data.active_entity)
+		return 1;
+
 	return 0;
 }
 
@@ -1738,7 +1747,7 @@ void iocg_destroy(struct cgroup_subsys *
 	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
 	struct hlist_node *n, *tmp;
 	struct io_group *iog;
-	unsigned long flags;
+	unsigned long flags, flags1;
 	int queue_lock_held = 0;
 	struct elv_fq_data *efqd;
 
@@ -1766,7 +1775,8 @@ retry:
 		rcu_read_lock();
 		efqd = rcu_dereference(iog->key);
 		if (efqd != NULL) {
-			if (spin_trylock_irq(efqd->queue->queue_lock)) {
+			if (spin_trylock_irqsave(efqd->queue->queue_lock,
+						flags1)) {
 				if (iog->key == efqd) {
 					queue_lock_held = 1;
 					rcu_read_unlock();
@@ -1780,7 +1790,8 @@ retry:
 				 * elevator hence we can proceed safely without
 				 * queue lock.
 				 */
-				spin_unlock_irq(efqd->queue->queue_lock);
+				spin_unlock_irqrestore(efqd->queue->queue_lock,
+							flags1);
 			} else {
 				/*
 				 * Did not get the queue lock while trying.
@@ -1803,7 +1814,7 @@ retry:
 locked:
 		__iocg_destroy(iocg, iog, queue_lock_held);
 		if (queue_lock_held) {
-			spin_unlock_irq(efqd->queue->queue_lock);
+			spin_unlock_irqrestore(efqd->queue->queue_lock, flags1);
 			queue_lock_held = 0;
 		}
 	}
@@ -1811,6 +1822,7 @@ locked:
 
 	BUG_ON(!hlist_empty(&iocg->group_data));
 
+	free_css_id(&io_subsys, &iocg->css);
 	kfree(iocg);
 }
