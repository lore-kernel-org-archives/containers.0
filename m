From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup changes for v3.12-rc1
Date: Tue, 3 Sep 2013 18:48:07 -0400
Message-ID: <20130903224807.GB31091__12313.4754169316$1378248507$gmane$org@mtj.dyndns.org>
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

A lot of activities on the cgroup front.  Most changes aren't visible
to userland at all at this point and are laying foundation for the
planned unified hierarchy.

* The biggest change is decoupling the lifetime management of css
  (cgroup_subsys_state) from that of cgroup's.  Because controllers
  (cpu, memory, block and so on) will need to be dynamically enabled
  and disabled, css which is the association point between a cgroup
  and a controller may come and go dynamically across the lifetime of
  a cgroup.  Till now, css's were created when the associated cgroup
  was created and stayed till the cgroup got destroyed.

  Assumptions around this tight coupling permeated through cgroup core
  and controllers.  These assumptions are gradually removed, which
  consists bulk of patches, and css destruction path is completely
  decoupled from cgroup destruction path.  Note that decoupling of
  creation path is relatively easy on top of these changes and the
  patchset is pending for the next window.

* cgroup has its own event mechanism cgroup.event_control, which is
  only used by memcg.  It is overly complex trying to achieve high
  flexibility whose benefits seem dubious at best.  Going forward, new
  events will simply generate file modified event and the existing
  mechanism is being made specific to memcg.  This pull request
  contains prepatory patches for such change.

* Various fixes and cleanups.

