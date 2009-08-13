From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] Set socket flags on restore using sock_setsockopt()
	where possible
Date: Thu, 13 Aug 2009 12:55:46 -0700
Message-ID: <87r5vfpjy5.fsf@caffeine.danplanet.com>
References: <1250191750-3864-1-git-send-email-danms@us.ibm.com>
	<1250191750-3864-2-git-send-email-danms@us.ibm.com>
	<4A846D0E.90607@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A846D0E.90607-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren Laadan's message of "Thu\,
	13 Aug 2009 15\:44\:14 -0400")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

OL> When you add support to new socket due to connect() that were not
OL> yet accept()ed from the listening socket - there will be a case of
OL> a sock without sock->sk_socket.

OL> This probably means that we want the test for sock->sk_socket to
OL> remain as is (and a similar one in sock_rst_flags above)

Okay, but we've got a lot of other places above that where we assume
sock->sk_socket is valid, so the thinking here was that when we have a
real reason to handle that case, I'd fix all the other cases as well.

However, I shouldn't have done that in the middle of this patch anyway.

OL> Super nit: perhaps s/rst/restore/ ?  Besides agreeing with current
OL> practice, it may dodge a related rant from Linux :o
    
Sure.

I'll re-send with the rename and without the sock->sk_socket and then
follow up with a fix for the other cases in a later patch.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
