From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 05/11] Implement find_new_sub_uids find_new_sub_gids
Date: Tue, 22 Jan 2013 01:15:05 -0800
Message-ID: <87fw1tr33a.fsf@xmission.com>
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


Functions for finding new subordinate uid and gids ranges for use
with useradd.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 lib/prototypes.h            |    9 ++++
 libmisc/Makefile.am         |    2 +
 libmisc/find_new_sub_gids.c |   87 +++++++++++++++++++++++++++++++++++++++++++
 libmisc/find_new_sub_uids.c |   87 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 185 insertions(+), 0 deletions(-)
 create mode 100644 libmisc/find_new_sub_gids.c
 create mode 100644 libmisc/find_new_sub_uids.c

diff --git a/lib/prototypes.h b/lib/prototypes.h
index 00d9e0b..487fb07 100644
--- a/lib/prototypes.h
+++ b/lib/prototypes.h
@@ -149,6 +149,15 @@ extern int find_new_uid (bool sys_user,
                          uid_t *uid,
                          /*@null@*/uid_t const *preferred_uid);
 
+/* find_new_sub_gids.c */
+extern int find_new_sub_gids (const char *owner,
+			      gid_t *range_start, unsigned long *range_count);
+
+/* find_new_sub_uids.c */
+extern int find_new_sub_uids (const char *owner,
+			      uid_t *range_start, unsigned long *range_count);
+
+
 /* get_gid.c */
 extern int get_gid (const char *gidstr, gid_t *gid);
 
diff --git a/libmisc/Makefile.am b/libmisc/Makefile.am
index 9da2ec3..5de9193 100644
--- a/libmisc/Makefile.am
+++ b/libmisc/Makefile.am
@@ -25,6 +25,8 @@ libmisc_a_SOURCES = \
 	failure.h \
 	find_new_gid.c \
 	find_new_uid.c \
+	find_new_sub_gids.c \
+	find_new_sub_uids.c \
 	getdate.h \
 	getdate.y \
 	getgr_nam_gid.c \
diff --git a/libmisc/find_new_sub_gids.c b/libmisc/find_new_sub_gids.c
new file mode 100644
index 0000000..68046ac
--- /dev/null
+++ b/libmisc/find_new_sub_gids.c
@@ -0,0 +1,87 @@
+/*
+ * Copyright (c) 2012 Eric Biederman
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. The name of the copyright holders or contributors may not be used to
+ *    endorse or promote products derived from this software without
+ *    specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ * PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
+ * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <config.h>
+
+#include <assert.h>
+#include <stdio.h>
+#include <errno.h>
+
+#include "prototypes.h"
+#include "subordinateio.h"
+#include "getdef.h"
+
+/*
+ * find_new_sub_gids - Find a new unused range of GIDs.
+ *
+ * If successful, find_new_sub_gids provides a range of unused
+ * user IDs in the [SUB_GID_MIN:SUB_GID_MAX] range.
+ * 
+ * Return 0 on success, -1 if no unused GIDs are available.
+ */
+int find_new_sub_gids (const char *owner,
+		       gid_t *range_start, unsigned long *range_count)
+{
+	unsigned long min, max;
+	unsigned long count;
+	gid_t start;
+
+	assert (range_start != NULL);
+	assert (range_count != NULL);
+
+	min = getdef_ulong ("SUB_GID_MIN", 100000UL);
+	max = getdef_ulong ("SUB_GID_MAX", 600100000UL);
+	count = getdef_ulong ("SUB_GID_COUNT", 10000);
+
+	/* Is there a preferred range that works? */
+	if ((*range_count != 0) &&
+	    (*range_start >= min) &&
+	    (((*range_start) + (*range_count) - 1) <= max) &&
+	    is_sub_gid_range_free(*range_start, *range_count)) {
+		return 0;
+	}
+
+	if (max < (min + count)) {
+		(void) fprintf (stderr,
+				_("%s: Invalid configuration: SUB_GID_MIN (%lu), SUB_GID_MAX (%lu)\n"),
+			Prog, min, max);
+		return -1;
+	}
+	start = sub_gid_find_free_range(min, max, count);
+	if (start == (gid_t)-1) {
+		fprintf (stderr,
+		         _("%s: Can't get unique secondary GID range\n"),
+		         Prog);
+		SYSLOG ((LOG_WARN, "no more available secondary GIDs on the system"));
+		return -1;
+	}
+	*range_start = start;
+	*range_count = count;
+	return 0;
+}
+
diff --git a/libmisc/find_new_sub_uids.c b/libmisc/find_new_sub_uids.c
new file mode 100644
index 0000000..f1720f9
--- /dev/null
+++ b/libmisc/find_new_sub_uids.c
@@ -0,0 +1,87 @@
+/*
+ * Copyright (c) 2012 Eric Biederman
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. The name of the copyright holders or contributors may not be used to
+ *    endorse or promote products derived from this software without
+ *    specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ * PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
+ * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <config.h>
+
+#include <assert.h>
+#include <stdio.h>
+#include <errno.h>
+
+#include "prototypes.h"
+#include "subordinateio.h"
+#include "getdef.h"
+
+/*
+ * find_new_sub_uids - Find a new unused range of UIDs.
+ *
+ * If successful, find_new_sub_uids provides a range of unused
+ * user IDs in the [SUB_UID_MIN:SUB_UID_MAX] range.
+ * 
+ * Return 0 on success, -1 if no unused UIDs are available.
+ */
+int find_new_sub_uids (const char *owner,
+		       uid_t *range_start, unsigned long *range_count)
+{
+	unsigned long min, max;
+	unsigned long count;
+	uid_t start;
+
+	assert (range_start != NULL);
+	assert (range_count != NULL);
+
+	min = getdef_ulong ("SUB_UID_MIN", 100000UL);
+	max = getdef_ulong ("SUB_UID_MAX", 600100000UL);
+	count = getdef_ulong ("SUB_UID_COUNT", 10000);
+
+	/* Is there a preferred range that works? */
+	if ((*range_count != 0) &&
+	    (*range_start >= min) &&
+	    (((*range_start) + (*range_count) - 1) <= max) &&
+	    is_sub_uid_range_free(*range_start, *range_count)) {
+		return 0;
+	}
+
+	if (max < (min + count)) {
+		(void) fprintf (stderr,
+				_("%s: Invalid configuration: SUB_UID_MIN (%lu), SUB_UID_MAX (%lu)\n"),
+			Prog, min, max);
+		return -1;
+	}
+	start = sub_uid_find_free_range(min, max, count);
+	if (start == (uid_t)-1) {
+		fprintf (stderr,
+		         _("%s: Can't get unique secondary UID range\n"),
+		         Prog);
+		SYSLOG ((LOG_WARN, "no more available secondary UIDs on the system"));
+		return -1;
+	}
+	*range_start = start;
+	*range_count = count;
+	return 0;
+}
+
-- 
1.7.5.4
