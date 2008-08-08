From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [RFC][PATCH 0/4] kernel-based checkpoint restart
Date: Fri, 8 Aug 2008 11:25:12 +0200
Message-ID: <200808081125.12706.arnd@arndb.de>
References: <20080807224033.FFB3A2C1@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080807224033.FFB3A2C1@kernel>
Content-Disposition: inline
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Friday 08 August 2008, Dave Hansen wrote:
> These patches are from Oren Laaden.  I've refactored them
> a bit to make them a wee bit more reviewable.  I think this
> separates out the per-arch bits pretty well.  It should also
> be at least build-bisetable.

Cool stuff

> ============================== ckpt.c ================================
> 
> #define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <errno.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <asm/unistd_32.h>
> #include <sys/syscall.h>

Note that asm/unistd_32.h is not portable, you should use asm/unistd.h
in the example.

>         pid_t pid = getpid();
>         int ret;
>
>         ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);

Interface-wise, I would consider checkpointing yourself signficantly
different from checkpointing some other thread. If checkpointing
yourself is the common case, it probably makes sense to allow passing
of pid=0 for this.

	Arnd <><
