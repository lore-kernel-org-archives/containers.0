From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 18/27] userns: Convert extN to support kuids and kgids in
	posix acls
Date: Wed, 19 Sep 2012 18:52:20 -0700
Message-ID: <1348105949-25454-18-git-send-email-ebiederm@xmission.com>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Convert ext2, ext3, and ext4 to fully support the posix acl changes,
using e_uid e_gid instead e_id.

Enabled building with posix acls enabled, all filesystems supporting
user namespaces, now also support posix acls when user namespaces are enabled.

Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ext2/acl.c |   28 ++++++++++++++++++++--------
 fs/ext3/acl.c |   28 ++++++++++++++++++++--------
 fs/ext4/acl.c |   27 ++++++++++++++++++++-------
 init/Kconfig  |    1 -
 4 files changed, 60 insertions(+), 24 deletions(-)

diff --git a/fs/ext2/acl.c b/fs/ext2/acl.c
index 70bb1bc..110b6b3 100644
--- a/fs/ext2/acl.c
+++ b/fs/ext2/acl.c
@@ -53,16 +53,23 @@ ext2_acl_from_disk(const void *value, size_t size)
 			case ACL_OTHER:
 				value = (char *)value +
 					sizeof(ext2_acl_entry_short);
-				acl->a_entries[n].e_id = ACL_UNDEFINED_ID;
 				break;
 
 			case ACL_USER:
+				value = (char *)value + sizeof(ext2_acl_entry);
+				if ((char *)value > end)
+					goto fail;
+				acl->a_entries[n].e_uid =
+					make_kuid(&init_user_ns,
+						  le32_to_cpu(entry->e_id));
+				break;
 			case ACL_GROUP:
 				value = (char *)value + sizeof(ext2_acl_entry);
 				if ((char *)value > end)
 					goto fail;
-				acl->a_entries[n].e_id =
-					le32_to_cpu(entry->e_id);
+				acl->a_entries[n].e_gid =
+					make_kgid(&init_user_ns,
+						  le32_to_cpu(entry->e_id));
 				break;
 
 			default:
