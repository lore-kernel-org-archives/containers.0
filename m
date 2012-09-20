From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 05/25] userns: Convert hugetlbfs to use kuid/kgid where
	appropriate
Date: Thu, 20 Sep 2012 04:41:46 -0700
Message-ID: <1348141326-23355-5-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, William Irwin <wli-tGiaVUSOoeej7qYf8Sx8sA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Note sysctl_hugetlb_shm_group can only be written in the root user
in the initial user namespace, so we can assume sysctl_hugetlb_shm_group
is in the initial user namespace.

Cc: William Irwin <wli-tGiaVUSOoeej7qYf8Sx8sA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/hugetlbfs/inode.c |   16 +++++++++++-----
 init/Kconfig         |    1 -
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 8349a89..6e572c4 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -42,8 +42,8 @@ static const struct inode_operations hugetlbfs_dir_inode_operations;
 static const struct inode_operations hugetlbfs_inode_operations;
 
 struct hugetlbfs_config {
-	uid_t   uid;
-	gid_t   gid;
+	kuid_t   uid;
+	kgid_t   gid;
 	umode_t mode;
 	long	nr_blocks;
 	long	nr_inodes;
@@ -785,13 +785,17 @@ hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
 		case Opt_uid:
 			if (match_int(&args[0], &option))
  				goto bad_val;
-			pconfig->uid = option;
+			pconfig->uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(pconfig->uid))
+				goto bad_val;
 			break;
 
 		case Opt_gid:
 			if (match_int(&args[0], &option))
  				goto bad_val;
-			pconfig->gid = option;
+			pconfig->gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(pconfig->gid))
+				goto bad_val;
 			break;
 
 		case Opt_mode:
@@ -924,7 +928,9 @@ static struct vfsmount *hugetlbfs_vfsmount;
 
 static int can_do_hugetlb_shm(void)
 {
-	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
+	kgid_t shm_group;
+	shm_group = make_kgid(&init_user_ns, sysctl_hugetlb_shm_group);
+	return capable(CAP_IPC_LOCK) || in_group_p(shm_group);
 }
 
 struct file *hugetlb_file_setup(const char *name, unsigned long addr,
diff --git a/init/Kconfig b/init/Kconfig
index 96007af..7ee6e19 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -954,7 +954,6 @@ config UIDGID_CONVERTED
 	depends on HFS_FS = n
 	depends on HFSPLUS_FS = n
 	depends on HPFS_FS = n
-	depends on HUGETLBFS = n
 	depends on ISO9660_FS = n
 	depends on JFFS2_FS = n
 	depends on JFS_FS = n
-- 
1.7.5.4
