From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: [PATCH 08/11] cgroups: Pull up res counter charge failure interpretation to caller
Date: Tue, 13 Sep 2011 01:11:28 +0200
Message-ID: <1315869091-18933-9-git-send-email-fweisbec@gmail.com>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Containers <containers@lists.osdl.org>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>
List-Id: containers.vger.kernel.org

res_counter_charge() always returns -ENOMEM when the limit is reached
and the charge thus can't happen.

However it's up to the caller to interpret this failure and return
the appropriate error value. The task counter subsystem will need
to report the user that a fork() has been cancelled because of some
limit reached, not because we are too short on memory.

Fix this by returning -1 when res_counter_charge() fails.

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
 Documentation/cgroups/resource_counter.txt |    2 ++
 kernel/res_counter.c                       |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
index a2cd05b..24ec61c 100644
--- a/Documentation/cgroups/resource_counter.txt
+++ b/Documentation/cgroups/resource_counter.txt
@@ -76,6 +76,8 @@ to work with it.
 	limit_fail_at parameter is set to the particular res_counter element
 	where the charging failed.
 
+	It returns 0 on success and -1 on failure.
+
  d. int res_counter_charge_locked
 			(struct res_counter *rc, unsigned long val)
 
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index f1fe9f0..076fda4 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -26,7 +26,7 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
 {
 	if (counter->usage + val > counter->limit) {
 		counter->failcnt++;
-		return -ENOMEM;
+		return -1;
 	}
 
 	counter->usage += val;
-- 
1.7.5.4
