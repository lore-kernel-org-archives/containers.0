From: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/9] cgroups: add res counter common ancestor searching
Date: Thu, 12 Dec 2013 16:35:13 -0500
Message-ID: <1386884118-14972-5-git-send-email-dwight.engen@oracle.com>
References: <1386884118-14972-1-git-send-email-dwight.engen@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1386884118-14972-1-git-send-email-dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

Add a new API to find the common ancestor between two resource counters.
This includes the passed resource counter themselves.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
Cc: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---
 include/linux/res_counter.h |  4 ++++
 kernel/res_counter.c        | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 9721fde..4addc7a 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -144,6 +144,10 @@ u64 res_counter_uncharge(struct res_counter *counter, unsigned long val);
 u64 res_counter_uncharge_until(struct res_counter *counter,
 			       struct res_counter *top,
 			       unsigned long val);
+
+struct res_counter *res_counter_common_ancestor(struct res_counter *l,
+						struct res_counter *r);
+
 /**
  * res_counter_margin - calculate chargeable space of a counter
  * @cnt: the counter
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index dadb16e..8c16224 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -132,6 +132,40 @@ u64 res_counter_uncharge(struct res_counter *counter, unsigned long val)
 	return res_counter_uncharge_until(counter, NULL, val);
 }
 
+/*
+ * Walk through r1 and r2 parents and try to find the closest common one
+ * between both. If none is found, it returns NULL.
+ */
+struct res_counter *
+res_counter_common_ancestor(struct res_counter *r1, struct res_counter *r2)
+{
+	struct res_counter *iter;
+	int r1_depth = 0, r2_depth = 0;
+
+	for (iter = r1; iter; iter = iter->parent)
+		r1_depth++;
+
+	for (iter = r2; iter; iter = iter->parent)
+		r2_depth++;
+
+	while (r1_depth > r2_depth) {
+		r1 = r1->parent;
+		r1_depth--;
+	}
+
+	while (r2_depth > r1_depth) {
+		r2 = r2->parent;
+		r2_depth--;
+	}
+
+	while (r1 != r2) {
+		r1 = r1->parent;
+		r2 = r2->parent;
+	}
+
+	return r1;
+}
+
 static inline unsigned long long *
 res_counter_member(struct res_counter *counter, int member)
 {
-- 
1.8.3.1
