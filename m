From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Thu, 29 Jan 2009 22:01:30 -0600
Message-ID: <20090130040130.GB30595__4365.39008883319$1233288229$gmane$org@us.ibm.com>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<49814FA2.9060108@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <49814FA2.9060108@cs.columbia.edu>
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
Cc: containers@lists.osdl.org, linuxppc-dev@ozlabs.org, Nathan Lynch <ntl@pobox.com>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl@cs.columbia.edu):
> > +static void cr_hdr_init(struct cr_hdr *hdr, __s16 type, __s16 len, __u32 parent)
> > +{
> > +	hdr->type = type;
> > +	hdr->len = len;
> > +	hdr->parent = parent;
> > +}
> > +
> 
> This function is rather generic and useful to non-arch-dependent and other
> architectures code. Perhaps put in a separate patch ?

BTW I disagree here - looking through the patch I found
the use of this fn to be very distracting.  To replace 3
simple in-line assignments, I have to verify the order of
4 weird-looking arguments, and actually first try to
remember what 'cr_hdr_init' is supposed to be and do?

That's not meant to be a complaint, just explanation :)

I prefer dropping its use altogether.  Since I believe
most of the functions calling it in this patch shouldn't
exist anyway (just writing 0xdeadbeef into the file), it
all the more should just go away.

-serge
