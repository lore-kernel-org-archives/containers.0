From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH] CGroups: Include hierarchy ids in /proc/<pid>/cgroup
Date: Tue, 08 Apr 2008 17:05:51 -0700
Message-ID: <47FC085F.2070709__44025.8504510441$1207699772$gmane$org@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

[ The RFC associated with this patch is whether there's a better way to export such information in a way that's simultaneously extensible, human-readable and machine-parsable ]

CGroups: Include hierarchy ids in /proc/<pid>/cgroup

This patch extends the /proc/<pid>/cgroup file to include the
appropriate hierarchy ID on each line. Currently this ID isn't really
needed since a hierarchy can be completely identified by the set of
subsystems bound to it, but this is likely to change in the near
future in order to support stateless subsystems and merging/rebinding
of subsystems. Getting this change into 2.6.25 reduces the need for
an API change later.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 kernel/cgroup.c |    1 +
 1 file changed, 1 insertion(+)

Index: cgroup-2.6.25-rc8-mm1/kernel/cgroup.c
===================================================================
--- cgroup-2.6.25-rc8-mm1.orig/kernel/cgroup.c
+++ cgroup-2.6.25-rc8-mm1/kernel/cgroup.c
@@ -2613,6 +2613,7 @@ static int proc_cgroup_show(struct seq_f
 		/* Skip this hierarchy if it has no active subsystems */
 		if (!root->actual_subsys_bits)
 			continue;
+		seq_printf(m, "%lu:", root->subsys_bits);
 		for_each_subsys(root, ss)
 			seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
 		seq_putc(m, ':');
