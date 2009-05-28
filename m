From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 7/7] [PATCH] Define clone_with_pids syscall
Date: Wed, 27 May 2009 19:58:29 -0700
Message-ID: <20090528025829.GA14605@us.ibm.com>
References: <20090527154212.GA3107@us.ibm.com>
	<20090527154507.GG3107@us.ibm.com>
	<4A1D9A47.6030201@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A1D9A47.6030201-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

| > +	if (copy_from_user(&pid_set, upid_setp, sizeof(pid_set)))
| > +		return ERR_PTR(-EFAULT);
| > +
| > +	size = pid_set.num_pids * sizeof(pid_t);
| 
| ...either test "pid_set.num_pids > 0" (and give -EINVAL),
| or...

Good point. I now check for num_pids > 0 and treat num_pids == 0 as
normal clone().

While addressing this I realized I had a lot of arch-independent code
in arch/x86/kernel/process_32.c. I have now moved this common code to
kernel/fork.c. Its non-trivial code move, so need new review/acks from
you and Serge for at least patches 6 and 7.

Sukadev
