From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/6] cr: checkpoint and restore task credentials
Date: Wed, 20 May 2009 16:40:27 -0500
Message-ID: <20090520214027.GA3517@us.ibm.com>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >  /* dump the task_struct of a given task */
> >  static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
> >  {
> >  	struct ckpt_hdr_task *h;
> >  	int ret;
> > +	int realcred_ref, ecred_ref;
> > +
> > +	realcred_ref = checkpoint_obj(ctx, t->real_cred, CKPT_OBJ_CRED);
> > +	if (realcred_ref < 0)
> > +		return realcred_ref;
> > +
> > +	ecred_ref = checkpoint_obj(ctx, t->cred, CKPT_OBJ_CRED);
> > +	if (ecred_ref < 0)
> > +		return ecred_ref;
> 
> Is this safe even if the checkpointed task's state changes ?
> (e.g. unfrozen - yes, I know there is a patch in the works to
> prevent this; but if we ever want to checkpoint STOPPED tasks...
> for instance).
> 
> Would incrementing the refcount on t->{cred,real_cred} help ?

Doesn't checkpoint_obj already do that through obj_new?

-serge
