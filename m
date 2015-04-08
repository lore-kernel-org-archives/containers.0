From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 0/4] Loopback mount escape fixes
Date: Wed, 08 Apr 2015 18:31:56 -0500
Message-ID: <874moq9oyb.fsf_-___697.806015569036$1428536185$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87a8yqou41.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Thu, 02 Apr 2015 20:53:18 -0500")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


After the last round of feedback I sat down and played with my fix
for the fact that a strategically placed rename, ".." on bind mounts
go up past the root of the bind mount.

The code better handles the escaped directory returning into it's bind
mount, and is now roughly a constant factor cost in all cases from what
the code costs without the fix.

So I think I have found a better tradeoff between fixing this bug and
not slowing down path name lookups in the common case.

These fixes are against on v4.0-rc6.

For those who like to see everything in a single tree the code is at:

    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing

Eric W. Biederman (4):
      mnt: Track which mounts use a dentry as root.
      vfs: Test for and handle paths that are unreachable from their mnt_root
      vfs: Handle mounts whose parents are unreachable from their mountpoint
      vfs: Do not allow escaping from bind mounts.

 fs/dcache.c            |  82 +++++++++++++++++++++++++++---
 fs/internal.h          |   2 +
 fs/mount.h             |   6 +++
 fs/namei.c             |  57 +++++++++++++++++----
 fs/namespace.c         | 135 +++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/dcache.h |  13 +++++
 include/linux/namei.h  |   2 +
 7 files changed, 277 insertions(+), 20 deletions(-)
