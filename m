From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/12] netprio_cgroup: convert away from cftype->read_map()
Date: Wed, 27 Nov 2013 18:42:31 -0500
Message-ID: <1385595759-17656-5-git-send-email-tj__42111.004345543$1385595799$gmane$org@kernel.org>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385595759-17656-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

In preparation of conversion to kernfs, cgroup file handling is being
consolidated so that it can be easily mapped to the seq_file based
interface of kernfs.

cftype->read_map() doesn't add any value and being replaced with
->read_seq_string().  Update read_priomap() to use ->read_seq_string()
instead.

This patch doesn't make any visible behavior changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
---
 net/core/netprio_cgroup.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 9b7cf6c..498710d 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -174,13 +174,13 @@ static u64 read_prioidx(struct cgroup_subsys_state *css, struct cftype *cft)
 }
 
 static int read_priomap(struct cgroup_subsys_state *css, struct cftype *cft,
-			struct cgroup_map_cb *cb)
+			struct seq_file *sf)
 {
 	struct net_device *dev;
 
 	rcu_read_lock();
 	for_each_netdev_rcu(&init_net, dev)
-		cb->fill(cb, dev->name, netprio_prio(css, dev));
+		seq_printf(sf, "%s %u\n", dev->name, netprio_prio(css, dev));
 	rcu_read_unlock();
 	return 0;
 }
@@ -238,7 +238,7 @@ static struct cftype ss_files[] = {
 	},
 	{
 		.name = "ifpriomap",
-		.read_map = read_priomap,
+		.read_seq_string = read_priomap,
 		.write_string = write_priomap,
 	},
 	{ }	/* terminate */
-- 
1.8.4.2
