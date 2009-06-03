From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/4] cgroup freezer: Fixes and CHECKPOINTING support
Date: Wed,  3 Jun 2009 02:31:17 -0700
Message-ID: <cover.1244019829.git.matthltc@us.ibm.com>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


This series fixes a bug with the mainline cgroup freezer code and
cleans up the cgroup freezer before introducing the new
CHECKPOINTING state in the last patch. All but this last patch are
independent of checkpoint/restart and hence should be suitable for
mainline.

The bug was noticed by Oren Ladaan and allows tasks frozen via the
cgroup freezer to be thawed during resume when they should remain
frozen. In Oren's checkpoint/restart tree is means that
sys_checkpoint() sometimes returns EBUSY even when the cgroup is, 
in fact, fully frozen. (Workaround: cat /cgroup/foo/freezer.state
before doing checkpoint..)

The final patch, which adds the CHECKPOINTING state, incorporates
Oren's comments and should fix the lockdep bug he posted too. I 
haven't tested this latest version yet myself and I have a few things to 
attend to before I can get to it so I'm posting this for initial review
now. I believe this resolves all the pending comments I've seen about
the CHECKPOINTING state.

Cheers,
	-Matt Helsley

Matt Helsley (4):
  cgroup freezer: Fix buggy resume test for tasks frozen with cgroup
    freezer
  cgroup freezer: Avoid lazy state changes when convenient
  cgroup freezer: Update stale locking comments
  cgroup freezer: Add CHECKPOINTING state to safeguard container
    checkpoint

 Documentation/cgroups/freezer-subsystem.txt |   10 ++
 checkpoint/checkpoint.c                     |    8 +-
 include/linux/freezer.h                     |   15 ++-
 kernel/cgroup_freezer.c                     |  163 +++++++++++++++++++--------
 kernel/power/process.c                      |    2 +-
 5 files changed, 146 insertions(+), 52 deletions(-)
