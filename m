From: Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 0/2] Namespace support for Android binder (under ipc-ns)
Date: Sun, 22 Dec 2013 05:07:38 -0500
Message-ID: <cover.1387706794.git.orenl@cellrox.com>
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
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, =?UTF-8?q?Arve=20Hj=C3=B8nnev=C3=A5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

This patch-duo adds namespaces support for the Android binder driver. As
discussed in Plumbers 2013, binder is a form of IPC and therefore will be
tied to ipc namespace.

On the ipc-ns side, the implementation is modelled after generic net-ns
pointers (see commit dec827d), but simplified to suit single user/caller
for now, to reduce complexity.

The binder driver registers with ipc-ns and uses the generic pointer to
store and retrieve its namespace data. That is, each namespace maintains
its own binder context manager - which suffices for separation, since all
transactions require binder handles provided by the context manager.

Thanks,

Oren.


Oren Laadan (2):
  ipc namespace: a generic per-ipc pointer and peripc_ops
  binder: implement namepsace support for Android binder driver

 drivers/staging/android/Kconfig  |   1 +
 drivers/staging/android/binder.c | 172 ++++++++++++++++++++++++++++++++-------
 include/linux/ipc_namespace.h    |  29 +++++++
 ipc/namespace.c                  |   9 ++
 ipc/util.c                       |  60 ++++++++++++++
 ipc/util.h                       |   3 +
 6 files changed, 244 insertions(+), 30 deletions(-)

-- 
1.8.3.2
