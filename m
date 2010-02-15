From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] ignore -eexist for mkdir of a cgroup
Date: Mon, 15 Feb 2010 16:58:15 -0600
Message-ID: <1266274696-23018-3-git-send-email-serue@us.ibm.com>
References: <1266274696-23018-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1266274696-23018-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 nsexec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nsexec.c b/nsexec.c
index 859b6c3..8b96bc9 100644
--- a/nsexec.c
+++ b/nsexec.c
@@ -146,7 +146,7 @@ int move_to_new_cgroup(int newcgroup)
 
 	snprintf(cgroupname, 150, "%s/%d", cgroupbase, newcgroup);
 	ret = mkdir(cgroupname, 0755);
-	if (ret)
+	if (ret && errno != EEXIST)
 		return 0;
 	snprintf(tasksfname, 200, "%s/tasks", cgroupname);
 	fout = fopen(tasksfname, "w");
-- 
1.6.0.6
