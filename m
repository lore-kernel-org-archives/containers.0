From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] don't call pre_restore_task twice
Date: Thu, 8 Oct 2009 09:12:58 -0500
Message-ID: <20091008141258.GA21486@us.ibm.com>
References: <20091007234750.GA6881@us.ibm.com>
	<20091008030919.GH18101@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091008030919.GH18101-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Wed, Oct 07, 2009 at 06:47:50PM -0500, Serge E. Hallyn wrote:
> > Pre_restore_task is being called both before and inside
> > restore_task, causing a memory leak at
> > current->checkpoint_data.
> > 
> > Only call it once, outside restore_task.
> > 
> > This fixes a memory leak spotted by Dan Smith, and the
> > actual bug was deduced by Matt Helsley.
> > 
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > Reported-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> However, I think I spotted another problem:
> 
> int pre_restore_task()
> {
>         sigset_t sigset;
> 
>         /* task-specific restart data: freed from post_restore_task() */
>         current->checkpoint_data = kzalloc(sizeof(struct ckpt_data),
> GFP_KERNEL);
>         if (!current->checkpoint_data)
>                 return -ENOMEM;
> ...
> }
> 
> void post_restore_task()
> {
> 	sigprocmask(SIG_SETMASK, &current->checkpoint_data->blocked, NULL);
> ...
> }
> 
> then in do_restore_coord():
> 
> if (ctx->uflags & RESTART_TASKSELF) {
>                 ret = pre_restore_task();
>                 ckpt_debug("pre restore task: %d\n", ret);
>                 if (ret < 0)
>                         goto out;
> ...
>  out:
>         if (ctx->uflags & RESTART_TASKSELF)
>                 post_restore_task();
> 
> But if we got -ENOMEM from pre_restore_task() then I think there will be a
> NULL dereference.

But the very first thing post_restore_task() does is

	/* can happen if restart failed early */
	if (!current->checkpoint_data)
		return;

-serge
