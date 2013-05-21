From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] cgroup: allow dropping RCU read lock while iterating
Date: Tue, 21 May 2013 10:50:20 +0900
Message-ID: <1369101025-28335-1-git-send-email-tj@kernel.org>
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
Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently all cgroup iterators require the whole traversal to be
contained in a single RCU read critical section, which can be too
restrictive as there are times when blocking operations are necessary
during traversal.  This forces controllers to implement specific
workarounds in those cases - building separate iteration list, punting
actual operations to work items and so on.

This patchset updates cgroup iterators so that they allow dropping RCU
read lock while iteration is in progress so that controllers which
require sleeping during iteration don't need to implement their own
mechanisms.

Dropping RCU read lock during iteration is unsafe because
cgroup->sibling.next can't be trusted once RCU read lock is dropped.
The sibling list is a RCU list and when a cgroup is removed the next
pointer is retained to keep RCU traversal working.  If the next
sibling is removed while RCU read lock is dropped, the removed current
cgroup's next won't be updated and the next sibling may complete its
grace period and get freed leaving the next pointer dangling.

Working around the problem is relatiely simple.  Whether
->sibling.next can be trusted can be trusted can be decided by looking
at CGRP_REMOVED - as cgroup removals are fully serialized, the flag is
guaranteed to be visible before the next sibling finishes its grace
period.  For those cases, each cgroup is assigned a monotonically
increasing serial number.  Because new cgroups are always appeneded to
the children list, it's guaranteed that all children list are sorted
in the ascending order of the serial numbers.  When the next pointer
can't be trusted, the next sibling can be located by walking the
parent's children list from the beginning looking for the first cgroup
with higher serial number.

The above is implemented in cgroup_next_sibling() and all iterators
are updated to use it to find out the next sibling thus allowing
droppping RCU read lock while iteration is in progress.  This patchset
replaces separate iteration list in device_cgroup with direct
descendant walk and there will be further patches making use of this
update.

This patchset contains the following five patches.

 0001-cgroup-fix-a-subtle-bug-in-descendant-pre-order-walk.patch
 0002-cgroup-make-cgroup_is_removed-static.patch
 0003-cgroup-add-cgroup-serial_nr-and-implement-cgroup_nex.patch
 0004-cgroup-update-iterators-to-use-cgroup_next_sibling.patch
 0005-device_cgroup-simplify-cgroup-tree-walk-in-propagate.patch

0001 fixes a subtle iteration bug.  Will be applied to for-3.10-fixes.

0002 is a trivial prep patch.

0003 implements cgroup_next_sibling() which can find out the next
sibling regardless of the state of the current cgroup.

0004 updates all iterators to use cgroup_next_sibling().

0005 replaces iteration list work around in device_cgroup with direct
iteration.

This patchset is on top of cgroup/for-3.11 23958e729e ("cgroup.h:
remove some functions that are now gone") and available in the
following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-interruptible-iter

diffstat follows.

 include/linux/cgroup.h   |   31 +++++++++++---
 kernel/cgroup.c          |   98 ++++++++++++++++++++++++++++++++++++++++-------
 security/device_cgroup.c |   56 ++++++++------------------
 3 files changed, 128 insertions(+), 57 deletions(-)

Thanks.

--
tejun
