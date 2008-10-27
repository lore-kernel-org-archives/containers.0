From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Mon, 27 Oct 2008 18:38:28 +0400
Message-ID: <200810271738.30020.major__25190.7140868299$1225118510$gmane$org@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<200810201614.36911.major@openvz.org>
	<48FCBD24.7070902@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FCBD24.7070902-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Monday 20 October 2008 21:17 Oren Laadan wrote:
> Andrey Mirkin wrote:
> > On Saturday 18 October 2008 03:33 Dave Hansen wrote:
> >> On Wed, 2008-09-03 at 14:57 +0400, Andrey Mirkin wrote:
> >>> This patchset introduces kernel based checkpointing/restart as it is
> >>> implemented in OpenVZ project. This patchset has limited functionality
> >>> and are able to checkpoint/restart only single process. Recently Oren
> >>> Laaden sent another kernel based implementation of checkpoint/restart.
> >>> The main differences between this patchset and Oren's patchset are:
> >>
> >> Hi Andrey,
> >>
> >> I'm curious what you want to happen with this patch set.  Is there
> >> something specific in Oren's set that deficient which you need
> >> implemented?  Are there some technical reasons you prefer this code?
> >
> > Hi Dave,
> >
> > Right now my patchset (v2) provides an ability to checkpoint and restart
> > a group of processes. The process of checkpointing and restart can be
> > initiated from external process (not from the process which should be
> > checkpointed).
>
> Both patchsets share the same design, namely be able to checkpoint and
> restart multiple processes, with the operation initiated by an external
> processes.
>
> I deliberately left out the part that handles multiple processes to
> keeps things simple for initial review, and until we decide on the
> question of kernel- or user- based process creation on restart.

I agree that multiple process handling is not needed for initial review. But I 
believe that the question with process creation should be discussed right 
now.

> > Also I think that all the restart job (including process forking) should
> > be done in kernel, as in this case we will not depend on user space and
> > will be more secure. This is also implemented in my patchset.
>
> I'm not convinced that creating the processes in the kernel makes it
> more secure.  Can you elaborate ?  for the discussion, let's compare
> these two basic scenarios:
>
> 1) container and processes are created in user space; each process
> calls "sys_restart()" which eventually calls "do_restart()" that
> does kernel-based restart.

Well, in this case there will be a gap after process is returned from fork but 
before entering kernel. During that time process can be killed by delivered 
signal. Another drawback of this approach is that we will need to provide an 
ability for user to create processes with predefined PID.

> 2) container and processes are created in kernel space; each process
> calls "do_restart()" to do kernel-based restart.
>
> In fact, creating in user based makes it easier to enforce capabilities
> and limits of the user. It also simplifies the debugging significantly,
> and allows us to delegate the entire issue of containers and namespace
> management back to user space, where it probably belongs.
>
> On the other hand, doing it in kernel space likely to produce simpler
> code for the creation of the processes.

You right here. Both approaches have pros and cons, but I think that kernel 
approach has more advantages

Andrey
