From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] don't call pre_restore_task twice
Date: Thu, 8 Oct 2009 11:49:30 -0700
Message-ID: <20091008184930.GA27627@count0.beaverton.ibm.com>
References: <20091007234750.GA6881@us.ibm.com>
	<20091008030919.GH18101@count0.beaverton.ibm.com>
	<20091008141258.GA21486@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091008141258.GA21486-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Oct 08, 2009 at 09:12:58AM -0500, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > On Wed, Oct 07, 2009 at 06:47:50PM -0500, Serge E. Hallyn wrote:

<snip>

> > void post_restore_task()
> > {
> > 	sigprocmask(SIG_SETMASK, &current->checkpoint_data->blocked, NULL);
> > ...
> > }
> > 
> > then in do_restore_coord():
> > 
> > if (ctx->uflags & RESTART_TASKSELF) {
> >                 ret = pre_restore_task();
> >                 ckpt_debug("pre restore task: %d\n", ret);
> >                 if (ret < 0)
> >                         goto out;
> > ...
> >  out:
> >         if (ctx->uflags & RESTART_TASKSELF)
> >                 post_restore_task();
> > 
> > But if we got -ENOMEM from pre_restore_task() then I think there will be a
> > NULL dereference.
> 
> But the very first thing post_restore_task() does is
> 
> 	/* can happen if restart failed early */
> 	if (!current->checkpoint_data)
> 		return;

Ah, good. That's a fairly recent change so it wasn't in my git tree.  Looks 
like it was added Oct 3rd by:

commit: bb091acbf0a47bd61323322a4e0a784d1ee0c24f
"c/r: threads sync on restart (fix regression from commit afbe522c...)"

Cheers,
	-Matt Helsley
