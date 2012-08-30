From: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [CRIU] Re: Error compiling CRtools-0.1..
Date: Thu, 30 Aug 2012 17:47:30 +0400
Message-ID: <20120830134730.GC22033@moon>
References: <604C0E70D2B64644B0BCE6939D9F7D0327A1C6@BGSMSX102.gar.corp.intel.com>
	<604C0E70D2B64644B0BCE6939D9F7D0327E011@BGSMSX102.gar.corp.intel.com>
	<20120830125557.GB8474@amd1> <20120830131058.GK21422@moon>
	<604C0E70D2B64644B0BCE6939D9F7D0327E623@BGSMSX102.gar.corp.intel.com>
	<20120830133033.GL21422@moon>
	<604C0E70D2B64644B0BCE6939D9F7D0327E674@BGSMSX102.gar.corp.intel.com>
	<20120830134513.GM21422@moon>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120830134513.GM21422@moon>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Muralidhar, Rajeev D" <rajeev.d.muralidhar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: "criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Aug 30, 2012 at 05:45:13PM +0400, Cyrill Gorcunov wrote:
> On Thu, Aug 30, 2012 at 01:43:05PM +0000, Muralidhar, Rajeev D wrote:
> > Hi Cyril
> > 
> > I took the current git snapshot from crtools repo. Should I try version 0.1 from the tar file?
> 
> No no, that's fine. I'm cooking a patch. Please wait a bit.

Does the patch below helps for you?

Andrew, why did we mangle the paths to unix names?

	Cyrill

--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-sk-unix.c-Don-t-mangle-name-provided-by-fiag-message.patch"

From 0b01d629e136b328fe4ce85f50d54dea9aaa0728 Mon Sep 17 00:00:00 2001
From: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Date: Thu, 30 Aug 2012 17:43:34 +0400
Subject: [PATCH] sk-unix.c: Don't mangle name provided by fiag message

Otherwise we can't fetch stat.

Reported-by: "Muralidhar, Rajeev D" <rajeev.d.muralidhar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 sk-unix.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/sk-unix.c b/sk-unix.c
index 9a9323c..605e32b 100644
--- a/sk-unix.c
+++ b/sk-unix.c
@@ -277,7 +277,7 @@ static int unix_collect_one(const struct unix_diag_msg *m,
 			}
 
 			uv = RTA_DATA(tb[UNIX_DIAG_VFS]);
-			snprintf(rpath, sizeof(rpath), ".%s", name);
+			snprintf(rpath, sizeof(rpath), "%s", name);
 			if (fstatat(mntns_root, rpath, &st, 0)) {
 				pr_perror("Can't stat socket %d(%s)",
 						m->udiag_ino, rpath);
-- 
1.7.7.6


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--opJtzjQTFsWo+cga--
