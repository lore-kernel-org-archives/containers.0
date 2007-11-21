From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Isolate the UTS namespace's domainname and hostname back
Date: Wed, 21 Nov 2007 14:06:35 +0300
Message-ID: <4744113B.5010309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761294AbXKULHf@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: Cedric Le Goater <clg@fr.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

The commit

commit 7d69a1f4a72b18876c99c697692b78339d491568
Author: Cedric Le Goater <clg@fr.ibm.com>
Date:   Sun Jul 15 23:40:58 2007 -0700

    remove CONFIG_UTS_NS and CONFIG_IPC_NS

accidentally removed the code, that prevented the uts->hostname
and uts->domainname values from being overwritten from another
namespace. In other words, setting hostname/domainname via sysfs 
(echo xxx > /proc/sys/kernel/(host|domain)name) cased the new
value to be set in init UTS namespace only.

Return the isolation back.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/kernel/utsname_sysctl.c b/kernel/utsname_sysctl.c
index c76c064..fe3a56c 100644
--- a/kernel/utsname_sysctl.c
+++ b/kernel/utsname_sysctl.c
@@ -18,6 +18,10 @@
 static void *get_uts(ctl_table *table, int write)
 {
 	char *which = table->data;
+	struct uts_namespace *uts_ns;
+
+	uts_ns = current->nsproxy->uts_ns;
+	which = (which - (char *)&init_uts_ns) + (char *)uts_ns;
 
 	if (!write)
 		down_read(&uts_sem);
