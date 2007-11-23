From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] utsns: Restore proper namespace handling.
Date: Fri, 23 Nov 2007 12:25:29 -0700
Message-ID: <m11wagpxw6.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757721AbXKWT1U@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


When CONFIG_UTS_NS was removed it seems that we also deleted
the code for handling sysctls in the other then the initial
uts namespace.   This patch restores that code.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 kernel/utsname_sysctl.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/utsname_sysctl.c b/kernel/utsname_sysctl.c
index c76c064..71f58c3 100644
--- a/kernel/utsname_sysctl.c
+++ b/kernel/utsname_sysctl.c
@@ -18,6 +18,8 @@
 static void *get_uts(ctl_table *table, int write)
 {
 	char *which = table->data;
+	struct uts_namespace *uts_ns = current->nsproxy->uts_ns;
+	which = (which - (char *)&init_uts_ns) + (char *)uts_ns;
 
 	if (!write)
 		down_read(&uts_sem);
-- 
1.5.3.rc6.17.g1911
