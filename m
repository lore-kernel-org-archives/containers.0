From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] ftrace: trace single pid for function graph tracer
Date: Wed, 3 Dec 2008 12:49:15 -0800
Message-ID: <20081203124915.2eb9e7cd.akpm@linux-foundation.org>
References: <20081203203656.776893226@goodmis.org>
	<20081203203829.362295724@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755383AbYLCUud@vger.kernel.org>
In-Reply-To: <20081203203829.362295724@goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, fweisbec@gmail.com, peterz@infradead.org, arjan@infradead.org, dave@linux.vnet.ibm.com, containers@lists.osdl.org, ebiederm@xmission.com, sukadev@linux.vnet.ibm.com, serue@us.ibm.com, srostedt@redhat.com
List-Id: containers.vger.kernel.org

On Wed, 03 Dec 2008 15:36:59 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> This patch makes the changes to set_ftrace_pid apply to the function
> graph tracer.

That sentence needs help.

>  # echo $$ > /debugfs/tracing/set_ftrace_pid
>  # echo function_graph > /debugfs/tracing/current_tracer
> 
> Will cause only the current task to be traced. Note, the trace flags are
> also inherited by child processes, so the children of the shell
> will also be traced.

Where did we end up on the pids-arent-unique issue?  Gave up?
