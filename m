From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/9] cr_tests: fs: A tool to create a random tree of dirs and
	files
Date: Fri, 19 Feb 2010 18:18:51 -0800
Message-ID: <7f04acbefe832b0bfaa832222da150c33af76ca8.1266632319.git.matthltc@us.ibm.com>
References: <1266632337-13792-1-git-send-email-matthltc@us.ibm.com>
	<72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc@us.ibm.com>
	<a5516d2e94b044e946ac039172a3d9cab0df0c1f.1266632319.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <a5516d2e94b044e946ac039172a3d9cab0df0c1f.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 fs/rand_tree.py |  113 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 113 insertions(+), 0 deletions(-)
 create mode 100755 fs/rand_tree.py

diff --git a/fs/rand_tree.py b/fs/rand_tree.py
new file mode 100755
index 0000000..54db43f
--- /dev/null
+++ b/fs/rand_tree.py
@@ -0,0 +1,113 @@
+#!/usr/bin/python
+#
+# Generate a random tree of files and dirs with known mode bits and
+# contents.
+#
+import optparse
+import sys
+import random
+import cPickle
+
+# for S_I* (e.g. S_IRWXU)
+from stat import *
+
+# For walk, path.join, open, unlink, close, and O_*
+from os import *
+
+# Root of the tree to generate
+root = None
+
+# Like os.walk() but assumes root and followlinks = False
+# (which prevents likely-unwanted removal of files for the
+#  purposes of this test script)
+def rwalk(**kw):
+	kw['followlinks'] = False
+	yield walk(root, **kw)
+
+# Alias path.join -> join
+def join(*args):
+	return path.join(*args)
+
+n_dirs = 10
+n_files = 100
+
+all_dir_paths = []
+
+# Get a random path from root
+def random_walk():
+	wchoice = random.choice(all_dir_paths)
+	return wchoice
+
+#
+# Create a random directory path in the tree that is, at most,
+# one level deeper than the depth of the tree.
+# NOTE: Naming relies on creating the dirs between each call!
+#
+def random_dir():
+	parent_dir = random_walk()
+	dname = str(len(listdir(parent_dir)) + 1)
+	dpath = join(parent_dir, dname)
+	all_dir_paths.append(dpath)
+	mkdir(dpath, S_IRWXU)
+
+# Create a random file path in the tree
+def random_file():
+	parent_dir = random_walk()
+	fname = str(len(listdir(parent_dir)) + 1)
+	return join(parent_dir, fname)
+
+if __name__ == '__main__':
+	parser = optparse.OptionParser()
+	parser.add_option("-r", "--root", dest="root", type="string",
+			action="store", help="root of tree to hold and unlink")
+	parser.add_option("-c", "--content-tag", dest="content", type="string",
+			default="original", action="store",
+			help="tag for contents of the files (e.g. \"original\", \"dummy\")")
+	parser.add_option("-d", "--num-directories", type="int", dest="n_dirs",
+			default=random.randint(0, n_dirs),
+			action="store", help="number of directories to create")
+	parser.add_option("-f", "--num-files", type="int", dest="n_files",
+			default=random.randint(0, n_files),
+			action="store", help="number of files to create")
+	parser.add_option("-s", "--seed", type="int", dest="random_seed",
+			default=None,
+			action="store", help="random seed to use")
+	parser.add_option("-S", "--random-state", type="string",
+			dest="random_state", default=None,
+			action="store", help="random state to use")
+	(options, args) = parser.parse_args()
+	root = path.abspath(options.root)
+	all_dir_paths.append(root)
+	n_dirs = options.n_dirs
+	n_files = options.n_files
+	content = options.content
+
+	# Set the random seed or random state
+	if options.random_seed is None and options.random_state is None:
+		random.seed()
+
+		# Output the random state so, presumably, we can recreate this
+		# same test tree.
+		sys.stdout.write(cPickle.dumps(random.getstate()))
+	elif not options.random_seed is None:
+		random.seed(options.random_seed)
+	elif not options.random_state is None:
+		random_state = cPickle.loads(options.random_state)
+		random.setstate(random_state)
+
+	# Ensure that the tree root exists
+	try:
+		makedirs(root, S_IRWXU)
+	except:
+		pass
+
+	while n_dirs > 0:
+		random_dir()
+		n_dirs = n_dirs - 1
+
+	while n_files > 0:
+		f = random_file()
+		fd = open(f, O_CREAT|O_WRONLY|O_TRUNC, S_IRUSR|S_IWUSR)
+		write(fd, "%s contents of %s\n" % (content, f))
+		close(fd)
+		n_files = n_files - 1
-- 
1.6.3.3
