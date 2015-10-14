From: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v4 07/11] smack: abstraction layer for 2 common Smack
	operations
Date: Wed, 14 Oct 2015 14:42:01 +0200
Message-ID: <1444826525-9758-8-git-send-email-l.pawelczyk@samsung.com>
References: <1444826525-9758-1-git-send-email-l.pawelczyk@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <1444826525-9758-1-git-send-email-l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Calvin Owens <calvinowens-b10kYP2dOMg@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Mauro Carvalho Chehab <mchehab-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: Lukasz Pawelczyk <havner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds two new functions that provide an abstraction layer for
two common internal Smack operations:

smk_find_label_name() - returns a label name (char*) from a struct
                        smack_known pointer
smk_get_label()       - either finds or imports a label from a raw label
                        name (char*) and returns struct smack_known
                        pointer

This patch also simplifies some pieces of code due to addition of those
2 functions (e.g. smack_inode_post_setxattr, smk_fill_rule,
smk_write_revoke_subj).

It is meant as a preparation for namespaces patches. Those 2 functions
will serve as entry points for namespace operations.

This patch should not change the Smack behaviour in any way.

Signed-off-by: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Reviewed-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
---
 security/smack/smack.h        |   2 +
 security/smack/smack_access.c |  41 ++++++++++++
 security/smack/smack_lsm.c    |  78 +++++++++++-----------
 security/smack/smackfs.c      | 147 +++++++++++++++++++++++-------------------
 4 files changed, 166 insertions(+), 102 deletions(-)

