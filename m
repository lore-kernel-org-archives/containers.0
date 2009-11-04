From: Liu Aleaxander <aleaxander@gmail.com>
Subject: [PATCH] cgroup: Fixes the un-paired cgroup lock problem
Date: Wed, 4 Nov 2009 09:40:40 +0800
Message-ID: <b741c2440911031740m52f8c11dt6e57b549cc6ce465@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753682AbZKDBkg@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: Liu Aleaxander <Aleaxander@gmail.com>
Date: Wed, 4 Nov 2009 09:27:06 +0800
Subject: [PATCH] Fixes the un-paired cgroup lock problem

In cgroup_lock_live_group, it locks the cgroup by mutex_lock, while in the
cgroup_tasks_write, it unlock it by cgroup_unlock. Even though they are
equal, but I do think we should make it pair.

BTW, should we replace others with cgroup_lock and cgroup_unlock?
Since we already have a wrapper one and it's meaningful.

Signed-off-by: Liu Aleaxander <Aleaxander@gmail.com>
---
 kernel/cgroup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0249f4b..ee2274e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1660,9 +1660,9 @@ static int cgroup_tasks_write(struct cgroup
*cgrp, struct cftype *cft, u64 pid)
  */
 bool cgroup_lock_live_group(struct cgroup *cgrp)
 {
-	mutex_lock(&cgroup_mutex);
+	cgroup_lock();
 	if (cgroup_is_removed(cgrp)) {
-		mutex_unlock(&cgroup_mutex);
+		cgroup_unlock();
 		return false;
 	}
 	return true;
-- 
1.6.2.5

-- 
regards
Liu Aleaxander
