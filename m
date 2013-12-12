From: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/9] cgroups: ability to stop res charge propagation on
	bounded ancestor
Date: Thu, 12 Dec 2013 16:35:12 -0500
Message-ID: <1386884118-14972-4-git-send-email-dwight.engen@oracle.com>
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

From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Moving a task from a cgroup to another may require to substract its
resource charge from the old cgroup and add it to the new one.

For this to happen, the uncharge/charge propagation can just stop when we
reach the common ancestor for the two cgroups.  Further the performance
reasons, we also want to avoid to temporarily overload the common
ancestors with a non-accurate resource counter usage if we charge first
the new cgroup and uncharge the old one thereafter.  This is going to be a
requirement for the coming max number of task subsystem.

To solve this, provide a pair of new API that can charge/uncharge a
resource counter until we reach a given ancestor.

Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Acked-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---
 Documentation/cgroups/resource_counter.txt | 13 ++++++++++---
 include/linux/res_counter.h                |  4 ++++
 kernel/res_counter.c                       | 21 ++++++++++++++++-----
 3 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
index c4d99ed..57f41d5 100644
--- a/Documentation/cgroups/resource_counter.txt
+++ b/Documentation/cgroups/resource_counter.txt
@@ -83,7 +83,14 @@ to work with it.
 	res_counter->lock internally (it must be called with res_counter->lock
 	held). The force parameter indicates whether we can bypass the limit.
 
- e. u64 res_counter_uncharge[_locked]
+ e. int res_counter_charge_until(struct res_counter *counter,
+			     struct res_counter *limit, unsigned long val,
+			     struct res_counter **limit_fail_at)
+
+	The same as res_counter_charge(), but the charge propagation to
+	the hierarchy stops at the limit given in the "limit" parameter.
+
+ f. u64 res_counter_uncharge[_locked]
 			(struct res_counter *rc, unsigned long val)
 
 	When a resource is released (freed) it should be de-accounted
@@ -93,12 +100,12 @@ to work with it.
 
 	The _locked routines imply that the res_counter->lock is taken.
 
- f. u64 res_counter_uncharge_until
+ g. u64 res_counter_uncharge_until
 		(struct res_counter *rc, struct res_counter *top,
 		 unsinged long val)
 
 	Almost same as res_cunter_uncharge() but propagation of uncharge
-	stops when rc == top. This is useful when kill a res_coutner in
+	stops when rc == top. This is useful when kill a res_counter in
 	child cgroup.
 
  2.1 Other accounting routines
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 92b9e18..9721fde 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -119,6 +119,10 @@ int __must_check res_counter_charge_locked(struct res_counter *counter,
 					   unsigned long val, bool force);
 int __must_check res_counter_charge(struct res_counter *counter,
 		unsigned long val, struct res_counter **limit_fail_at);
+int __must_check res_counter_charge_until(struct res_counter *counter,
+					  struct res_counter *top,
+					  unsigned long val,
+					  struct res_counter **limit_fail_at);
 int res_counter_charge_nofail(struct res_counter *counter,
 		unsigned long val, struct res_counter **limit_fail_at);
 
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 6174478..dadb16e 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -40,8 +40,9 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val,
 	return ret;
 }
 
-static int __res_counter_charge(struct res_counter *counter, unsigned long val,
-				struct res_counter **limit_fail_at, bool force)
+static int __res_counter_charge_until(struct res_counter *counter,
+			struct res_counter *top, unsigned long val,
+			struct res_counter **limit_fail_at, bool force)
 {
 	int ret, r;
 	unsigned long flags;
@@ -50,7 +51,7 @@ static int __res_counter_charge(struct res_counter *counter, unsigned long val,
 	r = ret = 0;
 	*limit_fail_at = NULL;
 	local_irq_save(flags);
-	for (c = counter; c != NULL; c = c->parent) {
+	for (c = counter; c != top; c = c->parent) {
 		spin_lock(&c->lock);
 		r = res_counter_charge_locked(c, val, force);
 		spin_unlock(&c->lock);
@@ -77,13 +78,23 @@ static int __res_counter_charge(struct res_counter *counter, unsigned long val,
 int res_counter_charge(struct res_counter *counter, unsigned long val,
 			struct res_counter **limit_fail_at)
 {
-	return __res_counter_charge(counter, val, limit_fail_at, false);
+	return __res_counter_charge_until(counter, NULL, val, limit_fail_at,
+					  false);
+}
+
+int res_counter_charge_until(struct res_counter *counter,
+			     struct res_counter *top, unsigned long val,
+			     struct res_counter **limit_fail_at)
+{
+	return __res_counter_charge_until(counter, top, val, limit_fail_at,
+					  false);
 }
 
 int res_counter_charge_nofail(struct res_counter *counter, unsigned long val,
 			      struct res_counter **limit_fail_at)
 {
-	return __res_counter_charge(counter, val, limit_fail_at, true);
+	return __res_counter_charge_until(counter, NULL, val, limit_fail_at,
+					  true);
 }
 
 u64 res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
-- 
1.8.3.1
