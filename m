From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][usercr] Add numeric hdr.type to ckptinfo
Date: Tue, 20 Apr 2010 19:23:14 -0700
Message-ID: <20100421022314.GA25133@us.ibm.com>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 20 Apr 2010 19:08:08 -0700
Subject: [PATCH 1/1] Add the numeric value of hdr.type

Debug messaages into dmesg rightly print only the numeric value of the
CKPT_HDR type. ckptinfo prints the descriptive macro. But to correlate
the two, one has to dive into the source to find the record type say 302
in dmesg and then find CKPT_HDR_FILE_DESC in ckptinfo output. Would be
easier if ckptinfo printed both the numeric value and descriptive macro.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 ckptinfo.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ckptinfo.c b/ckptinfo.c
index 6190301..09b9db4 100644
--- a/ckptinfo.c
+++ b/ckptinfo.c
@@ -182,8 +182,8 @@ static int image_read_obj(int fd, struct ckpt_hdr **hh)
 	if (ret == 0)
 		return 0;
 
-	VERBOSE("info: [@%lu] object %s len %d\n",
-		__filepos, hdr_to_str(h.type), h.len);
+	VERBOSE("info: [@%lu] object %3d %s len %d\n",
+		__filepos, h.type, hdr_to_str(h.type), h.len);
 
 	p = malloc(h.len);
 	if (!p) {
-- 
1.6.6.1
