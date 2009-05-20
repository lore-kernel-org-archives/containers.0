From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/6] cr: checkpoint and restore task credentials
Date: Wed, 20 May 2009 17:16:01 -0500
Message-ID: <20090520221600.GA3925@us.ibm.com>
References: <20090519014446.GA28277@us.ibm.com>
	<20090519014538.GD28312@us.ibm.com>
	<4A1435E0.3010306@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A1435E0.3010306-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >  /* read the entire state of the current task */
> >  int restore_task(struct ckpt_ctx *ctx)
> >  {
> >  	int ret;
> > +	struct cred *realcred, *ecred;
> >  
> > -	ret = restore_task_struct(ctx);
> > +	ret = restore_task_struct(ctx, &realcred, &ecred);
> 
> Actually, this is one of several cases where we need to restore some
> resources but only apply it to a process at the end of its restart.
> 
> Another example would be restoring pending signals and the blocked
> signal mask in the future.
> 
> I suggest that we keep a pointer on the task_struct to a structure
> that will hold all that do-later work. The structure can encapsulate
> the pending work either explicitly - e.g. a struct with fields like
> realcred, ecred, signal mask, etc... - or implicitly, by reusing the
> deferqueue framework, per task.
> 
> Actually, that pointer can be kept on the ckpt_ctx structure, to be
> used by the current-restarting-task only.
> 
> >  	ckpt_debug("ret %d\n", ret);
> >  	if (ret < 0)
> >  		goto out;
> > @@ -671,6 +1120,10 @@ int restore_task(struct ckpt_ctx *ctx)
> >  		goto out;
> >  	ret = restore_cpu(ctx);
> >  	ckpt_debug("cpu: ret %d\n", ret);
> > +	if (ret < 0)
> > +		goto out;
> > +	ret = restore_creds(ctx, realcred, ecred);
> 
> ... and this would then be called from a restore_task_finalize()
> function explicitly or implicitly by deferqueue_run().

deferqueue_run() won't do, since that's done only once for the
whole container, and we (as you say above) want to reuse one
set of fields in the ckpt_ctx for each task's sys_restart() run.

I'll go ahead and put fields in the ckpt_ctx this time around
and use those, but won't go further right now as I'd be
overgeneralizing before we have the signals and such work
done.  When we do that, we can move the restore_creds() fn
if appropriate.

-serge
