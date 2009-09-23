From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] ckptinfo.py: revert commit
	8f99ace6513f958d572ef690d7af111991124f5c
Date: Tue, 22 Sep 2009 20:16:50 -0400
Message-ID: <1253665010-3472-1-git-send-email-orenl@librato.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Said commit "slightly" broke 'ckptinfo -ve', causing it to produce
only "--UNKNOWN--" objects.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 ckptinfo.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ckptinfo.py b/ckptinfo.py
index add73cb..1c98569 100755
--- a/ckptinfo.py
+++ b/ckptinfo.py
@@ -42,7 +42,7 @@ char *%s_to_str(int type)
 	switch (type) {
 """ % type
     for key in list:
-        print "#ifdef CKPT_%s\n\tcase CKPT_%s: return \"%s\";\n#endif" % (key, key, key)
+        print "\tcase CKPT_%s: return \"%s\";\n" % (key, key)
 
     print """
 	}
-- 
1.6.0.4
