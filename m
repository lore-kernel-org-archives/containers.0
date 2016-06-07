From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 3/3] Write dump into container's filesystem for pipe_type
	core_pattern
Date: Tue, 7 Jun 2016 19:29:37 +0800
Message-ID: <9d61a9a95ca4c323adc182abf32714b46e963405.1465293010.git.zhaolei@cn.fujitsu.com>
References: <cover.1465293010.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1465293010.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

In current system, when we set core_pattern to a pipe, both pipe program
and program's output are in host's filesystem.
But when we set core_pattern to a file, the container will write dump
into container's filesystem.

For example, when we set following core_pattern:
 # echo "|/my_dump_pipe %s %c %p %u %g %t e" >/proc/sys/kernel/core_pattern
and trigger a segment fault in a container, my_dump_pipe is searched from
host's filesystem, and it will write coredump into host's filesystem too.

In a privileged container, user can destroy host system by following
command:
 # # In a container
 # echo "|/bin/dd of=/boot/vmlinuz" >/proc/sys/kernel/core_pattern
 # make_dump

Actually, all operation in a container should not change host's
environment, the container should use core_pattern as its private setting.
In detail, in core dump action:
1: Search pipe program in container's fs namespace.
2: Run pipe program in container's fs namespace to write coredump to it.

This patch fixed above problem by running pipe program with container's
fs_root.

Test:
 1: do dump in host
    should have same action with current code.
    [HOST] # ulimit -c 1024000
    [HOST] # rm -f /tmp/*dump*
    [HOST] # echo "|/dump_pipe %s %c %p %u %g %t e" >/proc/sys/kernel/core_pattern
    [HOST] # ./make_dump
    [HOST] Segmentation fault (core dumped)
    [HOST] # ls -l /tmp/*dump*  # Should see host_dump_*.
    [HOST] -rw-r--r-- 1 root root 331776 Apr 15 18:01 /tmp/host_dump_11_1048576000_2356_0_0_1460714470
 2: do dump after change core_pattern in container
    the container should write dump into its filesystem.
    [HOST] # rm -f /tmp/*dump*
    [HOST] # echo "|/dump_pipe %s %c %p %u %g %t e" >/proc/sys/kernel/core_pattern
    [HOST] # lxc-start -n vm_dumptest
    [GUEST]Please press Enter to activate this console.
    [GUEST]# ulimit -c 1024000
    [GUEST]# rm -f /tmp/*dump*
    [GUEST]# echo "|/dump_pipe %s %c %p %u %g %t e" >/proc/sys/kernel/core_pattern
    [GUEST]# ./make_dump
    [GUEST]Segmentation fault (core dumped)
    [GUEST]# ls -l /tmp/*dump*  # Should see guest_dump_*
    [GUEST]-rw-r--r--    1 root     root       331776 Apr 15 10:01 /tmp/guest_dump_11_524288000_12_0_0_1460714482
 3: do dump without change core_pattern in container
    the container should write dump into host's filesystem to keep compatibility.
    [HOST] # rm -f /tmp/*dump*
    [HOST] # echo "|/dump_pipe %s %c %p %u %g %t e" >/proc/sys/kernel/core_pattern
    [HOST] # lxc-start -n vm_dumptest
    [GUEST]Please press Enter to activate this console.
    [GUEST]# ulimit -c 1024000
    [GUEST]# rm -f /tmp/*dump*
    [GUEST]# ./make_dump
    [GUEST]Segmentation fault (core dumped)
    [GUEST]# ls -l /tmp/*dump*  # Should not see dump file
    [GUEST]ls: /tmp/*dump*: No such file or directory
    [HOST] # ls -l /tmp/*dump*  # Should see dump file
    [HOST] -rw-r--r-- 1 root root 331776 Apr 15 18:01 /tmp/host_dump_11_524288000_12_0_0_1460714516

Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/coredump.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 864985e..4616a25 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -592,6 +592,8 @@ void do_coredump(const siginfo_t *siginfo)
 		int dump_count;
 		char **helper_argv;
 		struct subprocess_info *sub_info;
+		struct pid_namespace *pid_ns;
+		struct path root_fs;
 
 		if (ispipe < 0) {
 			printk(KERN_WARNING "format_corename failed\n");
@@ -638,15 +640,29 @@ void do_coredump(const siginfo_t *siginfo)
 			goto fail_dropcount;
 		}
 
+		pid_ns = task_active_pid_ns(current);
+		spin_lock(&pid_ns->root_for_dump_lock);
+		while (pid_ns != &init_pid_ns) {
+			if (pid_ns->root_for_dump.mnt)
+				break;
+			spin_unlock(&pid_ns->root_for_dump_lock);
+			pid_ns = pid_ns->parent,
+			spin_lock(&pid_ns->root_for_dump_lock);
+		}
+		root_fs = pid_ns->root_for_dump;
+		path_get(&root_fs);
+		spin_unlock(&pid_ns->root_for_dump_lock);
+
 		retval = -ENOMEM;
 		sub_info = call_usermodehelper_setup(helper_argv[0],
 						helper_argv, NULL, GFP_KERNEL,
 						umh_pipe_setup, NULL, &cprm,
-						NULL);
+						&root_fs);
 		if (sub_info)
 			retval = call_usermodehelper_exec(sub_info,
 							  UMH_WAIT_EXEC);
 
+		path_put(&root_fs);
 		argv_free(helper_argv);
 		if (retval) {
 			printk(KERN_INFO "Core dump to |%s pipe failed\n",
-- 
1.8.5.1
