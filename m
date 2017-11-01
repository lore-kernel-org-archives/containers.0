From: Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 0/5] userns: bump idmap limits, fixes & tweaks
Date: Wed, 1 Nov 2017 14:31:00 +0100
Message-ID: <20171101133059.t7qgvylutsqhsc5f@gmail.com>
References: <20171024220441.10235-1-christian.brauner@ubuntu.com>
	<20171024220441.10235-2-christian.brauner@ubuntu.com>
	<871sliubhj.fsf_-_@xmission.com>
	<CAPP7u0WDVv0pAAFEuzL2c9Y-wVg0xG36jyH-eok=GV-r6UewZg@mail.gmail.com>
	<87tvyemeqe.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87tvyemeqe.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 01, 2017 at 06:15:53AM -0500, Eric W. Biederman wrote:
> Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
> 
> > On Tue, Oct 31, 2017 at 06:46:32PM -0500, Eric W. Biederman wrote:
> >>
> >> Christian I have looked through your code and I have found one real
> >> issue and of things I want to twak
> >
> > Cool, thanks for taking a close look Eric.
> >
> >>
> >> The real issue is reading nr_extents multiple times when reading a map.
> >> That can introduce races that will allow walking past the end of the
> >> array, if the first read is 0 but the second read is > 5.
> >>
> >> I have also found a couple of tweaks that look like they are worth
> >> implementing.
> >
> > Yeah, I saw that you unified some of the functions. I was thinking about this
> > but wanted to keep the cases distinct even with some amount of code duplication.
> > But it seems very much worth it from a maintenance perspective. Thanks!
> 
> Yes.  If we have a performance regression I am willing to remove the
> unification of map_id_range_down and map_id_down.  But I can't imagine
> that will result in a measurable performance difference.  If it does
> make a measurable perforamnce difference we almost certainly need to split
> the bsearch case as well.
> 
> >> As all of these are very small and very straight forward I have
> >> tested these and applied them all to my for-next branch
> >
> > Thanks for the fixes Eric. Really appreciated. If you're too swamped for stuff
> > like that I'm obviously happy to do such trivial fixes myself. :)
> 
> If you would test this some more in your setup I would appreciate it,
> just in case I missed something.

I've been running kernels with this patch for a few weeks now with nested
unprivileged containers and all sorts of weird setups. So far I didn't observe
any problems. Once we've settled the memory barrier discussion I'm going to
recompile and run a few tests.

> 
> Given where we are in the development cycle and the correctness concerns
> I just applied these as without the fix for reading extents exactly once
> the code is dangerously wrong.
> 
> Eric
> 
> > Christian
> >
> >>
> >>
> >> Eric W. Biederman (5):
> >>       userns: Don't special case a count of 0
> >>       userns: Simplify the user and group mapping functions
> >>       userns: Don't read extents twice in m_start
> >>       userns: Make map_id_down a wrapper for map_id_range_down
> >>       userns: Simplify insert_extent
> >>
> >>  kernel/user_namespace.c | 159 ++++++++++++++++--------------------------------
> >>  1 file changed, 51 insertions(+), 108 deletions(-)
> >>
> >>
> >>
> >>
