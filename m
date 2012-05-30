From: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 2/3] container quota tool: add quotaio for lxc
Date: Wed, 30 May 2012 23:07:57 +0800
Message-ID: <1338390478-13951-2-git-send-email-jeff.liu@oracle.com>
References: <1338390478-13951-1-git-send-email-jeff.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338390478-13951-1-git-send-email-jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
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

Add quotaio_lxc.c[.h] to isolate container quotactl operations.

Signed-off-by: Jie Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 quotaio_lxc.c |   78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 quotaio_lxc.h |    4 +++
 2 files changed, 82 insertions(+), 0 deletions(-)
 create mode 100644 quotaio_lxc.c
 create mode 100644 quotaio_lxc.h

diff --git a/quotaio_lxc.c b/quotaio_lxc.c
new file mode 100644
index 0000000..b3a8144
--- /dev/null
+++ b/quotaio_lxc.c
@@ -0,0 +1,78 @@
+#include "config.h"
+
+#include <errno.h>
+#include <string.h>
+#include <pwd.h>
+#include <grp.h>
+#include <stdlib.h>
+#include <sys/types.h>
+
+#include "pot.h"
+#include "common.h"
+#include "quotaio.h"
+#include "quotaio_generic.h"
+#include "quota.h"
+#include "quotasys.h"
+#include "dqblk_lxc.h"
+
+int lxc_init_io(struct quota_handle *h);
+int lxc_write_info(struct quota_handle *h);
+struct dquot *lxc_read_dquot(struct quota_handle *h, qid_t id);
+int lxc_commit_dquot(struct dquot *dquot, int flags);
+int lxc_scan_dquots(struct quota_handle *h, int (*process_dquot)(struct
+dquot *dquot, char *dqname));
+
+struct quotafile_ops quotafile_ops_lxc = {
+init_io:	lxc_init_io,
+write_info:	lxc_write_info,
+read_dquot:	lxc_read_dquot,
+commit_dquot:	lxc_commit_dquot,
+scan_dquots:	lxc_scan_dquots
+};
+
+/*
+ *	Initialize container quota information
+ */
+int lxc_init_io(struct quota_handle *h)
+{
+	/*
+	 * FIXME: at first, before turning LXC quota on,
+	 * call vfs_get_info() will failed as ENOSCH, so
+	 * just return 0 is ok.
+	 * Should we consider to call vfs_get_info(h) here?
+	 */
+	return 0;
+}
+
+/*
+ *	Write information (grace times)
+ */
+int lxc_write_info(struct quota_handle *h)
+{
+	return vfs_set_info(h, IIF_BGRACE | IIF_IGRACE);
+}
+
+struct dquot *lxc_read_dquot(struct quota_handle *h, qid_t id)
+{
+	struct dquot *dquot = get_empty_dquot();
+
+	dquot->dq_id = id;
+	dquot->dq_h = h;
+	memset(&dquot->dq_dqb, 0, sizeof(struct util_dqblk));
+	if (vfs_get_dquot(dquot) < 0) {
+		free(dquot);
+		return NULL;
+	}
+	return dquot;
+}
+
+int lxc_commit_dquot(struct dquot *dquot, int flags)
+{
+	return vfs_set_dquot(dquot, flags);
+}
+
+int lxc_scan_dquots(struct quota_handle *h, int (*process_dquot)(struct
+dquot *dquot, char *dqname))
+{
+	return generic_scan_dquots(h, process_dquot, vfs_get_dquot);
+}
diff --git a/quotaio_lxc.h b/quotaio_lxc.h
new file mode 100644
index 0000000..2ae2899
--- /dev/null
+++ b/quotaio_lxc.h
@@ -0,0 +1,4 @@
+#ifndef GUARD_QUOTAIO_GENERIC_H
+#define GUARD_QUOTAIO_GENERIC_H
+
+#endif
-- 
1.7.9
