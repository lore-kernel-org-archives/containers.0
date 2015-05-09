From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] userns: proc and sysfs mount fix
Date: Sat, 09 May 2015 15:54:13 -0500
Message-ID: <877fshtqtm.fsf_-___2679.36640088937$1431205149$gmane$org@x220.int.ebiederm.org>
References: <CAFmghwxWtf53ES1ZL8pZsncEPjY0awPTrja2Hct8zJQU8hXMOQ@mail.gmail.com>
	<87k2wi4urh.fsf@x220.int.ebiederm.org>
	<CAFmghwzv2TOJfDt0u4K3+m-nVBPHgbTqR65kJ3cZ++MzpYb-Vw@mail.gmail.com>
	<CAFmghwwYC+QaoHHHLwoVY6U1jSLFDuNtxvHULFFzQkc-wUGFOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAFmghwwYC+QaoHHHLwoVY6U1jSLFDuNtxvHULFFzQkc-wUGFOw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Eric Windisch's message of "Fri, 8 May 2015 18:44:05 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 7e96c1b0e0f495c5a7450dc4aa7c9a24ba4305bd mnt: Fix fs_fully_visible to verify the root directory is visible

Eric Windish recently reported a really bug that allows mounting fresh
copies of proc and sysfs when it really should not be allowed.  The code
attempted to verify that proc and sysfs were fully visible but there is
a test missing to ensure that the root of the filesystem is visible.
Doh!

The following patch fixes that.

This fixes a containment issue that the docker folks are seeing.

I see one or two more issues that I would like to correct in the check
for mounting proc and sysfs but those look like they have a non-trivial
chance of breaking working user space so they are going to need more
review and testing before I send them your way.

commit 7e96c1b0e0f495c5a7450dc4aa7c9a24ba4305bd
Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date:   Fri May 8 16:36:50 2015 -0500

    mnt: Fix fs_fully_visible to verify the root directory is visible
    
    This fixes a dumb bug in fs_fully_visible that allows proc or sys to
    be mounted if there is a bind mount of part of /proc/ or /sys/ visible.
    
    Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
    Reported-by: Eric Windisch <ewindisch-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/namespace.c b/fs/namespace.c
index 1f4f9dac6e5a..1b9e11167bae 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3179,6 +3179,12 @@ bool fs_fully_visible(struct file_system_type *type)
                if (mnt->mnt.mnt_sb->s_type != type)
                        continue;
 
+               /* This mount is not fully visible if it's root directory
+                * is not the root directory of the filesystem.
+                */
+               if (mnt->mnt.mnt_root != mnt->mnt.mnt_sb->s_root)
+                       continue;
+
                /* This mount is not fully visible if there are any child mounts
                 * that cover anything except for empty directories.
                 */
