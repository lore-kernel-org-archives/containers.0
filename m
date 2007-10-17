From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: current state of netns
Date: Wed, 17 Oct 2007 12:16:53 -0600
Message-ID: <m1odexehd6.fsf@ebiederm.dsl.xmission.com>
References: <4715F1FD.7010108@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4715F1FD.7010108-3ImXcnM4P+0@public.gmane.org> (Denis V. Lunev's message of "Wed, 17
	Oct 2007 15:29:01 +0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:

> Hello, Eric!
>
> I see that you quite busy and there is no reaction from Dave for your latest
> portion of netns patches. Right now, me and Pavel are working exclusively for
> mainstream.
>
> May be we could bring a torch from your hands and start to push Dave Miller even
> with IPv4 staff. 3 weeks passed, no reaction for you latest code. Looks like it
> has been missed somehow... I even have to stop my fingers every day from
> touching a generic structures like flowi :)

Short summary. 
- The merge window opened late.
- All of the netns code needs to be to Dave Miller before the merge window.
- My last round of changes were not bug fixes and were sent after Dave
  had stopped accepting feature additions for 2.6.24

Therefore after the merge window when Dave Miller is ready to queue up
more networking patches I expect progress can be made again.

I think the only thing that is happening is unfortunate timing.

I'm not really opposed to people taking my patches or something like
them cleaning them up and running with them, I just think the current
slow down bad timing.  We have achieved the hard part which is to
get the core network namespace infrastructure accepted.

On another note.  While I think using CONFIG_NET_NS is nice.  I really
only introduced it so that production kernels can avoid enabling an
experimental feature.  So far it still looks sane to me to remove
CONFIG_NET_NS when things are solid and we can remove the experimental
tag.

As for ipv4 and ipv6.  However we do that we want to very carefully
sequence the patches so that we increasingly make the network
namespace infrastructure fine grained.  Similar to make locks fine
grained.  I did that for my core network namespaces patches but that
careful ordering still needs to happen for my ipv4 patches.

Eric
