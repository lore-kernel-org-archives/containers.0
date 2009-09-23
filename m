From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] user-cr: s390: CPU parsing isn't wired properly
Date: Wed, 23 Sep 2009 15:03:38 -0700
Message-ID: <1253743418-10091-1-git-send-email-matthltc@us.ibm.com>
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
 ckptinfo.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/ckptinfo.c b/ckptinfo.c
index 45e3c6b..b2101e6 100644
--- a/ckptinfo.c
+++ b/ckptinfo.c
@@ -63,6 +63,10 @@ static int image_parse_error(struct ckpt_hdr *h, int fd, struct args *args);
 #define __HAVE_image_parse_cpu
 #define image_parse_cpu   image_parse_cpu_X86
 static int image_parse_cpu_X86(struct ckpt_hdr *h, int fd, struct args *args);
+#elif defined(__s390__)
+#define __HAVE_image_parse_cpu
+#define image_parse_cpu   image_parse_cpu_s390
+static int image_parse_cpu_s390(struct ckpt_hdr *h, int fd, struct args *args);
 #else
 static int image_parse_cpu(struct ckpt_hdr *h, int fd, struct args *args);
 #endif
-- 
1.5.6.3
