From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
Date: Tue, 11 Mar 2008 01:57:43 -0700
Message-ID: <6599ad830803110157u71fe6c3cse125d0202610413b@mail.gmail.com>
References: <47D16004.7050204@openvz.org>
	<20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>
	<47D63FBC.1010805@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47D63FBC.1010805-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 11, 2008 at 1:15 AM, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>
>  <mem_couter_0>
>   + -- <swap_counter_0>
>   + -- <mem_counter_1>
>   |     + -- <swap_counter_1>
>   |     + -- <mem_counter_11>
>   |     |     + -- <swap_counter_11>
>   |     + -- <mem_counter_12>
>   |           + -- <swap_counter_12>
>   + -- <mem_counter_2>
>   |     + -- <swap_counter_2>
>   |     + -- <mem_counter_21>
>   |     |     + -- <swap_counter_21>
>   |     + -- <mem_counter_22>
>   |           + -- <swap_counter_22>
>   + -- <mem_counter_N>
>        + -- <swap_counter_N>
>        + -- <mem_counter_N1>
>        |     + -- <swap_counter_N1>
>        + -- <mem_counter_N2>
>              + -- <swap_counter_N2>
>

The idea of hierarchy is good, but I don't think this particular
hierarchy works for memory.

Main memory and swap space are very different resources, with very
different performance characteristics. Suppose you have a 2G machine,
and you want to guarantee each job 1GB of main memory, plus give them
the option of 1GB of swap for when they go over the 1G main memory
limit. With the hierarchy given above, you've need to give each job a
2GB mem.limit and a 1GB swap.limit, and so there would be no main
memory isolation.

My feeling is that people are going to want to limit swap and main
memory usage as two independent resource hierarchies more often than
they're going to want to limit overall virtual memory. But assuming
that there are people who need to do the latter, then you should make
it configurable how the hierarchies fit together.

Alternatively, you could make it possible for a res_counter to have
multiple parents (each of which constrains the overall usage of it and
its siblings), and have three counters for each cgroup:

- vm_counter: overall virtual memory limit for group, parent =
parent_mem_cgroup->vm_counter

- mem_counter: main memory limit for group, parents = vm_counter,
parent_mem_cgroup->mem_counter

- swap_counter: swap limit for group, parents = vm_counter,
parent_mem_cgroup->swap_counter

Paul
