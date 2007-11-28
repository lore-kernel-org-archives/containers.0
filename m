From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: [RFC][ only for review ] memory controller bacground reclaim [2/5]
 set/get ops for res_counter
Date: Wed, 28 Nov 2007 17:52:39 +0900
Message-ID: <20071128175239.e20ec09d.kamezawa.hiroyu@jp.fujitsu.com>
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

At implmenting high/low watermark in res_counter, it will be better to
adjust high/low value when limit changes. (or don't allow user to specify
high/low value)

This patch adds *internal* interface to modify resource value.
(If there are only limit/usage/failcnt, these routines are not necessary but..)
And will be used later.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

 include/linux/res_counter.h |    7 +++++++
 kernel/res_counter.c        |   19 +++++++++++++++++++
 2 files changed, 26 insertions(+)

Index: linux-2.6.24-rc3-mm1/include/linux/res_counter.h
===================================================================
--- linux-2.6.24-rc3-mm1.orig/include/linux/res_counter.h	2007-11-28 14:18:21.000000000 +0900
+++ linux-2.6.24-rc3-mm1/include/linux/res_counter.h	2007-11-28 14:18:33.000000000 +0900
@@ -59,6 +59,13 @@
 		int (*write_strategy)(char *buf, unsigned long long *val));
 
 /*
+ * A routine for set/get limitation value from kernel internal code.
+ * res->lock should be held before call this.
+ */
+unsigned long long res_counter_get(struct res_counter *counter, int member);
+void res_counter_set(struct res_counter *conter, int member,
+			unsigned long long val);
+/*
  * the field descriptors. one for each member of res_counter
  */
 
Index: linux-2.6.24-rc3-mm1/kernel/res_counter.c
===================================================================
--- linux-2.6.24-rc3-mm1.orig/kernel/res_counter.c	2007-11-28 14:18:21.000000000 +0900
+++ linux-2.6.24-rc3-mm1/kernel/res_counter.c	2007-11-28 14:18:33.000000000 +0900
@@ -75,6 +75,25 @@
 	return NULL;
 }
 
+unsigned long long res_counter_get(struct res_counter *res, int member)
+{
+	unsigned long long *val;
+
+	val = res_counter_member(res, member);
+
+	return *val;
+}
+
+void res_counter_set(struct res_counter *res, int member,
+			unsigned long long newval)
+{
+	unsigned long long *val;
+
+	val = res_counter_member(res, member);
+	*val = newval;
+	return;
+}
+
 ssize_t res_counter_read(struct res_counter *counter, int member,
 		const char __user *userbuf, size_t nbytes, loff_t *pos,
 		int (*read_strategy)(unsigned long long val, char *st_buf))
