From: Cao Shufeng <caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 0/3] Make core_pattern support namespace
Date: Wed, 2 Aug 2017 14:37:26 +0800
Message-ID: <1501655849-9149-1-git-send-email-caosf.fnst__38087.9896496937$1501656525$gmane$org@cn.fujitsu.com>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mashimiao.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

This patchset includes following function points:
1: Let usermodehelper function possible to set pid namespace
   done by: [PATCH_v4.1_1/3] Make call_usermodehelper_exec possible
   to set namespaces
2: Let pipe_type core_pattern write dump into container's rootfs
   done by: [PATCH_v4.1_2/3] Limit dump_pipe program's permission to
   init for container
3: Make separate core_pattern setting for each container
   done by: [PATCH_v4.1_3/3] Make core_pattern support namespace
4: Compatibility with current system
   also included in: [PATCH_v4.1_3/3] Make core_pattern support namespace
   If container hadn't change core_pattern setting, it will keep
   same setting with host.

Test:
1: Pass a test script for each function of this patchset
   ## TEST IN HOST ##
   [root@kerneldev dumptest]# ./test_host
   Set file core_pattern: OK
   ./test_host: line 41:  2366 Segmentation fault      (core dumped) "$SCRI=
PT_BASE_DIR"/make_dump
   Checking dumpfile: OK
   Set file core_pattern: OK
   ./test_host: line 41:  2369 Segmentation fault      (core dumped) "$SCRI=
PT_BASE_DIR"/make_dump
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
   [   64.940734] make_dump[2432]: segfault at 0 ip 000000000040049d sp 000=
07ffc4af025f0 error 6 in make_dump[400000+a6000]
   #
2: Pass other test(which is not easy to do in script) by hand.

Changelog v3.1-v4:
1. remove extra fork pointed out by:
   Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
2: Rebase on top of v4.9-rc8.
3: Rebase on top of v4.12.

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
 include/linux/kmod.h          |   5 ++
 include/linux/pid_namespace.h |   3 +
 init/do_mounts_initrd.c       |   3 +-
 kernel/kmod.c                 |  56 +++++++++++++---
 kernel/pid.c                  |   2 +
 kernel/pid_namespace.c        |   2 +
 kernel/sysctl.c               |  50 ++++++++++++--
 lib/kobject_uevent.c          |   3 +-
 security/keys/request_key.c   |   4 +-
 11 files changed, 253 insertions(+), 27 deletions(-)

-- 
2.9.3
