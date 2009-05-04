From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 00/54] Kernel based checkpoint/restart
Date: Mon, 04 May 2009 15:13:11 -0400
Message-ID: <49FF3E47.9060002@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Dave,

I've addressed the feedback on ckpt-v14 and pushed it to ckpt-v15.
(There is no point in reposting the entire chain).

Main changes are use kmalloc/kfree in ckpt_hdr_get/put() implementation
(discard hbuf/hpos), move vdso patch early, fixes to s390, and added
support for /dev/null, /dev/zero, /dev/random, /dev/urandom (trivial
patch). Also, the powerpc patches are still there, however Nathan is
working or fixing them so eventually they will be replaced.

Oren.

Oren Laadan wrote:
> Here is the latest and greatest of checkpoint/restart (c/r) patchset.
> The logic and image format reworked and simplified, code refactored,
> support for PPC, s390, sysvipc, shared memory of all sorts, namespaces
> (uts and ipc).
> The userspace tool 'mktree' was extended to handle more complicated
> process tree and correctly account for process relationships and 
> session ID (sid). Should correctly handle threads.
> Hey, it even went through some massive renaming of files and functions...
> 
> Signals and timers are not supported yet, so programs that rely on
> their behavior may fail to oeprate correctly after a restart (e.g.
> may lose signals pending at time of checkpoint, and so on).
> 
> However, this one can actually be used for simple batch jobs (pipes,
> too), a whole container or just a subtree of tasks. Try it:
> 
> create the freezer cgroup:
>   $ mount -t cgroup -ofreezer freezer /freezer
>   $ mkdir /freezer/0
> 
> run the test, freeze it:  
>   $ test/multitask &
>   [1] 2754
>   $ for i in `pidof multitask`; do echo $i > /freezer/0/tasks; done
>   $ echo FROZEN > /freezer/0/freezer.state
> 
> checkpoint:
>   $ ./ckpt 2754 > ckpt.out
> 
> restart:
>   $ ./mktree < ckpt.out
> 
> voila :)
> 
> To do all this, you'll need:
> 
> The git tree tracking v14, branch 'ckpt-v14' (and past versions):
> 	git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git
> 
> Restarting multiple processes requires 'mktree' userspace tool with
> the matching branch (v14):
> 	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git
> 
> 
> Oren.
> 
> 
