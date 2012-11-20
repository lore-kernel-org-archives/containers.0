From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC 02/12] userns: Convert afs to use kuid/kgid where
	appropriate
Date: Tue, 20 Nov 2012 04:43:30 -0800
Message-ID: <1353415420-5457-2-git-send-email-ebiederm@xmission.com>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353415420-5457-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/afs/afs.h      |    4 ++--
 fs/afs/fsclient.c |   14 ++++++++++----
 fs/afs/inode.c    |    6 +++---
 init/Kconfig      |    1 -
 4 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/fs/afs/afs.h b/fs/afs/afs.h
index c548aa3..ba7ac7b 100644
--- a/fs/afs/afs.h
+++ b/fs/afs/afs.h
@@ -119,8 +119,8 @@ struct afs_file_status {
 	u64			size;		/* file size */
 	afs_dataversion_t	data_version;	/* current data version */
 	u32			author;		/* author ID */
-	u32			owner;		/* owner ID */
-	u32			group;		/* group ID */
+	kuid_t			owner;		/* owner ID */
+	kgid_t			group;		/* group ID */
 	afs_access_t		caller_access;	/* access rights for authenticated caller */
 	afs_access_t		anon_access;	/* access rights for unauthenticated caller */
 	umode_t			mode;		/* UNIX mode */
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index b960ff0..eecbf4b 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -42,6 +42,8 @@ static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
 	umode_t mode;
 	u64 data_version, size;
 	u32 changed = 0; /* becomes non-zero if ctime-type changes seen */
+	u32 owner;
+	u32 group;
 
 #define EXTRACT(DST)				\
 	do {					\
@@ -56,7 +58,9 @@ static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
 	size = ntohl(*bp++);
 	data_version = ntohl(*bp++);
 	EXTRACT(status->author);
-	EXTRACT(status->owner);
+	owner = from_kuid(&init_user_ns, status->owner);
+	EXTRACT(owner);
+	status->owner = make_kuid(&init_user_ns, owner);
 	EXTRACT(status->caller_access); /* call ticket dependent */
 	EXTRACT(status->anon_access);
 	EXTRACT(status->mode);
@@ -65,7 +69,9 @@ static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
 	bp++; /* seg size */
 	status->mtime_client = ntohl(*bp++);
 	status->mtime_server = ntohl(*bp++);
-	EXTRACT(status->group);
+	group = from_kgid(&init_user_ns, status->group);
+	EXTRACT(group);
+	status->group = make_kgid(&init_user_ns, group);
 	bp++; /* sync counter */
 	data_version |= (u64) ntohl(*bp++) << 32;
 	EXTRACT(status->lock_count);
@@ -181,12 +187,12 @@ static void xdr_encode_AFS_StoreStatus(__be32 **_bp, struct iattr *attr)
 
 	if (attr->ia_valid & ATTR_UID) {
 		mask |= AFS_SET_OWNER;
-		owner = attr->ia_uid;
+		owner = from_kuid(&init_user_ns, attr->ia_uid);
 	}
 
 	if (attr->ia_valid & ATTR_GID) {
 		mask |= AFS_SET_GROUP;
-		group = attr->ia_gid;
+		group = from_kgid(&init_user_ns, attr->ia_gid);
 	}
 
 	if (attr->ia_valid & ATTR_MODE) {
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 95cffd3..789bc25 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -69,7 +69,7 @@ static int afs_inode_map_status(struct afs_vnode *vnode, struct key *key)
 
 	set_nlink(inode, vnode->status.nlink);
 	inode->i_uid		= vnode->status.owner;
-	inode->i_gid		= 0;
+	inode->i_gid		= GLOBAL_ROOT_GID;
 	inode->i_size		= vnode->status.size;
 	inode->i_ctime.tv_sec	= vnode->status.mtime_server;
 	inode->i_ctime.tv_nsec	= 0;
@@ -175,8 +175,8 @@ struct inode *afs_iget_autocell(struct inode *dir, const char *dev_name,
 	inode->i_mode		= S_IFDIR | S_IRUGO | S_IXUGO;
 	inode->i_op		= &afs_autocell_inode_operations;
 	set_nlink(inode, 2);
-	inode->i_uid		= 0;
-	inode->i_gid		= 0;
+	inode->i_uid		= GLOBAL_ROOT_UID;
+	inode->i_gid		= GLOBAL_ROOT_GID;
 	inode->i_ctime.tv_sec	= get_seconds();
 	inode->i_ctime.tv_nsec	= 0;
 	inode->i_atime		= inode->i_mtime = inode->i_ctime;
diff --git a/init/Kconfig b/init/Kconfig
index 35c1b89..dfa391d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -999,7 +999,6 @@ config UIDGID_CONVERTED
 	default y
 
 	# Filesystems
-	depends on AFS_FS = n
 	depends on CEPH_FS = n
 	depends on CIFS = n
 	depends on CODA_FS = n
-- 
1.7.5.4
