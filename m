From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 11/11] newuidmap,
	newgidmap: New suid helpers for using subordinate uids and gids
Date: Tue, 22 Jan 2013 01:20:07 -0800
Message-ID: <87ehhdpoag.fsf@xmission.com>
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


Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 libmisc/Makefile.am |    2 +
 libmisc/idmapping.c |  126 +++++++++++++++++++++++++++++++++++
 libmisc/idmapping.h |   44 ++++++++++++
 man/Makefile.am     |    4 +
 man/newgidmap.1.xml |  157 +++++++++++++++++++++++++++++++++++++++++++
 man/newuidmap.1.xml |  154 +++++++++++++++++++++++++++++++++++++++++++
 src/Makefile.am     |    5 +-
 src/newgidmap.c     |  183 +++++++++++++++++++++++++++++++++++++++++++++++++++
 src/newuidmap.c     |  183 +++++++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 856 insertions(+), 2 deletions(-)
 create mode 100644 libmisc/idmapping.c
 create mode 100644 libmisc/idmapping.h
 create mode 100644 man/newgidmap.1.xml
 create mode 100644 man/newuidmap.1.xml
 create mode 100644 src/newgidmap.c
 create mode 100644 src/newuidmap.c

diff --git a/libmisc/Makefile.am b/libmisc/Makefile.am
index 5de9193..76f3c05 100644
--- a/libmisc/Makefile.am
+++ b/libmisc/Makefile.am
@@ -32,6 +32,8 @@ libmisc_a_SOURCES = \
 	getgr_nam_gid.c \
 	getrange.c \
 	hushed.c \
+	idmapping.h \
+	idmapping.c \
 	isexpired.c \
 	limits.c \
 	list.c log.c \
