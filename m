From: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 4/8] CGroup Files: Move notify_on_release file to separate
	write handler
Date: Fri, 20 Jun 2008 16:44:02 -0700
Message-ID: <20080621000730.444845000__11311.3350737423$1214007017$gmane$org@menage.corp.google.com>
References: <20080620234358.182933000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=cgroup_notify_on_release_file.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: pj-sJ/iWh9BUns@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch moves the write handler for the cgroups notify_on_release
file into a separate handler. This handler requires no cgroups locking
since it relies on atomic bitops for synchronization.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 kernel/cgroup.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

Index: cws-2.6.26-rc5-mm3/kernel/cgroup.c
===================================================================
--- cws-2.6.26-rc5-mm3.orig/kernel/cgroup.c
+++ cws-2.6.26-rc5-mm3/kernel/cgroup.c
@@ -1471,13 +1471,6 @@ static ssize_t cgroup_common_file_write(
 	case FILE_TASKLIST:
 		retval = attach_task_by_pid(cgrp, buffer);
 		break;
-	case FILE_NOTIFY_ON_RELEASE:
-		clear_bit(CGRP_RELEASABLE, &cgrp->flags);
-		if (simple_strtoul(buffer, NULL, 10) != 0)
-			set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
-		else
-			clear_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
-		break;
 	default:
 		retval = -EINVAL;
 		goto out2;
@@ -2248,6 +2241,18 @@ static u64 cgroup_read_notify_on_release
 	return notify_on_release(cgrp);
 }
 
+static int cgroup_write_notify_on_release(struct cgroup *cgrp,
+					  struct cftype *cft,
+					  u64 val)
+{
+	clear_bit(CGRP_RELEASABLE, &cgrp->flags);
+	if (val)
+		set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
+	else
+		clear_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
+	return 0;
+}
+
 /*
  * for the common functions, 'private' gives the type of file
  */
@@ -2264,7 +2269,7 @@ static struct cftype files[] = {
 	{
 		.name = "notify_on_release",
 		.read_u64 = cgroup_read_notify_on_release,
-		.write = cgroup_common_file_write,
+		.write_u64 = cgroup_write_notify_on_release,
 		.private = FILE_NOTIFY_ON_RELEASE,
 	},
 };

--
