From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/9] user-cr: ppc32 eclone wrapper
Date: Thu, 19 Nov 2009 10:18:45 -0600
Message-ID: <1258647525.4031.1262.camel@localhost.localdomain>
References: <1258505746-31182-1-git-send-email-ntl@pobox.com>
	<1258505746-31182-5-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258505746-31182-5-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Cc: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-11-17 at 18:55 -0600, Nathan Lynch wrote:

> +int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
> +	   struct clone_args *clone_args, pid_t *pids)
> +{
> +	struct clone_args my_args;
> +	unsigned long child_sp;
> +	int newpid;
> +
> +	if (clone_args->child_stack)
> +		child_sp = clone_args->child_stack +
> +			clone_args->child_stack_size - 1;

Should be
		child_sp = (clone_args->child_stack +
			clone_args->child_stack_size - 1) & ~0xf;

Otherwise the child starts with an unaligned sp, causing accesses
outside of the stack region.
