From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 24/27] userns: Convert quota netlink aka quota_send_warning
Date: Wed, 19 Sep 2012 18:52:26 -0700
Message-ID: <1348105949-25454-24-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Modify quota_send_warning to take struct kqid instead a type and
identifier pair.

When sending netlink broadcasts always convert uids and quota
identifiers into the intial user namespace.  There is as yet no way to
send a netlink broadcast message with different contents to receivers
in different namespaces, so for the time being just map all of the
identifiers into the initial user namespace which preserves the
current behavior.

Change the callers of quota_send_warning in gfs2, xfs and dquot
to generate a struct kqid to pass to quota send warning.  When
all of the user namespaces convesions are complete a struct kqid
values will be availbe without need for conversion, but a conversion
is needed now to avoid needing to convert everything at once.

Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/quota.c          |   12 ++++++++----
 fs/quota/dquot.c         |    2 +-
 fs/quota/netlink.c       |   10 ++++++----
 fs/xfs/xfs_trans_dquot.c |    8 +++++---
 include/linux/quota.h    |    4 ++--
 init/Kconfig             |    1 -
 6 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index b311539..d554dff 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -1070,8 +1070,10 @@ int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
 
 		if (be64_to_cpu(qd->qd_qb.qb_limit) && (s64)be64_to_cpu(qd->qd_qb.qb_limit) < value) {
 			print_message(qd, "exceeded");
-			quota_send_warning(test_bit(QDF_USER, &qd->qd_flags) ?
-					   USRQUOTA : GRPQUOTA, qd->qd_id,
+			quota_send_warning(make_kqid(&init_user_ns,
+						     test_bit(QDF_USER, &qd->qd_flags) ?
+						     USRQUOTA : GRPQUOTA,
+						     qd->qd_id),
 					   sdp->sd_vfs->s_dev, QUOTA_NL_BHARDWARN);
 
 			error = -EDQUOT;
@@ -1081,8 +1083,10 @@ int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
 			   time_after_eq(jiffies, qd->qd_last_warn +
 					 gfs2_tune_get(sdp,
 						gt_quota_warn_period) * HZ)) {
-			quota_send_warning(test_bit(QDF_USER, &qd->qd_flags) ?
-					   USRQUOTA : GRPQUOTA, qd->qd_id,
+			quota_send_warning(make_kqid(&init_user_ns,
+						     test_bit(QDF_USER, &qd->qd_flags) ?
+						     USRQUOTA : GRPQUOTA,
+						     qd->qd_id),
 					   sdp->sd_vfs->s_dev, QUOTA_NL_BSOFTWARN);
 			error = print_message(qd, "warning");
 			qd->qd_last_warn = jiffies;
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 7714b16..80d3378 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -1236,7 +1236,7 @@ static void flush_warnings(struct dquot_warn *warn)
 #ifdef CONFIG_PRINT_QUOTA_WARNING
 		print_warning(&warn[i]);
 #endif
-		quota_send_warning(warn[i].w_dq_type, warn[i].w_dq_id,
+		quota_send_warning(make_kqid(&init_user_ns, warn[i].w_dq_type, warn[i].w_dq_id),
 				   warn[i].w_sb->s_dev, warn[i].w_type);
 	}
 }
diff --git a/fs/quota/netlink.c b/fs/quota/netlink.c
index d67908b..16e8abb 100644
--- a/fs/quota/netlink.c
+++ b/fs/quota/netlink.c
@@ -30,7 +30,7 @@ static struct genl_family quota_genl_family = {
  *
  */
 
-void quota_send_warning(short type, unsigned int id, dev_t dev,
+void quota_send_warning(struct kqid qid, dev_t dev,
 			const char warntype)
 {
 	static atomic_t seq;
@@ -56,10 +56,11 @@ void quota_send_warning(short type, unsigned int id, dev_t dev,
 		  "VFS: Cannot store netlink header in quota warning.\n");
 		goto err_out;
 	}
-	ret = nla_put_u32(skb, QUOTA_NL_A_QTYPE, type);
+	ret = nla_put_u32(skb, QUOTA_NL_A_QTYPE, qid.type);
 	if (ret)
 		goto attr_err_out;
-	ret = nla_put_u64(skb, QUOTA_NL_A_EXCESS_ID, id);
+	ret = nla_put_u64(skb, QUOTA_NL_A_EXCESS_ID,
+			  from_kqid_munged(&init_user_ns, qid));
 	if (ret)
 		goto attr_err_out;
 	ret = nla_put_u32(skb, QUOTA_NL_A_WARNING, warntype);
@@ -71,7 +72,8 @@ void quota_send_warning(short type, unsigned int id, dev_t dev,
 	ret = nla_put_u32(skb, QUOTA_NL_A_DEV_MINOR, MINOR(dev));
 	if (ret)
 		goto attr_err_out;
-	ret = nla_put_u64(skb, QUOTA_NL_A_CAUSED_ID, current_uid());
+	ret = nla_put_u64(skb, QUOTA_NL_A_CAUSED_ID,
+			  from_kuid_munged(&init_user_ns, current_uid()));
 	if (ret)
 		goto attr_err_out;
 	genlmsg_end(skb, msg_head);
diff --git a/fs/xfs/xfs_trans_dquot.c b/fs/xfs/xfs_trans_dquot.c
index bcb6054..0c7fa54 100644
--- a/fs/xfs/xfs_trans_dquot.c
+++ b/fs/xfs/xfs_trans_dquot.c
@@ -578,9 +578,11 @@ xfs_quota_warn(
 	/* no warnings for project quotas - we just return ENOSPC later */
 	if (dqp->dq_flags & XFS_DQ_PROJ)
 		return;
-	quota_send_warning((dqp->dq_flags & XFS_DQ_USER) ? USRQUOTA : GRPQUOTA,
-			   be32_to_cpu(dqp->q_core.d_id), mp->m_super->s_dev,
-			   type);
+	quota_send_warning(make_kqid(&init_user_ns,
+				     (dqp->dq_flags & XFS_DQ_USER) ?
+				     USRQUOTA : GRPQUOTA,
+				     be32_to_cpu(dqp->q_core.d_id)),
+			   mp->m_super->s_dev, type);
 }
 
 /*
diff --git a/include/linux/quota.h b/include/linux/quota.h
index f96427a..8b27604 100644
--- a/include/linux/quota.h
+++ b/include/linux/quota.h
@@ -511,10 +511,10 @@ static inline unsigned int dquot_generic_flag(unsigned int flags, int type)
 }
 
 #ifdef CONFIG_QUOTA_NETLINK_INTERFACE
-extern void quota_send_warning(short type, unsigned int id, dev_t dev,
+extern void quota_send_warning(struct kqid qid, dev_t dev,
 			       const char warntype);
 #else
-static inline void quota_send_warning(short type, unsigned int id, dev_t dev,
+static inline void quota_send_warning(struct kqid qid, dev_t dev,
 				      const char warntype)
 {
 	return;
diff --git a/init/Kconfig b/init/Kconfig
index 15bb1dc..9c8aa8c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -928,7 +928,6 @@ config UIDGID_CONVERTED
 	depends on IMA = n
 	depends on EVM = n
 	depends on QUOTA = n
-	depends on QUOTA_NETLINK_INTERFACE = n
 
 	# Networking
 	depends on NET_9P = n
-- 
1.7.5.4
