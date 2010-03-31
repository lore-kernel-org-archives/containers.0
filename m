From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Skip down interfaces (v2)
Date: Wed, 31 Mar 2010 09:23:54 -0700
Message-ID: <1270052634-8170-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This makes the netns checkpoint code skip interfaces that are not up.
Later, we want to make it possible to checkpoint down interfaces with
a flag, but for now this helps prevent people from getting stuck on
stock kernels with various unsupported and persistent virtual interfaces,
such as tunnel devices.

Changes in v2:
 - Fix logic to only skip down interfaces if they're not supported

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint_dev.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index bc0415d..e8d574c 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -268,7 +268,16 @@ int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr)
 		goto out;
 
 	for_each_netdev(net, dev) {
-		ret = checkpoint_obj(ctx, dev, CKPT_OBJ_NETDEV);
+		if (dev->netdev_ops->ndo_checkpoint)
+			ret = checkpoint_obj(ctx, dev, CKPT_OBJ_NETDEV);
+		else if (dev->flags & IFF_UP)
+			ret = -ENOSYS;
+		else
+			/* TODO: There should be a flag to attempt a
+			 * checkpoint of downed interfaces, regardless
+			 * of whether they support checkpoint or not.
+			 */
+			ret = 0;
 		if (ret < 0)
 			break;
 	}
-- 
1.6.2.5
