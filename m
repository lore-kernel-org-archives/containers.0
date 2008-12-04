From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/3] ftrace: use struct pid
Date: Thu, 04 Dec 2008 04:55:56 -0800
Message-ID: <m11vwoumjn.fsf@frodo.ebiederm.org>
References: <20081204052638.425740534@goodmis.org>
	<20081204052735.175697908@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756195AbYLDNGh@vger.kernel.org>
In-Reply-To: <20081204052735.175697908@goodmis.org> (Steven Rostedt's message
	of "Thu, 04 Dec 2008 00:26:40 -0500")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> From: Steven Rostedt <srostedt@redhat.com>
>
> Impact: clean up
>
> Eric Biederman suggested using the struct pid for filtering on
> pids in the kernel. This patch is based off of a demonstration
> of an implementation that Eric sent me in an email.

Please find_get_vpid and pid_vnr.  

Eric
