From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Thu, 05 Feb 2009 07:58:19 +1100
Message-ID: <1233781099.4612.1.camel__2849.15420129455$1233781263$gmane$org@pasglop>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<1233718789.16867.156.camel@pasglop> <20090204155406.GA2039@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20090204155406.GA2039@us.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: containers@lists.osdl.org, linuxppc-dev@ozlabs.org, Nathan Lynch <ntl@pobox.com>
List-Id: containers.vger.kernel.org

On Wed, 2009-02-04 at 09:54 -0600, Serge E. Hallyn wrote:
> Quoting Benjamin Herrenschmidt (benh@kernel.crashing.org):
> > 
> > > +struct cr_hdr_cpu {
> > > +	struct pt_regs pt_regs;
> > > +	/* relevant fields from thread_struct */
> > > +	double fpr[32][TS_FPRWIDTH];
> > > +	unsigned int fpscr;
> > > +	int fpexc_mode;
> > > +	/* unsigned int align_ctl; this is never updated? */
> > > +	unsigned long dabr;
> > > +};
> > 
> > Is there some version or other identification somewhere ? If not there
> > should be. ie, we're going to add things here. For example, what about
> > the vector registers ? Also, some CPUs will have more HW debug registers
> > than just the DABR (we plan to add support for all the BookE architected
> > IACs and DACs for example), etc...
> 
> The arch-independent checkpoint header does have kernel
> maj:min:rev:patch info.  We expect to have to do more,
> assuming that the .config can change the arch-dependent
> cpu header (i.e. perhaps TS_FPRWIDTH could be changed).

It could to a certain extent... things like VSX, VSR, or freescale SPE,
or even the Cell SPU state etc....

I wonder if we want a tagged structure so we can easily add things...

Ben.
