From: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 00/11] pkg-shadow support subordinate ids with user
	namespaces
Date: Thu, 7 Mar 2013 10:23:52 -0500
Message-ID: <20130307102352.4a5943cd__38822.0316767276$1362669883$gmane$org@oracle.com>
References: <87d2wxshu0.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2wxshu0.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?UTF-8?B?RnJhbsOnb2lz?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Eric, here are some minor fixups to your patch set. I think the
NOTE section is left over from chsh, and doesn't apply here.

diff -ur shadow-4.1.5.1.orig/man/newgidmap.1.xml shadow-4.1.5.1/man/newgidmap.1.xml
--- shadow-4.1.5.1.orig/man/newgidmap.1.xml	2013-03-06 16:20:53.873175769 -0500
+++ shadow-4.1.5.1/man/newgidmap.1.xml	2013-03-06 16:52:46.327142067 -0500
@@ -98,21 +98,6 @@
     </variablelist>
   </refsect1>
 
-  <refsect1 id='note'>
-    <title>NOTE</title>
-    <para>
-      The only restriction placed on the login shell is that the command
-      name must be listed in <filename>/etc/shells</filename>, unless the
-      invoker is the superuser, and then any value may be added. An
-      account with a restricted login shell may not change her login shell.
-      For this reason, placing <filename>/bin/rsh</filename> in
-      <filename>/etc/shells</filename> is discouraged since accidentally
-      changing to a restricted shell would prevent the user from ever
-      changing her login shell back to its original value.
-    </para>
-  </refsect1>
-
-
   <refsect1 id='files'>
     <title>FILES</title>
     <variablelist>
diff -ur shadow-4.1.5.1.orig/man/newuidmap.1.xml shadow-4.1.5.1/man/newuidmap.1.xml
--- shadow-4.1.5.1.orig/man/newuidmap.1.xml	2013-03-06 16:20:53.873175769 -0500
+++ shadow-4.1.5.1/man/newuidmap.1.xml	2013-03-06 16:52:46.327142067 -0500
@@ -95,21 +95,6 @@
     </variablelist>
   </refsect1>
 
-  <refsect1 id='note'>
-    <title>NOTE</title>
-    <para>
-      The only restriction placed on the login shell is that the command
-      name must be listed in <filename>/etc/shells</filename>, unless the
-      invoker is the superuser, and then any value may be added. An
-      account with a restricted login shell may not change her login shell.
-      For this reason, placing <filename>/bin/rsh</filename> in
-      <filename>/etc/shells</filename> is discouraged since accidentally
-      changing to a restricted shell would prevent the user from ever
-      changing her login shell back to its original value.
-    </para>
-  </refsect1>
-
-
   <refsect1 id='files'>
     <title>FILES</title>
     <variablelist>
diff -ur shadow-4.1.5.1.orig/man/subgid.5.xml shadow-4.1.5.1/man/subgid.5.xml
--- shadow-4.1.5.1.orig/man/subgid.5.xml	2013-03-06 16:20:53.861175769 -0500
+++ shadow-4.1.5.1/man/subgid.5.xml	2013-03-06 16:52:46.327142067 -0500
@@ -48,7 +48,7 @@
     <title>DESCRIPTION</title>
     <para>
       Each line in <filename>/etc/subgid</filename> contains
-      a user id and a range of suboridinate user ids that user
+      a user name and a range of suboridinate group ids that user
       is allowed to use.
 
       This is specified with three fields delimited by colons
@@ -60,21 +60,21 @@
 	<para>login name</para>
       </listitem>
       <listitem>
-	<para>numerical subordinate user ID</para>
+	<para>numerical subordinate group ID</para>
       </listitem>
       <listitem>
-	<para>numerical subordinate user ID count</para>
+	<para>numerical subordinate group ID count</para>
       </listitem>
     </itemizedlist>
 
     <para>
-      This file specifies the group IDs to be that each user may use
-      with the <command>newgidmap</command> command that ordinary users can use to
+      This file specifies the group IDs that ordinary users may use
+      with the <command>newgidmap</command> command to
       configure gid mapping in a user namespace.
     </para>
 
     <para>
-      Multiple ranges may be specified per user ID.
+      Multiple ranges may be specified per user.
     </para>
 
   </refsect1>
diff -ur shadow-4.1.5.1.orig/man/subuid.5.xml shadow-4.1.5.1/man/subuid.5.xml
--- shadow-4.1.5.1.orig/man/subuid.5.xml	2013-03-06 16:20:53.862175769 -0500
+++ shadow-4.1.5.1/man/subuid.5.xml	2013-03-06 16:52:46.328142067 -0500
@@ -48,7 +48,7 @@
     <title>DESCRIPTION</title>
     <para>
       Each line in <filename>/etc/subuid</filename> contains
-      a user id and a range of suboridinate user ids that user
+      a user name and a range of suboridinate user ids that user
       is allowed to use.
 
       This is specified with three fields delimited by colons
@@ -68,13 +68,13 @@
     </itemizedlist>
 
     <para>
-      This file specifies the user IDs to be that each user may use
-      with the <command>newuidmap</command> command that ordinary users can use to
+      This file specifies the user IDs that ordinary users may use
+      with the <command>newuidmap</command> command to
       configure uid mapping in a user namespace.
     </para>
 
     <para>
-      Multiple ranges may be specified per user ID.
+      Multiple ranges may be specified per user.
     </para>
 
   </refsect1>
diff -ur shadow-4.1.5.1.orig/src/usermod.c shadow-4.1.5.1/src/usermod.c
--- shadow-4.1.5.1.orig/src/usermod.c	2013-03-06 16:20:53.872175769 -0500
+++ shadow-4.1.5.1/src/usermod.c	2013-03-06 16:53:17.560141517 -0500
@@ -410,9 +410,9 @@
 	(void) fputs (_("  -u, --uid UID                 new UID for the user account\n"), usageout);
 	(void) fputs (_("  -U, --unlock                  unlock the user account\n"), usageout);
 	(void) fputs (_("  -v, --add-subuids FIRST-LAST  add range of subordinate uids\n"), usageout);
-	(void) fputs (_("  -V, --del-subuids FIRST-LAST  remvoe range of subordinate uids\n"), usageout);
+	(void) fputs (_("  -V, --del-subuids FIRST-LAST  remove range of subordinate uids\n"), usageout);
 	(void) fputs (_("  -w, --add-subgids FIRST-LAST  add range of subordinate gids\n"), usageout);
-	(void) fputs (_("  -W, --del-subgids FIRST-LAST  remvoe range of subordinate gids\n"), usageout);
+	(void) fputs (_("  -W, --del-subgids FIRST-LAST  remove range of subordinate gids\n"), usageout);
 #ifdef WITH_SELINUX
 	(void) fputs (_("  -Z, --selinux-user SEUSER     new SELinux user mapping for the user account\n"), usageout);
 #endif				/* WITH_SELINUX */
@@ -993,9 +993,9 @@
 		};
 		while ((c = getopt_long (argc, argv,
 #ifdef WITH_SELINUX
-			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:UZ:",
+			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:Uv:V:w:W:Z:",
 #else				/* !WITH_SELINUX */
-			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:U",
+			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:Uv:V:w:W:",
 #endif				/* !WITH_SELINUX */
 			                 long_options, NULL)) != -1) {
 			switch (c) {
