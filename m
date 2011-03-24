From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Tests for cpusets and cgroup performance measurement
Date: Thu, 24 Mar 2011 14:16:27 -0700
Message-ID: <AANLkTimRqvy4JseWka9HfwvmirbUxcTEBy5OTg4UiQiZ__11713.1665618674$1301001524$gmane$org@mail.gmail.com>
References: <AANLkTinmjGaK9ZSbKYTm5g-wuQ-K1hQaJBA+gSN5ERJ=@mail.gmail.com>
	<AANLkTikHqJR=JgZzKc1G-m8z82hBFmD-w1bLn5aENTcr@mail.gmail.com>
	<AANLkTimPWxVeax3RcVBefPeV5+P8G6cHhdU-g82_s5s3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTimPWxVeax3RcVBefPeV5+P8G6cHhdU-g82_s5s3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Tue, Mar 22, 2011 at 10:42 PM, Jaswinder Singh
<jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> "Jobs on larger NUMA systems may see a performance boost if jobs can be
> intelligently assigned to specific CPUs. Jobs may perform better if
> striped across physical processors, or contained within the fewest
> number of memory controllers."
>
> I am curious and want to try some simple tests so that I can see the
> performance improvement by using cpusets on my PCs.
>
> Can you suggest some tests so that I can study them.

Not particularly - I've never been involved in optimizing apps on
large NUMA systems. Our uses of NUMA at Google have all involved
faked-NUMA nodes, assigning nodes to jobs to provide crude memory
limits.

I suspect that there aren't very many "simple" tests out there. Google
search for [hpc numa tuning] turns up a few likely pages that might
have pointers to suitable applications.

Paul
