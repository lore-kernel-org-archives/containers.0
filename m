From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Kernel oops on 2.6.38 on destroying a container
Date: Wed, 07 Sep 2011 23:40:01 +0200
Message-ID: <4E67E4B1.6050101@free.fr>
References: <88648D2CBB3136EB9A6EFE7B@nimrod.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <88648D2CBB3136EB9A6EFE7B-PdXK6nMiYlGE+EvaaNYduQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 09/07/2011 09:21 PM, Alex Bligh wrote:
> We are seeing oops like this from 2.6.38-11 Ubuntu on deleting containers.
>
> This one was somewhat complicated (but we grabbed the oops).
> The trace below happened destroying a container. I believe the iptables
> rules including conntrack rules would have been deleted immediately
> before the container process exited; devices evrrXXXX and evrlXXXX
> are veth pairs that would also just have been destroyed)
>
> My colleague can replicate this on different hardware (his desktop) using
>   lxc-create -n foo
>   lxc-start -n foo
> Send a ^C - entire system crashes. No exciting container activity
> at all.
>
> I haven't seen this on 2.6.32. Any ideas what it might be? We are
> trying to get this to work on a slightly more modern kernel with longterm
> support, so "fixed in Linus's current tree" is not quite what I need!

IMO you should fill a bug at :

https://bugs.launchpad.net/ubuntu/+source/linux/

and/or ask kernel-team-nLRlyDuq1AZFpShjVBNYrg@public.gmane.org

They will be able to identify the fix in the mainstream, backport it and
release a new kernel.

An oops is critical enough to have them to pay attention to this problem.

Hope that helps

  -- Daniel
