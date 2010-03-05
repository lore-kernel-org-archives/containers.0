From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 07/12][user-cr] Define INIT_SIGNAL_ARRAY
Date: Fri, 5 Mar 2010 14:38:46 -0800
Message-ID: <20100305223846.GG15939@us.ibm.com>
References: <20100305223439.GA15300@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100305223439.GA15300-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Thu, 4 Mar 2010 21:15:25 -0800
Subject: [PATCH 07/12][user-cr] Define INIT_SIGNAL_ARRAY

Code to initialize the signal_array[] table will need to be shared by more
than one file. To enable this sharing with, define INIT_SIGNAL_ARRAY which
can later be used in many places.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   76 ++++++++++++++++++++++++++++++++-----------------------------
 1 files changed, 40 insertions(+), 36 deletions(-)

diff --git a/restart.c b/restart.c
index d4a4000..b37bf81 100644
--- a/restart.c
+++ b/restart.c
@@ -157,46 +157,50 @@ static inline void ckpt_msg(int fd, char *format, ...)
 			ckpt_msg(global_ulogfd, __VA_ARGS__);	\
 	} while(0)
 
-#define SIGNAL_ENTRY(signal)  { SIG ## signal, #signal }
-
-struct {
+struct signal_array {
 	int signum;
 	char *sigstr;
-} signal_array[] = {
-	{ 0, "NONE" },
-	SIGNAL_ENTRY(ALRM),
-	SIGNAL_ENTRY(HUP),
-	SIGNAL_ENTRY(INT),
-	SIGNAL_ENTRY(KILL),
-	SIGNAL_ENTRY(PIPE),
-	SIGNAL_ENTRY(POLL),
-	SIGNAL_ENTRY(PROF),
-	SIGNAL_ENTRY(TERM),
-	SIGNAL_ENTRY(USR1),
-	SIGNAL_ENTRY(USR2),
-	SIGNAL_ENTRY(VTALRM),
-	SIGNAL_ENTRY(STKFLT),
-	SIGNAL_ENTRY(PWR),
-	SIGNAL_ENTRY(WINCH),
-	SIGNAL_ENTRY(CHLD),
-	SIGNAL_ENTRY(URG),
-	SIGNAL_ENTRY(TTIN),
-	SIGNAL_ENTRY(TTOU),
-	SIGNAL_ENTRY(STOP),
-	SIGNAL_ENTRY(CONT),
-	SIGNAL_ENTRY(ABRT),
-	SIGNAL_ENTRY(FPE),
-	SIGNAL_ENTRY(ILL),
-	SIGNAL_ENTRY(QUIT),
-	SIGNAL_ENTRY(SEGV),
-	SIGNAL_ENTRY(TRAP),
-	SIGNAL_ENTRY(SYS),
-	SIGNAL_ENTRY(BUS),
-	SIGNAL_ENTRY(XCPU),
-	SIGNAL_ENTRY(XFSZ),
-	{ -1, "LAST" },
 };
 
+#define SIGNAL_ENTRY(signal)  { SIG ## signal, #signal }
+
+#define INIT_SIGNAL_ARRAY { 	\
+	{ 0, "NONE" },		\
+	SIGNAL_ENTRY(ALRM),	\
+	SIGNAL_ENTRY(HUP),	\
+	SIGNAL_ENTRY(INT),	\
+	SIGNAL_ENTRY(KILL),	\
+	SIGNAL_ENTRY(PIPE),	\
+	SIGNAL_ENTRY(POLL),	\
+	SIGNAL_ENTRY(PROF),	\
+	SIGNAL_ENTRY(TERM),	\
+	SIGNAL_ENTRY(USR1),	\
+	SIGNAL_ENTRY(USR2),	\
+	SIGNAL_ENTRY(VTALRM),	\
+	SIGNAL_ENTRY(STKFLT),	\
+	SIGNAL_ENTRY(PWR),	\
+	SIGNAL_ENTRY(WINCH),	\
+	SIGNAL_ENTRY(CHLD),	\
+	SIGNAL_ENTRY(URG),	\
+	SIGNAL_ENTRY(TTIN),	\
+	SIGNAL_ENTRY(TTOU),	\
+	SIGNAL_ENTRY(STOP),	\
+	SIGNAL_ENTRY(CONT),	\
+	SIGNAL_ENTRY(ABRT),	\
+	SIGNAL_ENTRY(FPE),	\
+	SIGNAL_ENTRY(ILL),	\
+	SIGNAL_ENTRY(QUIT),	\
+	SIGNAL_ENTRY(SEGV),	\
+	SIGNAL_ENTRY(TRAP),	\
+	SIGNAL_ENTRY(SYS),	\
+	SIGNAL_ENTRY(BUS),	\
+	SIGNAL_ENTRY(XCPU),	\
+	SIGNAL_ENTRY(XFSZ),	\
+	{ -1, "LAST" },		\
+}
+
+static struct signal_array signal_array[] = INIT_SIGNAL_ARRAY;
+
 static char *sig2str(int sig)
 {
 	int i = 0;
-- 
1.6.0.4
