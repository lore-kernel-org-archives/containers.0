From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: nsproxy: fix refcounting
Date: Tue, 26 May 2009 17:03:13 -0500
Message-ID: <20090526220313.GA18572@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

[This is the fix for the bug I was trying to nail down earlier today]

If more than one restarted task are to share a checkpointed nsproxy,
then we must inc the count on the nsproxy for each new task, as
switch_task_namespaces() does not do that for us.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/process.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index fa166cd..52d2a9c 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -603,8 +603,10 @@ static int restore_ns_obj(struct ckpt_ctx *ctx, int ns_objref)
 	if (IS_ERR(nsproxy))
 		return PTR_ERR(nsproxy);
 
-	if (nsproxy != task_nsproxy(current))
+	if (nsproxy != task_nsproxy(current)) {
+		get_nsproxy(nsproxy);
 		switch_task_namespaces(current, nsproxy);
+	}
 
 	return 0;
 }
-- 
1.6.1
