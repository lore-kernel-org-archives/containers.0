From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH 1/9 v3] cgroup: add cgroup_subsys->post_create()
Date: Fri, 09 Nov 2012 12:09:38 +0100
Message-ID: <509CE472.9040504__34743.5012147345$1352459743$gmane$org@monom.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-2-git-send-email-tj@kernel.org>
	<20121108190715.GD9672@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121108190715.GD9672-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Tejun,

On 08.11.2012 20:07, Tejun Heo wrote:> Subject: cgroup: add 
cgroup_subsys->post_create()
 >
 > Currently, there's no way for a controller to find out whether a new
 > cgroup finished all ->create() allocatinos successfully and is
 > considered "live" by cgroup.

I'd like add hierarchy support to net_prio and the first thing to
do is to get rid of get_prioidx(). It looks like it would be nice to be 
able to use use_id and post_create() for this but as I read the code 
this might not work because the netdev might access resources allocated 
between create() and post_create(). So my question is would it make 
sense to move

cgroup_create():

		if (ss->use_id) {
			err = alloc_css_id(ss, parent, cgrp);
			if (err)
				goto err_destroy;
		}

part before create() or add some protection between create() and 
post_create() callback in net_prio. I have a patch but I see
I could drop it completely if post_create() is there.

cheers,
daniel


 From 84fbbdf0dc5d3460389e39a00a3ee553ee55b563 Mon Sep 17 00:00:00 2001
From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Date: Thu, 8 Nov 2012 17:17:21 +0100
Subject: [PATCH] cgroups: net_prio: Use IDR library to assign netprio index

get_prioidx() allocated a new id whenever it was called. put_prioidx()
gave an id back. get_pioidx() could can reallocate the id later on.
So that is exactly what IDR offers and so let's use it.

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
---
  net/core/netprio_cgroup.c | 51 
+++++++++--------------------------------------
  1 file changed, 9 insertions(+), 42 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 847c02b..3c1b612 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -27,10 +27,7 @@

  #include <linux/fdtable.h>

-#define PRIOIDX_SZ 128
-
-static unsigned long prioidx_map[PRIOIDX_SZ];
-static DEFINE_SPINLOCK(prioidx_map_lock);
+static DEFINE_IDA(netprio_ida);
  static atomic_t max_prioidx = ATOMIC_INIT(0);

  static inline struct cgroup_netprio_state *cgrp_netprio_state(struct 
cgroup *cgrp)
@@ -39,34 +36,6 @@ static inline struct cgroup_netprio_state 
*cgrp_netprio_state(struct cgroup *cgr
  			    struct cgroup_netprio_state, css);
  }

-static int get_prioidx(u32 *prio)
-{
-	unsigned long flags;
-	u32 prioidx;
-
-	spin_lock_irqsave(&prioidx_map_lock, flags);
-	prioidx = find_first_zero_bit(prioidx_map, sizeof(unsigned long) * 
PRIOIDX_SZ);
-	if (prioidx == sizeof(unsigned long) * PRIOIDX_SZ) {
-		spin_unlock_irqrestore(&prioidx_map_lock, flags);
-		return -ENOSPC;
-	}
-	set_bit(prioidx, prioidx_map);
-	if (atomic_read(&max_prioidx) < prioidx)
-		atomic_set(&max_prioidx, prioidx);
-	spin_unlock_irqrestore(&prioidx_map_lock, flags);
-	*prio = prioidx;
-	return 0;
-}
-
-static void put_prioidx(u32 idx)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&prioidx_map_lock, flags);
-	clear_bit(idx, prioidx_map);
-	spin_unlock_irqrestore(&prioidx_map_lock, flags);
-}
-
  static int extend_netdev_table(struct net_device *dev, u32 new_len)
  {
  	size_t new_size = sizeof(struct netprio_map) +
@@ -120,9 +89,9 @@ static struct cgroup_subsys_state *cgrp_create(struct 
cgroup *cgrp)
  	if (cgrp->parent && cgrp_netprio_state(cgrp->parent)->prioidx)
  		goto out;

-	ret = get_prioidx(&cs->prioidx);
-	if (ret < 0) {
-		pr_warn("No space in priority index array\n");
+	cs->prioidx = ida_simple_get(&netprio_ida, 0, 0, GFP_KERNEL);
+	if (cs->prioidx < 0) {
+		ret = cs->prioidx;
  		goto out;
  	}

@@ -146,7 +115,7 @@ static void cgrp_destroy(struct cgroup *cgrp)
  			map->priomap[cs->prioidx] = 0;
  	}
  	rtnl_unlock();
-	put_prioidx(cs->prioidx);
+	ida_simple_remove(&netprio_ida, cs->prioidx);
  	kfree(cs);
  }

@@ -284,12 +253,10 @@ struct cgroup_subsys net_prio_subsys = {
  	.module		= THIS_MODULE,

  	/*
-	 * net_prio has artificial limit on the number of cgroups and
-	 * disallows nesting making it impossible to co-mount it with other
-	 * hierarchical subsystems.  Remove the artificially low PRIOIDX_SZ
-	 * limit and properly nest configuration such that children follow
-	 * their parents' configurations by default and are allowed to
-	 * override and remove the following.
+	 * net_prio has artificial limit on properly nest
+	 * configuration such that children follow their parents'
+	 * configurations by default and are allowed to override and
+	 * remove the following.
  	 */
  	.broken_hierarchy = true,
  };
-- 
1.7.11.7
