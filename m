From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] Memory controller Add Documentation
Date: Thu, 23 Aug 2007 00:50:10 +0530
Message-ID: <46CC8C6A.7080904@linux.vnet.ibm.com>
References: <20070822130612.18981.58696.sendpatchset@balbir-laptop> <6599ad830708221218t3c1eae51o1605f00b8f204b02@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932206AbXHVTUd@vger.kernel.org>
In-Reply-To: <6599ad830708221218t3c1eae51o1605f00b8f204b02@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On 8/22/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
>>  Documentation/memcontrol.txt |  193 +++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 193 insertions(+)
>>
>> diff -puN /dev/null Documentation/memcontrol.txt
>> --- /dev/null   2007-06-01 20:42:04.000000000 +0530
>> +++ linux-2.6.23-rc2-mm2-balbir/Documentation/memcontrol.txt    2007-08-22 18:29:29.000000000 +0530
>> @@ -0,0 +1,193 @@
>> +Memory Controller
>> +
>> +0. Salient features
>> +
>> +a. Enable control of both RSS and Page Cache pages
> 
> s/RSS/anonymous/ (and generally throughout the document)? RSS can
> include pages that are part of the page cache too.
> 
> Paul

Yes, thats a good point. I'll clean up the documentation.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
