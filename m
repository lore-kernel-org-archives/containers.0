From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] Avoid memcpy overruns in fill|load_sigset()
Date: Fri, 13 Nov 2009 15:05:04 -0800
Message-ID: <41033d2ce4f31d016400bde1c5d393ae6f6b856a.1258153503.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Only copy the minimum size of the two structs. I believe gcc
will recognize that these are constants so the resulting code
should be the same size and just as fast.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/signal.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 989b974..c65ee00 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -22,12 +22,12 @@
 
 static inline void fill_sigset(struct ckpt_sigset *h, sigset_t *sigset)
 {
-	memcpy(&h->sigset, sigset, sizeof(*sigset));
+	memcpy(&h->sigset, sigset, min(sizeof(*h), sizeof(*sigset)));
 }
 
 static inline void load_sigset(sigset_t *sigset, struct ckpt_sigset *h)
 {
-	memcpy(sigset, &h->sigset, sizeof(*sigset));
+	memcpy(sigset, &h->sigset, min(sizeof(*h), sizeof(*sigset)));
 }
 
 /***********************************************************************
-- 
1.6.3.3
