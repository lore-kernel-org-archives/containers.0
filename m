From: Nathan Lynch <ntl@pobox.com>
Subject: Re: [PATCH 2/3] c/r: Add CR_COPY() macro (v3)
Date: Wed, 4 Mar 2009 14:01:29 -0600
Message-ID: <20090304140129.35e1ad97@thinkcentre.lan>
References: <1236095764-19325-1-git-send-email-danms@us.ibm.com>
 <1236095764-19325-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757659AbZCDUBq@vger.kernel.org>
In-Reply-To: <1236095764-19325-3-git-send-email-danms@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Hi Dan.

Dan Smith <danms@us.ibm.com> wrote:
> +#define CR_CPT 1
> +#define CR_RST 2
> +
> +#define CR_COPY(op, a, b)				        \
> +	do {							\
> +		if (op == CR_CPT)				\
> +			a = b;					\
> +		else						\
> +			b = a;					\
> +	} while (0);

Drop the semicolon ^


> +
> +#define CR_COPY_ARRAY(op, a, b, count)				\
> +	do {							\
> +		BUILD_BUG_ON(sizeof(*a) != sizeof(*b));		\
> +		if (op == CR_CPT)				\
> +			memcpy(a, b, count * sizeof(*a));	\
> +		else						\
> +			memcpy(b, a, count * sizeof(*a));	\
> +	} while (0);
> +

You might want to employ __must_be_array() or similar to catch misuse.

Misuse might also be prevented by providing some documentation :)
