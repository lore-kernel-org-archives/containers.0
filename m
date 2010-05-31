From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: alloc_css_id() increments hierarchy depth
Date: Sun, 30 May 2010 17:44:34 -0700
Message-ID: <AANLkTilNrrsNluDBUlXCsZMz7d_-VHn31Ogvkw9AUPnE__1257.96978031776$1275266788$gmane$org@mail.gmail.com>
References: <1275059781-9831-1-git-send-email-gthelen@google.com>
	<AANLkTino0k-wok9kXLmWTyr40dZKSCnR0Uk41uxAj5k1@mail.gmail.com>
	<20100531084529.2b1f0d25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100531085431.a45b30b9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100531085431.a45b30b9.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, May 30, 2010 at 4:54 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> On Mon, 31 May 2010 08:45:29 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>
>> On Fri, 28 May 2010 15:25:08 -0700
>> Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>
>> > On Fri, May 28, 2010 at 8:16 AM, Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> > >
>> > > Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> >
>> > Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> >
>> > Good catch, thanks.
>> >
>> Nice Catch.
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
>>
>> But, who breaks this ? Do we need backport this against old kernels ?
>>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=fae9c791703606636c1220e47f6690660042ce7f
>
> Hmm. this one. and 2.6.34 needs this patch. Greg, could you post this to
> stable-2.6.34 tree ?

Given that I forgot to include "Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>" in the
patch, I assume the best way to get this patch into -stable is for me
to email the commit id to stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org once the patch is accepted
into Linus' tree.  Let me know if there is a better way.

--
Greg
