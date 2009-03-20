From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Fri, 20 Mar 2009 15:42:51 -0500
Message-ID: <20090320204251.GC14879@us.ibm.com>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>
	<49C2C686.2060806@cs.columbia.edu>
	<871vstdtn1.fsf@caffeine.danplanet.com>
	<49C2CDFA.4010907@cs.columbia.edu>
	<20090320180506.GA8380@us.ibm.com>
	<49C3F0A9.9080703@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49C3F0A9.9080703-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>
> >> Dan Smith wrote:
> >>> OL> So what happens in the following scenario:
> >>>
> >>> OL> * task A is the container init(1)
> >>> OL> * A calls fork() to create task B
> >>> OL> * B calls unshare(CLONE_NEWUTS)
> >>> OL> * B calls clone(CLONE_PARENT) to create task C
> >>>
> >>> In the previous version of the patch, I failed the checkpoint if this
> >>> was the case by making sure that all tasks in the set had the same
> >>> nsproxy.  You said in IRC that this was already done elsewhere in the
> >>> infrastructure, but now that I look I don't see that anywhere.
> >>>
> >> in cr_may_checkpoint_task():
> >>
> >>  285         /* FIXME: change this for nested containers */
> >>  286         if (task_nsproxy(t) != ctx->root_nsproxy)
> >>  287                 return -EPERM;
> >>
> >>> The check I had was in response to Daniel's comments about avoiding
> >>> the situation for the time being by making sure that all the tasks had
> >>> the same set of namespaces (i.e. the same nsproxy at the time of
> >>> checkpoint).
> >>>
> >>> OL> Two approaches to solve this are:
> >>>
> >>> OL> a) Identify, in mktree, that this was the case, and impose an
> >>> OL> order on the forks/clones to recreate the same dependency (an
> >>> OL> algorithm for this is described in [1])
> >>>
> >>> OL> b) Do it in the kernel: for each nsproxy (identified by an objref)
> >>> OL> the first task that has it will create it during restart, in or
> >>> OL> out of the kernel, and the next task will simply attach to the
> >>> OL> existing one that will be deposited in the objhash.
> >>>
> >>> I think that prior discussion led to the conclusion that simplicity
> >>> wins for the moment, but if you want to solve it now I can cook up
> >>> some changes.
> >>>
> >> If we keep the assumption, for simplicity, that all tasks share the
> >> same namespace, then the checkpoint code should check, once, how that
> >> nsproxy differs from the container's parent (except for the obvious
> >> pidns).
> > 
> > I disagree.  Whether the container had its own utsns doesn't
> > affect whether it should have a private utsns on restart.
> 
> Right, I missed that...
> 
> >> If it does differ, e.g. in uts, then the checkpoint should save the
> >> uts state _once_ - as in global data. Restart will restore the state
> >> also _once_, for the init of the container (the first task restored),
> >> _before_ it forks the rest of the tree.
> >>
> >> Otherwise, we don't get the same outcome.
> > 
> > Again I disagree.  If we were planning on never supporting nested
> > uts namespaces it woudl be fine, but what you are talking about
> > is making sure we have to break the checkpoint format later to support
> > nested namespaces.
> 
> We don't know how we are to support nested namespaces. So either we solve
> it now, or we do something that is bound to break later. The image format
> is going to change anyways as we move along.
> 
> > 
> > Rather, we should do:
> > 
> > 1. record the hostname for the container in global data.
> > 2. The restart program can decide whether to honor the global
> >    checkpoint image hostname or not.  It can either use a
> >    command line option, or check whether the recorded hostname
> >    is different from the restart host.  I prefer the former.
> 
> Sounds good.
> 
> > 3. for each task, leave an optional spot for hostname.  If
> >    there is a hostname, then it will unshare(CLONE_NEWUTS)
> >    and set its hostname before calling sys_restart() or
> >    cloning any child tasks.
> 
> Doesn't this imply a a specific format that is bound to break later ?

Not if we don't specify a format for the optional record now.
We do of course need to pick a spot for it now, and as Dan
noticed, that should be above the actual task layout so that
the info can be easily accessed by mktree.c before calling
sys_restart()...

But what the heck, like you're saying let's leave step 3 for later :)

thanks,
-serge
