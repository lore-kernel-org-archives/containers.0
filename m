From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] ftrace: add cpu annotation for function graph
 tracer
Date: Tue, 25 Nov 2008 21:39:09 -0800
Message-ID: <20081125213909.d4eb3f09.akpm@linux-foundation.org>
References: <20081126051622.134970943@goodmis.org>
	<20081126051710.339437727@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752795AbYKZFjn@vger.kernel.org>
In-Reply-To: <20081126051710.339437727@goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

On Wed, 26 Nov 2008 00:16:27 -0500 Steven Rostedt <rostedt@goodmis.org> wrote:

> This patch adds the annotation of 'CPU[###]' where ### is a three digit
> number

Is this a plot to get yourself sent a 1024-way test box?
