From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7][v2] Define clone_with_pids syscall
Date: Thu, 28 May 2009 12:47:08 -0500
Message-ID: <20090528174708.GA2236@hallyn.com>
References: <20090528043748.GA16522@us.ibm.com>
	<20090528043945.GG16522@us.ibm.com>
	<4A1EA73F.1080802@cs.columbia.edu>
	<20090528151444.GA17772@us.ibm.com>
	<20090528170103.GA26183@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090528170103.GA26183-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> | Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> | > In general, can a task figure out it's depth in the pid-ns hierarchy ?
> | 
> | In user-space?  No.
> 
> Not from any existing user interface. But hypothetically or in the
> long-term can/should sys_checkpoint() not be able to figure out if
> it has to C/R say a bash shell that has nested pid namespaces ?
> 
> I am guessing sys_checkpoint() can know if its crossing a pid-ns
> boundary by comparing or computing the max nesting level while
> walking a process tree. i.e if task_pid(task)->pid_ns->level is
> not the same for all process in the tree, then we have nested
> namespaces. How to checkpoint/restart such a tree is of course a
> bigger challenge.
> 
> But if sys_checkpoint() can find the max nesting level ? If that
> info is saved in checkpoint image, clone_with_pids() could
> use that info - no ?

If a container at pidns level 2, with 1 more pidns underneath it,
is checkpointed, then the checkpoint image should only reflect
the base and child pidns.  The two ancestor pidns levels should
not be there.

-serge
