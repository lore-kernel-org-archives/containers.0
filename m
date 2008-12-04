From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] tracing: fix typo and missing inline function
Date: Thu, 4 Dec 2008 08:16:15 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812040815350.5240@gandalf.stny.rr.com>
References: <20081204052638.425740534@goodmis.org> <20081204081008.GC32594@elte.hu> <20081204083059.GA8131@elte.hu> <20081204083419.GA8918@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757045AbYLDNQ3@vger.kernel.org>
In-Reply-To: <20081204083419.GA8918@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org


On Thu, 4 Dec 2008, Ingo Molnar wrote:

> 
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > small fixlet below.
> 
> updated.
> 
> --------------->
> >From 6b2539302bee8e88c99e3c7d80c16a04dbe5e2ad Mon Sep 17 00:00:00 2001
> From: Ingo Molnar <mingo@elte.hu>
> Date: Thu, 4 Dec 2008 09:18:28 +0100
> Subject: [PATCH] tracing: fix typo and missing inline function
> 
> Impact: fix build bugs
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
>  kernel/trace/trace.h |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
> index 8b81b4d..b4b7b73 100644
> --- a/kernel/trace/trace.h
> +++ b/kernel/trace/trace.h
> @@ -529,7 +529,11 @@ static inline int ftrace_graph_addr(unsigned long addr)
>  #else
>  static inline int ftrace_trace_addr(unsigned long addr)
>  {
> -	return 1
> +	return 1;
> +}
> +static inline int ftrace_graph_addr(unsigned long addr)
> +{
> +	return 1;
>  }
>  #endif /* CONFIG_DYNAMIC_FTRACE */

Thanks! I guess I need to test the "off" cases ;-)

-- Steve
