From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] fix checkpoint header exports
Date: Mon, 15 Jun 2009 00:10:37 -0500
Message-ID: <m37hze2ib6.fsf@pobox.com>
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

checkpoint_types.h is not useful to userspace.  Unexport it.

checkpoint.h contains definitions that userspace needs.  Export it.

user-cr can now be built against exported headers.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

---

(against ckpt-v16-x86 as of a couple days ago; git.ncl.cs.columbia.edu
appears unresponsive atm)

 include/linux/Kbuild |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 25b7c0e..df43556 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -44,7 +44,7 @@ header-y += bpqether.h
 header-y += bsg.h
 header-y += can.h
 header-y += cdk.h
-header-y += checkpoint_types.h
+header-y += checkpoint.h
 header-y += checkpoint_hdr.h
 header-y += chio.h
 header-y += coda_psdev.h
-- 
1.6.0.6
