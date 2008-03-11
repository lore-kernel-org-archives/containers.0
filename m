From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
Date: Tue, 11 Mar 2008 17:32:25 +0900
Message-ID: <20080311173225.937935eb.kamezawa.hiroyu@jp.fujitsu.com>
References: <47D16004.7050204@openvz.org>
	<20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>
	<47D63FBC.1010805@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47D63FBC.1010805-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 11 Mar 2008 11:15:56 +0300
Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> > Hmm? seems strange.
> > 
> > IMO, a parent's usage is just sum of all childs'.
> > And, historically, memory overcommit is done agaist "memory usage + swap".
> > 
> > How about this ?
> >     <mem_counter_top, swap_counter_top>
> > 	<mem_counter_sub, swap_counter_sub>
> > 	<mem_counter_sub, swap_counter_sub>
> > 	<mem_counter_sub, swap_counter_sub>
> > 
> >    mem_counter_top.usage == sum of all mem_coutner_sub.usage
> >    swap_counter_sub.usage = sum of all swap_counter_sub.usage
> 
> I've misprinted in y tree, sorry.
> The correct hierarchy as I see it is
> 
thank you.

> <mem_couter_0>
>  + -- <swap_counter_0>
>  + -- <mem_counter_1>
>  |     + -- <swap_counter_1>
>  |     + -- <mem_counter_11>
>  |     |     + -- <swap_counter_11>
>  |     + -- <mem_counter_12>
>  |           + -- <swap_counter_12>
>  + -- <mem_counter_2>
>  |     + -- <swap_counter_2>
>  |     + -- <mem_counter_21>
>  |     |     + -- <swap_counter_21>
>  |     + -- <mem_counter_22>
>  |           + -- <swap_counter_22>
>  + -- <mem_counter_N>
>        + -- <swap_counter_N>
>        + -- <mem_counter_N1>
>        |     + -- <swap_counter_N1>
>        + -- <mem_counter_N2>
>              + -- <swap_counter_N2>
>
please let me confirm.

- swap_counter_X.limit can be defined independent from mem_counter_X.limit ?
- swap_conter_N1's limit and swap_counter_N's have some relationship ?

Thanks,
-kame
