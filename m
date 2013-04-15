From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 4/4] memcg: force use_hierarchy if sane_behavior
Date: Mon, 15 Apr 2013 13:40:16 -0700
Message-ID: <20130415204016.GA19531__4411.12269550121$1366058428$gmane$org@mtj.dyndns.org>
References: <1365808259-31073-1-git-send-email-tj@kernel.org>
	<1365808259-31073-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1365808259-31073-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Turn on use_hierarchy by default if sane_behavior is specified and
don't create .use_hierarchy file.

It is debatable whether to remove .use_hierarchy file or make it ro as
the former could make transition easier in certain cases; however, the
behavior changes which will be gated by sane_behavior are intensive
including changing basic meaning of certain control knobs in a few
controllers and I don't really think keeping this piece would make
things easier in any noticeable way, so let's remove it.

v2: Explain that mem_cgroup_bind() doesn't have to worry about
    children as suggested by Michal Hocko.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
Applying to cgroup/for-3.10.

Thanks!

 include/linux/cgroup.h |    3 +++
 mm/memcontrol.c        |   17 +++++++++++++++++
 2 files changed, 20 insertions(+)

--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -269,6 +269,9 @@ enum {
 	 *
 	 * - Remount is disallowed.
 	 *
+	 * - memcg: use_hierarchy is on by default and the cgroup file for
+	 *   the flag is not created.
+	 *
 	 * The followings are planned changes.
 	 *
 	 * - release_agent will be disallowed once replacement notification
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5814,6 +5814,7 @@ static struct cftype mem_cgroup_files[]
 	},
 	{
 		.name = "use_hierarchy",
+		.flags = CFTYPE_INSANE,
 		.write_u64 = mem_cgroup_hierarchy_write,
 		.read_u64 = mem_cgroup_hierarchy_read,
 	},
@@ -6784,6 +6785,21 @@ static void mem_cgroup_move_task(struct
 }
 #endif
 
+/*
+ * Cgroup retains root cgroups across [un]mount cycles making it necessary
+ * to verify sane_behavior flag on each mount attempt.
+ */
+static void mem_cgroup_bind(struct cgroup *root)
+{
+	/*
+	 * use_hierarchy is forced with sane_behavior.  cgroup core
+	 * guarantees that @root doesn't have any children, so turning it
+	 * on for the root memcg is enough.
+	 */
+	if (cgroup_sane_behavior(root))
+		mem_cgroup_from_cont(root)->use_hierarchy = true;
+}
+
 struct cgroup_subsys mem_cgroup_subsys = {
 	.name = "memory",
 	.subsys_id = mem_cgroup_subsys_id,
@@ -6794,6 +6810,7 @@ struct cgroup_subsys mem_cgroup_subsys =
 	.can_attach = mem_cgroup_can_attach,
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
+	.bind = mem_cgroup_bind,
 	.base_cftypes = mem_cgroup_files,
 	.early_init = 0,
 	.use_id = 1,
