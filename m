From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [libvirt] kernel summit topic - 'containers end-game'
Date: Wed, 1 Jul 2009 09:59:37 +0530
Message-ID: <20090701042937.GI11273@balbir.in.ibm.com>
References: <20090623145611.GB19332@us.ibm.com>
	<661de9470906290335i74f76a55t57438a781e6a84c8@mail.gmail.com>
	<20090630200613.GA22283@us.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <libvir-list-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <20090630200613.GA22283@us.ibm.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/libvir-list>
List-Post: <mailto:libvir-list@redhat.com>
List-Help: <mailto:libvir-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=subscribe>
Sender: libvir-list-bounces@redhat.com
Errors-To: libvir-list-bounces@redhat.com
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, libvir-list@redhat.com
List-Id: containers.vger.kernel.org

* Serge E. Hallyn <serue@us.ibm.com> [2009-06-30 15:06:13]:

> Quoting Balbir Singh (balbir@linux.vnet.ibm.com):
> > On Tue, Jun 23, 2009 at 8:26 PM, Serge E. Hallyn<serue@us.ibm.com> wr=
ote:
> > > A topic on ksummit agenda is 'containers end-game and how do we
> > > get there'.
> > >
> > > So for starters, looking just at application (and system) container=
s, what do
> > > the libvirt and liblxc projects want to see in kernel support that =
is currently
> > > missing? =A0Are there specific things that should be done soon to m=
ake containers
> > > more useful and usable?
> > >
> > > More generally, the topic raises the question... what 'end-games' a=
re there?
> > > A few I can think of off-hand include:
> > >
> > > =A0 =A0 =A0 =A01. resource control
> >=20
> > We intend to hold a io-controller minisummit before KS, we should hav=
e
> > updates on that front. We also need to discuss CPU hard limits and
> > Memory soft limits. We need control for memory large page, mlock, OOM
> > notification support, shared page accounting, etc. Eventually on the
> > libvirt front, we want to isolate cgroup and lxc support into
> > individual components (long term)
>=20
> Thanks, Balbir.  By the last sentence, are you talking about having
> cgroup in its own libcgroup, or do you mean something else?
>=20
> On the topic of cgroups, does anyone not agree that we should try
> to get rid of the ns cgroup, at least once user namespaces can
> prevent root in a container from escaping their cgroup?
>

I would have no objections to trying to obsolete ns cgroup once user
namespaces can do what you suggest.=20

--=20
	Balbir
