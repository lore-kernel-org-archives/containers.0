From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC PATCH v4 4/5] ima: extend IMA audit policy rules with attribute
	to audit namespaces
Date: Fri, 11 May 2018 10:42:29 -0400
Message-ID: <20180511144230.75384-5-stefanb__6175.3619499088$1526049725$gmane$org@linux.vnet.ibm.com>
References: <20180511144230.75384-1-stefanb@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180511144230.75384-1-stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Introduce a policy rule attribute called 'ns' that indicates that a rule
is supposed to apply to child namespaces of an IMA namespace. We support
this 'ns' attribute only for IMA-audit for now. IMA-measurement will get
support for this in a future version.

If 'uid=...' appears in a policy rule that has the 'ns' attribute, the uid
in that rule is relative to the current user namespace. If it is missing,
then the uid is relative to the user namespace that owns the IMA namespace
the policy is in. So we have to now map the uid's and do that with the
appropriate user namespace depending on the availability of the 'ns'
attribute. After that we can use the mapped uid for uid comparisons.

Signed-off-by: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 security/integrity/ima/ima.h          |  5 ++-
 security/integrity/ima/ima_api.c      |  6 ++-
 security/integrity/ima/ima_appraise.c |  2 +-
 security/integrity/ima/ima_main.c     |  3 +-
 security/integrity/ima/ima_policy.c   | 75 +++++++++++++++++++++++++++++++++--
 5 files changed, 81 insertions(+), 10 deletions(-)

diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
index 0a644922c6e7..a23f4b0b21f4 100644
--- a/security/integrity/ima/ima.h
+++ b/security/integrity/ima/ima.h
@@ -201,7 +201,8 @@ enum ima_hooks {
 
 /* LIM API function definitions */
 int ima_get_action(struct inode *inode, int mask,
-		   enum ima_hooks func, int *pcr);
+		   enum ima_hooks func, int *pcr,
+		   struct ima_namespace *ns);
 int ima_must_measure(struct inode *inode, int mask, enum ima_hooks func);
 int ima_collect_measurement(struct integrity_iint_cache *iint,
 			    struct file *file, void *buf, loff_t size,
@@ -222,7 +223,7 @@ const char *ima_d_path(const struct path *path, char **pathbuf, char *filename);
 
 /* IMA policy related functions */
 int ima_match_policy(struct inode *inode, enum ima_hooks func, int mask,
-		     int flags, int *pcr);
+		     int flags, int *pcr, struct ima_namespace *ns);
 void ima_init_policy(void);
 void ima_update_policy(void);
 void ima_update_policy_flag(void);
diff --git a/security/integrity/ima/ima_api.c b/security/integrity/ima/ima_api.c
index 08fe405338e1..85ca995b9bb7 100644
--- a/security/integrity/ima/ima_api.c
+++ b/security/integrity/ima/ima_api.c
@@ -162,6 +162,7 @@ void ima_add_violation(struct file *file, const unsigned char *filename,
  *        MAY_APPEND)
  * @func: caller identifier
  * @pcr: pointer filled in if matched measure policy sets pcr=
+ * @ns: the IMA namespace we are currently in
  *
  * The policy is defined in terms of keypairs:
  *		subj=, obj=, type=, func=, mask=, fsmagic=
