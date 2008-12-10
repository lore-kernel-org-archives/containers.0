From: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 0/3] CGroups: CGroups: Hierarchy locking/refcount changes
Date: Wed, 10 Dec 2008 15:36:54 -0800
Message-ID: <20081210233654.563182000__3585.41622194952$1228952953$gmane$org@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

These patches present an alternative to some of the other cgroups
locking/refcount patches that have been proposed on LKML recently.

Several of these patches have been to address the race opened by
moving the calls to pre_destroy() callbacks outside of cgroup_mutex;
rather than continuing to patch up the holes caused by that change,
these patches introduce new locking/refcount rules to ultimately allow
the previous atomicity of cgroup_rmdir() to be restored.

These three patches give:

1/3 - introduce a per-subsystem hierarchy_mutex which a subsystem can
      use to prevent changes to its own cgroup tree

2/3 - use hierarchy_mutex in place of calling cgroup_lock() in the
      memory controller

3/3 - introduce a css_tryget() function similar to the one proposed by
      Kamezawa, but avoiding spurious refcount failures in the event
      of a race between a css_tryget() and an unsuccessful cgroup_rmdir()

Future patches will likely involve:

- using hierarchy mutex in place of cgroup_lock() in more subsystems
  where appropriate

- restoring the atomicity of cgroup_rmdir() with respect to cgroup_create()

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
