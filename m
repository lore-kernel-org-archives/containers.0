From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup changes for 3.5-rc1
Date: Tue, 22 May 2012 10:34:50 -0700
Message-ID: <20120522173450.GG14339@google.com>
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

Please pull from the following branch to receive cgroup changes for
3.5-rc1.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.5

cgroup file type addition / removal is updated so that file types are
added and removed instead of individual files so that dynamic file
type addition / removal can be implemented by cgroup and used by
controllers.  blkio controller changes which will come through block
tree are dependent on this.  Other changes include res_counter cleanup
and disallowing kthread / PF_THREAD_BOUND threads to be attached to
non-root cgroups.

There's a reported bug with the file type addition / removal handling
which can lead to oops on cgroup umount.  The issue is being looked
into.  It shouldn't cause problems for most setups and isn't a
security concern.

Merging with mainline causes a conflict in
feature-removal-schedule.txt.  Simple append collision which can be
trivially resolved.

Thanks.

Frederic Weisbecker (2):
      res_counter: Merge res_counter_charge and res_counter_charge_nofail
      res_counter: Account max_usage when calling res_counter_charge_nofail()

Glauber Costa (2):
      cgroup: pass struct mem_cgroup instead of struct cgroup to socket memcg
      cgroup: get rid of populate for memcg

Mike Galbraith (1):
      cgroups: disallow attaching kthreadd or PF_THREAD_BOUND threads

Tejun Heo (16):
      cgroup: deprecate remount option changes
      cgroup: move cgroup_clear_directory() call out of cgroup_populate_dir()
      cgroup: build list of all cgroups under a given cgroupfs_root
      cgroup: implement cgroup_add_cftypes() and friends
      cgroup: merge cft_release_agent cftype array into the base files array
      cgroup: relocate cftype and cgroup_subsys definitions in controllers
      cgroup: convert all non-memcg controllers to the new cftype interface
      memcg: always create memsw files if CONFIG_CGROUP_MEM_RES_CTLR_SWAP
      cgroup: convert memcg controller to the new cftype interface
      cgroup: remove cgroup_add_file[s]()
      cgroup: relocate __d_cgrp() and __d_cft()
      cgroup: introduce struct cfent
      cgroup: implement cgroup_rm_cftypes()
      cgroup: use negative bias on css->refcnt to block css_tryget()
      cgroup: make css->refcnt clearing on cgroup removal optional
      cgroup: remove cgroup_subsys->populate()

 Documentation/cgroups/resource_counter.txt |    4 +-
 Documentation/feature-removal-schedule.txt |    9 +
 block/blk-cgroup.c                         |   45 +--
 include/linux/cgroup.h                     |   81 +++--
 include/linux/res_counter.h                |    2 +-
 include/net/sock.h                         |   12 +-
 include/net/tcp_memcontrol.h               |    4 +-
 kernel/cgroup.c                            |  564 +++++++++++++++++++++-------
 kernel/cgroup_freezer.c                    |   11 +-
 kernel/cpuset.c                            |   31 +-
 kernel/res_counter.c                       |   71 ++--
 kernel/sched/core.c                        |   16 +-
 mm/memcontrol.c                            |  115 +++---
 net/core/netprio_cgroup.c                  |   30 +-
 net/core/sock.c                            |   10 +-
 net/ipv4/tcp_memcontrol.c                  |   77 ++--
 net/sched/cls_cgroup.c                     |   31 +-
 security/device_cgroup.c                   |   10 +-
 18 files changed, 685 insertions(+), 438 deletions(-)

--
tejun
