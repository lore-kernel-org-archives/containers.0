From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] cgroup: deprecate remount option changes and "name=" mount
	option
Date: Wed, 14 Mar 2012 14:52:28 -0700
Message-ID: <20120314215228.GI7349__24343.6741097414$1331761961$gmane$org@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch removes the following features.

* Rebinding subsys by remount: Never reached useful state - only works
  on empty hierarchies.

* release_agent update by remount: release_agent itself will be
  replaced with conventional fsnotify notification.

* "name=" mount option: This has been broken for years before Li fixed
  it recently.  It has very marginal usefulness (plain bind mount can
  mostly replace it) and is quite unusual.  Take the chance and mark
  for deprecation.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
---
If you want these to survive, now is the time to scream. :)

Thanks.

 Documentation/feature-removal-schedule.txt |   12 ++++++++++++
 kernel/cgroup.c                            |   10 ++++++++++
 2 files changed, 22 insertions(+)

Index: work/Documentation/feature-removal-schedule.txt
===================================================================
--- work.orig/Documentation/feature-removal-schedule.txt
+++ work/Documentation/feature-removal-schedule.txt
@@ -510,3 +510,15 @@ Why:	The pci_scan_bus_parented() interfa
 	convert to using pci_scan_root_bus() so they can supply a list of
 	bus resources when the bus is created.
 Who:	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
+
+----------------------------
+
+What:	cgroup option updates via remount, and "name=" mount option
+When:	March 2013
+Why:	Remount currently allows changing bound subsystems and
+	release_agent.  Rebinding is hardly useful as it only works
+	when the hierarchy is empty and release_agent itself should be
+	replaced with conventional fsnotify.  "name=" option allows
+	mounting existing hierarchy by its name, which isn't useful
+	and has been broken for years without anyone noticing.
+Who:	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Index: work/kernel/cgroup.c
===================================================================
--- work.orig/kernel/cgroup.c
+++ work/kernel/cgroup.c
@@ -1146,6 +1146,11 @@ static int parse_cgroupfs_options(char *
 		}
 		if (!strncmp(token, "name=", 5)) {
 			const char *name = token + 5;
+
+			/* See feature-removal-schedule.txt */
+			pr_warning("cgroup: name= option is deprecated (pid=%d comm=%s name=%s)\n",
+				   task_tgid_nr(current), current->comm, name);
+
 			/* Can't specify an empty name */
 			if (!strlen(name))
 				return -EINVAL;
@@ -1294,6 +1299,11 @@ static int cgroup_remount(struct super_b
 	if (ret)
 		goto out_unlock;
 
+	/* See feature-removal-schedule.txt */
+	if (opts.subsys_bits != root->actual_subsys_bits || opts.release_agent)
+		pr_warning("cgroup: option changes via remount are deprecated (pid=%d comm=%s)\n",
+			   task_tgid_nr(current), current->comm);
+
 	/* Don't allow flags or name to change at remount */
 	if (opts.flags != root->flags ||
 	    (opts.name && strcmp(opts.name, root->name))) {
