From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [libvirt] kernel summit topic - 'containers end-game'
Date: Mon, 29 Jun 2009 16:05:41 +0530
Message-ID: <661de9470906290335i74f76a55t57438a781e6a84c8@mail.gmail.com>
References: <20090623145611.GB19332@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <libvir-list-bounces@redhat.com>
In-Reply-To: <20090623145611.GB19332@us.ibm.com>
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

On Tue, Jun 23, 2009 at 8:26 PM, Serge E. Hallyn<serue@us.ibm.com> wrote:
> A topic on ksummit agenda is 'containers end-game and how do we
> get there'.
>
> So for starters, looking just at application (and system) containers, w=
hat do
> the libvirt and liblxc projects want to see in kernel support that is c=
urrently
> missing? =A0Are there specific things that should be done soon to make =
containers
> more useful and usable?
>
> More generally, the topic raises the question... what 'end-games' are t=
here?
> A few I can think of off-hand include:
>
> =A0 =A0 =A0 =A01. resource control

We intend to hold a io-controller minisummit before KS, we should have
updates on that front. We also need to discuss CPU hard limits and
Memory soft limits. We need control for memory large page, mlock, OOM
notification support, shared page accounting, etc. Eventually on the
libvirt front, we want to isolate cgroup and lxc support into
individual components (long term)

> =A0 =A0 =A0 =A02. lightweight virtual servers
> =A0 =A0 =A0 =A03. (or 2.5) unprivileged containers/jail-on-steroids
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(lightweight virtual servers in which yo=
u might, just
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0maybe, almost, be able to give away a ro=
ot account, at
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0least as much as you could do so with a =
kvm/qemu/xen
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0partition)
> =A0 =A0 =A0 =A04. checkpoint, restart, and migration
>
> For each end-game, what kernel pieces do we think are missing? =A0For i=
nstance,
> people seem agreed that resource control needs io control :) =A0Contain=
ers imo
> need a user namespace. =A0I think there are quite a few network namespa=
ce
> exploiters who require sysfs directory tagging (or some equivalent) to
> allow us to migrate physical devices into network namespaces. =A0And
> checkpoint/restart needs... checkpoint/restart.

Balbir Singh
