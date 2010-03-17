From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [C/R v20][PATCH 91/96] powerpc: enable checkpoint support in Kconfig
Date: Wed, 17 Mar 2010 12:09:19 -0400
Message-ID: <1268842164-5590-92-git-send-email-orenl__28630.1086460755$1268850582$gmane$org@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-38-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-39-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-40-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-41-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-42-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-43-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-44-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-45-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-46-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-47-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-48-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-49-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-50-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-51-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-52-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-53-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-54-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-55-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-56-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-57-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-58-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-59-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-60-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-61-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-62-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-63-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-64-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-65-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-66-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-67-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-68-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-69-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-70-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-71-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-72-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-73-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-74-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-75-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-76-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-77-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-78-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-79-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-80-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-81-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-82-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-83-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-84-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-85-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-86-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-87-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-88-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-89-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-90-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-91-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268842164-5590-91-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/powerpc/Kconfig |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index ba3948c..dd88d3d 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -26,6 +26,9 @@ config MMU
 	bool
 	default y
 
+config CHECKPOINT_SUPPORT
+	def_bool y
+
 config GENERIC_CMOS_UPDATE
 	def_bool y
 
-- 
1.6.3.3
