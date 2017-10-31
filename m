From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 3/5] userns: Don't read extents twice in m_start
Date: Tue, 31 Oct 2017 18:48:17 -0500
Message-ID: <87k1zaswu6.fsf_-___44120.9537246779$1509493773$gmane$org@xmission.com>
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


This is important so reading /proc/<pid>/{uid_map,gid_map,projid_map} while
the map is being written does not do strange things.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/user_namespace.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 563a2981d7c7..4f7e357ac1e2 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -683,11 +683,13 @@ static void *m_start(struct seq_file *seq, loff_t *ppos,
 		     struct uid_gid_map *map)
 {
 	loff_t pos = *ppos;
+	unsigned extents = map->nr_extents;
+	smp_rmb();
 
-	if (pos >= map->nr_extents)
+	if (pos >= extents)
 		return NULL;
 
-	if (map->nr_extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
+	if (extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
 		return &map->extent[pos];
 
 	return &map->forward[pos];
-- 
2.14.1
