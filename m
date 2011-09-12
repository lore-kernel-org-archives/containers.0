From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: [PATCH 06/11] cgroups: Add res counter common ancestor searching
Date: Tue, 13 Sep 2011 01:11:26 +0200
Message-ID: <1315869091-18933-7-git-send-email-fweisbec@gmail.com>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Containers <containers@lists.osdl.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>
List-Id: containers.vger.kernel.org

Add a new API to find the common ancestor between two resource
counters. This includes the passed resource counter themselves.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
Acked-by: Paul Menage <paul@paulmenage.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Aditya Kali <adityakali@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kay Sievers <kay.sievers@vrfy.org>
Cc: Tim Hockin <thockin@hockin.org>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/res_counter.h |    3 +++
 kernel/res_counter.c        |   22 ++++++++++++++++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index de4ba29..558f39b 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -147,6 +147,9 @@ static inline void res_counter_uncharge(struct res_counter *counter,
 	res_counter_uncharge_until(counter, NULL, val);
 }
 
+struct res_counter *res_counter_common_ancestor(struct res_counter *l,
+						struct res_counter *r);
+
 /**
  * res_counter_margin - calculate chargeable space of a counter
  * @cnt: the counter
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 0cc9c7e..22f07cc 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -91,6 +91,28 @@ void res_counter_uncharge_until(struct res_counter *counter,
 	local_irq_restore(flags);
 }
 
+/*
+ * Walk through r1 and r2 parents and try to find the closest common one
+ * between both. If none is found, it returns NULL.
+ */
+struct res_counter *
+res_counter_common_ancestor(struct res_counter *r1, struct res_counter *r2)
+{
+	struct res_counter *iter;
+
+	while (r1) {
+		iter = r2;
+		while (iter) {
+			if (iter == r1)
+				return iter;
+			iter = iter->parent;
+		}
+
+		r1 = r1->parent;
+	}
+
+	return NULL;
+}
 
 static inline unsigned long long *
 res_counter_member(struct res_counter *counter, int member)
-- 
1.7.5.4
