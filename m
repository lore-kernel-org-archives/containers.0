From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/4] kernel-based checkpoint restart
Date: Fri, 08 Aug 2008 15:44:26 -0400
Message-ID: <489CA21A.4060009@cs.columbia.edu>
References: <20080807224033.FFB3A2C1@kernel> <200808081125.12706.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200808081125.12706.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

Arnd Bergmann wrote:
> On Friday 08 August 2008, Dave Hansen wrote:
>> These patches are from Oren Laaden.  I've refactored them
>> a bit to make them a wee bit more reviewable.  I think this
>> separates out the per-arch bits pretty well.  It should also
>> be at least build-bisetable.
> 
> Cool stuff
> 

Thanks. This is a proof of concept so all sorts of feedback are
definitely welcome. Some of the ideas and discussions are found
around:
   http://wiki.openvz.org/Containers/Mini-summit_2008
and the notes:
   http://wiki.openvz.org/Containers/Mini-summit_2008_notes
and the archives of the linux containers mailing list:
   https://lists.linux-foundation.org/pipermail/containers/
(August and July).

Several aspects of the implementation are still experimental and
I expect them to evolve with the feedback. In particular, expect
the specific user interface (syscalls) and the checkpoint image
format to be moving targets.

>> ============================== ckpt.c ================================
>>
>> #define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
>>
>> #include <stdio.h>
>> #include <stdlib.h>
>> #include <errno.h>
>> #include <fcntl.h>
>> #include <unistd.h>
>> #include <asm/unistd_32.h>
>> #include <sys/syscall.h>
> 
> Note that asm/unistd_32.h is not portable, you should use asm/unistd.h
> in the example.
> 
>>         pid_t pid = getpid();
>>         int ret;
>>
>>         ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);
> 
> Interface-wise, I would consider checkpointing yourself signficantly
> different from checkpointing some other thread. If checkpointing
> yourself is the common case, it probably makes sense to allow passing
> of pid=0 for this.
> 

The checkpoint/restart code is meant to checkpoint a whole container,
that is be able to save the state of multiple other tasks. The same
code can also be used to checkpoint yourself fairly easily with minimal
changes (see comments in the code about "in context" checkpoint/restart
that take care of this).

I suggest to keep the interface as is in the sense that the pid will
identify the target container (e.g. the pid of the init process of that
container).

Then, pid=0 would mean "the container to which I belong" if
you are inside a container (and therefore don't know the pid of the
init process there).

Finally, to checkpoint yourself, you would set the a bit in the flags
argument to something like CR_CKPT_MYSELF. Such a flag will be needed
internally anyway to special-case self checkpoint where appropriate.

Comments are welcome.

Oren.
