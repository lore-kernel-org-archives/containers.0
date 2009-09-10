From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/4] cr: define ckpt_debug if CONFIG_CHECKPOINT=n
Date: Thu, 10 Sep 2009 15:22:48 -0500
Message-ID: <20090910202248.GA7072@us.ibm.com>
References: <20090910202219.GA6778@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090910202219.GA6778@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org

So not all c/r code has to be ifdefed...

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/checkpoint.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 761cad5..06e3eb0 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -337,6 +337,9 @@ extern unsigned long ckpt_debug_level;
 
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
+#else /* CONFIG_CHECKPOINT */
+#define _ckpt_debug(level, fmt, args...)	do { } while (0)
+#define ckpt_debug(fmt, args...)		do { } while (0)
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
 
-- 
1.6.1

