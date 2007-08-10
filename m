From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [-mm PATCH 0/9] Memory controller introduction (v4)
Date: Fri, 10 Aug 2007 10:19:49 +0530
Message-ID: <46BBEE6D.1040704@linux.vnet.ibm.com>
References: <20070727200937.31565.78623.sendpatchset@balbir-laptop> <20070808125139.7cfe702c.kamezawa.hiroyu@jp.fujitsu.com> <20070808165131.b4ab4e92.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754665AbXHJEuX@vger.kernel.org>
In-Reply-To: <20070808165131.b4ab4e92.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Eric W Biederman <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: containers.vger.kernel.org


KAMEZAWA Hiroyuki wrote:
> On Wed, 8 Aug 2007 12:51:39 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> On Sat, 28 Jul 2007 01:39:37 +0530
>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> At OLS, the resource management BOF, it was discussed that we need to manage
>>> RSS and unmapped page cache together. This patchset is a step towards that
>>>
>> Can I make a question ? Why limiting RSS instead of # of used pages per
>> container ? Maybe bacause of shared pages between container.... 
> Sorry....Ignore above question.
> I didn't understand what mem_container_charge() accounts and limits.
> It controls # of meta_pages.

Hi Kame,

Actually the number of pages resident in memory brought in by a
container is charged.  However each such page will have a meta_page
allocated to keep the extra data.

Yes, the accounting counts the number of meta_page which is same as
the number of mapped and unmapped (pagecache) pages brought into the
system memory by this container.  Whether pagecache pages should be
included or not is configurable per container through the 'type' file
in containerfs.

--Vaidy
