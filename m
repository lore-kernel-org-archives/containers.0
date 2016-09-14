From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH tty-next 0/6] Minor devpts cleanups, fixes and enhancments
Date: Wed, 14 Sep 2016 13:52:00 -0500
Message-ID: <87sht25n73.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


Greg please apply the following patches to tty-next.  If tty-next is not
the proper tree please let me know and I will take these patches through
my user namespace tree.

The follow patches perform a few small cleanups and one enhancement to
devpts, with a net decrease in code size.

The big achievement from a code maintenance point of view is being able
to use mount_nodev in devpts_mount.

The only really significant bug fix is handling the very unlikely case
when kzalloc fails in new_pts_fs_info called from devpts_fill_super and
s_fs_info is NULL when devpts_kill_sb is called from deactivate_locked
super.

The final patch is an enhancment to use the fsuid and fsgid of the mounter
of devpts as the owner of /dev/pts/ptmx.  This is a feature that has
been asked for by users of user namespaces a couple of times, so that
they are not required to have uid 0 mapped into a user namespace to use
devpts.

Eric

fs/devpts/inode.c | 71 ++++++++++++++++++++-----------------------------------
 1 file changed, 26 insertions(+), 45 deletions(-)

Eric W. Biederman (6):
      devpts: Move parse_mount_options into fill_super
      devpts: Move the creation of /dev/pts/ptmx into fill_super
      devpts: Simplify devpts_mount by using mount_nodev
      devpts: Make devpts_kill_sb safe if fsi is NULL
      devpts: Remove sync_filesystems
      devpts: Change the owner of /dev/pts/ptmx to the mounter of /dev/pts
