From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 1/2] add SA_CLDREBOOT flag
Date: Thu, 11 Aug 2011 22:24:00 +0200
Message-ID: <1313094241-3674-2-git-send-email-daniel.lezcano__40645.1113442474$1313094758$gmane$org@free.fr>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1313094241-3674-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Add the SA_CLDREBOOT flag to enable the CLD_REBOOT on SIGCHLD
when a process of a child pid namespace calls the reboot syscall.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
---
 arch/alpha/include/asm/signal.h   |    2 ++
 arch/arm/include/asm/signal.h     |    2 ++
 arch/avr32/include/asm/signal.h   |    2 ++
 arch/cris/include/asm/signal.h    |    2 ++
 arch/h8300/include/asm/signal.h   |    2 ++
 arch/ia64/include/asm/signal.h    |    2 ++
 arch/m32r/include/asm/signal.h    |    2 ++
 arch/m68k/include/asm/signal.h    |    2 ++
 arch/mips/include/asm/signal.h    |    2 ++
 arch/mn10300/include/asm/signal.h |    2 ++
 arch/parisc/include/asm/signal.h  |    2 ++
 arch/powerpc/include/asm/signal.h |    2 ++
 arch/s390/include/asm/signal.h    |    2 ++
 arch/sparc/include/asm/signal.h   |    2 +-
 arch/x86/include/asm/signal.h     |    2 ++
 arch/xtensa/include/asm/signal.h  |    2 ++
 include/asm-generic/signal.h      |    2 ++
 17 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/arch/alpha/include/asm/signal.h b/arch/alpha/include/asm/signal.h
index a938830..40a2285 100644
--- a/arch/alpha/include/asm/signal.h
+++ b/arch/alpha/include/asm/signal.h
@@ -82,6 +82,7 @@ typedef unsigned long sigset_t;
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
+ * SA_CLDREBOOT flag to turn on SIGCHLD when pid namespace calls reboot
  *
  * SA_ONESHOT and SA_NOMASK are the historical Linux names for the Single
  * Unix names RESETHAND and NODEFER respectively.
@@ -94,6 +95,7 @@ typedef unsigned long sigset_t;
 #define SA_RESETHAND	0x00000010
 #define SA_NOCLDWAIT	0x00000020
 #define SA_SIGINFO	0x00000040
+#define SA_CLDREBOOT    0x00000080
 
 #define SA_ONESHOT	SA_RESETHAND
 #define SA_NOMASK	SA_NODEFER
diff --git a/arch/arm/include/asm/signal.h b/arch/arm/include/asm/signal.h
index 43ba0fb..2b585ec 100644
--- a/arch/arm/include/asm/signal.h
+++ b/arch/arm/include/asm/signal.h
@@ -78,6 +78,7 @@ typedef unsigned long sigset_t;
  * SA_NOCLDSTOP		flag to turn off SIGCHLD when children stop.
  * SA_NOCLDWAIT		flag on SIGCHLD to inhibit zombies.
  * SA_SIGINFO		deliver the signal with SIGINFO structs
+ * SA_CLDREBOOT         flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_THIRTYTWO		delivers the signal in 32-bit mode, even if the task 
  *			is running in 26-bit.
  * SA_ONSTACK		allows alternate signal stacks (see sigaltstack(2)).
@@ -91,6 +92,7 @@ typedef unsigned long sigset_t;
 #define SA_NOCLDSTOP	0x00000001
 #define SA_NOCLDWAIT	0x00000002
 #define SA_SIGINFO	0x00000004
+#define SA_CLDREBOOT    0x00000008
 #define SA_THIRTYTWO	0x02000000
 #define SA_RESTORER	0x04000000
 #define SA_ONSTACK	0x08000000
