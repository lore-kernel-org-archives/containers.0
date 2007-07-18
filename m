From: "Paul Menage" <menage@google.com>
Subject: Re: Containers: css_put() dilemma
Date: Wed, 18 Jul 2007 16:15:38 -0700
Message-ID: <6599ad830707181615w4f2e4078j58473090691e36eb@mail.gmail.com>
References: <469BBE00.8000709@linux.vnet.ibm.com>
	 <6599ad830707170018p180cb7dfr53e609fd0b186e30@mail.gmail.com>
	 <469C99D1.7090807@linux.vnet.ibm.com>
	 <6599ad830707170849v11fe8cecs6d172cd38d247e09@mail.gmail.com>
	 <469CFF2B.1080702@linux.vnet.ibm.com>
	 <6599ad830707171044u38c0a940r12d2bc80b475ead4@mail.gmail.com>
	 <469D066B.6050606@linux.vnet.ibm.com>
	 <6599ad830707171126o7c431277p84f532d0122a8a98@mail.gmail.com>
	 <469D9728.2080701@linux.vnet.ibm.com>
	 <469DA57F.9050302@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935858AbXGRXQQ@vger.kernel.org>
In-Reply-To: <469DA57F.9050302@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: dhaval@linux.vnet.ibm.com, linux kernel mailing list <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@sw.ru>, Paul Jackson <pj@sgi.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On 7/17/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> Thinking out loud again, can we add can_destroy() callbacks?
>

What would the exact semantics of such a callback be?

Since for proper interaction with release agents we need the subsystem
to notify the framework when a subsystem object becomes releasable
(currently as part of css_put()), what would a can_destroy() callback
let you do that you couldn't do just by taking an extra css refcount
to prevent destruction and releasing that refcount to allow
destruction?

Paul
