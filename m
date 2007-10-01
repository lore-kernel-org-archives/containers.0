From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 3/3] capabilities: reduce current's caps when reducing bset
Date: Mon, 1 Oct 2007 09:42:07 -0500
Message-ID: <20071001144207.GC25345@sergelap.austin.ibm.com>
References: <20071001144031.GA24683@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071001144031.GA24683@sergelap.austin.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: containers@lists.osdl.org
Cc: Andrew Morgan <morgan@kernel.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

From 2a0af2a5364ab568fa603cc9fdaeeef67d82dc56 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue@us.ibm.com>
Date: Fri, 28 Sep 2007 14:07:03 -0500
Subject: [PATCH 3/3] capabilities: reduce current's caps when reducing bset

When a task sets it's capability bounding set, ensure that
pI pE and pP are subsets of the new bounding set.

(note the new bset is a subset of the original)

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 security/commoncap.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/security/commoncap.c b/security/commoncap.c
index 324ff2a..dcd5af4 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -585,6 +585,12 @@ int cap_prctl_setbset(unsigned long new_bset)
 	if (!cap_issubset(new_bset, current->cap_bset))
 		return -EPERM;
 	current->cap_bset = new_bset;
+	current->cap_effective = cap_intersect(current->cap_effective,
+		new_bset);
+	current->cap_permitted = cap_intersect(current->cap_permitted,
+		new_bset);
+	current->cap_inheritable = cap_intersect(current->cap_inheritable,
+		new_bset);
 	return 0;
 }
 
-- 
1.5.1.6

