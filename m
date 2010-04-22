From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 2/5] cgroup: Fix an RCU warning in alloc_css_id()
Date: Thu, 22 Apr 2010 17:30:00 +0800
Message-ID: <4BD01718.7020706@cn.fujitsu.com>
References: <4BD016F4.8060108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BD016F4.8060108@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: "containers@lists.osdl.org" <containers@lists.osdl.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, KameZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: containers.vger.kernel.org

With CONFIG_PROVE_RCU=y, a warning can be triggered:

  # mount -t cgroup -o memory xxx /mnt
  # mkdir /mnt/0

...
kernel/cgroup.c:4442 invoked rcu_dereference_check() without protection!
...

This is a false-positive. It's safe to directly access parent_css->id.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cgroup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4ca928d..3a53c77 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4561,13 +4561,13 @@ static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
 {
 	int subsys_id, i, depth = 0;
 	struct cgroup_subsys_state *parent_css, *child_css;
-	struct css_id *child_id, *parent_id = NULL;
+	struct css_id *child_id, *parent_id;
 
 	subsys_id = ss->subsys_id;
 	parent_css = parent->subsys[subsys_id];
 	child_css = child->subsys[subsys_id];
-	depth = css_depth(parent_css) + 1;
 	parent_id = parent_css->id;
+	depth = parent_id->depth;
 
 	child_id = get_new_cssid(ss, depth);
 	if (IS_ERR(child_id))
-- 
1.6.3
