From: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [C/R v20][PATCH 37/96] c/r: introduce new 'file_operations':
	->checkpoint, ->collect()
Date: Mon, 22 Mar 2010 22:00:42 +1100
Message-ID: <20100322110042.GI17637__21235.5789299638$1269255754$gmane$org@laptop>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-3-git-send-email-orenl@cs.columbia.edu>
	<20100322063428.GE17637@laptop>
	<20100322101635.GC20796@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100322101635.GC20796-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 22, 2010 at 03:16:35AM -0700, Matt Helsley wrote:
> On Mon, Mar 22, 2010 at 05:34:28PM +1100, Nick Piggin wrote:
> > On Thu, Mar 18, 2010 at 08:59:46PM -0400, Oren Laadan wrote:
> > Hmm, what does generic_file_checkpoint mean? A NULL checkpoint op means
> > that checkpointing is allowed, and no action is required? Shouldn't it
> > be an opt-in operation, where NULL means not allowed?
> 
> generic_file_checkpoint is for files that have a seek operation and can be
> backed up or restored with a simple copy.
> 
> A NULL checkpoint op means "not allowed" as you thought it should. What
> gave you the impression it was otherwise? Here's the relevant snippet
> from checkpoint/files.c:

Right I didn't check that far. It's just a bit strange to make it look
like filling in an aop function but it is actually still NULL.


> 
> /* checkpoint callback for file pointer */
> int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
> {
>         struct file *file = (struct file *) ptr;
>         int ret;
> 
>         if (!file->f_op || !file->f_op->checkpoint) {
>                 ckpt_err(ctx, -EBADF, "%(T)%(P)%(V)f_op lacks checkpoint\n",
>                                file, file->f_op);
>                 return -EBADF;
>         }
> 
> > Either way, I don't know if you need to have this #define, provided you
> > have sufficient documentation.
> 
> We need it (or a suitable replacement) to avoid adding #ifdef around
> assignments to the operation in every filesystem. It's used if
> CONFIG_CHECKPOINT is not defined.

If !CONFIG_CHECKPOINT, ->checkpoint should not exist and neither
should it's callers.
