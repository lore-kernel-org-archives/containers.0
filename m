From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [-mm PATCH 4/9] Memory controller memory accounting (v4)
Date: Tue, 31 Jul 2007 18:14:26 +0530
Message-ID: <46AF2EAA.2080703@linux.vnet.ibm.com>
References: <20070727201018.31565.42132.sendpatchset@balbir-laptop> <20070731033832.9E8B41BF6B4@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759954AbXGaMoq@vger.kernel.org>
In-Reply-To: <20070731033832.9E8B41BF6B4@siro.lan>
Sender: linux-kernel-owner@vger.kernel.org
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, menage@google.com, dhaval@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org



YAMAMOTO Takashi wrote:
>> +	lock_meta_page(page);
>> +	/*
>> +	 * Check if somebody else beat us to allocating the meta_page
>> +	 */
>> +	race_mp = page_get_meta_page(page);
>> +	if (race_mp) {
>> +		kfree(mp);
>> +		mp = race_mp;
>> +		atomic_inc(&mp->ref_cnt);
>> +		res_counter_uncharge(&mem->res, 1);
>> +		goto done;
>> +	}
> 
> i think you need css_put here.

Thats correct. We do need css_put in this path.

Thanks,
Vaidy

> YAMAMOTO Takashi
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
