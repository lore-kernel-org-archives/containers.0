From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] Add a cleanup routine for objhash socket objects
Date: Tue, 15 Sep 2009 17:51:14 -0400
Message-ID: <4AB00C52.9040604@librato.com>
References: <1253033531-6764-1-git-send-email-danms@us.ibm.com>	<1253033531-6764-3-git-send-email-danms@us.ibm.com>	<20090915202118.GC10922@count0.beaverton.ibm.com>
	<87eiq8j653.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87eiq8j653.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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


Dan Smith wrote:
> MH> Does it make sense to add a generic (cleanup) operation when only
> MH> one object type will make use of it?
> 
> In general, I agree with you, but I don't think this is an obscure
> case.
> 
> MH> If we add generic mechanisms for things without having multiple
> MH> uses then are we just obfuscating the special cases of the code?
> 
> MH> As an alternative, would it work if we kept a list of unattached
> MH> sockets in the ckpt context, removed them whenever they become
> MH> attached, and then use the generic "end of restart" deferqueue to
> MH> cleanup unattached sockets?
> 
> It would be more code to do it that way, it would inflate the context
> with another list, and would cause us to iterate these objects more
> than we already do.

I agree with Dan.

So the problem happens because the ref_drop() method cannot tell
whether it's called from restore_obj() to drop an extra reference, or
from obj_hash_clear(), to drop the last reference (from the objhash).

[Actually, the way it is now there is still a leak: if the call to
obj_new() from restore_obj() fails, then the subsequent ref_drop()
*is* intended to drop the last reference, but it will not].

I think that the root of this is that ref_drop() doesn't have enough
information about what's going on. Dan's patch suggested to solve it
by adding a specialized ref_drop() - a cleanup method.

However, now I think that it's probably better to modify the prototype
of ref_drop() to be, e.g.:   void ref_drop(void *ptr, int clean), so
it can be smarter.

>>> +	if (sk->sk_socket && !sk->sk_socket->file) {
> 
> MH> Would it make sense to add a little helper to explain this?
> 
> MH> 	if (!is_sk_attached(sk)) {
> 
> Does that make it more clear?  What's the socket attached to?  Another
> socket?  I could add more words to the helper to make it more obvious
> but IMHO, it's clearer to have it spelled out.
> 

Perhaps a comment to spell it out :)

Oren.
