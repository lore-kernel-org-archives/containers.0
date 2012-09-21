From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 06/14] userns: Convert EVM to deal with kuids and kgids in
	it's hmac computation
Date: Thu, 20 Sep 2012 17:28:42 -0700
Message-ID: <1348187330-6616-6-git-send-email-ebiederm@xmission.com>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348187330-6616-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Mimi Zohar <zohar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Mimi Zohar <zohar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig                        |    1 -
 security/integrity/evm/evm_crypto.c |    4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 8450442..96ee3f3 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -926,7 +926,6 @@ config UIDGID_CONVERTED
 	# List of kernel pieces that need user namespace work
 	# Features
 	depends on IMA = n
-	depends on EVM = n
 
 	# Networking
 	depends on NET_9P = n
diff --git a/security/integrity/evm/evm_crypto.c b/security/integrity/evm/evm_crypto.c
index 49a464f..dfb2691 100644
--- a/security/integrity/evm/evm_crypto.c
+++ b/security/integrity/evm/evm_crypto.c
@@ -106,8 +106,8 @@ static void hmac_add_misc(struct shash_desc *desc, struct inode *inode,
 	memset(&hmac_misc, 0, sizeof hmac_misc);
 	hmac_misc.ino = inode->i_ino;
 	hmac_misc.generation = inode->i_generation;
-	hmac_misc.uid = inode->i_uid;
-	hmac_misc.gid = inode->i_gid;
+	hmac_misc.uid = from_kuid(&init_user_ns, inode->i_uid);
+	hmac_misc.gid = from_kgid(&init_user_ns, inode->i_gid);
 	hmac_misc.mode = inode->i_mode;
 	crypto_shash_update(desc, (const u8 *)&hmac_misc, sizeof hmac_misc);
 	crypto_shash_final(desc, digest);
-- 
1.7.5.4
