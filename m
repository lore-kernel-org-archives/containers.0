From: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Thu, 7 Aug 2014 09:28:23 -0400
Message-ID: <20140807132823.GB32722@thunk.org>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<20140806144643.45e5dab8@canb.auug.org.au>
	<87lhr2tcyx.fsf@x220.int.ebiederm.org>
	<20140806160608.218b6944@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140806160608.218b6944-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Aug 06, 2014 at 04:06:08PM +1000, Stephen Rothwell wrote:
> 
> Yes, that is what confused my, sorry, since that commit and the ones
> following are new commits but unchanged patches.

As a suggestion, in addition to trying to count the number of commits
that are new, or with the same patch id's, etc., is to provide the
diff stats between the last version of the branch that landed in
linux-next before the merge window opened, and the branch head that
was requested for Linus to pull?

This will get tripped up by those poeple who send multiple pull
requests which are subsets of the branch that is tracked by linux-next
(for example, to arrange the order of merging to minimize conflicts),
so like all things, it's not perfect, but it might be useful
additional indicator, at least in the early days of the merge window.

Also, if you could report the commit id of the branch head before the
merge window opened, then other people (including Linus) can do their
own investigation and draw their own conclusions.

Cheers,

						- Ted

P.S.  If there was some way this could be automated so that a 'bot
sends out a report for every single pull request, then it minimizes
the "J'accuse!" aspect, since the report is being done for all pull
requests, and everyone knows that robots makes mistakes.  :-)
