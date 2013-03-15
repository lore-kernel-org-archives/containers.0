From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/4] fix depvpts in user namespaces
Date: Fri, 15 Mar 2013 10:58:22 -0500
Message-ID: <20130315155822.GA30652__1203.6086446189$1363363156$gmane$org@sergelap>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
	<87boalt0vi.fsf@xmission.com> <20130315140040.GB3782@sergelap>
	<5143333E.1040100@parallels.com> <20130315152133.GB24305@sergelap>
	<51433DBE.9020109@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51433DBE.9020109-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> On 03/15/2013 07:21 PM, Serge Hallyn wrote:
> > Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> >> On 03/15/2013 06:00 PM, Serge Hallyn wrote:
> >>> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >>>> Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> >>>>
> >>>>> Hi,
> >>>>>
> >>>>> devpts mounts in user namespaces is queued for 3.9. However, while playing
> >>>>> with it I found it to be less than ideal. Although it could possibly work
> >>>>> with custom software that can be made to point to /dev/pts/ptmx, a few things
> >>>>> prevent it from working correctly for people that, like us, are booting full
> >>>>> distributions.
> >>>>
> >>>> Full distributions that have not been modified to be minimally container
> >>>> aware.
> >>>
> >>> Right, in fact in this case it doesn't need to be minimally container
> >>> aware, you just create the bind mount yourself and init just needs to
> >>> accept that it shouldn't touch it.
> >>>
> >>
> >> Well, what if it doesn't?
> >>
> >> At least in the system I am using, centos6, udev mounts a tmpfs in a
> >> temporary location, and then mount --move this to /dev. This is now
> >> empty, and devpts will be mounted ontop of that.
> > 
> > This also messes up your /dev/ttyN setup right?  How are you handling
> > that?
> > 
> very simple: udev will just mknod everything back, so let him!

So you're not using bind-mounted ptys over /dev/ttyN?

> >> Let me reverse the question: If you bind mount /dev/pts and then udev
> >> never touches it, etc, does my solution affects that in anyway? The way
> >> I see it, we just become more capable of running legacy system without
> >> giving nothing in return aside from code. And it is not even an
> >> extremely complex code.
> > 
> > Right - I don't object to your patch, I just wanted to see if you and
> > Eric could agree on which one to use.  After that I'll do a closer
> > review - but on first look it looked good to me.
> > 
> 
> As I said, as far as the specific part of the puzzle concerning the
> /dev/ptmx to /dev/pts/ptmx mapping, I am fine with whatever works.

ditto.

> >>>>> One of the problems that I am addressing in here is that we are disallowing
> >>>>> mknod in usernamespaces. Although I understand the motivation for that, I
> >>>>> believe that to be too restrictive, specially because we already control access
> >>>>> to the files separately. There should be no harm in mknod'ing something per se,
> >>>>> if manipulating it is forbidden.
> >>>>
> >>>> mknod in userspace needs to be a separate patchset.  There is no need to
> >>>> solve mknod in userspace to solve devpts.
> >>>>
> >>>>
> >>>>> Last, /dev/ptmx will still always be the global ptmx device. We need to somehow
> >>>>> link it to our namespaces'. My proposal is to multiplex it and return the
> >>>>> correct "root ptmx" depending on which userns is reading that device.
> >>>>
> >>>> Doable.  I still strongly prefer my version of having /dev/ptmx act like
> >>>> a link to /dev/pts/ptmx.  Letting the mount namespace control it.
> >>>
> >>> Right, Glauber have you seen this patch?  Eric did already solve this.
> >>> (And again that's a nice safeguard, but it shouldn't be necessary)
> >>>
> >> No. Where was that sent to?
> >>
> >> If you can point me to it, I am of course willing to test it. If it
> >> solves my problem (the description suggests that there is high
> >> probability), then I have no particular attachments to my specific solution.
> > 
> > Well shoot, I can't find it right now.  Not even in Eric's git tree.
> > IIRC upon lookup of /dev/pts it tried to find $rootfs/dev/pts/ptmx
> > and open that instead.
> >
> Which gives a very good explanation about why haven't I seen it =)
> Eric ?
> 
> What it a /dev/ptmx already exist? will it use it? That would be bad,

No, I think it was the open handler on the ptmx node that did it.  If
the fs underlying the ptmx file wasn't devpts then it would do the
path lookup.  So then if /dev/pts/ptmx was actually the host one, then
you get what you asked for, but it's not like a symlink (where the
link could be to host /dev/pts/ptmx whereas current task has a different
/dev/pts/ptmx)

> since that /dev/ptmx could be a host-side one. I actually believe
> linking to $rootfs/dev/pts/ptmx is more robust than my solution against
> remounts. So provided it can guarantee that the ptmx is not ever the
> root ptmx, I would ack that.
> 
