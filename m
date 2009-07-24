From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] c/r: [signal 3/3] pending signals (private, shared)
Date: Fri, 24 Jul 2009 08:59:39 -0400
Message-ID: <4A69B03B.2010806@librato.com>
References: <1248360514-20710-1-git-send-email-orenl@librato.com>
	<1248360514-20710-3-git-send-email-orenl@librato.com>
	<20090724123629.GH11101@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724123629.GH11101-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> Hi Oren,
> 
> On 23/07/09 10:48 -0400, Oren Laadan wrote:
>> This patch adds checkpoint and restart of pending signals queues:
>> struct sigpending, both per-task t->sigpending and shared (per-
>> thread-group) t->signal->shared_sigpending.
>>
>> To checkpoint pending signals (private/shared) we first detach the
>> signal queue (and copy the mask) to a separate struct sigpending.
>> This separate structure can be iterated through without locking.
>>
>> Once the state is saved, we re-attaches (prepends) the original signal
>> queue back to the original struct sigpending.
>>
>> Signals that arrive(d) in the meantime will be suitably queued after
>> these (for real-time signals). Repeated non-realtime signals will not
>> be queued because they will already be marked in the pending mask,
>> that remains as is. This is the expected behavior of non-realtime
>> signals.
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>> ---
>>  checkpoint/signal.c            |  255 +++++++++++++++++++++++++++++++++++++++-
>>  include/linux/checkpoint_hdr.h |   23 ++++
>>  2 files changed, 277 insertions(+), 1 deletions(-)
>>
>> diff --git a/checkpoint/signal.c b/checkpoint/signal.c
>> index b3f1d3e..940cc4a 100644
>> --- a/checkpoint/signal.c
>> +++ b/checkpoint/signal.c
> 
> [...]
> 
>> +
>> +static int restore_sigpending(struct ckpt_ctx *ctx, struct sigpending *pending)
>> +{
>> +	struct ckpt_hdr_sigpending *h;
>> +	struct ckpt_hdr_siginfo *si;
>> +	struct sigqueue *q, *n;
>> +	int ret = 0;
>> +
>> +	h = ckpt_read_buf_type(ctx, 0, CKPT_HDR_SIGPENDING);
>> +	if (IS_ERR(h))
>> +		return PTR_ERR(h);
>> +
>> +	INIT_LIST_HEAD(&pending->list);
>> +	load_sigset(&pending->signal, &h->signal);
>> +
>> +	si = h->siginfo;
>> +	while (h->nr_pending--) {
>> +		q = sigqueue_alloc();
> 
> This introduces a memory leak, since collect_signal() won't free q. Better to
> use __sigqueue_alloc() here, or clear the SIGQUEUE_PREALLOC flag.
> 

You're totally right.

I thought I needed it because of sigqueue_free() below, but in fact
it should be __sigqueue_alloc() and __sigqueue_free().

Thanks,

Oren.

> Thanks,
> 
> Louis
> 
>> +		if (!q) {
>> +			ret = -ENOMEM;
>> +			break;
>> +		}
>> +
>> +		ret = load_siginfo(&q->info, si++);
>> +		if (ret < 0) {
>> +			sigqueue_free(q);
>> +			break;
>> +		}
>> +
>> +		list_add_tail(&pending->list, &q->list);
>> +	}
>> +
>> +	if (ret < 0) {
>> +		list_for_each_entry_safe(q, n, &pending->list, list) {
>> +			list_del_init(&q->list);
>> +			sigqueue_free(q);
>> +		}
>> +	}
>> +
>> +	ckpt_hdr_put(ctx, h);
>> +	return ret;
>> +}
>> +
> 
> [...]
> 
