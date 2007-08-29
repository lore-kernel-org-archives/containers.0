From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Remove write-only variable from pktgen_thread
Date: Wed, 29 Aug 2007 17:22:02 +0400
Message-ID: <46D572FA.9090302@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, Sukadev Bhattiprolu <sukadev@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Netdev List <netdev@vger.kernel.org>
List-Id: containers.vger.kernel.org

The pktgen_thread.pid is set to current->pid and is never used
after this. So remove this at all.

Found during isolating the explicit pid/tgid usage.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 3a3154e..93695c2 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -380,7 +380,6 @@ struct pktgen_thread {
 	/* Field for thread to receive "posted" events terminate, stop ifs etc. */
 
 	u32 control;
-	int pid;
 	int cpu;
 
 	wait_queue_head_t queue;
@@ -3462,8 +3461,6 @@ static int pktgen_thread_worker(void *ar
 
 	init_waitqueue_head(&t->queue);
 
-	t->pid = current->pid;
-
 	pr_debug("pktgen: starting pktgen/%d:  pid=%d\n", cpu, task_pid_nr(current));
 
 	max_before_softirq = t->max_before_softirq;
