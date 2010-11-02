From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH][cr]: Mark ghost tasks as detached earlier
Date: Tue, 2 Nov 2010 08:57:04 -0700
Message-ID: <20101102155704.GA7054@us.ibm.com>
References: <20101030070151.GA4850@us.ibm.com>
	<4CCF00BA.2030500@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4CCF00BA.2030500-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| 
| 
| On 10/30/2010 03:01 AM, Sukadev Bhattiprolu wrote:
| Let me see if I get this correctly: first, the container-init calls
| wait(), then goes to sleep because children aren't ready, then the
| ghost changes state to detached and exits, but the container-init is
| not notified so not woken up. Is that correct ?
| 
| If so, then the problem is that changing from non-detached to detached
| is racy. Therefore, just doing it earlier may still not be correct,
| because the race (theoretically) still exists. It just makes it less
| likely to occur.

True. I was trying to understand if there was a need to mark it detached
that late.

| 
| If this analysis is correct, then I can think of two options:
| 
| 1) when creating the ghost tasks, create them as detached from
| user-space, and they won't need to be waited-for not become
| detached.

Yes and if we remove the assignment to ->exit_signal in do_ghost_task(),
we should be fine. This would be a better option than sending a signal
to the parent.

Sukadev
