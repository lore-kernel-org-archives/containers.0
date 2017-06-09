From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: [PATCH] ioctl_tty.2: add TIOCGPTPEER documentation
Date: Sat, 10 Jun 2017 03:01:47 +1000
Message-ID: <20170609170147.32311-1-asarai__43661.6363273517$1497027728$gmane$org@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Valentin Rothberg <vrothberg-IBi9RG/b67k@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

The feature this patch references has currently only been accepted into
tty-testing, but Greg told me to kick this down to man-pages. As a
result, I can't reference upstream commit id's because the code isn't in
Linus' tree yet -- should I resend this once it lands in tty-next or
Linus' tree?

Also obviously the release version is a bit of a lie.

8<-----------------------------------------------------------------------

This is an ioctl(2) recently added by myself, to allow for container
runtimes and other programs that interact with (potentially hostile)
Linux namespaces to safely create {master,slave} pseudoterminal pairs
without needing to open potentially unsafe /dev/pts/... filenames that
may be malicious mountpoints or similar in an untrusted namespace
(avoiding the endless issues with ptsname(3) and similar approaches).

Cc: <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Signed-off-by: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
---
 man2/ioctl_tty.2 | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/man2/ioctl_tty.2 b/man2/ioctl_tty.2
index d280beacf..61e147d99 100644
--- a/man2/ioctl_tty.2
+++ b/man2/ioctl_tty.2
@@ -380,6 +380,21 @@ Place the current lock state of the pseudoterminal slave device
 in the location pointed to by
 .IR argp
 (since Linux 3.8).
+.TP
+.BI "TIOCGPTPEER	int " flags
+Opens and returns a new file handle to the pseudoterminal slave
+device with the given
+.BR open (2)-style
+.IR flags ,
+regardless of whether the path is accessible through the calling process's
+mount namespaces.
+
+Security-conscious programs interacting with namespaces may wish to use this
+over
+.BR open (2)
+with the path provided by
+.BR ptsname (3),
+and similar library methods that have insecure APIs (since Linux 4.13).
 .PP
 The BSD ioctls
 .BR TIOCSTOP ,
-- 
2.13.1
