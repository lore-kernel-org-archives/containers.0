From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 10/25] userns: Convert ecryptfs to use kuid/kgid where
	appropriate
Date: Thu, 20 Sep 2012 04:41:51 -0700
Message-ID: <1348141326-23355-10-git-send-email-ebiederm@xmission.com>
References: <877grox6ql.fsf@xmission.com>
	<1348141326-23355-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348141326-23355-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Dustin Kirkland <dustin.kirkland-Bv2LyzZ6GzxBDgjK7y7TUQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Dustin Kirkland <dustin.kirkland-Bv2LyzZ6GzxBDgjK7y7TUQ@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ecryptfs/main.c      |    5 +++--
 fs/ecryptfs/messaging.c |    5 ++---
 init/Kconfig            |    1 -
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
index 2768138..1d6ce91 100644
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -544,11 +544,12 @@ static struct dentry *ecryptfs_mount(struct file_system_type *fs_type, int flags
 		goto out_free;
 	}
 
-	if (check_ruid && path.dentry->d_inode->i_uid != current_uid()) {
+	if (check_ruid && !uid_eq(path.dentry->d_inode->i_uid, current_uid())) {
 		rc = -EPERM;
 		printk(KERN_ERR "Mount of device (uid: %d) not owned by "
 		       "requested user (uid: %d)\n",
-		       path.dentry->d_inode->i_uid, current_uid());
+			i_uid_read(path.dentry->d_inode),
+			from_kuid(&init_user_ns, current_uid()));
 		goto out_free;
 	}
 
diff --git a/fs/ecryptfs/messaging.c b/fs/ecryptfs/messaging.c
index b29bb8b..5fa2471 100644
--- a/fs/ecryptfs/messaging.c
+++ b/fs/ecryptfs/messaging.c
@@ -33,7 +33,7 @@ static struct hlist_head *ecryptfs_daemon_hash;
 struct mutex ecryptfs_daemon_hash_mux;
 static int ecryptfs_hash_bits;
 #define ecryptfs_current_euid_hash(uid) \
-		hash_long((unsigned long)current_euid(), ecryptfs_hash_bits)
+	hash_long((unsigned long)from_kuid(&init_user_ns, current_euid()), ecryptfs_hash_bits)
 
 static u32 ecryptfs_msg_counter;
 static struct ecryptfs_msg_ctx *ecryptfs_msg_ctx_arr;
@@ -121,8 +121,7 @@ int ecryptfs_find_daemon_by_euid(struct ecryptfs_daemon **daemon)
 	hlist_for_each_entry(*daemon, elem,
 			    &ecryptfs_daemon_hash[ecryptfs_current_euid_hash()],
 			    euid_chain) {
-		if ((*daemon)->file->f_cred->euid == current_euid() &&
-		    (*daemon)->file->f_cred->user_ns == current_user_ns()) {
+		if (uid_eq((*daemon)->file->f_cred->euid, current_euid())) {
 			rc = 0;
 			goto out;
 		}
diff --git a/init/Kconfig b/init/Kconfig
index 5f846b5..6120bae 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -941,7 +941,6 @@ config UIDGID_CONVERTED
 	depends on CEPH_FS = n
 	depends on CIFS = n
 	depends on CODA_FS = n
-	depends on ECRYPT_FS = n
 	depends on EFS_FS = n
 	depends on EXOFS_FS = n
 	depends on FUSE_FS = n
-- 
1.7.5.4
