From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 07/14] userns: Add user namespace support to IMA
Date: Thu, 20 Sep 2012 17:28:43 -0700
Message-ID: <1348187330-6616-7-git-send-email-ebiederm@xmission.com>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348187330-6616-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Mimi Zohar <zohar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Use kuid's in the IMA rules.

When reporting the current uid in audit logs use from_kuid
to get a usable value.

Cc: Mimi Zohar <zohar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig                        |    4 ----
 security/integrity/ima/ima_audit.c  |    5 +++--
 security/integrity/ima/ima_policy.c |   14 +++++++-------
 3 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 96ee3f3..570cd33 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -923,10 +923,6 @@ config UIDGID_CONVERTED
 	bool
 	default y
 
-	# List of kernel pieces that need user namespace work
-	# Features
-	depends on IMA = n
-
 	# Networking
 	depends on NET_9P = n
 
diff --git a/security/integrity/ima/ima_audit.c b/security/integrity/ima/ima_audit.c
index 7a57f67..c586faa 100644
--- a/security/integrity/ima/ima_audit.c
+++ b/security/integrity/ima/ima_audit.c
@@ -39,8 +39,9 @@ void integrity_audit_msg(int audit_msgno, struct inode *inode,
 
 	ab = audit_log_start(current->audit_context, GFP_KERNEL, audit_msgno);
 	audit_log_format(ab, "pid=%d uid=%u auid=%u ses=%u",
-			 current->pid, current_cred()->uid,
-			 audit_get_loginuid(current),
+			 current->pid,
+			 from_kuid(&init_user_ns, current_cred()->uid),
+			 from_kuid(&init_user_ns, audit_get_loginuid(current)),
 			 audit_get_sessionid(current));
 	audit_log_task_context(ab);
 	audit_log_format(ab, " op=");
diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/ima_policy.c
index 1a95830..c84df05 100644
--- a/security/integrity/ima/ima_policy.c
+++ b/security/integrity/ima/ima_policy.c
@@ -39,7 +39,7 @@ struct ima_measure_rule_entry {
 	enum ima_hooks func;
 	int mask;
 	unsigned long fsmagic;
-	uid_t uid;
+	kuid_t uid;
 	struct {
 		void *rule;	/* LSM file metadata specific */
 		int type;	/* audit type */
@@ -71,7 +71,7 @@ static struct ima_measure_rule_entry default_rules[] = {
 	 .flags = IMA_FUNC | IMA_MASK},
 	{.action = MEASURE,.func = BPRM_CHECK,.mask = MAY_EXEC,
 	 .flags = IMA_FUNC | IMA_MASK},
-	{.action = MEASURE,.func = FILE_CHECK,.mask = MAY_READ,.uid = 0,
+	{.action = MEASURE,.func = FILE_CHECK,.mask = MAY_READ,.uid = GLOBAL_ROOT_UID,
 	 .flags = IMA_FUNC | IMA_MASK | IMA_UID},
 };
 
@@ -112,7 +112,7 @@ static bool ima_match_rules(struct ima_measure_rule_entry *rule,
 	if ((rule->flags & IMA_FSMAGIC)
 	    && rule->fsmagic != inode->i_sb->s_magic)
 		return false;
-	if ((rule->flags & IMA_UID) && rule->uid != cred->uid)
+	if ((rule->flags & IMA_UID) && !uid_eq(rule->uid, cred->uid))
 		return false;
 	for (i = 0; i < MAX_LSM_RULES; i++) {
 		int rc = 0;
@@ -277,7 +277,7 @@ static int ima_parse_rule(char *rule, struct ima_measure_rule_entry *entry)
 
 	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_INTEGRITY_RULE);
 
-	entry->uid = -1;
+	entry->uid = INVALID_UID;
 	entry->action = UNKNOWN;
 	while ((p = strsep(&rule, " \t")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
@@ -361,15 +361,15 @@ static int ima_parse_rule(char *rule, struct ima_measure_rule_entry *entry)
 		case Opt_uid:
 			ima_log_string(ab, "uid", args[0].from);
 
-			if (entry->uid != -1) {
+			if (uid_valid(entry->uid)) {
 				result = -EINVAL;
 				break;
 			}
 
 			result = strict_strtoul(args[0].from, 10, &lnum);
 			if (!result) {
-				entry->uid = (uid_t) lnum;
-				if (entry->uid != lnum)
+				entry->uid = make_kuid(current_user_ns(), (uid_t)lnum);
+				if (!uid_valid(entry->uid) || (((uid_t)lnum) != lnum))
 					result = -EINVAL;
 				else
 					entry->flags |= IMA_UID;
-- 
1.7.5.4
