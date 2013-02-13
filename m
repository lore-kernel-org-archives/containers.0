From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 50/85] sunrpc: Hash uids by first computing their value
	in the initial userns
Date: Wed, 13 Feb 2013 09:51:39 -0800
Message-ID: <1360777934-5663-50-git-send-email-ebiederm@xmission.com>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1360777934-5663-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

In svcauth_unix introduce a helper unix_gid_hash as otherwise the
expresion to generate the hash value is just too long.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/sunrpc/auth.c         |    2 +-
 net/sunrpc/svcauth_unix.c |    9 +++++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 4cd0ecf..392adc4 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -412,7 +412,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 			*entry, *new;
 	unsigned int nr;
 
-	nr = hash_long(acred->uid, cache->hashbits);
+	nr = hash_long(from_kuid(&init_user_ns, acred->uid), cache->hashbits);
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 92166b5..faf1719 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -419,6 +419,11 @@ struct unix_gid {
 	struct group_info	*gi;
 };
 
+static int unix_gid_hash(kuid_t uid)
+{
+	return hash_long(from_kuid(&init_user_ns, uid), GID_HASHBITS);
+}
+
 static void unix_gid_put(struct kref *kref)
 {
 	struct cache_head *item = container_of(kref, struct cache_head, ref);
@@ -530,7 +535,7 @@ static int unix_gid_parse(struct cache_detail *cd,
 		ug.h.expiry_time = expiry;
 		ch = sunrpc_cache_update(cd,
 					 &ug.h, &ugp->h,
-					 hash_long(uid, GID_HASHBITS));
+					 unix_gid_hash(uid));
 		if (!ch)
 			err = -ENOMEM;
 		else {
@@ -621,7 +626,7 @@ static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, kuid_t uid)
 	struct cache_head *ch;
 
 	ug.uid = uid;
-	ch = sunrpc_cache_lookup(cd, &ug.h, hash_long(uid, GID_HASHBITS));
+	ch = sunrpc_cache_lookup(cd, &ug.h, unix_gid_hash(uid));
 	if (ch)
 		return container_of(ch, struct unix_gid, h);
 	else
-- 
1.7.5.4
