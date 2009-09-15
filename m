From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add a cleanup routine for objhash socket objects
Date: Tue, 15 Sep 2009 13:38:00 -0700
Message-ID: <87eiq8j653.fsf@caffeine.danplanet.com>
References: <1253033531-6764-1-git-send-email-danms@us.ibm.com>
	<1253033531-6764-3-git-send-email-danms@us.ibm.com>
	<20090915202118.GC10922@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090915202118.GC10922-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org> (Matt Helsley's
	message of "Tue\, 15 Sep 2009 13\:21\:18 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

MH> Does it make sense to add a generic (cleanup) operation when only
MH> one object type will make use of it?

In general, I agree with you, but I don't think this is an obscure
case.

MH> If we add generic mechanisms for things without having multiple
MH> uses then are we just obfuscating the special cases of the code?

MH> As an alternative, would it work if we kept a list of unattached
MH> sockets in the ckpt context, removed them whenever they become
MH> attached, and then use the generic "end of restart" deferqueue to
MH> cleanup unattached sockets?

It would be more code to do it that way, it would inflate the context
with another list, and would cause us to iterate these objects more
than we already do.

>> +	if (sk->sk_socket && !sk->sk_socket->file) {

MH> Would it make sense to add a little helper to explain this?

MH> 	if (!is_sk_attached(sk)) {

Does that make it more clear?  What's the socket attached to?  Another
socket?  I could add more words to the helper to make it more obvious
but IMHO, it's clearer to have it spelled out.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
