From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [lxc-devel] [PATCH 1/1] lxc-ps: Nit - Avoid blank CONTAINER column
Date: Thu, 11 Feb 2010 09:54:46 -0600
Message-ID: <20100211155446.GC6884__33466.4097092629$1265903816$gmane$org@us.ibm.com>
References: <20100211042531.GA8835@us.ibm.com>
	<1265882900.2591.65.camel@pagloppaglop>
	<1265883662.2591.68.camel@pagloppaglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1265883662.2591.68.camel@pagloppaglop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michel Normand <normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, dlezcano-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Michel Normand (normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> Le jeudi 11 f=E9vrier 2010 =E0 11:08 +0100, Michel Normand a =E9crit :
> > Le mercredi 10 f=E9vrier 2010 =E0 20:25 -0800, Sukadev Bhattiprolu a =
=E9crit :
> > > From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > > Date: Wed, 10 Feb 2010 20:09:17 -0800
> > > Subject: [PATCH 1/1] lxc-ps: Nit - Avoid blank CONTAINER column
> > > =

> > > The contianer name is not printed in the lxc-ps output unless the --l=
xc
> > > option is specified.  But the CONTAINER column is printed (and left
> > > blank) even if the --lxc option is not specified.
> > > =

> > > 	$ /usr/local/bin/lxc-ps -n foo
> > > 	CONTAINER    PID TTY          TIME CMD
> > > 		   19525 pts/2    00:00:01 bash
> > > 		   20311 pts/2    00:00:00 lxc-ps
> > > 		   20312 pts/2    00:00:00 ps
> > =

> > For me the error in the script is =

> > to report default pid of ps command,
> > rather than to report the pids of specified 'foo' =

> > container in this case.
> > =

> > So a patch should address this point,
> > rather to remove the container column.
> =

> In fact there is no error in the script :)
> The -n option for lxc-ps is a ps option ! =


heh, good catch - given -n is pretty ubiquitous in lxc
commands it should probably be used here :)

And a '--' should be allowed to separate lxc-ps options from
/bin/ps ones.


> and not the --name option that I assume you should have specified
> as detailed in the online help of lxc-ps.
> =

> ---
> Michel
> =

> > =

> > ---
> > Michel
> > =

> > > =

> > > Like normal ps, it would be less confusing (IMHO) if the CONTAINER
> > > column is skipped unless the --lxc option is specified.
> > > =

> > > 	$ ./lxc-ps -n foo
> > > 	  PID TTY          TIME CMD
> > > 	19525 pts/2    00:00:01 bash
> > > 	20339 pts/2    00:00:00 lxc-ps
> > > 	20340 pts/2    00:00:00 ps
> > > =

> > > 	$ ./lxc-ps --lxc -n foo
> > > 	CONTAINER    PID TTY          TIME CMD
> > > 	foo        19646 pts/1    00:00:00 lxc-init
> > > 	foo        19647 pts/1    00:00:00 bash
> > > =

> > > Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > > ---
> > >  src/lxc/lxc-ps.in |   12 ++++++++++--
> > >  1 files changed, 10 insertions(+), 2 deletions(-)
> > > =

> > > diff --git a/src/lxc/lxc-ps.in b/src/lxc/lxc-ps.in
> > > index 249b104..e1aa655 100755
> > > --- a/src/lxc/lxc-ps.in
> > > +++ b/src/lxc/lxc-ps.in
> > > @@ -124,7 +124,11 @@ sub get_container {
> > >  }
> > >  =

> > >  sub display_headers {
> > > -    printf "%-10s %s", "CONTAINER", $PS_HEADERS;
> > > +    if ($LXC_DISPLAY) {
> > > +        printf "%-10s %s", "CONTAINER", $PS_HEADERS;
> > > +    } else {
> > > +        printf "%s", $PS_HEADERS;
> > > +    }
> > >  }
> > >  =

> > >  sub display_usage {
> > > @@ -195,7 +199,11 @@ for (@PS_LINES) {
> > >      my $container =3D get_container $a[$PS_PID_INDEX];
> > >      if ($LXC_DISPLAY =3D=3D 2 and not $LXC_NAMES{$container}) {next;}
> > >      if ($LXC_DISPLAY =3D=3D 1 and $container eq '') {next;}
> > > -    printf "%-10s %s", $container, $_;
> > > +    if ($LXC_DISPLAY) {
> > > +        printf "%-10s %s", $container, $_;
> > > +    } else {
> > > +        printf "%s", $_;
> > > +    }
> > >  }
> > >  =

> > >  exit 0;
> > =

> > =

> > =

> > -----------------------------------------------------------------------=
-------
> > SOLARIS 10 is the OS for Data Centers - provides features such as DTrac=
e,
> > Predictive Self Healing and Award Winning ZFS. Get Solaris 10 NOW
> > http://p.sf.net/sfu/solaris-dev2dev
> > _______________________________________________
> > Lxc-devel mailing list
> > Lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> > https://lists.sourceforge.net/lists/listinfo/lxc-devel
> =

> =

> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
