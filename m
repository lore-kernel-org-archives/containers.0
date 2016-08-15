From: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 0/2 v2] userns: show current values of user namespace counters
Date: Mon, 15 Aug 2016 13:10:20 -0700
Message-ID: <1471291822-539-1-git-send-email-avagin@openvz.org>
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Recently Eric added user namespace counters.  User namespace counters is
a feature that allows to limit the number of various kernel objects a
user can create. These limits are set via /proc/sys/user/ sysctls on a
per user namespace basis and are applicable to all users in that
namespace.

User namespace counters are not in the upstream tree yet,
you can find them in Eric's tree:
https://git.kernel.org/cgit/linux/kernel/git/ebiederm/user-namespace.git/log/?h=for-testing

This patch adds /proc/<pid>/userns_counts files to provide current usage
of user namespace counters.

  > cat /proc/813/userns_counts
  user_namespaces          101000               1
  pid_namespaces           101000               1
  ipc_namespaces           101000               4
  net_namespaces           101000               2
  mnt_namespaces           101000               5
  mnt_namespaces           100000               1

The meanings of the columns are as follows, from left to right:

  Name         Object name
  UID          User ID
  Usage        Current usage

The full documentation is in the second patch.

v2: - describe this file in Documentation/filesystems/proc.txt
    - move and rename into /proc/<pid>/userns_counts

Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

Andrei Vagin (1):
  kernel: show current values of user namespace counters

Kirill Kolyshkin (1):
  Documentation: describe /proc/<pid>/userns_counts

 Documentation/filesystems/proc.txt |  30 +++++++++++
 fs/proc/array.c                    |  55 ++++++++++++++++++++
 fs/proc/base.c                     |   1 +
 fs/proc/internal.h                 |   1 +
 include/linux/user_namespace.h     |   8 +++
 kernel/ucount.c                    | 102 +++++++++++++++++++++++++++++++++++++
 6 files changed, 197 insertions(+)

-- 
2.5.5
