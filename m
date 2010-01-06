From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] RFC: taking a crack at targeted capabilities
Date: Wed, 6 Jan 2010 14:17:25 -0600
Message-ID: <20100106201725.GA24242@us.ibm.com>
References: <20100106062809.GA17064@us.ibm.com>
	<m17hrv18ad.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m17hrv18ad.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > So i was thinking about how to safely but incrementally introduce
> > targeted capabilities - which we decided was a prereq to making VFS
> > handle user namespaces - and the following seemed doable.  My main
> > motivations were (in order):
> >
> >         1. don't make any unconverted capable() checks unsafe
> >         2. minimize performance impact on non-container case
> >         3. minimize performance impact on containers
> 
> My motivation is a bit different.  I would like to get to the
> unprivileged creation of new namespaces.  It looks like this gets us
> 90% of the way there, with only potential uid confusion issues left.
> 
> I still need to handle getting all caps after creation but otherwise I
> think I have a good starter patch that achieves all of your goals.
> 
> Of course kill_permission needs the checks you have suggested as well.
>
> Eric
> 
> 
> >From db104af741b5f0a2f128688905498cae68fbbde2 Mon Sep 17 00:00:00 2001
> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date: Wed, 6 Jan 2010 08:26:21 -0800
> Subject: [PATCH] security:  Make capabilities relative to the user namespace.
> 
> - Introduce ns_capable to test for a capability in a non-default
>   user namespace.
> - Teach cap_capable to handle capabilities in a non-default
>   user namespace.

So yeah, I didn't address the whole has_capability junk.  Feh.

So do you intend to tag all namespaces with the userns which
created it?  So sys_hostname() can check utsname->uts_ns->creator,
and net ioctl SIOCSIFNAME checks struct net->creator?

-serge
