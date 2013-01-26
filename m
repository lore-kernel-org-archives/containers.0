From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 2/6] userns: Allow any uid or gid mappings that don't
	overlap.
Date: Fri, 25 Jan 2013 18:21:00 -0800
Message-ID: <87zjzwhegj.fsf@xmission.com>
References: <87ehh8it9s.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ehh8it9s.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Fri, 25 Jan 2013 18:15:43 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


When I initially wrote the code for /proc/<pid>/uid_map.  I was lazy
and avoided duplicate mappings by the simple expedient of ensuring the
first number in a new extent was greater than any number in the
previous extent.

Unfortunately that precludes a number of valid mappings, and someone
noticed and complained.  So use a simple check to ensure that ranges
in the mapping extents don't overlap.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/user_namespace.c |   45 +++++++++++++++++++++++++++++++++++++++------
 1 files changed, 39 insertions(+), 6 deletions(-)

diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 24f8ec3..8b65083 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -520,6 +520,42 @@ struct seq_operations proc_projid_seq_operations = {
 	.show = projid_m_show,
 };
 
+static bool mappings_overlap(struct uid_gid_map *new_map, struct uid_gid_extent *extent)
+{
+	u32 upper_first, lower_first, upper_last, lower_last;
+	unsigned idx;
+
+	upper_first = extent->first;
+	lower_first = extent->lower_first;
+	upper_last = upper_first + extent->count - 1;
+	lower_last = lower_first + extent->count - 1;
+
+	for (idx = 0; idx < new_map->nr_extents; idx++) {
+		u32 prev_upper_first, prev_lower_first;
+		u32 prev_upper_last, prev_lower_last;
+		struct uid_gid_extent *prev;
+
+		prev = &new_map->extent[idx];
+
+		prev_upper_first = prev->first;
+		prev_lower_first = prev->lower_first;
+		prev_upper_last = prev_upper_first + prev->count - 1;
+		prev_lower_last = prev_lower_first + prev->count - 1;
+
+		/* Does the upper range intersect a previous extent? */
+		if ((prev_upper_first <= upper_last) &&
+		    (prev_upper_last >= upper_first))
+			return true;
+
+		/* Does the lower range intersect a previous extent? */
+		if ((prev_lower_first <= lower_last) &&
+		    (prev_lower_last >= lower_first))
+			return true;
+	}
+	return false;
+}
+
+
 static DEFINE_MUTEX(id_map_mutex);
 
 static ssize_t map_write(struct file *file, const char __user *buf,
@@ -532,7 +568,7 @@ static ssize_t map_write(struct file *file, const char __user *buf,
 	struct user_namespace *ns = seq->private;
 	struct uid_gid_map new_map;
 	unsigned idx;
-	struct uid_gid_extent *extent, *last = NULL;
+	struct uid_gid_extent *extent = NULL;
 	unsigned long page = 0;
 	char *kbuf, *pos, *next_line;
 	ssize_t ret = -EINVAL;
@@ -635,14 +671,11 @@ static ssize_t map_write(struct file *file, const char __user *buf,
 		if ((extent->lower_first + extent->count) <= extent->lower_first)
 			goto out;
 
-		/* For now only accept extents that are strictly in order */
-		if (last &&
-		    (((last->first + last->count) > extent->first) ||
-		     ((last->lower_first + last->count) > extent->lower_first)))
+		/* Do the ranges in extent overlap any previous extents? */
+		if (mappings_overlap(&new_map, extent))
 			goto out;
 
 		new_map.nr_extents++;
-		last = extent;
 
 		/* Fail if the file contains too many extents */
 		if ((new_map.nr_extents == UID_GID_MAP_MAX_EXTENTS) &&
-- 
1.7.5.4
