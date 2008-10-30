From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Thu, 30 Oct 2008 10:02:44 +0400
Message-ID: <200810300902.47067.major__10984.3225720853$1225346673$gmane$org@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<200810271707.13580.major@openvz.org>
	<4905D2AD.1070309@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4905D2AD.1070309-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Daniel
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Monday 27 October 2008 17:39 Oren Laadan wrote:
> Andrey Mirkin wrote:
> > On Monday 20 October 2008 19:55 Dave Hansen wrote:
> >> On Mon, 2008-10-20 at 16:14 +0400, Andrey Mirkin wrote:
> >>> Right now my patchset (v2) provides an ability to checkpoint and
> >>> restart a group of processes. The process of checkpointing and restart
> >>> can be initiated from external process (not from the process which
> >>> should be checkpointed).
> >>
> >> Absolutely.  Oren's code does it this way to make for a smaller patch at
> >> first.  The syscall takes a pid argument so it is surely expected to be
> >> expanded upon later.
> >>
> >>> Also I think that all the restart job (including process forking)
> >>> should be done in kernel, as in this case we will not depend on user
> >>> space and will be more secure. This is also implemented in my patchset.
> >>
> >> Do you think that this is an approach that Oren's patches are married
> >> to, or is this a "feature" we can add on later?
> >
> > Well, AFAICS from Oren's patch set his approach is oriented on process
> > creation in user space. I think we should choose right now what approach
> > will be used for process creation.
>
> This is inaccurate.
>
> I intentionally did not address how processes will be created, by
> simply allowing either way to be added to the patch.

Yes, you right. Either way is possible with your patchset. But as I understand 
in ZAP you are using user space process creation. No?
That is why I think that your design is more convenient for user process 
creation.

> I do agree that we probably want to decide how to do it. However,
> there is also room to allow for both approaches, in a compatible
> way, should we wish to explore both.

Yes, we can implement both approaches. Do you think we really need this?

> > We have two options here: fork processes in kernel or fork them in user
> > space. If process will be forked in user space, then there will be a gap
> > when process will be in user space and can be killed with received signal
> > before entering
>
> Why do we care about it ?
> Why is there a difference if it is killed before or after entering
> the kernel (e.g. user aborted restart, or kernel OOM kicked in) ?

If one process is killed during restart then you can even do not notice that 
(if processes are created from user space and then call sys_restart). And you 
will get not the same state as before C/R.

> > kernel. Also we will need a functionolity to create processes with
> > predefined PID. I think it is not very good to provide such ability to
> > user space. That is why we prefer in OpenVZ to do all the job in kernel.
>
> This is the weak side of creating the processes in user space -
> that we need such an interface. Note, however, that we can
> easily "hide" it inside the interface of the sys_restart() call,
> and restrict how it may be used.

Of course we can "hide" it somehow, but anyway we will have a hole and that is 
not good.

Anyway we should ask everyone what they think about user- and kernel- based 
process creation.
Dave, Serge, Cedric, Daniel, Louis what do you think about that?

Andrey

> >> I don't care which patch set we end up sticking in the kernel.  I'm
> >> trying to figure out which code we can more easily build upon in the
> >> future.  The fact that Oren's or yours can't do certain little things
> >> right now does not bother me.
> >>
> >> Honestly, I'm a little more confident that everyone can work with Oren
> >> since he managed to get 7 revisions of his patch out and make some
> >> pretty large changes while in the same time the OpenVZ patch was only
> >> released twice.  I'm not sure what has changed in the OpenVZ patch
> >> between releases, either.
> >
> > That is my fault. I am working right now on my Ph.D, that is why my
> > activity is not very high. But now I hope I will have more time for that.
> >
> >> Are there any reasons that you absolutely can not use the code Oren
> >> posted?  Will it not fulfill your needs somehow?  If so, could you
> >> please elaborate on how?
> >
> > We have one major difference with Oren's code - how processes are created
> > during restr.
> > Right now I'm trying to port kernel process creation on top of Oren's
> > patches. I agree that working in collaboration will speed up merging of
> > checkpointing to mainstream.
> >
> > Andrey
> >
> > P.S.: Sorry for late reply, my mailer attached your e-mail to wrong
> > thread. _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