@@ -173,13 +174,14 @@ void ima_add_violation(struct file *file, const unsigned char *filename,
  * Returns IMA_MEASURE, IMA_APPRAISE mask.
  *
  */
-int ima_get_action(struct inode *inode, int mask, enum ima_hooks func, int *pcr)
+int ima_get_action(struct inode *inode, int mask, enum ima_hooks func, int *pcr,
+		   struct ima_namespace *ns)
 {
 	int flags = IMA_MEASURE | IMA_AUDIT | IMA_APPRAISE | IMA_HASH;
 
 	flags &= ima_policy_flag;
 
-	return ima_match_policy(inode, func, mask, flags, pcr);
+	return ima_match_policy(inode, func, mask, flags, pcr, ns);
 }
 
 /*
diff --git a/security/integrity/ima/ima_appraise.c b/security/integrity/ima/ima_appraise.c
index f2803a40ff82..4d744a6aaaf1 100644
--- a/security/integrity/ima/ima_appraise.c
+++ b/security/integrity/ima/ima_appraise.c
@@ -54,7 +54,7 @@ int ima_must_appraise(struct inode *inode, int mask, enum ima_hooks func)
 		return 0;
 
 	return ima_match_policy(inode, func, mask, IMA_APPRAISE | IMA_HASH,
-				NULL);
+				NULL, get_current_ns());
 }
 
 static int ima_fix_xattr(struct dentry *dentry,
diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima/ima_main.c
index 2cfb0c714967..ad9acac98526 100644
--- a/security/integrity/ima/ima_main.c
+++ b/security/integrity/ima/ima_main.c
@@ -190,7 +190,8 @@ static int process_measurement(struct file *file, char *buf, loff_t size,
 	 * bitmask based on the appraise/audit/measurement policy.
 	 * Included is the appraise submask.
 	 */
-	action = ima_get_action(inode, mask, func, &pcr);
+	action = ima_get_action(inode, mask, func, &pcr, get_current_ns());
+
 	violation_check = ((func == FILE_CHECK || func == MMAP_CHECK) &&
 			   (ima_policy_flag & IMA_MEASURE));
 	if (!action && !violation_check)
diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/ima_policy.c
index 3a1412db02a3..768941a8e90c 100644
--- a/security/integrity/ima/ima_policy.c
+++ b/security/integrity/ima/ima_policy.c
@@ -33,6 +33,7 @@
 #define IMA_INMASK	0x0040
 #define IMA_EUID	0x0080
 #define IMA_PCR		0x0100
+#define IMA_NS		0x0200  /* rule applies only to child namespaces */
 
 #define UNKNOWN		0
 #define MEASURE		0x0001	/* same as IMA_MEASURE */
@@ -239,6 +240,48 @@ static void ima_lsm_update_rules(void)
 	}
 }
 