diff --git a/arch/avr32/include/asm/signal.h b/arch/avr32/include/asm/signal.h
index 8790dfc..a025546 100644
--- a/arch/avr32/include/asm/signal.h
+++ b/arch/avr32/include/asm/signal.h
@@ -83,6 +83,7 @@ typedef unsigned long sigset_t;
  * SA_NOCLDSTOP		flag to turn off SIGCHLD when children stop.
  * SA_NOCLDWAIT		flag on SIGCHLD to inhibit zombies.
  * SA_SIGINFO		deliver the signal with SIGINFO structs
+ * SA_CLDREBOOT         flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_ONSTACK		indicates that a registered stack_t will be used.
  * SA_RESTART		flag to get restarting signals (which were the default long ago)
  * SA_NODEFER		prevents the current signal from being masked in the handler.
@@ -94,6 +95,7 @@ typedef unsigned long sigset_t;
 #define SA_NOCLDSTOP	0x00000001
 #define SA_NOCLDWAIT	0x00000002
 #define SA_SIGINFO	0x00000004
+#define SA_CLDREBOOT    0x00000008
 #define SA_RESTORER	0x04000000
 #define SA_ONSTACK	0x08000000
 #define SA_RESTART	0x10000000
diff --git a/arch/cris/include/asm/signal.h b/arch/cris/include/asm/signal.h
index ea6af9a..fa804f0 100644
--- a/arch/cris/include/asm/signal.h
+++ b/arch/cris/include/asm/signal.h
@@ -76,6 +76,7 @@ typedef unsigned long sigset_t;
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -87,6 +88,7 @@ typedef unsigned long sigset_t;
 #define SA_NOCLDSTOP	0x00000001u
 #define SA_NOCLDWAIT	0x00000002u
 #define SA_SIGINFO	0x00000004u
+#define SA_CLDREBOOT    0x00000008u
 #define SA_ONSTACK	0x08000000u
 #define SA_RESTART	0x10000000u
 #define SA_NODEFER	0x40000000u
diff --git a/arch/h8300/include/asm/signal.h b/arch/h8300/include/asm/signal.h
index fd8b66e..13b4b5a 100644
--- a/arch/h8300/include/asm/signal.h
+++ b/arch/h8300/include/asm/signal.h
@@ -76,6 +76,7 @@ typedef unsigned long sigset_t;
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT         flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -86,6 +87,7 @@ typedef unsigned long sigset_t;
 #define SA_NOCLDSTOP	0x00000001
 #define SA_NOCLDWAIT	0x00000002 /* not supported yet */
 #define SA_SIGINFO	0x00000004
+#define SA_CLDREBOOT    0x00000008
 #define SA_ONSTACK	0x08000000
 #define SA_RESTART	0x10000000
 #define SA_NODEFER	0x40000000
diff --git a/arch/ia64/include/asm/signal.h b/arch/ia64/include/asm/signal.h
index b166248..30245a1 100644
--- a/arch/ia64/include/asm/signal.h
+++ b/arch/ia64/include/asm/signal.h
@@ -58,6 +58,7 @@
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -68,6 +69,7 @@
 #define SA_NOCLDSTOP	0x00000001
 #define SA_NOCLDWAIT	0x00000002
 #define SA_SIGINFO	0x00000004
+#define SA_CLDREBOOT    0x00000008
 #define SA_ONSTACK	0x08000000
 #define SA_RESTART	0x10000000
 #define SA_NODEFER	0x40000000
diff --git a/arch/m32r/include/asm/signal.h b/arch/m32r/include/asm/signal.h
index b2eeb0d..c547212 100644
--- a/arch/m32r/include/asm/signal.h
+++ b/arch/m32r/include/asm/signal.h
@@ -78,6 +78,7 @@ typedef unsigned long sigset_t;
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT         flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -88,6 +89,7 @@ typedef unsigned long sigset_t;
 #define SA_NOCLDSTOP	0x00000001u
 #define SA_NOCLDWAIT	0x00000002u
 #define SA_SIGINFO	0x00000004u
+#define SA_CLDREBOOT    0x00000008u
 #define SA_ONSTACK	0x08000000u
 #define SA_RESTART	0x10000000u
 #define SA_NODEFER	0x40000000u
