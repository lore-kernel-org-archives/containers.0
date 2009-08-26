From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] Store socket owner with buffers
Date: Wed, 26 Aug 2009 14:44:28 -0700
Message-ID: <873a7eqmgz.fsf@caffeine.danplanet.com>
References: <1251133918-8117-1-git-send-email-danms@us.ibm.com>
	<1251133918-8117-4-git-send-email-danms@us.ibm.com>
	<4A9377B8.1010400@librato.com> <87bpm2qy6q.fsf@caffeine.danplanet.com>
	<4A959C4A.6050803@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A959C4A.6050803-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren Laadan's message of "Wed\,
	26 Aug 2009 16\:34\:18 -0400")
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

OL> The concern I raised above is about manipulated checkpoint data
OL> that attempts to make a connected socket to have data from another
OL> (not peer) socket.

OL> Then I realized that since you use the usual send functions, this
OL> _should_ be covered by the existing checks in the unix networking
OL> code itself.

OL> So I wondered if it's worth a comment somewhere, just to let
OL> readers of the code know that this scenario was considered. (Of
OL> course, after verifying that my statement is indeed correct :)

Correct, the checks in sendmsg() and recvmsg() should properly protect
us from sending buffers to sockets that aren't supposed to receive
them (i.e. ones that are connected elsewhere).

OL> Regarding DEAD sockets - the may still be needed if they are the
OL> source of skb's, no ?  (of course, whatever they had in receive
OL> buffer should have been discarded).

Right, that's what I'm saying I've updated since this post.

OL> Maybe I need to read the code again. My impression was that when
OL> you checkpoint socket A, and you need B, then you call
OL> checkpoint_obj() on B, from within the processing of
OL> checkpoint_obj(A).

...correct.

OL> restart-obj() - it gets called automatically when ckpt_read_obj()
OL> sees an object of type CKPT_HDR_OBJREF; there is never an explicit
OL> call.  That's why I assumed that it will be called for A and then,
OL> while processing A, it will be called for B, since A will read in
OL> data and the ckpt_obj_read() will see the shared object.

Correct, it's the circular dependency between the sockets and their
buffers that the problem arises.

OL> So I guess it works because you explicitly ckpt_obj_insert() the
OL> sockets to the objhash; Then later restart_obj() inserts them (or
OL> something) again, but the second instance is never actually found
OL> in a lookup/fetch - the first instance is always returned.

I think we've resolved this on IRC just now, or at least, are close to
it :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
