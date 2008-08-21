From: Peter Eisentraut <peter_e@gmx.net>
Subject: Re: [Bugme-new] [Bug 11381] New: default shmmax
Date: Thu, 21 Aug 2008 11:24:08 +0300
Message-ID: <200808211124.10850.peter_e@gmx.net>
References: <bug-11381-10286@http.bugzilla.kernel.org/> <20080820120043.e6e7e436.akpm@linux-foundation.org> <18605.8253.81960.581255@frecb006361.adech.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755261AbYHUIYO@vger.kernel.org>
In-Reply-To: <18605.8253.81960.581255@frecb006361.adech.frec.bull.fr>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Solofo.Ramangalahy@bull.net
Cc: Andrew Morton <akpm@linux-foundation.org>, matthltc@us.ibm.com, bugme-daemon@bugzilla.kernel.org, linux-kernel@vger.kernel.org, Nadia Derbey <Nadia.Derbey@bull.net>, Manfred Spraul <manfred@colorfullife.com>, Pierre Peiffer <peifferp@gmail.com>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Solofo.Ramangalahy@bull.net wrote:
> OpenSuse (11.0 at least) has this:
> -#define SHMMAX 0x2000000 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* max share=
d seg size (bytes) */
> +#define SHMMAX ULONG_MAX =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* max share=
d seg size (bytes) */

Interesting, I don't see that in SLES 10, so it must be quite new.  If =
no=20
problems are found with this, this would be great for the upstream kern=
el.
