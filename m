From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7][v2] Define clone_with_pids syscall
Date: Fri, 29 May 2009 16:01:50 -0400
Message-ID: <4A203F2E.1060807@cs.columbia.edu>
References: <20090528043748.GA16522@us.ibm.com>
	<20090528043945.GG16522@us.ibm.com>
	<4A1EA73F.1080802@cs.columbia.edu>
	<20090528173019.GB26183@us.ibm.com>
	<4A1F228C.2020201@cs.columbia.edu>
	<20090529030558.GA2548@us.ibm.com>
	<4A1F72A1.4070103@cs.columbia.edu>
	<20090529054645.GA3344@us.ibm.com>
	<4A1F78AF.6030404@cs.columbia.edu>
	<20090529170616.GA12597@us.ibm.com>
	<20090529193416.GB12597@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090529193416.GB12597-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Sukadev Bhattiprolu wrote:
> Sukadev Bhattiprolu [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
> | Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> 
> I am not sure what the semantics should be for this case:
> 
> 	- checkpoint a process that is in level-3 pid namespace
> 	- restart in a level-2 or level-1 pid namespace
> 

Meaning: a container root was at level-3, so tasks in the container
were level-3 through level-(3+N), where N is the in-container depth
so to speak. Then it was restarted such that the base became level-2
or level-1.

I think we already covered this.

> clone_with_pids() will fail now since number of pids specified would
> be 4 but kernel expects only 2 or 3. mktree/restart program cannot
> figure out current nesting to trim the target-pids.
> 
> Should we remove the check of user-pids exceeding the current nesting
> level and simply ignore the pids from the older namespaces ?

It seems to me that the current behavior is correct: I can't think
of a case where trimming (silently) would make sense, or where
a program would end up giving more pids that it's nesting level.

Oren.
