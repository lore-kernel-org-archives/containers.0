From: Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH] userns: Convert quota to user kuid/kgid where appropriate
Date: Wed,  1 Aug 2012 14:38:52 +0400
Message-ID: <1343817532-12021-1-git-send-email-dmonakhov@openvz.org>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: jack-AlSwsSmVLrQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Map uid/gid to global kuid/kgid before pass it down to quota infrastructure.

Signed-off-by: Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 fs/quota/quota.c |   45 ++++++++++++++++++++++++++++++++++++---------
 1 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/fs/quota/quota.c b/fs/quota/quota.c
index 6f15578..a59efd4 100644
--- a/fs/quota/quota.c
+++ b/fs/quota/quota.c
@@ -19,8 +19,13 @@
 #include <linux/writeback.h>
 
 static int check_quotactl_permission(struct super_block *sb, int type, int cmd,
-				     qid_t id)
+				     qid_t id, qid_t* global_id)
 {
+	kuid_t kuid;
+	kgid_t kgid;
+	struct user_namespace *ns = current_user_ns();
+	int is_get_query = 0;
+
 	switch (cmd) {
 	/* these commands do not require any special privilegues */
 	case Q_GETFMT:
@@ -29,11 +34,32 @@ static int check_quotactl_permission(struct super_block *sb, int type, int cmd,
 	case Q_XGETQSTAT:
 	case Q_XQUOTASYNC:
 		break;
-	/* allow to query information for dquots we "own" */
 	case Q_GETQUOTA:
 	case Q_XGETQUOTA:
-		if ((type == USRQUOTA && current_euid() == id) ||
-		    (type == GRPQUOTA && in_egroup_p(id)))
+		is_get_query = 1;
+	case Q_SETQUOTA:
+	case Q_XSETQLIM:
+		/* Map to global user namespace */
+		switch (type) {
+		case USRQUOTA:
+			kuid = make_kuid(ns, id);
+			if (!uid_valid(kuid))
+				return -EINVAL;
+			*global_id = from_kuid_munged(&init_user_ns, kuid);
+			break;
+		case GRPQUOTA:
+			kgid = make_kgid(ns, id);
+			if (!gid_valid(kgid))
+				return -EINVAL;
+			*global_id = from_kgid_munged(&init_user_ns, kgid);
+			break;
+		default:
+			return -EINVAL;
+		}
+		/* allow to query information for dquots we "own" */
+		if (is_get_query &&
+		    ((type == USRQUOTA && uid_eq(current_euid(), kuid)) ||
+		     (type == GRPQUOTA && in_egroup_p(kgid))))
 			break;
 		/*FALLTHROUGH*/
 	default:
@@ -240,13 +266,14 @@ static int do_quotactl(struct super_block *sb, int type, int cmd, qid_t id,
 		       void __user *addr, struct path *path)
 {
 	int ret;
+	qid_t qid = -1;
 
 	if (type >= (XQM_COMMAND(cmd) ? XQM_MAXQUOTAS : MAXQUOTAS))
 		return -EINVAL;
 	if (!sb->s_qcop)
 		return -ENOSYS;
 
-	ret = check_quotactl_permission(sb, type, cmd, id);
+	ret = check_quotactl_permission(sb, type, cmd, id, &qid);
 	if (ret < 0)
 		return ret;
 
@@ -264,9 +291,9 @@ static int do_quotactl(struct super_block *sb, int type, int cmd, qid_t id,
 	case Q_SETINFO:
 		return quota_setinfo(sb, type, addr);
 	case Q_GETQUOTA:
-		return quota_getquota(sb, type, id, addr);
+		return quota_getquota(sb, type, qid, addr);
 	case Q_SETQUOTA:
-		return quota_setquota(sb, type, id, addr);
+		return quota_setquota(sb, type, qid, addr);
 	case Q_SYNC:
 		if (!sb->s_qcop->quota_sync)
 			return -ENOSYS;
@@ -278,9 +305,9 @@ static int do_quotactl(struct super_block *sb, int type, int cmd, qid_t id,
 	case Q_XGETQSTAT:
 		return quota_getxstate(sb, addr);
 	case Q_XSETQLIM:
-		return quota_setxquota(sb, type, id, addr);
+		return quota_setxquota(sb, type, qid, addr);
 	case Q_XGETQUOTA:
-		return quota_getxquota(sb, type, id, addr);
+		return quota_getxquota(sb, type, qid, addr);
 	case Q_XQUOTASYNC:
 		if (sb->s_flags & MS_RDONLY)
 			return -EROFS;
-- 
1.7.1