diff --git a/security/smack/smack.h b/security/smack/smack.h
index ca8fb7c..091efc2 100644
--- a/security/smack/smack.h
+++ b/security/smack/smack.h
@@ -306,6 +306,8 @@ int smack_has_ns_privilege(struct task_struct *task,
 int smack_has_privilege(struct task_struct *task, int cap);
 int smack_ns_privileged(struct user_namespace *user_ns, int cap);
 int smack_privileged(int cap);
+char *smk_find_label_name(struct smack_known *skp);
+struct smack_known *smk_get_label(const char *string, int len, bool import);
 
 /*
  * Shared data.
diff --git a/security/smack/smack_access.c b/security/smack/smack_access.c
index 72f848e..131c742 100644
--- a/security/smack/smack_access.c
+++ b/security/smack/smack_access.c
@@ -716,3 +716,44 @@ int smack_privileged(int cap)
 {
 	return smack_ns_privileged(&init_user_ns, cap);
 }
+
+/**
+ * smk_find_label_name - A helper to get a string value of a label
+ * @skp: a label we want a string value from
+ *
+ * Returns a pointer to a label name or NULL if label name not found.
+ */
+char *smk_find_label_name(struct smack_known *skp)
+{
+	return skp->smk_known;
+}
+
+/**
+ * smk_get_label - A helper to get the smack_known value from a string using
+ *                 either import or find functions if it already exists
+ * @string: a name of a label we look for or want to import
+ * @len: the string size, or zero if it is NULL terminated
+ * @import: whether we should import the label if not found
+ *
+ * Returns a smack_known label that is either imported or found.
+ * NULL if label not found (only when import == false).
+ * Error code otherwise.
+ */
+struct smack_known *smk_get_label(const char *string, int len, bool import)
+{
+	struct smack_known *skp;
+	char *cp;
+
+	if (import) {
+		skp = smk_import_entry(string, len);
+	} else {
+		cp = smk_parse_smack(string, len);
+		if (IS_ERR(cp))
+			return ERR_CAST(cp);
+
+		skp = smk_find_entry(cp);
+		kfree(cp);
+	}
+
+	return skp;
+}
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 198d3d6..7303c37 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -746,31 +746,31 @@ static int smack_set_mnt_opts(struct super_block *sb,
 	for (i = 0; i < num_opts; i++) {
 		switch (opts->mnt_opts_flags[i]) {
 		case FSDEFAULT_MNT:
-			skp = smk_import_entry(opts->mnt_opts[i], 0);
+			skp = smk_get_label(opts->mnt_opts[i], 0, true);
 			if (IS_ERR(skp))
 				return PTR_ERR(skp);
 			sp->smk_default = skp;
 			break;
 		case FSFLOOR_MNT:
-			skp = smk_import_entry(opts->mnt_opts[i], 0);
+			skp = smk_get_label(opts->mnt_opts[i], 0, true);
 			if (IS_ERR(skp))
 				return PTR_ERR(skp);
 			sp->smk_floor = skp;
 			break;
 		case FSHAT_MNT:
-			skp = smk_import_entry(opts->mnt_opts[i], 0);
+			skp = smk_get_label(opts->mnt_opts[i], 0, true);
 			if (IS_ERR(skp))
 				return PTR_ERR(skp);
 			sp->smk_hat = skp;
 			break;
 		case FSROOT_MNT:
-			skp = smk_import_entry(opts->mnt_opts[i], 0);
+			skp = smk_get_label(opts->mnt_opts[i], 0, true);
 			if (IS_ERR(skp))
 				return PTR_ERR(skp);
 			sp->smk_root = skp;
 			break;
 		case FSTRANS_MNT:
-			skp = smk_import_entry(opts->mnt_opts[i], 0);
+			skp = smk_get_label(opts->mnt_opts[i], 0, true);
 			if (IS_ERR(skp))
 				return PTR_ERR(skp);
 			sp->smk_root = skp;
@@ -1288,7 +1288,7 @@ static int smack_inode_setxattr(struct dentry *dentry, const char *name,
 		rc = -EPERM;
 
 	if (rc == 0 && check_import) {
-		skp = size ? smk_import_entry(value, size) : NULL;
+		skp = size ? smk_get_label(value, size, true) : NULL;
 		if (IS_ERR(skp))
 			rc = PTR_ERR(skp);
 		else if (skp == NULL || (check_star &&
@@ -1322,6 +1322,7 @@ static void smack_inode_post_setxattr(struct dentry *dentry, const char *name,
 				      const void *value, size_t size, int flags)
 {
 	struct smack_known *skp;
+	struct smack_known **skpp = NULL;
 	struct inode_smack *isp = d_backing_inode(dentry)->i_security;
 
 	if (strcmp(name, XATTR_NAME_SMACKTRANSMUTE) == 0) {
@@ -1329,27 +1330,21 @@ static void smack_inode_post_setxattr(struct dentry *dentry, const char *name,
 		return;
 	}
 
-	if (strcmp(name, XATTR_NAME_SMACK) == 0) {
-		skp = smk_import_entry(value, size);
-		if (!IS_ERR(skp))
-			isp->smk_inode = skp;
-		else
-			isp->smk_inode = &smack_known_invalid;
-	} else if (strcmp(name, XATTR_NAME_SMACKEXEC) == 0) {
-		skp = smk_import_entry(value, size);
-		if (!IS_ERR(skp))
-			isp->smk_task = skp;
-		else
-			isp->smk_task = &smack_known_invalid;
-	} else if (strcmp(name, XATTR_NAME_SMACKMMAP) == 0) {
-		skp = smk_import_entry(value, size);
+	if (strcmp(name, XATTR_NAME_SMACK) == 0)
+		skpp = &isp->smk_inode;
+	else if (strcmp(name, XATTR_NAME_SMACKEXEC) == 0)
+		skpp = &isp->smk_task;
+	else if (strcmp(name, XATTR_NAME_SMACKMMAP) == 0)
+		skpp = &isp->smk_mmap;
+
+	if (skpp) {
+		skp = smk_get_label(value, size, true);
+
 		if (!IS_ERR(skp))
-			isp->smk_mmap = skp;
+			*skpp = skp;
 		else
-			isp->smk_mmap = &smack_known_invalid;
+			*skpp = &smack_known_invalid;
 	}
-
-	return;
 }
 
 /**
@@ -1443,15 +1438,17 @@ static int smack_inode_getsecurity(const struct inode *inode,
 	struct socket *sock;
 	struct super_block *sbp;
 	struct inode *ip = (struct inode *)inode;
-	struct smack_known *isp;
-	int ilen;
+	struct smack_known *isp = NULL;
 	int rc = 0;
 
-	if (strcmp(name, XATTR_SMACK_SUFFIX) == 0) {
+	if (strcmp(name, XATTR_SMACK_SUFFIX) == 0)
 		isp = smk_of_inode(inode);
-		ilen = strlen(isp->smk_known);
-		*buffer = isp->smk_known;
-		return ilen;
+
+	if (isp) {
+		*buffer = smk_find_label_name(isp);
+		if (*buffer == NULL)
+			*buffer = smack_known_huh.smk_known;
+		return strlen(*buffer);
 	}
 
 	/*
@@ -1474,10 +1471,11 @@ static int smack_inode_getsecurity(const struct inode *inode,
 	else
 		return -EOPNOTSUPP;
 
-	ilen = strlen(isp->smk_known);
 	if (rc == 0) {
-		*buffer = isp->smk_known;
-		rc = ilen;
+		*buffer = smk_find_label_name(isp);
+		if (*buffer == NULL)
+			*buffer = smack_known_huh.smk_known;
+		rc = strlen(*buffer);
 	}
 
 	return rc;
@@ -2658,7 +2656,7 @@ static int smack_inode_setsecurity(struct inode *inode, const char *name,
 	if (value == NULL || size > SMK_LONGLABEL || size == 0)
 		return -EINVAL;
 
-	skp = smk_import_entry(value, size);
+	skp = smk_get_label(value, size, true);
 	if (IS_ERR(skp))
 		return PTR_ERR(skp);
 
@@ -3528,7 +3526,10 @@ static int smack_getprocattr(struct task_struct *p, char *name, char **value)
 	if (strcmp(name, "current") != 0)
 		return -EINVAL;
 
-	cp = kstrdup(skp->smk_known, GFP_KERNEL);
+	cp = smk_find_label_name(skp);
+	if (cp == NULL)
+		cp = smack_known_huh.smk_known;
+	cp = kstrdup(cp, GFP_KERNEL);
 	if (cp == NULL)
 		return -ENOMEM;
 
@@ -3572,7 +3573,7 @@ static int smack_setprocattr(struct task_struct *p, const struct cred *f_cred,
 	if (strcmp(name, "current") != 0)
 		return -EINVAL;
 
-	skp = smk_import_entry(value, size);
+	skp = smk_get_label(value, size, true);
 	if (IS_ERR(skp))
 		return PTR_ERR(skp);
 
@@ -4311,7 +4312,10 @@ static int smack_key_getsecurity(struct key *key, char **_buffer)
 		return 0;
 	}
 
-	copy = kstrdup(skp->smk_known, GFP_KERNEL);
+	copy = smk_find_label_name(skp);
+	if (copy == NULL)
+		copy = smack_known_huh.smk_known;
+	copy = kstrdup(copy, GFP_KERNEL);
 	if (copy == NULL)
 		return -ENOMEM;
 	length = strlen(copy) + 1;
diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index 05e09ee2..e5fb555 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -340,36 +340,17 @@ static int smk_fill_rule(const char *subject, const char *object,
 				struct smack_parsed_rule *rule, int import,
 				int len)
 {
-	const char *cp;
-	struct smack_known *skp;
-
-	if (import) {
-		rule->smk_subject = smk_import_entry(subject, len);
-		if (IS_ERR(rule->smk_subject))
-			return PTR_ERR(rule->smk_subject);
-
-		rule->smk_object = smk_import_entry(object, len);
-		if (IS_ERR(rule->smk_object))
-			return PTR_ERR(rule->smk_object);
-	} else {
-		cp = smk_parse_smack(subject, len);
-		if (IS_ERR(cp))
-			return PTR_ERR(cp);
-		skp = smk_find_entry(cp);
-		kfree(cp);
-		if (skp == NULL)
-			return -ENOENT;
-		rule->smk_subject = skp;
-
-		cp = smk_parse_smack(object, len);
-		if (IS_ERR(cp))
-			return PTR_ERR(cp);
-		skp = smk_find_entry(cp);
-		kfree(cp);
-		if (skp == NULL)
-			return -ENOENT;
-		rule->smk_object = skp;
-	}
+	rule->smk_subject = smk_get_label(subject, len, import);
+	if (IS_ERR(rule->smk_subject))
+		return PTR_ERR(rule->smk_subject);
+	if (rule->smk_subject == NULL)
+		return -ENOENT;
+
+	rule->smk_object = smk_get_label(object, len, import);
+	if (IS_ERR(rule->smk_object))
+		return PTR_ERR(rule->smk_object);
+	if (rule->smk_object == NULL)
+		return -ENOENT;
 
 	rule->smk_access1 = smk_perm_from_str(access1);
 	if (access2)
@@ -592,6 +573,9 @@ static void smk_seq_stop(struct seq_file *s, void *v)
 
 static void smk_rule_show(struct seq_file *s, struct smack_rule *srp, int max)
 {
+	char *sbj;
+	char *obj;
+
 	/*
 	 * Don't show any rules with label names too long for
 	 * interface file (/smack/load or /smack/load2)
@@ -605,9 +589,13 @@ static void smk_rule_show(struct seq_file *s, struct smack_rule *srp, int max)
 	if (srp->smk_access == 0)
 		return;
 
-	seq_printf(s, "%s %s",
-		   srp->smk_subject->smk_known,
-		   srp->smk_object->smk_known);
+	sbj = smk_find_label_name(srp->smk_subject);
+	obj = smk_find_label_name(srp->smk_object);
+
+	if (sbj == NULL || obj == NULL)
+		return;
+
+	seq_printf(s, "%s %s", sbj, obj);
 
 	seq_putc(s, ' ');
 
@@ -798,6 +786,7 @@ static int cipso_seq_show(struct seq_file *s, void *v)
 		list_entry_rcu(list, struct smack_known, list);
 	struct netlbl_lsm_catmap *cmp = skp->smk_netlabel.attr.mls.cat;
 	char sep = '/';
+	char *cp;
 	int i;
 
 	/*
@@ -811,7 +800,11 @@ static int cipso_seq_show(struct seq_file *s, void *v)
 	if (strlen(skp->smk_known) >= SMK_LABELLEN)
 		return 0;
 
-	seq_printf(s, "%s %3d", skp->smk_known, skp->smk_netlabel.attr.mls.lvl);
+	cp = smk_find_label_name(skp);
+	if (cp == NULL)
+		return 0;
+
+	seq_printf(s, "%s %3d", cp, skp->smk_netlabel.attr.mls.lvl);
 
 	for (i = netlbl_catmap_walk(cmp, 0); i >= 0;
 	     i = netlbl_catmap_walk(cmp, i + 1)) {
@@ -900,7 +893,7 @@ static ssize_t smk_set_cipso(struct file *file, const char __user *buf,
 	 */
 	mutex_lock(&smack_cipso_lock);
 
-	skp = smk_import_entry(rule, 0);
+	skp = smk_get_label(rule, 0, true);
 	if (IS_ERR(skp)) {
 		rc = PTR_ERR(skp);
 		goto out;
@@ -989,9 +982,14 @@ static int cipso2_seq_show(struct seq_file *s, void *v)
 		list_entry_rcu(list, struct smack_known, list);
 	struct netlbl_lsm_catmap *cmp = skp->smk_netlabel.attr.mls.cat;
 	char sep = '/';
+	char *cp;
 	int i;
 
-	seq_printf(s, "%s %3d", skp->smk_known, skp->smk_netlabel.attr.mls.lvl);
+	cp = smk_find_label_name(skp);
+	if (cp == NULL)
+		return 0;
+
+	seq_printf(s, "%s %3d", cp, skp->smk_netlabel.attr.mls.lvl);
 
 	for (i = netlbl_catmap_walk(cmp, 0); i >= 0;
 	     i = netlbl_catmap_walk(cmp, i + 1)) {
@@ -1072,8 +1070,12 @@ static int net4addr_seq_show(struct seq_file *s, void *v)
 			list_entry_rcu(list, struct smk_net4addr, list);
 	char *kp = SMACK_CIPSO_OPTION;
 
-	if (skp->smk_label != NULL)
-		kp = skp->smk_label->smk_known;
+	if (skp->smk_label != NULL) {
+		kp = smk_find_label_name(skp->smk_label);
+		if (kp == NULL)
+			kp = smack_known_huh.smk_known;
+	}
+
 	seq_printf(s, "%pI4/%d %s\n", &skp->smk_host.s_addr,
 			skp->smk_masks, kp);
 
@@ -1224,7 +1226,7 @@ static ssize_t smk_write_net4addr(struct file *file, const char __user *buf,
 	 * If smack begins with '-', it is an option, don't import it
 	 */
 	if (smack[0] != '-') {
-		skp = smk_import_entry(smack, 0);
+		skp = smk_get_label(smack, 0, true);
 		if (IS_ERR(skp)) {
 			rc = PTR_ERR(skp);
 			goto free_out;
@@ -1343,10 +1345,16 @@ static int net6addr_seq_show(struct seq_file *s, void *v)
 	struct list_head *list = v;
 	struct smk_net6addr *skp =
 			 list_entry(list, struct smk_net6addr, list);
+	char *kp;
 
-	if (skp->smk_label != NULL)
-		seq_printf(s, "%pI6/%d %s\n", &skp->smk_host, skp->smk_masks,
-				skp->smk_label->smk_known);
+	if (skp->smk_label != NULL) {
+		kp = smk_find_label_name(skp->smk_label);
+		if (kp == NULL)
+			kp = smack_known_huh.smk_known;
+
+		seq_printf(s, "%pI6/%d %s\n", &skp->smk_host,
+				skp->smk_masks, kp);
+	}
 
 	return 0;
 }
@@ -1500,7 +1508,7 @@ static ssize_t smk_write_net6addr(struct file *file, const char __user *buf,
 	 * If smack begins with '-', it is an option, don't import it
 	 */
 	if (smack[0] != '-') {
-		skp = smk_import_entry(smack, 0);
+		skp = smk_get_label(smack, 0, true);
 		if (IS_ERR(skp)) {
 			rc = PTR_ERR(skp);
 			goto free_out;
@@ -1820,6 +1828,7 @@ static ssize_t smk_read_ambient(struct file *filp, char __user *buf,
 				size_t cn, loff_t *ppos)
 {
 	ssize_t rc;
+	char *cp;
 	int asize;
 
 	if (*ppos != 0)
@@ -1830,12 +1839,14 @@ static ssize_t smk_read_ambient(struct file *filp, char __user *buf,
 	 */
 	mutex_lock(&smack_ambient_lock);
 
-	asize = strlen(smack_net_ambient->smk_known) + 1;
+	cp = smk_find_label_name(smack_net_ambient);
+	if (cp == NULL)
+		cp = smack_known_huh.smk_known;
+
+	asize = strlen(cp) + 1;
 
 	if (cn >= asize)
-		rc = simple_read_from_buffer(buf, cn, ppos,
-					     smack_net_ambient->smk_known,
-					     asize);
+		rc = simple_read_from_buffer(buf, cn, ppos, cp, asize);
 	else
 		rc = -EINVAL;
 
@@ -1873,7 +1884,7 @@ static ssize_t smk_write_ambient(struct file *file, const char __user *buf,
 		goto out;
 	}
 
-	skp = smk_import_entry(data, count);
+	skp = smk_get_label(data, count, true);
 	if (IS_ERR(skp)) {
 		rc = PTR_ERR(skp);
 		goto out;
@@ -1913,11 +1924,16 @@ static void *onlycap_seq_next(struct seq_file *s, void *v, loff_t *pos)
 
 static int onlycap_seq_show(struct seq_file *s, void *v)
 {
+	char *smack;
 	struct list_head *list = v;
 	struct smack_onlycap *sop =
 		list_entry_rcu(list, struct smack_onlycap, list);
 
-	seq_puts(s, sop->smk_label->smk_known);
+	smack = smk_find_label_name(sop->smk_label);
+	if (smack == NULL)
+		smack = smack_known_huh.smk_known;
+
+	seq_puts(s, smack);
 	seq_putc(s, ' ');
 
 	return 0;
@@ -2011,7 +2027,7 @@ static ssize_t smk_write_onlycap(struct file *file, const char __user *buf,
 		if (!*tok)
 			continue;
 
-		skp = smk_import_entry(tok, 0);
+		skp = smk_get_label(tok, 0, true);
 		if (IS_ERR(skp)) {
 			rc = PTR_ERR(skp);
 			break;
@@ -2081,8 +2097,11 @@ static ssize_t smk_read_unconfined(struct file *filp, char __user *buf,
 	if (*ppos != 0)
 		return 0;
 
-	if (smack_unconfined != NULL)
-		smack = smack_unconfined->smk_known;
+	if (smack_unconfined != NULL) {
+		smack = smk_find_label_name(smack_unconfined);
+		if (smack == NULL)
+			smack = smack_known_huh.smk_known;
+	}
 
 	asize = strlen(smack) + 1;
 
@@ -2129,7 +2148,7 @@ static ssize_t smk_write_unconfined(struct file *file, const char __user *buf,
 	 *
 	 * But do so only on invalid label, not on system errors.
 	 */
-	skp = smk_import_entry(data, count);
+	skp = smk_get_label(data, count, true);
 	if (PTR_ERR(skp) == -EINVAL)
 		skp = NULL;
 	else if (IS_ERR(skp)) {
@@ -2526,7 +2545,6 @@ static ssize_t smk_write_revoke_subj(struct file *file, const char __user *buf,
 				size_t count, loff_t *ppos)
 {
 	char *data;
-	const char *cp;
 	struct smack_known *skp;
 	struct smack_rule *sp;
 	struct list_head *rule_list;
@@ -2551,15 +2569,13 @@ static ssize_t smk_write_revoke_subj(struct file *file, const char __user *buf,
 		goto out_data;
 	}
 
-	cp = smk_parse_smack(data, count);
-	if (IS_ERR(cp)) {
-		rc = PTR_ERR(cp);
+	skp = smk_get_label(data, count, false);
+	if (IS_ERR(skp)) {
+		rc = PTR_ERR(skp);
 		goto out_data;
 	}
-
-	skp = smk_find_entry(cp);
 	if (skp == NULL)
-		goto out_cp;
+		goto out_data;
 
 	rule_list = &skp->smk_rules;
 	rule_lock = &skp->smk_rules_lock;
@@ -2571,8 +2587,6 @@ static ssize_t smk_write_revoke_subj(struct file *file, const char __user *buf,
 
 	mutex_unlock(rule_lock);
 
-out_cp:
-	kfree(cp);
 out_data:
 	kfree(data);
 
@@ -2641,8 +2655,11 @@ static ssize_t smk_read_syslog(struct file *filp, char __user *buf,
 	if (*ppos != 0)
 		return 0;
 
-	if (smack_syslog_label != NULL)
-		smack = smack_syslog_label->smk_known;
+	if (smack_syslog_label != NULL) {
+		smack = smk_find_label_name(smack_syslog_label);
+		if (smack == NULL)
+			smack = smack_known_huh.smk_known;
+	}
 
 	asize = strlen(smack) + 1;
 
@@ -2689,7 +2706,7 @@ static ssize_t smk_write_syslog(struct file *file, const char __user *buf,
 	 *
 	 * But do so only on invalid label, not on system errors.
 	 */
-	skp = smk_import_entry(data, count);
+	skp = smk_get_label(data, count, true);
 	if (PTR_ERR(skp) == -EINVAL)
 		skp = NULL;
 	else if (IS_ERR(skp)) {
-- 
2.4.3
