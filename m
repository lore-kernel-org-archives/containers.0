From: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC PATCH 5/5] ima: Add ns_mnt, dev,
	ino fields to IMA audit measurement msgs
Date: Thu, 20 Jul 2017 18:50:33 -0400
Message-ID: <20170720225033.21298-6-mkayaalp__202.693572691892$1500591425$gmane$org@linux.vnet.ibm.com>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170720225033.21298-1-mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Guilherme Magalhaes <guilherme.magalhaes-ZPxbGqLxI0U@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Guilherme Magalhaes <guilherme.magalhaes-ZPxbGqLxI0U@public.gmane.org>

Extending audit measurement record with mount namespace id, file inode,
and device name. These fields uniquely identify a pathname considering
different mount namespaces. The file inode on a given device is unique
and these fields are required to identify a namespace id since this id
can be released and later reused by a different process.

Signed-off-by: Guilherme Magalhaes <guilherme.magalhaes-ZPxbGqLxI0U@public.gmane.org>

Changelog:
* Change the field name from "mnt_ns" to "ns_mnt"

Signed-off-by: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 security/integrity/ima/ima_api.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/security/integrity/ima/ima_api.c b/security/integrity/ima/ima_api.c
index 4a77072..084b126 100644
--- a/security/integrity/ima/ima_api.c
+++ b/security/integrity/ima/ima_api.c
@@ -18,6 +18,7 @@
 #include <linux/fs.h>
 #include <linux/xattr.h>
 #include <linux/evm.h>
+#include <linux/proc_ns.h>
 
 #include "ima.h"
 
@@ -296,6 +297,7 @@ void ima_audit_measurement(struct integrity_iint_cache *iint,
 	char algo_hash[sizeof(hash) + strlen(algo_name) + 2];
 	int i;
 	unsigned long flags = iint_flags(iint, status);
+	struct ns_common *ns;
 
 	if (flags & IMA_AUDITED)
 		return;
@@ -314,6 +316,14 @@ void ima_audit_measurement(struct integrity_iint_cache *iint,
 	audit_log_format(ab, " hash=");
 	snprintf(algo_hash, sizeof(algo_hash), "%s:%s", algo_name, hash);
 	audit_log_untrustedstring(ab, algo_hash);
+	ns = mntns_operations.get(current);
+	if (!IS_ERR_OR_NULL(ns)) {
+		audit_log_format(ab, " ns_mnt=%u", ns->inum);
+		mntns_operations.put(ns);
+	}
+	audit_log_format(ab, " dev=");
+	audit_log_untrustedstring(ab, iint->inode->i_sb->s_id);
+	audit_log_format(ab, " ino=%lu", iint->inode->i_ino);
 
 	audit_log_task_info(ab, current);
 	audit_log_end(ab);
-- 
2.9.4
