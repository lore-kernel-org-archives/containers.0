From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] user-cr: s390: Detect s390x arch too
Date: Wed, 23 Sep 2009 15:03:39 -0700
Message-ID: <1253743418-10091-2-git-send-email-matthltc@us.ibm.com>
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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ckptinfo.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ckptinfo.c b/ckptinfo.c
index b2101e6..6859742 100644
--- a/ckptinfo.c
+++ b/ckptinfo.c
@@ -63,7 +63,7 @@ static int image_parse_error(struct ckpt_hdr *h, int fd, struct args *args);
 #define __HAVE_image_parse_cpu
 #define image_parse_cpu   image_parse_cpu_X86
 static int image_parse_cpu_X86(struct ckpt_hdr *h, int fd, struct args *args);
-#elif defined(__s390__)
+#elif defined(__s390__) || defined(__s390x__)
 #define __HAVE_image_parse_cpu
 #define image_parse_cpu   image_parse_cpu_s390
 static int image_parse_cpu_s390(struct ckpt_hdr *h, int fd, struct args *args);
@@ -301,7 +301,7 @@ static int image_parse_cpu_X86(struct ckpt_hdr *h, int fd, struct args *args)
 }
 #endif
 
-#ifdef __s390__
+#if defined(__s390__) || defined(__s390x__)
 static int image_parse_cpu_s390(struct ckpt_hdr *h, int fd, struct args *args)
 {
 	struct ckpt_hdr_cpu *hh = (struct ckpt_hdr_cpu *) h;
-- 
1.5.6.3
