From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET] perf,
	cgroup: implement hierarchy support for perf_event controller
Date: Mon,  8 Apr 2013 19:23:30 -0700
Message-ID: <1365474213-13354-1-git-send-email-tj__7428.46865109659$1365474227$gmane$org@kernel.org>
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
To: mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: namhyung.kim-Hm3cg6mZ9cc@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

perf_event cgroup controller is one of the remaining few with broken
hierarchy support.  It turns out it's pretty easy to implement - the
only thing necessary is making perf_cgroup_match() return %true also
when the cgroup of the current task is a descendant of the event's
cgroup.  This patchset implements cgroup_is_descendant() and uses it
to implement hierarchy support in perf_event controller.

This patchset contains the following three patches.

 0001-cgroup-make-sure-parent-won-t-be-destroyed-before-it.patch
 0002-cgroup-implement-cgroup_is_descendant.patch
 0003-perf-make-perf_event-cgroup-hierarchical.patch

The patches are also available in the following git branch, which is
based on top of cgroup/for-3.10.  It's currently based on top of
cgroup/for-3.10 as the first patch causes non-trivial conflict with it
otherwise, which is not difficult to resolve but still nice to avoid
anyway.

Li, Michal, I picked the first two patches from Li's memcg patchset.
Can we push the first two through cgroup/for-3.10 and put the rest in
-mm?

Ingo, how should these be routed?

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git perf_event-hierarchy-support

diffstat follows, thanks.

 include/linux/cgroup.h |    1 +
 kernel/cgroup.c        |   30 ++++++++++++++++++++++++++++++
 kernel/events/core.c   |   24 ++++++++++++++++--------
 3 files changed, 47 insertions(+), 8 deletions(-)

--
tejun
