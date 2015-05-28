From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [CFT][PATCH 00/10] Making new mounts of proc and sysfs as safe
	as bind mounts (take 2)
Date: Thu, 28 May 2015 14:08:39 +0000
Message-ID: <20150528140839.GD28842__11033.4352976226$1432822150$gmane$org@ubuntumail>
References: <87pp63jcca.fsf@x220.int.ebiederm.org>
	<87siaxuvik.fsf@x220.int.ebiederm.org>
	<87wq004im1.fsf@x220.int.ebiederm.org>
	<CALCETrUhXBR5WQ6gXr9KzGc4=7tph7kzopY29Hug4g+FhOzEKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrUhXBR5WQ6gXr9KzGc4=7tph7kzopY29Hug4g+FhOzEKg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michael Kerrisk-manpages <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andy Lutomirski (luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org):
> On Fri, May 22, 2015 at 10:39 AM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> > I had hoped to get some Tested-By's on that patch series.
> 
> Sorry, I've been totally swamped.
> 
> I suspect that Sandstorm is okay, but I haven't had a chance to test
> it for real.  Sandstorm makes only limited use of proc and sysfs in
> containers, but I'll see if I can test it for real this weekend.

Testing this with unprivileged containers, I get

lxc-start: conf.c: lxc_mount_auto_mounts: 808 Operation not permitted - error mounting sysfs on /usr/lib/x86_64-linux-gnu/lxc/sys/devices/virtual/net flags 0

> > Oh well.  The fundamentals seem sound, and my biggest concern the
> > implicit nodev does not apply so I will put this patchset in linux-next
> > and aim at merging it in the next merge window.  Hopefully that will
> > leave enough time catch problems.
> >
> > Eric
> >
> 
> 
> 
> -- 
> Andy Lutomirski
> AMA Capital Management, LLC
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
