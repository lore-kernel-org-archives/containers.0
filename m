From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][0/5] Fixing unprivileged mount -o remount,ro
Date: Tue, 29 Jul 2014 20:41:43 -0700
Message-ID: <87ppgnjyx4.fsf_-_@x220.int.ebiederm.org>
References: <87fvih4a99.fsf@x220.int.ebiederm.org>
	<CAObL_7FfacSTdO=JEfYyqQrp8qOSob6qoWrGN=rSM5t9ckkTWg@mail.gmail.com>
	<8761injfj9.fsf_-_@x220.int.ebiederm.org>
	<CAObL_7GhpuO4m6HunKvNMSpiEYBuaJnvjfVDiyG88GZ8HOa-vg@mail.gmail.com>
	<CAOP=4wgKGxJmLwSHYRKXCTva_Fyzn+D1vaWhtT-mo_t9Uu68zA@mail.gmail.com>
	<87lhrihaan.fsf@x220.int.ebiederm.org>
	<CAObL_7HSNkM=Kr9Jwc9JB7Zt7ZdR+skzmPrxYcFSkCutFDA5KA@mail.gmail.com>
	<20140724194920.GU26600@ubuntumail>
	<CAOP=4wh-AXf7qPy0rPaQ6RFbbJGRWKo0h1Rn=9vLUeJ6b6Q7YA@mail.gmail.com>
	<8738dqh2j1.fsf@x220.int.ebiederm.org> <20140725060810.GC31313@1wt.eu>
	<877g2xou2u.fsf@x220.int.ebiederm.org>
	<87r415nf3k.fsf_-_@x220.int.ebiederm.org>
	<874my1neyr.fsf_-_@x220.int.ebiederm.org>
	<CAOP=4wj7m+w4aDJCuQaf3r9aFraPN1SvPgFSz=_UNkyC8gEHyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOP=4wj7m+w4aDJCuQaf3r9aFraPN1SvPgFSz=_UNkyC8gEHyQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Kenton Varda's message of "Tue, 29 Jul 2014 15:09:25 -0700")
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
Cc: Andrew Lutomirski <andy-RHosVwM/Cj8@public.gmane.org>, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


This patchset addresses a nasty bug where
"unshare --user --mount mount --bind -o remount,ro /path"
would allow a following "mount --bind -o remount,rw" to succeed even
when /path started out read-only in the initial mount namespace.

The fixes are quite simple and since they are user namespace specific I
plan on carrying them in my user namespace tree and ultimately pushing
them to Linus.

If anyone has any concerns about the code before I do that please speak
up so the issues can be addressed.

Eric W. Biederman (5):
      mnt: Only change user settable mount flags in remount
      mnt: Move the test for MNT_LOCK_READONLY from change_mount_flags into do_remount
      mnt: Correct permission checks in do_remount
      mnt: Change the default remount atime from relatime to the existing value
      mnt: Add tests for unprivileged remount cases that have found to be faulty

 fs/namespace.c                                     |  59 ++++-
 include/linux/mount.h                              |   9 +-
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/mount/Makefile             |  17 ++
 .../selftests/mount/unprivileged-remount-test.c    | 242 +++++++++++++++++++++
 5 files changed, 320 insertions(+), 8 deletions(-)

Eric
