From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH (resend)][DOCUMENTATION] The namespaces compatibility list
 doc
Date: Wed, 21 Nov 2007 14:14:10 +0300
Message-ID: <47441302.6070300@openvz.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
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

Thanks to Cedirc for notes and spell checks on the doc, to Daniel
for additional info about IPC and User namespaces interaction
and to Randy, who alluded me to using a spell checker before
sending the documentation :)

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---

diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
index 0a2b12e..b4a0908 100644
--- a/Documentation/00-INDEX
+++ b/Documentation/00-INDEX
@@ -265,6 +265,8 @@ mtrr.txt
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
index 0000000..d0e8cc3
--- /dev/null
+++ b/Documentation/namespaces/compatibility-list.txt
@@ -0,0 +1,39 @@
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
+User		 2	 2		 X
+Net						 X
+
+1. Both the IPC and the PID namespaces provide IDs to address
+   object inside the kernel. E.g. semaphore with IPCID or
+   process group with pid.
+
+   In both cases, tasks shouldn't try exposing this ID to some
+   other task living in a different namespace via a shared filesystem
+   or IPC shmem/message. The fact is that this ID is only valid
+   within the namespace it was obtained in and may refer to some
+   other object in another namespace.
+
+2. Intentionally, two equal user IDs in different user namespaces
+   should not be equal from the VFS point of view. In other
+   words, user 10 in one user namespace shouldn't have the same
+   access permissions to files, belonging to user 10 in another
+   namespace.
+
+   The same is true for the IPC namespaces being shared - two users
+   from different user namespaces should not access the same IPC objects
+   even having equal UIDs.
+
+   But currently this is not so.
+
