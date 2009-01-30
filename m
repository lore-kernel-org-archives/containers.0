From: Nathan Lynch <ntl@pobox.com>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Fri, 30 Jan 2009 14:25:44 -0600
Message-ID: <20090130202544.GG6913__6235.73826528645$1233347335$gmane$org@localdomain>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<49814FA2.9060108@cs.columbia.edu> <20090129214035.GB6913@localdomain>
	<49824599.5030503@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <49824599.5030503@cs.columbia.edu>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.osdl.org, linuxppc-dev@ozlabs.org
List-Id: containers.vger.kernel.org

Oren Laadan wrote:
> 
> Nathan Lynch wrote:
> > 
> > Oren Laadan wrote:
> >> Nathan Lynch wrote:
> >>> +		pr_debug("%s: unexpected thread_hdr contents: 0x%lx\n",
> >>> +			 __func__, (unsigned long)thread_hdr->unimplemented);
> >> Given the macro for 'pr_fmt' in include/linux/checkpoint.h, the use of
> >> __func__ is redunant.
> > 
> > It seems to me that defining your own pr_fmt in a "public" header like
> > that is inappropriate, or at least unconventional.  Any file that
> > happens to include linux/checkpoint.h will have any prior definitions
> > of pr_fmt overridden, no?
> > 
> 
> Hmmm.. didn't think of it this way. Using the pr_debug() there was yet
> another feedback from LKML, and it seemed reasonable to me. Can you
> think of a case where linux/checkpoint.h will happen to be included
> in checkpoint-related code ?

(Assume you meant "included in checkpoint-unrelated code")

I could see checkpoint.h being included by files that don't
exclusively deal with C/R.  If you want a uniform debug statement
format for C/R-related code, that's fine, but this isn't the way to do
it.  See the existing users (almost all in drivers/s390).
