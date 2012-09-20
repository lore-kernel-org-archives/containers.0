From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 10/27] audit: Add typespecific uid and gid comparators
Date: Wed, 19 Sep 2012 18:52:12 -0700
Message-ID: <1348105949-25454-10-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

The audit filter code guarantees that uid are always compared with
uids and gids are always compared with gids, as the comparason
operations are type specific.  Take advantage of this proper to define
audit_uid_comparator and audit_gid_comparator which use the type safe
comparasons from uidgid.h.

Build on audit_uid_comparator and audit_gid_comparator and replace
audit_compare_id with audit_compare_uid and audit_compare_gid.  This
is one of those odd cases where being type safe and duplicating code
leads to simpler shorter and more concise code.

Don't allow bitmask operations in uid and gid comparisons in
audit_data_to_entry.  Bitmask operations are already denined in
audit_rule_to_entry.

Convert constants in audit_rule_to_entry and audit_data_to_entry into
kuids and kgids when appropriate.

Convert the uid and gid field in struct audit_names to be of type
kuid_t and kgid_t respectively, so that the new uid and gid comparators
can be applied in a type safe manner.

Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/audit.h |    2 +
 kernel/audit.h        |    2 +
 kernel/auditfilter.c  |  119 +++++++++++++++++++++++++++++++++++---
 kernel/auditsc.c      |  150 +++++++++++++++++++++++--------------------------
 4 files changed, 184 insertions(+), 89 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index b9c5b22..ca019bb 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -442,6 +442,8 @@ struct audit_krule {
 struct audit_field {
 	u32				type;
 	u32				val;
+	kuid_t				uid;
+	kgid_t				gid;
 	u32				op;
 	char				*lsm_str;
 	void				*lsm_rule;
diff --git a/kernel/audit.h b/kernel/audit.h
index 8167668..4b428bb 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -76,6 +76,8 @@ static inline int audit_hash_ino(u32 ino)
 
 extern int audit_match_class(int class, unsigned syscall);
 extern int audit_comparator(const u32 left, const u32 op, const u32 right);
+extern int audit_uid_comparator(kuid_t left, u32 op, kuid_t right);
+extern int audit_gid_comparator(kgid_t left, u32 op, kgid_t right);
 extern int audit_compare_dname_path(const char *dname, const char *path,
 				    int *dirlen);
 extern struct sk_buff *	    audit_make_reply(int pid, int seq, int type,
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index e242dd9..b30320c 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -342,6 +342,8 @@ static struct audit_entry *audit_rule_to_entry(struct audit_rule *rule)
 
 		f->type = rule->fields[i] & ~(AUDIT_NEGATE|AUDIT_OPERATORS);
 		f->val = rule->values[i];
+		f->uid = INVALID_UID;
+		f->gid = INVALID_GID;
 
 		err = -EINVAL;
 		if (f->op == Audit_bad)
@@ -350,16 +352,32 @@ static struct audit_entry *audit_rule_to_entry(struct audit_rule *rule)
 		switch(f->type) {
 		default:
 			goto exit_free;
-		case AUDIT_PID:
 		case AUDIT_UID:
 		case AUDIT_EUID:
 		case AUDIT_SUID:
 		case AUDIT_FSUID:
+		case AUDIT_LOGINUID:
+			/* bit ops not implemented for uid comparisons */
+			if (f->op == Audit_bitmask || f->op == Audit_bittest)
+				goto exit_free;
+
+			f->uid = make_kuid(current_user_ns(), f->val);
+			if (!uid_valid(f->uid))
+				goto exit_free;
+			break;
 		case AUDIT_GID:
 		case AUDIT_EGID:
 		case AUDIT_SGID:
 		case AUDIT_FSGID:
-		case AUDIT_LOGINUID:
+			/* bit ops not implemented for gid comparisons */
+			if (f->op == Audit_bitmask || f->op == Audit_bittest)
+				goto exit_free;
+
+			f->gid = make_kgid(current_user_ns(), f->val);
+			if (!gid_valid(f->gid))
+				goto exit_free;
+			break;
+		case AUDIT_PID:
 		case AUDIT_PERS:
 		case AUDIT_MSGTYPE:
 		case AUDIT_PPID:
@@ -437,19 +455,39 @@ static struct audit_entry *audit_data_to_entry(struct audit_rule_data *data,
 
 		f->type = data->fields[i];
 		f->val = data->values[i];
+		f->uid = INVALID_UID;
+		f->gid = INVALID_GID;
 		f->lsm_str = NULL;
 		f->lsm_rule = NULL;
 		switch(f->type) {
-		case AUDIT_PID:
 		case AUDIT_UID:
 		case AUDIT_EUID:
 		case AUDIT_SUID:
 		case AUDIT_FSUID:
+		case AUDIT_LOGINUID:
+		case AUDIT_OBJ_UID:
+			/* bit ops not implemented for uid comparisons */
+			if (f->op == Audit_bitmask || f->op == Audit_bittest)
+				goto exit_free;
+
+			f->uid = make_kuid(current_user_ns(), f->val);
+			if (!uid_valid(f->uid))
+				goto exit_free;
+			break;
 		case AUDIT_GID:
 		case AUDIT_EGID:
 		case AUDIT_SGID:
 		case AUDIT_FSGID:
-		case AUDIT_LOGINUID:
+		case AUDIT_OBJ_GID:
+			/* bit ops not implemented for gid comparisons */
+			if (f->op == Audit_bitmask || f->op == Audit_bittest)
+				goto exit_free;
+
+			f->gid = make_kgid(current_user_ns(), f->val);
+			if (!gid_valid(f->gid))
+				goto exit_free;
+			break;
+		case AUDIT_PID:
 		case AUDIT_PERS:
 		case AUDIT_MSGTYPE:
 		case AUDIT_PPID:
@@ -461,8 +499,6 @@ static struct audit_entry *audit_data_to_entry(struct audit_rule_data *data,
 		case AUDIT_ARG1:
 		case AUDIT_ARG2:
 		case AUDIT_ARG3:
-		case AUDIT_OBJ_UID:
-		case AUDIT_OBJ_GID:
 			break;
 		case AUDIT_ARCH:
 			entry->rule.arch_f = f;
@@ -707,6 +743,23 @@ static int audit_compare_rule(struct audit_krule *a, struct audit_krule *b)
 			if (strcmp(a->filterkey, b->filterkey))
 				return 1;
 			break;
+		case AUDIT_UID:
+		case AUDIT_EUID:
+		case AUDIT_SUID:
+		case AUDIT_FSUID:
+		case AUDIT_LOGINUID:
+		case AUDIT_OBJ_UID:
+			if (!uid_eq(a->fields[i].uid, b->fields[i].uid))
+				return 1;
+			break;
+		case AUDIT_GID:
+		case AUDIT_EGID:
+		case AUDIT_SGID:
+		case AUDIT_FSGID:
+		case AUDIT_OBJ_GID:
+			if (!gid_eq(a->fields[i].gid, b->fields[i].gid))
+				return 1;
+			break;
 		default:
 			if (a->fields[i].val != b->fields[i].val)
 				return 1;
@@ -1198,6 +1251,52 @@ int audit_comparator(u32 left, u32 op, u32 right)
 	}
 }
 
+int audit_uid_comparator(kuid_t left, u32 op, kuid_t right)
+{
+	switch (op) {
+	case Audit_equal:
+		return uid_eq(left, right);
+	case Audit_not_equal:
+		return !uid_eq(left, right);
+	case Audit_lt:
+		return uid_lt(left, right);
+	case Audit_le:
+		return uid_lte(left, right);
+	case Audit_gt:
+		return uid_gt(left, right);
+	case Audit_ge:
+		return uid_gte(left, right);
+	case Audit_bitmask:
+	case Audit_bittest:
+	default:
+		BUG();
+		return 0;
+	}
+}
+
+int audit_gid_comparator(kgid_t left, u32 op, kgid_t right)
+{
+	switch (op) {
+	case Audit_equal:
+		return gid_eq(left, right);
+	case Audit_not_equal:
+		return !gid_eq(left, right);
+	case Audit_lt:
+		return gid_lt(left, right);
+	case Audit_le:
+		return gid_lte(left, right);
+	case Audit_gt:
+		return gid_gt(left, right);
+	case Audit_ge:
+		return gid_gte(left, right);
+	case Audit_bitmask:
+	case Audit_bittest:
+	default:
+		BUG();
+		return 0;
+	}
+}
+
 /* Compare given dentry name with last component in given path,
  * return of 0 indicates a match. */
 int audit_compare_dname_path(const char *dname, const char *path,
@@ -1251,14 +1350,14 @@ static int audit_filter_user_rules(struct audit_krule *rule,
 			result = audit_comparator(task_pid_vnr(current), f->op, f->val);
 			break;
 		case AUDIT_UID:
-			result = audit_comparator(current_uid(), f->op, f->val);
+			result = audit_uid_comparator(current_uid(), f->op, f->uid);
 			break;
 		case AUDIT_GID:
-			result = audit_comparator(current_gid(), f->op, f->val);
+			result = audit_gid_comparator(current_gid(), f->op, f->gid);
 			break;
 		case AUDIT_LOGINUID:
-			result = audit_comparator(audit_get_loginuid(current),
-						  f->op, f->val);
+			result = audit_uid_comparator(audit_get_loginuid(current),
+						  f->op, f->uid);
 			break;
 		case AUDIT_SUBJ_USER:
 		case AUDIT_SUBJ_ROLE:
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 4b96415..0b5b8a2 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -113,8 +113,8 @@ struct audit_names {
 	unsigned long	ino;
 	dev_t		dev;
 	umode_t		mode;
-	uid_t		uid;
-	gid_t		gid;
+	kuid_t		uid;
+	kgid_t		gid;
 	dev_t		rdev;
 	u32		osid;
 	struct audit_cap_data fcap;
@@ -464,37 +464,47 @@ static int match_tree_refs(struct audit_context *ctx, struct audit_tree *tree)
 	return 0;
 }
 
-static int audit_compare_id(uid_t uid1,
-			    struct audit_names *name,
-			    unsigned long name_offset,
-			    struct audit_field *f,
-			    struct audit_context *ctx)
+static int audit_compare_uid(kuid_t uid,
+			     struct audit_names *name,
+			     struct audit_field *f,
+			     struct audit_context *ctx)
 {
 	struct audit_names *n;
-	unsigned long addr;
-	uid_t uid2;
 	int rc;
-
-	BUILD_BUG_ON(sizeof(uid_t) != sizeof(gid_t));
-
+ 
 	if (name) {
-		addr = (unsigned long)name;
-		addr += name_offset;
-
-		uid2 = *(uid_t *)addr;
-		rc = audit_comparator(uid1, f->op, uid2);
+		rc = audit_uid_comparator(uid, f->op, name->uid);
 		if (rc)
 			return rc;
 	}
-
+ 
 	if (ctx) {
 		list_for_each_entry(n, &ctx->names_list, list) {
-			addr = (unsigned long)n;
-			addr += name_offset;
-
-			uid2 = *(uid_t *)addr;
+			rc = audit_uid_comparator(uid, f->op, n->uid);
+			if (rc)
+				return rc;
+		}
+	}
+	return 0;
+}
 
-			rc = audit_comparator(uid1, f->op, uid2);
+static int audit_compare_gid(kgid_t gid,
+			     struct audit_names *name,
+			     struct audit_field *f,
+			     struct audit_context *ctx)
+{
+	struct audit_names *n;
+	int rc;
+ 
+	if (name) {
+		rc = audit_gid_comparator(gid, f->op, name->gid);
+		if (rc)
+			return rc;
+	}
+ 
+	if (ctx) {
+		list_for_each_entry(n, &ctx->names_list, list) {
+			rc = audit_gid_comparator(gid, f->op, n->gid);
 			if (rc)
 				return rc;
 		}
@@ -511,80 +521,62 @@ static int audit_field_compare(struct task_struct *tsk,
 	switch (f->val) {
 	/* process to file object comparisons */
 	case AUDIT_COMPARE_UID_TO_OBJ_UID:
-		return audit_compare_id(cred->uid,
-					name, offsetof(struct audit_names, uid),
-					f, ctx);
+		return audit_compare_uid(cred->uid, name, f, ctx);
 	case AUDIT_COMPARE_GID_TO_OBJ_GID:
-		return audit_compare_id(cred->gid,
-					name, offsetof(struct audit_names, gid),
-					f, ctx);
+		return audit_compare_gid(cred->gid, name, f, ctx);
 	case AUDIT_COMPARE_EUID_TO_OBJ_UID:
-		return audit_compare_id(cred->euid,
-					name, offsetof(struct audit_names, uid),
-					f, ctx);
+		return audit_compare_uid(cred->euid, name, f, ctx);
 	case AUDIT_COMPARE_EGID_TO_OBJ_GID:
-		return audit_compare_id(cred->egid,
-					name, offsetof(struct audit_names, gid),
-					f, ctx);
+		return audit_compare_gid(cred->egid, name, f, ctx);
 	case AUDIT_COMPARE_AUID_TO_OBJ_UID:
-		return audit_compare_id(tsk->loginuid,
-					name, offsetof(struct audit_names, uid),
-					f, ctx);
+		return audit_compare_uid(tsk->loginuid, name, f, ctx);
 	case AUDIT_COMPARE_SUID_TO_OBJ_UID:
-		return audit_compare_id(cred->suid,
-					name, offsetof(struct audit_names, uid),
-					f, ctx);
+		return audit_compare_uid(cred->suid, name, f, ctx);
 	case AUDIT_COMPARE_SGID_TO_OBJ_GID:
-		return audit_compare_id(cred->sgid,
-					name, offsetof(struct audit_names, gid),
-					f, ctx);
+		return audit_compare_gid(cred->sgid, name, f, ctx);
 	case AUDIT_COMPARE_FSUID_TO_OBJ_UID:
-		return audit_compare_id(cred->fsuid,
-					name, offsetof(struct audit_names, uid),
-					f, ctx);
+		return audit_compare_uid(cred->fsuid, name, f, ctx);
 	case AUDIT_COMPARE_FSGID_TO_OBJ_GID:
-		return audit_compare_id(cred->fsgid,
-					name, offsetof(struct audit_names, gid),
-					f, ctx);
+		return audit_compare_gid(cred->fsgid, name, f, ctx);
 	/* uid comparisons */
 	case AUDIT_COMPARE_UID_TO_AUID:
-		return audit_comparator(cred->uid, f->op, tsk->loginuid);
+		return audit_uid_comparator(cred->uid, f->op, tsk->loginuid);
 	case AUDIT_COMPARE_UID_TO_EUID:
-		return audit_comparator(cred->uid, f->op, cred->euid);
+		return audit_uid_comparator(cred->uid, f->op, cred->euid);
 	case AUDIT_COMPARE_UID_TO_SUID:
-		return audit_comparator(cred->uid, f->op, cred->suid);
+		return audit_uid_comparator(cred->uid, f->op, cred->suid);
 	case AUDIT_COMPARE_UID_TO_FSUID:
-		return audit_comparator(cred->uid, f->op, cred->fsuid);
+		return audit_uid_comparator(cred->uid, f->op, cred->fsuid);
 	/* auid comparisons */
 	case AUDIT_COMPARE_AUID_TO_EUID:
-		return audit_comparator(tsk->loginuid, f->op, cred->euid);
+		return audit_uid_comparator(tsk->loginuid, f->op, cred->euid);
 	case AUDIT_COMPARE_AUID_TO_SUID:
-		return audit_comparator(tsk->loginuid, f->op, cred->suid);
+		return audit_uid_comparator(tsk->loginuid, f->op, cred->suid);
 	case AUDIT_COMPARE_AUID_TO_FSUID:
-		return audit_comparator(tsk->loginuid, f->op, cred->fsuid);
+		return audit_uid_comparator(tsk->loginuid, f->op, cred->fsuid);
 	/* euid comparisons */
 	case AUDIT_COMPARE_EUID_TO_SUID:
-		return audit_comparator(cred->euid, f->op, cred->suid);
+		return audit_uid_comparator(cred->euid, f->op, cred->suid);
 	case AUDIT_COMPARE_EUID_TO_FSUID:
-		return audit_comparator(cred->euid, f->op, cred->fsuid);
+		return audit_uid_comparator(cred->euid, f->op, cred->fsuid);
 	/* suid comparisons */
 	case AUDIT_COMPARE_SUID_TO_FSUID:
-		return audit_comparator(cred->suid, f->op, cred->fsuid);
+		return audit_uid_comparator(cred->suid, f->op, cred->fsuid);
 	/* gid comparisons */
 	case AUDIT_COMPARE_GID_TO_EGID:
-		return audit_comparator(cred->gid, f->op, cred->egid);
+		return audit_gid_comparator(cred->gid, f->op, cred->egid);
 	case AUDIT_COMPARE_GID_TO_SGID:
-		return audit_comparator(cred->gid, f->op, cred->sgid);
+		return audit_gid_comparator(cred->gid, f->op, cred->sgid);
 	case AUDIT_COMPARE_GID_TO_FSGID:
-		return audit_comparator(cred->gid, f->op, cred->fsgid);
+		return audit_gid_comparator(cred->gid, f->op, cred->fsgid);
 	/* egid comparisons */
 	case AUDIT_COMPARE_EGID_TO_SGID:
-		return audit_comparator(cred->egid, f->op, cred->sgid);
+		return audit_gid_comparator(cred->egid, f->op, cred->sgid);
 	case AUDIT_COMPARE_EGID_TO_FSGID:
-		return audit_comparator(cred->egid, f->op, cred->fsgid);
+		return audit_gid_comparator(cred->egid, f->op, cred->fsgid);
 	/* sgid comparison */
 	case AUDIT_COMPARE_SGID_TO_FSGID:
-		return audit_comparator(cred->sgid, f->op, cred->fsgid);
+		return audit_gid_comparator(cred->sgid, f->op, cred->fsgid);
 	default:
 		WARN(1, "Missing AUDIT_COMPARE define.  Report as a bug\n");
 		return 0;
@@ -630,28 +622,28 @@ static int audit_filter_rules(struct task_struct *tsk,
 			}
 			break;
 		case AUDIT_UID:
-			result = audit_comparator(cred->uid, f->op, f->val);
+			result = audit_uid_comparator(cred->uid, f->op, f->uid);
 			break;
 		case AUDIT_EUID:
-			result = audit_comparator(cred->euid, f->op, f->val);
+			result = audit_uid_comparator(cred->euid, f->op, f->uid);
 			break;
 		case AUDIT_SUID:
-			result = audit_comparator(cred->suid, f->op, f->val);
+			result = audit_uid_comparator(cred->suid, f->op, f->uid);
 			break;
 		case AUDIT_FSUID:
-			result = audit_comparator(cred->fsuid, f->op, f->val);
+			result = audit_uid_comparator(cred->fsuid, f->op, f->uid);
 			break;
 		case AUDIT_GID:
-			result = audit_comparator(cred->gid, f->op, f->val);
+			result = audit_gid_comparator(cred->gid, f->op, f->gid);
 			break;
 		case AUDIT_EGID:
-			result = audit_comparator(cred->egid, f->op, f->val);
+			result = audit_gid_comparator(cred->egid, f->op, f->gid);
 			break;
 		case AUDIT_SGID:
-			result = audit_comparator(cred->sgid, f->op, f->val);
+			result = audit_gid_comparator(cred->sgid, f->op, f->gid);
 			break;
 		case AUDIT_FSGID:
-			result = audit_comparator(cred->fsgid, f->op, f->val);
+			result = audit_gid_comparator(cred->fsgid, f->op, f->gid);
 			break;
 		case AUDIT_PERS:
 			result = audit_comparator(tsk->personality, f->op, f->val);
@@ -717,10 +709,10 @@ static int audit_filter_rules(struct task_struct *tsk,
 			break;
 		case AUDIT_OBJ_UID:
 			if (name) {
-				result = audit_comparator(name->uid, f->op, f->val);
+				result = audit_uid_comparator(name->uid, f->op, f->uid);
 			} else if (ctx) {
 				list_for_each_entry(n, &ctx->names_list, list) {
-					if (audit_comparator(n->uid, f->op, f->val)) {
+					if (audit_uid_comparator(n->uid, f->op, f->uid)) {
 						++result;
 						break;
 					}
@@ -729,10 +721,10 @@ static int audit_filter_rules(struct task_struct *tsk,
 			break;
 		case AUDIT_OBJ_GID:
 			if (name) {
-				result = audit_comparator(name->gid, f->op, f->val);
+				result = audit_gid_comparator(name->gid, f->op, f->gid);
 			} else if (ctx) {
 				list_for_each_entry(n, &ctx->names_list, list) {
-					if (audit_comparator(n->gid, f->op, f->val)) {
+					if (audit_gid_comparator(n->gid, f->op, f->gid)) {
 						++result;
 						break;
 					}
@@ -750,7 +742,7 @@ static int audit_filter_rules(struct task_struct *tsk,
 		case AUDIT_LOGINUID:
 			result = 0;
 			if (ctx)
-				result = audit_comparator(tsk->loginuid, f->op, f->val);
+				result = audit_uid_comparator(tsk->loginuid, f->op, f->uid);
 			break;
 		case AUDIT_SUBJ_USER:
 		case AUDIT_SUBJ_ROLE:
-- 
1.7.5.4
