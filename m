From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: forbid noprefix if mounting more than just cpuset
	subsystem
Date: Tue, 02 Jun 2009 10:40:31 +0800
Message-ID: <4A24911F.4070601__2944.97104264355$1243910398$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

The 'noprefix' option was introduced for backwards-compatibility of
cpuset, but actually it can be used when mounting other subsystems.

This results in possibility of name collision, and now the collision
can really happen, because we have 'stat' file in both memory and
cpuacct subsystem:

	# mount -t cgroup -o noprefix,memory,cpuacct xxx /mnt

Cgroup will happily mount the 2 subsystems, but only 'stat' file of
memory subsys can be seen.

We don't want users to use nopreifx, and also want to avoid name
collision, so we change to allow noprefix only if mounting just
the cpuset subsystem.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a7267bf..ad17f9d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -842,6 +842,11 @@ static int parse_cgroupfs_options(char *data,
 				     struct cgroup_sb_opts *opts)
 {
 	char *token, *o = data ?: "all";
+	unsigned long mask = (unsigned long)-1;
+
+#ifdef CONFIG_CPUSETS
+	mask = ~(1 << cpuset_subsys_id);
+#endif
 
 	opts->subsys_bits = 0;
 	opts->flags = 0;
@@ -886,6 +891,11 @@ static int parse_cgroupfs_options(char *data,
 		}
 	}
 
+	/* We allow noprefix only if mounting just the cpuset subsystem */
+	if (test_bit(ROOT_NOPREFIX, &opts->flags) &&
+	    (opts->subsys_bits & mask))
+		return -EINVAL;
+
 	/* We can't have an empty hierarchy */
 	if (!opts->subsys_bits)
 		return -EINVAL;
-- 
1.5.4.rc3
