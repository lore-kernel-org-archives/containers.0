From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH -mmotm 1/3] memcg: dirty memory documentation
Date: Mon,  1 Mar 2010 22:23:38 +0100
Message-ID: <1267478620-5276-2-git-send-email-arighi__3830.74295609749$1267478870$gmane$org@develer.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267478620-5276-1-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Document cgroup dirty memory interfaces and statistics.

Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
---
 Documentation/cgroups/memory.txt |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index aad7d05..878afa7 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -308,6 +308,11 @@ cache		- # of bytes of page cache memory.
 rss		- # of bytes of anonymous and swap cache memory.
 pgpgin		- # of pages paged in (equivalent to # of charging events).
 pgpgout		- # of pages paged out (equivalent to # of uncharging events).
+filedirty	- # of pages that are waiting to get written back to the disk.
+writeback	- # of pages that are actively being written back to the disk.
+writeback_tmp	- # of pages used by FUSE for temporary writeback buffers.
+nfs		- # of NFS pages sent to the server, but not yet committed to
+		  the actual storage.
 active_anon	- # of bytes of anonymous and  swap cache memory on active
 		  lru list.
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
@@ -343,6 +348,37 @@ Note:
   - a cgroup which uses hierarchy and it has child cgroup.
   - a cgroup which uses hierarchy and not the root of hierarchy.
 
+5.4 dirty memory
+
+  Control the maximum amount of dirty pages a cgroup can have at any given time.
+
+  Limiting dirty memory is like fixing the max amount of dirty (hard to
+  reclaim) page cache used by any cgroup. So, in case of multiple cgroup writers,
+  they will not be able to consume more than their designated share of dirty
+  pages and will be forced to perform write-out if they cross that limit.
+
+  The interface is equivalent to the procfs interface: /proc/sys/vm/dirty_*.
+  It is possible to configure a limit to trigger both a direct writeback or a
+  background writeback performed by per-bdi flusher threads.
+
+  Per-cgroup dirty limits can be set using the following files in the cgroupfs:
+
+  - memory.dirty_ratio: contains, as a percentage of cgroup memory, the
+    amount of dirty memory at which a process which is generating disk writes
+    inside the cgroup will start itself writing out dirty data.
+
+  - memory.dirty_bytes: the amount of dirty memory of the cgroup (expressed in
+    bytes) at which a process generating disk writes will start itself writing
+    out dirty data.
+
+  - memory.dirty_background_ratio: contains, as a percentage of the cgroup
+    memory, the amount of dirty memory at which background writeback kernel
+    threads will start writing out dirty data.
+
+  - memory.dirty_background_bytes: the amount of dirty memory of the cgroup (in
+    bytes) at which background writeback kernel threads will start writing out
+    dirty data.
+
 
 6. Hierarchy support
 
-- 
1.6.3.3
