From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup changes for v3.11-rc1
Date: Tue, 2 Jul 2013 08:38:17 -0700
Message-ID: <20130702153817.GA17986@mtj.dyndns.org>
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

Please note that cgroup/for-3.11 branch pulled in percpu/for-3.11 to
convert cgroup_subsys_state reference counting to percpu-ref and this
pull request assumes that percpu/for-3.11 is pulled in first.

This pull request contains the following changes.

* cgroup_subsys_state (css) reference counting has been converted to
  percpu-ref.  css is what each resource controller embeds into its
  own control structure and perform reference count against.  It may
  be used in hot paths of various subsystems and is similar to module
  refcnt in that aspect.  For example, block-cgroup's css refcnting
  was showing up a lot in Mikulaus's device-mapper scalability work
  and this should alleviate it.

* cgroup subtree iterator has been updated so that RCU read lock can
  be released after grabbing reference.  This allows simplifying its
  users which requires blocking which used to build iteration list
  under RCU read lock and then traverse it outside.  This pull request
  contains simplification of cgroup core and device-cgroup.  A
  separate pull request will update cpuset.

* Fixes for various bugs including corner race conditions and RCU
  usage bugs.

* A lot of cleanups and some prepartory work for the planned unified
  hierarchy support.

The changes are available in the following git branch

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.11

for you to fetch changes up to c7ba8287cd11f2fc9e2feee9e1fac34b7293658f:

  cgroup: CGRP_ROOT_SUBSYS_BOUND should also be ignored when mounting an existing hierarchy (2013-06-29 14:06:10 -0700)

Thanks.

----------------------------------------------------------------
Greg KH (1):
      cgroup.h: remove some functions that are now gone

Li Zefan (6):
      cgroup: fix umount vs cgroup_cfts_commit() race
      cgroup: fix umount vs cgroup_event_remove() race
      cgroup: fix memory leak in cgroup_rm_cftypes()
      cgroup: make serial_nr_cursor available throughout cgroup.c
      cgroup: convert cgroup_cft_commit() to use cgroup_for_each_descendant_pre()
      cgroup: rename cont to cgrp

Tejun Heo (43):
      cgroup: refactor hierarchy_id handling
      cgroup: drop hierarchy_id_lock
      cgroup: make hierarchy_id use cyclic idr
      cgroup: implement task_cgroup_path_from_hierarchy()
      Merge branch 'for-3.10-fixes' into for-3.11
      cgroup: make cgroup_is_removed() static
      cgroup: add cgroup->serial_nr and implement cgroup_next_sibling()
      cgroup: update iterators to use cgroup_next_sibling()
      device_cgroup: simplify cgroup tree walk in propagate_exception()
      cgroup: mark "tasks" cgroup file as insane
      cgroup: mark "notify_on_release" and "release_agent" cgroup files insane
      cgroup: clean up the cftype array for the base cgroup files
      cgroup: remove now unused css_depth()
      cgroup: consistently use @cset for struct css_set variables
      cgroup: bring some sanity to naming around cg_cgroup_link
      cgroup: use kzalloc() instead of kmalloc()
      cgroup: clean up css_[try]get() and css_put()
      cgroup: rename CGRP_REMOVED to CGRP_DEAD
      cgroup: drop unnecessary RCU dancing from __put_css_set()
      cgroup: remove cgroup->count and use
      cgroup: reorder the operations in cgroup_destroy_locked()
      cgroup: split cgroup destruction into two steps
      Merge branch 'for-3.11' of git://git.kernel.org/.../tj/percpu into for-3.11
      cgroup: use percpu refcnt for cgroup_subsys_states
      cgroup: update sane_behavior documentation
      cgroup: disallow rename(2) if sane_behavior
      cgroup: clean up cgroup_serial_nr_cursor
      cgroup: convert CFTYPE_* flags to enums
      cgroup: prefix global variables with "cgroup_"
      cgroup: remove cgroup->actual_subsys_mask
      cgroup: clean up find_css_set() and friends
      cgroup: s/for_each_subsys()/for_each_root_subsys()/
      cgroup: move init_css_set initialization inside cgroup_mutex
      cgroup: implement for_each_[builtin_]subsys()
      cgroup: reserve ID 0 for dummy_root and 1 for unified hierarchy
      cgroup: fix cgroupfs_root early destruction path
      cgroup: grab cgroup_mutex in drop_parsed_module_refcounts()
      cgroup: fix RCU accesses to task->cgroups
      cgroup: fix RCU accesses around task->cgroups
      cgroup: always use RCU accessors for protected accesses
      cgroup: fix deadlock on cgroup_mutex via drop_parsed_module_refcounts()
      cgroup: CGRP_ROOT_SUBSYS_BOUND should be ignored when comparing mount options
      cgroup: CGRP_ROOT_SUBSYS_BOUND should also be ignored when mounting an existing hierarchy

 include/linux/cgroup.h   |  222 ++++---
 kernel/cgroup.c          | 1536 ++++++++++++++++++++++++++--------------------
 security/device_cgroup.c |   56 +-
 3 files changed, 1029 insertions(+), 785 deletions(-)

-- 
tejun
