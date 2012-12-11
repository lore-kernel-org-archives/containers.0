From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup changes for v3.8
Date: Tue, 11 Dec 2012 07:35:58 -0800
Message-ID: <20121211153558.GI7084@htj.dyndns.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Linus.

A lot of activities on cgroup side.  The big changes are focused on
making cgroup hierarchy handling saner.

* cgroup_rmdir() had peculiar semantics - it allowed cgroup
  destruction to be vetoed by individual controllers and tried to
  drain refcnt synchronously.  The vetoing never worked properly and
  caused good deal of contortions in cgroup.  memcg was the last
  reamining user.  Michal Hocko removed the usage and cgroup_rmdir()
  path has been simplified significantly.  This was done in a separate
  branch so that the memcg people can base further memcg changes on
  top.

* The above allowed cleaning up cgroup lifecycle management and
  implementation of generic cgroup iterators which are used to improve
  hierarchy support.

* cgroup_freezer updated to allow migration in and out of a frozen
  cgroup and handle hierarchy.  If a cgroup is frozen, all descendant
  cgroups are frozen.

* netcls_cgroup and netprio_cgroup updated to handle hierarchy
  properly.

* Various fixes and cleanups.

* Two merge commits.  One to pull in memcg and rmdir cleanups (needed
  to build iterators).  The other pulled in cgroup/for-3.7-fixes for
  device_cgroup fixes so that further device_cgroup patches can be
  stacked on top.

Please pull from the following branch to receive the above changes.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.8

