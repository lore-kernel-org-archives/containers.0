From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: [RFC 0/3] seccomp trap to userspace
Date: Sun,  4 Feb 2018 11:49:43 +0100
Message-ID: <20180204104946.25559-1-tycho__2892.88406861505$1517741364$gmane$org@tycho.ws>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

Several months ago at Linux Plumber's, we had a discussion about adding a
feature to seccomp which would allow seccomp to trigger a notification for some
other process. Here's a draft of that feature.

Patch 1 contains the bulk of it, patches 2 & 3 offer an alternative way to
acquire the fd that receives notifications via ptrace (the method in patch 1
poses some problems). Other suggestions for how to acquire one of these fds
would be welcome.

Take a close look at the synchronization. I think I've got it right, but I
probably don't :)

Thanks!

Tycho Andersen (3):
  seccomp: add a return code to trap to userspace
  seccomp: hoist out filter resolving logic
  seccomp: add a way to get a listener fd from ptrace

 arch/Kconfig                                  |   7 +
 include/linux/seccomp.h                       |  14 +-
 include/uapi/linux/ptrace.h                   |   1 +
 include/uapi/linux/seccomp.h                  |  18 +-
 kernel/ptrace.c                               |   4 +
 kernel/seccomp.c                              | 467 ++++++++++++++++++++++++--
 tools/testing/selftests/seccomp/seccomp_bpf.c | 180 +++++++++-
 7 files changed, 653 insertions(+), 38 deletions(-)

-- 
2.14.1
