From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cpuset changes for 3.9-rc1
Date: Tue, 19 Feb 2013 10:40:55 -0800
Message-ID: <20130219184055.GR17414@htj.dyndns.org>
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

This is cpuset changes for 3.9-rc1.

* Synchornization has seen a lot of changes with focus on decoupling
  cpuset synchronization from cgroup internal locking.  After this
  change, there only remain a couple of mostly trivial dependencies on
  cgroup_lock outside cgroup core proper.  cgroup_lock is scheduled to
  be unexported in this devel cycle.  This will finally remove the
  fragile locking order around cgroup (cgroup locking wants to /
  should be one of the outermost but yet has been acquired from deep
  inside individual controllers).

* At this point, Li is most knowlegeable with cpuset and taking over
  the maintainership of cpuset.

This depends on cgroup_rightmost_descendant() implemented in
cgroup/for-3.9 and this pull request assumes that cgroup/for-3.9 is
already pulled in.

The changes are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.9-cpuset

for you to fetch changes up to d127027baf98dce3ca31bec18c2c0e048ceda7c4:

  cpuset: drop spurious retval assignment in proc_cpuset_show() (2013-01-15 08:38:55 -0800)

----------------------------------------------------------------
Li Zefan (3):
      cpuset: update MAINTAINERS
      cpuset: fix RCU lockdep splat
      cpuset: drop spurious retval assignment in proc_cpuset_show()

Tejun Heo (15):
      cpuset: remove unused cpuset_unlock()
      cpuset: remove fast exit path from remove_tasks_in_empty_cpuset()
      cpuset: introduce ->css_on/offline()
      cpuset: introduce CS_ONLINE
      cpuset: introduce cpuset_for_each_child()
      cpuset: cleanup cpuset[_can]_attach()
      cpuset: reorganize CPU / memory hotplug handling
      cpuset: don't nest cgroup_mutex inside get_online_cpus()
      cpuset: drop async_rebuild_sched_domains()
      cpuset: make CPU / memory hotplug propagation asynchronous
      cpuset: pin down cpus and mems while a task is being attached
      cpuset: schedule hotplug propagation from cpuset_attach() if the cpuset is empty
      cpuset: replace cgroup_mutex locking with cpuset internal locking
      cpuset: replace cpuset->stack_list with cpuset_for_each_descendant_pre()
      cpuset: remove cpuset->parent

 MAINTAINERS     |   4 +-
 kernel/cpuset.c | 872 +++++++++++++++++++++++++++++++-------------------------
 2 files changed, 485 insertions(+), 391 deletions(-)

Thanks.

--
tejun
