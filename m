From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cgroup: alloc_css_id() increments hierarchy depth
Date: Fri, 28 May 2010 08:16:21 -0700
Message-ID: <1275059781-9831-1-git-send-email-gthelen__38438.0366806456$1275060196$gmane$org@google.com>
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
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Child groups should have a greater depth than their parents.
Prior to this change, the parent would incorrectly report zero
memory usage for child cgroups when use_hierarchy is enabled.

test script:
  mount -t cgroup none /cgroups -o memory
  cd /cgroups
  mkdir cg1

  echo 1 > cg1/memory.use_hierarchy
  mkdir cg1/cg11

  echo $$ > cg1/cg11/tasks
  dd if=/dev/zero of=/tmp/foo bs=1M count=1

  echo
  echo CHILD
  grep cache cg1/cg11/memory.stat

  echo
  echo PARENT
  grep cache cg1/memory.stat

  echo $$ > tasks
  rmdir cg1/cg11 cg1
  cd /
  umount /cgroups

Using fae9c79, a recent patch that changed alloc_css_id() depth computation,
the parent incorrectly reports zero usage:
  root@ubuntu:~# ./test
  1+0 records in
  1+0 records out
  1048576 bytes (1.0 MB) copied, 0.0151844 s, 69.1 MB/s

  CHILD
  cache 1048576
  total_cache 1048576

  PARENT
  cache 0
  total_cache 0

With this patch, the parent correctly includes child usage:
  root@ubuntu:~# ./test
  1+0 records in
  1+0 records out
  1048576 bytes (1.0 MB) copied, 0.0136827 s, 76.6 MB/s

  CHILD
  cache 1052672
  total_cache 1052672

  PARENT
  cache 0
  total_cache 1052672

Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 422cb19..3ac6f5b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4598,7 +4598,7 @@ static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
 	parent_css = parent->subsys[subsys_id];
 	child_css = child->subsys[subsys_id];
 	parent_id = parent_css->id;
-	depth = parent_id->depth;
+	depth = parent_id->depth + 1;
 
 	child_id = get_new_cssid(ss, depth);
 	if (IS_ERR(child_id))
-- 
1.7.0.1
