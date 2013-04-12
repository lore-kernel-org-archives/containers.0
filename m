From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] cgroup, memcg: introduce sane_behavior mount option
Date: Fri, 12 Apr 2013 16:10:55 -0700
Message-ID: <1365808259-31073-1-git-send-email-tj__22687.5598229983$1365808272$gmane$org@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

It's a sad fact that at this point various cgroup controllers are
carrying so many idiosyncrasies and pure insanities that it simply
isn't possible to reach any sort of sane consistent behavior while
staying compatible with what already has been exposed to userland.

To make progress, those behaviors need to go but we can't simply drop
or change the crazies as those are directly visible to userland.  This
patchset implements a mount option - sane_behavior - which turns on
new saner behaviors, so that we can keep providing the old behaviors
while and after transitioning to saner ones.

As the behaviors which should be changed are still being determined
and then implemented, __DEVEL__ prefix is added to the mount option
and it triggers a warning message when used.

The mount option changes the following behaviors after this patchset.

* Mount options "noprefix" and "clone_children" are disallowed.  Also,
  cgroupfs file cgroup.clone_children is not created.

* When mounting an existing superblock, mount options should match.
  This is currently pretty crazy.  If one mounts a cgroup, creates a
  subdirectory, unmounts it and then mount it again with different
  option, it looks like the new options are applied but they aren't.

* Remount is disallowed.

* memcg: .use_hierarchy is forced on and the cgroupfs file is not
  created.

and there are a lot more to come.  Basically, when turned on, all
controllers should be ready to be mounted in the same hierarchy and
not get in the way unless specifically configured - making blk-throtl
hierarchical would need this to flip the meaning of limits, cpuset to
allow tasks to run by default in new cgroups and handle empty cpusets
in a way friendly to being co-mounted, and so on.

This patchset contains the following four patches.

 0001-cgroup-convert-cgroupfs_root-flag-bits-to-masks-and-.patch
 0002-move-cgroupfs_root-to-include-linux-cgroup.h.patch
 0003-cgroup-introduce-sane_behavior-mount-option.patch
 0004-memcg-force-use_hierarchy-if-sane_behavior.patch

0001-0002 are prep patches.  It exposes cgroupfs_root in cgroup.h so
that flags can be tested with inline helpers.

0003 introduces sane_behavior mount option and implements behavior
changes in cgroup core proper.

0004 makes memcg .use_hierarchy changes.

The memcg patch doesn't conflict with memcg changes in -next, so it
can be routed through the cgroup tree.  Michal, how do you wanna route
it?

This patchset is based on top of cgroup/for-3.10 and also available in
the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-sane_behavior

Thanks.

 include/linux/cgroup.h |  103 +++++++++++++++++++++++++++++++++++++++++
 kernel/cgroup.c        |  121 ++++++++++++++++++++++---------------------------
 mm/memcontrol.c        |   13 +++++
 3 files changed, 172 insertions(+), 65 deletions(-)

--
tejun