@@ -96,14 +103,19 @@ ext2_acl_to_disk(const struct posix_acl *acl, size_t *size)
 	ext_acl->a_version = cpu_to_le32(EXT2_ACL_VERSION);
 	e = (char *)ext_acl + sizeof(ext2_acl_header);
 	for (n=0; n < acl->a_count; n++) {
+		const struct posix_acl_entry *acl_e = &acl->a_entries[n];
 		ext2_acl_entry *entry = (ext2_acl_entry *)e;
-		entry->e_tag  = cpu_to_le16(acl->a_entries[n].e_tag);
-		entry->e_perm = cpu_to_le16(acl->a_entries[n].e_perm);
-		switch(acl->a_entries[n].e_tag) {
+		entry->e_tag  = cpu_to_le16(acl_e->e_tag);
+		entry->e_perm = cpu_to_le16(acl_e->e_perm);
+		switch(acl_e->e_tag) {
 			case ACL_USER:
+				entry->e_id = cpu_to_le32(
+					from_kuid(&init_user_ns, acl_e->e_uid));
+				e += sizeof(ext2_acl_entry);
+				break;
 			case ACL_GROUP:
-				entry->e_id =
-					cpu_to_le32(acl->a_entries[n].e_id);
+				entry->e_id = cpu_to_le32(
+					from_kgid(&init_user_ns, acl_e->e_gid));
 				e += sizeof(ext2_acl_entry);
 				break;
 
diff --git a/fs/ext3/acl.c b/fs/ext3/acl.c
index 2cf6a80..dbb5ad5 100644
--- a/fs/ext3/acl.c
+++ b/fs/ext3/acl.c
@@ -48,16 +48,23 @@ ext3_acl_from_disk(const void *value, size_t size)
 			case ACL_OTHER:
 				value = (char *)value +
 					sizeof(ext3_acl_entry_short);
-				acl->a_entries[n].e_id = ACL_UNDEFINED_ID;
 				break;
 
 			case ACL_USER:
+				value = (char *)value + sizeof(ext3_acl_entry);
+				if ((char *)value > end)
+					goto fail;
+				acl->a_entries[n].e_uid =
+					make_kuid(&init_user_ns,
+						  le32_to_cpu(entry->e_id));
+				break;
 			case ACL_GROUP:
 				value = (char *)value + sizeof(ext3_acl_entry);
 				if ((char *)value > end)
 					goto fail;
-				acl->a_entries[n].e_id =
-					le32_to_cpu(entry->e_id);
+				acl->a_entries[n].e_gid =
+					make_kgid(&init_user_ns,
+						  le32_to_cpu(entry->e_id));
 				break;
 
 			default:
@@ -91,14 +98,19 @@ ext3_acl_to_disk(const struct posix_acl *acl, size_t *size)
 	ext_acl->a_version = cpu_to_le32(EXT3_ACL_VERSION);
 	e = (char *)ext_acl + sizeof(ext3_acl_header);
 	for (n=0; n < acl->a_count; n++) {
+		const struct posix_acl_entry *acl_e = &acl->a_entries[n];
 		ext3_acl_entry *entry = (ext3_acl_entry *)e;
-		entry->e_tag  = cpu_to_le16(acl->a_entries[n].e_tag);
-		entry->e_perm = cpu_to_le16(acl->a_entries[n].e_perm);
-		switch(acl->a_entries[n].e_tag) {
+		entry->e_tag  = cpu_to_le16(acl_e->e_tag);
+		entry->e_perm = cpu_to_le16(acl_e->e_perm);
+		switch(acl_e->e_tag) {
 			case ACL_USER:
+				entry->e_id = cpu_to_le32(
+					from_kuid(&init_user_ns, acl_e->e_uid));
+				e += sizeof(ext3_acl_entry);
+				break;
 			case ACL_GROUP:
-				entry->e_id =
-					cpu_to_le32(acl->a_entries[n].e_id);
+				entry->e_id = cpu_to_le32(
+					from_kgid(&init_user_ns, acl_e->e_gid));
 				e += sizeof(ext3_acl_entry);
 				break;
 
diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
index 42b95fc..d3c5b88 100644
--- a/fs/ext4/acl.c
+++ b/fs/ext4/acl.c
@@ -55,16 +55,23 @@ ext4_acl_from_disk(const void *value, size_t size)
 		case ACL_OTHER:
 			value = (char *)value +
 				sizeof(ext4_acl_entry_short);
-			acl->a_entries[n].e_id = ACL_UNDEFINED_ID;
 			break;
 
 		case ACL_USER:
+			value = (char *)value + sizeof(ext4_acl_entry);
+			if ((char *)value > end)
+				goto fail;
+			acl->a_entries[n].e_uid =
+				make_kuid(&init_user_ns,
+					  le32_to_cpu(entry->e_id));
+			break;
 		case ACL_GROUP:
 			value = (char *)value + sizeof(ext4_acl_entry);
 			if ((char *)value > end)
 				goto fail;
-			acl->a_entries[n].e_id =
-				le32_to_cpu(entry->e_id);
+			acl->a_entries[n].e_gid =
+				make_kgid(&init_user_ns,
+					  le32_to_cpu(entry->e_id));
 			break;
 
 		default:
@@ -98,13 +105,19 @@ ext4_acl_to_disk(const struct posix_acl *acl, size_t *size)
 	ext_acl->a_version = cpu_to_le32(EXT4_ACL_VERSION);
 	e = (char *)ext_acl + sizeof(ext4_acl_header);
 	for (n = 0; n < acl->a_count; n++) {
+		const struct posix_acl_entry *acl_e = &acl->a_entries[n];
 		ext4_acl_entry *entry = (ext4_acl_entry *)e;
-		entry->e_tag  = cpu_to_le16(acl->a_entries[n].e_tag);
-		entry->e_perm = cpu_to_le16(acl->a_entries[n].e_perm);
-		switch (acl->a_entries[n].e_tag) {
+		entry->e_tag  = cpu_to_le16(acl_e->e_tag);
+		entry->e_perm = cpu_to_le16(acl_e->e_perm);
+		switch (acl_e->e_tag) {
 		case ACL_USER:
+			entry->e_id = cpu_to_le32(
+				from_kuid(&init_user_ns, acl_e->e_uid));
+			e += sizeof(ext4_acl_entry);
+			break;
 		case ACL_GROUP:
-			entry->e_id = cpu_to_le32(acl->a_entries[n].e_id);
+			entry->e_id = cpu_to_le32(
+				from_kgid(&init_user_ns, acl_e->e_gid));
 			e += sizeof(ext4_acl_entry);
 			break;
 
diff --git a/init/Kconfig b/init/Kconfig
index 2a388e5..ed6310b 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -927,7 +927,6 @@ config UIDGID_CONVERTED
 	# Features
 	depends on IMA = n
 	depends on EVM = n
-	depends on FS_POSIX_ACL = n
 	depends on QUOTA = n
 	depends on QUOTACTL = n
 
-- 
1.7.5.4
