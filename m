From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: [PATCH 07/11] res_counter: Allow charge failure pointer to be null
Date: Tue, 13 Sep 2011 01:11:27 +0200
Message-ID: <1315869091-18933-8-git-send-email-fweisbec@gmail.com>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Containers <containers@lists.osdl.org>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>
List-Id: containers.vger.kernel.org

So that callers of res_counter_charge() don't have to create and
pass this pointer even if they aren't interested in it.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Paul Menage <paul@paulmenage.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Aditya Kali <adityakali@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kay Sievers <kay.sievers@vrfy.org>
Cc: Tim Hockin <thockin@hockin.org>
Cc: Tejun Heo <tj@kernel.org>
---
 kernel/res_counter.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 22f07cc..f1fe9f0 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -43,14 +43,16 @@ int res_counter_charge_until(struct res_counter *counter,
 	unsigned long flags;
 	struct res_counter *c, *u;
 
-	*limit_fail_at = NULL;
+	if (limit_fail_at)
+		*limit_fail_at = NULL;
 	local_irq_save(flags);
 	for (c = counter; c != limit; c = c->parent) {
 		spin_lock(&c->lock);
 		ret = res_counter_charge_locked(c, val);
 		spin_unlock(&c->lock);
 		if (ret < 0) {
-			*limit_fail_at = c;
+			if (limit_fail_at)
+				*limit_fail_at = c;
 			goto undo;
 		}
 	}
-- 
1.7.5.4
