From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support
Date: Mon, 08 Jun 2009 02:15:08 -0400
Message-ID: <4A2CAC6C.2000700@cs.columbia.edu>
References: <1244042305-7770-1-git-send-email-danms@us.ibm.com>
	<20090604151923.GA29519@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090604151923.GA29519-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
>> has been tested with a single and multiple processes, and with data inflight
>> at the time of checkpoint.  It supports both socketpair()s and path-based
>> sockets.
>>
>> I have an almost-working AF_INET follow-on to this which I can submit after
>> this is reviewed and tweaked into acceptance.
>>
>> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

[...]

> 
>> +static int sock_un_checkpoint(struct ckpt_ctx *ctx,
>> +			      struct sock *sock,
>> +			      struct ckpt_hdr_socket *h)
>> +{
>> +	struct unix_sock *sk = unix_sk(sock);
>> +	struct unix_sock *pr = unix_sk(sk->peer);
>> +	int new;
>> +	int ret;
>> +
>> +	h->un.this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
>> +	if (h->un.this < 0)
>> +		goto out;
>> +
>> +	if (sk->peer)
>> +		h->un.peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
>> +	else
>> +		h->un.peer = 0;
>> +
>> +	if (h->un.peer < 0) {
>> +		ret = h->un.peer;
>> +		goto out;
>> +	}
>> +
>> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
>> + out:
>> +	return ret;
>> +}
> 
> in the CHECKPOINT_SUBTREE case do we want to try to ensure that sk->peer
> is owned by another checkpointed task?

What exactly would you like to enforce - that it is "in-use"
by a checkpointed task, or that is isn't "in-use" outside ?

It probably makes sense to verify that the socket is "in-use"
by at least one task in the checkpointed set (heh... I expect
kerlab guys to argue against forcing this...), and perhaps
issue a warning ?

(Which is not a bad idea - add a ckpt_write_warning() function
that will write a warning in the image, but won't abort the
entire checkpoint).

It isn't easy to verify the "in-use" property - what if task
A transfers a file using unix-domain sockets to task B (both
in the set), and A closed the file descriptor.... so we can
know it's in transit, but we don't know who will receive the
file eventually.

(Ahh.. of course .. issue a warning :)

It makes less sense to verify the socket is _not_ in use
_outside_ the checkpointed set - and it can be expensive to
do so; After all, there is a whole-container option if you
need that guarantee.

If we are to add such checks, or warnings, it's clearly not
a high priority now (and given akpm's comment ...).

Oren.
