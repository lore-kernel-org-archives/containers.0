From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Mark timer_stats as incompatible with multiple pid
	namespaces
Date: Thu, 13 Dec 2007 22:37:11 +0100
Message-ID: <20071213213710.GB25563@elte.hu>
References: <m13au7tsov.fsf@ebiederm.dsl.xmission.com> <20071213090102.GB1926@elte.hu> <m1r6hqstat.fsf@ebiederm.dsl.xmission.com> <20071213130423.GB28340@elte.hu> <m1ir32sejc.fsf@ebiederm.dsl.xmission.com> <20071213202621.GC25130@elte.hu> <m1prxaqo62.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933596AbXLMVh4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1prxaqo62.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


* Eric W. Biederman <ebiederm@xmission.com> wrote:

> >> Well struct pid * works in that case if you grab the reference to 
> >> it.
> >
> > but the display of the stats might happen much later. The point of 
> > this API is to save pid+comm, which gives users a good idea about 
> > what caused the events in the past - without having to pin any 
> > resource of that task.
> 
> Likewise struct pid is designed not to be a problem if pinned. It is a 
> little heavier then it used to be with the addition of pid namespace 
> support but not much.  And if it is to heavy struct pid needs to be 
> fixed.
> 
> Holding the struct pid very much does not pin the task struct, and it 
> shouldn't pin any other resources.  I agree 64bytes or so is a bit 
> more to pin then 4 bytes but it really isn't a lot.

yeah, and i have no conceptual objections - i just wanted to outline the 
thinking behind /proc/timer_stats.

	Ingo
