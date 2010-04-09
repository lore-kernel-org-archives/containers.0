From: "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH] c/r: restore tty pgrp properly
Date: Fri, 9 Apr 2010 11:47:00 +0400
Message-ID: <201004091147.01571@zigzag.lvk.cs.msu.su>
References: <4BBDFB60.2080505@lvk.cs.msu.su>
	<20100408210008.GF3345@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100408210008.GF3345-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Leonid Snegirev <leo-n4oKp6kCDthKyFCjRbgQbg@public.gmane.org>
List-Id: containers.vger.kernel.org

> Do you have a testcase where restart doesn't work because of problems
> with tty->pgrp restore? Or was this just something that caught your eye
> during review?

Yes, we faced this while trying to restore an Xvnc session (bash running a 
script + Xvnc + twm + xterm + bash). It was failing with -ESRCH at this 
particular point, and we have been trying to solve it.

> Userspace can change h->tty_pgrp_owner to any value (bug, cosmic ray,
> exploit attempt) before passing the checkpoint image to restart. We
> don't want malicious programs to be able to cause an Oops or worse so we
> need to make sure the index is less than the number of entries in the
> pids_arr. Since the value was a prgrp id prior to this patch I doubt
> that check already exists.

Understood.

It should be not

if (h->tty_pgrp_owner != -1), but

but

if ( h->tty_pgrp_owner >=0 && h->tty_pgrp_owner < ctx->nr_tasks)

> However, I suspect this is already covered in userspace
> by rewriting the pids array prior to calling sys_restart(). See
> ckpt_init_tree() in user-cr's restart.c and let me know if you agree
> and/or see any problems with that approach.

This may be indeed better, but it requires userspace to have knowledge 
about entire checkpoint structure, with (as far as I understand) is not 
the case currently, and may be hard to maintain while checkpoint format 
envolves in future.

Nikita
