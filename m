From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/10] cgroup: merge cft_release_agent cftype array into the
	base files array
Date: Fri, 16 Mar 2012 16:35:57 -0700
Message-ID: <1331940963-15756-5-git-send-email-tj@kernel.org>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1331940963-15756-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Now that cftype can express whether a file should only be on root,
cft_release_agent can be merged into the base files cftypes array.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2b1a209..6c396f3 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3748,13 +3748,13 @@ static struct cftype files[] = {
 		.read_u64 = cgroup_clone_children_read,
 		.write_u64 = cgroup_clone_children_write,
 	},
-};
-
-static struct cftype cft_release_agent = {
-	.name = "release_agent",
-	.read_seq_string = cgroup_release_agent_show,
-	.write_string = cgroup_release_agent_write,
-	.max_write_len = PATH_MAX,
+	{
+		.name = "release_agent",
+		.flags = CFTYPE_ONLY_ON_ROOT,
+		.read_seq_string = cgroup_release_agent_show,
+		.write_string = cgroup_release_agent_write,
+		.max_write_len = PATH_MAX,
+	},
 };
 
 static int cgroup_populate_dir(struct cgroup *cgrp)
@@ -3766,11 +3766,6 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
 	if (err < 0)
 		return err;
 
-	if (cgrp == cgrp->top_cgroup) {
-		if ((err = cgroup_add_file(cgrp, NULL, &cft_release_agent)) < 0)
-			return err;
-	}
-
 	/* process cftsets of each subsystem */
 	for_each_subsys(cgrp->root, ss) {
 		struct cftype_set *set;
-- 
1.7.7.3
