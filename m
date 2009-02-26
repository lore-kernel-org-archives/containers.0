From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 4/4] keys: make procfiles per-user-namespace
Date: Thu, 26 Feb 2009 15:50:12 -0600
Message-ID: <20090226215012.GA24500@us.ibm.com>
References: <20090109225313.GB15599@us.ibm.com> <20090109225208.GA15252@us.ibm.com> <5296.1234522990@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759438AbZBZVum@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5296.1234522990@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells@redhat.com):
> Serge E. Hallyn <serue@us.ibm.com> wrote:
> 
> > Restrict the /proc/keys and /proc/key-users output to keys
> > belonging to the same user namespace as the reading task.
> > 
> > We may want to make this more complicated - so that any
> > keys in a user-namespace which is belongs to the reading
> > task are also shown.  But let's see if anyone wants that
> > first.
> 
> Hmmm...  I wonder if we can do better by making the file position indicate the
> key ID rather than being a count of the number of keys read.  It might make
> this cleaner.

Ok, what I came up with so far is the following.  The diffstat
would be far more impressive (in terms of - vs +) if I could
use key_lookup() for proc_keys_start(), but since I need to
return the next greatest key, it seems like I need to do my
own find_ge_key() function.

From cf3961ed60d162bb2b1a3da231009733fd114546 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue@us.ibm.com>
Date: Thu, 26 Feb 2009 13:29:59 -0800
Subject: [PATCH 1/1] keys: /proc/keys: use keyid not numread as fpos

Just an experiment - previously the fpos used in
printing /proc/keys through seq_file interface
represented number of items read.  This patch
instead stores the key->serial in fpos.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 security/keys/proc.c |   63 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 41 insertions(+), 22 deletions(-)

diff --git a/security/keys/proc.c b/security/keys/proc.c
index 769f9bd..6132629 100644
--- a/security/keys/proc.c
+++ b/security/keys/proc.c
@@ -91,8 +91,9 @@ __initcall(key_proc_init);
  */
 #ifdef CONFIG_KEYS_DEBUG_PROC_KEYS
 
-static struct rb_node *__key_serial_next(struct rb_node *n)
+static struct rb_node *key_serial_next(struct rb_node *n)
 {
+	n = rb_next(n);
 	while (n) {
 		struct key *key = rb_entry(n, struct key, serial_node);
 		if (key->user->user_ns == current_user_ns())
@@ -102,44 +103,62 @@ static struct rb_node *__key_serial_next(struct rb_node *n)
 	return n;
 }
 
-static struct rb_node *key_serial_next(struct rb_node *n)
+static int proc_keys_open(struct inode *inode, struct file *file)
 {
-	return __key_serial_next(rb_next(n));
-}
+	return seq_open(file, &proc_keys_ops);
 
-static struct rb_node *key_serial_first(struct rb_root *r)
-{
-	struct rb_node *n = rb_first(r);
-	return __key_serial_next(n);
 }
 
-static int proc_keys_open(struct inode *inode, struct file *file)
+static struct key *find_ge_key(unsigned int id)
 {
-	return seq_open(file, &proc_keys_ops);
+	struct rb_node *n = key_serial_tree.rb_node;
+	struct key *minkey = NULL;
+
+	while (n) {
+		struct key *key = rb_entry(n, struct key, serial_node);
+		if (id < key->serial) {
+			if (!minkey || minkey->serial > key->serial)
+				minkey = key;
+			n = n->rb_left;
+		} else if (id > key->serial)
+			n = n->rb_right;
+		else {
+			minkey = key;
+			break;
+		}
+		key = NULL;
+	}
 
+	return minkey;
 }
 
 static void *proc_keys_start(struct seq_file *p, loff_t *_pos)
 {
-	struct rb_node *_p;
-	loff_t pos = *_pos;
+	struct key *key;
+	unsigned int pos = *_pos;
 
 	spin_lock(&key_serial_lock);
+	key = find_ge_key(pos);
+	if (!key)
+		return NULL;
+	*_pos = key->serial;
+	return &key->serial_node;
+}
 
-	_p = key_serial_first(&key_serial_tree);
-	while (pos > 0 && _p) {
-		pos--;
-		_p = key_serial_next(_p);
-	}
-
-	return _p;
-
+static inline unsigned int key_node_serial(struct rb_node *n)
+{
+	struct key *key = rb_entry(n, struct key, serial_node);
+	return key->serial;
 }
 
 static void *proc_keys_next(struct seq_file *p, void *v, loff_t *_pos)
 {
-	(*_pos)++;
-	return key_serial_next((struct rb_node *) v);
+	struct rb_node *n;
+
+	n = key_serial_next(v);
+	if (n)
+		*_pos = key_node_serial(n);
+	return n;
 
 }
 
-- 
1.5.4.3
