From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 2/6] dcache: Handle escaped paths in prepend_path
Date: Mon, 03 Aug 2015 16:26:34 -0500
Message-ID: <87pp349i7p.fsf_-_@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871tfkawu9.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Mon, 03 Aug 2015 16:25:18 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


A rename can result in a dentry that by walking up d_parent
will never reach it's mnt_root.  For lack of a better term
I call this an escaped path.

prepend_path is called by four different functions __d_path,
d_absolute_path, d_path, and getcwd.

__d_path only wants to see paths are connected to the root it passes
in.  So __d_path needs prepend_path to return an error.

d_absolute_path similarly wants to see paths that are connected to
some root.  Escaped paths are not connected to any mnt_root so
d_absolute_path needs prepend_path to return an error greater
than 1.  So escaped paths will be treated like paths on lazily
unmounted mounts.

getcwd needs to prepend "(unreachable)" so getcwd also needs
prepend_path to return an error.

d_path is the interesting hold out.  d_path just wants to print
something, and does not care about the weird cases.  Which raises
the question what should be printed?

Given that <escaped_path>/<anything> should result in -ENOENT I
believe it is desirable for escaped paths to be printed as empty
paths.  As there are not really any meaninful path components when
considered from the perspective of a mount tree.

So tweak prepend_path to return an empty path with an new error
code of 3 when it encounters an escaped path.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 5c8ea15e73a5..d7fe995dd32d 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2926,6 +2926,13 @@ restart:
 
 		if (dentry == vfsmnt->mnt_root || IS_ROOT(dentry)) {
 			struct mount *parent = ACCESS_ONCE(mnt->mnt_parent);
+			/* Escaped? */
+			if (dentry != vfsmnt->mnt_root) {
+				bptr = *buffer;
+				blen = *buflen;
+				error = 3;
+				break;
+			}
 			/* Global root? */
 			if (mnt != parent) {
 				dentry = ACCESS_ONCE(mnt->mnt_mountpoint);
-- 
2.2.1
