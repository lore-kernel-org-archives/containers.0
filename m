From: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 1/3] container quota tool: add LXC quota format identifier
Date: Wed, 30 May 2012 23:07:56 +0800
Message-ID: <1338390478-13951-1-git-send-email-jeff.liu@oracle.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: tytso-3s7WtUTddSA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

Add a new quota format QFMT_NS for container, return from Q_GETINFO.

Signed-off-by: Jie Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 quota.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/quota.h b/quota.h
index ac034d0..9c37bed 100644
--- a/quota.h
+++ b/quota.h
@@ -145,6 +145,7 @@ enum {
 #define QFMT_VFS_V0  2
 #define QFMT_OCFS2   3
 #define QFMT_VFS_V1  4
+#define QFMT_NS      5
 
 /* Flags supported by kernel */
 #define V1_DQF_RSQUASH 1
-- 
1.7.9
