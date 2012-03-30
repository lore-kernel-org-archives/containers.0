From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup: urgent fix for 3.4-rc1 merge window
Date: Thu, 29 Mar 2012 22:26:12 -0700
Message-ID: <20120330052612.GA13855@dhcp-172-17-108-109.mtv.corp.google.com>
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
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Linus.

61d1d219c4 "cgroup: remove extra calls to find_existing_css_set" which
was part of the rc1 cgroup pull request made writes to cgroup "tasks"
file return uninitialized retval on success which can cause boot
failures with systemd.  The change stayed in linux-next for quite some
time but gcc interestingly failed to emit warning about using
uninitialized variable and the problem seems to materialize only for
certain build combinations (probably depends on register allocation).

It's just missing local variable initialization and the fix is trivial
& safe.  As the problem is critical when it materializes, I'm
fast-tracking it.  Also included is Li's email address change in
MAINTAINERS.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.4-fixes

Li Zefan (1):
      cgroup: update MAINTAINERS entry

Tejun Heo (1):
      cgroup: cgroup_attach_task() could return -errno after success

Thanks.
---
 MAINTAINERS     |    2 +-
 kernel/cgroup.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index f9faade..3dbf4d1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1940,7 +1940,7 @@ F:	drivers/connector/
 
 CONTROL GROUPS (CGROUPS)
 M:	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
-M:	Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
+M:	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
 L:	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
 L:	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f4ea4b6..ed64cca 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1883,7 +1883,7 @@ static void cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
  */
 int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 {
-	int retval;
+	int retval = 0;
 	struct cgroup_subsys *ss, *failed_ss = NULL;
 	struct cgroup *oldcgrp;
 	struct cgroupfs_root *root = cgrp->root;

--
tejun
