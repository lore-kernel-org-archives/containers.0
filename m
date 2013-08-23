From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL RESEND] cgroup fixes for v3.11-rc6
Date: Fri, 23 Aug 2013 11:51:15 -0400
Message-ID: <20130823155115.GF3277__2422.58407311073$1377273092$gmane$org@htj.dyndns.org>
References: <20130823154813.GE3277@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130823154813.GE3277-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

(forgot to cc lkml, resending, no content change)

Hello, Linus.

A late fix for cgroup.  This fixes a behavior regression visible to
userland which was created by a commit merged during -rc1.  While the
behavior change isn't too likely to be noticeable, the fix is
relatively low risk and we'll need to backport it through -stable
anyway if the bug gets released.

The fix is available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.11-fixes

for you to fetch changes up to 1c09b195d37fa459844036f429a0f378e70c3db6:

  cpuset: fix a regression in validating config change (2013-08-21 08:40:27 -0400)

Thanks.

----------------------------------------------------------------
Li Zefan (1):
      cpuset: fix a regression in validating config change

 kernel/cpuset.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 010a008..ea1966d 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -475,13 +475,17 @@ static int validate_change(const struct cpuset *cur, const struct cpuset *trial)
 
 	/*
 	 * Cpusets with tasks - existing or newly being attached - can't
-	 * have empty cpus_allowed or mems_allowed.
+	 * be changed to have empty cpus_allowed or mems_allowed.
 	 */
 	ret = -ENOSPC;
-	if ((cgroup_task_count(cur->css.cgroup) || cur->attach_in_progress) &&
-	    (cpumask_empty(trial->cpus_allowed) &&
-	     nodes_empty(trial->mems_allowed)))
-		goto out;
+	if ((cgroup_task_count(cur->css.cgroup) || cur->attach_in_progress)) {
+		if (!cpumask_empty(cur->cpus_allowed) &&
+		    cpumask_empty(trial->cpus_allowed))
+			goto out;
+		if (!nodes_empty(cur->mems_allowed) &&
+		    nodes_empty(trial->mems_allowed))
+			goto out;
+	}
 
 	ret = 0;
 out:

--
tejun
