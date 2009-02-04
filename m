From: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Thu, 05 Feb 2009 07:58:19 +1100
Message-ID: <1233781099.4612.1.camel__8752.72899070314$1233781279$gmane$org@pasglop>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<1233718789.16867.156.camel@pasglop> <20090204155406.GA2039@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090204155406.GA2039-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2009-02-04 at 09:54 -0600, Serge E. Hallyn wrote:
> Quoting Benjamin Herrenschmidt (benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org):
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
