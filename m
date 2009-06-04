From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup freezer: --- replacement patch 4/4 (b)
Date: Thu, 4 Jun 2009 09:04:55 -0500
Message-ID: <20090604140455.GB27550@us.ibm.com>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<89c3726813accffb7c51cd30ff93b79a4391f382.1244019829.git.matthltc@us.ibm.com>
	<20090603161840.GD7848@us.ibm.com>
	<Pine.LNX.4.64.0906031957110.19096@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0906032011470.19096@takamine.ncl.cs.columbia.edu>
	<20090604104527.GY9285@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090604104527.GY9285-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Wed, Jun 03, 2009 at 08:12:19PM -0400, Oren Laadan wrote:
> > From 3c24531980764a71705492c2dfc2cc99366784f3 Mon Sep 17 00:00:00 2001
> > From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> > Date: Wed, 3 Jun 2009 19:31:21 -0400
> > Subject: [PATCH] c/r: use CHECKPOINTING state for hierarchy's cgroup freezer
> > 
> > Set state of freezer cgroup of checkpointed task hierarchy to
> > "CHECKPOINTING" during a checkpoint, to ensure that tasks cannot
> > be thawed while at it.
> >
> > get_container() grabs a reference to the root task's freezer cgroup.
> > Then in may_checkpoint_task() each it verifies that all tasks belong
> > to the same freezer group.
> 
> Ugh, I really don't like grabbing this reference. It may be necessary
> though -- I need to think about it more.

This was my first thought too.  The rest of Oren's algorithm seems
sounds, but this just seems like an unneeded step.  If we prevent
tasks from being moved out of the freezer container, and from
being thawed before checkpoint is done, then why do we need to
get the container?

-serge
