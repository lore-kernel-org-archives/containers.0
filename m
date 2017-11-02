From: Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 1/1] userns: Fix/clarify memory ordering
Date: Thu,  2 Nov 2017 12:03:44 +0100
Message-ID: <20171102110344.31647-2-christian.brauner@ubuntu.com>
References: <20171102110344.31647-1-christian.brauner@ubuntu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20171102110344.31647-1-christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
Cc: nborisov-IBi9RG/b67k@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, tycho-E0fblnxP3wo@public.gmane.org, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Nikolay noticed a number of undocumented memory barriers in this code;
the ordering is fairly simple but not explicitly described. Cure that.

Switch over to smp_store_release() / smp_load_acquire() as that is the
natural fit for the pattern and includes the missing but required
WRITE_ONCE()/READ_ONCE()s.

CC: Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Reported-by: Nikolay Borisov <nborisov-IBi9RG/b67k@public.gmane.org>
Signed-off-by: Peter Zijlstra (Intel) <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Signed-off-by: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
---
 kernel/user_namespace.c | 74 +++++++++++++++++++++++++++++++------------------
 1 file changed, 47 insertions(+), 27 deletions(-)

diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 899c31060ff3..2129762a930e 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -27,8 +27,47 @@
 #include <linux/sort.h>
 
 static struct kmem_cache *user_ns_cachep __read_mostly;
+
+/**
+ * The userns_state_mutex serializes all writes to any given map.
+ *
+ * Any map is only ever written once.
+ *
+ * An id map fits within 1 cache line on most architectures.
+ */
 static DEFINE_MUTEX(userns_state_mutex);
 
+/**
+ * There is a data dependency between reading the count of the extents and the
+ * values of the extents. The desired behavior is to see the values of the
+ * extents that were written before the count of the extents.
+ *
+ * To achieve this smp_store_release() is used to guarantee the write order and
+ * smp_load_acquire() is guaranteed that we observe the written data.
+ */
+static inline void map_store_extents(struct uid_gid_map *map,
+				     unsigned int extents)
+{
+	/*
+	 * Ensure the map->extent[] stores happen-before we grow map->nr_extents
+	 * to cover it.
+	 *
+	 * Matches the load_acquire in map_load_extents().
+	 */
+	smp_store_release(&map->nr_extents, extents);
+}
+
+static inline unsigned int map_load_extents(struct uid_gid_map *map)
+{
+	/*
+	 * Ensure the map->nr_extents load happens-before we try and access
+	 * map->extent[], such that we guarantee the data is in fact there.
+	 *
+	 * Matches the store-release in map_store_extents().
+	 */
+	return smp_load_acquire(&map->nr_extents);
+}
+
 static bool new_idmap_permitted(const struct file *file,
 				struct user_namespace *ns, int cap_setid,
 				struct uid_gid_map *map);
@@ -296,9 +335,9 @@ map_id_range_down_base(unsigned extents, struct uid_gid_map *map, u32 id, u32 co
 static u32 map_id_range_down(struct uid_gid_map *map, u32 id, u32 count)
 {
 	struct uid_gid_extent *extent;
-	unsigned extents = map->nr_extents;
-	smp_rmb();
+	unsigned extents;
 
+	extents = map_load_extents(map);
 	if (extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
 		extent = map_id_range_down_base(extents, map, id, count);
 	else
@@ -359,9 +398,9 @@ map_id_up_max(unsigned extents, struct uid_gid_map *map, u32 id)
 static u32 map_id_up(struct uid_gid_map *map, u32 id)
 {
 	struct uid_gid_extent *extent;
-	unsigned extents = map->nr_extents;
-	smp_rmb();
+	unsigned extents;
 
+	extents = map_load_extents(map);
 	if (extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
 		extent = map_id_up_base(extents, map, id);
 	else
@@ -647,9 +686,9 @@ static void *m_start(struct seq_file *seq, loff_t *ppos,
 		     struct uid_gid_map *map)
 {
 	loff_t pos = *ppos;
-	unsigned extents = map->nr_extents;
-	smp_rmb();
+	unsigned extents;
 
+	extents = map_load_extents(map);
 	if (pos >= extents)
 		return NULL;
 
@@ -860,25 +899,6 @@ static ssize_t map_write(struct file *file, const char __user *buf,
 	char *kbuf = NULL, *pos, *next_line;
 	ssize_t ret = -EINVAL;
 
-	/*
-	 * The userns_state_mutex serializes all writes to any given map.
-	 *
-	 * Any map is only ever written once.
-	 *
-	 * An id map fits within 1 cache line on most architectures.
-	 *
-	 * On read nothing needs to be done unless you are on an
-	 * architecture with a crazy cache coherency model like alpha.
-	 *
-	 * There is a one time data dependency between reading the
-	 * count of the extents and the values of the extents.  The
-	 * desired behavior is to see the values of the extents that
-	 * were written before the count of the extents.
-	 *
-	 * To achieve this smp_wmb() is used on guarantee the write
-	 * order and smp_rmb() is guaranteed that we don't have crazy
-	 * architectures returning stale data.
-	 */
 	mutex_lock(&userns_state_mutex);
 
 	memset(&new_map, 0, sizeof(struct uid_gid_map));
@@ -1015,8 +1035,8 @@ static ssize_t map_write(struct file *file, const char __user *buf,
 		map->forward = new_map.forward;
 		map->reverse = new_map.reverse;
 	}
-	smp_wmb();
-	map->nr_extents = new_map.nr_extents;
+
+	map_store_extents(map, new_map.nr_extents);
 
 	*ppos = count;
 	ret = count;
-- 
2.14.1
