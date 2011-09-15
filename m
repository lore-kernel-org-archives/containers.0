From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Subject: [PATCH] User namespace: don't allow sysctl in non-init user ns
Date: Thu, 15 Sep 2011 14:48:12 -0500
Message-ID: <20110915194812.GA24348@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@osdl.org>, Vasiliy Kulikov <segoon@openwall.com>, richard@nod.at
List-Id: containers.vger.kernel.org

sysctl.c has its own custom uid check, which is not user namespace
aware.  As discovered by Richard, that allows root in a container
privileged access to set all sysctls.

To fix that, just refuse access if current is not in init_user_ns.  We
may at some point want to relax that check so that some sysctls are
allowed - for instance dmesg_restrict when syslog is containerized.

Signed-off-by: Serge Hallyn <serge.hallyn@canonical.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Vasiliy Kulikov <segoon@openwall.com>
Cc: richard@nod.at
---
 kernel/sysctl.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 11d65b5..f2b42e2 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1697,6 +1697,8 @@ void register_sysctl_root(struct ctl_table_root *root)
 
 static int test_perm(int mode, int op)
 {
+	if (current_user_ns() != &init_user_ns)
+		return -EACCES;
 	if (!current_euid())
 		mode >>= 6;
 	else if (in_egroup_p(0))
-- 
1.7.5.4
