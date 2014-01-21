From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup changes for v3.14-rc1
Date: Tue, 21 Jan 2014 05:04:56 -0500
Message-ID: <20140121100456.GC6928__22607.1873716593$1390298715$gmane$org@htj.dyndns.org>
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

The bulk of changes are cleanups and preparations for the upcoming
kernfs conversion.

* cgroup_event mechanism which is and will be used only by memcg is
  moved to memcg.

* pidlist handling is updated so that it can be served by seq_file.
  Also, the list is not sorted if sane_behavior.  cgroup documentation
  explicitly states that the file is not sorted but it has been for
  quite some time.

* All cgroup file handling now happens on top of seq_file.  This is to
  prepare for kernfs conversion.  In addition, all operations are
  restructured so that they map 1-1 to kernfs operations.

* Other cleanups and low-pri fixes.

The following changes since commit 266ccd505e8acb98717819cef9d91d66c7b237cc:

  cgroup: fix cgroup_create() error handling path (2013-12-06 15:08:50 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.14

for you to fetch changes up to dd4b0a4676907481256d16d5de0851b315a6f22c:

  cgroup: trivial style updates (2014-01-18 08:56:11 -0500)

Thanks.
----------------------------------------------------------------
Hugh Dickins (1):
      cgroup: remove stray references to css_id

Masanari Iida (1):
      doc: cgroups: Fix typo in doc/cgroups

SeongJae Park (1):
      cgroup: trivial style updates

Tejun Heo (38):
      cgroup, memcg: move cgroup_event implementation to memcg
      memcg: cgroup_write_event_control() now knows @css is for memcg
      cgroup, memcg: move cgroup->event_list[_lock] and event callbacks into memcg
      memcg: remove cgroup_event->cft
      memcg: make cgroup_event deal with mem_cgroup instead of cgroup_subsys_state
      memcg: rename cgroup_event to mem_cgroup_event
      cgroup: unexport cgroup_css() and remove __file_cft()
      cgroup: Merge branch 'memcg_event' into for-3.14
      cgroup: Merge branch 'for-3.13-fixes' into for-3.14
      cgroup: don't skip seq_open on write only opens on pidlist files
      cgroup: remove cftype->release()
      cgroup: implement delayed destruction for cgroup_pidlist
      cgroup: introduce struct cgroup_pidlist_open_file
      cgroup: refactor cgroup_pidlist_find()
      cgroup: remove cgroup_pidlist->rwsem
      cgroup: load and release pidlists from seq_file start and stop respectively
      cgroup: remove cgroup_pidlist->use_count
      cgroup: don't guarantee cgroup.procs is sorted if sane_behavior
      cgroup, sched: convert away from cftype->read_map()
      cpuset: convert away from cftype->read()
      memcg: convert away from cftype->read() and ->read_map()
      netprio_cgroup: convert away from cftype->read_map()
      hugetlb_cgroup: convert away from cftype->read()
      cgroup: remove cftype->read(), ->read_map() and ->write()
      cgroup: unify cgroup_write_X64() and cgroup_write_string()
      cgroup: unify read path so that seq_file is always used
      cgroup: generalize cgroup_pidlist_open_file
      cgroup: attach cgroup_open_file to all cgroup files
      cgroup: replace cftype->read_seq_string() with cftype->seq_show()
      cgroup: unify pidlist and other file handling
      Merge branch 'for-3.13-fixes' into for-3.14
      cgroup: css iterations and css_from_dir() are safe under cgroup_mutex
      cgroup: make for_each_subsys() useable under cgroup_root_mutex
      cgroup: reorder operations in cgroup_create()
      cgroup: combine css handling loops in cgroup_create()
      cgroup: factor out cgroup_subsys_state creation into create_css()
      cgroup: implement for_each_css()
      cgroup: remove for_each_root_subsys()

Vladimir Davydov (1):
      cgroup: fix fail path in cgroup_load_subsys()

Wei Yongjun (1):
      cgroup: fix missing unlock on error in cgroup_load_subsys()

 Documentation/cgroups/cgroups.txt          |   20 -
 Documentation/cgroups/memory.txt           |    4 +-
 Documentation/cgroups/resource_counter.txt |    4 +-
 block/blk-throttle.c                       |   35 +-
 block/cfq-iosched.c                        |  131 ++-
 drivers/md/bcache/request.c                |    1 -
 include/linux/cgroup.h                     |  112 +--
 include/linux/vmpressure.h                 |    8 +-
 init/Kconfig                               |    3 +-
 kernel/cgroup.c                            | 1202 +++++++++++-----------------
 kernel/cgroup_freezer.c                    |    7 +-
 kernel/cpuset.c                            |   71 +-
 kernel/sched/core.c                        |   13 +-
 kernel/sched/cpuacct.c                     |   18 +-
 mm/hugetlb_cgroup.c                        |   22 +-
 mm/memcontrol.c                            |  426 ++++++++--
 mm/page_cgroup.c                           |    2 +-
 mm/vmpressure.c                            |   26 +-
 net/core/netprio_cgroup.c                  |    8 +-
 security/device_cgroup.c                   |    7 +-
 20 files changed, 1022 insertions(+), 1098 deletions(-)

--
tejun
