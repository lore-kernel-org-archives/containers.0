From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 03/11] Implement commonio_append.
Date: Tue, 22 Jan 2013 01:13:54 -0800
Message-ID: <87pq0xr359.fsf@xmission.com>
References: <87d2wxshu0.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2wxshu0.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Tue, 22 Jan 2013 01:11:19 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nicolas =?utf-8?Q?Fran=C3=A7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


To support files that do not have a simple unique key implement
commonio_append to allow new entries to be added.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 lib/commonio.c |   30 ++++++++++++++++++++++++++++++
 lib/commonio.h |    1 +
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/lib/commonio.c b/lib/commonio.c
index 6b6ce7b..7a76975 100644
--- a/lib/commonio.c
+++ b/lib/commonio.c
@@ -1113,6 +1113,36 @@ int commonio_update (struct commonio_db *db, const void *eptr)
 	return 1;
 }
 
+int commonio_append (struct commonio_db *db, const void *eptr)
+{
+	struct commonio_entry *p;
+	void *nentry;
+
+	if (!db->isopen || db->readonly) {
+		errno = EINVAL;
+		return 0;
+	}
+	nentry = db->ops->dup (eptr);
+	if (NULL == nentry) {
+		errno = ENOMEM;
+		return 0;
+	}
+	/* new entry */
+	p = (struct commonio_entry *) malloc (sizeof *p);
+	if (NULL == p) {
+		db->ops->free (nentry);
+		errno = ENOMEM;
+		return 0;
+	}
+
+	p->eptr = nentry;
+	p->line = NULL;
+	p->changed = true;
+	add_one_entry (db, p);
+
+	db->changed = true;
+	return 1;
+}
 
 void commonio_del_entry (struct commonio_db *db, const struct commonio_entry *p)
 {
diff --git a/lib/commonio.h b/lib/commonio.h
index a1117a8..1866b89 100644
--- a/lib/commonio.h
+++ b/lib/commonio.h
@@ -146,6 +146,7 @@ extern int commonio_lock_nowait (struct commonio_db *, bool log);
 extern int commonio_open (struct commonio_db *, int);
 extern /*@observer@*/ /*@null@*/const void *commonio_locate (struct commonio_db *, const char *);
 extern int commonio_update (struct commonio_db *, const void *);
+extern int commonio_append (struct commonio_db *, const void *);
 extern int commonio_remove (struct commonio_db *, const char *);
 extern int commonio_rewind (struct commonio_db *);
 extern /*@observer@*/ /*@null@*/const void *commonio_next (struct commonio_db *);
-- 
1.7.5.4
