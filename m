From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] user namespace updates for v4.15-rc1
Date: Wed, 15 Nov 2017 21:34:44 -0600
Message-ID: <87a7zmzyjv.fsf@xmission.com>
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
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: userns: Simplify insert_extent 3fda0e737e906ce73220b20c27e7f792d0aac6a8

The only change that is production reading this round is the work to
increase the number of uid and gid mappings a user namespace can support
from 5 to 340.  This code was carefully benchmarked and it was confirmed
that in the existing cases the performance remains the same.  In the
worst case with 340 mappings an cache cold stat times go from 158ns to
248ns.  That is noticable but still quite small, and only the people who
are doing crazy things pay the cost.

This work uncovered some documentation and cleanup opportunities in the
mapping code, and patches to make those cleanups and improve the
documentation will be coming in the next merge window.

Christian Brauner (2):
      userns: use union in {g,u}idmap struct
      userns: bump idmap limits to 340

Eric W. Biederman (5):
      userns: Don't special case a count of 0
      userns: Simplify the user and group mapping functions
      userns: Don't read extents twice in m_start
      userns: Make map_id_down a wrapper for map_id_range_down
      userns: Simplify insert_extent

 include/linux/user_namespace.h |  23 ++-
 kernel/user.c                  |  30 ++--
 kernel/user_namespace.c        | 349 ++++++++++++++++++++++++++++++++++-------
 3 files changed, 325 insertions(+), 77 deletions(-)

Eric
