From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] block: modularize blkcg config and stat file handling
Date: Wed, 28 Mar 2012 15:51:10 -0700
Message-ID: <1332975091-10950-1-git-send-email-tj__13865.0066023276$1332975113$gmane$org@kernel.org>
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
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

The way configuration and statistics are handled in block cgroup is
rather depressing.  Every configuration and stat counter are defined
in blkcg core and specific policy implementations should go through
some blkcg interface to access and manipulate them and be notified of
the changes.

By doing things this way, it achieves both complexity and
inflexibility - the code paths are unnecessarily complex while not
achieving any layering or modularity.  A configuration or statistics
counter cannot be added to policies without modifying multiple places
in blkcg core code.  Wanna implement a new policy?  Good luck.  The
implementation details are sad too.  Stuff goes through needless
layers of functions with hard coded cases on specific counters and
configurations and fields specific to policies are thrown into common
area with some shared and others unused.

This patchset is an attempt at bringing some sanity to blkcg config
and stat file handling.  It makes use of the pending dynamic cgroup
file type addition / removal support [1], which will be merged into
cgroup/for-3.5 once 3.4-rc1 is released.

All conf and stat file handling is moved into the policy
implementaiton the files belong to and blkcg supplies helpers to ease
file handling in policy implementations without requiring full
knowledge of all configurations and statistic counters.

This patchset sheds >500 lines of code while maintaining the same
features and with more comments and much more modular design.  Yeah,
it was just wrong.

This patchset contains the following 21 patches

 0001-blkcg-remove-unused-pol-and-plid-parameters.patch
 0002-blkcg-BLKIO_STAT_CPU_SECTORS-doesn-t-have-subcounter.patch
 0003-blkcg-introduce-blkg_stat-and-blkg_rwstat.patch
 0004-blkcg-restructure-statistics-printing.patch
 0005-blkcg-drop-blkiocg_file_write_u64.patch
 0006-blkcg-restructure-configuration-printing.patch
 0007-blkcg-restructure-blkio_group-configruation-setting.patch
 0008-blkcg-blkg_conf_prep.patch
 0009-blkcg-export-conf-stat-helpers-to-prepare-for-reorga.patch
 0010-blkcg-implement-blkio_policy_type-cftypes.patch
 0011-blkcg-move-conf-stat-file-handling-code-to-policies.patch
 0012-cfq-collapse-cfq.h-into-cfq-iosched.c.patch
 0013-blkcg-move-statistics-update-code-to-policies.patch
 0014-blkcg-cfq-doesn-t-need-per-cpu-dispatch-stats.patch
 0015-blkcg-add-blkio_policy_ops-operations-for-exit-and-s.patch
 0016-blkcg-move-blkio_group_stats-to-cfq-iosched.c.patch
 0017-blkcg-move-blkio_group_stats_cpu-and-friends-to-blk-.patch
 0018-blkcg-move-blkio_group_conf-weight-to-cfq.patch
 0019-blkcg-move-blkio_group_conf-iops-and-bps-to-blk-thro.patch
 0020-blkcg-pass-around-pd-pdata-instead-of-pd-itself-in-p.patch
 0021-blkcg-drop-BLKCG_STAT_-PRIV-POL-OFF-macros.patch

and is on top of

  block/for-3.5/core eb7d8c07f9 "cfq: fix cfqg ref handling..."
+ [1] cgroup-cftypes d954ca6469 "cgroup: implement cgroup_rm_cftypes()"

Note that the cgroup branch is temporary and the merge between the two
branches aren't trivial.  I'll prepare a proper merged branch once the
cgroup/for-3.5 branch is settled.

This patchset is also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git blkcg-files

diffstat follows.

 block/blk-cgroup.c   | 1343 ++++++---------------------------------------------
 block/blk-cgroup.h   |  414 ++++++---------
 block/blk-throttle.c |  318 ++++++++++--
 block/cfq-iosched.c  |  567 +++++++++++++++++++--
 block/cfq.h          |  118 ----
 5 files changed, 1102 insertions(+), 1658 deletions(-)

--
tejun

[1] http://thread.gmane.org/gmane.linux.kernel.containers/22623
