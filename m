From: James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [TOOLS] To make use of the patches
Date: Thu, 28 Jul 2011 08:23:59 +0000
Message-ID: <1311841438.30253.20.camel@mulgrave>
References: <4E204466.8010204@parallels.com> <4E204554.6040901@parallels.com>
	<20110722234558.GD16940@count0.beaverton.ibm.com>
	<4E2A8704.3030306@parallels.com>
	<20110727230003.GE15501@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110727230003.GE15501-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
Content-Language: en-US
Content-ID: <1AEA053E1B2579478E7B5C4B79637E58-ruSsrxOD6xDby3iVrkZq2A@public.gmane.org>
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
Cc: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2011-07-27 at 16:00 -0700, Matt Helsley wrote:
> On Sat, Jul 23, 2011 at 12:32:04PM +0400, Pavel Emelyanov wrote:
> 
> <snip>
> 
> > > For any subsequent postings could you split this up into multiple
> > > emails -- perhaps one per file? 
> > 
> > OK, will do this.
> > 
> > > Or perhaps make them patches to the kernel's tools directory?
> > 
> > Hm... I didn't think about having these tools be the part of the kernel source tree.
> > 
> > Maybe it would be better if I publish the tools in git repo, what do you think?
> 
> I honestly don't know which is more appropriate.

The decision has largely been made for us.  We now use the kernel
repository tools directory for any tools which are specific to (and
bound to) kernel infrastructure.  Checkpoint/Restore seems to fall into
this category.

James
