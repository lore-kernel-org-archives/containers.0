From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: don't change release_agent when remount failed
Date: Wed, 04 Mar 2009 10:17:20 +0800
Message-ID: <49ADE4B0.5090405__13681.1562268578$1236133114$gmane$org@cn.fujitsu.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Remount can fail in either case:
  - wrong mount options is specified, or option 'noprefix' is changed.
  - a to-be-added subsys is already mounted/active.

When using remount to change 'release_agent', for the above former failure
case, remount will return errno with release_agent unchanged, but for the
latter case, remount will return EBUSY with relase_agent changed, which is
unexpected I think:

 # mount -t cgroup -o cpu xxx /cgrp1
 # mount -t cgroup -o cpuset,release_agent=agent1 yyy /cgrp2
 # cat /cgrp2/release_agent
 agent1
 # mount -t cgroup -o remount,cpuset,noprefix,release_agent=agent2 yyy /cgrp2
 mount: /cgrp2 not mounted already, or bad option
 # cat /cgrp2/release_agent
 agent1     <-- ok
 # mount -t cgroup -o remount,cpu,cpuset,release_agent=agent2 yyy /cgrp2
 mount: /cgrp2 is busy
 # cat /cgrp2/release_agent
 agent2     <-- unexpected!

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ad10c5d..ebb4a4e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -915,10 +915,11 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	}
 
 	ret = rebind_subsystems(root, opts.subsys_bits);
+	if (ret)
+		goto out_unlock;
 
 	/* (re)populate subsystem files */
-	if (!ret)
-		cgroup_populate_dir(cgrp);
+	cgroup_populate_dir(cgrp);
 
 	if (opts.release_agent)
 		strcpy(root->release_agent_path, opts.release_agent);
-- 
1.5.4.rc3
