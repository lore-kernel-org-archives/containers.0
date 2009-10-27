From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v18-dev, updated. v2.6.31-124-g8adba1c
Date: Tue, 27 Oct 2009 11:53:33 -0400
Message-ID: <200910271553.n9RFrXHO003235@gorgona.ncl.cs.columbia.edu>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The branch, ckpt-v18-dev has been updated
       via  8adba1cc04ec7c406969990e2a1c0ba5c94a9d73 (commit)
       via  e57988655ff68df7b571a2a295f39e22a9e91b0f (commit)
       via  635b019e6138a893b0dbb06330da285b23c0ac83 (commit)
      from  066f73af9c55d4fa285f3065a9403a81d52228c8 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 8adba1cc04ec7c406969990e2a1c0ba5c94a9d73
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Oct 27 11:51:44 2009 -0400

    c/r: self-restart to tolerate missing pgid
    
    In self-restart we don't generate ghost tasks. Instead we permit
    undefined pgid - tolerate inability to restore the pgid of the
    restarting process.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit e57988655ff68df7b571a2a295f39e22a9e91b0f
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Oct 27 11:51:44 2009 -0400

    c/r: fix compile warning in restore_open_fname()
    
    (regression from commit e57f0b4bb8daf82c15a99095ecf38cb7383fae08)
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 635b019e6138a893b0dbb06330da285b23c0ac83
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Oct 27 11:51:37 2009 -0400

    c/r: fix typos in Documentation/checkpoint
    
    - update description of sample output in usage.txt
    - fix typo in self_checkpoint.c
    - fix typo in self_restart.c
    
    Reported by Liu Aleaxander.
    
    Cc: Liu Aleaxander <Aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 Documentation/checkpoint/self_checkpoint.c |    2 +-
 Documentation/checkpoint/self_restart.c    |    2 +-
 Documentation/checkpoint/usage.txt         |   48 +++++++++++++++++----------
 checkpoint/files.c                         |    2 +-
 checkpoint/process.c                       |    4 ++
 5 files changed, 37 insertions(+), 21 deletions(-)


hooks/post-receive
--
linux-cr
