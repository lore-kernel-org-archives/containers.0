From: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC PATCH 3/5] ima: mamespace audit status flags
Date: Thu, 20 Jul 2017 18:50:31 -0400
Message-ID: <20170720225033.21298-4-mkayaalp__2579.06228439442$1500591361$gmane$org@linux.vnet.ibm.com>
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
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

The iint cache stores whether the file is measured, appraised, audited
etc. This patch moves the IMA_AUDITED flag into the per-namespace
ns_status, enabling IMA audit mechanism to audit the same file each time
it is accessed in a new namespace.

The ns_status is not looked up if the CONFIG_IMA_NS is disabled or if
none of the IMA_NS_STATUS_ACTIONS (currently only IMA_AUDIT) are enabled.

Read and write operations on the iint flags is replaced with function
calls. For reading, iint_flags() returns the bitwise AND of iint->flags
and ns_status->flags. The ns_status flags are masked with
IMA_NS_STATUS_FLAGS (currently only IMA_AUDITED). Similarly
set_iint_flags() only writes the masked portion to the ns_status flags,
while the iint flags is set as before. The ns_status parameter added to
ima_audit_measurement() is used with the above functions to query and
set the ns_status flags.

Signed-off-by: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 init/Kconfig                      |  4 +++-
 security/integrity/ima/ima.h      | 24 +++++++++++++++++++++++-
 security/integrity/ima/ima_api.c  |  8 +++++---
 security/integrity/ima/ima_main.c | 15 ++++++++++++---
 security/integrity/ima/ima_ns.c   | 21 +++++++++++++++++++++
 5 files changed, 64 insertions(+), 8 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 339f84d..6bfc579 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1294,7 +1294,9 @@ config IMA_NS
 	help
 	  Allow the creation of IMA namespaces for each mount namespace.
 	  Namespaced IMA data enables having IMA features work separately
-	  for each mount namespace.
+	  for each mount namespace. Currently, only the audit status flags
+	  are stored in the namespace, which allows the same file to be
+	  audited each time it is accessed in a new namespace.
 
 endif # NAMESPACES
 
diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
index 5ab769a..78921b7 100644
--- a/security/integrity/ima/ima.h
+++ b/security/integrity/ima/ima.h
@@ -210,7 +210,8 @@ void ima_store_measurement(struct integrity_iint_cache *iint, struct file *file,
 			   struct evm_ima_xattr_data *xattr_value,
 			   int xattr_len, int pcr);
 void ima_audit_measurement(struct integrity_iint_cache *iint,
-			   const unsigned char *filename);
+			   const unsigned char *filename,
+			   struct ns_status *status);
 int ima_alloc_init_template(struct ima_event_data *event_data,
 			    struct ima_template_entry **entry);
 int ima_store_template(struct ima_template_entry *entry, int violation,
@@ -299,10 +300,17 @@ static inline int ima_read_xattr(struct dentry *dentry,
 
 #endif /* CONFIG_IMA_APPRAISE */
 
+#define IMA_NS_STATUS_ACTIONS   IMA_AUDIT
+#define IMA_NS_STATUS_FLAGS     IMA_AUDITED
+
 #ifdef CONFIG_IMA_NS
 int ima_ns_init(void);
 struct ns_status *ima_get_ns_status(struct ima_namespace *ns,
 				    struct inode *inode);
+unsigned long iint_flags(struct integrity_iint_cache *iint,
+			 struct ns_status *status);
+unsigned long set_iint_flags(struct integrity_iint_cache *iint,
+			     struct ns_status *status, unsigned long flags);
 #else
 static inline int ima_ns_init(void)
 {
@@ -314,6 +322,20 @@ static inline struct ns_status *ima_get_ns_status(struct ima_namespace *ns,
 {
 	return NULL;
 }
+
+static inline unsigned long iint_flags(struct integrity_iint_cache *iint,
+				       struct ns_status *status)
+{
+	return iint->flags;
+}
+
+static inline unsigned long set_iint_flags(struct integrity_iint_cache *iint,
+					   struct ns_status *status,
+					   unsigned long flags)
+{
+	iint->flags = flags;
+	return flags;
+}
 #endif /* CONFIG_IMA_NS */
 
 /* LSM based policy rules require audit */
diff --git a/security/integrity/ima/ima_api.c b/security/integrity/ima/ima_api.c
index c2edba8..4a77072 100644
--- a/security/integrity/ima/ima_api.c
+++ b/security/integrity/ima/ima_api.c
@@ -287,15 +287,17 @@ void ima_store_measurement(struct integrity_iint_cache *iint,
 }
 
 void ima_audit_measurement(struct integrity_iint_cache *iint,
-			   const unsigned char *filename)
+			   const unsigned char *filename,
+			   struct ns_status *status)
 {
 	struct audit_buffer *ab;
 	char hash[(iint->ima_hash->length * 2) + 1];
 	const char *algo_name = hash_algo_name[iint->ima_hash->algo];
 	char algo_hash[sizeof(hash) + strlen(algo_name) + 2];
 	int i;
+	unsigned long flags = iint_flags(iint, status);
 
-	if (iint->flags & IMA_AUDITED)
+	if (flags & IMA_AUDITED)
 		return;
 
 	for (i = 0; i < iint->ima_hash->length; i++)
@@ -316,7 +318,7 @@ void ima_audit_measurement(struct integrity_iint_cache *iint,
 	audit_log_task_info(ab, current);
 	audit_log_end(ab);
 
-	iint->flags |= IMA_AUDITED;
+	set_iint_flags(iint, status, flags | IMA_AUDITED);
 }
 
 /*
diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima/ima_main.c
index 2aebb79..fb002f2 100644
--- a/security/integrity/ima/ima_main.c
+++ b/security/integrity/ima/ima_main.c
@@ -160,6 +160,7 @@ static int process_measurement(struct file *file, char *buf, loff_t size,
 {
 	struct inode *inode = file_inode(file);
 	struct integrity_iint_cache *iint = NULL;
+	struct ns_status *status = NULL;
 	struct ima_template_desc *template_desc;
 	char *pathbuf = NULL;
 	char filename[NAME_MAX];
@@ -170,6 +171,7 @@ static int process_measurement(struct file *file, char *buf, loff_t size,
 	int xattr_len = 0;
 	bool violation_check;
 	enum hash_algo hash_algo;
+	unsigned long flags;
 
 	if (!ima_policy_flag || !S_ISREG(inode->i_mode))
 		return 0;
@@ -196,6 +198,12 @@ static int process_measurement(struct file *file, char *buf, loff_t size,
 		iint = integrity_inode_get(inode);
 		if (!iint)
 			goto out;
+
+		if (action & IMA_NS_STATUS_ACTIONS) {
+			status = ima_get_ns_status(get_current_ns(), inode);
+			if (IS_ERR(status))
+				goto out;
+		}
 	}
 
 	if (violation_check) {
@@ -211,9 +219,10 @@ static int process_measurement(struct file *file, char *buf, loff_t size,
 	 * (IMA_MEASURE, IMA_MEASURED, IMA_XXXX_APPRAISE, IMA_XXXX_APPRAISED,
 	 *  IMA_AUDIT, IMA_AUDITED)
 	 */
-	iint->flags |= action;
+	flags = iint_flags(iint, status);
+	flags = set_iint_flags(iint, status, flags | action);
 	action &= IMA_DO_MASK;
-	action &= ~((iint->flags & (IMA_DONE_MASK ^ IMA_MEASURED)) >> 1);
+	action &= ~((flags & (IMA_DONE_MASK ^ IMA_MEASURED)) >> 1);
 
 	/* If target pcr is already measured, unset IMA_MEASURE action */
 	if ((action & IMA_MEASURE) && (iint->measured_pcrs & (0x1 << pcr)))
@@ -251,7 +260,7 @@ static int process_measurement(struct file *file, char *buf, loff_t size,
 		rc = ima_appraise_measurement(func, iint, file, pathname,
 					      xattr_value, xattr_len, opened);
 	if (action & IMA_AUDIT)
-		ima_audit_measurement(iint, pathname);
+		ima_audit_measurement(iint, pathname, status);
 
 out_digsig:
 	if ((mask & MAY_WRITE) && (iint->flags & IMA_DIGSIG) &&
diff --git a/security/integrity/ima/ima_ns.c b/security/integrity/ima/ima_ns.c
index 5ec5a4b..562a0812 100644
--- a/security/integrity/ima/ima_ns.c
+++ b/security/integrity/ima/ima_ns.c
@@ -301,3 +301,24 @@ struct ns_status *ima_get_ns_status(struct ima_namespace *ns,
 
 	return status;
 }
+
+#define IMA_NS_STATUS_ACTIONS	IMA_AUDIT
+#define IMA_NS_STATUS_FLAGS	IMA_AUDITED
+
+unsigned long iint_flags(struct integrity_iint_cache *iint,
+			 struct ns_status *status)
+{
+	if (!status)
+		return iint->flags;
+
+	return iint->flags & (status->flags & IMA_NS_STATUS_FLAGS);
+}
+
+unsigned long set_iint_flags(struct integrity_iint_cache *iint,
+			     struct ns_status *status, unsigned long flags)
+{
+	iint->flags = flags;
+	if (status)
+		status->flags = flags & IMA_NS_STATUS_FLAGS;
+	return flags;
+}
-- 
2.9.4
