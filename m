From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH -mm] cgroup: fix boot option parsing
Date: Mon, 17 Mar 2008 17:24:57 +0900
Message-ID: <47DE2AD9.503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754772AbYCQIZu@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

When boot with 'cgroup_disable=cpuacct', it turns out subsystem
'cpu' is disabled.

When Balbir posted the patch to add cgroup boot option support,
Paul M noticed this problem, but the patch was accepted without
fixing it.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cgroup.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e8e8ec4..54c28ea 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3062,25 +3062,22 @@ static void cgroup_release_agent(struct work_struct *work)
 static int __init cgroup_disable(char *str)
 {
 	int i;
+	char *token;
+
+	while ((token = strsep(&str, ",")) != NULL) {
+		if (!*token)
+			continue;
 
-	while (*str) {
 		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
 
-			if (!strncmp(str, ss->name, strlen(ss->name))) {
+			if (!strcmp(token, ss->name)) {
 				ss->disabled = 1;
 				printk(KERN_INFO "Disabling %s control group"
 					" subsystem\n", ss->name);
 				break;
 			}
 		}
-		/*
-		 * Find the next option if any
-		 */
-		while (*str && (*str != ','))
-			str++;
-		if (*str == ',')
-			str++;
 	}
 	return 1;
 }
-- 
1.5.4.rc3
