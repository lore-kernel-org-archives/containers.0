From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Mark timer_stats as incompatible with multiple pid
	namespaces
Date: Thu, 13 Dec 2007 21:26:21 +0100
Message-ID: <20071213202621.GC25130@elte.hu>
References: <m13au7tsov.fsf@ebiederm.dsl.xmission.com> <20071213090102.GB1926@elte.hu> <m1r6hqstat.fsf@ebiederm.dsl.xmission.com> <20071213130423.GB28340@elte.hu> <m1ir32sejc.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765573AbXLMU0w@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1ir32sejc.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


* Eric W. Biederman <ebiederm@xmission.com> wrote:

> > the problem is, this interface stores historic PIDs too - i.e. PIDs 
> > of tasks that might have exited already.
> 
> Well struct pid * works in that case if you grab the reference to it.

but the display of the stats might happen much later. The point of this 
API is to save pid+comm, which gives users a good idea about what caused 
the events in the past - without having to pin any resource of that 
task.

>  {
>  	timer->start_site = NULL;
> +	pit_pid(timer->start_pid);
> +	timer->start_pid = NULL;

s/pit/put, right?

	Ingo
