From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: lxc-start: Device or resource busy - failed to remove previous
	cgroup
Date: Mon, 4 Jan 2010 20:30:01 -0600
Message-ID: <20100105023001.GA19747@us.ibm.com>
References: <68e6eac61001031710w3e16f62blfb3b5bfb86ea43b7@mail.gmail.com>
	<661de9471001031722o21c6bd55kb73403c85a8145e3@mail.gmail.com>
	<68e6eac61001031746r44668e6cheb497c7df5f68a18@mail.gmail.com>
	<68e6eac61001031854v35c9b0a0sebce033812977e73@mail.gmail.com>
	<4B41C5A4.704@free.fr>
	<68e6eac61001040721m250c0f14u9c07d04ef9ec3648@mail.gmail.com>
	<20100104180225.GA3510@us.ibm.com>
	<68e6eac61001041642p15d34837ocd13f13bd8249f21@mail.gmail.com>
	<20100105012418.GA14928@us.ibm.com>
	<68e6eac61001041815h251bf0ffi5123f42e69e6a179@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <68e6eac61001041815h251bf0ffi5123f42e69e6a179-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Mon, Jan 4, 2010 at 7:24 PM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > tasks is empty, but there are subdirectories - 102, 26533, etc.
> > This looks like the dirtywork of the ns cgroup. =A0If each of those
> > subdirs is also empty then you can rmdir them, then rmdir /cgroup/arch6=
4-1.
> >
> > Or, use a release agent, which is what I do.
> >
> > cat << EOF > /bin/remove_dead_cgroup.sh
> > #!/bin/sh
> > echo "Removing dead cgroup .$*." >> /var/log/cgroup
> > rmdir /cgroup/$* >> /var/log/cgroup 2>&1
> > echo "return value was $?" >> /var/log/cgroup
> > EOF
> > echo /bin/remove_dead_cgroup.sh > /cgroup/release_agent
> > echo 1 > /cgroup/notify_on_release
> >
> =

> well, In my case those numbered subdirectories are empty, and I can't
> remove the files in them as root even with -f.
> =

> I'll try with a newer kernel.

By 'they are empty' you mean no tasks listed in their tasks file?
What files are you trying to rm -f?  So long as there are no further
cgroup subdirectories, just rmdir each directory - the cgroupfs files
can't be deleted by hand, it's true.

-serge
