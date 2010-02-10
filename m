From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC PATCH] c/r: fixed false complaint on "unlinked" pipes, socket,
	etc
Date: Wed, 10 Feb 2010 11:47:38 -0500
Message-ID: <4B72E32A.20802@cs.columbia.edu>
References: <1265399854-26534-1-git-send-email-orenl@cs.columbia.edu>
	<87tytpgitd.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tytpgitd.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


Heh ... following the discussion on the IRC, I actually prefer
a solution that will push tests that are not filesystm-agnostic
to the filesystem-specific .checkpoint method.  Then also put
it in the generic .checkpoint method to catch the "default" case.

I think it's cleaner and does not introduce needless noise in
the kernel.

FWIW, not only for the d_unlinked() test, but also for the locks
issue;  even though locks are supposed to be VFS generic and not
depend on specific filesystem, apparently they do. (Either that
or fix find_locks_with_owner() in a generic way).

Oren.


Dan Smith wrote:
> OL> Comments ?
> 
> Works for me (although the issue remains that find_locks_with_owner()
> thinks there are locks present on a socket).
> 
