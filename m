From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cr_tests: Fix quoting in common.sh
Date: Sun, 12 Jul 2009 20:25:26 -0700
Message-ID: <20090713032526.GD5213@count0.beaverton.ibm.com>
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
To: Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

When doing a very quick scan of shell script it's hard to notice the
difference between ' and `.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
Caught by my vim config which does syntax highlighting. Otherwise I
might not have noticed.

 common.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/common.sh b/common.sh
index 002cd47..d889242 100644
--- a/common.sh
+++ b/common.sh
@@ -50,13 +50,13 @@ thaw()
 
 get_ltp_user()
 {
-	awk -F: '{ print $1 '} /etc/passwd | grep "\<ltp\>"
+	awk -F: '{ print $1 }' /etc/passwd | grep "\<ltp\>"
 	if [ $? -ne 0 ]; then
 		echo "I refuse to mess with your password file"
 		echo "please create a user named ltp"
 		uid=-1
 	fi
-	uid=`grep "\<ltp\>" /etc/passwd | awk -F: '{ print $3 '}`
+	uid=`grep "\<ltp\>" /etc/passwd | awk -F: '{ print $3 }'`
 }
 
 handlesigusr1()
-- 
1.5.6.3
