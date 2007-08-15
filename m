From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Subject: Re: [-mm PATCH 4/9] Memory controller memory accounting (v4)
Date: Wed, 15 Aug 2007 17:44:53 +0900 (JST)
Message-ID: <20070815084454.09B061BF982@siro.lan>
References: <46AF2EAA.2080703@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764745AbXHOIpW@vger.kernel.org>
In-Reply-To: Your message of "Tue, 31 Jul 2007 18:14:26 +0530"
	<46AF2EAA.2080703@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: svaidy@linux.vnet.ibm.com
Cc: a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, menage@google.com, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

> YAMAMOTO Takashi wrote:
> >> +	lock_meta_page(page);
> >> +	/*
> >> +	 * Check if somebody else beat us to allocating the meta_page
> >> +	 */
> >> +	race_mp = page_get_meta_page(page);
> >> +	if (race_mp) {
> >> +		kfree(mp);
> >> +		mp = race_mp;
> >> +		atomic_inc(&mp->ref_cnt);
> >> +		res_counter_uncharge(&mem->res, 1);
> >> +		goto done;
> >> +	}
> > 
> > i think you need css_put here.
> 
> Thats correct. We do need css_put in this path.
> 
> Thanks,
> Vaidy

v5 still seems to have the problem.

YAMAMOTO Takashi
