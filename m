From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 08/14] userns: Teach security_path_chown to take kuids and
	kgids
Date: Thu, 20 Sep 2012 17:28:44 -0700
Message-ID: <1348187330-6616-8-git-send-email-ebiederm@xmission.com>
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
Cc: John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kentaro Takeda <takedakn-3MafRgGXt7BL9jVzuh4AOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Don't make the security modules deal with raw user space uid and
gids instead pass in a kuid_t and a kgid_t so that security modules
only have to deal with internal kernel uids and gids.

Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Kentaro Takeda <takedakn-3MafRgGXt7BL9jVzuh4AOg@public.gmane.org>
Cc: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/open.c                |    2 +-
 include/linux/security.h |    6 +++---
 security/apparmor/lsm.c  |    2 +-
 security/capability.c    |    2 +-
 security/security.c      |    2 +-
 security/tomoyo/tomoyo.c |   12 +++++++-----
 6 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index f3d96e7..2b25739 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -534,7 +534,7 @@ static int chown_common(struct path *path, uid_t user, gid_t group)
 		newattrs.ia_valid |=
 			ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
 	mutex_lock(&inode->i_mutex);
-	error = security_path_chown(path, user, group);
+	error = security_path_chown(path, uid, gid);
 	if (!error)
 		error = notify_change(path->dentry, &newattrs);
 	mutex_unlock(&inode->i_mutex);
diff --git a/include/linux/security.h b/include/linux/security.h
index 4e5a73c..ebb92cb 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1437,7 +1437,7 @@ struct security_operations {
 	int (*path_rename) (struct path *old_dir, struct dentry *old_dentry,
 			    struct path *new_dir, struct dentry *new_dentry);
 	int (*path_chmod) (struct path *path, umode_t mode);
-	int (*path_chown) (struct path *path, uid_t uid, gid_t gid);
+	int (*path_chown) (struct path *path, kuid_t uid, kgid_t gid);
 	int (*path_chroot) (struct path *path);
 #endif
 
@@ -2832,7 +2832,7 @@ int security_path_link(struct dentry *old_dentry, struct path *new_dir,
 int security_path_rename(struct path *old_dir, struct dentry *old_dentry,
 			 struct path *new_dir, struct dentry *new_dentry);
 int security_path_chmod(struct path *path, umode_t mode);
-int security_path_chown(struct path *path, uid_t uid, gid_t gid);
+int security_path_chown(struct path *path, kuid_t uid, kgid_t gid);
 int security_path_chroot(struct path *path);
 #else	/* CONFIG_SECURITY_PATH */
 static inline int security_path_unlink(struct path *dir, struct dentry *dentry)
@@ -2888,7 +2888,7 @@ static inline int security_path_chmod(struct path *path, umode_t mode)
 	return 0;
 }
 
-static inline int security_path_chown(struct path *path, uid_t uid, gid_t gid)
+static inline int security_path_chown(struct path *path, kuid_t uid, kgid_t gid)
 {
 	return 0;
 }
diff --git a/security/apparmor/lsm.c b/security/apparmor/lsm.c
index 8ea39aa..8c2a7f6 100644
--- a/security/apparmor/lsm.c
+++ b/security/apparmor/lsm.c
@@ -352,7 +352,7 @@ static int apparmor_path_chmod(struct path *path, umode_t mode)
 	return common_perm_mnt_dentry(OP_CHMOD, path->mnt, path->dentry, AA_MAY_CHMOD);
 }
 
-static int apparmor_path_chown(struct path *path, uid_t uid, gid_t gid)
+static int apparmor_path_chown(struct path *path, kuid_t uid, kgid_t gid)
 {
 	struct path_cond cond =  { path->dentry->d_inode->i_uid,
 				   path->dentry->d_inode->i_mode
diff --git a/security/capability.c b/security/capability.c
index 61095df..a40aac6 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -284,7 +284,7 @@ static int cap_path_chmod(struct path *path, umode_t mode)
 	return 0;
 }
 
-static int cap_path_chown(struct path *path, uid_t uid, gid_t gid)
+static int cap_path_chown(struct path *path, kuid_t uid, kgid_t gid)
 {
 	return 0;
 }
diff --git a/security/security.c b/security/security.c
index 860aeb3..f9a2f2e 100644
--- a/security/security.c
+++ b/security/security.c
@@ -434,7 +434,7 @@ int security_path_chmod(struct path *path, umode_t mode)
 	return security_ops->path_chmod(path, mode);
 }
 
-int security_path_chown(struct path *path, uid_t uid, gid_t gid)
+int security_path_chown(struct path *path, kuid_t uid, kgid_t gid)
 {
 	if (unlikely(IS_PRIVATE(path->dentry->d_inode)))
 		return 0;
diff --git a/security/tomoyo/tomoyo.c b/security/tomoyo/tomoyo.c
index c2d04a5..d88eb3a 100644
--- a/security/tomoyo/tomoyo.c
+++ b/security/tomoyo/tomoyo.c
@@ -373,13 +373,15 @@ static int tomoyo_path_chmod(struct path *path, umode_t mode)
  *
  * Returns 0 on success, negative value otherwise.
  */
-static int tomoyo_path_chown(struct path *path, uid_t uid, gid_t gid)
+static int tomoyo_path_chown(struct path *path, kuid_t uid, kgid_t gid)
 {
 	int error = 0;
-	if (uid != (uid_t) -1)
-		error = tomoyo_path_number_perm(TOMOYO_TYPE_CHOWN, path, uid);
-	if (!error && gid != (gid_t) -1)
-		error = tomoyo_path_number_perm(TOMOYO_TYPE_CHGRP, path, gid);
+	if (uid_valid(uid))
+		error = tomoyo_path_number_perm(TOMOYO_TYPE_CHOWN, path,
+						from_kuid(&init_user_ns, uid));
+	if (!error && gid_valid(gid))
+		error = tomoyo_path_number_perm(TOMOYO_TYPE_CHGRP, path,
+						from_kgid(&init_user_ns, gid));
 	return error;
 }
 
-- 
1.7.5.4
