From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Mark timer_stats as incompatible with multiple pid
	namespaces
Date: Thu, 13 Dec 2007 14:04:23 +0100
Message-ID: <20071213130423.GB28340@elte.hu>
References: <m13au7tsov.fsf@ebiederm.dsl.xmission.com> <20071213090102.GB1926@elte.hu> <m1r6hqstat.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761599AbXLMNEw@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1r6hqstat.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


* Eric W. Biederman <ebiederm@xmission.com> wrote:

> > What the heck??? Please solve this properly instead of hiding it. 
> > /proc/timer_stats is damn useful and it's a must-have for powertop 
> > to work.
> 
> Hmm.  Perhaps the dependency conflict should go in the other direction 
> then.
> 
> My goal is to document the issue while a proper fix is being written. 
> I have known about this for all of about 1 day now.  It was added 
> since last time I went through the kernel and made a thorough sweep of 
> pid users.
> 
> What the proper fix is isn't even obvious at this point. Possibly it 
> is making /proc/timer_stats disappear in child pid namespaces.
>   Which we don't currently have the infrastructure fore.
>
> Possibly it is reworking the stats collection so we store a struct pid 
> * instead of a pid_t value.  So we would know if the reader of the 
> value can even see processes you have collected stats for.

the problem is, this interface stores historic PIDs too - i.e. PIDs of 
tasks that might have exited already.

the proper way would be to also store the namespace address, and to 
filter out non-matching entries. (If leakage of this data across 
namespace creation is of any concern then flush out existing namespace 
data when a namespace is destroyed)

	Ingo