+static bool ima_uid_op(const struct cred *cred, struct ima_rule_entry *rule)
+{
+	kuid_t right;
+	struct user_namespace *user_ns;
+
+	/*
+	 * The 'ns' attribute makes the uid in the rule relative to the
+	 * current user namespace. So '... ns uid=123' applies to uid=123
+	 * in the current user namespace.
+	 * Without an 'ns' attribute 'uid=123' refers to the
+	 * uid = 123 of the user namespace where the policy resides in.
+	 * (currently init_ima_ns.user_ns == &init_user_ns)
+	 */
+	if (rule->flags & IMA_NS)
+		user_ns = current_user_ns();
+	else
+		user_ns = init_ima_ns.user_ns;
+
+	right = make_kuid(user_ns, __kuid_val(rule->uid));
+	if (!uid_valid(right))
+		return false;
+
+	return rule->uid_op(cred->uid, right);
+}
+
+static bool ima_fowner_op(kuid_t left, struct ima_rule_entry *rule)
+{
+	kuid_t right;
+	struct user_namespace *user_ns;
+
+	if (rule->flags & IMA_NS)
+		user_ns = current_user_ns();
+	else
+		user_ns = init_ima_ns.user_ns;
+
+	right = make_kuid(user_ns, __kuid_val(rule->uid));
+	if (!uid_valid(right))
+		return false;
+
+	return rule->fowner_op(left, right);
+}
+
 /**
  * ima_match_rules - determine whether an inode matches the measure rule.
  * @rule: a pointer to a rule
@@ -270,7 +313,7 @@ static bool ima_match_rules(struct ima_rule_entry *rule, struct inode *inode,
 	if ((rule->flags & IMA_FSUUID) &&
 	    !uuid_equal(&rule->fsuuid, &inode->i_sb->s_uuid))
 		return false;
-	if ((rule->flags & IMA_UID) && !rule->uid_op(cred->uid, rule->uid))
+	if ((rule->flags & IMA_UID) && !ima_uid_op(cred, rule))
 		return false;
 	if (rule->flags & IMA_EUID) {
 		if (has_capability_noaudit(current, CAP_SETUID)) {
@@ -283,7 +326,7 @@ static bool ima_match_rules(struct ima_rule_entry *rule, struct inode *inode,
 	}
 
 	if ((rule->flags & IMA_FOWNER) &&
-	    !rule->fowner_op(inode->i_uid, rule->fowner))
+	    ima_fowner_op(inode->i_uid, rule))
 		return false;
 	for (i = 0; i < MAX_LSM_RULES; i++) {
 		int rc = 0;
@@ -356,6 +399,7 @@ static int get_subaction(struct ima_rule_entry *rule, enum ima_hooks func)
  * @func: IMA hook identifier
  * @mask: requested action (MAY_READ | MAY_WRITE | MAY_APPEND | MAY_EXEC)
  * @pcr: set the pcr to extend
+ * @ns: the IMA namespace
  *
  * Measure decision based on func/mask/fsmagic and LSM(subj/obj/type)
  * conditions.
@@ -365,7 +409,7 @@ static int get_subaction(struct ima_rule_entry *rule, enum ima_hooks func)
  * than writes so ima_match_policy() is classical RCU candidate.
  */
 int ima_match_policy(struct inode *inode, enum ima_hooks func, int mask,
-		     int flags, int *pcr)
+		     int flags, int *pcr, struct ima_namespace *ns)
 {
 	struct ima_rule_entry *entry;
 	int action = 0, actmask = flags | (flags << 1);
@@ -376,6 +420,19 @@ int ima_match_policy(struct inode *inode, enum ima_hooks func, int mask,
 		if (!(entry->action & actmask))
 			continue;
 
+		switch (entry->action) {
+		case AUDIT:
+			/*
+			 * A rule with 'ns' attribute does not
+			 * apply to the namespace the policy is in
+			 * (here: init_ima_ns)
+			 */
+			if (ns == &init_ima_ns &&
+			    entry->flags & IMA_NS)
+				continue;
+			break;
+		}
+
 		if (!ima_match_rules(entry, inode, func, mask))
 			continue;
 
@@ -533,7 +590,7 @@ enum {
 	Opt_uid_gt, Opt_euid_gt, Opt_fowner_gt,
 	Opt_uid_lt, Opt_euid_lt, Opt_fowner_lt,
 	Opt_appraise_type, Opt_permit_directio,
-	Opt_pcr
+	Opt_pcr, Opt_ns,
 };
 
 static match_table_t policy_tokens = {
@@ -566,6 +623,7 @@ static match_table_t policy_tokens = {
 	{Opt_appraise_type, "appraise_type=%s"},
 	{Opt_permit_directio, "permit_directio"},
 	{Opt_pcr, "pcr=%s"},
+	{Opt_ns, "ns"},
 	{Opt_err, NULL}
 };
 
@@ -881,6 +939,13 @@ static int ima_parse_rule(char *rule, struct ima_rule_entry *entry)
 		case Opt_permit_directio:
 			entry->flags |= IMA_PERMIT_DIRECTIO;
 			break;
+		case Opt_ns:
+			if (entry->action != AUDIT) {
+				result = -EINVAL;
+				break;
+			}
+			entry->flags |= IMA_NS;
+			break;
 		case Opt_pcr:
 			if (entry->action != MEASURE) {
 				result = -EINVAL;
@@ -1168,6 +1233,8 @@ int ima_policy_show(struct seq_file *m, void *v)
 		seq_puts(m, "appraise_type=imasig ");
 	if (entry->flags & IMA_PERMIT_DIRECTIO)
 		seq_puts(m, "permit_directio ");
+	if (entry->flags & IMA_NS)
+		seq_puts(m, "ns ");
 	rcu_read_unlock();
 	seq_puts(m, "\n");
 	return 0;
-- 
2.14.3
