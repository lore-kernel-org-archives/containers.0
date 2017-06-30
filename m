From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 1/8] signal/alpha: Document a conflict with SI_USER for SIGTRAP
Date: Fri, 30 Jun 2017 07:38:59 -0500
Message-ID: <20170630123906.8865-1-ebiederm__21494.8469693356$1498826825$gmane$org@xmission.com>
References: <87efu22set.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87efu22set.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ivan Kokshaysky <ink-biIs/Y0ymYJMZLIVYojuPNP0rXTJTi09@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Richard Henderson <rth-hL46jP5Bxq7R7s880joybQ@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Setting si_code to __SI_FAULT results in a userspace seeing
an si_code of 0.  This is the same si_code as SI_USER.  Posix
and common sense requires that SI_USER not be a signal specific
si_code.  As such this use of 0 for the si_code is a pretty
horribly broken ABI.

Given that alpha is on it's last legs I don't know that it is worth
fixing this, but it is worth documenting what is going on so that
no one decides to copy this bad decision.

This was introduced during the 2.5 development cycle so this
mess has had a long time for people to be able to depend upon it.

Cc: Richard Henderson <rth-hL46jP5Bxq7R7s880joybQ@public.gmane.org>
Cc: Ivan Kokshaysky <ink-biIs/Y0ymYJMZLIVYojuPNP0rXTJTi09@public.gmane.org>
Cc: Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
History Tree: https://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git
Ref: 0a635c7a84cf ("Fill in siginfo_t.")
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 arch/alpha/include/uapi/asm/siginfo.h | 5 +++++
 arch/alpha/kernel/traps.c             | 6 +++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/siginfo.h b/arch/alpha/include/uapi/asm/siginfo.h
index 9822362a8424..687e4972971b 100644
--- a/arch/alpha/include/uapi/asm/siginfo.h
+++ b/arch/alpha/include/uapi/asm/siginfo.h
@@ -6,4 +6,9 @@
 
 #include <asm-generic/siginfo.h>
 
+/*
+ * SIGTRAP si_codes
+ */
+#define TRAP_FIXME	(__SI_FAULT|0)	/* Broken dup of SI_USER */
+
 #endif
diff --git a/arch/alpha/kernel/traps.c b/arch/alpha/kernel/traps.c
index 65bb102d985b..37c4fc91b215 100644
--- a/arch/alpha/kernel/traps.c
+++ b/arch/alpha/kernel/traps.c
@@ -278,7 +278,7 @@ do_entIF(unsigned long type, struct pt_regs *regs)
 	      case 1: /* bugcheck */
 		info.si_signo = SIGTRAP;
 		info.si_errno = 0;
-		info.si_code = __SI_FAULT;
+		info.si_code = TRAP_FIXME;
 		info.si_addr = (void __user *) regs->pc;
 		info.si_trapno = 0;
 		send_sig_info(SIGTRAP, &info, current);
@@ -318,7 +318,7 @@ do_entIF(unsigned long type, struct pt_regs *regs)
 			break;
 		case GEN_ROPRAND:
 			signo = SIGFPE;
-			code = __SI_FAULT;
+			code = TRAP_FIXME;
 			break;
 
 		case GEN_DECOVF:
@@ -340,7 +340,7 @@ do_entIF(unsigned long type, struct pt_regs *regs)
 		case GEN_SUBRNG7:
 		default:
 			signo = SIGTRAP;
-			code = __SI_FAULT;
+			code = TRAP_FIXME;
 			break;
 		}
 
-- 
2.10.1
