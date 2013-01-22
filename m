From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 04/11] Add backend support for suboridnate uids and gids
Date: Tue, 22 Jan 2013 01:14:35 -0800
Message-ID: <87liblr344.fsf@xmission.com>
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


These files list the set of subordinate uids and gids that users are allowed
to use.   The expect use case is with the user namespace but other uses are
allowed.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 etc/login.defs      |    8 +
 lib/Makefile.am     |    2 +
 lib/getdef.c        |    6 +
 lib/subordinateio.c |  512 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/subordinateio.h |   38 ++++
 5 files changed, 566 insertions(+), 0 deletions(-)
 create mode 100644 lib/subordinateio.c
 create mode 100644 lib/subordinateio.h

diff --git a/etc/login.defs b/etc/login.defs
index 5b6fab3..01a0089 100644
--- a/etc/login.defs
+++ b/etc/login.defs
@@ -226,6 +226,10 @@ UID_MAX			60000
 # System accounts
 SYS_UID_MIN		  101
 SYS_UID_MAX		  999
+# Extra per user uids
+SUB_UID_MIN		   100000
+SUB_UID_MAX		600100000
+SUB_UID_COUNT		    10000
 
 #
 # Min/max values for automatic gid selection in groupadd
@@ -235,6 +239,10 @@ GID_MAX			60000
 # System accounts
 SYS_GID_MIN		  101
 SYS_GID_MAX		  999
+# Extra per user group ids
+SUB_GID_MIN		   100000
+SUB_GID_MAX		600100000
+SUB_GID_COUNT		    10000
 
 #
 # Max number of login retries if password is bad
diff --git a/lib/Makefile.am b/lib/Makefile.am
index c448dd3..6db86cd 100644
--- a/lib/Makefile.am
+++ b/lib/Makefile.am
@@ -39,6 +39,8 @@ libshadow_la_SOURCES = \
 	pwio.c \
 	pwio.h \
 	pwmem.c \
+	subordinateio.h \
+	subordinateio.c \
 	selinux.c \
 	semanage.c \
 	sgetgrent.c \
