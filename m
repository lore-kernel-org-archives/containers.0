From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/9] cr_tests: fs: Add script to hold an unlinked tree
Date: Fri, 19 Feb 2010 18:18:54 -0800
Message-ID: <970e1b8ed6c9322e3c069bae404b6d8cd17a7a94.1266632319.git.matthltc@us.ibm.com>
References: <1266632337-13792-1-git-send-email-matthltc@us.ibm.com>
	<72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc@us.ibm.com>
	<a5516d2e94b044e946ac039172a3d9cab0df0c1f.1266632319.git.matthltc@us.ibm.com>
	<7f04acbefe832b0bfaa832222da150c33af76ca8.1266632319.git.matthltc@us.ibm.com>
	<0efaca297a696880440a982210325dc7c473b13d.1266632319.git.matthltc@us.ibm.com>
	<dfc5e84b2c8940b07be485b8df1e530e4128e253.1266632319.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <dfc5e84b2c8940b07be485b8df1e530e4128e253.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

This python script opens a tree, unlinks the whole thing, and
waits for checkpoint. A subsequent patch will make a tree
and run this script on it as a test.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/hold_unlinked_tree.py |   85 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 85 insertions(+), 0 deletions(-)
 create mode 100755 fs/hold_unlinked_tree.py

diff --git a/fs/hold_unlinked_tree.py b/fs/hold_unlinked_tree.py
new file mode 100755
index 0000000..c56222b
--- /dev/null
+++ b/fs/hold_unlinked_tree.py
@@ -0,0 +1,85 @@
+#!/usr/bin/python
+#
+# Open everything in a tree, unlink the tree, and optional create new
+# things where the tree once was.
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
+# List of open fds
+open_fds = []
+
+# Lists of dirs and files to "re-create"
+mkdirs = []
+mkfiles = []
+
+# Root of the tree to hold
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
+			default="./hold_root",
+			action="store", help="root of tree to hold and unlink")
+	parser.add_option("-n", "--new-tree", dest="mknew",
+			action="store_true", help="remake tree")
+	(options, args) = parser.parse_args()
+	root = path.abspath(options.root)
+	do_mk = options.mknew
+	mkdirs.append(root)
+
+	# Hold open fds to everything in the tree
+	for (dirpath, dirnames, filenames) in rwalk():
+		for fname in filenames:
+			fpath = join(dirpath, fname)
+			fd = open(join(dirpath, fname), O_RDONLY)
+			open_fds.append(fd);
+			unlink(fpath);
+			# Record the files to re-create
+			mkfiles.append(fpath)
+		for dname in dirnames:
+			fd = open(join(dirpath, dname), O_RDONLY|O_DIRECTORY)
+			open_fds.append(fd);
+			# Can't unlink the dirs yet
+			# Record the directories to re-create, top-down
+			mkdirs.append(join(dirpath, dname))
+
+	# Unlink dirs, bottom up
+	for (dirpath, dirnames, filenames) in rwalk(topdown=False):
+		for dname in dirnames:
+			rmdir(join(dirpath, dname))
+	rmdir(root)
+
+	if do_mk:
+		# Make a new tree over the old one
+		for dir in mkdirs:
+			mkdir(dir, S_IRWXU)
+		for f in mkfiles:
+			fd = open(f, O_CREAT|O_EXCL|O_WRONLY, S_IRUSR|S_IWUSR)
+			write(fd, "new contents of %s\n" % (f))
+			close(fd)
+	mkdirs = None
+	mkfiles = None
+
+	sys.stdout.flush()
+
+	# Sleep until signalled, then exit. NOTE: assumes
+	# O_CLOEXEC is not set on fds.
+	execv("./do_ckpt", [ "./do_ckpt" ])
-- 
1.6.3.3