diff --git a/arch/m68k/include/asm/signal.h b/arch/m68k/include/asm/signal.h
index 60e8866..14334b2 100644
--- a/arch/m68k/include/asm/signal.h
+++ b/arch/m68k/include/asm/signal.h
@@ -76,6 +76,7 @@ typedef unsigned long sigset_t;
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -86,6 +87,7 @@ typedef unsigned long sigset_t;
 #define SA_NOCLDSTOP	0x00000001
 #define SA_NOCLDWAIT	0x00000002
 #define SA_SIGINFO	0x00000004
+#define SA_CLDREBOOT    0x00000008
 #define SA_ONSTACK	0x08000000
 #define SA_RESTART	0x10000000
 #define SA_NODEFER	0x40000000
diff --git a/arch/mips/include/asm/signal.h b/arch/mips/include/asm/signal.h
index c783f36..acf7494 100644
--- a/arch/mips/include/asm/signal.h
+++ b/arch/mips/include/asm/signal.h
@@ -66,6 +66,7 @@ typedef unsigned long old_sigset_t;		/* at least 32 bits */
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -80,6 +81,7 @@ typedef unsigned long old_sigset_t;		/* at least 32 bits */
 #define SA_NODEFER	0x40000000
 #define SA_NOCLDWAIT	0x00010000
 #define SA_NOCLDSTOP	0x00000001
+#define SA_CLDREBOOT    0x00000002
 
 #define SA_NOMASK	SA_NODEFER
 #define SA_ONESHOT	SA_RESETHAND
diff --git a/arch/mn10300/include/asm/signal.h b/arch/mn10300/include/asm/signal.h
index 1865d72..ad1f454 100644
--- a/arch/mn10300/include/asm/signal.h
+++ b/arch/mn10300/include/asm/signal.h
@@ -86,6 +86,7 @@ typedef unsigned long sigset_t;
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -96,6 +97,7 @@ typedef unsigned long sigset_t;
 #define SA_NOCLDSTOP	0x00000001U
 #define SA_NOCLDWAIT	0x00000002U
 #define SA_SIGINFO	0x00000004U
+#define SA_CLDREBOOT    0x00000008U
 #define SA_ONSTACK	0x08000000U
 #define SA_RESTART	0x10000000U
 #define SA_NODEFER	0x40000000U
diff --git a/arch/parisc/include/asm/signal.h b/arch/parisc/include/asm/signal.h
index c203563..85c2fec 100644
--- a/arch/parisc/include/asm/signal.h
+++ b/arch/parisc/include/asm/signal.h
@@ -50,6 +50,7 @@
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT         flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -58,6 +59,7 @@
  * Unix names RESETHAND and NODEFER respectively.
  */
 #define SA_ONSTACK	0x00000001
+#define SA_CLDREBOOT    0x00000002
 #define SA_RESETHAND	0x00000004
 #define SA_NOCLDSTOP	0x00000008
 #define SA_SIGINFO	0x00000010
