From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: Device Namespaces
Date: Sun, 29 Sep 2013 13:06:20 -0700
Message-ID: <20130929200620.GA31304@kroah.com>
References: <CAA2m6veny-7_ONMA973Wu36U4kz4gAuw0dpodkb8+GZDv6VNBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAA2m6veny-7_ONMA973Wu36U4kz4gAuw0dpodkb8+GZDv6VNBQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Sep 29, 2013 at 10:28:55PM +0300, Amir Goldstein wrote:
> =

> =

> =

> On Thu, Sep 26, 2013 at 8:33 AM, Greg Kroah-Hartman <gregkh@linuxfoundati=
on.org
> > wrote:
> =

>     On Wed, Sep 25, 2013 at 02:34:54PM -0700, Eric W. Biederman wrote:
>     > So the big issues for a device namespace to solve are filtering whi=
ch
>     > devices a container has access to and being able to dynamically cha=
nge
>     > which devices those are at run time (aka hotplug).
> =

>     As _all_ devices are hotpluggable now (look, there's no CONFIG_HOTPLUG
>     anymore, because it was redundant), I think you need to really think
>     this through better (pci, memory, cpus, etc.) before you do anything =
in
>     the kernel.
> =

>     > After having thought about this for a bit I don't know if a pure
>     > userspace solution is sufficient or actually a good idea.
>     >
>     > - We can manually manage a tmpfs with device nodes in userspace.
>     > =A0 (But that is deprecated functionality in the mainstream kernel).
> =

>     Yes, but I'm not going to namespace devtmpfs, as that is going to be =
an
>     impossible task, right?
> =

> =

> That sounds like a challenge ;-)
> Seriously, as Serge correctly noted, it would not be that different from =
devpts
> if you start from an empty devtmpfs and populate it with devices that are
> "added in the context of that namespace".  The semantics in which
> devices are "added in the context of a namespace" is the missing piece
> of the puzzle.

And the fact that these devices are almost all created before userspace
starts up, is a non-trivial "piece of the puzzle" :)

Good luck,

greg k-h
