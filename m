From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v3 0/3] Make core_pattern support namespace
Date: Mon, 29 Aug 2016 20:06:38 +0800
Message-ID: <cover.1472471585.git.zhaolei@cn.fujitsu.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

This patchset includes following function points:
1: Let usermodehelper function possible to set pid namespace
   done by: [PATCH v3 1/3] Make call_usermodehelper_exec possible
   to set pid namespace.
2: Let pipe_type core_pattern write dump into container's rootfs
   done by: [PATCH v3 2/3] Limit dump_pipe program's permission to
   init for container.
2: Make separate core_pattern setting for each container
   done by: [PATCH v3 3/3] Make core_pattern support namespace
3: Compatibility with current system
   also included in: [PATCH v3 3/3] Make core_pattern support namespace
   If container hadn't change core_pattern setting, it will keep
   same setting with host.

Test:
1: Pass a test script for each function of this patchset
   ## TEST IN HOST ##
   [root@kerneldev dumptest]# ./test_host
   Set file core_pattern: OK
   ./test_host: line 41:  2366 Segmentation fault      (core dumped) "$SCRIPT_BASE_DIR"/make_dump
   Checking dumpfile: OK
   Set file core_pattern: OK
   ./test_host: line 41:  2369 Segmentation fault      (core dumped) "$SCRIPT_BASE_DIR"/make_dump
   Checking dump_pipe triggered: OK
   Checking rootfs: OK
   Checking dumpfile: OK
   Checking namespace: OK
   Checking process list: OK
   Checking capabilities: OK

   ## TEST IN GUEST ##
   # ./test
   Segmentation fault (core dumped)
   Checking dump_pipe triggered: OK
   Checking rootfs: OK
   Checking dumpfile: OK
   Checking namespace: OK
   Checking process list: OK
   Checking cg pids: OK
   Checking capabilities: OK
   [   64.940734] make_dump[2432]: segfault at 0 ip 000000000040049d sp 00007ffc4af025f0 error 6 in make_dump[400000+a6000]
   #
2: Pass other test(which is not easy to do in script) by hand.

Changelog v2->v3:
1: Fix problem of setting pid namespace, pointed out by:
   Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Changelog v1(RFC)->v2:
1: Add [PATCH 2/2] which was todo in [RFC v1].
2: Pass a test script for each function.
3: Rebase on top of v4.7.

Suggested-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Suggested-by: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Zhao Lei (3):
  Make call_usermodehelper_exec possible to set pid namespace
  Limit dump_pipe program's permission to init for container
  Make core_pattern support namespace

 fs/coredump.c                 | 126 ++++++++++++++++++++++++++++++++++++---
 include/linux/binfmts.h       |   1 +
 include/linux/kmod.h          |   2 +
 include/linux/pid_namespace.h |   3 +
 init/do_mounts_initrd.c       |   3 +-
 kernel/kmod.c                 | 133 +++++++++++++++++++++++++++++++++++++-----
 kernel/pid.c                  |   2 +
 kernel/pid_namespace.c        |   2 +
 kernel/sysctl.c               |  50 ++++++++++++++--
 lib/kobject_uevent.c          |   3 +-
 security/keys/request_key.c   |   4 +-
 11 files changed, 296 insertions(+), 33 deletions(-)

-- 
1.8.5.1
