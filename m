From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 2/5] userns: Simplify the user and group mapping functions
Date: Tue, 31 Oct 2017 18:47:43 -0500
Message-ID: <87po92swv4.fsf_-___36180.7318557569$1509493708$gmane$org@xmission.com>
References: <20171024220441.10235-1-christian.brauner@ubuntu.com>
	<20171024220441.10235-2-christian.brauner@ubuntu.com>
	<871sliubhj.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871sliubhj.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Tue, 31 Oct 2017 18:46:32 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, tycho-E0fblnxP3wo@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Consolidate reading the number of extents and computing the return
value in the map_id_down, map_id_range_down and map_id_range.

This removal of one read of extents makes one smp_rmb unnecessary
and makes the code safe it is executed during the map write.  Reading
the number of extents twice and depending on the result being the same
is not safe, as it could be 0 the first time and > 5 the second time,
which would lead to misinterpreting the union fields.

The consolidation of the return value just removes a duplicate
caluculation which should make it easier to understand and maintain
the code.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/user_namespace.c | 132 +++++++++++++++++++++---------------------------
 1 file changed, 58 insertions(+), 74 deletions(-)

diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index c9904ee084c4..563a2981d7c7 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -256,28 +256,17 @@ static int cmp_map_id(const void *k, const void *e)
  * map_id_range_down_max - Find idmap via binary search in ordered idmap array.
  * Can only be called if number of mappings exceeds UID_GID_MAP_MAX_BASE_EXTENTS.
  */
-static u32 map_id_range_down_max(struct uid_gid_map *map, u32 id, u32 count)
+static struct uid_gid_extent *
+map_id_range_down_max(unsigned extents, struct uid_gid_map *map, u32 id, u32 count)
 {
-	u32 extents;
-	struct uid_gid_extent *extent;
 	struct idmap_key key;
 
 	key.map_up = false;
 	key.count = count;
 	key.id = id;
 
-	extents = map->nr_extents;
-	smp_rmb();
-
-	extent = bsearch(&key, map->forward, extents,
-			 sizeof(struct uid_gid_extent), cmp_map_id);
-	/* Map the id or note failure */
-	if (extent)
-		id = (id - extent->first) + extent->lower_first;
-	else
-		id = (u32) -1;
-
-	return id;
+	return bsearch(&key, map->forward, extents,
+		       sizeof(struct uid_gid_extent), cmp_map_id);
 }
 
 /**
@@ -285,41 +274,43 @@ static u32 map_id_range_down_max(struct uid_gid_map *map, u32 id, u32 count)
  * Can only be called if number of mappings is equal or less than
  * UID_GID_MAP_MAX_BASE_EXTENTS.
  */
