From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [REVIEW][PATCH 0/6] Wrapping up the vfs support for unprivileged
	mounts
Date: Wed, 30 May 2018 14:34:55 +1000
Message-ID: <20180530043455.GN23861__13337.5002457344$1527654802$gmane$org@dastard>
References: <87o9h6554f.fsf@xmission.com> <20180524214617.GG7712@thunk.org>
	<87y3g8y6x9.fsf@xmission.com> <20180525035716.GE10363@dastard>
	<8736yar4g3.fsf@xmission.com> <20180529221710.GM23861@dastard>
	<87k1rlkh1g.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87k1rlkh1g.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: "Theodore Y. Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, May 29, 2018 at 09:34:35PM -0500, Eric W. Biederman wrote:
> Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org> writes:
> 
> > Yeah, the are some fairly big process and policy things that
> > need to be decided here. Not just at the kernel level, but at
> > distro and app infrastructure level too.
> >
> > I was originally sceptical of supporting kernel filesystems via
> > lkl, but the desire for unprivileged mounts has not gone away
> > and so I'm less worried about accessing filesystems that way
> > than I am of letting the kernel parse untrusted images from
> > untrusted users...
> 
> There is also the more readily available libguestfs which doesn't
> support as many filesystems but does seem available in most linux
> distributions already.  It already has a fuse option available
> with guestmount.  I may have to dig in there and see how to make
> it available without using fusermount.

That only provides host access to filesystems mounted inside guest
VMs, right?  AFAIA, libguestfs is not providing a FUSE
implementation that mounts and parses raw XFS images. e.g it barely
understands anything XFS, and that which it does is via running and
screen-scraping the output of XFS's userspace management tools...

> > I'm not sure what the correct forum for this is - wasn't this
> > something the Plumbers conference was supposed to facilitate?
> 
> Yes.  If we all need to be in a room and talk about things.
> It is early enough in the planning for Plumers that we could
> definitely schedule a talk or a BOF for this.

Ok. I have no idea if I'll be at plumbers - it's an awful long way
from where I am....

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
