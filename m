From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 0/6] Wrapping up the vfs support for unprivileged
	mounts
Date: Wed, 23 May 2018 18:22:56 -0500
Message-ID: <87o9h6554f.fsf__14184.7512605183$1527117686$gmane$org@xmission.com>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
List-Id: containers.vger.kernel.org


Very slowly the work has been progressing to ensure the vfs has the
necessary support for mounting filesystems without privilege.

This patchset contains one more core piece of that work, ensuring a few
more operations that would write back an inode and confuse an exisiting
filesystem are denied.

The rest of the changes actually enable userns root to do things with
filesystems that the userns root has mounted.  Most of these have been
waiting in the wings a long time, held back because I wanted the core
of the patchset to be solid before I started allowing additional
behavor.

It is definitely time for these changes so the effect of s_user_ns
becomes less theoretical.

The change to allow mknod is new, but consistent with everything else
and harmless as device nodes on filesystems mounted without privilege
are ignored.

Unless problems show up in the during review I plan to merge these changes.

These changes are also available at:
  git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git userns-test

Eric W. Biederman (5):
      vfs: Don't allow changing the link count of an inode with an invalid uid or gid
      vfs: Allow userns root to call mknod on owned filesystems.
      fs: Allow superblock owner to replace invalid owners of inodes
      fs: Allow superblock owner to access do_remount_sb()
      capabilities: Allow privileged user in s_user_ns to set security.* xattrs

Seth Forshee (1):
      fs: Allow CAP_SYS_ADMIN in s_user_ns to freeze and thaw filesystems

 fs/attr.c            | 36 ++++++++++++++++++++++++++++--------
 fs/ioctl.c           |  4 ++--
 fs/namei.c           | 16 ++++++++++++----
 fs/namespace.c       |  4 ++--
 security/commoncap.c |  8 ++++++--
 5 files changed, 50 insertions(+), 18 deletions(-)

Eric
