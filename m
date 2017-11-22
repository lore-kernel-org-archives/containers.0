From: Cao Shufeng <caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH_v4.1 0/3] Make core_pattern support namespace
Date: Wed, 22 Nov 2017 11:24:15 +0800
Message-ID: <1511321058-6089-1-git-send-email-caosf.fnst@cn.fujitsu.com>
References: <1501655849-9149-1-git-send-email-caosf.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1501655849-9149-1-git-send-email-caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mashimiao.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, fnstml-container-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

This patchset includes following function points:
1: Let usermodehelper function possible to set pid namespace
   done by: [PATCH_v4.1 1/3] Make call_usermodehelper_exec possible
   to set namespaces
2: Let pipe_type core_pattern write dump into container's rootfs
   done by: [PATCH_v4.1 2/3] Limit dump_pipe program's permission to
   init for container
3: Make separate core_pattern setting for each container
   done by: [PATCH_v4.1 3/3] Make core_pattern support namespace
4: Compatibility with current system
   also included in: [PATCH_v4.1 3/3] Make core_pattern support namespace
   If container hadn't change core_pattern setting, it will keep
   same setting with host.

Changelog v3.1-v4:
1. remove extra fork pointed out by:
   Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
2: Rebase on top of v4.9-rc8.
3: Rebase on top of v4.12.
3: Rebase on top of v4.14.

Changelog v3-v3.1:
1. Switch "pwd" of pipe program to container's root fs.
2. Rebase on top of v4.9-rc1.

Changelog v2->v3:
1: Fix problem of setting pid namespace, pointed out by:
   Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Changelog v1(RFC)->v2:
1: Add [PATCH 2/2] which was todo in [RFC v1].
2: Pass a test script for each function.
3: Rebase on top of v4.7.

Suggested-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Suggested-by: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Cao Shufeng <caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Cao Shufeng (3):
  Make call_usermodehelper_exec possible to set namespaces
  Limit dump_pipe program's permission to init for container
  Make core_pattern support namespace

 fs/coredump.c                 | 150 +++++++++++++++++++++++++++++++++++++++---
 include/linux/binfmts.h       |   2 +
 include/linux/pid_namespace.h |   3 +
 include/linux/umh.h           |   5 ++
 init/do_mounts_initrd.c       |   3 +-
 kernel/kmod.c                 |   3 +-
 kernel/pid.c                  |   2 +
 kernel/pid_namespace.c        |   2 +
 kernel/sysctl.c               |  50 ++++++++++++--
 kernel/umh.c                  |  51 +++++++++++---
 security/keys/request_key.c   |   4 +-
 11 files changed, 250 insertions(+), 25 deletions(-)

-- 
2.1.0
