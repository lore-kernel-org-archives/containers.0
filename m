From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Creating tasks on restart: userspace vs kernel
Date: Tue, 14 Apr 2009 11:59:04 +0200
Message-ID: <20090414095904.GD3558@elte.hu>
References: <49E40662.2040508@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754990AbZDNKAd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49E40662.2040508@cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>, Dave Hansen <dave@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org


* Oren Laadan <orenl@cs.columbia.edu> wrote:

> <3> Clone with pid:
> 
> To restart processes from userspace, there needs to be a way to 
> request a specific pid--in the current pid_ns--for the child 
> process (clearly, if it isn't in use).
> 
> Why is it a disadvantage ?  to Linus, a syscall clone_with_pid() 
> "sounds like a _wonderful_ attack vector against badly written 
> user-land software...".  Actually, getting a specific pid is 
> possible without this syscall.  But the point is that it's 
> undesirable to have this functionality unrestricted.

The point is that there's a class of a difference between a racy and 
unreliable method of 'create tens of thousands of tasks to steal the 
right PID you are interested in' and a built-in syscall that gives 
this within a couple of microseconds.

Most signal races are timing dependent so the ability to do it 
really quickly makes or breaks the practicality of many classes of 
exploits.

> So one option is to require root privileges. Another option is to 
> restrict such action in pid_ns created by the same user. Even more 
> so, restrict to only containers that are being restarted.

Requiring root privileges seems to remove much of the appeal of 
allowing this to be a more generic sub-container creation thing. If 
regular unprivileged apps cannot use this to save/restore their own 
local task hierarchy, the whole thing becomes rather pointless, 
right?

	Ingo
