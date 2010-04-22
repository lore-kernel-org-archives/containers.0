From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 4/5] freezer cgroup: Fix an RCU warning in cgroup_freezing_or_frozen()
Date: Thu, 22 Apr 2010 17:31:20 +0800
Message-ID: <4BD01768.2020606@cn.fujitsu.com>
References: <4BD016F4.8060108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BD016F4.8060108@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: "containers@lists.osdl.org" <containers@lists.osdl.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Helsley <matthltc@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>
List-Id: containers.vger.kernel.org

with CONFIG_PROVE_RCU, a warning can be triggered when we
resume from suspend:

...
include/linux/cgroup.h:533 invoked rcu_dereference_check() without protection!
...

task_freezer() calls task_subsys_state(), which needs to be
protected by rcu_read_lock or cgroup_mutex.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cgroup_freezer.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 5038f4c..ac76983 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -53,6 +53,7 @@ int cgroup_freezing_or_frozen(struct task_struct *task)
 	struct freezer *freezer;
 	enum freezer_state state;
 
+	rcu_read_lock();
 	task_lock(task);
 	freezer = task_freezer(task);
 	if (!freezer->css.cgroup->parent)
@@ -60,6 +61,7 @@ int cgroup_freezing_or_frozen(struct task_struct *task)
 	else
 		state = freezer->state;
 	task_unlock(task);
+	rcu_read_unlock();
 
 	return (state == CGROUP_FREEZING) || (state == CGROUP_FROZEN);
 }
-- 
1.6.3
