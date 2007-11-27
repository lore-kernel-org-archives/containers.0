From: Pierre Peiffer <pierre.peiffer@bull.net>
Subject: Re: [PATCH 2.6.24-rc3-mm1] IPC: consolidate sem_exit_ns(), msg_exit_ns
 and shm_exit_ns()
Date: Tue, 27 Nov 2007 09:19:34 +0100
Message-ID: <474BD316.3030709@bull.net>
References: <20071123175250.0f584913.pierre.peiffer@bull.net>	<20071126224438.df547263.akpm@linux-foundation.org> <20071126224636.ca1ef92e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752740AbXK0ITx@vger.kernel.org>
In-Reply-To: <20071126224636.ca1ef92e.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org



Andrew Morton wrote:
> On Mon, 26 Nov 2007 22:44:38 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> On Fri, 23 Nov 2007 17:52:50 +0100 Pierre Peiffer <pierre.peiffer@bull.net> wrote:
>>
>>> sem_exit_ns(), msg_exit_ns() and shm_exit_ns() are all called when an ipc_namespace is
>>> released to free all ipcs of each type.
>>> But in fact, they do the same thing: they loop around all ipcs to free them
>>> individually by calling a specific routine.
>>>
>>> This patch proposes to consolidate this by introducing a common function, free_ipcs(),
>>> that do the job. The specific routine to call on each individual ipcs is passed as
>>> parameter. For this, these ipc-specific 'free' routines are reworked to take a
>>> generic 'struct ipc_perm' as parameter.
>> This conflicts in more-than-trivial ways with Pavel's
>> move-the-ipc-namespace-under-ipc_ns-option.patch, which was in
>> 2.6.24-rc3-mm1.
>>
> 
> err, no, it wasn't that patch.  For some reason your change assumes that
> msg_exit_ns() (for example) doesn't have these lines:
> 
>         kfree(ns->ids[IPC_MSG_IDS]);
>         ns->ids[IPC_MSG_IDS] = NULL;
> 
> in it.

Yes, in fact, I've made this patch on top of this one:
http://lkml.org/lkml/2007/11/22/49

As the patch mentioned by this previous thread was acked by Cedric and Pavel,
I've assumed that you will take both. But I've not made this clear, sorry.

-- 
Pierre
