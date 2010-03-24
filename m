From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 14/14][user-cr] Minimize unshare() calls
Date: Tue, 23 Mar 2010 23:26:53 -0500
Message-ID: <20100324042653.GA8263@us.ibm.com>
References: <20100319062659.GA23838@us.ibm.com>
	<20100319063448.GN24844@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100319063448.GN24844-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Mon, 8 Mar 2010 12:03:46 -0800
> Subject: [PATCH 14/14][user-cr] Minimize unshare() calls

Hmm, and yet, when I run cr_tests/simple.sh, restart apparently
does not use CLONE_NEWNS, bc I then have to
	umount /proc
	mount -t proc proc /proc
to restore sanity.

Not sure why...  restart -vd gives me

Using output dir ./cr_simple_N3wEpal
about to clone with 20020000
<3793>number of tasks: 1
<3793>total tasks (including ghosts): 1
<3793>====== TASKS
<3793>  [0] pid 1 ppid 0 sid 0 creator 0       
<3793>............
<3793>new pidns with init
<3793>forking child vpid 1 flags 0x21
<3793>forked child vpid 3795 (asked 1)
<1>root task pid 1
<1>pid 1: pid 1 sid 0 parent 0
<1>about to call sys_restart(), flags 0
<3794>====== PIDS ARRAY
<3794>[0] pid 1 ppid 0 sid 0 pgid 0
<3794>............
<3794>c/r read input 16384
<3794>c/r read input 16384
<3794>c/r read input 16384
<3794>c/r read input 16384
<3794>c/r read input 16384
<3794>c/r read input 11161
<3794>c/r read input 0
Success
<3793>restart succeeded
<3793>SIGCHLD: already collected
<3793>task exited with status 0
<3793>c/r succeeded
PASS

Oh, there you go - I suppose restart.c:557 should have TASK_NEWNS added?
Indeed that fixes that.

-serge
