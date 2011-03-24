From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: c/r failure
Date: Wed, 23 Mar 2011 20:34:52 -0500
Message-ID: <20110324013452.GA14481@hallyn.com>
References: <20110307193503.GA16777@hallyn.com>
	<20110324005230.GD22601@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110324005230.GD22601-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> 	Unfortunately ckptinfo is broken. My most recent series of 18 patches
> to user-cr fixes it. I've attached the output using an earlier version

Egads.

> beginning. This was masked by some troubles with ckpt_err() which I still
> haven't been able to figure out -- the "error" reported in dmesg above
> is -512 but really should be -32 (EPIPE). You rewrote that code, didn't you? ;)

Eeeeyeee know nothink.  Nothink!

> Anyhow, today I managed to bisect my user-cr troubles down to:
> 
> 5b97422c4c1342a128df508cda7c4639ecb24a36
> 
> Revert was not clean and the resolved conflicts on top of the revert did
> not seem to fix the problem, soo... :/ all I can recommend at the moment is
> sticking to the earlier branches.


> Hope that helps. Again, sorry for the delay.

Thanks, Matt.  It'll be at least a week before I have a chance to play with
it again, but I'll give earlier versions a shot.  Is there any particular
matching version for kernel+user-dr which you'd recomment at this point?

thanks,
-serge
