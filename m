From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [RFC] cgroup: deprecate clone_children
Date: Mon, 5 Nov 2012 10:02:13 -0800
Message-ID: <20121105180213.GB19354@mtj.dyndns.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-2-git-send-email-tj@kernel.org>
	<5097C23B.3040808@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5097C23B.3040808-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

clone_children makes cgroup invoke ->post_clone() callback if it
exists and sets CGRP_CLONE_CHILDREN.  ->post_clone(), while being
named generically, is only supposed to copy configuration from its
parent.

This is an entirely convenience feature which is only used by cpuset
to alter its configuration propagation.  As the mount option and
cgroupfs knobs are cgroup-wide and different controllers differ in
their configuration propagations, it's awkward to use for multiple
controllers especially if they're co-mounted.  At this point, we can't
use this flag for any other controller anyway as it would implicitly
change the behavior.

As this is unnecessary feature with very limited use and awkward in
co-mounted use cases, let's try to deprecate it.  Whine on the mount
option and accesses to cgroupfs knobs.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
---
Glauber, I think this is more befitting change for .post_clone().  If
people aren't depending on this, I'd much prefer to just remove it.

Thanks.

 kernel/cgroup.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1162,6 +1162,8 @@ static int parse_cgroupfs_options(char *
 			continue;
 		}
 		if (!strcmp(token, "clone_children")) {
+			pr_warning("cgroup: mount option clone_children is deprecated (pid=%d comm=%s)\n",
+				   task_tgid_nr(current), current->comm);
 			opts->clone_children = true;
 			continue;
 		}
@@ -3837,6 +3839,9 @@ fail:
 static u64 cgroup_clone_children_read(struct cgroup *cgrp,
 				    struct cftype *cft)
 {
+	printk_ratelimited(KERN_WARNING "cgroup: clone_children is deprecated (pid=%d comm=%s)\n",
+			   task_tgid_nr(current), current->comm);
+
 	return clone_children(cgrp);
 }
 
@@ -3844,6 +3849,9 @@ static int cgroup_clone_children_write(s
 				     struct cftype *cft,
 				     u64 val)
 {
+	printk_ratelimited(KERN_WARNING "cgroup: clone_children is deprecated (pid=%d comm=%s)\n",
+			   task_tgid_nr(current), current->comm);
+
 	if (val)
 		set_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
 	else
