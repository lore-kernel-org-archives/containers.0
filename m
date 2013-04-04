From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] cgroup: unexport locking interface
Date: Thu,  4 Apr 2013 16:36:24 -0700
Message-ID: <1365118589-10619-1-git-send-email-tj__23781.7282359631$1365118657$gmane$org@kernel.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

Most cgroup_mutex abuses outside cgroup core proper have been
eradicated but there's still one use remaining and locking interface
is still exported.  This patchset updates the last user and unexports
the locking interface and is composed of the following five patches.

 0001-cgroup-cpuset-replace-move_member_tasks_to_cpuset-wi.patch
 0002-cgroup-relocate-cgroup_lock_live_group-and-cgroup_at.patch
 0003-cgroup-unexport-locking-interface-and-cgroup_attach_.patch
 0004-cgroup-kill-cgroup_-un-lock.patch
 0005-cgroup-remove-cgroup_lock_is_held.patch

It's on top of cgroup/for-3.10 a423ecb8a ("memcg: fix
memcg_cache_name() to use cgroup_name()") and available in the
following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-unexport-locking

diffstat follows.  Thanks.

 include/linux/cgroup.h |   19 +++--
 kernel/cgroup.c        |  162 ++++++++++++++++++++++++-------------------------
 kernel/cpuset.c        |   51 +--------------
 3 files changed, 96 insertions(+), 136 deletions(-)

--
tejun
