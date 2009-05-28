From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7][v2] Define clone_with_pids syscall
Date: Thu, 28 May 2009 19:45:17 -0400
Message-ID: <4A1F220D.80205@cs.columbia.edu>
References: <20090528043748.GA16522@us.ibm.com>	<20090528043945.GG16522@us.ibm.com>	<4A1EA73F.1080802@cs.columbia.edu>	<20090528151444.GA17772@us.ibm.com>	<20090528170103.GA26183@us.ibm.com>	<20090528174708.GA2236@hallyn.com>
	<20090528180057.GA27191@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090528180057.GA27191-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Serge E. Hallyn [serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org] wrote:
> | 
> | If a container at pidns level 2, with 1 more pidns underneath it,
> | is checkpointed, then the checkpoint image should only reflect
> | the base and child pidns.  The two ancestor pidns levels should
> | not be there.
> 
> Agree. I meant to say that we would need to specify more than 2
> pids when checkpoint/restarting apps with deeply nested namespaces
> if any :-)

Just like the checkpoint image should only reflect the nesting
from some base down, clone_with_pid() should reflect nesting
from some base down.

(Hmm.. ignore this if it is what you meant already ...)

> 
> Specifying bottom-up may solve the problem I guess.

Perhaps bottom-up is a misleading: I don't care about the order...
I meant that a N size array should affect the last N levels of
the hierarchy (if it is deeper than N).

Oren.
