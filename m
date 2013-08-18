From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup fixes for v3.11-rc5
Date: Sun, 18 Aug 2013 07:20:05 -0400
Message-ID: <20130818112005.GD7093@htj.dyndns.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Linus.

This pull request contains one patch to fix the return value of
cpuset's cgroups interface function, which used to always return
-ENODEV for the writes on the "memory_pressure_enabled" file.

The fix is available in the following branch

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.11-fixes

for you to fetch changes up to a903f0865a190f8778c73df1a810ea6e25e5d7cf:

  cpuset: fix the return value of cpuset_write_u64() (2013-08-13 10:54:40 -0400)

Thanks.

----------------------------------------------------------------
Li Zefan (1):
      cpuset: fix the return value of cpuset_write_u64()

 kernel/cpuset.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index e565778..010a008 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1608,11 +1608,13 @@ static int cpuset_write_u64(struct cgroup *cgrp, struct cftype *cft, u64 val)
 {
 	struct cpuset *cs = cgroup_cs(cgrp);
 	cpuset_filetype_t type = cft->private;
-	int retval = -ENODEV;
+	int retval = 0;
 
 	mutex_lock(&cpuset_mutex);
-	if (!is_cpuset_online(cs))
+	if (!is_cpuset_online(cs)) {
+		retval = -ENODEV;
 		goto out_unlock;
+	}
 
 	switch (type) {
 	case FILE_CPU_EXCLUSIVE:

--
tejun
