From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 02/27] userns: net: Call key_alloc with GLOBAL_ROOT_UID,
	GLOBAL_ROOT_GID instead of 0, 0
Date: Wed, 19 Sep 2012 18:52:04 -0700
Message-ID: <1348105949-25454-2-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

In net/dns_resolver/dns_key.c and net/rxrpc/ar-key.c make them
work with user namespaces enabled where key_alloc takes kuids and kgids.
Pass GLOBAL_ROOT_UID and GLOBAL_ROOT_GID instead of bare 0's.

Cc: Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>
Cc: ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig               |    2 --
 net/dns_resolver/dns_key.c |    3 ++-
 net/rxrpc/ar-key.c         |    6 ++++--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 8dce711..fd8696b 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -938,8 +938,6 @@ config UIDGID_CONVERTED
 
 	# Networking
 	depends on NET_9P = n
-	depends on AF_RXRPC = n
-	depends on DNS_RESOLVER = n
 
 	# Filesystems
 	depends on USB_GADGETFS = n
diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index d9507dd..9807945 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -259,7 +259,8 @@ static int __init init_dns_resolver(void)
 	if (!cred)
 		return -ENOMEM;
 
-	keyring = key_alloc(&key_type_keyring, ".dns_resolver", 0, 0, cred,
+	keyring = key_alloc(&key_type_keyring, ".dns_resolver",
+			    GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred,
 			    (KEY_POS_ALL & ~KEY_POS_SETATTR) |
 			    KEY_USR_VIEW | KEY_USR_READ,
 			    KEY_ALLOC_NOT_IN_QUOTA);
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index 8b1f9f4..011d238 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -948,7 +948,8 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
 
 	_enter("");
 
-	key = key_alloc(&key_type_rxrpc, "x", 0, 0, cred, 0,
+	key = key_alloc(&key_type_rxrpc, "x",
+			GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred, 0,
 			KEY_ALLOC_NOT_IN_QUOTA);
 	if (IS_ERR(key)) {
 		_leave(" = -ENOMEM [alloc %ld]", PTR_ERR(key));
@@ -994,7 +995,8 @@ struct key *rxrpc_get_null_key(const char *keyname)
 	struct key *key;
 	int ret;
 
-	key = key_alloc(&key_type_rxrpc, keyname, 0, 0, cred,
+	key = key_alloc(&key_type_rxrpc, keyname,
+			GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred,
 			KEY_POS_SEARCH, KEY_ALLOC_NOT_IN_QUOTA);
 	if (IS_ERR(key))
 		return key;
-- 
1.7.5.4
