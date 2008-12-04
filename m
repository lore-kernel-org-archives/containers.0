From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 04 Dec 2008 04:59:04 -0800
Message-ID: <m1vdu0t7tz.fsf@frodo.ebiederm.org>
References: <20081204052638.425740534@goodmis.org>
	<20081204052735.362609481@goodmis.org>
	<20081204001803.598063f5.akpm@linux-foundation.org>
	<20081204091023.GJ32594@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756779AbYLDNGw@vger.kernel.org>
In-Reply-To: <20081204091023.GJ32594@elte.hu> (Ingo Molnar's message of "Thu,
	4 Dec 2008 10:10:23 +0100")
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

Ingo Molnar <mingo@elte.hu> writes:

> * Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> > Signed-off-by: Steven Rostedt <srostedt@redhat.com>
>> 
>> What does this patch actually do?  Is swapper currently excluded from 
>> tracing for undisclosed reasons and this patch permits it to be traced? 
>> If so, why was swapper thus excluded?  Or am I totally off track?
>
>> > +static struct pid * const ftrace_swapper_pid = (struct pid *)1;
>> 
>> eh?
>
> all side-effects of getting rid of the integer based PID namespace and 
> replacing them with struct pid pointers.

Thanks for asking Andrew it looks like an unnecessary side effect.

Eric
