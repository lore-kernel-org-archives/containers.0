From: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Tue, 23 Mar 2010 00:38:58 +1100
Message-ID: <20100322133858.GP17637__1585.09783582321$1269265246$gmane$org@laptop>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
	<20100322103035.GF17637@laptop>
	<20100322132232.GD20796@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100322132232.GD20796-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 22, 2010 at 06:22:32AM -0700, Matt Helsley wrote:
> On Mon, Mar 22, 2010 at 09:30:35PM +1100, Nick Piggin wrote:
> > On Thu, Mar 18, 2010 at 08:59:47PM -0400, Oren Laadan wrote:
> > > +	/*
> > > +	 * if seen first time, this will add 'file' to the objhash, keep
> > > +	 * a reference to it, dump its state while at it.
> > > +	 */
> > 
> > All these kinds of things (including above hunks) IMO are nasty to put
> > outside fs/. It would be nice to see higher level functionality
> > implemented in fs and exported to your checkpoint stuff.
> 
> Agreed. I posted a series of patches that reorganized the non-filesystem
> checkpoint/restart code by distributing it to more appropriate places.
> If you can stomach web interfaces have a look at:
> 
> 	http://thread.gmane.org/gmane.linux.kernel.containers/16617
> 
> It'll take a some effort to reorganize and retest ckpt-v20 as I did for
> v19. Then I've got to do the same for the filesystem portions. I think
> that would complete the reorganization.

It may get easier for fs people to review because they won't have
to wade through as much checkpoint code.

 
> > Apparently it's hard because checkpointing is so incestuous with
> > everything, but that's why it's important to structure the code well.
> 
> You're saying it's difficult to organize because it's got to work with
> quite a few disparate VFS structures? My impression is the code breaks
> down pretty well along existing lines (fds, fd table, struct files...).

It is that you are poking inside the internals of the vfs from your
module. This isn't liked because now any changes to vfs have to be
done with an eye to checkpoint/ code. If you can instead implement
the required higher level functionality in fs then it is easier to
ensure that is correct and that the interfaces are used correctly.


> The main problems are resolving the effects of CONFIG_CHECKPOINT=n and
> header inclusion messes.

That's your main problem?

#ifdefs are discouraged but not if it makes the whole structure of
the code more convoluted. ifdefs in _ops structure init for example
isn't a big problem.
