From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup changes for v3.15-rc1
Date: Thu, 3 Apr 2014 12:49:11 -0400
Message-ID: <20140403164911.GE24119@htj.dyndns.org>
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

A lot updates for cgroup.

* The biggest one is cgroup's conversion to kernfs.  cgroup took after
  the long abandoned vfs-entangled sysfs implementation and made it
  even more convoluted over time.  cgroup's internal objects were
  fused with vfs objects which also brought in vfs locking and object
  lifetime rules.  Naturally, there are places where vfs rules don't
  fit and nasty hacks, such as credential switching or lock dance
  interleaving inode mutex and cgroup_mutex with object serial number
  comparison thrown in to decide whether the operation is actually
  necessary, needed to be employed.

  After conversion to kernfs, internal object lifetime and locking
  rules are mostly isolated from vfs interactions allowing shedding of
  several nasty hacks and overall simplification.  This will also
  allow implmentation of operations which may affect multiple cgroups
  which weren't possible before as it would have required nesting
  i_mutexes.

* Various simplifications including dropping of module support, easier
  cgroup name/path handling, simplified cgroup file type handling and
  task_cg_lists optimization.

* Prepatory changes for the planned unified hierarchy, which is still
  a patchset away from being actually operational.  The dummy
  hierarchy is updated to serve as the default unified hierarchy.
  Controllers which aren't claimed by other hierarchies are associated
  with it, which BTW was what the dummy hierarchy was for anyway.

* Various fixes from Li and others.  This pull request includes some
  patches to add missing slab.h to various subsystems.  This was
  triggered xattr.h include removal from cgroup.h.  cgroup.h
  indirectly got included a lot of files which brought in xattr.h
  which brought in slab.h.

There are several merge commits - one to pull in kernfs updates
necessary for converting cgroup (already in upstream through
driver-core), others for interfering changes in the fixes branch.

Pulling in this branch creates four conflicts - two detected during
merge and two silent.

