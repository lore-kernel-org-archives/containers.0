From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Containers and /proc/sys/vm/drop_caches
Date: Tue, 11 Jan 2011 10:28:54 -0600
Message-ID: <20110111162854.GB2378@localhost>
References: <20110105094022.GA5366@glandium.org> <4D243EC3.1050101@free.fr>
	<20110105140159.GC2718@hallyn.com>
	<AANLkTi=x=6gUZTxJC8LXxYNu029+firyzKqjMa6m+R-x@mail.gmail.com>
	<20110106214315.GJ29064@count0.beaverton.ibm.com>
	<4D270F34.8080305@parallels.com> <20110107151241.GB4962@hallyn.com>
	<4D285B03.6050708@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D285B03.6050708-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Rob Landley (rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> On 01/07/2011 09:12 AM, Serge Hallyn wrote:
> >> Changing ownership so a script can't open a file that it otherwise
> >>  could may cause scripts to fail when run in a container.  Makes
> >> the containers less transparent.
> > 
> > While my goal next week is to make containers more transparent, the 
> > official stance from kernel summit a few years ago was:  transparent
> >  containers are not a valid goal (as seen from kernel).
> 
> Do you have a reference for that?  I'm still coming up to speed on all this.  Trying to collect documentation...

Sorry, I don't offhand, and a quick google search wasn't helpful.  I think
it was from the very first containers discussion at ksummit, but not sure.
There is http://lwn.net/Articles/191923/.  Toward the bottom it claims that
noone thought it would be a problem to tweak distros to run in containers
without /sys and /proc.

But this was 2006, when pid namespaces were still a new idea, and noone
was actually using containers.  It certainly is possible that sentiment
has changed, which is why I do feel that it's worth it for someone to
try some native containerization inside fs/proc/*.c.  While user namespaces
should make it possible to make fuse proc filtering less wishy-washy, they
won't make it any less ugly :)

-serge
