From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup debug seems dead?
Date: Tue, 19 Oct 2010 18:42:02 -0700
Message-ID: <AANLkTinjzW38s=WJD3b9kQppbKCrHLaSunpo0wS0nwiU@mail.gmail.com>
References: <20101019085139.1ccb22bc@nehalam> <4CBE41AE.2020101@cn.fujitsu.com>
	<20101019181245.7902113a@nehalam>
	<AANLkTinH2t41jvGG_D9qAdN5MvRHg7aR+J2mKV5ifMfC@mail.gmail.com>
	<20101019183705.04a11816@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101019183705.04a11816@nehalam>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 19, 2010 at 6:37 PM, Stephen Hemminger
<shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> wrote:
>
> That would work but doesn't because the following is missing
> in cgroup_subsys.h!
>
> #ifdef CONFIG_CGROUP_DEBUG
> SUBSYS(debug)
> #endif
>
> /* */
>

I see that fragment at line 16 in cgroup_subsys.h (see e.g.
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=include/linux/cgroup_subsys.h;h=ccefff02b6cb005123c4b904e06116cb3a850474;hb=HEAD)

Which kernel tree are you looking at?

Paul
