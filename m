From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 3/4] kill 'Enable' in c/r config option
Date: Fri, 05 Jun 2009 12:15:28 -0700
Message-ID: <20090605191528.10AC5D2F@kernel>
References: <20090605191525.C3F1C2F2@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090605191525.C3F1C2F2@kernel>
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
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


We don't neeeed to say 'Enable'.  That's what Kconfig does
for everything. :)


---

 linux-2.6.git-dave/checkpoint/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN checkpoint/Kconfig~kill-Enabled checkpoint/Kconfig
--- linux-2.6.git/checkpoint/Kconfig~kill-Enabled	2009-06-05 11:46:01.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/Kconfig	2009-06-05 11:57:46.000000000 -0700
@@ -7,7 +7,7 @@ config DEFERQUEUE
 	default n
 
 config CHECKPOINT
-	bool "Enable checkpoint/restart (EXPERIMENTAL)"
+	bool "Checkpoint/restart (EXPERIMENTAL)"
 	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
 	select DEFERQUEUE
 	help
_
