From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/4] Add cpp definitions for enums
Date: Tue, 13 Oct 2009 17:53:08 -0700
Message-ID: <1255481585-32625-4-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This allows us to test for the enums in cpp expressions.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Here's a convenient vim expression to help process enum blocks. Move
your cursor into the enum block and enter the following ex command:

.,/^};/s/CKPT_\([^[:space:]=]*\)\(.*,.*\)[[:space:]]*$/CKPT_\1\2\r#define CKPT_\1 CKPT_\1/gc

It looks for CKPT_* enums and prompty to ask if you wish to add #define
lines for each one.
---
 arch/x86/include/asm/checkpoint_hdr.h |    2 +
 include/linux/checkpoint_hdr.h        |   97 ++++++++++++++++++++++++++++++++-
 2 files changed, 97 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 7a24de5..d586e76 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -45,7 +45,9 @@
 /* arch dependent header types */
 enum {
 	CKPT_HDR_CPU_FPU = 201,
+#define CKPT_HDR_CPU_FPU CKPT_HDR_CPU_FPU
 	CKPT_HDR_MM_CONTEXT_LDT,
+#define CKPT_HDR_MM_CONTEXT_LDT CKPT_HDR_MM_CONTEXT_LDT
 };
 
 /* arch dependent constants */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b5f958e..8dd60c1 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -56,72 +56,124 @@ struct ckpt_hdr {
 /* header types */
 enum {
 	CKPT_HDR_HEADER = 1,
+#define CKPT_HDR_HEADER CKPT_HDR_HEADER
 	CKPT_HDR_HEADER_ARCH,
+#define CKPT_HDR_HEADER_ARCH CKPT_HDR_HEADER_ARCH
 	CKPT_HDR_BUFFER,
+#define CKPT_HDR_BUFFER CKPT_HDR_BUFFER
 	CKPT_HDR_STRING,
+#define CKPT_HDR_STRING CKPT_HDR_STRING
 	CKPT_HDR_OBJREF,
+#define CKPT_HDR_OBJREF CKPT_HDR_OBJREF
 
 	CKPT_HDR_TREE = 101,
+#define CKPT_HDR_TREE CKPT_HDR_TREE
 	CKPT_HDR_TASK,
+#define CKPT_HDR_TASK CKPT_HDR_TASK
 	CKPT_HDR_TASK_NS,
+#define CKPT_HDR_TASK_NS CKPT_HDR_TASK_NS
 	CKPT_HDR_TASK_OBJS,
+#define CKPT_HDR_TASK_OBJS CKPT_HDR_TASK_OBJS
 	CKPT_HDR_RESTART_BLOCK,
+#define CKPT_HDR_RESTART_BLOCK CKPT_HDR_RESTART_BLOCK
 	CKPT_HDR_THREAD,
+#define CKPT_HDR_THREAD CKPT_HDR_THREAD
 	CKPT_HDR_CPU,
+#define CKPT_HDR_CPU CKPT_HDR_CPU
 	CKPT_HDR_NS,
+#define CKPT_HDR_NS CKPT_HDR_NS
 	CKPT_HDR_UTS_NS,
+#define CKPT_HDR_UTS_NS CKPT_HDR_UTS_NS
 	CKPT_HDR_IPC_NS,
+#define CKPT_HDR_IPC_NS CKPT_HDR_IPC_NS
 	CKPT_HDR_CAPABILITIES,
+#define CKPT_HDR_CAPABILITIES CKPT_HDR_CAPABILITIES
 	CKPT_HDR_USER_NS,
+#define CKPT_HDR_USER_NS CKPT_HDR_USER_NS
 	CKPT_HDR_CRED,
+#define CKPT_HDR_CRED CKPT_HDR_CRED
 	CKPT_HDR_USER,
+#define CKPT_HDR_USER CKPT_HDR_USER
 	CKPT_HDR_GROUPINFO,
+#define CKPT_HDR_GROUPINFO CKPT_HDR_GROUPINFO
 	CKPT_HDR_TASK_CREDS,
+#define CKPT_HDR_TASK_CREDS CKPT_HDR_TASK_CREDS
 
 	/* 201-299: reserved for arch-dependent */
 
 	CKPT_HDR_FILE_TABLE = 301,
+#define CKPT_HDR_FILE_TABLE CKPT_HDR_FILE_TABLE
 	CKPT_HDR_FILE_DESC,
+#define CKPT_HDR_FILE_DESC CKPT_HDR_FILE_DESC
 	CKPT_HDR_FILE_NAME,
+#define CKPT_HDR_FILE_NAME CKPT_HDR_FILE_NAME
 	CKPT_HDR_FILE,
+#define CKPT_HDR_FILE CKPT_HDR_FILE
 	CKPT_HDR_PIPE_BUF,
+#define CKPT_HDR_PIPE_BUF CKPT_HDR_PIPE_BUF
 	CKPT_HDR_TTY,
+#define CKPT_HDR_TTY CKPT_HDR_TTY
 	CKPT_HDR_TTY_LDISC,
+#define CKPT_HDR_TTY_LDISC CKPT_HDR_TTY_LDISC
 
 	CKPT_HDR_MM = 401,
+#define CKPT_HDR_MM CKPT_HDR_MM
 	CKPT_HDR_VMA,
+#define CKPT_HDR_VMA CKPT_HDR_VMA
 	CKPT_HDR_PGARR,
+#define CKPT_HDR_PGARR CKPT_HDR_PGARR
 	CKPT_HDR_MM_CONTEXT,
+#define CKPT_HDR_MM_CONTEXT CKPT_HDR_MM_CONTEXT
 
 	CKPT_HDR_IPC = 501,
+#define CKPT_HDR_IPC CKPT_HDR_IPC
 	CKPT_HDR_IPC_SHM,
+#define CKPT_HDR_IPC_SHM CKPT_HDR_IPC_SHM
 	CKPT_HDR_IPC_MSG,
+#define CKPT_HDR_IPC_MSG CKPT_HDR_IPC_MSG
 	CKPT_HDR_IPC_MSG_MSG,
+#define CKPT_HDR_IPC_MSG_MSG CKPT_HDR_IPC_MSG_MSG
 	CKPT_HDR_IPC_SEM,
+#define CKPT_HDR_IPC_SEM CKPT_HDR_IPC_SEM
 
 	CKPT_HDR_SIGHAND = 601,
+#define CKPT_HDR_SIGHAND CKPT_HDR_SIGHAND
 	CKPT_HDR_SIGNAL,
+#define CKPT_HDR_SIGNAL CKPT_HDR_SIGNAL
 	CKPT_HDR_SIGNAL_TASK,
+#define CKPT_HDR_SIGNAL_TASK CKPT_HDR_SIGNAL_TASK
 	CKPT_HDR_SIGPENDING,
+#define CKPT_HDR_SIGPENDING CKPT_HDR_SIGPENDING
 
 	CKPT_HDR_SOCKET = 701,
+#define CKPT_HDR_SOCKET CKPT_HDR_SOCKET
 	CKPT_HDR_SOCKET_QUEUE,
+#define CKPT_HDR_SOCKET_QUEUE CKPT_HDR_SOCKET_QUEUE
 	CKPT_HDR_SOCKET_BUFFER,
+#define CKPT_HDR_SOCKET_BUFFER CKPT_HDR_SOCKET_BUFFER
 	CKPT_HDR_SOCKET_UNIX,
+#define CKPT_HDR_SOCKET_UNIX CKPT_HDR_SOCKET_UNIX
 	CKPT_HDR_SOCKET_INET,
+#define CKPT_HDR_SOCKET_INET CKPT_HDR_SOCKET_INET
 
 	CKPT_HDR_TAIL = 9001,
+#define CKPT_HDR_TAIL CKPT_HDR_TAIL
 
 	CKPT_HDR_ERROR = 9999,
+#define CKPT_HDR_ERROR CKPT_HDR_ERROR
 };
 
 /* architecture */
 enum {
 	/* do not change order (will break ABI) */
 	CKPT_ARCH_X86_32 = 1,
+#define CKPT_ARCH_X86_32 CKPT_ARCH_X86_32
 	CKPT_ARCH_S390X,
+#define CKPT_ARCH_S390X CKPT_ARCH_S390X
 	CKPT_ARCH_PPC32,
+#define CKPT_ARCH_PPC32 CKPT_ARCH_PPC32
 	CKPT_ARCH_PPC64,
+#define CKPT_ARCH_PPC64 CKPT_ARCH_PPC64
 };
 
 /* shared objrects (objref) */
@@ -134,22 +186,39 @@ struct ckpt_hdr_objref {
 /* shared objects types */
 enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
+#define CKPT_OBJ_IGNORE CKPT_OBJ_IGNORE
 	CKPT_OBJ_INODE,
+#define CKPT_OBJ_INODE CKPT_OBJ_INODE
 	CKPT_OBJ_FILE_TABLE,
+#define CKPT_OBJ_FILE_TABLE CKPT_OBJ_FILE_TABLE
 	CKPT_OBJ_FILE,
+#define CKPT_OBJ_FILE CKPT_OBJ_FILE
 	CKPT_OBJ_MM,
+#define CKPT_OBJ_MM CKPT_OBJ_MM
 	CKPT_OBJ_SIGHAND,
+#define CKPT_OBJ_SIGHAND CKPT_OBJ_SIGHAND
 	CKPT_OBJ_SIGNAL,
+#define CKPT_OBJ_SIGNAL CKPT_OBJ_SIGNAL
 	CKPT_OBJ_NS,
+#define CKPT_OBJ_NS CKPT_OBJ_NS
 	CKPT_OBJ_UTS_NS,
+#define CKPT_OBJ_UTS_NS CKPT_OBJ_UTS_NS
 	CKPT_OBJ_IPC_NS,
+#define CKPT_OBJ_IPC_NS CKPT_OBJ_IPC_NS
 	CKPT_OBJ_USER_NS,
+#define CKPT_OBJ_USER_NS CKPT_OBJ_USER_NS
 	CKPT_OBJ_CRED,
+#define CKPT_OBJ_CRED CKPT_OBJ_CRED
 	CKPT_OBJ_USER,
+#define CKPT_OBJ_USER CKPT_OBJ_USER
 	CKPT_OBJ_GROUPINFO,
+#define CKPT_OBJ_GROUPINFO CKPT_OBJ_GROUPINFO
 	CKPT_OBJ_SOCK,
+#define CKPT_OBJ_SOCK CKPT_OBJ_SOCK
 	CKPT_OBJ_TTY,
+#define CKPT_OBJ_TTY CKPT_OBJ_TTY
 	CKPT_OBJ_MAX
+#define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
 
 /* kernel constants */
@@ -354,12 +423,19 @@ struct ckpt_hdr_restart_block {
 
 enum restart_block_type {
 	CKPT_RESTART_BLOCK_NONE = 1,
+#define CKPT_RESTART_BLOCK_NONE CKPT_RESTART_BLOCK_NONE
 	CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP,
+#define CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP
 	CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP,
+#define CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP
 	CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP,
+#define CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP
 	CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP,
+#define CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP
 	CKPT_RESTART_BLOCK_POLL,
-	CKPT_RESTART_BLOCK_FUTEX
+#define CKPT_RESTART_BLOCK_POLL CKPT_RESTART_BLOCK_POLL
+	CKPT_RESTART_BLOCK_FUTEX,
+#define CKPT_RESTART_BLOCK_FUTEX CKPT_RESTART_BLOCK_FUTEX
 };
 
 /* file system */
@@ -378,12 +454,19 @@ struct ckpt_hdr_file_desc {
 
 enum file_type {
 	CKPT_FILE_IGNORE = 0,
+#define CKPT_FILE_IGNORE CKPT_FILE_IGNORE
 	CKPT_FILE_GENERIC,
+#define CKPT_FILE_GENERIC CKPT_FILE_GENERIC
 	CKPT_FILE_PIPE,
+#define CKPT_FILE_PIPE CKPT_FILE_PIPE
 	CKPT_FILE_FIFO,
+#define CKPT_FILE_FIFO CKPT_FILE_FIFO
 	CKPT_FILE_SOCKET,
+#define CKPT_FILE_SOCKET CKPT_FILE_SOCKET
 	CKPT_FILE_TTY,
+#define CKPT_FILE_TTY CKPT_FILE_TTY
 	CKPT_FILE_MAX
+#define CKPT_FILE_MAX CKPT_FILE_MAX
 };
 
 /* file objects */
@@ -503,15 +586,25 @@ struct ckpt_hdr_mm {
 /* vma subtypes - index into restore_vma_dispatch[] */
 enum vma_type {
 	CKPT_VMA_IGNORE = 0,
+#define CKPT_VMA_IGNORE CKPT_VMA_IGNORE
 	CKPT_VMA_VDSO,		/* special vdso vma */
+#define CKPT_VMA_VDSO CKPT_VMA_VDSO
 	CKPT_VMA_ANON,		/* private anonymous */
+#define CKPT_VMA_ANON CKPT_VMA_ANON
 	CKPT_VMA_FILE,		/* private mapped file */
+#define CKPT_VMA_FILE CKPT_VMA_FILE
 	CKPT_VMA_SHM_ANON,	/* shared anonymous */
+#define CKPT_VMA_SHM_ANON CKPT_VMA_SHM_ANON
 	CKPT_VMA_SHM_ANON_SKIP,	/* shared anonymous (skip contents) */
+#define CKPT_VMA_SHM_ANON_SKIP CKPT_VMA_SHM_ANON_SKIP
 	CKPT_VMA_SHM_FILE,	/* shared mapped file, only msync */
+#define CKPT_VMA_SHM_FILE CKPT_VMA_SHM_FILE
 	CKPT_VMA_SHM_IPC,	/* shared sysvipc */
+#define CKPT_VMA_SHM_IPC CKPT_VMA_SHM_IPC
 	CKPT_VMA_SHM_IPC_SKIP,	/* shared sysvipc (skip contents) */
-	CKPT_VMA_MAX,
+#define CKPT_VMA_SHM_IPC_SKIP CKPT_VMA_SHM_IPC_SKIP
+	CKPT_VMA_MAX
+#define CKPT_VMA_MAX CKPT_VMA_MAX
 };
 
 /* vma descriptor */
-- 
1.5.6.3
