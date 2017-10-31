From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 5/5] userns: Simplify insert_extent
Date: Tue, 31 Oct 2017 18:49:22 -0500
Message-ID: <878tfqswsd.fsf_-___90.7362126328692$1509493789$gmane$org@xmission.com>
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


Consolidate the code to write to the new mapping at the end of the
function to remove the duplication.  Move the increase in the number
of mappings into insert_extent, keeping the logic together.

Just a small increase in readability and maintainability.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/user_namespace.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 1d0298870ee3..899c31060ff3 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -758,12 +758,7 @@ static bool mappings_overlap(struct uid_gid_map *new_map,
  */
 static int insert_extent(struct uid_gid_map *map, struct uid_gid_extent *extent)
 {
-	if (map->nr_extents < UID_GID_MAP_MAX_BASE_EXTENTS) {
-		map->extent[map->nr_extents].first = extent->first;
-		map->extent[map->nr_extents].lower_first = extent->lower_first;
-		map->extent[map->nr_extents].count = extent->count;
-		return 0;
-	}
+	struct uid_gid_extent *dest;
 
 	if (map->nr_extents == UID_GID_MAP_MAX_BASE_EXTENTS) {
 		struct uid_gid_extent *forward;
@@ -784,9 +779,13 @@ static int insert_extent(struct uid_gid_map *map, struct uid_gid_extent *extent)
 		map->reverse = NULL;
 	}
 
-	map->forward[map->nr_extents].first = extent->first;
-	map->forward[map->nr_extents].lower_first = extent->lower_first;
-	map->forward[map->nr_extents].count = extent->count;
+	if (map->nr_extents < UID_GID_MAP_MAX_BASE_EXTENTS)
+		dest = &map->extent[map->nr_extents];
+	else
+		dest = &map->forward[map->nr_extents];
+
+	*dest = *extent;
+	map->nr_extents++;
 	return 0;
 }
 
@@ -968,8 +967,6 @@ static ssize_t map_write(struct file *file, const char __user *buf,
 		if (ret < 0)
 			goto out;
 		ret = -EINVAL;
-
-		new_map.nr_extents++;
 	}
 	/* Be very certaint the new map actually exists */
 	if (new_map.nr_extents == 0)
-- 
2.14.1
