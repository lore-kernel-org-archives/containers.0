From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/9] cr_tests: fs: A tool to re-fill a tree of dirs and files
Date: Fri, 19 Feb 2010 18:18:52 -0800
Message-ID: <0efaca297a696880440a982210325dc7c473b13d.1266632319.git.matthltc@us.ibm.com>
References: <1266632337-13792-1-git-send-email-matthltc@us.ibm.com>
	<72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc@us.ibm.com>
	<a5516d2e94b044e946ac039172a3d9cab0df0c1f.1266632319.git.matthltc@us.ibm.com>
	<7f04acbefe832b0bfaa832222da150c33af76ca8.1266632319.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7f04acbefe832b0bfaa832222da150c33af76ca8.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/fill_tree.py |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)
 create mode 100755 fs/fill_tree.py

diff --git a/fs/fill_tree.py b/fs/fill_tree.py
new file mode 100755
index 0000000..28a3e55
--- /dev/null
+++ b/fs/fill_tree.py
@@ -0,0 +1,47 @@
+#!/usr/bin/python
+#
+# fill a tree with known contents.
+#
+import optparse
+import sys
+
+# for S_I* (e.g. S_IRWXU)
+from stat import *
+
+# For walk, path.join, open, unlink, close, and O_*
+from os import *
+
+# Root of the tree to check
+root = None
+
+# Like os.walk() but assumes root and followlinks = False
+# (which prevents likely-unwanted removal of files for the
+#  purposes of this test script)
+def rwalk(**kw):
+	kw['followlinks'] = False
+	return walk(root, **kw)
+
+# Alias path.join -> join
+def join(*args):
+	return path.join(*args)
+
+if __name__ == '__main__':
+	parser = optparse.OptionParser()
+	parser.add_option("-r", "--root", dest="root", type="string",
+			action="store", help="root of tree to hold and unlink")
+	parser.add_option("-c", "--content-tag", dest="content", type="string",
+			default="dummy", action="store",
+			help="tag for contents of the files (e.g. \"original\", \"dummy\")")
+	(options, args) = parser.parse_args()
+	root = path.abspath(options.root)
+	content = options.content
+
+	for (dirpath, dirnames, filenames) in rwalk():
+		for dir in dirnames:
+			chmod(join(dirpath, dir), S_IRWXU)
+		for fname in filenames:
+			f = join(dirpath, fname)
+			chmod(f, S_IRUSR|S_IWUSR)
+			fd = open(f, O_WRONLY|O_TRUNC)
+			write(fd, "%s contents of %s\n" % (content, f))
+			close(fd)
-- 
1.6.3.3
