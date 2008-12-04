From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 4 Dec 2008 10:10:23 +0100
Message-ID: <20081204091023.GJ32594@elte.hu>
References: <20081204052638.425740534@goodmis.org> <20081204052735.362609481@goodmis.org> <20081204001803.598063f5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755364AbYLDJLc@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081204001803.598063f5.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> > Signed-off-by: Steven Rostedt <srostedt@redhat.com>
> 
> What does this patch actually do?  Is swapper currently excluded from 
> tracing for undisclosed reasons and this patch permits it to be traced? 
> If so, why was swapper thus excluded?  Or am I totally off track?

> > +static struct pid * const ftrace_swapper_pid = (struct pid *)1;
> 
> eh?

all side-effects of getting rid of the integer based PID namespace and 
replacing them with struct pid pointers.

	Ingo
