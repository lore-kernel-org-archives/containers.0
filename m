From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 2/2] c/r: [x86] save/restore 'sysenter_return' for threads
Date: Sun, 11 Jul 2010 22:05:22 -0400
Message-ID: <1278900322-15287-2-git-send-email-orenl@cs.columbia.edu>
References: <1278900322-15287-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1278900322-15287-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On x86 architecture, save/restore the 'thread_info->sysenter_return'
of tasks. This fixes crashes of threads immediately after restart.

This field is set in arch_setup_additional_pages() for thread group
leaders, and then inherited by threads. At restart, we first create
all tasks (and threads) and then restore their MMs. In particular, we
call arch_setup_additional_page() again, which may re-map the vdso
page to the saved location. However, we only do so explicitly to the
thread group leader, so the 'sysenter_return' pointers of the threads
aren't automatically adjusted.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/include/asm/checkpoint_hdr.h |    1 +
 arch/x86/kernel/checkpoint.c          |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 535a9c6..0505329 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -82,6 +82,7 @@ struct ckpt_hdr_header_arch {
 
 struct ckpt_hdr_thread {
 	struct ckpt_hdr h;
+	__u64 sysenter_return;
 	__u32 thread_info_flags;
 	__u16 gdt_entry_tls_entries;
 	__u16 sizeof_tls_array;
diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoint.c
index 0258245..3fb9deb 100644
--- a/arch/x86/kernel/checkpoint.c
+++ b/arch/x86/kernel/checkpoint.c
@@ -103,6 +103,8 @@ int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 		task_thread_info(t)->flags & ~CKPT_X86_TIF_UNSUPPORTED;
 	h->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
 	h->sizeof_tls_array = tls_size;
+	h->sysenter_return = (__u64) (unsigned long)
+		task_thread_info(current)->sysenter_return;
 
 	/* For simplicity dump the entire array */
 	memcpy(h + 1, t->thread.tls_array, tls_size);
@@ -297,6 +299,9 @@ int restore_thread(struct ckpt_ctx *ctx)
 		}
 	}
 
+	task_thread_info(current)->sysenter_return =
+		(void __user *) (unsigned long) h->sysenter_return;
+
 	/* TODO: restore TIF flags as necessary (e.g. TIF_NOTSC) */
 
 	ret = 0;
-- 
1.7.0.4
