From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v16][PATCH 25/43] tee: don't return 0 when another task
	drains/fills a pipe
Date: Wed, 27 May 2009 13:32:51 -0400
Message-ID: <1243445589-32388-26-git-send-email-orenl__27896.5689395138$1243447514$gmane$org@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch is a modified version of Max Kellerman patch that fixes
a race in do_tee() (see http://patchwork/kernel/org/patch/21040).

It differs in that it rafactors link_pipe() so that the following
patch (that adds support for splice() between pipes, also based on
a patch by Max Kellerman), can better share code.

Below is Max's original description:
--
Cite from the tee() manual page:

 "A return value of 0 means that there was no data to transfer, and it
 would not make sense to block, because there are no writers connected
 to the write end of the pipe"

There is however a race condition in the tee() implementation, which
violates this definition:

- do_tee() ensures that ipipe is readable and opipe is writable by
  calling link_ipipe_prep() and link_opipe_prep()
- these two functions unlock the pipe after they have waited
- during this unlocked phase, there is a short window where other
  tasks may drain the input pipe or fill the output pipe
- do_tee() now calls link_pipe(), which re-locks both pipes
- link_pipe() sees that it is unable to read ("i >= ipipe->nrbufs ||
  opipe->nrbufs >= PIPE_BUFFERS") and breaks from the loop
- link_pipe() returns 0

Although there may be writers connected to the input pipe, tee() now
returns 0, and the caller (spuriously) assumes this is the end of the
stream.

This patch wraps the link_[io]pipe_prep() invocation in a loop within
link_pipe(), and loops until the result is reliable.
--

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 fs/splice.c |   80 +++++++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 61 insertions(+), 19 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 666953d..92dd63c 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1586,6 +1586,59 @@ static int link_opipe_prep(struct pipe_inode_info *pipe, unsigned int flags)
 	return ret;
 }
 
+/**
+ * link_pipe_prep - make sure there's readable data and writable room
+ * @ipipe: the input pipe
+ * @opipe: the output pipe
+ * @flags: splice modifier flags
+ *
+ * Wrap the link_[io]pipe_prep() invocation in a loop until the result
+ * is reliable.
+ *
+ * Expects pipes to be unlocked, and on success returns them locked.
+ */
+static int link_pipe_prep(struct pipe_inode_info *ipipe,
+			  struct pipe_inode_info *opipe,
+			  unsigned int flags)
+{
+	int ret;
+
+	while (1) {
+		/* wait for ipipe to become ready to read */
+		ret = link_ipipe_prep(ipipe, flags);
+		if (ret)
+			return ret;
+
+		/* wait for opipe to become ready to write */
+		ret = link_opipe_prep(opipe, flags);
+		if (ret)
+			return ret;
+
+		/*
+		 * Potential ABBA deadlock, work around it by ordering
+		 * lock grabbing by inode address. Otherwise two
+		 * different processes could deadlock (one doing tee
+		 * from A -> B, the other from B -> A).
+		 */
+		pipe_double_lock(ipipe, opipe);
+
+		/* see if the tee() is still possible */
+		if ((ipipe->nrbufs > 0 || ipipe->writers == 0) &&
+		    opipe->nrbufs < PIPE_BUFFERS)
+			/* yes, it is - keep the locks and end this
+			   loop */
+			break;
+
+		/* no - someone has drained ipipe or has filled opipe
+		   between link_[io]pipe_pre()'s lock and our lock.
+		   Drop both locks and wait again. */
+		pipe_unlock(ipipe);
+		pipe_unlock(opipe);
+	}
+
+	return 0;
+}
+
 /*
  * Link contents of ipipe to opipe.
  */
@@ -1594,14 +1647,13 @@ static int link_pipe(struct pipe_inode_info *ipipe,
 		     size_t len, unsigned int flags)
 {
 	struct pipe_buffer *ibuf, *obuf;
-	int ret = 0, i = 0, nbuf;
+	int ret, i = 0, nbuf;
 
-	/*
-	 * Potential ABBA deadlock, work around it by ordering lock
-	 * grabbing by pipe info address. Otherwise two different processes
-	 * could deadlock (one doing tee from A -> B, the other from B -> A).
-	 */
-	pipe_double_lock(ipipe, opipe);
+	ret = link_pipe_prep(ipipe, opipe, flags);
+	if (ret < 0)
+		return ret;
+
+	/* pipes are now locked */
 
 	do {
 		if (!opipe->readers) {
@@ -1685,18 +1737,8 @@ static long do_tee(struct file *in, struct file *out, size_t len,
 	 * Duplicate the contents of ipipe to opipe without actually
 	 * copying the data.
 	 */
-	if (ipipe && opipe && ipipe != opipe) {
-		/*
-		 * Keep going, unless we encounter an error. The ipipe/opipe
-		 * ordering doesn't really matter.
-		 */
-		ret = link_ipipe_prep(ipipe, flags);
-		if (!ret) {
-			ret = link_opipe_prep(opipe, flags);
-			if (!ret)
-				ret = link_pipe(ipipe, opipe, len, flags);
-		}
-	}
+	if (ipipe && opipe && ipipe != opipe)
+		ret = link_pipe(ipipe, opipe, len, flags);
 
 	return ret;
 }
-- 
1.6.0.4
