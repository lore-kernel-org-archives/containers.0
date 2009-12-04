From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [RFC] [PATCH 5/5] cgroups: subsystem dependencies
Date: Fri, 4 Dec 2009 03:58:54 -0500
Message-ID: <20091204085854.GE18912__2342.59736394069$1259917473$gmane$org@andrew.cmu.edu>
References: <20091204085349.GA18867@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: attachment;
	filename="cgroups-subsystem-dependencies.patch"
In-Reply-To: <20091204085349.GA18867-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org
List-Id: containers.vger.kernel.org

Adds support for cgroup subsystems to specify dependencies on other subsystems

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

This patch adds a mechanism with which a subsystem can specify dependencies on
other subsystems. Since subsystems can come and go, it would not be useful to
refer to a depended-upon subsystem by subsys_id, so instead a NULL-terminated
array of strings must be specified. Validation is done by scanning for each
potential subsystem its list of subsystem names with strcmp at the end of
parse_cgroupfs_options.

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
---

 Documentation/cgroups/cgroups.txt |    4 ++++
 include/linux/cgroup.h            |    8 ++++++++
 kernel/cgroup.c                   |   36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 48 insertions(+), 0 deletions(-)


diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 110228e..a8de651 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -458,6 +458,10 @@ Other fields in the cgroup_subsys object include:
 - name: should be initialized to a unique subsystem name. Should be
   no longer than MAX_CGROUP_TYPE_NAMELEN.
 
+- depends: allows subsystems to specify dependencies in the form of
+  a list (NULL-terminated) of names of other subsystems. A subsystem
+  cannot be mounted unless all of its dependencies are also mounted.
+
 - early_init: indicate if the subsystem needs early initialization
   at system boot.
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1cbb07f..6f77e30 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -457,6 +457,14 @@ struct cgroup_subsys {
 	bool use_id;
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
+	/*
+	 * A subsystem can specify dependencies in the form of a list of names
+	 * of other subsystems. Such a subsystem can only be mounted on a
+	 * hierarchy if all subsystems named in this list are also to be
+	 * mounted. If this list of strings is initialized, it must be null
+	 * terminated.
+	 */
+	const char **depends;
 
 	/*
 	 * Protects sibling/children links of cgroups in this
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c2c7681..5bbc45a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1015,6 +1015,38 @@ struct cgroup_sb_opts {
 };
 
 /*
+ * Given a mask of subsystems to be mounted, ensure all dependencies are met.
+ */
+static bool check_subsys_dependencies(unsigned long subsys_bits)
+{
+	unsigned long i, j, k;
+	bool matched;
+
+	for_each_bit(i, &subsys_bits, CGROUP_SUBSYS_COUNT) {
+		BUG_ON(!subsys[i]);
+		if (!subsys[i]->depends)
+			continue;
+		/* For each specified dependency, make sure there's a matching
+		 * subsystem among the ones intended for mounting. */
+		for (j = 0; subsys[i]->depends[j]; j++) {
+			matched = false;
+			for_each_bit(k, &subsys_bits, CGROUP_SUBSYS_COUNT) {
+				BUG_ON(!subsys[k]);
+				BUG_ON(!subsys[k]->name);
+				if (!strcmp(subsys[i]->depends[j],
+					    subsys[k]->name)) {
+					matched = true;
+					break;
+				}
+			}
+			if (!matched)
+				return false;
+		}
+	}
+	return true;
+}
+
+/*
  * Convert a hierarchy specifier into a bitmask of subsystems and flags. Call
  * with subsys_mutex held to guard subsys[] between us and rebind_subsystems.
  */
@@ -1123,6 +1155,10 @@ static int parse_cgroupfs_options(char *data,
 	if (!opts->subsys_bits && !opts->name)
 		return -EINVAL;
 
+	/* Check subsystem dependencies */
+	if (opts->subsys_bits && !check_subsys_dependencies(opts->subsys_bits))
+		return -ESRCH;
+
 	return 0;
 }
