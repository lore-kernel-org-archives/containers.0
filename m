From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Subject: Re: [-mm PATCH 4/9] Memory controller memory accounting (v4)
Date: Tue, 31 Jul 2007 12:38:32 +0900 (JST)
Message-ID: <20070731033832.9E8B41BF6B4@siro.lan>
References: <20070727201018.31565.42132.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S940288AbXGaDip@vger.kernel.org>
In-Reply-To: Your message of "Sat, 28 Jul 2007 01:40:18 +0530"
	<20070727201018.31565.42132.sendpatchset@balbir-laptop>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

> +	lock_meta_page(page);
> +	/*
> +	 * Check if somebody else beat us to allocating the meta_page
> +	 */
> +	race_mp = page_get_meta_page(page);
> +	if (race_mp) {
> +		kfree(mp);
> +		mp = race_mp;
> +		atomic_inc(&mp->ref_cnt);
> +		res_counter_uncharge(&mem->res, 1);
> +		goto done;
> +	}

i think you need css_put here.

YAMAMOTO Takashi