diff --git a/libmisc/idmapping.c b/libmisc/idmapping.c
new file mode 100644
index 0000000..cb9e898
--- /dev/null
+++ b/libmisc/idmapping.c
@@ -0,0 +1,126 @@
+/*
+ * Copyright (c) 2013 Eric Biederman
+ * All rights reserved.
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
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <limits.h>
+#include <stdlib.h>
+#include "prototypes.h"
+#include "idmapping.h"
+
+struct map_range *get_map_ranges(int ranges, int argc, char **argv)
+{
+	struct map_range *mappings, *mapping;
+	int idx, argidx;
+
+	if ((ranges * 3) > argc) {
+		fprintf(stderr, "ranges: %u argc: %d\n",
+			ranges, argc);
+		fprintf(stderr,
+			_( "%s: Not enough arguments to form %u mappings\n"),
+			Prog, ranges);
+		return NULL;
+	}
+
+	mappings = calloc(ranges, sizeof(*mappings));
+	if (!mappings) {
+		fprintf(stderr, _( "%s: Memory allocation failure\n"),
+			Prog);
+		exit(EXIT_FAILURE);
+	}
+
+	/* Gather up the ranges from the command line */
+	mapping = mappings;
+	for (idx = 0; idx < ranges; idx++, argidx += 3, mapping++) {
+		if (!getulong(argv[argidx + 0], &mapping->upper))
+			return NULL;
+		if (!getulong(argv[argidx + 1], &mapping->lower))
+			return NULL;
+		if (!getulong(argv[argidx + 2], &mapping->count))
+			return NULL;
+	}
+	return mappings;
+}
+
+/* Number of ascii digits needed to print any unsigned long in decimal.
+ * There are approximately 10 bits for every 3 decimal digits.
+ * So from bits to digits the formula is roundup((Number of bits)/10) * 3.
+ * For common sizes of integers this works out to:
+ *  2bytes -->  6 ascii estimate  -> 65536  (5 real)
+ *  4bytes --> 12 ascii estimated -> 4294967296 (10 real)
+ *  8bytes --> 21 ascii estimated -> 18446744073709551616 (20 real)
+ * 16bytes --> 39 ascii estimated -> 340282366920938463463374607431768211456 (39 real)
+ */
+#define ULONG_DIGITS ((((sizeof(unsigned long) * CHAR_BIT) + 9)/10)*3)
+
+
+void write_mapping(int proc_dir_fd, int ranges, struct map_range *mappings,
+	const char *map_file)
+{
+	int idx;
+	struct map_range *mapping;
+	size_t bufsize;
+	char *buf, *pos;
+	int fd;
+
+	bufsize = ranges * ((ULONG_DIGITS  + 1) * 3);
+	pos = buf = xmalloc(bufsize);
+
+	/* Build the mapping command */
+	mapping = mappings;
+	for (idx = 0; idx < ranges; idx++, mapping++) {
+		/* Append this range to the string that will be written */
+		int written = snprintf(pos, bufsize - (pos - buf),
+			"%lu %lu %lu\n",
+			mapping->upper,
+			mapping->lower,
+			mapping->count);
+		if ((written <= 0) || (written >= (bufsize - (pos - buf)))) {
+			fprintf(stderr, _("%s: snprintf failed!\n"), Prog);
+			exit(EXIT_FAILURE);
+		}
+		pos += written;
+	}
+
+	/* Write the mapping to the maping file */
+	fd = openat(proc_dir_fd, map_file, O_WRONLY);
+	if (fd < 0) {
+		fprintf(stderr, _("%s: open of %s failed: %s\n"),
+			Prog, map_file, strerror(errno));
+		exit(EXIT_FAILURE);
+	}
+	if (write(fd, buf, pos - buf) != (pos - buf)) {
+		fprintf(stderr, _("%s: write to %s failed: %s\n"),
+			Prog, map_file, strerror(errno));
+		exit(EXIT_FAILURE);
+	}
+	close(fd);
+}
diff --git a/libmisc/idmapping.h b/libmisc/idmapping.h
new file mode 100644
index 0000000..88cf761
--- /dev/null
+++ b/libmisc/idmapping.h
@@ -0,0 +1,44 @@
+/*
+ * Copyright (c) 2013 Eric Biederman
+ * All rights reserved.
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
+#ifndef _IDMAPPING_H_
+#define _IDMAPPING_H_
+
+struct map_range {
+	unsigned long upper;
+	unsigned long lower;
+	unsigned long count;
+};
+
+extern struct map_range *get_map_ranges(int ranges, int argc, char **argv);
+extern void write_mapping(int proc_dir_fd, int ranges,
+	struct map_range *mappings, const char *map_file);
+
+#endif /* _ID_MAPPING_H_ */
+
diff --git a/man/Makefile.am b/man/Makefile.am
index fc617e9..b50ca41 100644
--- a/man/Makefile.am
+++ b/man/Makefile.am
@@ -30,7 +30,9 @@ man_MANS = \
 	man1/login.1 \
 	man5/login.defs.5 \
 	man8/logoutd.8 \
+	man1/newgidmap.1 \
 	man1/newgrp.1 \
+	man1/newuidmap.1 \
 	man8/newusers.8 \
 	man8/nologin.8 \
 	man1/passwd.1 \
@@ -83,7 +85,9 @@ man_XMANS = \
 	login.access.5.xml \
 	login.defs.5.xml \
 	logoutd.8.xml \
+	newgidmap.1.xml \
 	newgrp.1.xml \
+	newuidmap.1.xml \
 	newusers.8.xml \
 	nologin.8.xml \
 	passwd.1.xml \
