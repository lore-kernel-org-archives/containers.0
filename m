From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [libvirt] kernel summit topic - 'containers end-game'
Date: Tue, 30 Jun 2009 15:06:13 -0500
Message-ID: <20090630200613.GA22283@us.ibm.com>
References: <20090623145611.GB19332@us.ibm.com>
	<661de9470906290335i74f76a55t57438a781e6a84c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <libvir-list-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <661de9470906290335i74f76a55t57438a781e6a84c8@mail.gmail.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/libvir-list>
List-Post: <mailto:libvir-list@redhat.com>
List-Help: <mailto:libvir-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=subscribe>
Sender: libvir-list-bounces@redhat.com
Errors-To: libvir-list-bounces@redhat.com
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, libvir-list@redhat.com
List-Id: containers.vger.kernel.org

Quoting Balbir Singh (balbir@linux.vnet.ibm.com):
> On Tue, Jun 23, 2009 at 8:26 PM, Serge E. Hallyn<serue@us.ibm.com> wrot=
e:
> > A topic on ksummit agenda is 'containers end-game and how do we
> > get there'.
> >
> > So for starters, looking just at application (and system) containers,=
 what do
> > the libvirt and liblxc projects want to see in kernel support that is=
 currently
> > missing? =A0Are there specific things that should be done soon to mak=
e containers
> > more useful and usable?
> >
> > More generally, the topic raises the question... what 'end-games' are=
 there?
> > A few I can think of off-hand include:
> >
> > =A0 =A0 =A0 =A01. resource control
>=20
> We intend to hold a io-controller minisummit before KS, we should have
> updates on that front. We also need to discuss CPU hard limits and
> Memory soft limits. We need control for memory large page, mlock, OOM
> notification support, shared page accounting, etc. Eventually on the
> libvirt front, we want to isolate cgroup and lxc support into
> individual components (long term)

Thanks, Balbir.  By the last sentence, are you talking about having
cgroup in its own libcgroup, or do you mean something else?

On the topic of cgroups, does anyone not agree that we should try
to get rid of the ns cgroup, at least once user namespaces can
prevent root in a container from escaping their cgroup?

thanks,
-serge
