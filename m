From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add support for the per-task sem_undo list (v2)
Date: Wed, 04 Aug 2010 17:48:00 -0400
Message-ID: <4C59E010.2090200@cs.columbia.edu>
References: <1280941345-27566-1-git-send-email-danms@us.ibm.com>	<1280941345-27566-3-git-send-email-danms@us.ibm.com>	<4C59B625.7000007@cs.columbia.edu>	<87pqxyku9j.fsf@caffeine.danplanet.com>	<4C59DBD0.1000107@cs.columbia.edu>
	<87lj8mkqhk.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87lj8mkqhk.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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



On 08/04/2010 05:38 PM, Dan Smith wrote:
> OL>  In that case, the atomic_inc for the first task should occur
> OL>  earlier - as soon as it is attached to the task _and_ inserted
> OL>  into the objhash.
>
> Okay, fair enough.  By my calculations, it belongs just a few lines
> above, in restore_sem_undo() before a successful termination.  Then we

Yep, in the last "else" clause that returns the @ulp.

> leave the refcount increment in restore_obj_sem_undo(), but only for
> second-and-later tasks.  Agreed?

Deal :)

Oren.
