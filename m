From: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Subject: [RFC/PATCH 4/8]: CGroup Files: Move notify_on_release file to
	separate write handler
Date: Mon, 12 May 2008 23:37:11 -0700
Message-ID: <20080513071522.635138000@menage.corp.google.com>
References: <20080513063707.049448000@menage.corp.google.com>
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
 kernel/cgroup.c |   27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

Index: cgroup-2.6.25-mm1/kernel/cgroup.c
===================================================================
--- cgroup-2.6.25-mm1.orig/kernel/cgroup.c
+++ cgroup-2.6.25-mm1/kernel/cgroup.c
@@ -1440,13 +1440,6 @@ static ssize_t cgroup_common_file_write(
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
@@ -2275,6 +2268,18 @@ static u64 cgroup_read_notify_on_release
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
@@ -2291,7 +2296,7 @@ static struct cftype files[] = {
 	{
 		.name = "notify_on_release",
 		.read_u64 = cgroup_read_notify_on_release,
-		.write = cgroup_common_file_write,
+		.write_u64 = cgroup_write_notify_on_release,
 		.private = FILE_NOTIFY_ON_RELEASE,
 	},
 };

--
