From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: Creating tasks on restart: userspace vs kernel
Date: Tue, 14 Apr 2009 20:46:23 +0400
Message-ID: <20090414164623.GF27461@x200.localdomain>
References: <49E40662.2040508@cs.columbia.edu> <20090414163633.GE27461@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757257AbZDNQq0@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090414163633.GE27461@x200.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.osdl.org, Dave Hansen <dave@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

> 1) somebody should write registers before final jump to userspace.
>    Task itself can't generally do it: struct pt_regs is in the same place
>    as kernel stack.
> 
>    cr_load_cpu_regs() does exactly this: as current writes to it's own
>    pt_regs. Oren, why don't you see crashes?
> 
>    I first tried to do it and was greeted with horrible crashes because
>    e.g current becoming NULL under current. That's why 
>    cr_arch_restore_task_struct() is not done in current context.

Hmm, this must an artefact of kernel_thread() approach.
