From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm PATCH] Memory controller improve user interface (v3)
Date: Tue, 04 Sep 2007 08:28:57 +0100
Message-ID: <46DD0939.7030409@linux.vnet.ibm.com>
References: <20070902105021.3737.31251.sendpatchset@balbir-laptop> <6599ad830709022153g1720bcedsb61d7cf7a783bd3f@mail.gmail.com> <46DC6543.3000607@linux.vnet.ibm.com> <6599ad830709040019r17861771we2a0893c0c160723@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753360AbXIDH3m@vger.kernel.org>
In-Reply-To: <6599ad830709040019r17861771we2a0893c0c160723@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On 9/3/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> Paul Menage wrote:
>>> On 9/2/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>> -       s += sprintf(s, "%lu\n", *val);
>>>> +       if (read_strategy)
>>>> +               s += read_strategy(*val, s);
>>>> +       else
>>>> +               s += sprintf(s, "%lu\n", *val);
>>> This would be better as %llu
>>>
>> Hi, Paul,
>>
>> This does not need fixing, since the other counters like failcnt are
>> still unsigned long
>>
> 
> But val is an unsigned long long*. So printing *val with %lu will
> break (at least a warning, and maybe corruption if you had other
> parameters) on 32-bit archs.
> 

Yeah... Hmm.. just wonder if all the counters should be unsigned long
long? failcnt is the only remaining unsigned long counter now.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
