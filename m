From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 4/5] userns: Make map_id_down a wrapper for map_id_range_down
Date: Tue, 31 Oct 2017 18:48:46 -0500
Message-ID: <87efpiswtd.fsf_-___1834.9421131008$1509493781$gmane$org@xmission.com>
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


There is no good reason for this code duplication, the number of cache
line accesses not the number of instructions are the bottleneck in
this code.

Therefore simplify maintenance by removing unnecessary code.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/user_namespace.c | 38 +-------------------------------------
 1 file changed, 1 insertion(+), 37 deletions(-)

diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 4f7e357ac1e2..1d0298870ee3 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -313,45 +313,9 @@ static u32 map_id_range_down(struct uid_gid_map *map, u32 id, u32 count)
 	return id;
 }
 
-/**
- * map_id_down_base - Find idmap via binary search in static extent array.
- * Can only be called if number of mappings is equal or less than
- * UID_GID_MAP_MAX_BASE_EXTENTS.
- */
-static struct uid_gid_extent *
-map_id_down_base(unsigned extents, struct uid_gid_map *map, u32 id)
-{
-	unsigned idx;
-	u32 first, last;
-
-	/* Find the matching extent */
-	for (idx = 0; idx < extents; idx++) {
-		first = map->extent[idx].first;
-		last = first + map->extent[idx].count - 1;
-		if (id >= first && id <= last)
-			return &map->extent[idx];
-	}
-	return NULL;
-}
-
 static u32 map_id_down(struct uid_gid_map *map, u32 id)
 {
-	struct uid_gid_extent *extent;
-	unsigned extents = map->nr_extents;
-	smp_rmb();
-
-	if (extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
-		extent = map_id_down_base(extents, map, id);
-	else
-		extent = map_id_range_down_max(extents, map, id, 1);
-
-	/* Map the id or note failure */
-	if (extent)
-		id = (id - extent->first) + extent->lower_first;
-	else
-		id = (u32) -1;
-
-	return id;
+	return map_id_range_down(map, id, 1);
 }
 
 /**
-- 
2.14.1