Pulling will generate the following conflict in mm/memcontrol.c.

  static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
				  int node, int zid, enum lru_list lru)
  {
  <<<<<<< HEAD
	  struct lruvec *lruvec;
	  unsigned long flags, loop;
  =======
	  struct mem_cgroup_per_zone *mz;
	  unsigned long flags;
  >>>>>>> 15ef4ffaa797034d5ff82844daf8f595d7c6d53c
	  struct list_head *list;
	  struct page *busy;
	  struct zone *zone;

	  zone = &NODE_DATA(node)->node_zones[zid];
	  lruvec = mem_cgroup_zone_lruvec(zone, memcg);
	  list = &lruvec->lists[lru];

  <<<<<<< HEAD
	  loop = mem_cgroup_get_lru_size(lruvec, lru);
	  /* give some margin against EBUSY etc...*/
	  loop += 256;
  =======
  >>>>>>> 15ef4ffaa797034d5ff82844daf8f595d7c6d53c
	  busy = NULL;
	  do {

This is caused by the following two commits.

* bea8c150a7 ("memcg: fix hotplugged memory zone oops") in master
* 2ef37d3fe4 ("memcg: Simplify mem_cgroup_force_empty_list error
  handling") in for-3.8

The former changed how @lruvec is determined in
mem_cgroup_force_empty_list() and the latter removed looping limit in
the function.  The conflicts are in local variable decls and loop
limit calculation.  This can be resolved by removing @loop handling
from the former.

  static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
				  int node, int zid, enum lru_list lru)
  {
	  struct lruvec *lruvec;
	  unsigned long flags;
	  struct list_head *list;
	  struct page *busy;
	  struct zone *zone;

	  zone = &NODE_DATA(node)->node_zones[zid];
	  lruvec = mem_cgroup_zone_lruvec(zone, memcg);
	  list = &lruvec->lists[lru];

	  busy = NULL;
	  do {

Just in case, the merged branch is available at

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.8-test-merge

Thanks.

----------------------------------------------------------------
Gao feng (3):
      cgroup: use cgroup_addrm_files() in cgroup_clear_directory()
      cgroup: remove subsystem files when remounting cgroup
      cgroup_rm_file: don't delete the uncreated files

Glauber Costa (1):
      cgroup: warn about broken hierarchies only after css_online

Greg Thelen (2):
      cgroup: fix lockdep warning for event_control
      cgroup: list_del_init() on removed events

Li Zhong (1):
      cgroup: move list add after list head initilization

Michal Hocko (5):
      memcg: split mem_cgroup_force_empty into reclaiming and reparenting parts
      memcg: root_cgroup cannot reach mem_cgroup_move_parent
      memcg: Simplify mem_cgroup_force_empty_list error handling
      memcg: make mem_cgroup_reparent_charges non failing
      hugetlb: do not fail in hugetlb_cgroup_pre_destroy

Namjae Jeon (1):
      cgroup: update Documentation/cgroups/00-INDEX

Oleg Nesterov (1):
      freezer: change ptrace_stop/do_signal_stop to use freezable_schedule()

Tao Ma (2):
      cgroup: set 'start' with the right value in cgroup_path.
      cgroup: remove obsolete guarantee from cgroup_task_migrate.

Tejun Heo (51):
      cgroup: cgroup_subsys->fork() should be called after the task is added to css_set
      freezer: add missing mb's to freezer_count() and freezer_should_skip()
      cgroup_freezer: make it official that writes to freezer.state don't fail
      cgroup_freezer: don't stall transition to FROZEN for PF_NOFREEZE or PF_FREEZER_SKIP tasks
      cgroup_freezer: allow moving tasks in and out of a frozen cgroup
      cgroup_freezer: prepare update_if_frozen() for locking change
      cgroup_freezer: don't use cgroup_lock_live_group()
      cgroup: kill cgroup_subsys->__DEPRECATED_clear_css_refs
      cgroup: kill CSS_REMOVED
      cgroup: use cgroup_lock_live_group(parent) in cgroup_create()
      cgroup: deactivate CSS's and mark cgroup dead before invoking ->pre_destroy()
      cgroup: remove CGRP_WAIT_ON_RMDIR, cgroup_exclude_rmdir() and cgroup_release_and_wakeup_rmdir()
      cgroup: make ->pre_destroy() return void
      Merge branch 'cgroup-rmdir-updates' into cgroup/for-3.8
      Merge branch 'cgroup/for-3.7-fixes' into cgroup/for-3.8
      device_cgroup: add lockdep asserts
      cgroup: add cgroup_subsys->post_create()
      cgroup: use rculist ops for cgroup->children
      cgroup: implement generic child / descendant walk macros
      cgroup_freezer: trivial cleanups
      cgroup_freezer: prepare freezer_change_state() for full hierarchy support
      cgroup_freezer: make freezer->state mask of flags
      cgroup_freezer: introduce CGROUP_FREEZING_[SELF|PARENT]
      cgroup_freezer: add ->post_create() and ->pre_destroy() and track online state
      cgroup_freezer: implement proper hierarchy support
      cgroup: remove incorrect dget/dput() pair in cgroup_create_dir()
      cgroup: initialize cgrp->allcg_node in init_cgroup_housekeeping()
      cgroup: open-code cgroup_create_dir()
      cgroup: create directory before linking while creating a new cgroup
      cgroup: cgroup->dentry isn't a RCU pointer
      cgroup: make CSS_* flags bit masks instead of bit positions
      cgroup: trivial cleanup for cgroup_init/load_subsys()
      cgroup: lock cgroup_mutex in cgroup_init_subsys()
      cgroup: fix harmless bugs in cgroup_load_subsys() fail path and cgroup_unload_subsys()
      cgroup: separate out cgroup_destroy_locked()
      cgroup: introduce CSS_ONLINE flag and on/offline_css() helpers
      cgroup: simplify cgroup_load_subsys() failure path
      cgroup: use mutex_trylock() when grabbing i_mutex of a new cgroup directory
      cgroup: update cgroup_create() failure path
      cgroup: allow ->post_create() to fail
      cgroup: rename ->create/post_create/pre_destroy/destroy() to ->css_alloc/online/offline/free()
      cgroup: s/CGRP_CLONE_CHILDREN/CGRP_CPUSET_CLONE_CHILDREN/
      cgroup, cpuset: remove cgroup_subsys->post_clone()
      cgroup: add cgroup->id
      netcls_cgroup: move config inheritance to ->css_online() and remove .broken_hierarchy marking
      netprio_cgroup: simplify write_priomap()
      netprio_cgroup: shorten variable names in extend_netdev_table()
      netprio_cgroup: reimplement priomap expansion
      netprio_cgroup: use cgroup->id instead of cgroup_netprio_state->prioidx
      netprio_cgroup: implement netprio[_set]_prio() helpers
      netprio_cgroup: allow nesting and inherit config on cgroup creation

 Documentation/cgroups/00-INDEX              |   8 +
 Documentation/cgroups/cgroups.txt           |  61 ++-
 Documentation/cgroups/freezer-subsystem.txt |  63 ++-
 Documentation/cgroups/net_prio.txt          |   2 +
 block/blk-cgroup.c                          |  15 +-
 include/linux/cgroup.h                      | 167 ++++--
 include/linux/freezer.h                     |  57 ++-
 include/net/netprio_cgroup.h                |  11 +-
 kernel/cgroup.c                             | 754 ++++++++++++++--------------
 kernel/cgroup_freezer.c                     | 514 +++++++++++--------
 kernel/cpuset.c                             |  90 ++--
 kernel/events/core.c                        |   8 +-
 kernel/fork.c                               |   9 +-
 kernel/freezer.c                            |  11 +-
 kernel/power/process.c                      |  13 +-
 kernel/sched/core.c                         |  16 +-
 kernel/signal.c                             |  20 +-
 mm/hugetlb_cgroup.c                         |  23 +-
 mm/memcontrol.c                             | 191 +++----
 net/core/netprio_cgroup.c                   | 260 +++++-----
 net/sched/cls_cgroup.c                      |  28 +-
 security/device_cgroup.c                    |  20 +-
 22 files changed, 1255 insertions(+), 1086 deletions(-)

--
tejun
