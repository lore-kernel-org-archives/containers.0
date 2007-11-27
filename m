From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2.6.24-rc3-mm1] IPC: consolidate sem_exit_ns(),
 msg_exit_ns and shm_exit_ns()
Date: Mon, 26 Nov 2007 22:44:38 -0800
Message-ID: <20071126224438.df547263.akpm@linux-foundation.org>
References: <20071123175250.0f584913.pierre.peiffer@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753972AbXK0Gp3@vger.kernel.org>
In-Reply-To: <20071123175250.0f584913.pierre.peiffer@bull.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Pierre Peiffer <pierre.peiffer@bull.net>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Fri, 23 Nov 2007 17:52:50 +0100 Pierre Peiffer <pierre.peiffer@bull.net> wrote:

> sem_exit_ns(), msg_exit_ns() and shm_exit_ns() are all called when an ipc_namespace is
> released to free all ipcs of each type.
> But in fact, they do the same thing: they loop around all ipcs to free them
> individually by calling a specific routine.
> 
> This patch proposes to consolidate this by introducing a common function, free_ipcs(),
> that do the job. The specific routine to call on each individual ipcs is passed as
> parameter. For this, these ipc-specific 'free' routines are reworked to take a
> generic 'struct ipc_perm' as parameter.

This conflicts in more-than-trivial ways with Pavel's
move-the-ipc-namespace-under-ipc_ns-option.patch, which was in
2.6.24-rc3-mm1.
