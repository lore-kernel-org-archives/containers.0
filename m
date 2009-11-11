From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] implement s390 clone_with_pids syscall
Date: Wed, 11 Nov 2009 14:37:39 -0600
Message-ID: <20091111203739.GD8761@us.ibm.com>
References: <20091110163708.GA19122@us.ibm.com>
	<1257924442.7132.467.camel@localhost.localdomain>
	<20091111144600.GA6925@us.ibm.com>
	<1257958793.7132.1068.camel@localhost.localdomain>
	<20091111183303.GA8761@us.ibm.com>
	<1257970778.7132.1364.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1257970778.7132.1364.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org):
> Something I missed earlier is that the stack_size you are passing in
> from user space is not actually the size of the stack.  It's adjusted to
> account for arguments that have been placed at the end of the stack
> region.  So stack_size becomes a value that you want the kernel to add
> to stack_base to get the desired stack pointer value in the child --
> it's not a size at all.  At this point we may as well communicate the
> desired stack pointer value directly (which could be denoted by
> stack_size == 0, or we could add another member to clone_args), or
> rename stack_size to stack_offset or similar.

So do I understand correctly that the agreement (reached on irc) is
to keep passing in a stack_size, but enforce that it ==0 for all but
ia64?

-serge
