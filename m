From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup fixes for v3.10-rc4
Date: Sun, 2 Jun 2013 20:39:24 -0700
Message-ID: <20130603033924.GC6071@mtj.dyndns.org>
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

This pull request contains

* Fix for yet another xattr bug which may lead to NULL deref.

* A subtle bug in for_each_descendant_pre().  This bug requires quite
  specific conditions to trigger and isn't too likely to actually
  happen in the wild, but maybe that just makes it that much more
  nastier.

* A warning message added for silly cgroup re-mount (not -o remount,
  but unmount followed by mount) behavior.

The changes are available in the following git branch

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.10-fixes

for you to fetch changes up to 2a0ff3fbe39bc93f719ff857e5a359d9780579ff:

  cgroup: warn about mismatching options of a new mount of an existing hierarchy (2013-05-29 07:59:39 +0900)

Thanks.

----------------------------------------------------------------
Jeff Liu (1):
      cgroup: warn about mismatching options of a new mount of an existing hierarchy

Li Zefan (1):
      cgroup: initialize xattr before calling d_instantiate()

Tejun Heo (1):
      cgroup: fix a subtle bug in descendant pre-order walk

 include/linux/cgroup.h |  2 +-
 kernel/cgroup.c        | 31 ++++++++++++++++---------------
 2 files changed, 17 insertions(+), 16 deletions(-)

--
tejun
