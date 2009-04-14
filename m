From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: Creating tasks on restart: userspace vs kernel
Date: Tue, 14 Apr 2009 11:16:01 -0500
Message-ID: <20090414161601.GB8085@us.ibm.com>
References: <49E40662.2040508@cs.columbia.edu> <20090414095904.GD3558@elte.hu> <49E4A380.4070503@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757804AbZDNQQj@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49E4A380.4070503@cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Ingo Molnar <mingo@elte.hu>, containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl@cs.columbia.edu):
> For #1, we need to create a new container to begin with. This already
> requires CAP_SYS_ADMIN. Yes, for now we can use some setuid() to create
> a new pid_ns and then do the restart.

This is why I like tagging a pidns with a userid, and requiring that
current->euid==pidns->uid in order to be allowed to set pid in that
pidns.

We require cap_sys_admin wil doing clone(CLONE_NEWPID).  So if we do
that while uid=500, then drop cap_sys_admin, then we can proceed to
create new tasks with specified pids in that pidns.

-serge
