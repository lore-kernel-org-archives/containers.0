From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH][DOCUMENTATION] The namespaces compatibility list doc
Date: Fri, 16 Nov 2007 12:34:44 +0300
Message-ID: <473D6434.5020201@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

From time to time people begin discussions about how the
namespaces are working/going-to-work together.

Ted T'so proposed to create some document that describes what
problems user may have when he/she creates some new namespace,
but keeps others shared. I liked this idea, so here's the 
initial version of such a document with the problems I currently 
have in mind and can describe somewhat audibly - the "namespaces 
compatibility list".

The Documentation/namespaces/ directory is about to contain more
docs about the namespaces stuff.

Thanks to Cedirc for notes and spell checks on the doc.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---

commit 83061c56e1c4dcd54d48a62b108d219a7f5279a0
Author: Pavel <pavel-00xAsUaB/BPciZdyczg/7Q@public.gmane.org>
Date:   Fri Nov 16 12:25:53 2007 +0300

    Namespaces compatibility list

diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
index 910e511..3ead06b 100644
--- a/Documentation/00-INDEX
+++ b/Documentation/00-INDEX
@@ -262,6 +262,8 @@ mtrr.txt
 	- how to use PPro Memory Type Range Registers to increase performance.
 mutex-design.txt
 	- info on the generic mutex subsystem.
+namespaces/
+	- directory with various information about namespaces
 nbd.txt
 	- info on a TCP implementation of a network block device.
 netlabel/
diff --git a/Documentation/namespaces/compatibility-list.txt b/Documentation/namespaces/compatibility-list.txt
new file mode 100644
index 0000000..9c9e5c1
--- /dev/null
+++ b/Documentation/namespaces/compatibility-list.txt
@@ -0,0 +1,33 @@
+	Namespaces compatibility list
+
+This document contains the information about the problems user
+may have when creating tasks living in different namespaces.
+
+Here's the summary. This matrix shows the known problems, that
+occur when tasks share some namespace (the columns) while living
+in different other namespaces (the rows):
+
+	UTS	IPC	VFS	PID	User	Net
+UTS	 X
+IPC		 X	 1
+VFS			 X
+PID		 1	 1	 X
+User			 2		 X
+Net						 X
+
+1. Both the IPC and the PID namespaces provide IDs to address
+   object inside the kernel. E.g. semaphore with ipcid or
+   process group with pid.
+
+   In both cases, tasks shouldn't try exposing this id to some
+   other task living in a different namespace via a shared filesystem
+   or IPC shmem/message. The fact is that this ID is only valid
+   within the namespace it was obtained in and may refer to some
+   other object in another namespace.
+
+2. Intentionnaly, two equal user ids in different user namespaces
+   should not be equal from the VFS point of view. In other
+   words, user 10 in one user namespace shouldn't have the same
+   access permissions to files, beloging to user 10 in another
+   namespace. But currently this is not so.
+
