From: Jaswinder Singh <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Tests for cpusets and cgroup performance measurement
Date: Wed, 23 Mar 2011 11:12:41 +0530
Message-ID: <AANLkTimPWxVeax3RcVBefPeV5+P8G6cHhdU-g82_s5s3__42579.0866873742$1300859008$gmane$org@mail.gmail.com>
References: <AANLkTinmjGaK9ZSbKYTm5g-wuQ-K1hQaJBA+gSN5ERJ=@mail.gmail.com>
	<AANLkTikHqJR=JgZzKc1G-m8z82hBFmD-w1bLn5aENTcr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTikHqJR=JgZzKc1G-m8z82hBFmD-w1bLn5aENTcr-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Paul,

On Mon, Mar 21, 2011 at 11:03 PM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, Mar 21, 2011 at 3:42 AM, Jaswinder Singh
> <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>
>> Can you please suggest some simple tests to measure the performance
>> enhancement by using cpusets/cgroups.
>
> The cgroups framework is simply a way of grouping processes together
> and allowing subsystems (memory, CPU, disk I/O, etc) to associate
> state objects with each group. Generally this is for improving
> isolation rather than improving performance - sticking extra machinery
> and scheduling in will typically reduce overall throughput, but make
> it more practical to share resources safely between multiple groups of
> processes.
>
> Your question is pretty open-ended - what's your ultimate goal? You
> should probably be focusing on some particular problem that you're
> trying to measure/improve via resource isolation/scheduling.
>

As per http://www.clusterresources.com/torquedocs21/3.5linuxcpusets.shtml :

Under section 3.5.4 Cpuset advantages / disadvantages

"Jobs on larger NUMA systems may see a performance boost if jobs can be
intelligently assigned to specific CPUs. Jobs may perform better if
striped across physical processors, or contained within the fewest
number of memory controllers."


I am curious and want to try some simple tests so that I can see the
performance improvement by using cpusets on my PCs.

Can you suggest some tests so that I can study them.

Thank you,
--
Jaswinder Singh.
