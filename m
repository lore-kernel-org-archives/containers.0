From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: [RFC][ only for review ] memory controller bacground reclaim [1/5]
 spinlock fix in res_counter modification
Date: Wed, 28 Nov 2007 17:51:35 +0900
Message-ID: <20071128175135.c42adecc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071128174923.1f54f53f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071128174923.1f54f53f.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

spinlock is necessary when someone changes res_counter value.
splited out from YAMAMOTO's background page reclaim for memory cgroup set.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
From: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>


 kernel/res_counter.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6.24-rc3-mm1/kernel/res_counter.c
===================================================================
--- linux-2.6.24-rc3-mm1.orig/kernel/res_counter.c	2007-11-27 14:07:44.000000000 +0900
+++ linux-2.6.24-rc3-mm1/kernel/res_counter.c	2007-11-27 14:09:40.000000000 +0900
@@ -98,7 +98,7 @@
 {
 	int ret;
 	char *buf, *end;
-	unsigned long long tmp, *val;
+	unsigned long long flags, tmp, *val;
 
 	buf = kmalloc(nbytes + 1, GFP_KERNEL);
 	ret = -ENOMEM;
@@ -121,9 +121,10 @@
 		if (*end != '\0')
 			goto out_free;
 	}
-
+	spin_lock_irqsave(&counter->lock, flags);
 	val = res_counter_member(counter, member);
 	*val = tmp;
+	spin_unlock_irqrestore(&counter->lock, flags);
 	ret = nbytes;
 out_free:
 	kfree(buf);
