From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Mark timer_stats as incompatible with multiple pid
	namespaces
Date: Thu, 13 Dec 2007 10:01:02 +0100
Message-ID: <20071213090102.GB1926@elte.hu>
References: <m13au7tsov.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758572AbXLMJCb@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m13au7tsov.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


* Eric W. Biederman <ebiederm@xmission.com> wrote:

> /proc/timer_stats currently reports the user of a timer by pid, which 
> is a reasonable approach.  However if you are not in the initial pid 
> namespace the pid that is reported is nonsense.
> 
> Therefore until we can make timer_stats pid namespace safe just 
> disable it in the build if pid namespace support is selected so we at 
> least know we have a conflict.

What the heck??? Please solve this properly instead of hiding it. 
/proc/timer_stats is damn useful and it's a must-have for powertop to 
work.

	Ingo
