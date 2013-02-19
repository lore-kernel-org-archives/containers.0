From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup changes for 3.9-rc1
Date: Tue, 19 Feb 2013 10:32:53 -0800
Message-ID: <20130219183253.GQ17414__31042.2963033945$1361298810$gmane$org@htj.dyndns.org>
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

These are cgroup changes for 3.9-rc1.  Nothing too drastic.

* Removal of synchronize_rcu() from userland visible paths.

* Various fixes and cleanups from Li.

* cgroup_rightmost_descendant() added which will be used by cpuset
  changes (it will be a separate pull request).

The changes are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.9

for you to fetch changes up to f169007b2773f285e098cb84c74aac0154d65ff7:

  cgroup: fail if monitored file and event_control are in different cgroup (2013-02-18 09:31:35 -0800)

----------------------------------------------------------------
Greg Thelen (2):
      cgroups: move cgroup_event_listener.c to tools/cgroup
      cgroups: fix cgroup_event_listener error handling

Li Zefan (15):
      cgroup: use new hashtable implementation
      cgroup: remove synchronize_rcu() from cgroup_attach_{task|proc}()
      cgroup: remove synchronize_rcu() from rebind_subsystems()
      cgroup: fix bogus kernel warnings when cgroup_create() failed
      cgroup: remove a NULL check in cgroup_exit()
      cgroup: initialize cgrp->dentry before css_alloc()
      sched: split out css_online/css_offline from tg creation/destruction
      sched: remove redundant NULL cgroup check in task_group_path()
      cgroup: remove duplicate RCU free on struct cgroup
      cgroup: remove synchronize_rcu() from cgroup_diput()
      cgroup: remove bogus comments in cgroup_diput()
      cgroup: fix exit() vs rmdir() race
      cpuset: fix cpuset_print_task_mems_allowed() vs rename() race
      cgroup: fix cgroup_rmdir() vs close(eventfd) race
      cgroup: fail if monitored file and event_control are in different cgroup

Tejun Heo (2):
      cgroup: remove unused dummy cgroup_fork_callbacks()
      cgroup: implement cgroup_rightmost_descendant()

 Documentation/cgroups/00-INDEX                     |   2 -
 Documentation/cgroups/memcg_test.txt               |   3 +-
 include/linux/cgroup.h                             |   3 +-
 include/linux/sched.h                              |   3 +
 kernel/cgroup.c                                    | 288 ++++++++++++---------
 kernel/cpuset.c                                    |  12 +-
 kernel/sched/auto_group.c                          |   3 +
 kernel/sched/core.c                                |  49 +++-
 kernel/sched/debug.c                               |   7 -
 tools/Makefile                                     |  19 +-
 tools/cgroup/.gitignore                            |   1 +
 tools/cgroup/Makefile                              |  11 +
 .../cgroup}/cgroup_event_listener.c                |  72 ++----
 13 files changed, 270 insertions(+), 203 deletions(-)
 create mode 100644 tools/cgroup/.gitignore
 create mode 100644 tools/cgroup/Makefile
 rename {Documentation/cgroups => tools/cgroup}/cgroup_event_listener.c (54%)

Thanks.

--
tejun
