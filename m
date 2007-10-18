From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Simplify /proc/cgroups
Date: Thu, 18 Oct 2007 12:17:45 +0900
Message-ID: <20071018121745.35c740bd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071018025636.ADCDE3D6261@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764916AbXJRDQZ@vger.kernel.org>
In-Reply-To: <20071018025636.ADCDE3D6261@localhost>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, pj@sgi.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Wed, 17 Oct 2007 19:56:36 -0700 (PDT)
menage@google.com (Paul Menage) wrote:

> +		seq_printf(m, "%s\t%d\t%d\n",
> +			   ss->name, ss->root->subsys_bits,
> +			   ss->root->number_of_cgroups);
>  	}
Because subsys_bits is unsigned long, then %lu or %lx is better.

Thanks,
-Kame
