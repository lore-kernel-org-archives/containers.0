From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Remove READ_IMPLIES_EXEC during restart
Date: Tue, 14 Apr 2009 10:40:00 -0400
Message-ID: <49E4A040.6030307@cs.columbia.edu>
References: <1239039694-22332-1-git-send-email-danms@us.ibm.com>	<20090406181748.GA24751@us.ibm.com>
	<49E42646.4040703@cs.columbia.edu>	<49E4278C.3060500@cs.columbia.edu>
	<87y6u3cqd0.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87y6u3cqd0.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Probably best is to (a) save and restore the task's personality
(regardless), and (b) in do_restart() (re)set the personality as
we wish, with a clear comment about why and the fact that the
'real' personality is restore later.

Oren.

Dan Smith wrote:
> OL> In fact, if elsewhere we restore current->personality of the task,
> OL> then unless we move it to cr_read_mm(), it will overwrite it :(
> 
> Should we move it or just remove RIE before we start the restart and
> let the task regain the flag if it had it before?
> 
