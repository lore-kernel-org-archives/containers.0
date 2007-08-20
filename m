From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [Devel] [-mm PATCH 1/9] Memory controller resource counters (v6)
Date: Mon, 20 Aug 2007 14:31:51 +0530
Message-ID: <46C9587F.8000402@linux.vnet.ibm.com>
References: <20070817084228.26003.12568.sendpatchset@balbir-laptop> <20070817084238.26003.7733.sendpatchset@balbir-laptop> <20070820082054.GA6926@localhost.sw.ru>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757266AbXHTJDd@vger.kernel.org>
In-Reply-To: <20070820082054.GA6926@localhost.sw.ru>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> On Fri, Aug 17, 2007 at 02:12:38PM +0530, Balbir Singh wrote:
>> --- /dev/null
>> +++ linux-2.6.23-rc2-mm2-balbir/kernel/res_counter.c
>> +void res_counter_init(struct res_counter *counter)
>> +{
>> +	spin_lock_init(&counter->lock);
>> +	counter->limit = (unsigned long)LONG_MAX;
> 
> why cast?
> 

These patches come from Pavel. They add to readability since
limit is unsigned long.

>> +int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
>> +{
>> +	if (counter->usage > (counter->limit - val)) {
> 
> () aren't needed.
> 

it makes the code more readable

>> +	if (WARN_ON(counter->usage < val))
>> +		val = counter->usage;
> 
> explicit if and WARN_ON(1) is clearer. I should send a patch banning such
> type of usage soon.
> 

We had a WARN_ON(1) before, but we changed it in v2 or v3 based on review
comments from Dave. I think WARN_ON(cond) is more readable than
WARN_ON(1) for the same reason as BUG_ON(cond) vs BUG_ON(1)

>> +	buf = kmalloc(nbytes + 1, GFP_KERNEL);
> 
> please, switch to fixed buffer, allocating memory depending on size
> told by userspace will beat later. Ditto for other proc writing
> functions.
> 

I agree with you in part, but the size of user input is not fixed.
Setting a fixed limit seems artificial, I'll see how this can be improved.


Thanks for the detailed review comments,

-- 
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
