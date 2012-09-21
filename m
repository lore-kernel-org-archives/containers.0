From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 03/14] userns: Convert tomoyo to use kuid and kgid where
	appropriate
Date: Thu, 20 Sep 2012 17:28:39 -0700
Message-ID: <1348187330-6616-3-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig                |    3 ---
 security/tomoyo/audit.c     |   23 ++++++++++++++++-------
 security/tomoyo/common.c    |    4 +++-
 security/tomoyo/common.h    |    4 ++--
 security/tomoyo/condition.c |   20 ++++++++++----------
 5 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 637faf8..381f765 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -962,9 +962,6 @@ config UIDGID_CONVERTED
 	# The rare drivers that won't build
 	depends on ANDROID_BINDER_IPC = n
 
-	# Security modules
-	depends on SECURITY_TOMOYO = n
-
 config UIDGID_STRICT_TYPE_CHECKS
 	bool "Require conversions between uid/gids and their internal representation"
 	depends on UIDGID_CONVERTED
diff --git a/security/tomoyo/audit.c b/security/tomoyo/audit.c
index 7ef9fa3..c1b0037 100644
--- a/security/tomoyo/audit.c
+++ b/security/tomoyo/audit.c
@@ -168,9 +168,14 @@ static char *tomoyo_print_header(struct tomoyo_request_info *r)
 		       stamp.day, stamp.hour, stamp.min, stamp.sec, r->profile,
 		       tomoyo_mode[r->mode], tomoyo_yesno(r->granted), gpid,
 		       tomoyo_sys_getpid(), tomoyo_sys_getppid(),
-		       current_uid(), current_gid(), current_euid(),
-		       current_egid(), current_suid(), current_sgid(),
-		       current_fsuid(), current_fsgid());
+		       from_kuid(&init_user_ns, current_uid()),
+		       from_kgid(&init_user_ns, current_gid()),
+		       from_kuid(&init_user_ns, current_euid()),
+		       from_kgid(&init_user_ns, current_egid()),
+		       from_kuid(&init_user_ns, current_suid()),
+		       from_kgid(&init_user_ns, current_sgid()),
+		       from_kuid(&init_user_ns, current_fsuid()),
+		       from_kgid(&init_user_ns, current_fsgid()));
 	if (!obj)
 		goto no_obj_info;
 	if (!obj->validate_done) {
@@ -191,15 +196,19 @@ static char *tomoyo_print_header(struct tomoyo_request_info *r)
 					tomoyo_buffer_len - 1 - pos,
 					" path%u.parent={ uid=%u gid=%u "
 					"ino=%lu perm=0%o }", (i >> 1) + 1,
-					stat->uid, stat->gid, (unsigned long)
-					stat->ino, stat->mode & S_IALLUGO);
+					from_kuid(&init_user_ns, stat->uid),
+					from_kgid(&init_user_ns, stat->gid),
+					(unsigned long)stat->ino,
+					stat->mode & S_IALLUGO);
 			continue;
 		}
 		pos += snprintf(buffer + pos, tomoyo_buffer_len - 1 - pos,
 				" path%u={ uid=%u gid=%u ino=%lu major=%u"
 				" minor=%u perm=0%o type=%s", (i >> 1) + 1,
-				stat->uid, stat->gid, (unsigned long)
-				stat->ino, MAJOR(dev), MINOR(dev),
+				from_kuid(&init_user_ns, stat->uid),
+				from_kgid(&init_user_ns, stat->gid),
+				(unsigned long)stat->ino,
+				MAJOR(dev), MINOR(dev),
 				mode & S_IALLUGO, tomoyo_filetype(mode));
 		if (S_ISCHR(mode) || S_ISBLK(mode)) {
 			dev = stat->rdev;
diff --git a/security/tomoyo/common.c b/security/tomoyo/common.c
index 2e0f12c..f89a033 100644
--- a/security/tomoyo/common.c
+++ b/security/tomoyo/common.c
@@ -925,7 +925,9 @@ static bool tomoyo_manager(void)
 
 	if (!tomoyo_policy_loaded)
 		return true;
-	if (!tomoyo_manage_by_non_root && (task->cred->uid || task->cred->euid))
+	if (!tomoyo_manage_by_non_root &&
+	    (!uid_eq(task->cred->uid,  GLOBAL_ROOT_UID) ||
+	     !uid_eq(task->cred->euid, GLOBAL_ROOT_UID)))
 		return false;
 	exe = tomoyo_get_exe();
 	if (!exe)
diff --git a/security/tomoyo/common.h b/security/tomoyo/common.h
index 75e4dc1..af010b6 100644
--- a/security/tomoyo/common.h
+++ b/security/tomoyo/common.h
@@ -561,8 +561,8 @@ struct tomoyo_address_group {
 
 /* Subset of "struct stat". Used by conditional ACL and audit logs. */
 struct tomoyo_mini_stat {
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 	ino_t ino;
 	umode_t mode;
 	dev_t dev;
diff --git a/security/tomoyo/condition.c b/security/tomoyo/condition.c
index 986330b..63681e8 100644
--- a/security/tomoyo/condition.c
+++ b/security/tomoyo/condition.c
@@ -813,28 +813,28 @@ bool tomoyo_condition(struct tomoyo_request_info *r,
 			unsigned long value = 0;
 			switch (index) {
 			case TOMOYO_TASK_UID:
-				value = current_uid();
+				value = from_kuid(&init_user_ns, current_uid());
 				break;
 			case TOMOYO_TASK_EUID:
-				value = current_euid();
+				value = from_kuid(&init_user_ns, current_euid());
 				break;
 			case TOMOYO_TASK_SUID:
-				value = current_suid();
+				value = from_kuid(&init_user_ns, current_suid());
 				break;
 			case TOMOYO_TASK_FSUID:
-				value = current_fsuid();
+				value = from_kuid(&init_user_ns, current_fsuid());
 				break;
 			case TOMOYO_TASK_GID:
-				value = current_gid();
+				value = from_kgid(&init_user_ns, current_gid());
 				break;
 			case TOMOYO_TASK_EGID:
-				value = current_egid();
+				value = from_kgid(&init_user_ns, current_egid());
 				break;
 			case TOMOYO_TASK_SGID:
-				value = current_sgid();
+				value = from_kgid(&init_user_ns, current_sgid());
 				break;
 			case TOMOYO_TASK_FSGID:
-				value = current_fsgid();
+				value = from_kgid(&init_user_ns, current_fsgid());
 				break;
 			case TOMOYO_TASK_PID:
 				value = tomoyo_sys_getpid();
@@ -970,13 +970,13 @@ bool tomoyo_condition(struct tomoyo_request_info *r,
 					case TOMOYO_PATH2_UID:
 					case TOMOYO_PATH1_PARENT_UID:
 					case TOMOYO_PATH2_PARENT_UID:
-						value = stat->uid;
+						value = from_kuid(&init_user_ns, stat->uid);
 						break;
 					case TOMOYO_PATH1_GID:
 					case TOMOYO_PATH2_GID:
 					case TOMOYO_PATH1_PARENT_GID:
 					case TOMOYO_PATH2_PARENT_GID:
-						value = stat->gid;
+						value = from_kgid(&init_user_ns, stat->gid);
 						break;
 					case TOMOYO_PATH1_INO:
 					case TOMOYO_PATH2_INO:
-- 
1.7.5.4
