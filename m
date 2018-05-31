From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: [PATCH v3 0/4] seccomp trap to userspace
Date: Thu, 31 May 2018 08:49:45 -0600
Message-ID: <20180531144949.24995-1-tycho__44807.2814303034$1527778188$gmane$org@tycho.ws>
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
Cc: "Tobin C . Harding" <me-xzjC0nNlxno@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi all,

Here's a v3 of the seccomp trap to userspace, with all the nits from v2
fixed. Open questions from v2 are still:

1. is it ok not to use netlink?
2. what should the fd passing API look like? (see patch notes on this
   one for details of why the current one might (?) be a problem)

As an added bonus, I've also written some stress testing, with lots of
tasks and listeners (1000 of each) sharing the same notification thread,
and not found any issues so far. Code is here:
https://github.com/tych0/kernel-utils/blob/master/seccomp/notify_stress.c
although I haven't included it in the patchset.

v2: https://lkml.org/lkml/2018/5/17/627

Tycho Andersen (4):
  seccomp: add a return code to trap to userspace
  seccomp: make get_nth_filter available outside of CHECKPOINT_RESTORE
  seccomp: add a way to get a listener fd from ptrace
  seccomp: add support for passing fds via USER_NOTIF

 arch/Kconfig                                  |   7 +
 include/linux/seccomp.h                       |  14 +-
 include/uapi/linux/ptrace.h                   |   2 +
 include/uapi/linux/seccomp.h                  |  20 +-
 kernel/ptrace.c                               |   4 +
 kernel/seccomp.c                              | 477 +++++++++++++++++-
 tools/testing/selftests/seccomp/seccomp_bpf.c | 373 +++++++++++++-
 7 files changed, 889 insertions(+), 8 deletions(-)

-- 
2.17.0
