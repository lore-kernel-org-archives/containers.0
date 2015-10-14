From: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v4 00/11] Smack namespace
Date: Wed, 14 Oct 2015 14:41:54 +0200
Message-ID: <1444826525-9758-1-git-send-email-l.pawelczyk@samsung.com>
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
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Calvin Owens <calvinowens-b10kYP2dOMg@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Mauro Carvalho Chehab <mchehab-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: Lukasz Pawelczyk <havner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Fourth version of Smack namespace. Rebased for smack-for-4.4 with some
minor cosmetic changes.

Readme from v3 as there were the most significant changes:

https://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg899383.html
https://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg898638.html

1. the label map should be in /proc/.../attr/label_map and be handled
   generically.
2. The proper file system label (unmapped) should be written only once
   to remove a state where an incorrect label is on the filesystem.

Ad 1: Contrary to what Stephen said this unfortunately required LSM
modifications.

For reading: the map can be long, in principle longer than PAGE_SIZE to
which normal getprocattr hook is limited. So I invented a way for
getprocattr to be handled by seq operations. I think it is generic and
can be reused nicely by other LSMs. Also it doesn't break current LSM
code in any way. This created a new patch.

For writing: the default setprocattr arguments were not enough for me
to securely decide if the write access should be granted. To be in
parallel with user namespace I also needed credentials of the process
that actually opened the map (in addition to current). So I added a new
argument. This is also a new patch.

Ad 2: I really tried to make it work without introducing a new LSM
hook but changing a little semantics behind the current ones. Finally
I just added a simple inode_pre_setxattr hook that can swap the label
before it is written to the filesystem.  Hopefully this is ok. I
couldn't do this in inode_setxattr hook as Stephen suggested as this
hook is called before __vfs_setxattr_noperm which is an exported
symbol and is used sometimes without setxattr hence the logic had to
be inside that one. This is also a new patch.

I also added a new patch that "fixes" smackfs/syslog. I've noticed that
inside a namespace when I cat the file it shows "*". Even when I
remapped the star. After looking at the code it had it implicitly
displayed when it's not set. There were few problems with it:

1. In a namespace we can see a label that is not mapped.
2. There was no way to actually reset the value to default (NULL)
3. It was inconsistent from user space point of view:

# cat /smack/syslog
*

After the reboot the syslog hook doesn't limit anything, the
smack_syslog_label is NULL, but it displays star.

# echo '*' > /smack/syslog
# cat /smack/syslog
*

From user space POV this is the same, file has star inside, but now for
the hook to pass the current needs to be star as well. And there is no
way to reset it back to NULL. So I treated syslog file the same way
unconfined and onlycap are handled. If it's empty, there is no label
set, hook doesn't limit anything (except for the cap). When it's filled
current needs to be equal for the hook to pass (as was before). But now
it can be reset back to NULL by writing EINVAL value (e.g. -syslog).
The syslog hook itself was not modified, only the file handling.

Changes from v3:
- rebased to the latest smack branch (smack-for-4.4)
- cosmetics in second patch reported by Paul Moore
- Acks from Paul Moore and Serge E. Hallyn on selected patches

Changes from v2:
- fix for config ifdefs in user_ns LSM hooks patch (CONFIG_USER_NS
  should've been used instead of CONFIG_SECURITY in several places)
- new patch for "smack_map" -> "attr/label_map" and new related
  getprocattr_seq lsm hook. With this change the code in further
  patches for handling smack_map has been moved to this new method
- new patch for setprocattr hook new argument, file's opener creds
- new patch for inode_pre_setxattr LSM hook
- new patch related to handling smackfs/syslog

Changes from v1:
- "kernel/exit.c: make sure current's nsproxy != NULL while checking
  caps" patch has been dropped
- fixed the title of the user_ns operations patch

Lukasz Pawelczyk (11):
  user_ns: 3 new LSM hooks for user namespace operations
  lsm: /proc/$PID/attr/label_map file and getprocattr_seq hook
  lsm: add file opener's cred to a setprocattr arguments
  lsm: inode_pre_setxattr hook
  smack: extend capability functions and fix 2 checks
  smack: don't use implicit star to display smackfs/syslog
  smack: abstraction layer for 2 common Smack operations
  smack: misc cleanups in preparation for a namespace patch
  smack: namespace groundwork
  smack: namespace implementation
  smack: documentation for the Smack namespace

 Documentation/security/00-INDEX            |   2 +
 Documentation/security/Smack-namespace.txt | 231 +++++++++++
 MAINTAINERS                                |   1 +
 fs/proc/base.c                             |  83 +++-
 fs/xattr.c                                 |  10 +
 include/linux/lsm_hooks.h                  |  70 +++-
 include/linux/security.h                   |  49 ++-
 include/linux/user_namespace.h             |   4 +
 kernel/user.c                              |   3 +
 kernel/user_namespace.c                    |  18 +
 security/apparmor/lsm.c                    |   5 +-
 security/security.c                        |  54 ++-
 security/selinux/hooks.c                   |   2 +-
 security/smack/Kconfig                     |  12 +
 security/smack/Makefile                    |   1 +
 security/smack/smack.h                     | 124 +++++-
 security/smack/smack_access.c              | 263 ++++++++++--
 security/smack/smack_lsm.c                 | 626 +++++++++++++++++++++--------
 security/smack/smack_ns.c                  | 443 ++++++++++++++++++++
 security/smack/smackfs.c                   | 206 ++++++----
 20 files changed, 1912 insertions(+), 295 deletions(-)
 create mode 100644 Documentation/security/Smack-namespace.txt
 create mode 100644 security/smack/smack_ns.c

-- 
2.4.3
