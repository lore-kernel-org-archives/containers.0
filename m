From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] cgroup: fix and clean up cgroup file creations and removals
Date: Fri, 28 Jun 2013 16:45:36 -0700
Message-ID: <1372463145-4245-1-git-send-email-tj__33681.4586692073$1372463167$gmane$org@kernel.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

cgroup has been pretty lax about errors while creating cgroupfs files.
In most cases, it just ignores the errors and continues - cgroups
created or subsystems bound under heavy memory pressure could be
missing some files.  As such low memory conditions aren't too
frequent, this hasn't caused a lot of problems but this is lousy and
we'll be creating and removing cgroupfs files a lot more dynamically
with unified hierarchy.  Let's get it in proper shape.

This patchset contains the following nine patches.

 0001-cgroup-minor-updates-around-cgroup_clear_directory.patch
 0002-cgroup-fix-error-path-of-cgroup_addrm_files.patch
 0003-cgroup-fix-cgroup_add_cftypes-error-handling.patch
 0004-cgroup-separate-out-cgroup_base_files-handling-out-o.patch
 0005-cgroup-update-error-handling-in-cgroup_populate_dir.patch
 0006-cgroup-make-rebind_subsystems-handle-file-additions-.patch
 0007-cgroup-cosmetic-follow-up-cleanups.patch
 0008-cgroup-move-number_of_cgroups-test-out-of-rebind_sub.patch
 0009-blkcg-make-blkcg_policy_register-correctly-handle-cg.patch

0001-0007 clean up and get proper error handling implemented so that
if a file creation fails, the whole operation fails.

0008 is trivial reorganization to prepare for unified hierarchy.

0009 updates blkcg to treat cgroup_add_cftypes(), which now behaves
correctly after a failure, error properly.

This patch is on top of cgroup/for-3.11 0ce6cba357 ("cgroup:
CGRP_ROOT_SUBSYS_BOUND should be ignored when comparing mount
options") and available in the following git branc.h

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-file-error-handling

diffstat follows.

 block/blk-cgroup.c |    9 +-
 kernel/cgroup.c    |  212 ++++++++++++++++++++++++++++++-----------------------
 2 files changed, 126 insertions(+), 95 deletions(-)

Thanks.

--
tejun
