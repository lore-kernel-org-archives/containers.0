From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup: alloc_css_id() increments hierarchy depth
Date: Mon, 31 May 2010 09:01:17 +0800
Message-ID: <4C030A5D.2000700__25281.6924629316$1275267662$gmane$org@cn.fujitsu.com>
References: <1275059781-9831-1-git-send-email-gthelen@google.com>
	<AANLkTino0k-wok9kXLmWTyr40dZKSCnR0Uk41uxAj5k1@mail.gmail.com>
	<20100531084529.2b1f0d25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100531085431.a45b30b9.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTilNrrsNluDBUlXCsZMz7d_-VHn31Ogvkw9AUPnE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTilNrrsNluDBUlXCsZMz7d_-VHn31Ogvkw9AUPnE-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

>>>> On Fri, May 28, 2010 at 8:16 AM, Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>>>> Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>>> Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>>>
>>>> Good catch, thanks.
>>>>
>>> Nice Catch.
>>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
>>>
>>> But, who breaks this ? Do we need backport this against old kernels ?
>>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=fae9c791703606636c1220e47f6690660042ce7f
>>
>> Hmm. this one. and 2.6.34 needs this patch. Greg, could you post this to
>> stable-2.6.34 tree ?
> 
> Given that I forgot to include "Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>" in the
> patch, I assume the best way to get this patch into -stable is for me
> to email the commit id to stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org once the patch is accepted
> into Linus' tree.  Let me know if there is a better way.
> 

I think Andrew will mark it and send it to stable.
