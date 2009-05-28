From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 3/7][v2] Add target_pid parameter to alloc_pidmap()
Date: Wed, 27 May 2009 21:38:34 -0700
Message-ID: <20090528043834.GC16522@us.ibm.com>
References: <20090528043748.GA16522@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090528043748.GA16522-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


From a1fdec1036a952359d02a7c667d126bd2fff6804 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Mon, 4 May 2009 01:17:41 -0700
Subject: [RFC][PATCH 3/7][v2] Add target_pid parameter to alloc_pidmap()

With support for setting a specific pid number for a process,
alloc_pidmap() will need a paramter a 'target_pid' parameter.

Changelog[v2]:
	- (Serge Hallyn) Check for 'pid < 0' in set_pidmap().(Code
	  actually checks for 'pid <= 0' for completeness).

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 kernel/pid.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/kernel/pid.c b/kernel/pid.c
index b2d6a19..b44dd21 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -147,11 +147,35 @@ static int alloc_pidmap_page(struct pidmap *map)
 	return 0;
 }
 
-static int alloc_pidmap(struct pid_namespace *pid_ns)
+static int set_pidmap(struct pid_namespace *pid_ns, int pid)
+{
+	int offset;
+	struct pidmap *map;
+
+	if (pid <= 0 || pid >= pid_max)
+		return -EINVAL;
+
+	offset = pid & BITS_PER_PAGE_MASK;
+	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
+
+	if (alloc_pidmap_page(map))
+		return -ENOMEM;
+
+	if (test_and_set_bit(offset, map->page))
+		return -EBUSY;
+
+	atomic_dec(&map->nr_free);
+	return pid;
+}
+
+static int alloc_pidmap(struct pid_namespace *pid_ns, int target_pid)
 {
 	int i, rc, offset, max_scan, pid, last = pid_ns->last_pid;
 	struct pidmap *map;
 
+	if (target_pid)
+		return set_pidmap(pid_ns, target_pid);
+
 	pid = last + 1;
 	if (pid >= pid_max)
 		pid = RESERVED_PIDS;
@@ -270,7 +294,7 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 
 	tmp = ns;
 	for (i = ns->level; i >= 0; i--) {
-		nr = alloc_pidmap(tmp);
+		nr = alloc_pidmap(tmp, 0);
 		if (nr < 0)
 			goto out_free;
 
-- 
1.5.2.5