diff --git a/man/newgidmap.1.xml b/man/newgidmap.1.xml
new file mode 100644
index 0000000..424a480
--- /dev/null
+++ b/man/newgidmap.1.xml
@@ -0,0 +1,157 @@
+<?xml version="1.0" encoding="UTF-8"?>
+<!--
+   Copyright (c) 2013 Eric W. Biederman
+   All rights reserved.
+  
+   Redistribution and use in source and binary forms, with or without
+   modification, are permitted provided that the following conditions
+   are met:
+   1. Redistributions of source code must retain the above copyright
+      notice, this list of conditions and the following disclaimer.
+   2. Redistributions in binary form must reproduce the above copyright
+      notice, this list of conditions and the following disclaimer in the
+      documentation and/or other materials provided with the distribution.
+   3. The name of the copyright holders or contributors may not be used to
+      endorse or promote products derived from this software without
+      specific prior written permission.
+  
+   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+   PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
+   HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+-->
+<!DOCTYPE refentry PUBLIC "-//OASIS//DTD DocBook V4.5//EN"
+  "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" [
+<!-- SHADOW-CONFIG-HERE -->
+]>
+
+<refentry id='newgidmap.1'>
+  <refmeta>
+    <refentrytitle>newgidmap</refentrytitle>
+    <manvolnum>1</manvolnum>
+    <refmiscinfo class="sectdesc">User Commands</refmiscinfo>
+    <refmiscinfo class="source">shadow-utils</refmiscinfo>
+    <refmiscinfo class="version">&SHADOW_UTILS_VERSION;</refmiscinfo>
+  </refmeta>
+  <refnamediv id='name'>
+    <refname>newgidmap</refname>
+    <refpurpose>set the gid mapping of a user namespace</refpurpose>
+  </refnamediv>
+
+  <refsynopsisdiv id='synopsis'>
+    <cmdsynopsis>
+      <command>newgidmap</command>
+      <arg choice='plain'>
+	<replaceable>pid</replaceable>
+      </arg>
+      <arg choice='plain'>
+	<replaceable>gid</replaceable>
+      </arg>
+      <arg choice='plain'>
+	<replaceable>lowergid</replaceable>
+      </arg>
+      <arg choice='plain'>
+	<replaceable>count</replaceable>
+      </arg>
+      <arg choice='opt'>
+	<arg choice='plain'>
+	  <replaceable>pid</replaceable>
+	</arg>
+	<arg choice='plain'>
+	  <replaceable>gid</replaceable>
+	</arg>
+	<arg choice='plain'>
+	  <replaceable>lowergid</replaceable>
+	</arg>
+	<arg choice='plain'>
+	  <replaceable>count</replaceable>
+	</arg>
+	<arg choice='opt'>
+	  <replaceable>...</replaceable>
+	</arg>
+      </arg>
+    </cmdsynopsis>
+  </refsynopsisdiv>
+
+  <refsect1 id='description'>
+    <title>DESCRIPTION</title>
+    <para>
+      The <command>newgidmap</command> sets <filename>/proc/[pid]/gid_map</filename> based on it's
+      command line arguments and the gids allowed in <filename>/etc/subgid</filename>.
+    </para>
+
+  </refsect1>
+
+  <refsect1 id='options'>
+    <title>OPTIONS</title>
+    <para>
+      There currently are no options to the <command>newgidmap</command> command.
+    </para>
+    <variablelist remap='IP'>
+    </variablelist>
+  </refsect1>
+
+  <refsect1 id='note'>
+    <title>NOTE</title>
+    <para>
+      The only restriction placed on the login shell is that the command
+      name must be listed in <filename>/etc/shells</filename>, unless the
+      invoker is the superuser, and then any value may be added. An
+      account with a restricted login shell may not change her login shell.
+      For this reason, placing <filename>/bin/rsh</filename> in
+      <filename>/etc/shells</filename> is discouraged since accidentally
+      changing to a restricted shell would prevent the user from ever
+      changing her login shell back to its original value.
+    </para>
+  </refsect1>
+
+
+  <refsect1 id='files'>
+    <title>FILES</title>
+    <variablelist>
+      <varlistentry>
+	<term><filename>/etc/subgid</filename></term>
+	<listitem>
+	  <para>List of users subordinate user IDs.</para>
+	</listitem>
+      </varlistentry>
+      <varlistentry>
+	<term><filename>/proc/[pid]/gid_map</filename></term>
+	<listitem>
+	  <para>Mapping of gids from one between user namespaces.</para>
+	</listitem>
+      </varlistentry>
+    </variablelist>
+  </refsect1>
+
+  <refsect1 id='see_also'>
+    <title>SEE ALSO</title>
+    <para>
+      <citerefentry>
+	<refentrytitle>login.defs</refentrytitle><manvolnum>5</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>useradd</refentrytitle><manvolnum>8</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>usermod</refentrytitle><manvolnum>8</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>newusers</refentrytitle><manvolnum>8</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>userdel</refentrytitle><manvolnum>8</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>subgid</refentrytitle><manvolnum>5</manvolnum>
+      </citerefentry>.
+    </para>
+  </refsect1>
+</refentry>
diff --git a/man/newuidmap.1.xml b/man/newuidmap.1.xml
new file mode 100644
index 0000000..c6687ea
--- /dev/null
+++ b/man/newuidmap.1.xml
@@ -0,0 +1,154 @@
+<?xml version="1.0" encoding="UTF-8"?>
+<!--
+   Copyright (c) 2013 Eric W. Biederman
+   All rights reserved.
+  
+   Redistribution and use in source and binary forms, with or without
+   modification, are permitted provided that the following conditions
+   are met:
+   1. Redistributions of source code must retain the above copyright
+      notice, this list of conditions and the following disclaimer.
+   2. Redistributions in binary form must reproduce the above copyright
+      notice, this list of conditions and the following disclaimer in the
+      documentation and/or other materials provided with the distribution.
+   3. The name of the copyright holders or contributors may not be used to
+      endorse or promote products derived from this software without
+      specific prior written permission.
+  
+   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+   PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
+   HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+-->
+<!DOCTYPE refentry PUBLIC "-//OASIS//DTD DocBook V4.5//EN"
+  "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" [
+<!-- SHADOW-CONFIG-HERE -->
+]>
+
+<refentry id='newuidmap.1'>
+  <refmeta>
+    <refentrytitle>newuidmap</refentrytitle>
+    <manvolnum>1</manvolnum>
+    <refmiscinfo class="sectdesc">User Commands</refmiscinfo>
+    <refmiscinfo class="source">shadow-utils</refmiscinfo>
+    <refmiscinfo class="version">&SHADOW_UTILS_VERSION;</refmiscinfo>
+  </refmeta>
+  <refnamediv id='name'>
+    <refname>newuidmap</refname>
+    <refpurpose>set the uid mapping of a user namespace</refpurpose>
+  </refnamediv>
+
+  <refsynopsisdiv id='synopsis'>
+    <cmdsynopsis>
+      <command>newuidmap</command>
+      <arg choice='plain'>
+	<replaceable>pid</replaceable>
+      </arg>
+      <arg choice='plain'>
+	<replaceable>uid</replaceable>
+      </arg>
+      <arg choice='plain'>
+	<replaceable>loweruid</replaceable>
+      </arg>
+      <arg choice='plain'>
+	<replaceable>count</replaceable>
+      </arg>
+      <arg choice='opt'>
+	<arg choice='plain'>
+	  <replaceable>uid</replaceable>
+	</arg>
+	<arg choice='plain'>
+	  <replaceable>loweruid</replaceable>
+	</arg>
+	<arg choice='plain'>
+	  <replaceable>count</replaceable>
+	</arg>
+	<arg choice='opt'>
+	  <replaceable>...</replaceable>
+	</arg>
+      </arg>
+    </cmdsynopsis>
+  </refsynopsisdiv>
+
+  <refsect1 id='description'>
+    <title>DESCRIPTION</title>
+    <para>
+      The <command>newuidmap</command> sets <filename>/proc/[pid]/uid_map</filename> based on it's
+      command line arguments and the uids allowed in <filename>/etc/subuid</filename>.
+    </para>
+
+  </refsect1>
+
+  <refsect1 id='options'>
+    <title>OPTIONS</title>
+    <para>
+      There currently are no options to the <command>newuidmap</command> command.
+    </para>
+    <variablelist remap='IP'>
+    </variablelist>
+  </refsect1>
+
+  <refsect1 id='note'>
+    <title>NOTE</title>
+    <para>
+      The only restriction placed on the login shell is that the command
+      name must be listed in <filename>/etc/shells</filename>, unless the
+      invoker is the superuser, and then any value may be added. An
+      account with a restricted login shell may not change her login shell.
+      For this reason, placing <filename>/bin/rsh</filename> in
+      <filename>/etc/shells</filename> is discouraged since accidentally
+      changing to a restricted shell would prevent the user from ever
+      changing her login shell back to its original value.
+    </para>
+  </refsect1>
+
+
+  <refsect1 id='files'>
+    <title>FILES</title>
+    <variablelist>
+      <varlistentry>
+	<term><filename>/etc/subuid</filename></term>
+	<listitem>
+	  <para>List of users subordinate user IDs.</para>
+	</listitem>
+      </varlistentry>
+      <varlistentry>
+	<term><filename>/proc/[pid]/uid_map</filename></term>
+	<listitem>
+	  <para>Mapping of uids from one between user namespaces.</para>
+	</listitem>
+      </varlistentry>
+    </variablelist>
+  </refsect1>
+
+  <refsect1 id='see_also'>
+    <title>SEE ALSO</title>
+    <para>
+      <citerefentry>
+	<refentrytitle>login.defs</refentrytitle><manvolnum>5</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>useradd</refentrytitle><manvolnum>8</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>usermod</refentrytitle><manvolnum>8</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>newusers</refentrytitle><manvolnum>8</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>userdel</refentrytitle><manvolnum>8</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>subuid</refentrytitle><manvolnum>5</manvolnum>
+      </citerefentry>.
+    </para>
+  </refsect1>
+</refentry>
diff --git a/src/Makefile.am b/src/Makefile.am
index 88cae99..1390cae 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -24,7 +24,8 @@ INCLUDES = \
 
 bin_PROGRAMS   = groups login su
 sbin_PROGRAMS  = nologin
