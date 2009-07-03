From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks"
	that shows only unique tgids
Date: Thu, 2 Jul 2009 19:25:53 -0700
Message-ID: <20090703022553.GJ19135__17099.6173903861$1246588079$gmane$org@count0.beaverton.ibm.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
	<20090702164649.303c4952.akpm@linux-foundation.org>
	<2f86c2480907021731h13e0bb95q94f06829eded9aa6@mail.gmail.com>
	<20090702175341.fd2e26d5.akpm@linux-foundation.org>
	<6599ad830907021808o6f3bb51eh324e4bf13544d83e@mail.gmail.com>
	<2f86c2480907021817o79fce75yd9785aab682f7bb4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2f86c2480907021817o79fce75yd9785aab682f7bb4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 02, 2009 at 06:17:56PM -0700, Benjamin Blum wrote:
> On Thu, Jul 2, 2009 at 6:08 PM, Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> > On Thu, Jul 2, 2009 at 5:53 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org=
> wrote:

<snip>

> >
> >>
> >> One could perhaps create an alias (symlink?) and leave that in place
> >> for a few kernel releases and then remove the old names. =A0The trick =
to
> >> doing this politely is to arrange for a friendly printk to come out
> >> when userspace uses the old filename, so people know to change their
> >> tools. =A0That printk should come out once-per-boot, not once-per-acce=
ss.
> >
> > Personally, I feel that a bit of ugliness in the naming inconsistency
> > is less painful than trying to deprecate something that people might
> > be using.
> =

> That's what the people who designed x86 said :P

And look at how successful x86 has been! ;)

Seriously, I don't think the name "tasks" is ugly. I think "tasks"
is a nice balance between overly verbose ("cgroup.tasks") and specificity.
If anything I think the new file should be called "processes", not
"cgroup.procs". The established convention was "subsys.foo". cgroup is not
a subsystem of itself hence the names "tasks" and "processes" are just fine.

> > If we could just flip the names without breaking anyone,
> > that would be great, but this is just a style issue rather than a
> > functional issue. My experience of such printk() statements scattered
> > around in code is that no-one takes much notice of them.

I agree with Paul.

> =

> Whether or not we get rid of the old ones, it would be good to put in
> aliases with the new style now so there's the option of removing the
> old style ones later.

What a terrible idea! If every alias has an uncertain future nobody will
know which they should use. As a consequence 50% may use "tasks" and 50%
may use "cgroup.tasks" and then we won't be able to remove either name!

Let's stick with what we have and not add endless numbers of aliases for
every possible naming convention.

Cheers,
	-Matt Helsley
