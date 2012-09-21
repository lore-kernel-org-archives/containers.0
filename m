From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 02/14] userns: Convert apparmor to use kuid and kgid where
	appropriate
Date: Thu, 20 Sep 2012 17:28:38 -0700
Message-ID: <1348187330-6616-2-git-send-email-ebiederm@xmission.com>
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
Cc: John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig                      |    1 -
 security/apparmor/domain.c        |    4 ++--
 security/apparmor/file.c          |   12 +++++++-----
 security/apparmor/include/audit.h |    2 +-
 security/apparmor/include/file.h  |    4 ++--
 5 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index f315997..637faf8 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -964,7 +964,6 @@ config UIDGID_CONVERTED
 
 	# Security modules
 	depends on SECURITY_TOMOYO = n
-	depends on SECURITY_APPARMOR = n
 
 config UIDGID_STRICT_TYPE_CHECKS
 	bool "Require conversions between uid/gids and their internal representation"
diff --git a/security/apparmor/domain.c b/security/apparmor/domain.c
index b81ea10..60f0c76 100644
--- a/security/apparmor/domain.c
+++ b/security/apparmor/domain.c
@@ -721,7 +721,7 @@ audit:
 	if (!permtest)
 		error = aa_audit_file(profile, &perms, GFP_KERNEL,
 				      OP_CHANGE_HAT, AA_MAY_CHANGEHAT, NULL,
-				      target, 0, info, error);
+				      target, GLOBAL_ROOT_UID, info, error);
 
 out:
 	aa_put_profile(hat);
@@ -848,7 +848,7 @@ int aa_change_profile(const char *ns_name, const char *hname, bool onexec,
 audit:
 	if (!permtest)
 		error = aa_audit_file(profile, &perms, GFP_KERNEL, op, request,
-				      name, hname, 0, info, error);
+				      name, hname, GLOBAL_ROOT_UID, info, error);
 
 	aa_put_namespace(ns);
 	aa_put_profile(target);
diff --git a/security/apparmor/file.c b/security/apparmor/file.c
index cf19d40..cd21ec5 100644
--- a/security/apparmor/file.c
+++ b/security/apparmor/file.c
@@ -65,7 +65,7 @@ static void audit_file_mask(struct audit_buffer *ab, u32 mask)
 static void file_audit_cb(struct audit_buffer *ab, void *va)
 {
 	struct common_audit_data *sa = va;
-	uid_t fsuid = current_fsuid();
+	kuid_t fsuid = current_fsuid();
 
 	if (sa->aad->fs.request & AA_AUDIT_FILE_MASK) {
 		audit_log_format(ab, " requested_mask=");
@@ -76,8 +76,10 @@ static void file_audit_cb(struct audit_buffer *ab, void *va)
 		audit_file_mask(ab, sa->aad->fs.denied);
 	}
 	if (sa->aad->fs.request & AA_AUDIT_FILE_MASK) {
-		audit_log_format(ab, " fsuid=%d", fsuid);
-		audit_log_format(ab, " ouid=%d", sa->aad->fs.ouid);
+		audit_log_format(ab, " fsuid=%d",
+				 from_kuid(&init_user_ns, fsuid));
+		audit_log_format(ab, " ouid=%d",
+				 from_kuid(&init_user_ns, sa->aad->fs.ouid));
 	}
 
 	if (sa->aad->fs.target) {
@@ -103,7 +105,7 @@ static void file_audit_cb(struct audit_buffer *ab, void *va)
  */
 int aa_audit_file(struct aa_profile *profile, struct file_perms *perms,
 		  gfp_t gfp, int op, u32 request, const char *name,
-		  const char *target, uid_t ouid, const char *info, int error)
+		  const char *target, kuid_t ouid, const char *info, int error)
 {
 	int type = AUDIT_APPARMOR_AUTO;
 	struct common_audit_data sa;
@@ -201,7 +203,7 @@ static struct file_perms compute_perms(struct aa_dfa *dfa, unsigned int state,
 	 */
 	perms.kill = 0;
 
-	if (current_fsuid() == cond->uid) {
+	if (uid_eq(current_fsuid(), cond->uid)) {
 		perms.allow = map_old_perms(dfa_user_allow(dfa, state));
 		perms.audit = map_old_perms(dfa_user_audit(dfa, state));
 		perms.quiet = map_old_perms(dfa_user_quiet(dfa, state));
diff --git a/security/apparmor/include/audit.h b/security/apparmor/include/audit.h
index 4b7e189..69d8cae 100644
--- a/security/apparmor/include/audit.h
+++ b/security/apparmor/include/audit.h
@@ -125,7 +125,7 @@ struct apparmor_audit_data {
 			const char *target;
 			u32 request;
 			u32 denied;
-			uid_t ouid;
+			kuid_t ouid;
 		} fs;
 	};
 };
diff --git a/security/apparmor/include/file.h b/security/apparmor/include/file.h
index f98fd47..967b2de 100644
--- a/security/apparmor/include/file.h
+++ b/security/apparmor/include/file.h
@@ -71,7 +71,7 @@ struct path;
 
 /* need to make conditional which ones are being set */
 struct path_cond {
-	uid_t uid;
+	kuid_t uid;
 	umode_t mode;
 };
 
@@ -146,7 +146,7 @@ static inline u16 dfa_map_xindex(u16 mask)
 
 int aa_audit_file(struct aa_profile *profile, struct file_perms *perms,
 		  gfp_t gfp, int op, u32 request, const char *name,
-		  const char *target, uid_t ouid, const char *info, int error);
+		  const char *target, kuid_t ouid, const char *info, int error);
 
 /**
  * struct aa_file_rules - components used for file rule permissions
-- 
1.7.5.4
