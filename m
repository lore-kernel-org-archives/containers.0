From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] RFC: taking a crack at targeted capabilities
Date: Mon, 15 Feb 2010 08:37:08 -0800
Message-ID: <20100215163708.GG3714@count0.beaverton.ibm.com>
References: <20100106062809.GA17064@us.ibm.com>
	<m17hrv18ad.fsf@fess.ebiederm.org>
	<20100106201725.GA24242@us.ibm.com>
	<20100215142746.GD3714@count0.beaverton.ibm.com>
	<m13a12bhjq.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m13a12bhjq.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 15, 2010 at 08:16:41AM -0800, Eric W. Biederman wrote:
> Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > On Wed, Jan 06, 2010 at 02:17:25PM -0600, Serge E. Hallyn wrote:
> >> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> > "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> >
> > <snip>
> >
> >> > >From db104af741b5f0a2f128688905498cae68fbbde2 Mon Sep 17 00:00:00 2001
> >> > From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >> > Date: Wed, 6 Jan 2010 08:26:21 -0800
> >> > Subject: [PATCH] security:  Make capabilities relative to the user namespace.
> >> > 
> >> > - Introduce ns_capable to test for a capability in a non-default
> >> >   user namespace.
> >> > - Teach cap_capable to handle capabilities in a non-default
> >> >   user namespace.
> >> 
> >> So yeah, I didn't address the whole has_capability junk.  Feh.
> >> 
> >> So do you intend to tag all namespaces with the userns which
> >> created it?  So sys_hostname() can check utsname->uts_ns->creator,
> >> and net ioctl SIOCSIFNAME checks struct net->creator?
> >
> > That makes sense but I'm getting a worried about the way those extra
> > namespace references are popping up in other namespace structs. Seems
> > like it would be easy to write code that could create reference
> > cycles and thus leak memory. Perhaps it will require splitting the
> > references sort of like struct mm_struct?
> 
> Not yet.  If we only grab references as namespace creation time
> reference cycles are impossible, at least reference cycles outside
> of the initial namespaces.

Ahh, good point.

It occurs to me that one nice thing about sticking those references in
is the code will roughly document the fact that these types of namespaces
are related.

> > The other example of that idea was keeping a syslog_ns reference in
> > the netns for the iptables printks in ipt_LOG.c. What happens when
> > one of the CONFIG_*NS options isn't selected? Suddenly we're littering
> > the struct definitions with #ifdefs and making the code alot more
> > complicated to test (I suspect). Perhaps it's time to merge all
> > the CONFIG_*NS options into CONFIG_NAMESPACES?
> 
> Truthfully I am dubious about the syslog namespace.  Certainly the
> implementations I have seen so far seem half thought out.

Yeah. I agree that it's not quite clear what's needed. But that doesn't
really address my points in the second paragraph above (the first
paragraphed was answered nicely, thanks!).

Cheers,
	-Matt Helsley
