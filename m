From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] have restart return error if error
Date: Sat, 17 Oct 2009 00:17:47 -0500
Message-ID: <20091017051747.GA25566@us.ibm.com>
References: <20091015184935.GB30490@us.ibm.com> <4AD90CB8.5050307@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AD90CB8.5050307-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> Serge E. Hallyn wrote:
> > I still need this for cr_tests/userns/run_simple.sh to succeed.
> > All tests pass with this patch applied.
> > 
> 
> But this is not the intended behavior.
> 
> The coordinator will:
> 
> 1) If restart fails, exit with an error status (>0)

But restart is failing, and the coordinator is not exiting with
error status.

> 2) If restart succeeds, exit immediately with status 0 (--no-wait),
> or (by default) wait for the restart root-task to exit, and then
> exit with success status 0, regardless of the exit status (or
> reason) of the restarted root-task.
> 
> What you want is that the coordinator instead will report the exit
> status of the restart root-task. You can use the --copy-status
> command line switch for that.
> 
> The intended behavior is that if the restarted root-task died due
> to a signal, then so will the coordinator (if --copy-status is
> requested). I now see that this part needs a small fix - to ensure
> that the signal is not handled by the coordinator. Will fix that.
> 
> Oren.
> 
> 
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  restart.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/restart.c b/restart.c
> > index cb81293..fa786ef 100644
> > --- a/restart.c
> > +++ b/restart.c
> > @@ -780,7 +780,7 @@ static int ckpt_parse_status(int status, int mimic, int verbose)
> >  		}
> >  	}
> >  
> > -	return 0;
> > +	return ret;
> >  }
> >  
> >  static int ckpt_collect_child(struct ckpt_ctx *ctx)
