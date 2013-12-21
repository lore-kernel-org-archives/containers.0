From: Andreas Gruenbacher <agruen-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] userns: Relax the posix_acl_valid() checks
Date: Sat, 21 Dec 2013 19:22:26 +0100
Message-ID: <1387650146-7219-1-git-send-email-agruen@linbit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

So far, POSIX ACLs are using a canonical representation that keeps all ACL
entries in a strict order; the ACL_USER and ACL_GROUP entries for specific
users and groups are ordered by user and group identifier, respectively. The
user-space code provides ACL entries in this order; the kernel verifies that
the ACL entry order is correct in posix_acl_valid().

User namespaces allow to arbitrary map user and group identifiers which can
cause the ACL_USER and ACL_GROUP entry order to differ between user space and
the kernel; posix_acl_valid() would then fail.

Work around this by allowing ACL_USER and ACL_GROUP entries to be in any order
in the kernel. The effect is only minor: file permission checks will pick the
first matching ACL_USER entry, and check all matching ACL_GROUP entries.

(The libacl user-space library and getfacl / setfacl tools will not create ACLs
with duplicate user or group idenfifiers; they will handle ACLs with entries in
an arbitrary order correctly.)

Signed-off-by: Andreas Gruenbacher <agruen-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
---
 fs/posix_acl.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 8bd2135..1b30b11 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -78,8 +78,6 @@ posix_acl_valid(const struct posix_acl *acl)
 {
 	const struct posix_acl_entry *pa, *pe;
 	int state = ACL_USER_OBJ;
-	kuid_t prev_uid = INVALID_UID;
-	kgid_t prev_gid = INVALID_GID;
 	int needs_mask = 0;
 
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
@@ -98,10 +96,6 @@ posix_acl_valid(const struct posix_acl *acl)
 					return -EINVAL;
 				if (!uid_valid(pa->e_uid))
 					return -EINVAL;
-				if (uid_valid(prev_uid) &&
-				    uid_lte(pa->e_uid, prev_uid))
-					return -EINVAL;
-				prev_uid = pa->e_uid;
 				needs_mask = 1;
 				break;
 
@@ -117,10 +111,6 @@ posix_acl_valid(const struct posix_acl *acl)
 					return -EINVAL;
 				if (!gid_valid(pa->e_gid))
 					return -EINVAL;
-				if (gid_valid(prev_gid) &&
-				    gid_lte(pa->e_gid, prev_gid))
-					return -EINVAL;
-				prev_gid = pa->e_gid;
 				needs_mask = 1;
 				break;
 
-- 
1.8.1.4