C1. e61734c55c24 ("cgroup: remove cgroup->name") dropped a bunch of
    vars from mem_cgroup_print_oom_info and 08088cb9ac0a ("memcg:
    change oom_info_lock to mutex") changed one of them.  Can be
    combined by dropping what's dropped in the former and updating
    oom_info_lock according to the latter.

void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
{
<<<<<<< HEAD
	/*
	 * protects memcg_name and makes sure that parallel ooms do not
	 * interleave
	 */
	static DEFINE_MUTEX(oom_info_lock);
	struct cgroup *task_cgrp;
	struct cgroup *mem_cgrp;
	static char memcg_name[PATH_MAX];
	int ret;
=======
	/* oom_info_lock ensures that parallel ooms do not interleave */
	static DEFINE_SPINLOCK(oom_info_lock);
>>>>>>> 1ec41830e087cda1f62dda4182c2b62811eb0ffc
	struct mem_cgroup *iter;
	unsigned int i;

******* RESOLUTION *******

void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
{
	/* oom_info_lock ensures that parallel ooms do not interleave */
	static DEFINE_MUTEX(oom_info_lock);
	struct mem_cgroup *iter;
	unsigned int i;


C2. b8dadcb58d54 ("cpuset: use rcu_read_lock() to protect task_cs()")
    replaced task_lock() with rcu_read_lock() and 99afb0fd5f05
    ("cpuset: fix a race condition in
    __cpuset_node_allowed_softwall()") relocated a line into the
    locked region from after.  The resolution is straight-forward.

	rcu_read_lock();
	cs = nearest_hardwall_ancestor(task_cs(current));
<<<<<<< HEAD
	allowed = node_isset(node, cs->mems_allowed);
	task_unlock(current);
=======
	rcu_read_unlock();
>>>>>>> 1ec41830e087cda1f62dda4182c2b62811eb0ffc

	mutex_unlock(&callback_mutex);
	return allowed;

******* RESOLUTION *******

	rcu_read_lock();
	cs = nearest_hardwall_ancestor(task_cs(current));
	allowed = node_isset(node, cs->mems_allowed);
	rcu_read_unlock();

	mutex_unlock(&callback_mutex);
	return allowed;


C3. fed95bab8d29 ("sysfs: fix namespace refcnt leak") added an
    argument to kernfs_mount() and was routed through driver-core-next
    after cgroup pulled the tree.  cgroup's usage needs to be updated
    accordingly.


C4. 3eb59ec64fc7 ("cgroup: fix a failure path in create_css()") routed
    through cgroup/for-3.14-fixes added new usage of ss->subsys_id
    which was renamed to ss->id in the devel branch.  The new usage
    needs to be updated accordingly.


The following patch resolves C3 and C4.

index 432bdec..fede3d3 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1603,7 +1603,7 @@ out_unlock:
        if (ret)
                return ERR_PTR(ret);

-       dentry = kernfs_mount(fs_type, flags, root->kf_root);
+       dentry = kernfs_mount(fs_type, flags, root->kf_root, NULL);
        if (IS_ERR(dentry))
                cgroup_put(&root->cgrp);
        return dentry;
@@ -3654,7 +3654,7 @@ static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss)
        return 0;

 err_clear_dir:
-       cgroup_clear_dir(css->cgroup, 1 << css->ss->subsys_id);
+       cgroup_clear_dir(css->cgroup, 1 << css->ss->id);
 err_free_percpu_ref:
        percpu_ref_cancel_init(&css->refcnt);
 err_free_css:


Due to the intermediate merges, git-request-pull's diffstat didn't
match the changes made by pulling in the tree.  diffstat is generated
by comparing pre and post merge trees.  The test merge is available in
test-merge-3.15 branch.

The following changes since commit 532de3fc72adc2a6525c4d53c07bf81e1732083d:

  cgroup: update cgroup_enable_task_cg_lists() to grab siglock (2014-02-18 18:23:18 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.15

for you to fetch changes up to 1ec41830e087cda1f62dda4182c2b62811eb0ffc:

  cgroup: remove useless argument from cgroup_exit() (2014-03-29 09:15:54 -0400)

Thanks.

----------------------------------------------------------------
Fengguang Wu (1):
      cgroup: fix coccinelle warnings

Li Zefan (7):
      cgroup: fix locking in cgroupstats_build()
      cgroup: fix memory leak in cgroup_mount()
      cgroup: deal with dummp_top in cgroup_name() and cgroup_path()
      cgroup: add a validation check to cgroup_add_cftyps()
      cpuset: use rcu_read_lock() to protect task_cs()
      cgroup: fix spurious lockdep warning in cgroup_exit()
      cgroup: remove useless argument from cgroup_exit()

Monam Agarwal (1):
      cgroup: Use RCU_INIT_POINTER(x, NULL) in cgroup.c

Paul Gortmaker (1):
      sparc: fix implicit include of slab.h in leon_pci_grpci2.c

Stephen Rothwell (1):
      sun4M: add include of slab.h for kzalloc

Tejun Heo (67):
      cgroup: make CONFIG_CGROUP_NET_PRIO bool and drop unnecessary init_netclassid_cgroup()
      cgroup: drop module support
      cgroup: clean up cgroup_subsys names and initialization
      cgroup: rename cgroup_subsys->subsys_id to ->id
      cgroup: update locking in cgroup_show_options()
      cgroup: remove cgroup_root_mutex
      Merge branch 'for-3.14-fixes' into for-3.15
      Merge branch 'driver-core-next' into cgroup/for-3.15
      Merge branch 'cgroup/for-3.14-fixes' into cgroup/for-3.15
      cgroup: improve css_from_dir() into css_tryget_from_dir()
      cgroup: introduce cgroup_tree_mutex
      cgroup: release cgroup_mutex over file removals
      cgroup: restructure locking and error handling in cgroup_mount()
      cgroup: factor out cgroup_setup_root() from cgroup_mount()
      cgroup: update cgroup name handling
      cgroup: make cgroup_subsys->base_cftypes use cgroup_add_cftypes()
      cgroup: update the meaning of cftype->max_write_len
      cgroup: introduce cgroup_init/exit_cftypes()
      cgroup: introduce cgroup_ino()
      cgroup: misc preps for kernfs conversion
      cgroup: relocate functions in preparation of kernfs conversion
      cgroup: convert to kernfs
      cgroup: warn if "xattr" is specified with "sane_behavior"
      cgroup: relocate cgroup_rm_cftypes()
      cgroup: remove cftype_set
      cgroup: simplify dynamic cftype addition and removal
      cgroup: make cgroup hold onto its kernfs_node
      cgroup: remove cgroup->name
      cgroup: rename cgroupfs_root->number_of_cgroups to ->nr_cgrps and make it atomic_t
      cgroup: remove cgroupfs_root->refcnt
      cgroup: disallow xattr, release_agent and name if sane_behavior
      cgroup: drop CGRP_ROOT_SUBSYS_BOUND
      cgroup: enable task_cg_lists on the first cgroup mount
      cgroup: relocate cgroup_enable_task_cg_lists()
      cgroup: implement cgroup_has_tasks() and unexport cgroup_task_count()
      cgroup: reimplement cgroup_transfer_tasks() without using css_scan_tasks()
      cgroup: make css_set_lock a rwsem and rename it to css_set_rwsem
      cpuset: use css_task_iter_start/next/end() instead of css_scan_tasks()
      cgroup: remove css_scan_tasks()
      cgroup: separate out put_css_set_locked() and remove put_css_set_taskexit()
      cgroup: move css_set_rwsem locking outside of cgroup_task_migrate()
      cgroup: drop @skip_css from cgroup_taskset_for_each()
      cpuset: don't use cgroup_taskset_cur_css()
      cgroup: remove cgroup_taskset_cur_css() and cgroup_taskset_size()
      cgroup: cosmetic updates to cgroup_attach_task()
      cgroup: unexport functions
      Merge branch 'cgroup/for-3.14-fixes' into cgroup/for-3.15
      cgroup: add css_set->mg_tasks
      cgroup: use css_set->mg_tasks to track target tasks during migration
      cgroup: separate out cset_group_from_root() from task_cgroup_from_root()
      cgroup: split process / task migration into four steps
      cgroup: update how a newly forked task gets associated with css_set
      cgroup: drop task_lock() protection around task->cgroups
      cgroup: update cgroup_transfer_tasks() to either succeed or fail
      cgroup_freezer: document freezer_fork() subtleties
      cgroup: relocate setting of CGRP_DEAD
      cgroup: reorganize cgroup bootstrapping
      cgroup: use cgroup_setup_root() to initialize cgroup_dummy_root
      cgroup: remove NULL checks from [pr_cont_]cgroup_{name|path}()
      cgroup: treat cgroup_dummy_root as an equivalent hierarchy during rebinding
      cgroup: move ->subsys_mask from cgroupfs_root to cgroup
      cgroup: rename cgroup_dummy_root and related names
      cgroup: drop const from @buffer of cftype->write_string()
      cgroup: make cgrp_dfl_root mountable
      cgroup: implement CFTYPE_ONLY_ON_DFL
      cgroup: fix cgroup_taskset walking order
      cgroup: break kernfs active_ref protection in cgroup directory operations

 arch/sparc/kernel/leon_pci_grpci2.c |    1 
 arch/sparc/kernel/sun4m_irq.c       |    2 
 block/blk-cgroup.c                  |   11 
 block/blk-cgroup.h                  |   14 
 block/blk-throttle.c                |    8 
 block/cfq-iosched.c                 |    7 
 fs/bio.c                            |    2 
 fs/kernfs/dir.c                     |    1 
 include/linux/cgroup.h              |  275 +-
 include/linux/cgroup_subsys.h       |   30 
 include/linux/hugetlb_cgroup.h      |    2 
 include/linux/memcontrol.h          |    2 
 include/net/cls_cgroup.h            |    2 
 include/net/netprio_cgroup.h        |   17 
 init/Kconfig                        |    1 
 kernel/cgroup.c                     | 3721 ++++++++++++++----------------------
 kernel/cgroup_freezer.c             |   40 
 kernel/cpuset.c                     |  262 --
 kernel/events/core.c                |   25 
 kernel/exit.c                       |    2 
 kernel/fork.c                       |    5 
 kernel/sched/core.c                 |   10 
 kernel/sched/cpuacct.c              |    6 
 kernel/sched/debug.c                |    3 
 mm/hugetlb_cgroup.c                 |   11 
 mm/memcontrol.c                     |  110 -
 mm/memory-failure.c                 |    8 
 net/Kconfig                         |    2 
 net/core/netclassid_cgroup.c        |   15 
 net/core/netprio_cgroup.c           |   41 
 net/ipv4/tcp_memcontrol.c           |    4 
 security/device_cgroup.c            |   12 
 32 files changed, 1913 insertions(+), 2739 deletions(-)

--
tejun
