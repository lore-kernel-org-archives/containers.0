From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Sat, 23 Jul 2011 12:43:08 +0400
Message-ID: <4E2A899C.8090909@parallels.com>
References: <20110718132759.GB8127@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110718132759.GB8127-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/18/2011 11:04 PM, Serge E. Hallyn wrote:
> (sorry, just realized postfix has been messing up my email, hope this
> comes through ok)
> 
> Thanks, Pavel.  I will take a look at this when I get a chance.  I'm
> a little worried about security implications - this approach should
> lend itself (especially with the binfmt handler) to clean handling
> of security issues, but given the issues we've had with /proc things
> that already exist, I'm worried about the dump files.  If you have
> any preemptive comments on that, please do share :)

As far as the security is concerned - yes, this is very tricky question.
Before we find out and fix all the possible security implications, I'd
suggest adding the
  if (!capable(CAP_SYS_ADMIN))
	return -EPERM
check into the execve handler. :)

And I understand your worry about the dump files in /proc. I do not like
this thing either and looking forward for your suggestions. I've asked this
question to Tejun, hopefully we'll work out the good solution.

> We did briefly try a binfmt handler at the very end of our foray into
> the ptrace checkpoint/restart approach, but your overall set here seems
> very nice.
> 
> thanks,
> -serge
> .
> 
