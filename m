From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Sun, 31 May 2009 20:38:37 -0500
Message-ID: <20090601013837.GA15897@hallyn.com>
References: <20090529223229.GA14536@us.ibm.com> <20090529223319.GE14602@us.ibm.com> <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Andrew G. Morgan" <morgan@kernel.org>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Andrew G. Morgan (morgan@kernel.org):
> Serge,
> 
> I'm not sure I'm too happy with hard coding the 64-bitness of
> capability sets. It may well be a very long time before we increase
> their size, but couldn't you prepare for that with some reference to
> the prevailing magic numbers for the current ABI representation?

Hmm, ok.  I figured since the c/r code was in capability.h it would
be obvious that going past 64-bit would mean a new checkpoint image
format.  I can see where that's silly...

I'll put in a commented BUILD_BUG_ON like Alexey suggests - does that
suffice?

> Also, the use of 'error' as both a variable and a goto destination
> looks a little confusing.

Ok will change.

Did you see any problems with the way I authorize a task's resetting
of capabilities at sys_restart()?

thanks,
-serge
