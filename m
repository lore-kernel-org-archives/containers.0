From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH linux-cr] nested pid namespaces (v2)
Date: Mon, 22 Mar 2010 12:57:35 -0700
Message-ID: <20100322195735.GE20796@count0.beaverton.ibm.com>
References: <20100319213955.GA17912@us.ibm.com>
 <20100322105502.GB5569@localdomain>
 <20100322143800.GD3744@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100322143800.GD3744@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Louis Rilling <Louis.Rilling@kerlabs.com>, Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 22, 2010 at 09:38:00AM -0500, Serge E. Hallyn wrote:
> Quoting Louis Rilling (Louis.Rilling@kerlabs.com):
> > On Fri, Mar 19, 2010 at 04:39:55PM -0500, Serge E. Hallyn wrote:
> > > Support checkpoint and restart of tasks in nested pid namespaces.  At

<snip>

> > It would probably be safer too to use task_active_pid_ns() instead of
> > task->nsproxy->pid_ns, just in case some PID namespace unsharing like proposed
> > by Eric makes it to mainline.
> 
> The task is frozen though so it shouldn't be able to unshare while being
> checkpointed, right?  But it's probably better code anyway.

By the time it reaches checkpoint a frozen task is in the refrigerator
-- most often in the signal delivery portion of syscall return. So it can't
be making any new unshare/setns syscalls and any changes to the namespaces
should be visible.

Cheers,
	-Matt Helsley
