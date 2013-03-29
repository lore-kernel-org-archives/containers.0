From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2 01/28] super: fix calculation of shrinkable objects for
	small numbers
Date: Fri, 29 Mar 2013 13:13:43 +0400
Message-ID: <1364548450-28254-2-git-send-email-glommer@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1364548450-28254-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

The sysctl knob sysctl_vfs_cache_pressure is used to determine which
percentage of the shrinkable objects in our cache we should actively try
to shrink.

It works great in situations in which we have many objects (at least
more than 100), because the aproximation errors will be negligible. But
if this is not the case, specially when total_objects < 100, we may end
up concluding that we have no objects at all (total / 100 = 0,  if total
< 100).

This is certainly not the biggest killer in the world, but may matter in
very low kernel memory situations.

[ v2: fix it for all occurrences of sysctl_vfs_cache_pressure ]

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Reviewed-by: Carlos Maiolino <cmaiolino-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
CC: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>
CC: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
---
 fs/gfs2/glock.c        |  2 +-
 fs/gfs2/quota.c        |  2 +-
 fs/mbcache.c           |  2 +-
 fs/nfs/dir.c           |  2 +-
 fs/quota/dquot.c       |  5 ++---
 fs/super.c             | 14 +++++++-------
 fs/xfs/xfs_qm.c        |  2 +-
 include/linux/dcache.h |  4 ++++
 8 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index cf35155..078daa5 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1476,7 +1476,7 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
 		gfs2_scan_glock_lru(sc->nr_to_scan);
 	}
 
-	return (atomic_read(&lru_count) / 100) * sysctl_vfs_cache_pressure;
+	return vfs_pressure_ratio(atomic_read(&lru_count));
 }
 
 static struct shrinker glock_shrinker = {
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index c7c840e..5c14206 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -114,7 +114,7 @@ int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
 	spin_unlock(&qd_lru_lock);
 
 out:
-	return (atomic_read(&qd_lru_count) * sysctl_vfs_cache_pressure) / 100;
+	return vfs_pressure_ratio(atomic_read(&qd_lru_count));
 }
 
 static u64 qd2index(struct gfs2_quota_data *qd)
diff --git a/fs/mbcache.c b/fs/mbcache.c
index 8c32ef3..5eb0476 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -189,7 +189,7 @@ mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
 	list_for_each_entry_safe(entry, tmp, &free_list, e_lru_list) {
 		__mb_cache_entry_forget(entry, gfp_mask);
 	}
-	return (count / 100) * sysctl_vfs_cache_pressure;
+	return vfs_pressure_ratio(count);
 }
 
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f23f455..197bfff 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1996,7 +1996,7 @@ remove_lru_entry:
 	}
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
-	return (atomic_long_read(&nfs_access_nr_entries) / 100) * sysctl_vfs_cache_pressure;
+	return vfs_pressure_ratio(atomic_long_read(&nfs_access_nr_entries));
 }
 
 static void __nfs_access_zap_cache(struct nfs_inode *nfsi, struct list_head *head)
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 3e64169..762b09c 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -719,9 +719,8 @@ static int shrink_dqcache_memory(struct shrinker *shrink,
 		prune_dqcache(nr);
 		spin_unlock(&dq_list_lock);
 	}
-	return ((unsigned)
-		percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS])
-		/100) * sysctl_vfs_cache_pressure;
+	return vfs_pressure_ratio(
+	percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS]));
 }
 
 static struct shrinker dqcache_shrinker = {
diff --git a/fs/super.c b/fs/super.c
index 7465d43..2a37fd6 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -82,13 +82,13 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 		int	inodes;
 
 		/* proportion the scan between the caches */
-		dentries = (sc->nr_to_scan * sb->s_nr_dentry_unused) /
-							total_objects;
-		inodes = (sc->nr_to_scan * sb->s_nr_inodes_unused) /
-							total_objects;
+		dentries = mult_frac(sc->nr_to_scan, sb->s_nr_dentry_unused,
+							total_objects);
+		inodes = mult_frac(sc->nr_to_scan, sb->s_nr_inodes_unused,
+							total_objects);
 		if (fs_objects)
-			fs_objects = (sc->nr_to_scan * fs_objects) /
-							total_objects;
+			fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
+							total_objects);
 		/*
 		 * prune the dcache first as the icache is pinned by it, then
 		 * prune the icache, followed by the filesystem specific caches
@@ -104,7 +104,7 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 				sb->s_nr_inodes_unused + fs_objects;
 	}
 
-	total_objects = (total_objects / 100) * sysctl_vfs_cache_pressure;
+	total_objects = vfs_pressure_ratio(total_objects);
 	drop_super(sb);
 	return total_objects;
 }
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index e5b5cf9..305f4e5 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -1568,7 +1568,7 @@ xfs_qm_shake(
 	}
 
 out:
-	return (qi->qi_lru_count / 100) * sysctl_vfs_cache_pressure;
+	return vfs_pressure_ratio(qi->qi_lru_count);
 }
 
 /*
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 1a6bb81..4d24a12 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -411,4 +411,8 @@ static inline bool d_mountpoint(struct dentry *dentry)
 
 extern int sysctl_vfs_cache_pressure;
 
+static inline unsigned long vfs_pressure_ratio(unsigned long val)
+{
+	return mult_frac(val, sysctl_vfs_cache_pressure, 100);
+}
 #endif	/* __LINUX_DCACHE_H */
-- 
1.8.1.4
