From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 4/4] introduce sys_checkpoint and sys_restore
Date: Thu, 07 Aug 2008 15:40:38 -0700
Message-ID: <20080807224038.0B03CEEF__26205.0450117842$1218149092$gmane$org@kernel>
References: <20080807224033.FFB3A2C1@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080807224033.FFB3A2C1@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Create trivial sys_checkpoint and sys_restore system calls. They will
enable to checkpoint and restart an entire container, to and from a
checkpoint image file.

First create a template for both syscalls: they take a file descriptor
(for the image file) and flags as arguments. For sys_checkpoint the
first argument identifies the target container; for sys_restart it will
identify the checkpoint image.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

---

 linux-2.6.git-dave/arch/x86/kernel/syscall_table_32.S |    2 ++
 linux-2.6.git-dave/include/asm-x86/unistd_32.h        |    2 ++
 2 files changed, 4 insertions(+)

diff -puN arch/x86/kernel/syscall_table_32.S~introduce_sys_checkpoint_and_sys_restore arch/x86/kernel/syscall_table_32.S
--- linux-2.6.git/arch/x86/kernel/syscall_table_32.S~introduce_sys_checkpoint_and_sys_restore	2008-08-07 15:38:04.000000000 -0700
+++ linux-2.6.git-dave/arch/x86/kernel/syscall_table_32.S	2008-08-07 15:38:04.000000000 -0700
@@ -326,3 +326,5 @@ ENTRY(sys_call_table)
 	.long sys_fallocate
 	.long sys_timerfd_settime	/* 325 */
 	.long sys_timerfd_gettime
+	.long sys_checkpoint
+	.long sys_restart
diff -puN include/asm-x86/unistd_32.h~introduce_sys_checkpoint_and_sys_restore include/asm-x86/unistd_32.h
--- linux-2.6.git/include/asm-x86/unistd_32.h~introduce_sys_checkpoint_and_sys_restore	2008-08-07 15:38:04.000000000 -0700
+++ linux-2.6.git-dave/include/asm-x86/unistd_32.h	2008-08-07 15:38:04.000000000 -0700
@@ -332,6 +332,8 @@
 #define __NR_fallocate		324
 #define __NR_timerfd_settime	325
 #define __NR_timerfd_gettime	326
+#define __NR_checkpoint		327
+#define __NR_restart		328
 
 #ifdef __KERNEL__
 
diff -puN Makefile~introduce_sys_checkpoint_and_sys_restore Makefile
_
