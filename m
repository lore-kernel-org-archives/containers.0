From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][user-cr]: ckptinfo: Have -v imply -p option
Date: Fri, 19 Feb 2010 11:36:43 -0800
Message-ID: <20100219193643.GA332@us.ibm.com>
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


Do we even need the -p option ? It is not used without the -v at present.
Can we drop the -p and have -v print filepos always ?

---
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 19 Feb 2010 11:19:08 -0800
Subject: [PATCH 1/1] ckptinfo: Have -v imply -p

When the -v is chosen, user wants verbose debug information. The
filepos would be useful to correlate with the kernel debug messages
and does not clutter the output.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 ckptinfo.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ckptinfo.c b/ckptinfo.c
index 6859742..be91b80 100644
--- a/ckptinfo.c
+++ b/ckptinfo.c
@@ -135,7 +135,7 @@ int main(int argc, char *argv[])
 
 	if (args.verbose)
 		__verbose = 1;
-	if (args.position)
+	if (args.position || args.verbose)
 		__position = 1;
 
 	argc -= optind;
-- 
1.6.6.1
