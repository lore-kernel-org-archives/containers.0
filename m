From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/4] keys: skip keys from another user namespace
Date: Fri, 9 Jan 2009 16:52:55 -0600
Message-ID: <20090109225255.GA15599@us.ibm.com>
References: <20090109225208.GA15252@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090109225208.GA15252-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org


When listing keys, do not return keys belonging to the
same uid in another user namespace.  Otherwise uid 500
in another user namespace will return keyrings called
uid.500 for another user namespace.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 security/keys/keyring.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index ed85157..3dba81c 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -539,6 +539,9 @@ struct key *find_keyring_by_name(const char *name, bool skip_perm_check)
 				    &keyring_name_hash[bucket],
 				    type_data.link
 				    ) {
+			if (keyring->user->user_ns != current_user_ns())
+				continue;
+
 			if (test_bit(KEY_FLAG_REVOKED, &keyring->flags))
 				continue;
 
-- 
1.5.4.3
