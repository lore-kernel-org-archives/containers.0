From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 1/5] userns: Don't special case a count of 0
Date: Tue, 31 Oct 2017 18:47:15 -0500
Message-ID: <87vaiuswvw.fsf_-___43815.0337235585$1509493675$gmane$org@xmission.com>
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


We can always use a count of 1 so there is no reason to have
a special case of a count of 0.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/user_namespace.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 5fd2d53dbc75..c9904ee084c4 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -232,11 +232,7 @@ static int cmp_map_id(const void *k, const void *e)
 	const struct idmap_key *key = k;
 	const struct uid_gid_extent *el = e;
 
-	/* handle map_id_range_down() */
-	if (key->count)
-		id2 = key->id + key->count - 1;
-	else
-		id2 = key->id;
+	id2 = key->id + key->count - 1;
 
 	/* handle map_id_{down,up}() */
 	if (key->map_up)
@@ -362,7 +358,7 @@ static u32 map_id_down(struct uid_gid_map *map, u32 id)
 	if (extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
 		return map_id_down_base(map, id);
 
-	return map_id_range_down_max(map, id, 0);
+	return map_id_range_down_max(map, id, 1);
 }
 
 /**
@@ -404,7 +400,7 @@ static u32 map_id_up_max(struct uid_gid_map *map, u32 id)
 	struct idmap_key key;
 
 	key.map_up = true;
-	key.count = 0;
+	key.count = 1;
 	key.id = id;
 
 	extents = map->nr_extents;
-- 
2.14.1
