From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 00/11] pkg-shadow support subordinate ids with user namespaces
Date: Tue, 22 Jan 2013 01:11:19 -0800
Message-ID: <87d2wxshu0.fsf@xmission.com>
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
To: Nicolas =?utf-8?Q?Fran=C3=A7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


The kernel support for user namespaces allows ordinary users to use
multiple uids and gids if they can get a trusted program to tell the
kernel the set of subordinate uids and gids they are allowed to use.

This is my work to make that trusted program.
Two new files are added /etc/subuid /etc/subgid that specify
ranges of uids and gids that users may uses.

useradd, and newusers are modifed to add users to those files.

userdel is modeifed to remove users from those files.

usermod is modified to give manual control of what goes in those files.

newuidmap and newgidmap read the new files and update
/proc/[pid]/uid_map and /proc/[pid]/gid_map respectively
as requested by their command line parameters and as allowed
by the /etc/subuid and /etc/subgid.

The following patches are against the current developent trunk
of pkg-shadow svn rev 3745.  With minor tweaking of man/Makefile.am
these patches also apply to shadow 4.1.5.

Eric W. Biederman (11):
      Documentation for /etc/subuid and /etc/subgid
      login.defs.5: Document the new variables in login.defs
      Implement commonio_append.
      Add backend support for suboridnate uids and gids
      Implement find_new_sub_uids find_new_sub_gids
      userdel: Add support for removing subordinate user and group ids.
      useradd: Add support for subordinate user identifiers
      Add support for detecting busy subordinate user ids
      usermod: Add support for subordinate uids and gids.
      newusers: Add support for assiging subordinate uids and gids.
      newuidmap,newgidmap: New suid helpers for using subordinate uids and gids
---

 etc/login.defs                     |    8 +
 lib/Makefile.am                    |    2 +
 lib/commonio.c                     |   30 ++
 lib/commonio.h                     |    1 +
 lib/getdef.c                       |    6 +
 lib/prototypes.h                   |    9 +
 lib/subordinateio.c                |  512 ++++++++++++++++++++++++++++++++++++
 lib/subordinateio.h                |   38 +++
 libmisc/Makefile.am                |    4 +
 libmisc/find_new_sub_gids.c        |   87 ++++++
 libmisc/find_new_sub_uids.c        |   87 ++++++
 libmisc/idmapping.c                |  126 +++++++++
 libmisc/idmapping.h                |   44 +++
 libmisc/user_busy.c                |   18 +-
 man/Makefile.am                    |   10 +
 man/login.defs.5.xml               |    8 +
 man/login.defs.d/SUB_GID_COUNT.xml |   46 ++++
 man/login.defs.d/SUB_UID_COUNT.xml |   46 ++++
 man/newgidmap.1.xml                |  157 +++++++++++
 man/newuidmap.1.xml                |  154 +++++++++++
 man/subgid.5.xml                   |  120 +++++++++
 man/subuid.5.xml                   |  120 +++++++++
 man/usermod.8.xml                  |   80 ++++++
 src/Makefile.am                    |    5 +-
 src/newgidmap.c                    |  183 +++++++++++++
 src/newuidmap.c                    |  183 +++++++++++++
 src/newusers.c                     |  124 +++++++++
 src/useradd.c                      |  141 ++++++++++-
 src/userdel.c                      |  115 ++++++++
 src/usermod.c                      |  255 ++++++++++++++++++-
 30 files changed, 2708 insertions(+), 11 deletions(-)