-static u32 map_id_range_down_base(struct uid_gid_map *map, u32 id, u32 count)
+static struct uid_gid_extent *
+map_id_range_down_base(unsigned extents, struct uid_gid_map *map, u32 id, u32 count)
 {
-	unsigned idx, extents;
+	unsigned idx;
 	u32 first, last, id2;
 
 	id2 = id + count - 1;
 
 	/* Find the matching extent */
-	extents = map->nr_extents;
-	smp_rmb();
 	for (idx = 0; idx < extents; idx++) {
 		first = map->extent[idx].first;
 		last = first + map->extent[idx].count - 1;
 		if (id >= first && id <= last &&
 		    (id2 >= first && id2 <= last))
-			break;
+			return &map->extent[idx];
 	}
-	/* Map the id or note failure */
-	if (idx < extents)
-		id = (id - first) + map->extent[idx].lower_first;
-	else
-		id = (u32) -1;
-
-	return id;
+	return NULL;
 }
 
 static u32 map_id_range_down(struct uid_gid_map *map, u32 id, u32 count)
 {
-	u32 extents = map->nr_extents;
+	struct uid_gid_extent *extent;
+	unsigned extents = map->nr_extents;
 	smp_rmb();
 
 	if (extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
-		return map_id_range_down_base(map, id, count);
+		extent = map_id_range_down_base(extents, map, id, count);
+	else
+		extent = map_id_range_down_max(extents, map, id, count);
 
-	return map_id_range_down_max(map, id, count);
+	/* Map the id or note failure */
+	if (extent)
+		id = (id - extent->first) + extent->lower_first;
+	else
+		id = (u32) -1;
+
+	return id;
 }
 
 /**
@@ -327,38 +318,40 @@ static u32 map_id_range_down(struct uid_gid_map *map, u32 id, u32 count)
  * Can only be called if number of mappings is equal or less than
  * UID_GID_MAP_MAX_BASE_EXTENTS.
  */
-static u32 map_id_down_base(struct uid_gid_map *map, u32 id)
+static struct uid_gid_extent *
+map_id_down_base(unsigned extents, struct uid_gid_map *map, u32 id)
 {
-	unsigned idx, extents;
+	unsigned idx;
 	u32 first, last;
 
 	/* Find the matching extent */
-	extents = map->nr_extents;
-	smp_rmb();
 	for (idx = 0; idx < extents; idx++) {
 		first = map->extent[idx].first;
 		last = first + map->extent[idx].count - 1;
 		if (id >= first && id <= last)
-			break;
+			return &map->extent[idx];
 	}
-	/* Map the id or note failure */
-	if (idx < extents)
-		id = (id - first) + map->extent[idx].lower_first;
-	else
-		id = (u32) -1;
-
-	return id;
+	return NULL;
 }
 
 static u32 map_id_down(struct uid_gid_map *map, u32 id)
 {
-	u32 extents = map->nr_extents;
+	struct uid_gid_extent *extent;
+	unsigned extents = map->nr_extents;
 	smp_rmb();
 
 	if (extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
-		return map_id_down_base(map, id);
+		extent = map_id_down_base(extents, map, id);
+	else
+		extent = map_id_range_down_max(extents, map, id, 1);
 
-	return map_id_range_down_max(map, id, 1);
+	/* Map the id or note failure */
+	if (extent)
+		id = (id - extent->first) + extent->lower_first;
+	else
+		id = (u32) -1;
+
+	return id;
 }
 
 /**
@@ -366,48 +359,50 @@ static u32 map_id_down(struct uid_gid_map *map, u32 id)
  * Can only be called if number of mappings is equal or less than
  * UID_GID_MAP_MAX_BASE_EXTENTS.
  */
-static u32 map_id_up_base(struct uid_gid_map *map, u32 id)
+static struct uid_gid_extent *
+map_id_up_base(unsigned extents, struct uid_gid_map *map, u32 id)
 {
-	unsigned idx, extents;
+	unsigned idx;
 	u32 first, last;
 
 	/* Find the matching extent */
-	extents = map->nr_extents;
-	smp_rmb();
 	for (idx = 0; idx < extents; idx++) {
 		first = map->extent[idx].lower_first;
 		last = first + map->extent[idx].count - 1;
 		if (id >= first && id <= last)
-			break;
+			return &map->extent[idx];
 	}
-	/* Map the id or note failure */
-	if (idx < extents)
-		id = (id - first) + map->extent[idx].first;
-	else
-		id = (u32) -1;
-
-	return id;
+	return NULL;
 }
 
 /**
  * map_id_up_max - Find idmap via binary search in ordered idmap array.
  * Can only be called if number of mappings exceeds UID_GID_MAP_MAX_BASE_EXTENTS.
  */
-static u32 map_id_up_max(struct uid_gid_map *map, u32 id)
+static struct uid_gid_extent *
+map_id_up_max(unsigned extents, struct uid_gid_map *map, u32 id)
 {
-	u32 extents;
-	struct uid_gid_extent *extent;
 	struct idmap_key key;
 
 	key.map_up = true;
 	key.count = 1;
 	key.id = id;
 
-	extents = map->nr_extents;
+	return bsearch(&key, map->reverse, extents,
+		       sizeof(struct uid_gid_extent), cmp_map_id);
+}
+
+static u32 map_id_up(struct uid_gid_map *map, u32 id)
+{
+	struct uid_gid_extent *extent;
+	unsigned extents = map->nr_extents;
 	smp_rmb();
 
-	extent = bsearch(&key, map->reverse, extents,
-			 sizeof(struct uid_gid_extent), cmp_map_id);
+	if (extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
+		extent = map_id_up_base(extents, map, id);
+	else
+		extent = map_id_up_max(extents, map, id);
+
 	/* Map the id or note failure */
 	if (extent)
 		id = (id - extent->lower_first) + extent->first;
@@ -417,17 +412,6 @@ static u32 map_id_up_max(struct uid_gid_map *map, u32 id)
 	return id;
 }
 
-static u32 map_id_up(struct uid_gid_map *map, u32 id)
-{
-	u32 extents = map->nr_extents;
-	smp_rmb();
-
-	if (extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
-		return map_id_up_base(map, id);
-
-	return map_id_up_max(map, id);
-}
-
 /**
  *	make_kuid - Map a user-namespace uid pair into a kuid.
  *	@ns:  User namespace that the uid is in
-- 
2.14.1
