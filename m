From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Wed, 04 Feb 2009 14:39:49 +1100
Message-ID: <1233718789.16867.156.camel__4089.1645745889$1233718948$gmane$org@pasglop>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1233182478-27113-2-git-send-email-ntl@pobox.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
To: Nathan Lynch <ntl@pobox.com>
Cc: containers@lists.osdl.org, linuxppc-dev@ozlabs.org
List-Id: containers.vger.kernel.org


> +struct cr_hdr_cpu {
> +	struct pt_regs pt_regs;
> +	/* relevant fields from thread_struct */
> +	double fpr[32][TS_FPRWIDTH];
> +	unsigned int fpscr;
> +	int fpexc_mode;
> +	/* unsigned int align_ctl; this is never updated? */
> +	unsigned long dabr;
> +};

Is there some version or other identification somewhere ? If not there
should be. ie, we're going to add things here. For example, what about
the vector registers ? Also, some CPUs will have more HW debug registers
than just the DABR (we plan to add support for all the BookE architected
IACs and DACs for example), etc...

Ben.
