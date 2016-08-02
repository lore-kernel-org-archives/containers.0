From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 0/2] Make core_pattern support namespace
Date: Tue, 2 Aug 2016 17:08:31 +0800
Message-ID: <cover.1470128571.git.zhaolei@cn.fujitsu.com>
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
1: Let pipe_type core_pattern write dump into container's rootfs
   done by: [PATCH v2 1/2] Limit dump_pipe program's permission to
   init for container
2: Make separate core_pattern setting for each container
   done by: [PATCH v2 2/2] Make core_pattern support namespace
3: Compatibility with current system
   also included in: [PATCH v2 2/2] Make core_pattern support namespace
   If container hadn't change core_pattern setting, it will keep
   same setting with host.

Test:
1: Pass a test script for each function of this patchset
   # ./test_host
   Set file core_pattern: OK
   ./test_host: line 41:  4237 Segmentation fault      (core dumped) "$SCRIPT_BASE_DIR"/make_dump
   Checking dumpfile: OK
   Set file core_pattern: OK
   ./test_host: line 41:  4240 Segmentation fault      (core dumped) "$SCRIPT_BASE_DIR"/make_dump
   Checking dump_pipe triggered: OK
   Checking rootfs: OK
   Checking dumpfile: OK
   Checking namespace: OK
   Checking process list: OK
   Checking capabilities: OK
   #
   # /test
   Segmentation fault (core dumped)
   -rw-r--r--    1 root     root          123 Aug  2 09:01 /tmp/dumptest_cap_init
   -rw-r--r--    1 root     root          123 Aug  2 09:01 /tmp/dumptest_cap_self
   -rw-r--r--    1 root     root            5 Aug  2 09:01 /tmp/dumptest_cg_cgpid
   -rw-r--r--    1 root     root       327680 Aug  2 09:01 /tmp/dumptest_guestdump_11_524288000_16_0_0_1470128516
   -rw-r--r--    1 root     root          123 Aug  2 09:01 /tmp/dumptest_ns_init
   -rw-r--r--    1 root     root          123 Aug  2 09:01 /tmp/dumptest_ns_self
   -rw-r--r--    1 root     root          288 Aug  2 09:01 /tmp/dumptest_psresult
   -rw-r--r--    1 root     root         1728 Aug  2 09:01 /tmp/dumptest_rootfs
   Checking dump_pipe triggered: OK
   Checking rootfs: OK
   Checking dumpfile: OK
   Checking namespace: OK
   Checking process list: OK
   Checking cg pids: OK
   Checking capabilities: OK
2: Pass other test(which is not easy to do in script) by hand.

Changelog v1(RFC)->v2:
1: Add [PATCH 2/2] which was todo in [RFC v1].
2: Pass a test script for each function.
3: Rebase on top of v4.7.

Suggested-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Suggested-by: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Zhao Lei (2):
  Limit dump_pipe program's permission to init for container
  Make core_pattern support namespace

 fs/coredump.c                 | 110 +++++++++++++++++++++++++++++++++++++++---
 include/linux/binfmts.h       |   1 +
 include/linux/pid_namespace.h |   3 ++
 kernel/pid.c                  |   2 +
 kernel/pid_namespace.c        |   2 +
 kernel/sysctl.c               |  50 +++++++++++++++++--
 6 files changed, 156 insertions(+), 12 deletions(-)

-- 
1.8.5.1
