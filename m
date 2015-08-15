From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 4/7] dcache: Implement d_common_ancestor
Date: Sat, 15 Aug 2015 13:37:55 -0500
Message-ID: <87k2sw5rek.fsf_-___16658.2836457112$1439664308$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<87egjk9i61.fsf_-_@x220.int.ebiederm.org>
	<20150810043637.GC14139@ZenIV.linux.org.uk>
	<877foymrwt.fsf@x220.int.ebiederm.org>
	<87wpwyjxwc.fsf_-_@x220.int.ebiederm.org>
	<87fv3mjxsc.fsf_-_@x220.int.ebiederm.org>
	<20150815061617.GG14139@ZenIV.linux.org.uk>
	<874mk08l3g.fsf@x220.int.ebiederm.org>
	<87a8ts763c.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87a8ts763c.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Sat, 15 Aug 2015 13:35:19 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


If possible find the common ancestor of two dentries.

This is necessary infrastructure for better handling the case
when a dentry is moved out from under the root of a bind mount.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c            | 37 +++++++++++++++++++++++++++++++++++++
 include/linux/dcache.h |  1 +
 2 files changed, 38 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 53b7f1e63beb..4e66bf92a481 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2469,6 +2469,43 @@ void dentry_update_name_case(struct dentry *dentry, struct qstr *name)
 }
 EXPORT_SYMBOL(dentry_update_name_case);
 
+static unsigned long d_depth(const struct dentry *dentry)
+{
+	unsigned long depth = 0;
+
+	while (!IS_ROOT(dentry)) {
+		dentry = dentry->d_parent;
+		depth++;
+	}
+	return depth;
+}
+
+const struct dentry *d_common_ancestor(const struct dentry *left,
+				       const struct dentry *right)
+{
+	unsigned long ldepth = d_depth(left);
+	unsigned long rdepth = d_depth(right);
+
+	while (ldepth > rdepth) {
+		left = left->d_parent;
+		ldepth--;
+	}
+
+	while (rdepth > ldepth) {
+		right = right->d_parent;
+		rdepth--;
+	}
+
+	while (left != right) {
+		if (IS_ROOT(left))
+			return NULL;
+		left = left->d_parent;
+		right = right->d_parent;
+	}
+
+	return left;
+}
+
 static void swap_names(struct dentry *dentry, struct dentry *target)
 {
 	if (unlikely(dname_external(target))) {
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 06bed2a1053c..5b69856b45a2 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -313,6 +313,7 @@ extern void dentry_update_name_case(struct dentry *, struct qstr *);
 extern void d_move(struct dentry *, struct dentry *);
 extern void d_exchange(struct dentry *, struct dentry *);
 extern struct dentry *d_ancestor(struct dentry *, struct dentry *);
+extern const struct dentry *d_common_ancestor(const struct dentry *, const struct dentry *);
 
 /* appendix may either be NULL or be used for transname suffixes */
 extern struct dentry *d_lookup(const struct dentry *, const struct qstr *);
-- 
2.2.1
