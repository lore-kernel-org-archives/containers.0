From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm 4/5] memcg: dirty pages accounting and limiting
	infrastructure
Date: Wed, 17 Mar 2010 23:48:38 -0700
Message-ID: <1268894918-26797-1-git-send-email-gthelen__43869.2293748774$1268895060$gmane$org@google.com>
References: <1268609202-15581-5-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268609202-15581-5-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Balbir Singh <balbir@linux>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

I have a proposed change to "[PATCH -mmotm 4/5] memcg: dirty pages accounting
and limiting infrastructure" v6.  The change is small and I am presenting it
as a git patch (below) to be applied after 4/5 v6 has been applied.
The change is fairly simple.  An alternative would be to reject my
patch (below) and enhance get_vm_dirty_param() to loop for consistenty in all
cases.

---patch snip here, rest of email is git patch of 4/5 v6 ---

Removed unneeded looping from get_vm_dirty_param().  The only caller of
get_vm_dirty_param() gracefully handles inconsistent values, so there is no
need for get_vm_dirty_param() to loop to ensure consistency.  The previous
looping was inconsistent because it did not loop for the case where memory
cgroups were disabled.

Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 mm/memcontrol.c |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4d00c0f..990a907 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1081,6 +1081,10 @@ static void __mem_cgroup_get_dirty_param(struct vm_dirty_param *param,
  * The function fills @param with the current memcg dirty memory settings. If
  * memory cgroup is disabled or in case of error the structure is filled with
  * the global dirty memory settings.
+ *
+ * Because global and memcg vm_dirty_param are not protected, inconsistent
+ * values may be returned.  If consistent values are required, then the caller
+ * should call this routine until dirty_param_is_valid() returns true.
  */
 void get_vm_dirty_param(struct vm_dirty_param *param)
 {
@@ -1090,28 +1094,20 @@ void get_vm_dirty_param(struct vm_dirty_param *param)
 		get_global_vm_dirty_param(param);
 		return;
 	}
+
 	/*
 	 * It's possible that "current" may be moved to other cgroup while we
 	 * access cgroup. But precise check is meaningless because the task can
 	 * be moved after our access and writeback tends to take long time.
 	 * At least, "memcg" will not be freed under rcu_read_lock().
 	 */
-	while (1) {
-		rcu_read_lock();
-		memcg = mem_cgroup_from_task(current);
-		if (likely(memcg))
-			__mem_cgroup_get_dirty_param(param, memcg);
-		else
-			get_global_vm_dirty_param(param);
-		rcu_read_unlock();
-		/*
-		 * Since global and memcg vm_dirty_param are not protected we
-		 * try to speculatively read them and retry if we get
-		 * inconsistent values.
-		 */
-		if (likely(dirty_param_is_valid(param)))
-			break;
-	}
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	if (likely(memcg))
+		__mem_cgroup_get_dirty_param(param, memcg);
+	else
+		get_global_vm_dirty_param(param);
+	rcu_read_unlock();
 }
 
 /*
-- 
1.7.0.1
