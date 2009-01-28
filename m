From: Nathan Lynch <ntl@pobox.com>
Subject: [PATCH 3/3] allow checkpoint/restart on powerpc
Date: Wed, 28 Jan 2009 16:41:18 -0600
Message-ID: <1233182478-27113-4-git-send-email-ntl__37727.1542478867$1233182946$gmane$org@pobox.com>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1233182478-27113-1-git-send-email-ntl@pobox.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
To: containers@lists.osdl.org
Cc: linuxppc-dev@ozlabs.org
List-Id: containers.vger.kernel.org

Signed-off-by: Nathan Lynch <ntl@pobox.com>
---
 checkpoint/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
index ffaa635..00036aa 100644
--- a/checkpoint/Kconfig
+++ b/checkpoint/Kconfig
@@ -1,7 +1,7 @@
 config CHECKPOINT_RESTART
 	prompt "Enable checkpoint/restart (EXPERIMENTAL)"
 	def_bool n
-	depends on X86_32 && EXPERIMENTAL
+	depends on (X86_32 || PPC) && EXPERIMENTAL
 	help
 	  Application checkpoint/restart is the ability to save the
 	  state of a running application so that it can later resume
-- 
1.5.5
