From: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 07/12] container quota: add quota control source file.
Date: Wed, 30 May 2012 22:59:01 +0800
Message-ID: <1338389946-13711-8-git-send-email-jeff.liu@oracle.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338389946-13711-1-git-send-email-jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: tytso-3s7WtUTddSA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

Add container disk quota control source file.

Signed-off-by: Jie Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 fs/ns_quota.c |  261 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 261 insertions(+), 0 deletions(-)
 create mode 100644 fs/ns_quota.c

diff --git a/fs/ns_quota.c b/fs/ns_quota.c
new file mode 100644
index 0000000..9d24041
--- /dev/null
+++ b/fs/ns_quota.c
@@ -0,0 +1,261 @@
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <asm/current.h>
+#include <linux/uaccess.h>
+#include <linux/kernel.h>
+#include <linux/security.h>
+#include <linux/syscalls.h>
+#include <linux/capability.h>
+#include <linux/types.h>
+#include <linux/writeback.h>
+#include <linux/nsproxy.h>
+#include <linux/mnt_namespace.h>
+#include "mount.h"
+
+/*
+ * The corresponding device of "/" and file system type is "rootfs"
+ * if quotactl(2) is invoked from a container guest.
+ */
+static int is_container_rootfs(const char __user *special)
+{
+	int ret;
+	char *tmp = getname(special);
+
+	if (IS_ERR(tmp))
+		return PTR_ERR(tmp);
+
+	ret = strcmp(tmp, "rootfs");
+	putname(tmp);
+
+	return !ret;
+}
+
+/*
+ * Currently, to ensure quotactl(2) is invoked from a container VM or a
+ * cloned mount namespace created through unshare(1), I do check that the
+ * input dev is "rootfs" or the current pid namespace is not the initial
+ * one.  Is that sounds stupid enough? :(
+ *
+ * FIXME:
+ * Need to find out a reasonable approach to examine whether perform
+ * container disk quota or not.
+ * Some of my thoughs were shown as following:
+ * 1. Define a couple of pariticular NS_QUOTAON/NS_QUOTAOFF/NS_QGETINFO, etc.
+ *    do container disk quota if they are presented.
+ * 2. Maybe people prefer to make use of container disk quota through
+ *    unshare(1) combine with cgroups, and they even don't want run
+ *    quotacheck(8) in this case, they just want to limit those quota stuff
+ *    in a strightford way without disk usage pre-checkup, something like:
+ *    turn quota on a particular mount namespace, set the quota limits per
+ *    their requirements, stop further storage operations once over quota
+ *    limits.  And also, the quota limits can across different storage if
+ *    the underlying file systems are running with container quota enabled.
+ */
+int do_quotactl_for_container(const char __user *special)
+{
+	return (is_container_rootfs(special) ||
+		current->nsproxy->pid_ns != &init_pid_ns) ? 1 : 0;
+}
+
+/*
+ * FIXME: find out a way to solve mount namespace security/cap verfication.
+ * Something like: ns_capable(current->nsproxy->mnt_ns, CAP_XXXX)?
+ */
+static int check_ns_quotactl_permission(struct mnt_namespace *ns,
+					int type, int cmd, qid_t id)
+{
+	switch (cmd) {
+	/* these commands do not require any special privilegues */
+	case Q_GETFMT:
+	case Q_GETINFO:
+		break;
+	/* allow to query information for dquots we "own" */
+	case Q_GETQUOTA:
+		if ((type == USRQUOTA && current_euid() == id) ||
+		    (type == GRPQUOTA && in_egroup_p(id)))
+			break;
+		/*fallthrough*/
+	default:
+		if (!capable(CAP_SYS_ADMIN))
+			return -EPERM;
+	}
+
+	return 0;
+}
+
+/*
+ * FIXME:
+ * The following helpers are copied from general quota, they can be
+ * shared actally.
+ */
+static void copy_to_if_dqblk(struct if_dqblk *dst, struct fs_disk_quota *src)
+{
+	dst->dqb_bhardlimit = src->d_blk_hardlimit;
+	dst->dqb_bsoftlimit = src->d_blk_softlimit;
+	dst->dqb_curspace = src->d_bcount;
+	dst->dqb_ihardlimit = src->d_ino_hardlimit;
+	dst->dqb_isoftlimit = src->d_ino_softlimit;
+	dst->dqb_curinodes = src->d_icount;
+	dst->dqb_btime = src->d_btimer;
+	dst->dqb_itime = src->d_itimer;
+	dst->dqb_valid = QIF_ALL;
+}
+
+static void copy_from_if_dqblk(struct fs_disk_quota *dst, struct if_dqblk *src)
+{
+	dst->d_blk_hardlimit = src->dqb_bhardlimit;
+	dst->d_blk_softlimit  = src->dqb_bsoftlimit;
+	dst->d_bcount = src->dqb_curspace;
+	dst->d_ino_hardlimit = src->dqb_ihardlimit;
+	dst->d_ino_softlimit = src->dqb_isoftlimit;
+	dst->d_icount = src->dqb_curinodes;
+	dst->d_btimer = src->dqb_btime;
+	dst->d_itimer = src->dqb_itime;
+
+	dst->d_fieldmask = 0;
+	if (src->dqb_valid & QIF_BLIMITS)
+		dst->d_fieldmask |= FS_DQ_BSOFT | FS_DQ_BHARD;
+	if (src->dqb_valid & QIF_SPACE)
+		dst->d_fieldmask |= FS_DQ_BCOUNT;
+	if (src->dqb_valid & QIF_ILIMITS)
+		dst->d_fieldmask |= FS_DQ_ISOFT | FS_DQ_IHARD;
+	if (src->dqb_valid & QIF_INODES)
+		dst->d_fieldmask |= FS_DQ_ICOUNT;
+	if (src->dqb_valid & QIF_BTIME)
+		dst->d_fieldmask |= FS_DQ_BTIMER;
+	if (src->dqb_valid & QIF_ITIME)
+		dst->d_fieldmask |= FS_DQ_ITIMER;
+}
+
+static int ns_quota_on(struct mnt_namespace *ns, int type)
+{
+	return ns->ns_qcop->quota_on(ns, type);
+}
+
+static int ns_quota_off(struct mnt_namespace *ns, int type)
+{
+	return ns->ns_qcop->quota_off(ns, type);
+}
+
+static int ns_quota_getinfo(struct mnt_namespace *ns, int type,
+			    void __user *addr)
+{
+	struct if_dqinfo info;
+	int ret;
+
+	ret = ns->ns_qcop->get_info(ns, type, &info);
+	if (!ret && copy_to_user(addr, &info, sizeof(info)))
+		return -EFAULT;
+
+	return ret;
+}
+
+static int ns_quota_setinfo(struct mnt_namespace *ns, int type,
+			    void __user *addr)
+{
+	struct if_dqinfo info;
+
+	if (copy_from_user(&info, addr, sizeof(info)))
+		return -EFAULT;
+
+	return ns->ns_qcop->set_info(ns, type, &info);
+}
+
+static int ns_quota_getquota(struct mnt_namespace *ns, int type,
+			     qid_t id, void __user *addr)
+{
+	struct fs_disk_quota fdq;
+	struct if_dqblk idq;
+	int ret;
+
+	ret = ns->ns_qcop->get_dqblk(ns, type, id, &fdq);
+	if (ret)
+		return ret;
+
+	copy_to_if_dqblk(&idq, &fdq);
+	if (copy_to_user(addr, &idq, sizeof(idq)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int ns_quota_setquota(struct mnt_namespace *ns, int type, qid_t id,
+			     void __user *addr)
+{
+	struct fs_disk_quota fdq;
+	struct if_dqblk idq;
+
+	if (copy_from_user(&idq, addr, sizeof(idq)))
+		return -EFAULT;
+
+	copy_from_if_dqblk(&fdq, &idq);
+	return ns->ns_qcop->set_dqblk(ns, type, id, &fdq);
+}
+
+static int ns_quota_getfmt(struct mnt_namespace *ns, int type,
+			   void __user *addr)
+{
+	__u32 fmt;
+
+	fmt = ns_dquot_getfmt(ns, type);
+	if (!fmt)
+		return fmt;
+
+	if (copy_to_user(addr, &fmt, sizeof(fmt)))
+		return -EFAULT;
+	return 0;
+}
+
+/* Copy parameters and call proper function */
+int do_container_quotactl(int type, int cmd, qid_t id, void __user *addr)
+{
+	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+	int ret = 0;
+
+	if (type >= (XQM_COMMAND(cmd) ? XQM_MAXQUOTAS : MAXQUOTAS))
+		return -EINVAL;
+
+	lock_mnt_ns(ns);
+	ret = check_ns_quotactl_permission(ns, type, cmd, id);
+	if (ret < 0)
+		goto out_unlock;
+
+	if (!ns->ns_qcop) {
+		ret = -ENOSYS;
+		goto out_unlock;
+	}
+
+	switch (cmd) {
+	case Q_QUOTAON:
+		ret = ns_quota_on(ns, type);
+		break;
+	case Q_QUOTAOFF:
+		ret = ns_quota_off(ns, type);
+		break;
+	case Q_GETQUOTA:
+		ret = ns_quota_getquota(ns, type, id, addr);
+		break;
+	case Q_SETQUOTA:
+		ret = ns_quota_setquota(ns, type, id, addr);
+		break;
+	case Q_GETINFO:
+		ret = ns_quota_getinfo(ns, type, addr);
+		break;
+	case Q_SETINFO:
+		ret = ns_quota_setinfo(ns, type, addr);
+		break;
+	case Q_GETFMT:
+		ret = ns_quota_getfmt(ns, type, addr);
+		break;
+	case Q_SYNC:
+		ret = 0;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+out_unlock:
+	unlock_mnt_ns(ns);
+	return ret;
+}
-- 
1.7.9
