From: David Howells <dhowells@redhat.com>
Subject: [PATCH] CRED: Fix creds refcounting in lookup_user_key()
Date: Tue, 14 Oct 2008 22:52:49 +0100
Message-ID: <20081014215247.3307.50245.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
To: jmorris@namei.org
Cc: dhowells@redhat.com, serue@us.ibm.com, containers@lists.osdl.org, ebiederm@xmission.com, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Make lookup_user_key() at all return points drop the reference to the current
creds that it took at the top of the function.

Signed-off-by: David Howells <dhowells@redhat.com>
Tested-by: Serge Hallyn <serue@us.ibm.com>
---

 security/keys/process_keys.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index e40f61d..2d6076d 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -667,6 +667,7 @@ try_again:
 		goto invalid_key;
 
 error:
+	put_cred(cred);
 	return key_ref;
 
 invalid_key:

