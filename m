From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: add checkpoint/restore methods to struct
	proto_ops
Date: Mon, 17 Aug 2009 13:41:47 -0700
Message-ID: <87r5va5g1g.fsf@caffeine.danplanet.com>
References: <1250539931-12951-1-git-send-email-orenl@librato.com>
	<1250539931-12951-3-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250539931-12951-3-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren
	Laadan's message of "Mon\, 17 Aug 2009 16\:12\:10 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

OL> -	if ((h->sock.type != SOCK_DGRAM) && (h->sock.type != SOCK_STREAM)) {
OL> -		ckpt_debug("Socket type %i not supported", h->sock.type);
OL> +	if (h->sock.type & ~SOCK_TYPE_MASK)
OL>  		return ERR_PTR(-EINVAL);
OL> -	}

The idea here was to prevent a rewritten checkpoint stream from
causing us to call sock_create() with a type that we don't support.
Checking the mask may be functionally equivalent right now, but may
open the door for an interesting failure later, no?

OL>  static const struct proto_ops unix_seqpacket_ops = {
OL> @@ -565,6 +569,8 @@ static const struct proto_ops unix_seqpacket_ops = {
OL>  	.recvmsg =	unix_dgram_recvmsg,
OL>  	.mmap =		sock_no_mmap,
OL>  	.sendpage =	sock_no_sendpage,
OL> +	.checkpoint =	sock_unix_checkpoint,
OL> +	.restore =	sock_unix_restore,
OL>  };

Have you tested SEQPACKET?  I haven't.

Other than that, it looks fine to me and fails the same set of tests
that the current tree does.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
