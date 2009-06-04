From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup freezer: --- replacement patch 4/4 (b)
Date: Thu, 4 Jun 2009 09:52:41 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0906040946280.25421@takamine.ncl.cs.columbia.edu>
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

On Thu, 4 Jun 2009, Matt Helsley wrote:

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
> 
> > 
> > In particular, the root task is also tested, such that if the root
> > tasks changes its freezer cgroups before it moves to "CHECKPOINTING",
> > it will be notived and an error returned.
> 
> Tasks in a CHECKPOINTING cgroup are frozen and frozen tasks cannot move.
> See freezer_can_attach(). This does rather complicate self-checkpoint
> though! See my reply to your follow-on patches..

We grab the reference of the css _before_ the group is CHECKPOINTING.
Between that point and calling cgroup_freezer_begin_checkpoint(), the
root task may still be thawed and/or change groups. In this comment I
argue that the code is safe, since the test in may_checkpoint_task()
that compares a task's css to the "container's" css will return an
error in this case.

As for the self-checkpoint you are right. Probably aneasiest way is
require isn't kept the self-checkpointer not in the freezer cgroup, 
and skip the relevant tests for it.

Oren.

> 
> Cheers,
> 	-Matt Helsley
> 
> 
