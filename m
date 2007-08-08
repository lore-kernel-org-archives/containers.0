From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm PATCH 0/9] Memory controller introduction (v4)
Date: Wed, 8 Aug 2007 12:51:39 +0900
Message-ID: <20070808125139.7cfe702c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070727200937.31565.78623.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936885AbXHHDtr@vger.kernel.org>
In-Reply-To: <20070727200937.31565.78623.sendpatchset@balbir-laptop>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Eric W Biederman <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On Sat, 28 Jul 2007 01:39:37 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> At OLS, the resource management BOF, it was discussed that we need to manage
> RSS and unmapped page cache together. This patchset is a step towards that
> 
Can I make a question ? Why limiting RSS instead of # of used pages per
container ? Maybe bacause of shared pages between container.... 
I'm sorry that I don't have much knowledge about history of this work.
If already discussed, the pointer to log is helpful.

Thanks,
-Kame
