From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: setns vs unshare bug
Date: Fri, 10 Aug 2012 10:24:16 -0500
Message-ID: <20120810152416.GA26902@sergelap>
References: <502520E8.5040401@parallels.com> <20120810150046.GA20449@sergelap>
	<502523DF.4040103@parallels.com> <502525FC.3060608@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <502525FC.3060608-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> On 08/10/2012 07:08 PM, Pavel Emelyanov wrote:
> > On 08/10/2012 07:00 PM, Serge Hallyn wrote:
> >> Hi Pavel,
> >>
> >> I don't believe this is a bug.  The fd is to a specific network
> >> namespace.  If the target task later changes his namespace, that
> >> doesn't change the fact that you asked for access to the old
> >> namespace.
> >>
> >> You're worried about a race?
> > 
> > No, it's not a race. The proc ns file doesn't reflect the actual state
> > of a task it belongs to, but instead has some internal state which is
> > not observable/controllable from the outside. Look at my proggie -- the
> > "else" branch does expects that setns will bring it into a new net, but
> > it only does so if proc dcache is empty!
> 
> I mean -- I open a task's proc ns file _strictly_ _after_ that task called
> unshare, but happen to obtain an _old_ net namespace, because this old netns
> was cached on the task's proc file.
> 
> Hope this explains better what I'm concerned about.

Ooh!  Sorry, now I see.

-serge
