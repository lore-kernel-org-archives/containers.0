From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cgroups: make messages more readable
Date: Tue, 28 Apr 2009 13:53:24 -0700
Message-ID: <49F76CC4.8050200@oracle.com>
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
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

Fix some cgroup messages to read better.
Update MAINTAINERS to include mm/*cgroup* files.

Signed-off-by: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 MAINTAINERS      |    1 +
 mm/page_cgroup.c |   14 +++++++-------
 2 files changed, 8 insertions(+), 7 deletions(-)

--- lnx-2630-rc3.orig/mm/page_cgroup.c
+++ lnx-2630-rc3/mm/page_cgroup.c
@@ -83,12 +83,12 @@ void __init page_cgroup_init(void)
 			goto fail;
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try cgroup_disable=memory option if you"
-	" don't want\n");
+	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
+	" don't want memory cgroups\n");
 	return;
 fail:
-	printk(KERN_CRIT "allocation of page_cgroup was failed.\n");
-	printk(KERN_CRIT "please try cgroup_disable=memory boot option\n");
+	printk(KERN_CRIT "allocation of page_cgroup failed.\n");
+	printk(KERN_CRIT "please try 'cgroup_disable=memory' boot option\n");
 	panic("Out of memory");
 }
 
@@ -257,14 +257,14 @@ void __init page_cgroup_init(void)
 		fail = init_section_page_cgroup(pfn);
 	}
 	if (fail) {
-		printk(KERN_CRIT "try cgroup_disable=memory boot option\n");
+		printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
 		panic("Out of memory");
 	} else {
 		hotplug_memory_notifier(page_cgroup_callback, 0);
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try cgroup_disable=memory option if you don't"
-	" want\n");
+	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you don't"
+	" want memory cgroups\n");
 }
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
--- lnx-2630-rc3.orig/MAINTAINERS
+++ lnx-2630-rc3/MAINTAINERS
@@ -1519,6 +1519,7 @@ L:	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
 S:	Maintained
 F:	include/linux/cgroup*
 F:	kernel/cgroup*
+F:	mm/*cgroup*
 
 CORETEMP HARDWARE MONITORING DRIVER
 P:	Rudolf Marek
