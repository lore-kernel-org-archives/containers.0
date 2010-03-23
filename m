From: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 3/3] c/r: ARM implementation of checkpoint/restart
Date: Tue, 23 Mar 2010 21:18:43 +0000
Message-ID: <20100323211843.GC19572__6611.99986138872$1269391297$gmane$org@n2100.arm.linux.org.uk>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-4-git-send-email-christofferdall@christofferdall.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1269219965-23923-4-git-send-email-christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Mar 21, 2010 at 09:06:05PM -0400, Christoffer Dall wrote:
> The ISA version (given by __LINUX_ARM_ARCH__) is checkpointed and verified
> against the machine architecture on restart.

I think you misunderstand what __LINUX_ARM_ARCH__ signifies.  It is the
build architecture for the kernel, and it indicates the lowest
architecture version that the kernel will run on.

That doesn't indicate what ISA version the system is running on, or even
if the ABI is compatible (we have two ABIs - OABI and EABI).

There's also the matter of FP implementation - whether it is VFP or FPA,
and whether iwMMXt is available or not.  (iwMMXt precludes the use of
FPA.)

> Regarding ThumbEE, the thumbee_state field on the thread_info is stored
> in checkpoints when CONFIG_ARM_THUMBEE and 0 is stored otherwise. If
> a value different than 0 is checkpointed and CONFIG_ARM_THUMBEE is not
> set on the restore system, the restore is aborted. Feedback on this
> implementation is very welcome.

I don't recognise this configuration symbol; it doesn't exist in mainline.

> We checkpoint whether the system is running with CONFIG_MMU or not and
> require the same configuration for the system on which we restore the
> process. It might be possible to allow something more fine-grained,
> if it's worth the energy. Input on this item is also very welcome,
> specifically from someone who knows the exact meaning of the end_brk
> field.

Processes which run on MMU and non-MMU CPUs are unlikely to be
interchangable - the run time environments are quite different.  I
think this is a sane check.

> +/* dump the thread_struct of a given task */
> +int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
> +{
> +	int ret;
> +	struct ckpt_hdr_thread *h;
> +	struct thread_info *ti = task_thread_info(t);
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	/*
> +	 * Store the syscall information about the checkpointed process
> +	 * as we need to know if the process was doing a syscall (and which)
> +	 * during restart.
> +	 */
> +	h->syscall = ti->syscall;
> +
> +	/*
> +	 * Store remaining thread-specific info.
> +	 */
> +	h->tp_value = ti->tp_value;

How do you safely obtain consistent information from a thread?  Do you
temporarily stop it?
