From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 8/9] ckptinfo: s/ckpt_pids/ckpt_task_pids/ after kerenl header
	update
Date: Wed, 26 Jan 2011 11:19:07 -0500
Message-ID: <1296058748-21418-9-git-send-email-orenl@cs.columbia.edu>
References: <1296058748-21418-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1296058748-21418-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
List-Id: containers.vger.kernel.org

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 ckptinfo.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ckptinfo.c b/ckptinfo.c
index d73b38c..1361c21 100644
--- a/ckptinfo.c
+++ b/ckptinfo.c
@@ -254,7 +254,7 @@ static int image_parse(int fd, struct args *args)
 static int image_parse_tree(struct ckpt_hdr *h, int fd, struct args *args)
 {
 	struct ckpt_hdr_tree *hh;
-	struct ckpt_pids *pp;
+	struct ckpt_task_pids *pp;
 	int nr_tasks;
 	int i, ret;
 
@@ -268,7 +268,7 @@ static int image_parse_tree(struct ckpt_hdr *h, int fd, struct args *args)
 	if (ret <= 0)
 		return -1;
 
-	pp =  (struct ckpt_pids *) h;
+	pp =  (struct ckpt_task_pids *) h;
 
 	if (args->show_task_tree) {
 		for (i = 0; i < nr_tasks; i++) {
-- 
1.7.1
