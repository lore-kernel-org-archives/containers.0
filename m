From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/18] user-cr: Avoid redundant definitions
Date: Thu, 17 Mar 2011 10:27:42 -0700
Message-ID: <65466a734e085f916c776de153dfddf1c60aea7b.1300382276.git.matthltc@us.ibm.com>
References: <1300382870-28486-1-git-send-email-matthltc@us.ibm.com>
	<beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc@us.ibm.com>
	<1525d5365ced342871277f7a94a42bcd960c04a9.1300382276.git.matthltc@us.ibm.com>
	<ccf68c276e54e7cb9dce0df9b8fec8391dd0e349.1300382276.git.matthltc@us.ibm.com>
	<143894c882d1339322b36ea459531a7debec7f29.1300382276.git.matthltc@us.ibm.com>
	<c9471f79da9f1ddbbbc9d8f565951c2bc5fd5ee7.1300382276.git.matthltc@us.ibm.com>
	<5a316654b4cc0a18ae05f012ab69b86dbc4b21dd.1300382276.git.matthltc@us.ibm.com>
	<4fa9581395e8ce3b7317a221321e15321b01f534.1300382276.git.matthltc@us.ibm.com>
	<da8b6651fb9271826e35ba47d9e41883b63bfee0.1300382276.git.matthltc@us.ibm.com>
	<4b6b9f5cc66c1675d6249622455709d6c5d586c9.1300382276.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4b6b9f5cc66c1675d6249622455709d6c5d586c9.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Use a dictionary to collapse multiple definitions of the same enum --
we don't want to output it twice because that will cause a compilation
error. This can happen if we have a comment or other poorly-formatted code
which matches one of the regexes.

Later it might be good to track the values and ensure they match before
collapsing the definitions. If they don't match *then* we should trigger
a compilation error.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ckptinfo.py |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/ckptinfo.py b/ckptinfo.py
index bea1b5d..08ee92c 100755
--- a/ckptinfo.py
+++ b/ckptinfo.py
@@ -17,31 +17,31 @@ regx_obj = re.compile(r"^(\s*CKPT_)(OBJ_[A-Z_]*)")
 regx_file = re.compile(r"^(\s*CKPT_)(FILE_[A-Z_]*)")
 regx_vma = re.compile(r"^(\s*CKPT_)(VMA_[A-Z_]*)")
 
-list_hdr = []
-list_obj = []
-list_file = []
-list_vma = []
+enums_hdr = {}
+enums_obj = {}
+enums_file = {}
+enums_vma = {}
 
 lineno = 1
 
-def match_something(line, regx, list, type):
+def match_something(line, regx, enum_set, type):
     match = regx.search(line)
     if match:
         if match.lastindex != 2:
             print "Multiple %s... matches on line %d" % (type, lineno)
             sys.exit(1)
-        list.append(match.group(2))
+        enum_set[match.group(2)] = True
         return 1
     else:
         return 0
 
-def print_something(list, type):
+def print_something(enum_set, type):
     print """
 char *%s_to_str(int type)
 {
 	switch (type) {
 """ % type
-    for key in list:
+    for key in enum_set.keys():
         print "\tcase CKPT_%s: return \"%s\";\n" % (key, key)
 
     print """
@@ -60,13 +60,13 @@ while (1):
     line = sys.stdin.readline()
     if line == "": break
 
-    if match_something(line, regx_hdr, list_hdr, "CKPT_HDR_..."):
+    if match_something(line, regx_hdr, enums_hdr, "CKPT_HDR_..."):
         pass
-    elif match_something(line, regx_obj, list_obj, "CKPT_OBJ_..."):
+    elif match_something(line, regx_obj, enums_obj, "CKPT_OBJ_..."):
         pass
-    elif match_something(line, regx_file, list_file, "CKPT_FILE_..."):
+    elif match_something(line, regx_file, enums_file, "CKPT_FILE_..."):
         pass
-    elif match_something(line, regx_vma, list_vma, "CKPT_VMA_..."):
+    elif match_something(line, regx_vma, enums_vma, "CKPT_VMA_..."):
         pass
 
 # Now output the appropriate C code for switch statements that
@@ -82,9 +82,9 @@ print """
 #include <linux/checkpoint_hdr.h>
 """
 
-print_something(list_hdr, "hdr")
-print_something(list_obj, "obj")
-print_something(list_file, "file")
-print_something(list_vma, "vma")
+print_something(enums_hdr, "hdr")
+print_something(enums_obj, "obj")
+print_something(enums_file, "file")
+print_something(enums_vma, "vma")
 
 # Done
-- 
1.6.3.3
