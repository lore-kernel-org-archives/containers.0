From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] Add a choosepid() syscall as a simpler alternative to
	clone_with_pids()
Date: Mon, 02 Nov 2009 16:02:13 -0500
Message-ID: <4AEF48D5.7070201@librato.com>
References: <1257194293-12099-1-git-send-email-danms@us.ibm.com>	<4AEF45BB.4080609@librato.com>
	<87ws281weu.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ws281weu.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> OL> 2. What do you expect to gain by splitting the work into two
> OL> separate system calls ?
> 
> Simplicity and avoidance of the arch-specific issues, which seems to
> be what hung us up on $NEW_CLONE_NAME_O'_THE_DAY.

Adding a syscall, a field on current, and a set of rules how those
are managed, is not simpler IMHO.

Some objections in the past argued that this may cause unexpected
behavior to the user or tracing/debugging tools. I'm not sure to
what extend this still is, but those will come again.

Finally, I disagree with the prognosis: the arch-specific issue that
hung the today's-clone was introducing *a* new clone such that its
args are passed incorrectly from a _technical_ point of view.

The thing is, that we need a new clone anyway (if not only for the
flags), and that new clone will have to get its args correctly.

On the other hand, Suka fixed his arch-dependent part and we're left
with agreeing on a new plausible name ...

That said, if you manage to get that to mainline, I'll be fine with
it (and then someone later will need to extend clone somehow). I only
think that chances are slim.

Oren.