diff --git a/arch/powerpc/include/asm/signal.h b/arch/powerpc/include/asm/signal.h
index 3eb13be..f96e2d5 100644
--- a/arch/powerpc/include/asm/signal.h
+++ b/arch/powerpc/include/asm/signal.h
@@ -65,6 +65,7 @@ typedef struct {
  * SA_ONSTACK is not currently supported, but will allow sigaltstack(2).
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -75,6 +76,7 @@ typedef struct {
 #define SA_NOCLDSTOP	0x00000001U
 #define SA_NOCLDWAIT	0x00000002U
 #define SA_SIGINFO	0x00000004U
+#define SA_CLDREBOOT    0x00000008U
 #define SA_ONSTACK	0x08000000U
 #define SA_RESTART	0x10000000U
 #define SA_NODEFER	0x40000000U
diff --git a/arch/s390/include/asm/signal.h b/arch/s390/include/asm/signal.h
index cdf5cb2..449a2dc 100644
--- a/arch/s390/include/asm/signal.h
+++ b/arch/s390/include/asm/signal.h
@@ -86,6 +86,7 @@ typedef unsigned long sigset_t;
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT  flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -96,6 +97,7 @@ typedef unsigned long sigset_t;
 #define SA_NOCLDSTOP    0x00000001
 #define SA_NOCLDWAIT    0x00000002
 #define SA_SIGINFO      0x00000004
+#define SA_CLDREBOOT    0x00000008
 #define SA_ONSTACK      0x08000000
 #define SA_RESTART      0x10000000
 #define SA_NODEFER      0x40000000
diff --git a/arch/sparc/include/asm/signal.h b/arch/sparc/include/asm/signal.h
index e49b828..26cbd7e 100644
--- a/arch/sparc/include/asm/signal.h
+++ b/arch/sparc/include/asm/signal.h
@@ -146,7 +146,7 @@ struct sigstack {
 #define SA_NOMASK	0x20u
 #define SA_NOCLDWAIT    0x100u
 #define SA_SIGINFO      0x200u
-
+#define SA_CLDREBOOT    0x400u
 
 #define SIG_BLOCK          0x01	/* for blocking signals */
 #define SIG_UNBLOCK        0x02	/* for unblocking signals */
diff --git a/arch/x86/include/asm/signal.h b/arch/x86/include/asm/signal.h
index 598457c..83696a5 100644
--- a/arch/x86/include/asm/signal.h
+++ b/arch/x86/include/asm/signal.h
@@ -90,6 +90,7 @@ typedef unsigned long sigset_t;
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
+ * SA_CLDREBOOT flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_NODEFER prevents the current signal from being masked in the handler.
  *
  * SA_ONESHOT and SA_NOMASK are the historical Linux names for the Single
@@ -98,6 +99,7 @@ typedef unsigned long sigset_t;
 #define SA_NOCLDSTOP	0x00000001u
 #define SA_NOCLDWAIT	0x00000002u
 #define SA_SIGINFO	0x00000004u
+#define SA_CLDREBOOT    0x00000008u
 #define SA_ONSTACK	0x08000000u
 #define SA_RESTART	0x10000000u
 #define SA_NODEFER	0x40000000u
diff --git a/arch/xtensa/include/asm/signal.h b/arch/xtensa/include/asm/signal.h
index 633ba73..5961f12 100644
--- a/arch/xtensa/include/asm/signal.h
+++ b/arch/xtensa/include/asm/signal.h
@@ -77,6 +77,7 @@ typedef struct {
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_CLDREBOOT flag to turn on SIGCHLD when pid namespace calls reboot
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -87,6 +88,7 @@ typedef struct {
 #define SA_NOCLDSTOP	0x00000001
 #define SA_NOCLDWAIT	0x00000002 /* not supported yet */
 #define SA_SIGINFO	0x00000004
+#define SA_CLDREBOOT    0x00000008
 #define SA_ONSTACK	0x08000000
 #define SA_RESTART	0x10000000
 #define SA_NODEFER	0x40000000
diff --git a/include/asm-generic/signal.h b/include/asm-generic/signal.h
index 555c0ae..504f910 100644
--- a/include/asm-generic/signal.h
+++ b/include/asm-generic/signal.h
@@ -57,6 +57,7 @@
  * SA_ONSTACK indicates that a registered stack_t will be used.
  * SA_RESTART flag to get restarting signals (which were the default long ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
+ * SA_REBOOT flag to turn on SIGCHLD when pid namespace reboots
  * SA_RESETHAND clears the handler when the signal is delivered.
  * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
  * SA_NODEFER prevents the current signal from being masked in the handler.
@@ -67,6 +68,7 @@
 #define SA_NOCLDSTOP	0x00000001
 #define SA_NOCLDWAIT	0x00000002
 #define SA_SIGINFO	0x00000004
+#define SA_CLDREBOOT    0x00000004
 #define SA_ONSTACK	0x08000000
 #define SA_RESTART	0x10000000
 #define SA_NODEFER	0x40000000
-- 
1.7.4.1
