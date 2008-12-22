From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] keys: make procfiles per-user-namespace
Date: Mon, 22 Dec 2008 13:35:44 -0600
Message-ID: <20081222193544.GA21939@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Restrict the /proc/keys and /proc/key-users output to keys
belonging to the same user namespace as the reading task.

We may want to make this more complicated - so that any
keys in a user-namespace which is belongs to the reading
task are also shown.  But let's see if anyone wants that
first.

(This applies on top of the 3 keys-userns patches I sent
last week, on top of security-next)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 security/keys/proc.c |   55 ++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 49 insertions(+), 6 deletions(-)

diff --git a/security/keys/proc.c b/security/keys/proc.c
index 7f508de..769f9bd 100644
--- a/security/keys/proc.c
+++ b/security/keys/proc.c
@@ -91,6 +91,28 @@ __initcall(key_proc_init);
  */
 #ifdef CONFIG_KEYS_DEBUG_PROC_KEYS
 
+static struct rb_node *__key_serial_next(struct rb_node *n)
+{
+	while (n) {
+		struct key *key = rb_entry(n, struct key, serial_node);
+		if (key->user->user_ns == current_user_ns())
+			break;
+		n = rb_next(n);
+	}
+	return n;
+}
+
+static struct rb_node *key_serial_next(struct rb_node *n)
+{
+	return __key_serial_next(rb_next(n));
+}
+
+static struct rb_node *key_serial_first(struct rb_root *r)
+{
+	struct rb_node *n = rb_first(r);
+	return __key_serial_next(n);
+}
+
 static int proc_keys_open(struct inode *inode, struct file *file)
 {
 	return seq_open(file, &proc_keys_ops);
@@ -104,10 +126,10 @@ static void *proc_keys_start(struct seq_file *p, loff_t *_pos)
 
 	spin_lock(&key_serial_lock);
 
-	_p = rb_first(&key_serial_tree);
+	_p = key_serial_first(&key_serial_tree);
 	while (pos > 0 && _p) {
 		pos--;
-		_p = rb_next(_p);
+		_p = key_serial_next(_p);
 	}
 
 	return _p;
@@ -117,7 +139,7 @@ static void *proc_keys_start(struct seq_file *p, loff_t *_pos)
 static void *proc_keys_next(struct seq_file *p, void *v, loff_t *_pos)
 {
 	(*_pos)++;
-	return rb_next((struct rb_node *) v);
+	return key_serial_next((struct rb_node *) v);
 
 }
 
@@ -203,6 +225,27 @@ static int proc_keys_show(struct seq_file *m, void *v)
 
 #endif /* CONFIG_KEYS_DEBUG_PROC_KEYS */
 
+static struct rb_node *__key_user_next(struct rb_node *n)
+{
+	while (n) {
+		struct key_user *user = rb_entry(n, struct key_user, node);
+		if (user->user_ns == current_user_ns())
+			break;
+		n = rb_next(n);
+	}
+	return n;
+}
+
+static struct rb_node *key_user_next(struct rb_node *n)
+{
+	return __key_user_next(rb_next(n));
+}
+
+static struct rb_node *key_user_first(struct rb_root *r)
+{
+	struct rb_node *n = rb_first(r);
+	return __key_user_next(n);
+}
 /*****************************************************************************/
 /*
  * implement "/proc/key-users" to provides a list of the key users
@@ -220,10 +263,10 @@ static void *proc_key_users_start(struct seq_file *p, loff_t *_pos)
 
 	spin_lock(&key_user_lock);
 
-	_p = rb_first(&key_user_tree);
+	_p = key_user_first(&key_user_tree);
 	while (pos > 0 && _p) {
 		pos--;
-		_p = rb_next(_p);
+		_p = key_user_next(_p);
 	}
 
 	return _p;
@@ -233,7 +276,7 @@ static void *proc_key_users_start(struct seq_file *p, loff_t *_pos)
 static void *proc_key_users_next(struct seq_file *p, void *v, loff_t *_pos)
 {
 	(*_pos)++;
-	return rb_next((struct rb_node *) v);
+	return key_user_next((struct rb_node *) v);
 
 }
 
-- 
1.5.4.3
