From: Kevin Fox <Kevin.Fox-Y2zl/4KMd60@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Mon, 16 Mar 2009 15:33:28 -0700
Message-ID: <1237242808.23841.38.camel__36731.6710799516$1237243135$gmane$org@sledge.emsl.pnl.gov>
References: <1236891719.32630.14.camel@bahia>
	<20090312212124.GA25019@us.ibm.com>
	<604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
	<20090313053458.GA28833@us.ibm.com>
	<alpine.LFD.2.00.0903131018390.3940@localhost.localdomain>
	<20090313193500.GA2285@x200.localdomain>
	<alpine.LFD.2.00.0903131401070.3940@localhost.localdomain>
	<1236981097.30142.251.camel@nimitz><49BADAE5.8070900@cs.columbia.edu>
	<m1hc1xrlt5.fsf@fess.ebiederm.org>  <20090314081207.GA16436@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090314081207.GA16436-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 2009-03-14 at 01:12 -0700, Ingo Molnar wrote:
> 
> * Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> 
> > >> In the OpenVZ case, they've at least demonstrated that the
> > >> filesystem can be moved largely with rsync.  Unlinked files
> > >> need some in-kernel TLC (or /proc mangling) but it isn't
> > >> *that* bad.
> > >
> > > And in the Zap we have successfully used a log-based
> > > filesystem (specifically NILFS) to continuously snapshot the
> > > file-system atomically with taking a checkpoint, so it can
> > > easily branch off past checkpoints, including the file
> > > system.
> > >
> > > And unlinked files can be (inefficiently) handled by saving
> > > their full contents with the checkpoint image - it's not a
> > > big toll on many apps (if you exclude Wine and UML...). At
> > > least that's a start.
> >
> > Oren we might want to do a proof of concept implementation
> > like I did with network namespaces.  That is done in the
> > community and goes far enough to show we don't have horribly
> > nasty code.  The patches and individual changes don't need to
> > be quite perfect but close enough that they can be considered
> > for merging.
> >
> > For the network namespace that seems to have made a big
> > difference.
> >
> > I'm afraid in our clean start we may have focused a little too
> > much on merging something simple and not gone far enough on
> > showing that things will work.
> >
> > After I had that in the network namespace and we had a clear
> > vision of the direction.  We started merging the individual
> > patches and things went well.
> 
> I'm curious: what is the actual end result other than good
> looking code? In terms of tangible benefits to the everyday
> Linux distro user. [This is not meant to be sarcastic, i'm
> truly curious.]

From an ordinary user perspective, I hate loosing my desktop state every
time there is a power bump or a new kernel/video driver comes down from
the distro provider. Some of the stuff I loose:
*All my terminals
    *many tabs and windows
    *each in a different directory
    *vi
       *which files I was editing
       *which function I was coding
    *screen
    *scrollback buffer's contents
         *history for debugging code
    *command line arguments
*State of running apps
    *web browser
        *Tabs, yes it saves urls on crash, but sometimes the page cant
come back up (say, because of a form)
        *where the windows are on the desktop
    *evolution
        *what folder is selected
        *which message within the folder is selected
    *rhythmbox
    *misc other apps

Being able to reboot and get back to exactly where I was before the
reboot would save me a lot of time restarting apps and getting my
desktop back to where it was before the reboot. I'd also be more
inclined to reboot to get security updates more frequently if I didn't
loose track of what I was doing in the session, making machines more
secure in the process.

Kevin

PS: Yes, I know both GNOME and KDE have tried to deal with some of this
with their session manager stuff, but it doesn't restore everything and
only supported by some apps. It would probably take more work to get all
apps working with the session management stuff then supporting kernel
C/R.

>         Ingo
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
> 
