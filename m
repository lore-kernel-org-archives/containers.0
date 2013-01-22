From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 01/11] Documentation for /etc/subuid and /etc/subgid
Date: Tue, 22 Jan 2013 01:12:23 -0800
Message-ID: <877gn5shs8.fsf@xmission.com>
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
 man/Makefile.am  |    4 ++
 man/subgid.5.xml |  120 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/subuid.5.xml |  120 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 244 insertions(+), 0 deletions(-)
 create mode 100644 man/subgid.5.xml
 create mode 100644 man/subuid.5.xml

diff --git a/man/Makefile.am b/man/Makefile.am
index b39043e..be7f5e2 100644
--- a/man/Makefile.am
+++ b/man/Makefile.am
@@ -43,6 +43,8 @@ man_MANS = \
 	man5/shadow.5 \
 	man1/su.1 \
 	man5/suauth.5 \
+	man5/subgid.5 \
+	man5/subuid.5 \
 	man8/useradd.8 \
 	man8/userdel.8 \
 	man8/usermod.8 \
@@ -94,6 +96,8 @@ man_XMANS = \
 	sg.1.xml \
 	su.1.xml \
 	suauth.5.xml \
+	subgid.5.xml \
+	subuid.5.xml \
 	useradd.8.xml \
 	userdel.8.xml \
 	usermod.8.xml \
diff --git a/man/subgid.5.xml b/man/subgid.5.xml
new file mode 100644
index 0000000..3855319
--- /dev/null
+++ b/man/subgid.5.xml
@@ -0,0 +1,120 @@
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
+<refentry id='subgid.5'>
+  <refmeta>
+    <refentrytitle>subgid</refentrytitle>
+    <manvolnum>5</manvolnum>
+    <refmiscinfo class="sectdesc">File Formats and Conversions</refmiscinfo>
+    <refmiscinfo class="source">shadow-utils</refmiscinfo>
+    <refmiscinfo class="version">&SHADOW_UTILS_VERSION;</refmiscinfo>
+  </refmeta>
+  <refnamediv id='name'>
+    <refname>subgid</refname>
+    <refpurpose>the subordinate gid file</refpurpose>
+  </refnamediv>
+
+  <refsect1 id='description'>
+    <title>DESCRIPTION</title>
+    <para>
+      Each line in <filename>/etc/subgid</filename> contains
+      a user id and a range of suboridinate user ids that user
+      is allowed to use.
+
+      This is specified with three fields delimited by colons
+      (<quote>:</quote>).
+      These fields are:
+    </para>
+    <itemizedlist mark='bullet'>
+      <listitem>
+	<para>login name</para>
+      </listitem>
+      <listitem>
+	<para>numerical subordinate user ID</para>
+      </listitem>
+      <listitem>
+	<para>numerical subordinate user ID count</para>
+      </listitem>
+    </itemizedlist>
+
+    <para>
+      This file specifies the group IDs to be that each user may use
+      with the <command>newgidmap</command> command that ordinary users can use to
+      configure gid mapping in a user namespace.
+    </para>
+
+    <para>
+      Multiple ranges may be specified per user ID.
+    </para>
+
+  </refsect1>
+
+  <refsect1 id='files'>
+    <title>FILES</title>
+    <variablelist>
+      <varlistentry>
+	<term><filename>/etc/subgid</filename></term>
+	<listitem>
+	  <para>Per user subordinate group IDs.</para>
+	</listitem>
+      </varlistentry>
+      <varlistentry>
+	<term><filename>/etc/subgid-</filename></term>
+	<listitem>
+	  <para>Backup file for /etc/subgid.</para>
+	</listitem>
+      </varlistentry>
+    </variablelist>
+  </refsect1>
+
+  <refsect1 id='see_also'>
+    <title>SEE ALSO</title>
+    <para>
+      <citerefentry>
+	<refentrytitle>subuid</refentrytitle><manvolnum>5</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>logindefs</refentrytitle><manvolnum>5</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>newuidmap</refentrytitle><manvolnum>1</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>newgidmap</refentrytitle><manvolnum>1</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>usermod</refentrytitle><manvolnum>8</manvolnum>
+      </citerefentry>,
+    </para>
+  </refsect1>
+</refentry>
diff --git a/man/subuid.5.xml b/man/subuid.5.xml
new file mode 100644
index 0000000..60f139f
--- /dev/null
+++ b/man/subuid.5.xml
@@ -0,0 +1,120 @@
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
+<refentry id='subuid.5'>
+  <refmeta>
+    <refentrytitle>subuid</refentrytitle>
+    <manvolnum>5</manvolnum>
+    <refmiscinfo class="sectdesc">File Formats and Conversions</refmiscinfo>
+    <refmiscinfo class="source">shadow-utils</refmiscinfo>
+    <refmiscinfo class="version">&SHADOW_UTILS_VERSION;</refmiscinfo>
+  </refmeta>
+  <refnamediv id='name'>
+    <refname>subuid</refname>
+    <refpurpose>the subordinate uid file</refpurpose>
+  </refnamediv>
+
+  <refsect1 id='description'>
+    <title>DESCRIPTION</title>
+    <para>
+      Each line in <filename>/etc/subuid</filename> contains
+      a user id and a range of suboridinate user ids that user
+      is allowed to use.
+
+      This is specified with three fields delimited by colons
+      (<quote>:</quote>).
+      These fields are:
+    </para>
+    <itemizedlist mark='bullet'>
+      <listitem>
+	<para>login name</para>
+      </listitem>
+      <listitem>
+	<para>numerical subordinate user ID</para>
+      </listitem>
+      <listitem>
+	<para>numerical subordinate user ID count</para>
+      </listitem>
+    </itemizedlist>
+
+    <para>
+      This file specifies the user IDs to be that each user may use
+      with the <command>newuidmap</command> command that ordinary users can use to
+      configure uid mapping in a user namespace.
+    </para>
+
+    <para>
+      Multiple ranges may be specified per user ID.
+    </para>
+
+  </refsect1>
+
+  <refsect1 id='files'>
+    <title>FILES</title>
+    <variablelist>
+      <varlistentry>
+	<term><filename>/etc/subuid</filename></term>
+	<listitem>
+	  <para>Per user subordinate user IDs.</para>
+	</listitem>
+      </varlistentry>
+      <varlistentry>
+	<term><filename>/etc/subuid-</filename></term>
+	<listitem>
+	  <para>Backup file for /etc/subuid.</para>
+	</listitem>
+      </varlistentry>
+    </variablelist>
+  </refsect1>
+
+  <refsect1 id='see_also'>
+    <title>SEE ALSO</title>
+    <para>
+      <citerefentry>
+	<refentrytitle>subgid</refentrytitle><manvolnum>5</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>logindefs</refentrytitle><manvolnum>5</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>newuidmap</refentrytitle><manvolnum>1</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>newgidmap</refentrytitle><manvolnum>1</manvolnum>
+      </citerefentry>,
+      <citerefentry>
+	<refentrytitle>usermod</refentrytitle><manvolnum>8</manvolnum>
+      </citerefentry>,
+    </para>
+  </refsect1>
+</refentry>
-- 
1.7.5.4
