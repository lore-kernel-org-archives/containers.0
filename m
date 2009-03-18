From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/6] /proc/pid/checkpointable
Date: Wed, 18 Mar 2009 08:53:20 -0500
Message-ID: <20090318135320.GD22636@us.ibm.com>
References: <20090317062754.GA2377@us.ibm.com>
	<20090317063958.GG2377@us.ibm.com>
	<49C0B750.4050109@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49C0B750.4050109-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Sukadev Bhattiprolu wrote:
> > From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > Date: Sat, 14 Mar 2009 10:21:07 -0700
> > Subject: [PATCH 6/6] Explain reason for task being uncheckpointable
> > 
> > Try to give an useful message on why a task is uncheckpointable.
> > 
> > Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > ---
> >  checkpoint/checkpoint.c    |   13 +++++++++----
> >  fs/proc/base.c             |   19 ++++++++++++++++++-
> >  include/linux/checkpoint.h |    7 +++++++
> >  3 files changed, 34 insertions(+), 5 deletions(-)
> > 
> 
> [...]
> 
> >  #ifdef CONFIG_CHECKPOINT_RESTART
> > +static char *explain_checkpointable(int reason)
> > +{
> > +	char *message;
> > +
> > +	switch(reason) {
> > +	case CR_CHECKPOINTABLE: message = "1"; break;
> > +	case CR_DEAD: 		message = "0 (dead)"; break;
> > +	case CR_NOT_FROZEN: 	message = "0 (not frozen)"; break;
> 
> Hmmm... so a task cannot test if it itself is checkpointable, because
> it will never be frozen and will fail right there before proceeding to
> addition (future) tests ?

No, no...  :

/* Verify that task is frozen, unless it is self-checkpoint */
if (t != current && !frozen(t))
-               return 0;
+               return CR_NOT_FROZEN;

-serge
