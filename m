From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: CAP_SYS_ADMIN on restart(2) (was: Re: [PATCH 00/30] C/R
	OpenVZ/Virtuozzo style)
Date: Wed, 15 Apr 2009 15:22:20 -0500
Message-ID: <20090415202220.GA5228__27968.2036526085$1239827145$gmane$org@us.ibm.com>
References: <20090410023207.GA27788@x200.localdomain>
	<1239340031.24083.21.camel@nimitz>
	<20090413091423.GA19236@x200.localdomain>
	<49E4108A.8050201@cs.columbia.edu>
	<20090414145830.GA27461@x200.localdomain>
	<49E4D115.5080601@cs.columbia.edu>
	<20090414204912.GA28458@x200.localdomain>
	<20090414213934.GB17986@us.ibm.com>
	<20090415192150.GC26994@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090415192150.GC26994-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Is sysctl to control CAP_SYS_ADMIN on restart(2) OK?

You mean a sysctl to specify whether to require CAP_SYS_ADMIN for
restart(2)?

Yeah I wouldn't object to that - it certainly seems like something
sane for an admin to use depending on their users.

Though I think the bigger fish to fry first is whether we only support
whole-container checkpoint/restart.  If that is the case, then
CAP_SYS_ADMIN will always be needed for restart since it will always
unshare some namespaces.

thanks,
-serge
