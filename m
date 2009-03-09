From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] s390 sys_clone is backwards
Date: Mon, 9 Mar 2009 14:28:38 -0500
Message-ID: <20090309192838.GA25727@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Switch the flags and sp for sys_clone for s390.

Without this, lxc-execute gets a segfault on clone (of course).
With this, it succeeds.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 src/lxc/lxc_namespace.h |    4 +++-
 src/lxc/namespace.h     |    4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/src/lxc/lxc_namespace.h b/src/lxc/lxc_namespace.h
index 3bef4a8..ec51cb4 100644
--- a/src/lxc/lxc_namespace.h
+++ b/src/lxc/lxc_namespace.h
@@ -60,8 +60,10 @@
 #    error "unsupported architecture"
 #  endif
 #endif
-#if __i386__ || __x86_64__ || __s390__ || __powerpc__
+#if __i386__ || __x86_64__ || __powerpc__
 #   define fork_ns(flags) syscall(SYS_clone, flags|SIGCHLD, NULL)
+#elif __s390__
+#   define fork_ns(flags) syscall(SYS_clone, NULL, flags|SIGCHLD)
 #elif __ia64__
 #   define fork_ns(flags) syscall(SYS_clone2, flags|SIGCHLD, NULL)
 #else
diff --git a/src/lxc/namespace.h b/src/lxc/namespace.h
index 4059368..004af4b 100644
--- a/src/lxc/namespace.h
+++ b/src/lxc/namespace.h
@@ -60,8 +60,10 @@
 #    error "unsupported architecture"
 #  endif
 #endif
-#if __i386__ || __x86_64__ || __s390__ || __powerpc__
+#if __i386__ || __x86_64__ || __powerpc__
 #   define fork_ns(flags) syscall(SYS_clone, flags|SIGCHLD, NULL);
+#elif __s390__
+#   define fork_ns(flags) syscall(SYS_clone, NULL, flags|SIGCHLD)
 #elif __ia64__
 #   define fork_ns(flags) syscall(SYS_clone2, flags|SIGCHLD, NULL);
 #else
-- 
1.6.1.1
