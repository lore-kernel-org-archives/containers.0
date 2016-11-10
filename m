From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] audit: tame initialization warning len_abuf in
	audit_log_execve_info
Date: Thu, 10 Nov 2016 01:39:49 -0500
Message-ID: <55715f3a839b7d38839d02f3d28a90b3476f7046.1478759919.git.rgb__38304.7707764947$1478760052$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Tame initialization warning of len_abuf in audit_log_execve_info even
though there isn't presently a bug introduced by commit 43761473c254
("audit: fix a double fetch in audit_log_single_execve_arg()").  Using
UNINITIALIZED_VAR instead may mask future bugs.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 kernel/auditsc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index e414dfa..d161b17 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1000,7 +1000,7 @@ static void audit_log_execve_info(struct audit_context *context,
 	long len_rem;
 	long len_full;
 	long len_buf;
-	long len_abuf;
+	long len_abuf = 0;
 	long len_tmp;
 	bool require_data;
 	bool encode;
-- 
1.7.1
