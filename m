From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/3] powerpc: bare minimum
	checkpoint/restart	implementation
Date: Wed, 04 Feb 2009 18:44:14 -0500
Message-ID: <498A284E.4050501__9775.1434463591$1233791228$gmane$org@cs.columbia.edu>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>	<1233182478-27113-2-git-send-email-ntl@pobox.com>	<1233718789.16867.156.camel@pasglop>
	<20090204155406.GA2039@us.ibm.com>
	<1233781099.4612.1.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1233781099.4612.1.camel@pasglop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org



Benjamin Herrenschmidt wrote:
> On Wed, 2009-02-04 at 09:54 -0600, Serge E. Hallyn wrote:
>> Quoting Benjamin Herrenschmidt (benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org):
>>>> +struct cr_hdr_cpu {
>>>> +	struct pt_regs pt_regs;
>>>> +	/* relevant fields from thread_struct */
>>>> +	double fpr[32][TS_FPRWIDTH];
>>>> +	unsigned int fpscr;
>>>> +	int fpexc_mode;
>>>> +	/* unsigned int align_ctl; this is never updated? */
>>>> +	unsigned long dabr;
>>>> +};
>>> Is there some version or other identification somewhere ? If not there
>>> should be. ie, we're going to add things here. For example, what about
>>> the vector registers ? Also, some CPUs will have more HW debug registers
>>> than just the DABR (we plan to add support for all the BookE architected
>>> IACs and DACs for example), etc...
>> The arch-independent checkpoint header does have kernel
>> maj:min:rev:patch info.  We expect to have to do more,
>> assuming that the .config can change the arch-dependent
>> cpu header (i.e. perhaps TS_FPRWIDTH could be changed).
> 
> It could to a certain extent... things like VSX, VSR, or freescale SPE,
> or even the Cell SPU state etc....
> 
> I wonder if we want a tagged structure so we can easily add things...

From the little bit I read hear, I suspect that the sub-arch classification
is best done in an arch-dependent header. I'd follow the following rule
of thumb:

* Anything that is decided at compiled time should probably go to the arch-
dependent header.

* Anything that can change at boot time (e.g., for x86 that would include
the capabilities of the FPU), or even run time (is there any ?) should
be described to the letter (in fine print) in 'struct cr_hdr_cpu' and
friends.

Oren.