Merging into master 2f01ea908b ("Merge tag 'tty-3.12-rc1' of
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty") generates
one conflict in kernel/cgroup.c.

	/*
<<<<<<< HEAD
	 * Make sure there's no live children.  We can't test ->children
	 * emptiness as dead children linger on it while being destroyed;
	 * otherwise, "rmdir parent/child parent" may fail with -EBUSY.
	 */
	empty = true;
	rcu_read_lock();
	list_for_each_entry_rcu(child, &cgrp->children, sibling) {
		empty = cgroup_is_dead(child);
		if (!empty)
			break;
	}
	rcu_read_unlock();
	if (!empty)
		return -EBUSY;

	/*
	 * Block new css_tryget() by killing css refcnts.  cgroup core
...
=======
	 * Initiate massacre of all css's.  cgroup_destroy_css_killed()
	 * will be invoked to perform the rest of destruction once the
	 * percpu refs of all css's are confirmed to be killed.
>>>>>>> d1625964da51bda61306ad3ec45307a799c21f08
	 */
	for_each_root_subsys(cgrp->root, ss)
		kill_css(cgroup_css(cgrp, ss));

This is the last minute fix bb78a92f47 ("cgroup: fix rmdir EBUSY
regression in 3.11") which was merged after v3.11-rc7 conflicting with
updates in for-3.12 and can be resolved by taking only the emptiness
check part from master.

	/*
	 * Make sure there's no live children.  We can't test ->children
	 * emptiness as dead children linger on it while being destroyed;
	 * otherwise, "rmdir parent/child parent" may fail with -EBUSY.
	 */
	empty = true;
	rcu_read_lock();
	list_for_each_entry_rcu(child, &cgrp->children, sibling) {
		empty = cgroup_is_dead(child);
		if (!empty)
			break;
	}
	rcu_read_unlock();
	if (!empty)
		return -EBUSY;

	/*
	 * Initiate massacre of all css's.  cgroup_destroy_css_killed()
	 * will be invoked to perform the rest of destruction once the
	 * percpu refs of all css's are confirmed to be killed.
	 */
	for_each_root_subsys(cgrp->root, ss)
		kill_css(cgroup_css(cgrp, ss));

Just in case, the following branch has an example merge.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git test-merge-3.12

I pulled for-3.11-fixes into for-3.12 once during the last devel cycle
and git-request-pull got confused when generating diffstat, so I
generated it manually by diffing master against test-merge-3.12.

Thanks.

The following changes since commit da0a12caffad2eeadea429f83818408e7b77379a:

  cgroup: fix a leak when percpu_ref_init() fails (2013-07-31 06:13:25 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.12

for you to fetch changes up to d1625964da51bda61306ad3ec45307a799c21f08:

  cgroup: fix cgroup_css() invocation in css_from_id() (2013-08-27 14:27:23 -0400)

----------------------------------------------------------------
Li Zefan (10):
      cgroup: remove sparse tags from offline_css()
      cgroup: remove struct cgroup_seqfile_state
      cgroup: more naming cleanups
      cgroup: convert cgroup_ida to cgroup_idr
      cgroup: document how cgroup IDs are assigned
      cgroup: implement cgroup_from_id()
      cgroup: restructure the failure path in cgroup_write_event_control()
      cgroup: rename cgroup_pidlist->mutex
      cpuset: remove an unncessary forward declaration
      cgroup: change cgroup_from_id() to css_from_id()

Li Zhong (1):
      cgroup: use css_get() in cgroup_create() to check CSS_ROOT

Tejun Heo (57):
      cgroup: minor updates around cgroup_clear_directory()
      cgroup: fix error path of cgroup_addrm_files()
      cgroup: fix cgroup_add_cftypes() error handling
      cgroup: separate out cgroup_base_files[] handling out of cgroup_populate/clear_dir()
      cgroup: update error handling in cgroup_populate_dir()
      cgroup: use for_each_subsys() instead of for_each_root_subsys() in cgroup_populate/clear_dir()
      cgroup: make rebind_subsystems() handle file additions and removals with proper error handling
      cgroup: move number_of_cgroups test out of rebind_subsystems() into cgroup_remount()
      cgroup: move module ref handling into rebind_subsystems()
      cgroup: remove gratuituous BUG_ON()s from rebind_subsystems()
      cgroup: Merge branch 'for-3.11-fixes' into for-3.12
      cgroup: s/cgroup_subsys_state/cgroup_css/ s/task_subsys_state/task_css/
      cpuset: drop "const" qualifiers from struct cpuset instances
      netprio_cgroup: pass around @css instead of @cgroup and kill struct cgroup_netprio_state
      hugetlb_cgroup: pass around @hugetlb_cgroup instead of @cgroup
      cgroup: add subsystem pointer to cgroup_subsys_state
      cgroup: add/update accessors which obtain subsys specific data from css
      cgroup: add css_parent()
      cgroup: pass around cgroup_subsys_state instead of cgroup in subsystem methods
      cgroup: add subsys backlink pointer to cftype
      cgroup: pin cgroup_subsys_state when opening a cgroupfs file
      cgroup: add cgroup->dummy_css
      cgroup: pass around cgroup_subsys_state instead of cgroup in file methods
      cgroup: convert cgroup_next_sibling() to cgroup_next_child()
      cgroup: always use cgroup_next_child() to walk the children list
      cgroup: make hierarchy iterators deal with cgroup_subsys_state instead of cgroup
      cgroup: relocate cgroup_advance_iter()
      cgroup: rename cgroup_iter to cgroup_task_iter
      cgroup: make cgroup_task_iter remember the cgroup being iterated
      cgroup: remove struct cgroup_scanner
      cgroup: make task iterators deal with cgroup_subsys_state instead of cgroup
      cgroup: make cftype->[un]register_event() deal with cgroup_subsys_state instead of cgroup
      cgroup: make cgroup_taskset deal with cgroup_subsys_state instead of cgroup
      cgroup: unexport cgroup_css()
      cgroup: make css_for_each_descendant() and friends include the origin css in the iteration
      cgroup: always use cgroup_css()
      cgroup: rename cgroup_subsys_state->dput_work and its callback function
      cgroup: add cgroup_subsys_state->parent
      cgroup: cgroup_css_from_dir() now should be called with RCU read locked
      cgroup: make cgroup_file_open() rcu_read_lock() around cgroup_css() and add cfent->css
      cgroup: add __rcu modifier to cgroup->subsys[]
      cgroup: reorganize css init / exit paths
      cgroup: move cgroup->subsys[] assignment to online_css()
      cgroup: bounce cgroup_subsys_state ref kill confirmation to a work item
      cgroup: replace cgroup->css_kill_cnt with ->nr_css
      cgroup: decouple cgroup_subsys_state destruction from cgroup destruction
      cgroup: factor out kill_css()
      cgroup: move subsys file removal to kill_css()
      cgroup: RCU protect each cgroup_subsys_state release
      cgroup: fix subsystem file accesses on the root cgroup
      cgroup: fix cgroup_write_event_control()
      cgroup: rename cgroup_css_from_dir() to css_from_dir() and update its syntax
      cgroup: make cgroup_css() take cgroup_subsys * instead and allow NULL subsys
      cgroup: implement CFTYPE_NO_PREFIX
      cgroup: make cgroup_event hold onto cgroup_subsys_state instead of cgroup
      cgroup: make cgroup_write_event_control() use css_from_dir() instead of __d_cgrp()
      cgroup: fix cgroup_css() invocation in css_from_id()

Zhao Hongjiang (2):
      cpuset: get rid of the useless forward declaration of cpuset
      cpuset: relocate a misplaced comment

 block/blk-cgroup.c           |   49 -
 block/blk-cgroup.h           |   38 
 block/blk-throttle.c         |   43 -
 block/cfq-iosched.c          |   90 +-
 fs/bio.c                     |    2 
 include/linux/cgroup.h       |  303 ++++---
 include/linux/memcontrol.h   |    2 
 include/linux/vmpressure.h   |    6 
 include/net/cls_cgroup.h     |    4 
 include/net/netprio_cgroup.h |    8 
 kernel/cgroup.c              | 1643 ++++++++++++++++++++++++-------------------
 kernel/cgroup_freezer.c      |  155 ++--
 kernel/cpuset.c              |  317 ++++----
 kernel/events/core.c         |   27 
 kernel/sched/core.c          |  113 +-
 kernel/sched/cpuacct.c       |   51 -
 kernel/sched/sched.h         |    6 
 mm/hugetlb_cgroup.c          |   69 -
 mm/memcontrol.c              |  223 ++---
 mm/vmpressure.c              |   25 
 net/core/netprio_cgroup.c    |   72 -
 net/ipv4/tcp_memcontrol.c    |   12 
 net/sched/cls_cgroup.c       |   39 -
 security/device_cgroup.c     |   65 -
 24 files changed, 1751 insertions(+), 1611 deletions(-)

-- 
tejun
