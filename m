From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 02/11] login.defs.5: Document the new variables in login.defs
Date: Tue, 22 Jan 2013 01:12:58 -0800
Message-ID: <871uddshr9.fsf@xmission.com>
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
 man/Makefile.am                    |    2 +
 man/login.defs.5.xml               |    8 ++++++
 man/login.defs.d/SUB_GID_COUNT.xml |   46 ++++++++++++++++++++++++++++++++++++
 man/login.defs.d/SUB_UID_COUNT.xml |   46 ++++++++++++++++++++++++++++++++++++
 4 files changed, 102 insertions(+), 0 deletions(-)
 create mode 100644 man/login.defs.d/SUB_GID_COUNT.xml
 create mode 100644 man/login.defs.d/SUB_UID_COUNT.xml

diff --git a/man/Makefile.am b/man/Makefile.am
index be7f5e2..fc617e9 100644
--- a/man/Makefile.am
+++ b/man/Makefile.am
@@ -163,6 +163,8 @@ login_defs_v = \
 	USERDEL_CMD.xml \
 	USERGROUPS_ENAB.xml \
 	USE_TCB.xml \
+	SUB_GID_COUNT.xml \
+	SUB_UID_COUNT.xml \
 	SYS_GID_MAX.xml \
 	SYS_UID_MAX.xml
 
diff --git a/man/login.defs.5.xml b/man/login.defs.5.xml
index 459b866..d5279ca 100644
--- a/man/login.defs.5.xml
+++ b/man/login.defs.5.xml
@@ -78,6 +78,8 @@
 <!ENTITY SULOG_FILE            SYSTEM "login.defs.d/SULOG_FILE.xml">
 <!ENTITY SU_NAME               SYSTEM "login.defs.d/SU_NAME.xml">
 <!ENTITY SU_WHEEL_ONLY         SYSTEM "login.defs.d/SU_WHEEL_ONLY.xml">
+<!ENTITY SUB_GID_COUNT         SYSTEM "login.defs.d/SUB_GID_COUNT.xml">
+<!ENTITY SUB_UID_COUNT         SYSTEM "login.defs.d/SUB_UID_COUNT.xml">
 <!ENTITY SYS_GID_MAX           SYSTEM "login.defs.d/SYS_GID_MAX.xml">
 <!ENTITY SYSLOG_SG_ENAB        SYSTEM "login.defs.d/SYSLOG_SG_ENAB.xml">
 <!ENTITY SYSLOG_SU_ENAB        SYSTEM "login.defs.d/SYSLOG_SU_ENAB.xml">
@@ -216,6 +218,8 @@
       &SULOG_FILE;
       &SU_NAME;
       &SU_WHEEL_ONLY;
+      &SUB_GID_COUNT; <!-- documents also SUB_GID_MIN SUB_GID_MAX -->
+      &SUB_UID_COUNT; <!-- documents also SUB_UID_MIN SUB_UID_MAX -->
       &SYS_GID_MAX; <!-- documents also SYS_GID_MIN -->
       &SYS_UID_MAX; <!-- documents also SYS_UID_MIN -->
       &SYSLOG_SG_ENAB;
@@ -393,6 +397,8 @@
 	    PASS_MAX_DAYS PASS_MIN_DAYS PASS_WARN_AGE
 	    <phrase condition="sha_crypt">SHA_CRYPT_MAX_ROUNDS
 	    SHA_CRYPT_MIN_ROUNDS</phrase>
+	    SUB_GID_COUNT SUB_GID_MAX SUB_GID_MIN
+	    SUB_UID_COUNT SUB_UID_MAX SUB_UID_MIN
 	    SYS_GID_MAX SYS_GID_MIN SYS_UID_MAX SYS_UID_MIN UID_MAX UID_MIN
 	    UMASK
 	  </para>
@@ -470,6 +476,8 @@
 	    GID_MAX GID_MIN
 	    MAIL_DIR MAX_MEMBERS_PER_GROUP
 	    PASS_MAX_DAYS PASS_MIN_DAYS PASS_WARN_AGE
+	    SUB_GID_COUNT SUB_GID_MAX SUB_GID_MIN
+	    SUB_UID_COUNT SUB_UID_MAX SUB_UID_MIN
 	    SYS_GID_MAX SYS_GID_MIN SYS_UID_MAX SYS_UID_MIN UID_MAX UID_MIN
 	    UMASK
 	    <phrase condition="tcb">TCB_AUTH_GROUP TCB_SYMLINK USE_TCB</phrase>
diff --git a/man/login.defs.d/SUB_GID_COUNT.xml b/man/login.defs.d/SUB_GID_COUNT.xml
new file mode 100644
index 0000000..db1a25b
--- /dev/null
+++ b/man/login.defs.d/SUB_GID_COUNT.xml
@@ -0,0 +1,46 @@
+<!--
+   Copyright (c) 2013, Eric W. Biederman
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
+<varlistentry>
+  <term><option>SUB_GID_MIN</option> (number)</term>
+  <term><option>SUB_GID_MAX</option> (number)</term>
+  <term><option>SUB_GID_COUNT</option> (number)</term>
+  <listitem>
+    <para>
+      The commands <command>useradd</command> and <command>newusers</command>
+      allocate <option>SUB_GID_COUNT</option> unused group IDs from the range
+      <option>SUB_GID_MIN</option> to <option>SUB_GID_MAX</option> for each
+      new user.
+    </para>
+    <para>
+      The default values for <option>SUB_GID_MAN</option>,
+      <option>SUB_GID_MIN</option>, <option>SUB_GID_COUNT</option>
+      are respectively 100000, 600100000 and 10000.
+    </para>
+  </listitem>
+</varlistentry>
diff --git a/man/login.defs.d/SUB_UID_COUNT.xml b/man/login.defs.d/SUB_UID_COUNT.xml
new file mode 100644
index 0000000..bea3b6a
--- /dev/null
+++ b/man/login.defs.d/SUB_UID_COUNT.xml
@@ -0,0 +1,46 @@
+<!--
+   Copyright (c) 2013, Eric W. Biederman
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
+<varlistentry>
+  <term><option>SUB_UID_MIN</option> (number)</term>
+  <term><option>SUB_UID_MAX</option> (number)</term>
+  <term><option>SUB_UID_COUNT</option> (number)</term>
+  <listitem>
+    <para>
+      The commands <command>useradd</command> and <command>newusers</command>
+      allocate <option>SUB_UID_COUNT</option> unused user IDs from the range
+      <option>SUB_UID_MIN</option> to <option>SUB_UID_MAX</option> for each
+      new user.
+    </para>
+    <para>
+      The default values for <option>SUB_GID_MAN</option>,
+      <option>SUB_GID_MIN</option>, <option>SUB_GID_COUNT</option>
+      are respectively 100000, 600100000 and 10000.
+    </para>
+  </listitem>
+</varlistentry>
-- 
1.7.5.4
