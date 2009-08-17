From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: add checkpoint/restore methods to struct
	proto_ops
Date: Mon, 17 Aug 2009 17:41:34 -0400
Message-ID: <4A89CE8E.6070604@librato.com>
References: <1250539931-12951-1-git-send-email-orenl@librato.com>	<1250539931-12951-3-git-send-email-orenl@librato.com>	<87r5va5g1g.fsf@caffeine.danplanet.com>
	<4A89C681.7030307@librato.com>
	<874os65e6q.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874os65e6q.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> OL> I figured that if we called a sock_create() for a type that isn't
> OL> supported by checkpoint/restart, we will catch it down the code by
> OL> testing sock->ops->restore. That way, I don't need to "teach"
> OL> sock_file_restore() about socket types and protocols.
> 
> Okay, yeah I suppose so.  In that case, why even have the check?
> certainly sock_create() checks that somewhere down the line, right?

Hmm... true.  I was distracted by the test in socket() syscalls.
Will remove the test.

Oren.


> 
> OL> Do you see any reason why it should work ?  The only difference
> OL> (for afunix) between dgram and seqpacket is the requirement that
> OL> the socket be connected - see unix_seqpacket_sendmsg().
> 
> Not for AF_UNIX, no.  I just said I hadn't tested it :)
> 
