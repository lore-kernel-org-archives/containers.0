From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 05/14] userns: Convert hostfs to use kuid and kgid where
	appropriate
Date: Thu, 20 Sep 2012 17:28:41 -0700
Message-ID: <1348187330-6616-5-git-send-email-ebiederm@xmission.com>
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
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jeff Dike <jdike-OPE4K8JWMJJBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Jeff Dike <jdike-OPE4K8JWMJJBDgjK7y7TUQ@public.gmane.org>
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/hostfs/hostfs_kern.c |    8 ++++----
 init/Kconfig            |    2 --
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index 1241465..6c9f3a9 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -542,8 +542,8 @@ static int read_name(struct inode *ino, char *name)
 	ino->i_ino = st.ino;
 	ino->i_mode = st.mode;
 	set_nlink(ino, st.nlink);
-	ino->i_uid = st.uid;
-	ino->i_gid = st.gid;
+	i_uid_write(ino, st.uid);
+	i_gid_write(ino, st.gid);
 	ino->i_atime = st.atime;
 	ino->i_mtime = st.mtime;
 	ino->i_ctime = st.ctime;
@@ -808,11 +808,11 @@ int hostfs_setattr(struct dentry *dentry, struct iattr *attr)
 	}
 	if (attr->ia_valid & ATTR_UID) {
 		attrs.ia_valid |= HOSTFS_ATTR_UID;
-		attrs.ia_uid = attr->ia_uid;
+		attrs.ia_uid = from_kuid(&init_user_ns, attr->ia_uid);
 	}
 	if (attr->ia_valid & ATTR_GID) {
 		attrs.ia_valid |= HOSTFS_ATTR_GID;
-		attrs.ia_gid = attr->ia_gid;
+		attrs.ia_gid = from_kgid(&init_user_ns, attr->ia_gid);
 	}
 	if (attr->ia_valid & ATTR_SIZE) {
 		attrs.ia_valid |= HOSTFS_ATTR_SIZE;
diff --git a/init/Kconfig b/init/Kconfig
index 381f765..8450442 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -957,8 +957,6 @@ config UIDGID_CONVERTED
 	depends on UFS_FS = n
 	depends on XFS_FS = n
 
-	depends on !UML || HOSTFS = n
-
 	# The rare drivers that won't build
 	depends on ANDROID_BINDER_IPC = n
 
-- 
1.7.5.4
