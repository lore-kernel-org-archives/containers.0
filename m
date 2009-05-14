From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: c/r updates
Date: Thu, 14 May 2009 11:53:40 -0400
Message-ID: <4A0C3E84.1040702@cs.columbia.edu>
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
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

The current development kernel git:
  git://git.ncl.cs.columbia.edu/pub/git/linux-cr    [ckpt-v15-dev]

The current development user tools git:
  git://git.ncl.cs.columbia.edu/pub/git/user-cr     [ckpt-v15-dev]

(branch naming will remain consistent from now ...)

Dave: I pushed a series of patches/fixes to current c/r tree, some of
which are are relevant to the patch series you're preparing.

Nathan: patches "tee...", "splice..." and "c/r: redo..." change the
way pipes are saved/restored, and avoids the lockdep issue.

Patches:
 c/r: fix ckpt_obj_fetch return values (v3)
 c/r: redo {checkpoint,restore}_pipe() using splice and tee
 splice: added support for pipe-to-pipe splice()
 tee: don't return 0 when another task drains/fills a pipe
 c/r: fix incorrect 'cond ? : xxx' statemnt
 c/r: set expire value to zero for restart block that expired
 c/r: x86 checkpoint support does not depend on CONFIG_COMPAT_VDSO
 c/r: s390: remove unused variable ret
 c/r: s390: fix unterminated ifdef
 c/r: test for ops->restore method in do_restore_file()
 c/r: grab missing reference to a (pipe) file if not first encounter
 Separate restore of task nxproxy (first) and memory (second)
 Fix leak of objects restored in restore_obj()
 c/r: fix users count of files that are pointed to by mm->exe_file
 c/r: fix incorrect variable type in call to strict_strtoul()

Oren.
