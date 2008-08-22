From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 06/10] user namespaces: hook fs/attr.c
Date: Fri, 22 Aug 2008 14:46:25 -0500
Message-ID: <20080822194625.GF10360@us.ibm.com>
References: <20080822194513.GA10262@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080822194513.GA10262-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hook fs/attr.c so things like chown are properly handled.  Note this is only
for permission checks.  We'll need to hook ext3_setattr to get the right
uids updated.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/attr.c             |   28 +++++++++++++++++++---------
 include/linux/sched.h |    1 +
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 26c71ba..072d367 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -22,6 +22,11 @@ int inode_change_ok(struct inode *inode, struct iattr *attr)
 {
 	int retval = -EPERM;
 	unsigned int ia_valid = attr->ia_valid;
+	uid_t iuid;
+	gid_t igid;
+
+	if (!s_convert_uid_gid(inode, current_userns(), &iuid, &igid))
+		return -EPERM;
 
 	/* If force is set do it anyway. */
 	if (ia_valid & ATTR_FORCE)
@@ -29,30 +34,30 @@ int inode_change_ok(struct inode *inode, struct iattr *attr)
 
 	/* Make sure a caller can chown. */
 	if ((ia_valid & ATTR_UID) &&
-	    (current->fsuid != inode->i_uid ||
-	     attr->ia_uid != inode->i_uid) && !capable(CAP_CHOWN))
+	    (current->fsuid != iuid ||
+	     attr->ia_uid != iuid) && !s_is_capable(inode, current_userns(), CAP_CHOWN))
 		goto error;
 
 	/* Make sure caller can chgrp. */
 	if ((ia_valid & ATTR_GID) &&
-	    (current->fsuid != inode->i_uid ||
-	    (!in_group_p(attr->ia_gid) && attr->ia_gid != inode->i_gid)) &&
-	    !capable(CAP_CHOWN))
+	    (current->fsuid != iuid ||
+	    (!in_group_p(attr->ia_gid) && attr->ia_gid != igid)) &&
+	    !s_is_capable(inode, current_userns(), CAP_CHOWN))
 		goto error;
 
 	/* Make sure a caller can chmod. */
 	if (ia_valid & ATTR_MODE) {
-		if (!is_owner_or_cap(inode))
+		if (current->fsuid != iuid || !s_is_capable(inode, current_userns(), CAP_FOWNER))
 			goto error;
 		/* Also check the setgid bit! */
 		if (!in_group_p((ia_valid & ATTR_GID) ? attr->ia_gid :
-				inode->i_gid) && !capable(CAP_FSETID))
+				igid) && !s_is_capable(inode, current_userns(), CAP_FSETID))
 			attr->ia_mode &= ~S_ISGID;
 	}
 
 	/* Check for setting the inode time. */
 	if (ia_valid & (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)) {
-		if (!is_owner_or_cap(inode))
+		if (current->fsuid != iuid || !s_is_capable(inode, current_userns(), CAP_FOWNER))
 			goto error;
 	}
 fine:
@@ -66,6 +71,11 @@ EXPORT_SYMBOL(inode_change_ok);
 int inode_setattr(struct inode * inode, struct iattr * attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
+	uid_t iuid;
+	gid_t igid;
+
+	if (!s_convert_uid_gid(inode, current_userns(), &iuid, &igid))
+		return -EPERM;
 
 	if (ia_valid & ATTR_SIZE &&
 	    attr->ia_size != i_size_read(inode)) {
@@ -90,7 +100,7 @@ int inode_setattr(struct inode * inode, struct iattr * attr)
 	if (ia_valid & ATTR_MODE) {
 		umode_t mode = attr->ia_mode;
 
-		if (!in_group_p(inode->i_gid) && !capable(CAP_FSETID))
+		if (!in_group_p(igid) && !s_is_capable(inode, current_userns(), CAP_FSETID))
 			mode &= ~S_ISGID;
 		inode->i_mode = mode;
 	}
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a2f1356..f557535 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -611,6 +611,7 @@ struct user_struct {
 #endif
 };
 
+#define current_userns() (current->user->user_ns)
 extern int uids_sysfs_init(void);
 
 extern struct user_struct *find_user(uid_t);
-- 
1.5.4.3
