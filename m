From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/9] cr_tests: fs: A tool to check a tree of files and dirs
Date: Fri, 19 Feb 2010 18:18:53 -0800
Message-ID: <dfc5e84b2c8940b07be485b8df1e530e4128e253.1266632319.git.matthltc@us.ibm.com>
References: <1266632337-13792-1-git-send-email-matthltc@us.ibm.com>
	<72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc@us.ibm.com>
	<a5516d2e94b044e946ac039172a3d9cab0df0c1f.1266632319.git.matthltc@us.ibm.com>
	<7f04acbefe832b0bfaa832222da150c33af76ca8.1266632319.git.matthltc@us.ibm.com>
	<0efaca297a696880440a982210325dc7c473b13d.1266632319.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <0efaca297a696880440a982210325dc7c473b13d.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 fs/check_tree.py |   60 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 60 insertions(+), 0 deletions(-)
 create mode 100755 fs/check_tree.py

diff --git a/fs/check_tree.py b/fs/check_tree.py
new file mode 100755
index 0000000..d757f66
--- /dev/null
+++ b/fs/check_tree.py
@@ -0,0 +1,60 @@
+#!/usr/bin/python
+#
+# Open everything in a tree and check for known contents.
+#
+# NOTE: Does not detect if there are more files and directories
+#       beyond the "original" tree if the new ones follow the
+#	scheme detected here.
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
+			if not access(join(dirpath, dir), R_OK|W_OK|X_OK):
+				exit(EX_NOPERM)
+		for fname in filenames:
+			f = join(dirpath, fname)
+			fd = open(f, O_RDONLY, S_IRUSR|S_IWUSR) # does access()
+			expected_contents = "%s contents of %s\n" % (content, f)
+			contents = read(fd, len(expected_contents))
+			if read(fd, 2) != '':
+				sys.stderr.write('Extra contents of file \"%s\": Got \"%s\" and more but expected \"%s\"\n' % (f, contents, expected_contents))
+				sys.exit(EX_DATAERR) # not at EOF
+			close(fd)
+			if expected_contents == contents:
+				continue
+			sys.stderr.write('Contents mismatch \"%s\": Got \"%s\" but expected \"%s\"\n' % (f, contents, expected_contents))
+			sys.exit(EX_DATAERR)
+	sys.exit(EX_OK)
-- 
1.6.3.3
