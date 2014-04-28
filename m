From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: pid ns feature request
Date: Mon, 28 Apr 2014 13:39:08 +0000
Message-ID: <20140428133908.GE24913@ubuntumail>
References: <CALCETrVSaboa0Y2v_sTbSz3xOxOZ-6jSq_D7DyQXMRB9VXJB8w@mail.gmail.com>
	<87ha5h42va.fsf@x220.int.ebiederm.org>
	<CALCETrX3GjNkhKkST9Nw4sk2ETt=MRUWcc+bNXnGFTXn7ve-ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrX3GjNkhKkST9Nw4sk2ETt=MRUWcc+bNXnGFTXn7ve-ww-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serge-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andy Lutomirski (luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org):
> On Fri, Apr 25, 2014 at 12:37 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> > Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
> >
> >> Unless I'm missing some trick, it's currently rather painful to mount
> >> a namespace /proc.  You have to actually be in the pid namespace to
> >> mount the correct /proc instance, and you can't unmount the old /proc
> >> until you've mounted the new /proc.  This means that you have to fork
> >> into the new pid namespace before you can finish setting it up.
> >
> > Yes.  You have to be inside just about all namespaces before you can
> > finish setting them up.
> >
> > I don't know the context in which needed to be inside the pid namespace
> > is a burden.
> 
> I'm trying to sandbox myself.  I unshare everything, setup up new
> mounts, pivot_root, umount the old stuff, fork, and wait around for
> the child to finish.
> 
> This doesn't work: the parent can't mount the new /proc, and the child
> can't either because it's too late.

I'm probably not thinking it through enough...  But can't the parent, before
forking, do

	mkdir -p /childproc/proc
	mount --bind /childproc /childproc
	mount --make-rshared /childproc

then the child mounts its proc under /childproc/proc and have that show
up in the parent's tree?
