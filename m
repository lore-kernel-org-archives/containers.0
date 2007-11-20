From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/1] capabilities: introduce per-process capability
	bounding set (v8)
Date: Tue, 20 Nov 2007 14:23:40 -0600
Message-ID: <20071120202340.GA15804@sergelap.austin.ibm.com>
References: <20071119212519.GA23178@sergelap.austin.ibm.com> <47425727.10702@kernel.org> <20071120200746.GA15698@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071120200746.GA15698@sergelap.austin.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Andrew Morgan <morgan@kernel.org>, Chris Wright <chrisw@sous-sol.org>, casey@schaufler-ca.com, Andrew Morton <akpm@google.com>, Stephen Smalley <sds@tycho.nsa.gov>, KaiGai Kohei <kaigai@kaigai.gr.jp>, James Morris <jmorris@namei.org>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue@us.ibm.com):
> How about the following?

Argh, with the following on top of it...

-serge


From 470a68120cda83875a281354b897f3bda04b58fc Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue@us.ibm.com>
Date: Tue, 20 Nov 2007 15:12:54 -0500
Subject: [PATCH 1/1] capbset: fix compilation when CONFIG_SECURITY=n

without this patch, kernel/sys.c has undefined reference
to cap_prctl_drop().

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 kernel/sys.c         |    4 ++++
 security/commoncap.c |    4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index b528e75..efc495e 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1747,7 +1747,11 @@ asmlinkage long sys_prctl(int option, unsigned long arg2, unsigned long arg3,
 				return -EINVAL;
 			return !!cap_raised(current->cap_bset, arg2);
 		case PR_CAPBSET_DROP:
+#ifdef CONFIG_SECURITY_FILE_CAPABILITIES
 			return cap_prctl_drop(arg2);
+#else
+			return -EINVAL;
+#endif
 
 		default:
 			error = -EINVAL;
diff --git a/security/commoncap.c b/security/commoncap.c
index b72825e..e909f4f 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -594,10 +594,6 @@ int cap_task_kill(struct task_struct *p, struct siginfo *info,
 {
 	return 0;
 }
-long cap_prctl_drop(unsigned long cap)
-{
-	return -EINVAL;
-}
 #endif
 
 void cap_task_reparent_to_init (struct task_struct *p)
-- 
1.5.1.1.GIT

