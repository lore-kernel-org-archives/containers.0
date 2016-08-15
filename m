From: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/2] Documentation: describe /proc/<pid>/userns_counts
Date: Mon, 15 Aug 2016 13:10:22 -0700
Message-ID: <1471291822-539-3-git-send-email-avagin@openvz.org>
References: <1471291822-539-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1471291822-539-1-git-send-email-avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Kirill Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Kirill Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

This file provides current usage of user namespace counters.

Signed-off-by: Kirill Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 Documentation/filesystems/proc.txt | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 68080ad..7300d9c 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -44,6 +44,7 @@ Table of Contents
   3.8   /proc/<pid>/fdinfo/<fd> - Information about opened file
   3.9   /proc/<pid>/map_files - Information about memory mapped files
   3.10  /proc/<pid>/timerslack_ns - Task timerslack value
+  3.11  /proc/<pid>/userns_counts - User namespace counters
 
   4	Configuring procfs
   4.1	Mount options
@@ -1889,6 +1890,35 @@ Valid values are from 0 - ULLONG_MAX
 An application setting the value must have PTRACE_MODE_ATTACH_FSCREDS level
 permissions on the task specified to change its timerslack_ns value.
 
+3.11 /proc/<pid>/userns_counts - User namespace counters
+---------------------------------------------------------
+
+This file provides current usage of user namespace counters.
+
+User namespace counters is a feature that allows to limit the number of various
+kernel objects a user can create. These limits are set via /proc/sys/user/
+sysctls on a per user namespace basis and are applicable to all users in that
+namespace. Therefore, the limits are the same for every user in a user
+namespace.
+
+Each user has their own set of user namespace counters. Once a user creates a
+new user namespace, every new object created inside that namespace is also
+charged to the user. That means that a user is limited by their user namespace
+limits, as well as the limits in their parent user namespaces.
+
+  > cat /proc/813/userns_counts
+  user_namespaces          101000	         1
+  pid_namespaces           101000	         1
+  ipc_namespaces           101000	         4
+  net_namespaces           101000	         2
+  mnt_namespaces           101000	         5
+  mnt_namespaces           100000	         1
+
+The meanings of the columns are as follows, from left to right:
+
+  Name		Object name
+  UID		User ID
+  Usage		Current usage
 
 ------------------------------------------------------------------------------
 Configuring procfs
-- 
2.5.5
