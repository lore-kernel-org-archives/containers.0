From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/6] /proc/pid/checkpointable
Date: Wed, 18 Mar 2009 12:18:40 -0500
Message-ID: <20090318171840.GA29523@us.ibm.com>
References: <20090317062754.GA2377@us.ibm.com>
	<20090317063940.GF2377@us.ibm.com>
	<49C0B6FF.5030104@cs.columbia.edu>
	<20090318135953.GE22636@us.ibm.com>
	<49C1201A.3050604@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49C1201A.3050604-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>
> >> Sukadev Bhattiprolu wrote:
> >>> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> >>> Date: Fri, 13 Mar 2009 17:25:42 -0700
> >>> Subject: [PATCH 5/6] Define and use proc_pid_checkpointable()
> >>>
> >>> Create a proc file, /proc/pid/checkpointable, which shows '1' if
> >>> task is checkpointable and '0' if it is not.
> >>>
> >>> To determine whether a task is checkpointable, the handler for this
> >>> new proc file, shares the same code with sys_checkpoint().
> > 
> > Hey Oren,
> > 
> > 3 counter-points:
> > 
> >> I still don't understand why we would like to do it this way.
> >>
> >> First, it makes little sense to do it per-task, because we are supposed
> >> to checkpoint an entire container.
> > 
> > Yes we need per-container info too.  Actually, per-checkpoint-job-init,
> > so if we send pids in for that, it should return false if we send in the
> > pid of a task which isn't a proper checkpoint-job-init.
> > 
> > But we also want the info per-task, for debugging info.
> > 
> 
> My suggestions works for this two: we add a flag CR_CTX_DRYRUN; a task
> can ask to checkpoint itself, or another task, with CR_CTX_DRYRUN and
> the checkpoint code runs without actual effect. (If we don't want to
> expose the actual flag to userspace, then we simply use it in an
> implementation of a /proc/PID/checkpointable operation).

Hmm, so if we pass in CR_CTX_DRYRUN, then the fd can point to a file
wherein to store a text represenation of the reason?

Dave will probably hate it, but it could be worse...

-serge
