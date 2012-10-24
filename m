From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup fixes for v3.7-rc2
Date: Wed, 24 Oct 2012 12:54:41 -0700
Message-ID: <20121024195441.GI12182@atj.dyndns.org>
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

This pull request contains three fixes.  Two are reverts of
task_lock() removal in cgroup fork path.  The optimizations
incorrectly assumed that threadgroup_lock can protect process forks
(as opposed to thread creations) too.  Further cleanup of cgroup fork
path is scheduled.  The third fixes cgroup emptiness notification
loss.

Please pull from the following git branch to receive the above
changes.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.7-fixes

for you to fetch changes up to d87838321124061f6c935069d97f37010fa417e6:

  Revert "cgroup: Remove task_lock() from cgroup_post_fork()" (2012-10-19 14:09:35 -0700)

----------------------------------------------------------------
Daisuke Nishimura (1):
      cgroup: notify_on_release may not be triggered in some cases

Tejun Heo (2):
      Revert "cgroup: Drop task_lock(parent) on cgroup_fork()"
      Revert "cgroup: Remove task_lock() from cgroup_post_fork()"

 kernel/cgroup.c | 41 ++++++++++-------------------------------
 1 file changed, 10 insertions(+), 31 deletions(-)

Thanks.

--
tejun
