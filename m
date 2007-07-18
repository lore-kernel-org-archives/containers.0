From: "=?ISO-2022-JP?B?UGF1bCAoGyRCSnVOXBsoQikgTWVuYWdl?="
	<menage@google.com>
Subject: Re: Containers: css_put() dilemma
Date: Tue, 17 Jul 2007 23:07:09 -0700
Message-ID: <6599ad830707172307t7a9f9555n3ebe8c20c8b854fa@mail.gmail.com>
References: <469BBE00.8000709@linux.vnet.ibm.com>
	 <20070717070031.GA22410@linux.vnet.ibm.com>
	 <6599ad830707170018p180cb7dfr53e609fd0b186e30@mail.gmail.com>
	 <469C99D1.7090807@linux.vnet.ibm.com>
	 <6599ad830707170849v11fe8cecs6d172cd38d247e09@mail.gmail.com>
	 <469CFF2B.1080702@linux.vnet.ibm.com>
	 <6599ad830707171044u38c0a940r12d2bc80b475ead4@mail.gmail.com>
	 <469D066B.6050606@linux.vnet.ibm.com>
	 <6599ad830707171126o7c431277p84f532d0122a8a98@mail.gmail.com>
	 <469D9728.2080701@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761262AbXGRGHe@vger.kernel.org>
In-Reply-To: <469D9728.2080701@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: dhaval@linux.vnet.ibm.com, linux kernel mailing list <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@sw.ru>, Paul Jackson <pj@sgi.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On 7/17/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> Ok.. so my problem still remains, how do I get a non-blocking atomic
> reference increment/decrement routine, that would prevent my
> container from being deleted?

css_put() in my new patchset will be non-blocking.

>
> I don't find cpusets using css_put().

Cpusets never needs to keep a non-process reference on a cpuset
object, so the framework handles everything.

Paul
