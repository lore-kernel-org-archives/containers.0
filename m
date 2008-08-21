From: Peter Eisentraut <peter_e@gmx.net>
Subject: Re: [Bugme-new] [Bug 11381] New: default shmmax
Date: Thu, 21 Aug 2008 11:19:14 +0300
Message-ID: <200808211119.15788.peter_e@gmx.net>
References: <bug-11381-10286@http.bugzilla.kernel.org/> <20080820120043.e6e7e436.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753306AbYHUITU@vger.kernel.org>
In-Reply-To: <20080820120043.e6e7e436.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugme-daemon@bugzilla.kernel.org, linux-kernel@vger.kernel.org, Nadia Derbey <Nadia.Derbey@bull.net>, Solofo Ramangalahy <Solofo.Ramangalahy@bull.net>, Manfred Spraul <manfred@colorfullife.com>, Pierre Peiffer <peifferp@gmail.com>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Andrew Morton wrote:
> It would be useful to get distro input on this. =A0Do they override t=
he
> kernel default at boot time? =A0If so, what do they do?

Debian and Ubuntu have a sysctl.conf that is processed at boot time, bu=
t it=20
does not contain anything related to shm* by default.

Suse has a sysctl.conf, but it is not processed at boot by default.  Yo=
u have=20
to activate a special boot service in the runlevel system to make it ac=
tually=20
run at boot.  (Try explaining that to a PostgreSQL user.)  There is not=
hing=20
related to shm* in the default configuration.
