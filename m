From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: [Patch resend v3 3/3] binfmt_misc: add F option description to
	documentation
Date: Tue, 19 Apr 2016 08:29:40 -0400
Message-ID: <1461068980.2435.6.camel__49506.1150788844$1461068997$gmane$org@HansenPartnership.com>
References: <1461068670.2435.0.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1461068670.2435.0.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
---
 Documentation/binfmt_misc.txt | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/binfmt_misc.txt b/Documentation/binfmt_misc.txt
index 6b1de70..ec83bbc 100644
--- a/Documentation/binfmt_misc.txt
+++ b/Documentation/binfmt_misc.txt
@@ -66,6 +66,13 @@ Here is what the fields mean:
             This feature should be used with care as the interpreter
             will run with root permissions when a setuid binary owned by root
             is run with binfmt_misc.
+      'F' - fix binary.  The usual behaviour of binfmt_misc is to spawn the
+      	    binary lazily when the misc format file is invoked.  However,
+	    this doesn't work very well in the face of mount namespaces and
+	    changeroots, so the F mode opens the binary as soon as the
+	    emulation is installed and uses the opened image to spawn the
+	    emulator, meaning it is always available once installed,
+	    regardless of how the environment changes.
 
 
 There are some restrictions:
-- 
2.6.6
