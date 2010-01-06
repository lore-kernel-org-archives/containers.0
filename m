From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] RFC: taking a crack at targeted capabilities
Date: Wed, 6 Jan 2010 15:57:21 -0600
Message-ID: <20100106215721.GA5823@us.ibm.com>
References: <20100106062809.GA17064@us.ibm.com>
	<m17hrv18ad.fsf@fess.ebiederm.org>
	<20100106201725.GA24242@us.ibm.com>
	<m1skajszuw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1skajszuw.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
> >> - Introduce ns_capable to test for a capability in a non-default
> >>   user namespace.
> >> - Teach cap_capable to handle capabilities in a non-default
> >>   user namespace.
> >
> > So yeah, I didn't address the whole has_capability junk.  Feh.
> 
> That just fell out...
> 
> > So do you intend to tag all namespaces with the userns which
> > created it?  So sys_hostname() can check utsname->uts_ns->creator,
> > and net ioctl SIOCSIFNAME checks struct net->creator?
> 
> That is the plan.  Add a creator/usernamespace as part of the patches
> to support creating a new namespace without the global CAP_SYS_ADMIN.

Cool - are you working on that right now, or should I start it myself
if i'm bored and restless tonight?

-serge
