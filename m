From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Tests for cpusets and cgroup performance measurement
Date: Mon, 21 Mar 2011 10:33:08 -0700
Message-ID: <AANLkTikHqJR=JgZzKc1G-m8z82hBFmD-w1bLn5aENTcr__41588.2309353494$1300729023$gmane$org@mail.gmail.com>
References: <AANLkTinmjGaK9ZSbKYTm5g-wuQ-K1hQaJBA+gSN5ERJ=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTinmjGaK9ZSbKYTm5g-wuQ-K1hQaJBA+gSN5ERJ=@mail.gmail.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jaswinder Singh <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 21, 2011 at 3:42 AM, Jaswinder Singh
<jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> Can you please suggest some simple tests to measure the performance
> enhancement by using cpusets/cgroups.

The cgroups framework is simply a way of grouping processes together
and allowing subsystems (memory, CPU, disk I/O, etc) to associate
state objects with each group. Generally this is for improving
isolation rather than improving performance - sticking extra machinery
and scheduling in will typically reduce overall throughput, but make
it more practical to share resources safely between multiple groups of
processes.

Your question is pretty open-ended - what's your ultimate goal? You
should probably be focusing on some particular problem that you're
trying to measure/improve via resource isolation/scheduling.

Paul
