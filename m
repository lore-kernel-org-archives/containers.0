From: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 08/12] container quota: let quotactl(2) works for container.
Date: Wed, 30 May 2012 22:59:02 +0800
Message-ID: <1338389946-13711-9-git-send-email-jeff.liu@oracle.com>
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

Modify quotactl(2) to determine for container quota control operations.

Signed-off-by: Jie Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 fs/quota/quota.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/quota/quota.c b/fs/quota/quota.c
index 9a39120..40f381e 100644
--- a/fs/quota/quota.c
+++ b/fs/quota/quota.c
@@ -18,6 +18,12 @@
 #include <linux/types.h>
 #include <linux/writeback.h>
 
+/* Mount namespace disk quota required */
+#include <linux/mount.h>
+#include <linux/mnt_namespace.h>
+#include "../ns_quota.h"
+#include "../ns_quotaops.h"
+
 static int check_quotactl_permission(struct super_block *sb, int type, int cmd,
 				     qid_t id)
 {
@@ -355,6 +361,14 @@ SYSCALL_DEFINE4(quotactl, unsigned int, cmd, const char __user *, special,
 	type = cmd & SUBCMDMASK;
 
 	/*
+	 * Perform mount namespace quotactl when it is invoked from container.
+	 */
+	if (do_quotactl_for_container(special)) {
+		ret = do_container_quotactl(type, cmds, id, addr);
+		goto out;
+	}
+
+	/*
 	 * As a special case Q_SYNC can be called without a specific device.
 	 * It will iterate all superblocks that have quota enabled and call
 	 * the sync action on each of them.
-- 
1.7.9
