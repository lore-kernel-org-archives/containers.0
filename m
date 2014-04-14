From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET cgroup/for-3.16] cgroup: implement cgroup.populated, v2
Date: Mon, 14 Apr 2014 17:44:03 -0400
Message-ID: <1397511846-2904-1-git-send-email-tj@kernel.org>
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
Cc: rlove-L7G0xEPcOZbYtjvyW6yDsg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

This is v2 of cgroup.populated patchset changes from v1[L] are,

* Rebased on top of v3.15-rc1

* Patch description updated for the third patch as per Serge.

(inotify folks, can you please review the second patch which hooks up
 kernfs_notify() with fsnotify?  It works but directly invoking
 fsnotify_parent() and fsnotify() feels a bit dirty.  Maybe something
 like fsnotify_notify_modify_by_dentry() would make more sense?)

cgroup users often need a way to determine when a cgroup's
subhierarchy becomes empty so that it can be cleaned up.  cgroup
currently provides release_agent for it; unfortunately, this mechanism
is riddled with issues.  This patchset implements a replacement
mechanism "cgroup.subtree_populated" which can be used to monitor
whether the cgroup's subhierarchy has tasks in it or not and triggers
poll and [di]notify events when its content changes.

This patchset contains the following three patches.

 0001-kernfs-implement-kernfs_root-supers-list.patch
 0002-kernfs-make-kernfs_notify-trigger-inotify-events-too.patch
 0003-cgroup-implement-cgroup.subtree_populated-for-the-de.patch

0001-0002 add [di]notify notification to kernfs_notify().

0003 implements cgroup.subtree_populated.

This patchset is on top of "cgroup: implement unified hierarchy, v2"
patchset[1] and availalbe in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-populated

diffstat follows.

 fs/kernfs/dir.c             |    1 
 fs/kernfs/file.c            |   41 +++++++++++++++++++++++----
 fs/kernfs/kernfs-internal.h |    5 +++
 fs/kernfs/mount.c           |   11 +++++++
 include/linux/cgroup.h      |   15 ++++++++++
 include/linux/kernfs.h      |    4 ++
 kernel/cgroup.c             |   65 +++++++++++++++++++++++++++++++++++++++++---
 7 files changed, 132 insertions(+), 10 deletions(-)

Thanks.

--
tejun

[L] http://lkml.kernel.org/g/1397056052-2829-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
[1] http://lkml.kernel.org/g/1397511430-2673-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
