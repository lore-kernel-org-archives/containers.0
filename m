From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7] Clone PTS namespace
Date: Wed, 09 Apr 2008 15:15:13 -0700
Message-ID: <1207779313.16926.12.camel@x61.ebiederm.org>
References: <20080408215333.GA8799@us.ibm.com>  <47FC138B.4070408@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47FC138B.4070408-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2008-04-08 at 17:53 -0700, H. Peter Anvin wrote:
> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > Devpts namespace patchset
> > 
> > In continuation of the implementation of containers in mainline, we need to
> > support multiple PTY namespaces so that the PTY index (ie the tty names) in
> > one container is independent of the PTY indices of other containers.  For
> > instance this would allow each container to have a '/dev/pts/0' PTY and
> > refer to different terminals.
> > 
> 
> Why do we "need" this?  There isn't a fundamental need for this to be a 
> dense numberspace (in fact, there are substantial reasons why it's a bad 
> idea; the only reason the namespace is dense at the moment is because of 
> the hideously bad handing of utmp in glibc.)  Other than indicies, this 
> seems to be a more special case of device isolation across namespaces, 
> would that be a more useful problem to solve across the board?

In short application migration.  When you move a running applicaiton
from one machine to another you want to be able to keep the same pseudo
devices.

The isolation that you have noticed is also an important application and
like the rest of the namespaces if we can solve the duplicate identifier
problem needed to restore checkpoints we also largely solve the
isolation problem.

This problem is much larger then ptys.  ptys are the really in your face
aspect of it.  There are a more pseudo devices in the kernel and it is
the device number to device mapping that we are abstracting.  So this
really should be done as a device namespace not a pty namespace.

I would be happy if the first version of the device namespace could not
map anything but pty's (assuming an incremental implementation path).  I
really don't think we should do a special case for each kind of device.

Oh and just skimming the patch summary I'm pretty certain this
implementation breaks /sys/class/tty/ptyXX/uevent.  Which is another
reason why it would be good to have a single device namespace.  So we
only to capture one more namespace and figure out how to deal with it
when mounting sysfs. 

Eric
