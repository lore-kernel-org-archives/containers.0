From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH cgroup/for-3.11 3/3] cgroup: clean up the cftype array for
	the base cgroup files
Date: Mon, 3 Jun 2013 19:14:34 -0700
Message-ID: <20130604021434.GJ29989@mtj.dyndns.org>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604021355.GI29989@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130604021355.GI29989-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

* Rename it from files[] (really?) to cgroup_base_files[].

* Drop CGROUP_FILE_GENERIC_PREFIX which was defined as "cgroup." and
  used inconsistently.  Just use "cgroup." directly.

* Collect insane files at the end.  Note that only the insane ones are
  missing "cgroup." prefix.

This patch doesn't introduce any functional changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c |   47 ++++++++++++++++++++++++-----------------------
 1 file changed, 24 insertions(+), 23 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4029,35 +4029,16 @@ static int cgroup_clone_children_write(s
 	return 0;
 }
 
-/*
- * for the common functions, 'private' gives the type of file
- */
-/* for hysterical raisins, we can't put this on the older files */
-#define CGROUP_FILE_GENERIC_PREFIX "cgroup."
-static struct cftype files[] = {
+static struct cftype cgroup_base_files[] = {
 	{
-		.name = "tasks",
-		.flags = CFTYPE_INSANE,		/* use "procs" instead */
-		.open = cgroup_tasks_open,
-		.write_u64 = cgroup_tasks_write,
-		.release = cgroup_pidlist_release,
-		.mode = S_IRUGO | S_IWUSR,
-	},
-	{
-		.name = CGROUP_FILE_GENERIC_PREFIX "procs",
+		.name = "cgroup.procs",
 		.open = cgroup_procs_open,
 		.write_u64 = cgroup_procs_write,
 		.release = cgroup_pidlist_release,
 		.mode = S_IRUGO | S_IWUSR,
 	},
 	{
-		.name = "notify_on_release",
-		.flags = CFTYPE_INSANE,
-		.read_u64 = cgroup_read_notify_on_release,
-		.write_u64 = cgroup_write_notify_on_release,
-	},
-	{
-		.name = CGROUP_FILE_GENERIC_PREFIX "event_control",
+		.name = "cgroup.event_control",
 		.write_string = cgroup_write_event_control,
 		.mode = S_IWUGO,
 	},
@@ -4072,6 +4053,26 @@ static struct cftype files[] = {
 		.flags = CFTYPE_ONLY_ON_ROOT,
 		.read_seq_string = cgroup_sane_behavior_show,
 	},
+
+	/*
+	 * Historical crazy stuff.  These don't have "cgroup."  prefix and
+	 * don't exist if sane_behavior.  If you're depending on these, be
+	 * prepared to be burned.
+	 */
+	{
+		.name = "tasks",
+		.flags = CFTYPE_INSANE,		/* use "procs" instead */
+		.open = cgroup_tasks_open,
+		.write_u64 = cgroup_tasks_write,
+		.release = cgroup_pidlist_release,
+		.mode = S_IRUGO | S_IWUSR,
+	},
+	{
+		.name = "notify_on_release",
+		.flags = CFTYPE_INSANE,
+		.read_u64 = cgroup_read_notify_on_release,
+		.write_u64 = cgroup_write_notify_on_release,
+	},
 	{
 		.name = "release_agent",
 		.flags = CFTYPE_INSANE | CFTYPE_ONLY_ON_ROOT,
@@ -4095,7 +4096,7 @@ static int cgroup_populate_dir(struct cg
 	struct cgroup_subsys *ss;
 
 	if (base_files) {
-		err = cgroup_addrm_files(cgrp, NULL, files, true);
+		err = cgroup_addrm_files(cgrp, NULL, cgroup_base_files, true);
 		if (err < 0)
 			return err;
 	}
