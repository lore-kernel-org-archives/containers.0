From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] Make extract_headers.sh grab setns as well
Date: Wed,  2 Mar 2011 13:35:23 -0800
Message-ID: <1299101725-17603-2-git-send-email-danms@us.ibm.com>
References: <1299101725-17603-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1299101725-17603-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 scripts/extract-headers.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/extract-headers.sh b/scripts/extract-headers.sh
index 19f63b4..e83ed2b 100755
--- a/scripts/extract-headers.sh
+++ b/scripts/extract-headers.sh
@@ -154,7 +154,7 @@ ARM_SYSCALL_BASE="#	define __NR_OABI_SYSCALL_BASE 0x900000\n\
 # Get the regular expression for the current architecture
 function get_unistd_regex()
 {
-	local SYS_NR_DEF_REGEX='[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+'
+	local SYS_NR_DEF_REGEX='[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids|setns)[[:space:]]+'
 
 	case "$1" in
 	arm)	echo -n "${SYS_NR_DEF_REGEX}"
-- 
1.7.2.2
