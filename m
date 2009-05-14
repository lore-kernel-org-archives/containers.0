From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Remove READ_IMPLIES_EXEC during restart
Date: Thu, 14 May 2009 12:10:53 -0400
Message-ID: <4A0C428D.6050706@cs.columbia.edu>
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


Dan,

Now after the rework of the patchset, it's probably a good time
to add support for this.

I'm unsure if the personality can affect other restore actions
that take place elsewhere If so, probably the correct way is to:

1) restore personality as part of the task (in the beginning)

2) temporarily change it around those places where we want the
"native" personality, e.g. the call to do_mmap_pgoff(), or shmat(),

(The reason not to put it around the entire restore_mm() is to
be safe in case a personality makes a difference when you open
files. This way we isolate the effect of changing personality).

Any thoughts ?

Oren.

Dan Smith wrote:
> OL> In fact, if elsewhere we restore current->personality of the task,
> OL> then unless we move it to cr_read_mm(), it will overwrite it :(
> 
> Should we move it or just remove RIE before we start the restart and
> let the task regain the flag if it had it before?
> 
