From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] sem restore: don't free sma if it's an error
Date: Wed, 13 Jan 2010 14:17:30 -0600
Message-ID: <20100113201730.GA28472@us.ibm.com>
References: <1263355761-17112-1-git-send-email-serue@us.ibm.com>
	<1263355761-17112-2-git-send-email-serue@us.ibm.com>
	<20100113194121.GA26938@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100113194121.GA26938-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  ipc/checkpoint_sem.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
> > index 53a19ed..395c84d 100644
> > --- a/ipc/checkpoint_sem.c
> > +++ b/ipc/checkpoint_sem.c
> > @@ -186,6 +186,7 @@ int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
> >  	sma = restore_sem_array(ctx, h->sem_nsems);
> >  	if (IS_ERR(sma)) {
> >  		ret = PTR_ERR(sma);
> > +		sma = NULL;
> >  		goto out;
> >  	}
> > 
> > -- 
> > 1.6.0.6
> 
> So FWIW on x86-64 many of the tests current pass - the 3 failures I'm seeing
> are due to:
> 
> 	1. message queues for some reason aren't seen by the restarted
> 	   task (restart does think it is restoring them according to debug
> 	   info)
> 	2. self-checkpoint not yet supported
> 	3. restart block not set up right (or at least cr_tests/sleep fails
> 	   for some reason, haven't yet looked at why)
> 
> I'm trying to track down #1 right now

Oops, haha - bad selinux policy.  Down to two errors then.

-serge
