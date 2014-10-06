From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V5 05/13] audit: initialize at subsystem time rather than
	device time
Date: Mon,  6 Oct 2014 01:08:30 -0400
Message-ID: <7fda57304bb2f74ccb7f610c04df6aa0c04bf4ba.1412543112.git.rgb__34443.0958074101$1412572210$gmane$org@redhat.com>
References: <cover.1412543112.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

The audit subsystem should be initialized a bit earlier so that it is in place
in time for initial namespace serial number logging.
---
 kernel/audit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index ff1630d..8ff7f28 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1186,7 +1186,7 @@ static int __init audit_init(void)
 
 	return 0;
 }
-__initcall(audit_init);
+subsys_initcall(audit_init);
 
 /* Process kernel command-line parameter at boot time.  audit=0 or audit=1. */
 static int __init audit_enable(char *str)
-- 
1.7.1
