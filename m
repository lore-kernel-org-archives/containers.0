From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 0/2] Make core_pattern support namespace
Date: Wed, 16 Mar 2016 17:23:17 +0800
Message-ID: <cover.1458119582.git.zhaolei@cn.fujitsu.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

We discussed patch titled:
 [PATCH] Make core_pattern support namespace
before.

Above patch can solve half problem of custom core_dump pattern
in container, but there are also another problem that limit
custom core_pattern in container, it is the pipe-type core_pattern
will write core dump into host's filesystem.
(See discussion of that patch for detail)

Now we can solve the second problem by [PATCH 1/2], I send
the origional patch with it.

Zhao Lei (2):
  Run dump pipe in container's namespace
  Make core_pattern support namespace

 arch/x86/kernel/process_32.c  |  5 +--
 arch/x86/kernel/process_64.c  |  5 +--
 fs/coredump.c                 | 79 +++++++++++++++++++++++++------------------
 include/linux/pid_namespace.h |  2 ++
 include/linux/sched.h         |  5 +--
 kernel/fork.c                 | 24 +++++++------
 kernel/pid.c                  |  1 +
 kernel/pid_namespace.c        |  3 ++
 kernel/sysctl.c               | 22 ++++++++----
 9 files changed, 92 insertions(+), 54 deletions(-)

-- 
1.8.5.1
