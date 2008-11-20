From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 3/7] Introduction for new feature
Date: Thu, 20 Nov 2008 19:11:08 +0800
Message-ID: <492545CC.6000909__7065.14030830494$1227179789$gmane$org@cn.fujitsu.com>
References: <4925445C.10302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4925445C.10302-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Documentation of using bio-cgroup in io-throttle.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/controllers/io-throttle.txt |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/Documentation/controllers/io-throttle.txt b/Documentation/controllers/io-throttle.txt
index 2a3bbd1..d3510ae 100644
--- a/Documentation/controllers/io-throttle.txt
+++ b/Documentation/controllers/io-throttle.txt
@@ -223,7 +223,34 @@ $ cat /proc/$$/io-throttle-stat
    \ \_______global bandwidth sleep (clock ticks)
     \________global bandwidth counter
 
-2.4. Examples
+2.4. Buffered-io tracking
+bio-cgroup can be used to track buffered-io(in delay-write condition) and for 
+proper throttling. You can directly mount io-throttle and bio-cgroup together 
+to track buffered-io. An alternative choice is making use of bio-cgroup id. An 
+association between a given io-throttle cgroup and a given bio-cgroup cgroup can 
+be built by echo a bio-cgroup id to the file blockio.bio_id. This file is exported 
+for the purpose of associating io-throttle and bio-cgroup groups. If you'd like to 
+create an association, you must ensure the io-throttle group is empty, that is, 
+there are no tasks in this group. otherwise, association creating will fail. If an 
+association is successfully built, task moving in this group will be denied. Of 
+course, you can remove an association, just echo an negative number into 
+blockio.bio_id.
+
+Example:
+* Create an association between a given io-throttle group and a given bio-cgroup 
+group.
+$ mount -t cgroup -o bio bio-cgroup /mnt/bio-cgroup/
+$ cd /mnt/bio-cgroup/
+$ mkdir bio-grp
+$ cat bio-grp/bio.id
+1
+
+$ mount -t cgroup -o blockio blockio /mnt/throttle
+$ cd /mnt/throttle
+$ mkdir foo
+$ echo 1 > foo/blockio.bio_id
+
+2.5. Examples
 
 * Mount the cgroup filesystem (blockio subsystem):
   # mkdir /mnt/cgroup
-- 1.5.4.rc3 
