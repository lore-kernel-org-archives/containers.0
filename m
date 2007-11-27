From: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Subject: Re: [PATCH 1/2] namespaces: introduce sys_hijack (v10)
Date: Tue, 27 Nov 2007 13:09:24 -0500
Message-ID: <1196186964.3925.129.camel__16306.5646346242$1196187496$gmane$org@moss-spartans.epoch.ncsc.mil>
References: <474B78CB.5070607@au1.ibm.com> <474BC017.6060801@crispincowan.com>
	<20071127161132.GD32362@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071127161132.GD32362-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Crispin Cowan <crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org>, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2007-11-27 at 10:11 -0600, Serge E. Hallyn wrote:
> Quoting Crispin Cowan (crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org):
> > Just the name "sys_hijack" makes me concerned.
> > 
> > This post describes a bunch of "what", but doesn't tell us about "why"
> > we would want this. What is it for?
> 
> Please see my response to Casey's email.
> 
> > And I second Casey's concern about careful management of the privilege
> > required to "hijack" a process.
> 
> Absolutely.  We're definately still in RFC territory.
> 
> Note that there are currently several proposed (but no upstream) ways to
> accomplish entering a namespace:
> 
> 	1. bind_ns() is a new pair of syscalls proposed by Cedric.  An
> 	nsproxy is given an integer id.  The id can be used to enter
> 	an nsproxy, basically a straight current->nsproxy = target_nsproxy;
> 
> 	2. I had previously posted a patchset on top of the nsproxy
> 	cgroup which allowed entering a nsproxy through the ns cgroup
> 	interface.
> 
> There are objections to both those patchsets because simply switching a
> task's nsproxy using a syscall or file write in the middle of running a
> binary is quite unsafe.  Eric Biederman had suggested using ptrace or
> something like it to accomplish the goal.
> 
> Just using ptrace is however not safe either.  You are inheriting *all*
> of the target's context, so it shouldn't be difficult for a nefarious
> container/vserver admin to trick the host admin into running something
> which gives the container/vserver admin full access to the host.

I don't follow the above - with ptrace, you are controlling a process
already within the container (hence in theory already limited to its
container), and it continues to execute within that container.  What's
the issue there?

> That's where the hijack idea came from.  Yes, I called it hijack to make
> sure alarm bells went off :) bc it's definately still worrisome.  But at
> this point I believe it is the safest solution suggested so far.

-- 
Stephen Smalley
National Security Agency