-ubin_PROGRAMS  = faillog lastlog chage chfn chsh expiry gpasswd newgrp passwd
+ubin_PROGRAMS  = faillog lastlog chage chfn chsh expiry gpasswd newgrp passwd \
+	newgidmap newuidmap
 usbin_PROGRAMS = \
 	chgpasswd \
 	chpasswd \
@@ -49,7 +50,7 @@ usbin_PROGRAMS = \
 noinst_PROGRAMS = id sulogin
 
 suidbins       = su
-suidubins      = chage chfn chsh expiry gpasswd newgrp passwd
+suidubins      = chage chfn chsh expiry gpasswd newgrp passwd newuidmap newgidmap
 if ACCT_TOOLS_SETUID
 	suidubins += chage chgpasswd chpasswd groupadd groupdel groupmod newusers useradd userdel usermod
 endif
diff --git a/src/newgidmap.c b/src/newgidmap.c
new file mode 100644
index 0000000..1527a61
--- /dev/null
+++ b/src/newgidmap.c
@@ -0,0 +1,183 @@
+/*
+ * Copyright (c) 2013 Eric Biederman
+ * All rights reserved.
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
+#include <stdio.h>
+#include <string.h>
+#include <errno.h>
+#include <stdbool.h>
+#include <stdlib.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include "defines.h"
+#include "prototypes.h"
+#include "subordinateio.h"
+#include "idmapping.h"
+
+/*
+ * Global variables
+ */
+const char *Prog;
+
+static bool verify_range(struct passwd *pw, struct map_range *range)
+{
+	/* An empty range is invalid */
+	if (range->count == 0)
+		return false;
+
+	/* Test /etc/subgid */
+	if (have_sub_gids(pw->pw_name, range->lower, range->count))
+		return true;
+
+	/* Allow a process to map it's own gid */
+	if ((range->count == 1) && (pw->pw_gid == range->lower))
+		return true;
+
+	return false;
+}
+
+static void verify_ranges(struct passwd *pw, int ranges,
+	struct map_range *mappings)
+{
+	struct map_range *mapping;
+	int idx;
+
+	mapping = mappings;
+	for (idx = 0; idx < ranges; idx++, mapping++) {
+		if (!verify_range(pw, mapping)) {
+			fprintf(stderr, _( "%s: gid range [%lu-%lu) -> [%lu-%lu) not allowed\n"),
+				Prog,
+				mapping->upper,
+				mapping->upper + mapping->count,
+				mapping->lower,
+				mapping->lower + mapping->count);
+			exit(EXIT_FAILURE);
+		}
+	}
+}
+
+static void usage(void)
+{
+	fprintf(stderr, _("usage: %s <pid> <gid> <lowergid> <count> [ <gid> <lowergid> <count> ] ... \n"), Prog);
+	exit(EXIT_FAILURE);
+}
+
+/*
+ * newgidmap - Set the gid_map for the specified process
+ */
+int main(int argc, char **argv)
+{
+	char proc_dir_name[PATH_MAX];
+	char *target_str;
+	pid_t target, parent;
+	int proc_dir_fd;
+	int ranges;
+	struct map_range *mappings;
+	struct stat st;
+	struct passwd *pw;
+	int written;
+
+	Prog = Basename (argv[0]);
+
+	/*
+	 * The valid syntax are
+	 * newgidmap target_pid
+	 */
+	if (argc < 2)
+		usage();
+
+	/* Find the process that needs it's user namespace
+	 * gid mapping set.
+	 */
+	target_str = argv[1];
+	if (!get_pid(target_str, &target))
+		usage();
+
+	written = snprintf(proc_dir_name, sizeof(proc_dir_name), "/proc/%u/",
+		target);
+	if ((written <= 0) || (written >= sizeof(proc_dir_name))) {
+		fprintf(stderr, "%s: snprintf of proc path failed: %s\n",
+			Prog, strerror(errno));
+	}
+
+	proc_dir_fd = open(proc_dir_name, O_DIRECTORY);
+	if (proc_dir_fd < 0) {
+		fprintf(stderr, _("%s: Could not open proc directory for target %u\n"),
+			Prog, target);
+		return EXIT_FAILURE;
+	}
+
+	/* Who am i? */
+	pw = get_my_pwent ();
+	if (NULL == pw) {
+		fprintf (stderr,
+			_("%s: Cannot determine your user name.\n"),
+			Prog);
+		SYSLOG ((LOG_WARN, "Cannot determine the user name of the caller (UID %lu)",
+				(unsigned long) getuid ()));
+		return EXIT_FAILURE;
+	}
+	
+	/* Get the effective uid and effective gid of the target process */
+	if (fstat(proc_dir_fd, &st) < 0) {
+		fprintf(stderr, _("%s: Could not stat directory for target %u\n"),
+			Prog, target);
+		return EXIT_FAILURE;
+	}
+
+	/* Verify real user and real group matches the password entry
+	 * and the effective user and group of the program whose
+	 * mappings we have been asked to set.
+	 */
+	if ((getuid() != pw->pw_uid) ||
+	    (getgid() != pw->pw_gid) ||
+	    (pw->pw_uid != st.st_uid) ||
+	    (pw->pw_gid != st.st_gid)) {
+		fprintf(stderr, _( "%s: Target %u is owned by a different user\n" ),
+			Prog, target);
+		return EXIT_FAILURE;
+	}
+
+	if (!sub_gid_open(O_RDONLY)) {
+		return EXIT_FAILURE;
+	}
+
+	ranges = ((argc - 2) + 2) / 3;
+	mappings = get_map_ranges(ranges, argc - 2, argv + 2);
+	if (!mappings)
+		usage();
+
+	verify_ranges(pw, ranges, mappings);
+
+	write_mapping(proc_dir_fd, ranges, mappings, "gid_map");
+	sub_gid_close();
+
+	return EXIT_SUCCESS;
+}
diff --git a/src/newuidmap.c b/src/newuidmap.c
new file mode 100644
index 0000000..69c5094
--- /dev/null
+++ b/src/newuidmap.c
@@ -0,0 +1,183 @@
+/*
+ * Copyright (c) 2013 Eric Biederman
+ * All rights reserved.
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
+#include <stdio.h>
+#include <string.h>
+#include <errno.h>
+#include <stdbool.h>
+#include <stdlib.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include "defines.h"
+#include "prototypes.h"
+#include "subordinateio.h"
+#include "idmapping.h"
+
+/*
+ * Global variables
+ */
+const char *Prog;
+
+static bool verify_range(struct passwd *pw, struct map_range *range)
+{
+	/* An empty range is invalid */
+	if (range->count == 0)
+		return false;
+
+	/* Test /etc/subuid */
+	if (have_sub_uids(pw->pw_name, range->lower, range->count))
+		return true;
+
+	/* Allow a process to map it's own uid */
+	if ((range->count == 1) && (pw->pw_uid == range->lower))
+		return true;
+
+	return false;
+}
+
+static void verify_ranges(struct passwd *pw, int ranges,
+	struct map_range *mappings)
+{
+	struct map_range *mapping;
+	int idx;
+
+	mapping = mappings;
+	for (idx = 0; idx < ranges; idx++, mapping++) {
+		if (!verify_range(pw, mapping)) {
+			fprintf(stderr, _( "%s: uid range [%lu-%lu) -> [%lu-%lu) not allowed\n"),
+				Prog,
+				mapping->upper,
+				mapping->upper + mapping->count,
+				mapping->lower,
+				mapping->lower + mapping->count);
+			exit(EXIT_FAILURE);
+		}
+	}
+}
+
+void usage(void)
+{
+	fprintf(stderr, _("usage: %s <pid> <uid> <loweruid> <count> [ <uid> <loweruid> <count> ] ... \n"), Prog);
+	exit(EXIT_FAILURE);
+}
+
+/*
+ * newuidmap - Set the uid_map for the specified process
+ */
+int main(int argc, char **argv)
+{
+	char proc_dir_name[PATH_MAX];
+	char *target_str;
+	pid_t target, parent;
+	int proc_dir_fd;
+	int ranges;
+	struct map_range *mappings;
+	struct stat st;
+	struct passwd *pw;
+	int written;
+
+	Prog = Basename (argv[0]);
+
+	/*
+	 * The valid syntax are
+	 * newuidmap target_pid
+	 */
+	if (argc < 2)
+		usage();
+
+	/* Find the process that needs it's user namespace
+	 * uid mapping set.
+	 */
+	target_str = argv[1];
+	if (!get_pid(target_str, &target))
+		usage();
+
+	written = snprintf(proc_dir_name, sizeof(proc_dir_name), "/proc/%u/",
+		target);
+	if ((written <= 0) || (written >= sizeof(proc_dir_name))) {
+		fprintf(stderr, "%s: snprintf of proc path failed: %s\n",
+			Prog, strerror(errno));
+	}
+
+	proc_dir_fd = open(proc_dir_name, O_DIRECTORY);
+	if (proc_dir_fd < 0) {
+		fprintf(stderr, _("%s: Could not open proc directory for target %u\n"),
+			Prog, target);
+		return EXIT_FAILURE;
+	}
+
+	/* Who am i? */
+	pw = get_my_pwent ();
+	if (NULL == pw) {
+		fprintf (stderr,
+			_("%s: Cannot determine your user name.\n"),
+			Prog);
+		SYSLOG ((LOG_WARN, "Cannot determine the user name of the caller (UID %lu)",
+				(unsigned long) getuid ()));
+		return EXIT_FAILURE;
+	}
+	
+	/* Get the effective uid and effective gid of the target process */
+	if (fstat(proc_dir_fd, &st) < 0) {
+		fprintf(stderr, _("%s: Could not stat directory for target %u\n"),
+			Prog, target);
+		return EXIT_FAILURE;
+	}
+
+	/* Verify real user and real group matches the password entry
+	 * and the effective user and group of the program whose
+	 * mappings we have been asked to set.
+	 */
+	if ((getuid() != pw->pw_uid) ||
+	    (getgid() != pw->pw_gid) ||
+	    (pw->pw_uid != st.st_uid) ||
+	    (pw->pw_gid != st.st_gid)) {
+		fprintf(stderr, _( "%s: Target %u is owned by a different user\n" ),
+			Prog, target);
+		return EXIT_FAILURE;
+	}
+
+	if (!sub_uid_open(O_RDONLY)) {
+		return EXIT_FAILURE;
+	}
+
+	ranges = ((argc - 2) + 2) / 3;
+	mappings = get_map_ranges(ranges, argc - 2, argv + 2);
+	if (!mappings)
+		usage();
+
+	verify_ranges(pw, ranges, mappings);
+
+	write_mapping(proc_dir_fd, ranges, mappings, "uid_map");
+	sub_uid_close();
+
+	return EXIT_SUCCESS;
+}
-- 
1.7.5.4
