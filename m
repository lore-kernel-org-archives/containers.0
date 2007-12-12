From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Mark timer_stats as incompatible with multiple pid namespaces
Date: Wed, 12 Dec 2007 16:10:56 -0700
Message-ID: <m13au7tsov.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760100AbXLLXMt@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


/proc/timer_stats currently reports the user of a timer by pid,
which is a reasonable approach.  However if you are not in
the initial pid namespace the pid that is reported is nonsense.

Therefore until we can make timer_stats pid namespace safe just
disable it in the build if pid namespace support is selected
so we at least know we have a conflict.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 lib/Kconfig.debug |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index cc42773..c8e81e6 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -146,7 +146,7 @@ config SCHEDSTATS
 
 config TIMER_STATS
 	bool "Collect kernel timers statistics"
-	depends on DEBUG_KERNEL && PROC_FS
+	depends on DEBUG_KERNEL && PROC_FS && !PID_NS
 	help
 	  If you say Y here, additional code will be inserted into the
 	  timer routines to collect statistics about kernel timers being
-- 
1.5.3.rc6.17.g1911

