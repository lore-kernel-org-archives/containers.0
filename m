From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 0/6] miscelaneous user namespace patches
Date: Fri, 25 Jan 2013 18:15:43 -0800
Message-ID: <87ehh8it9s.fsf@xmission.com>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Now that I have done my worst to infect user space with some
basic tools for using user namespaces, this is my first round of patches
aimed at the 3.9 merge window.

This documents that if you care about limit resources you want
to configure the memory control group when user namespaces are
enabled.

This enables the user namespace root to mount devpts, ramfs and tmpfs.
Functionality that is needed for practical uses of the user namespace.

This includes my patch to enable more flexibility into the input
allowed in uid_map and gid_map.

 Documentation/namespaces/resource-control.txt |   10 ++++
 fs/devpts/inode.c                             |   18 +++++++
 fs/ramfs/inode.c                              |    1 +
 include/linux/user_namespace.h                |   10 ++--
 init/Kconfig                                  |    7 +++
 kernel/user.c                                 |    4 +-
 kernel/user_namespace.c                       |   62 +++++++++++++++++++------
 mm/shmem.c                                    |    2 +
 8 files changed, 92 insertions(+), 22 deletions(-)

Eric W. Biederman (6):
      userns: Avoid recursion in put_user_ns
      userns: Allow any uid or gid mappings that don't overlap.
      userns: Recommend use of memory control groups.
      userns: Allow the userns root to mount of devpts
      userns: Allow the userns root to mount ramfs.
      userns: Allow the userns root to mount tmpfs.
