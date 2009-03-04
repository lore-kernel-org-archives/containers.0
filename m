From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/1] ipc namespace: initialize init_ipc_ns.count to 1
Date: Wed, 4 Mar 2009 09:52:51 -0600
Message-ID: <20090304155251.GA11741@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754207AbZCDPxW@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Hi Andrew,

when I sent an earlier version of the posix mqueue namespaces patchset
you called me on setting init_ipc_ns.count to 2.  The following patch
changes that to 1.  This is safe because the 1-count is for swapper, who
cannot unshare the namespace.  Having init do unshare(CLONE_NEWIPC) only
drops the count to 1.  No pre-init resources other than tasks pin (and
therefore can decrease the refcount on) an ipc_ns.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 ipc/msgutil.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/ipc/msgutil.c b/ipc/msgutil.c
index e5d6da1..f095ee2 100644
--- a/ipc/msgutil.c
+++ b/ipc/msgutil.c
@@ -26,8 +26,7 @@ DEFINE_SPINLOCK(mq_lock);
  * and not CONFIG_IPC_NS.
  */
 struct ipc_namespace init_ipc_ns = {
-	/* It's not for this patch to change, but should this be 1? */
-	.count		= ATOMIC_INIT(2),
+	.count		= ATOMIC_INIT(1),
 #ifdef CONFIG_POSIX_MQUEUE
 	.mq_queues_max   = DFLT_QUEUESMAX,
 	.mq_msg_max      = DFLT_MSGMAX,
-- 
1.5.4.3
