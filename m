From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/8] Changes css_set freeing mechanism to be under RCU
Date: Tue, 18 Aug 2009 16:58:32 -0700
Message-ID: <20090818235832.22531.96610.stgit@menage.mtv.corp.google.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090818235059.22531.42618.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>


Changes css_set freeing mechanism to be under RCU

This is a prepatch for making the procs file writable. In order to free the
old css_sets for each task to be moved as they're being moved, the freeing
mechanism must be RCU-protected, or else we would have to have a call to
synchronize_rcu() for each task before freeing its old css_set.

Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 include/linux/cgroup.h |    3 +++
 kernel/cgroup.c        |    8 +++++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 88e8634..3ac78a2 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -260,6 +260,9 @@ struct css_set {
 	 * during subsystem registration (at boot time).
 	 */
 	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];
+
+	/* For RCU-protected deletion */
+	struct rcu_head rcu_head;
 };
 
 /*
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7e2b285..9f9e154 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -267,6 +267,12 @@ static struct hlist_head *css_set_hash(struct cgroup_subsys_state *css[])
 	return &css_set_table[index];
 }
 
+static void free_css_set_rcu(struct rcu_head *obj)
+{
+	struct css_set *cg = container_of(obj, struct css_set, rcu_head);
+	kfree(cg);
+}
+
 /* We don't maintain the lists running through each css_set to its
  * task until after the first call to cgroup_iter_start(). This
  * reduces the fork()/exit() overhead for people who have cgroups
@@ -310,7 +316,7 @@ static void __put_css_set(struct css_set *cg, int taskexit)
 	}
 
 	write_unlock(&css_set_lock);
-	kfree(cg);
+	call_rcu(&cg->rcu_head, free_css_set_rcu);
 }
 
 /*
