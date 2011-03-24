From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: c/r failure
Date: Wed, 23 Mar 2011 19:11:37 -0700
Message-ID: <20110324021137.GE22601@count0.beaverton.ibm.com>
References: <20110307193503.GA16777@hallyn.com>
	<20110324005230.GD22601@count0.beaverton.ibm.com>
	<20110324013452.GA14481@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110324013452.GA14481-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 23, 2011 at 08:34:52PM -0500, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > 	Unfortunately ckptinfo is broken. My most recent series of 18 patches
> > to user-cr fixes it. I've attached the output using an earlier version
> 
> Egads.

Incidentally, those patches don't change checkpoint or restart -- just
the build and ckptinfo. So unless you want to patch your own ckptinfo
or have some quirky old "boxes" like me, you don't need them.

> 
> > beginning. This was masked by some troubles with ckpt_err() which I still
> > haven't been able to figure out -- the "error" reported in dmesg above
> > is -512 but really should be -32 (EPIPE). You rewrote that code, didn't you? ;)
> 
> Eeeeyeee know nothink.  Nothink!
> 
> > Anyhow, today I managed to bisect my user-cr troubles down to:
> > 
> > 5b97422c4c1342a128df508cda7c4639ecb24a36
> > 
> > Revert was not clean and the resolved conflicts on top of the revert did
> > not seem to fix the problem, soo... :/ all I can recommend at the moment is
> > sticking to the earlier branches.
> 
> 
> > Hope that helps. Again, sorry for the delay.
> 
> Thanks, Matt.  It'll be at least a week before I have a chance to play with
> it again, but I'll give earlier versions a shot.  Is there any particular
> matching version for kernel+user-dr which you'd recomment at this point?

So far the closest thing I have to a working combination is this commit
found via bisect:

v23-rc1 + user-cr @ f1d427d4ce1df44432fccd2e08c60992c8169b8c
"Ghost tasks must be detached"

(which just follows: f0fdd38cb0a53594eec9d4e19671d0c33036517c
"headers: regenerate for ckpt-v23-rc1 [x86_32]" -- nice to know it's
about the right spot)

Watch out for non-matching syscall numbers. The clone_*.* source files
will use old "default" values _very_ _quietly_ if they aren't found via
the updated headers in ./include/linux . Syscall numbers in those files
tend to get updated much less frequently.

I am testing on x86-32 in KVM at the moment and haven't run everything
so YMMV.

Cheers,
	-Matt Helsley
