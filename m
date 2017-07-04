From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] mnt namespace updates for v4.13-rc1
Date: Tue, 04 Jul 2017 16:34:53 -0500
Message-ID: <87d19fhon6.fsf@xmission.com>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 296990deb389c7da21c78030376ba244dc1badf5 mnt: Make propagate_umount less slow for overlapping mount propagation trees

A big break through came during this development cycle as a way was
found to maintain the existing umount -l semantics while allowing for
optimizations that improve the performance.  That is represented by the
first change in this series moving the reparenting of mounts into their
own pass.  This has allowed addressing the horrific performance of
umount -l on a carefully crafted tree of mounts with locks held (0.06s
vs 60s in my testing).   What allowed this was not changing where
umounts propagate to while propgating umounts.

The next change fixes the case where the order of the mount whose umount
are being progated visits a tree where the mounts are stacked upon each
other in another order.  This is weird but not hard to implement.

The final change takes advantage of the unchanging mount propgation tree
to skip parts of the mount propgation tree that have already been
visited.  Yielding a very nice speed up in the worst case.

There remains one outstanding question about the semantics of umount -l
that I am still discussiong with Ram Pai.  In practice that area of the
semantics was changed by 1064f874abc0 ("mnt: Tuck mounts under others
instead of creating shadow/side mounts.") and no regressions have been
reported.  Still I intend to finish talking that out with him to ensure
there is not something a more intense use of mount propagation in the
future will not cause to become significant.

Eric W. Biederman (3):
      mnt: In umount propagation reparent in a separate pass
      mnt: In propgate_umount handle visiting mounts in any order
      mnt: Make propagate_umount less slow for overlapping mount propagation trees

 fs/mount.h     |   1 +
 fs/namespace.c |   1 +
 fs/pnode.c     | 212 ++++++++++++++++++++++++++++++++++++++++++++-------------
 3 files changed, 165 insertions(+), 49 deletions(-)

Eric
