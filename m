From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET v2 cgroup/for-3.12] cgroup: make cgroup_event specific to
	memcg
Date: Thu, 15 Aug 2013 12:02:18 -0400
Message-ID: <1376582550-12548-1-git-send-email-tj__20947.1669783399$1376582574$gmane$org@kernel.org>
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
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

Changes from the last take[L] are

* Event handling updated such that it doesn't require meddling with
  internals not normally exposed outside cgroup core proper.  dentry
  reference counting is replaced with css one and cftype handling is
  completely gone.  Hopefully, this addresses Michal's complaints.

* Further simplifications.

* Rebased on top of the current cgroup/for-3.12 and pending patches.

Like many other things in cgroup, cgroup_event is way too flexible and
complex - it strives to provide completely flexible event monitoring
facility in cgroup proper which allows any number of users to monitor
custom events.  This essentially is a layering violation and leads to
weird issues like worrying about event API mis/abuse from userland in
cgroup controller event source implementation.

The only thing cgroup_event can do better than standard "file changed"
notification is serving many uncoordinated event listeners watching
many different thresholds which would only make sense if access to the
cgroup hierarchy is widely distributed.  The existing implementation
is pretty ill-equipped to handle such scenario, is not in the right
layer to tackle such issues and the whole cgroup is headed the other
way.  As such, going forward, cgroup core won't support cgroup_event
as the common event mechanism.

Fortunately, memcg along with vmpressure is the only user of the
facility and gets to keep it.  This patchset makes cgroup_event
specific to memcg, moves all related code into mm/memcontrol.c and
renames it to mem_cgroup_event so that its usage can't spread to other
subsystems and later deprecation and cleanup can be localized.

Note that after this patchset, cgroup.event_control file exists only
for the hierarchy which has memcg attached to it.  This is a userland
visible change but unlikely to be noticeable as the file has never
been meaningful outside memcg.  If this ever becomes problematic, we
can add a dummy file on hierarchies w/o memcg when !sane_behavior.

This patchset is consited of the following 12 patches.

 0001-cgroup-rename-cgroup_css_from_dir-to-css_from_dir-an.patch
 0002-cgroup-make-cgroup_css-take-cgroup_subsys-instead-an.patch
 0003-cgroup-implement-CFTYPE_NO_PREFIX.patch
 0004-cgroup-make-cgroup_event-hold-onto-cgroup_subsys_sta.patch
 0005-cgroup-make-cgroup_write_event_control-use-css_from_.patch
 0006-cgroup-memcg-move-cgroup_event-implementation-to-mem.patch
 0007-memcg-cgroup_write_event_control-now-knows-css-is-fo.patch
 0008-cgroup-memcg-move-cgroup-event_list-_lock-and-event-.patch
 0009-memcg-remove-cgroup_event-cft.patch
 0010-memcg-make-cgroup_event-deal-with-mem_cgroup-instead.patch
 0011-memcg-rename-cgroup_event-to-mem_cgroup_event.patch
 0012-cgroup-unexport-cgroup_css-and-remove-__file_cft.patch

0001-0005 prep for the move.  0005 moves it.  0006-0012 simplify it.

While these are quite a few patches, they are mostly trivial in nature
and some are required changes with the planned unified hierarchy
(e.g. switching to css refcnting) and we'd have to restructure it to
handle dynamic css attach/detach if it's kept generic, which will
likely be a lot more work for no noticeable gain.

The patches are based on top of

  cgroup/for-3.12 ff58ac0d58 ("cpuset: remove an unncessary forward declaration")
+ [PATCH] cgroup: fix subsystem file accesses on the root cgroup
+ [PATCH] cgroup: fix cgroup_write_event_control()

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-memcg_event

diffstat follows.

 Documentation/cgroups/cgroups.txt |   20 -
 include/linux/cgroup.h            |   28 --
 include/linux/vmpressure.h        |    8
 init/Kconfig                      |    3
 kernel/cgroup.c                   |  383 +++++---------------------------------
 kernel/events/core.c              |    2
 mm/memcontrol.c                   |  351 +++++++++++++++++++++++++++++++---
 mm/vmpressure.c                   |   26 --
 8 files changed, 389 insertions(+), 432 deletions(-)

Thanks.

--
tejun

[L] http://thread.gmane.org/gmane.linux.kernel.cgroups/8726
