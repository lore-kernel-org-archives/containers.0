From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 21/85] ocfs2: Handle kuids and kgids in acl/xattr
	conversions.
Date: Wed, 13 Feb 2013 09:51:10 -0800
Message-ID: <1360777934-5663-21-git-send-email-ebiederm@xmission.com>
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
Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Explicitly deal with the different kinds of acls because they need
different conversions.

Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>
Cc: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ocfs2/acl.c |   31 +++++++++++++++++++++++++++++--
 1 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/fs/ocfs2/acl.c b/fs/ocfs2/acl.c
index 260b162..8a40457 100644
--- a/fs/ocfs2/acl.c
+++ b/fs/ocfs2/acl.c
@@ -65,7 +65,20 @@ static struct posix_acl *ocfs2_acl_from_xattr(const void *value, size_t size)
 
 		acl->a_entries[n].e_tag  = le16_to_cpu(entry->e_tag);
 		acl->a_entries[n].e_perm = le16_to_cpu(entry->e_perm);
-		acl->a_entries[n].e_id   = le32_to_cpu(entry->e_id);
+		switch(acl->a_entries[n].e_tag) {
+		case ACL_USER:
+			acl->a_entries[n].e_uid =
+				make_kuid(&init_user_ns,
+					  le32_to_cpu(entry->e_id));
+			break;
+		case ACL_GROUP:
+			acl->a_entries[n].e_gid =
+				make_kgid(&init_user_ns,
+					  le32_to_cpu(entry->e_id));
+			break;
+		default:
+			break;
+		}
 		value += sizeof(struct posix_acl_entry);
 
 	}
@@ -91,7 +104,21 @@ static void *ocfs2_acl_to_xattr(const struct posix_acl *acl, size_t *size)
 	for (n = 0; n < acl->a_count; n++, entry++) {
 		entry->e_tag  = cpu_to_le16(acl->a_entries[n].e_tag);
 		entry->e_perm = cpu_to_le16(acl->a_entries[n].e_perm);
-		entry->e_id   = cpu_to_le32(acl->a_entries[n].e_id);
+		switch(acl->a_entries[n].e_tag) {
+		case ACL_USER:
+			entry->e_id = cpu_to_le32(
+				from_kuid(&init_user_ns,
+					  acl->a_entries[n].e_uid));
+			break;
+		case ACL_GROUP:
+			entry->e_id = cpu_to_le32(
+				from_kgid(&init_user_ns,
+					  acl->a_entries[n].e_gid));
+			break;
+		default:
+			entry->e_id = cpu_to_le32(ACL_UNDEFINED_ID);
+			break;
+		}
 	}
 	return ocfs2_acl;
 }
-- 
1.7.5.4