diff --git a/lib/getdef.c b/lib/getdef.c
index ac08163..f872bb3 100644
--- a/lib/getdef.c
+++ b/lib/getdef.c
@@ -81,6 +81,12 @@ static struct itemdef def_table[] = {
 	{"SHA_CRYPT_MAX_ROUNDS", NULL},
 	{"SHA_CRYPT_MIN_ROUNDS", NULL},
 #endif
+	{"SUB_GID_COUNT", NULL},
+	{"SUB_GID_MAX", NULL},
+	{"SUB_GID_MIN", NULL},
+	{"SUB_UID_COUNT", NULL},
+	{"SUB_UID_MAX", NULL},
+	{"SUB_UID_MIN", NULL},
 	{"SULOG_FILE", NULL},
 	{"SU_NAME", NULL},
 	{"SYS_GID_MAX", NULL},
diff --git a/lib/subordinateio.c b/lib/subordinateio.c
new file mode 100644
index 0000000..851cfa0
--- /dev/null
+++ b/lib/subordinateio.c
@@ -0,0 +1,512 @@
+/*
+ * Copyright (c) 2012 - Eric Biederman
+ */
+
+#include <config.h>
+#include "prototypes.h"
+#include "defines.h"
+#include <stdio.h>
+#include "commonio.h"
+#include "subordinateio.h"
+
+struct subordinate_range {
+	const char *owner;
+	unsigned long start;
+	unsigned long count;
+};
+
+#define NFIELDS 3
+
+static /*@null@*/ /*@only@*/void *subordinate_dup (const void *ent)
+{
+	const struct subordinate_range *rangeent = ent;
+	struct subordinate_range *range;
+
+	range = (struct subordinate_range *) malloc (sizeof *range);
+	if (NULL == range) {
+		return NULL;
+	}
+	range->owner = strdup (rangeent->owner);
+	if (NULL == range->owner) {
+		free(range);
+		return NULL;
+	}
+	range->start = rangeent->start;
+	range->count = rangeent->count;
+
+	return range;
+}
+
+static void subordinate_free (/*@out@*/ /*@only@*/void *ent)
+{
+	struct subordinate_range *rangeent = ent;
+	
+	free ((void *)(rangeent->owner));
+	free (rangeent);
+}
+
+static void *subordinate_parse (const char *line)
+{
+	static struct subordinate_range range;
+	char rangebuf[1024];
+	int i;
+	char *cp;
+	char *fields[NFIELDS];
+
+	/*
+	 * Copy the string to a temporary buffer so the substrings can
+	 * be modified to be NULL terminated.
+	 */
+	if (strlen (line) >= sizeof rangebuf)
+		return NULL;	/* fail if too long */
+	strcpy (rangebuf, line);
+
+	/*
+	 * Save a pointer to the start of each colon separated
+	 * field.  The fields are converted into NUL terminated strings.
+	 */
+
+	for (cp = rangebuf, i = 0; (i < NFIELDS) && (NULL != cp); i++) {
+		fields[i] = cp;
+		while (('\0' != *cp) && (':' != *cp)) {
+			cp++;
+		}
+
+		if ('\0' != *cp) {
+			*cp = '\0';
+			cp++;
+		} else {
+			cp = NULL;
+		}
+	}
+
+	/*
+	 * There must be exactly NFIELDS colon separated fields or
+	 * the entry is invalid.  Also, fields must be non-blank.
+	 */
+	if (i != NFIELDS || *fields[0] == '\0' || *fields[1] == '\0' || *fields[2] == '\0')
+		return NULL;
+	range.owner = fields[0];
+	if (getulong (fields[1], &range.start) == 0)
+		return NULL;
+	if (getulong (fields[2], &range.count) == 0)
+		return NULL;
+
+	return &range;
+}
+
+static int subordinate_put (const void *ent, FILE * file)
+{
+	const struct subordinate_range *range = ent;
+
+	return fprintf(file, "%s:%lu:%lu\n",
+			       range->owner,
+			       range->start,
+			       range->count) < 0 ? -1  : 0;
+}
+
+static struct commonio_ops subordinate_ops = {
+	subordinate_dup,	/* dup */
+	subordinate_free,	/* free */
+	NULL,			/* getname */
+	subordinate_parse,	/* parse */
+	subordinate_put,	/* put */
+	fgets,			/* fgets */
+	fputs,			/* fputs */
+	NULL,			/* open_hook */
+	NULL,			/* close_hook */
+};
+
+static /*@observer@*/ /*@null*/const struct subordinate_range *subordinate_next(struct commonio_db *db)
+{
+	commonio_next (db);
+}
+
+static bool is_range_free(struct commonio_db *db, unsigned long start,
+			  unsigned long count)
+{
+	const struct subordinate_range *range;
+	unsigned long end = start + count - 1;
+
+	commonio_rewind(db);
+	while ((range = commonio_next(db)) != NULL) {
+		unsigned long first = range->start;
+		unsigned long last = first + range->count - 1;
+
+		if ((end >= first) && (start <= last))
+			return false;
+	}
+	return true;
+}
+
+static const bool range_exists(struct commonio_db *db, const char *owner)
+{
+	const struct subordinate_range *range;
+	commonio_rewind(db);
+	while ((range = commonio_next(db)) != NULL) {
+		unsigned long first = range->start;
+		unsigned long last = first + range->count - 1;
+
+		if (0 == strcmp(range->owner, owner))
+			return true;
+	}
+	return false;
+}
+
+static const struct subordinate_range *find_range(struct commonio_db *db,
+						  const char *owner, unsigned long val)
+{
+	const struct subordinate_range *range;
+	commonio_rewind(db);
+	while ((range = commonio_next(db)) != NULL) {
+		unsigned long first = range->start;
+		unsigned long last = first + range->count - 1;
+
+		if (0 != strcmp(range->owner, owner))
+			continue;
+
+		if ((val >= first) && (val <= last))
+			return range;
+	}
+	return NULL;
+}
+
+static bool have_range(struct commonio_db *db,
+		       const char *owner, unsigned long start, unsigned long count)
+{
+	const struct subordinate_range *range;
+	unsigned long end;
+
+	if (count == 0)
+		return false;
+
+	end = start + count - 1;
+	range = find_range (db, owner, start);
+	while (range) {
+		unsigned long last; 
+
+		last = range->start + range->count - 1;
+		if (last >= (start + count - 1))
+			return true;
+
+		count = end - last;
+		start = last + 1;
+		range = find_range(db, owner, start);
+	}
+	return false;
+}
+
+static int subordinate_range_cmp (const void *p1, const void *p2)
+{
+	struct subordinate_range *range1, *range2;
+
+	if ((*(struct commonio_entry **) p1)->eptr == NULL)
+		return 1;
+	if ((*(struct commonio_entry **) p2)->eptr == NULL)
+		return -1;
+
+	range1 = ((struct subordinate_range *) (*(struct commonio_entry **) p1)->eptr);
+	range2 = ((struct subordinate_range *) (*(struct commonio_entry **) p2)->eptr);
+
+	if (range1->start < range2->start)
+		return -1;
+	else if (range1->start > range2->start)
+		return 1;
+	else if (range1->count < range2->count)
+		return -1;
+	else if (range1->count > range2->count)
+		return 1;
+	else
+		return strcmp(range1->owner, range2->owner);
+}
+
+static unsigned long find_free_range(struct commonio_db *db,
+				     unsigned long min, unsigned long max,
+				     unsigned long count)
+{
+	const struct subordinate_range *range;
+	unsigned long low, high;
+
+	/* When given invalid parameters fail */
+	if ((count == 0) || (max <= min))
+		goto fail;
+
+	/* Sort by range than by owner */
+	commonio_sort (db, subordinate_range_cmp);
+	commonio_rewind(db);
+
+	low = min;
+	while ((range = commonio_next(db)) != NULL) {
+		unsigned long first = range->start;
+		unsigned long last = first + range->count - 1;
+
+		/* Find the top end of the hole before this range */
+		high = first;
+		if (high > max)
+			high = max;
+
+		/* Is the hole before this range large enough? */
+		if ((high > low) && (((high - low) + 1) >= count))
+			return low;
+
+		/* Compute the low end of the next hole */
+		if (low < (last + 1))
+			low = last + 1;
+		if (low > max)
+			goto fail;
+	}
+
+	/* Is the remaining unclaimed area large enough? */
+	if (((max - low) + 1) >= count)
+		return low;
+fail:
+	return ULONG_MAX;
+}
+
+static int add_range(struct commonio_db *db,
+	const char *owner, unsigned long start, unsigned long count)
+{
+	struct subordinate_range range;
+	range.owner = owner;
+	range.start = start;
+	range.count = count;
+
+	/* See if the range is already present */
+	if (have_range(db, owner, start, count))
+		return 1;
+
+	/* Oterwise append the range */
+	return commonio_append(db, &range);
+}
+
+static int remove_range(struct commonio_db *db,
+	const char *owner, unsigned long start, unsigned long count)
+{
+	struct commonio_entry *ent;
+	unsigned long end;
+
+	if (count == 0)
+		return 1;
+
+	end = start + count - 1;
+	for (ent = db->head; ent; ent = ent->next) {
+		struct subordinate_range *range = ent->eptr;
+		unsigned long first;
+		unsigned long last;
+
+		/* Skip unparsed entries */
+		if (!range)
+			continue;
+
+		first = range->start;
+		last = first + range->count - 1;
+
+		/* Skip entries with a different owner */
+		if (0 != strcmp(range->owner, owner))
+			continue;
+
+		/* Skip entries outside of the range to remove */
+		if ((end < first) || (start > last))
+			continue;
+
+		/* Is entry completely contained in the range to remove? */
+		if ((start <= first) && (end >= last)) {
+			commonio_del_entry (db, ent);
+		} 
+		/* Is just the start of the entry removed? */
+		else if ((start <= first) && (end < last)) {
+			range->start = end + 1;
+			range->count = (last - range->start) + 1;
+
+			ent->changed = true;
+		}
+		/* Is just the end of the entry removed? */
+		else if ((start > first) && (end >= last)) {
+			range->count = (start - range->start) + 1;
+
+			ent->changed = true;
+		}
+		/* The middle of the range is removed */
+		else {
+			struct subordinate_range tail;
+			tail.owner = range->owner;
+			tail.start = end + 1;
+			tail.count = (last - tail.start) + 1;
+
+			if (!commonio_append(db, &tail))
+				return 0;
+
+			range->count = (start - range->start) + 1;
+
+			ent->changed = true;
+		}
+	}
+
+	return 1;
+}
+
+static struct commonio_db subordinate_uid_db = {
+	"/etc/subuid",		/* filename */
+	&subordinate_ops,	/* ops */
+	NULL,			/* fp */
+#ifdef WITH_SELINUX
+	NULL,			/* scontext */
+#endif
+	NULL,			/* head */
+	NULL,			/* tail */
+	NULL,			/* cursor */
+	false,			/* changed */
+	false,			/* isopen */
+	false,			/* locked */
+	false			/* readonly */
+};
+
+int sub_uid_setdbname (const char *filename)
+{
+	return commonio_setname (&subordinate_uid_db, filename);
+}
+
+/*@observer@*/const char *sub_uid_dbname (void)
+{
+	return subordinate_uid_db.filename;
+}
+
+bool sub_uid_file_present (void)
+{
+	return commonio_present (&subordinate_uid_db);
+}
+
+int sub_uid_lock (void)
+{
+	return commonio_lock (&subordinate_uid_db);
+}
+
+int sub_uid_open (int mode)
+{
+	return commonio_open (&subordinate_uid_db, mode);
+}
+
+bool is_sub_uid_range_free(uid_t start, unsigned long count)
+{
+	return is_range_free (&subordinate_uid_db, start, count);
+}
+
+bool sub_uid_assigned(const char *owner)
+{
+	return range_exists (&subordinate_uid_db, owner);
+}
+
+bool have_sub_uids(const char *owner, uid_t start, unsigned long count)
+{
+	return have_range (&subordinate_uid_db, owner, start, count);
+}
+
+int sub_uid_add (const char *owner, uid_t start, unsigned long count)
+{
+	return add_range (&subordinate_uid_db, owner, start, count);
+}
+
+int sub_uid_remove (const char *owner, uid_t start, unsigned long count)
+{
+	return remove_range (&subordinate_uid_db, owner, start, count);
+}
+
+int sub_uid_close (void)
+{
+	return commonio_close (&subordinate_uid_db);
+}
+
+int sub_uid_unlock (void)
+{
+	return commonio_unlock (&subordinate_uid_db);
+}
+
+uid_t sub_uid_find_free_range(uid_t min, uid_t max, unsigned long count)
+{
+	unsigned long start;
+	start = find_free_range (&subordinate_uid_db, min, max, count);
+	return start == ULONG_MAX ? (uid_t) -1 : start;
+}
+
+static struct commonio_db subordinate_gid_db = {
+	"/etc/subgid",		/* filename */
+	&subordinate_ops,	/* ops */
+	NULL,			/* fp */
+#ifdef WITH_SELINUX
+	NULL,			/* scontext */
+#endif
+	NULL,			/* head */
+	NULL,			/* tail */
+	NULL,			/* cursor */
+	false,			/* changed */
+	false,			/* isopen */
+	false,			/* locked */
+	false			/* readonly */
+};
+
+int sub_gid_setdbname (const char *filename)
+{
+	return commonio_setname (&subordinate_gid_db, filename);
+}
+
+/*@observer@*/const char *sub_gid_dbname (void)
+{
+	return subordinate_gid_db.filename;
+}
+
+bool sub_gid_file_present (void)
+{
+	return commonio_present (&subordinate_gid_db);
+}
+
+int sub_gid_lock (void)
+{
+	return commonio_lock (&subordinate_gid_db);
+}
+
+int sub_gid_open (int mode)
+{
+	return commonio_open (&subordinate_gid_db, mode);
+}
+
+bool is_sub_gid_range_free(gid_t start, unsigned long count)
+{
+	return is_range_free (&subordinate_gid_db, start, count);
+}
+
+bool have_sub_gids(const char *owner, gid_t start, unsigned long count)
+{
+	return have_range(&subordinate_gid_db, owner, start, count);
+}
+
+bool sub_gid_assigned(const char *owner)
+{
+	return range_exists (&subordinate_gid_db, owner);
+}
+
+int sub_gid_add (const char *owner, gid_t start, unsigned long count)
+{
+	return add_range (&subordinate_gid_db, owner, start, count);
+}
+
+int sub_gid_remove (const char *owner, gid_t start, unsigned long count)
+{
+	return remove_range (&subordinate_gid_db, owner, start, count);
+}
+
+int sub_gid_close (void)
+{
+	return commonio_close (&subordinate_gid_db);
+}
+
+int sub_gid_unlock (void)
+{
+	return commonio_unlock (&subordinate_gid_db);
+}
+
+gid_t sub_gid_find_free_range(gid_t min, gid_t max, unsigned long count)
+{
+	unsigned long start;
+	start = find_free_range (&subordinate_gid_db, min, max, count);
+	return start == ULONG_MAX ? (gid_t) -1 : start;
+}
diff --git a/lib/subordinateio.h b/lib/subordinateio.h
new file mode 100644
index 0000000..f27b3c0
--- /dev/null
+++ b/lib/subordinateio.h
@@ -0,0 +1,38 @@
+/*
+ * Copyright (c) 2012- Eric W. Biederman
+ */
+
+#ifndef _SUBORDINATEIO_H
+#define _SUBORDINATEIO_H
+
+#include <sys/types.h>
+
+extern int sub_uid_close(void);
+extern bool is_sub_uid_range_free(uid_t start, unsigned long count);
+extern bool have_sub_uids(const char *owner, uid_t start, unsigned long count);
+extern bool sub_uid_file_present (void);
+extern bool sub_uid_assigned(const char *owner);
+extern int sub_uid_lock (void);
+extern int sub_uid_setdbname (const char *filename);
+extern /*@observer@*/const char *sub_uid_dbname (void);
+extern int sub_uid_open (int mode);
+extern int sub_uid_unlock (void);
+extern int sub_uid_add (const char *owner, uid_t start, unsigned long count);
+extern int sub_uid_remove (const char *owner, uid_t start, unsigned long count);
+extern uid_t sub_uid_find_free_range(uid_t min, uid_t max, unsigned long count);
+
+extern int sub_gid_close(void);
+extern bool is_sub_gid_range_free(gid_t start, unsigned long count);
+extern bool have_sub_gids(const char *owner, gid_t start, unsigned long count);
+extern bool sub_gid_file_present (void);
+extern bool sub_gid_assigned(const char *owner);
+extern int sub_gid_lock (void);
+extern int sub_gid_setdbname (const char *filename);
+extern /*@observer@*/const char *sub_gid_dbname (void);
+extern int sub_gid_open (int mode);
+extern int sub_gid_unlock (void);
+extern int sub_gid_add (const char *owner, gid_t start, unsigned long count);
+extern int sub_gid_remove (const char *owner, gid_t start, unsigned long count);
+extern uid_t sub_gid_find_free_range(gid_t min, gid_t max, unsigned long count);
+
+#endif
-- 
1.7.5.4
