From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [v10][PATCH 8/9] Define clone_with_pids() syscall
Date: Tue, 3 Nov 2009 09:16:22 -0800
Message-ID: <20091103171622.GA18403@us.ibm.com>
References: <20091101204132.GA22116@us.ibm.com>
	<20091101204548.GG23168@us.ibm.com>
	<1257264980.31972.2518.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1257264980.31972.2518.camel@nimitz>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| On Sun, 2009-11-01 at 12:45 -0800, Sukadev Bhattiprolu wrote:
| > +int sys_clone_with_pids(struct pt_regs *regs)
| > +{
| ...
| > +       rc = copy_from_user(&kcs, ucs, sizeof(kcs));
| > +       if (rc)
| > +               return -EFAULT;
| > +
| > +       /*
| > +        * TODO: If size of clone_args is not what the kernel expects, it
| > +        *       could be that kernel is newer and has an extended structure.
| > +        *       When that happens, this check needs to be smarter (and we
| > +        *       need an additional copy_from_user()). For now, assume exact
| > +        *       match.
| > +        */
| > +       if (kcs.clone_args_size != sizeof(kcs))
| > +               return -EINVAL;
| > +
| > +       /*
| > +        * To avoid future compatibility issues, ensure unused fields are 0.
| > +        */
| > +       if (kcs.reserved1 || kcs.clone_flags_high)
| > +               return -EINVAL;
| 
| Suka, is there a reason we don't have these bits in some
| arch-independent code?  I would have thought the stuff in the
| process_32.c code would be just as thin a wrapper as possible to unwrap
| the pt_regs and call into generic code.

Yes, it can be in arch independent code: but couple of minor inconvinences:

	- currently the arch independent code does not know about the
	  'clone_args' structure. This helps keep this patchset smaller.
	  It could know about it in the future (when more flags are added).

	- and we need to check these *before* unwrapping the values from
	  pt_regs.

Well, you are right. Will define 'check_clone_with_pids_params()' in
kernel/fork.c and call it here before unwrapping the params.

Suka
