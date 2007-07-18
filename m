From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Subject: Re: Containers: css_put() dilemma
Date: Wed, 18 Jul 2007 11:22:18 +0530
Message-ID: <20070718055218.GF2216@linux.vnet.ibm.com>
References: <20070717070031.GA22410@linux.vnet.ibm.com> <6599ad830707170018p180cb7dfr53e609fd0b186e30@mail.gmail.com> <469C99D1.7090807@linux.vnet.ibm.com> <6599ad830707170849v11fe8cecs6d172cd38d247e09@mail.gmail.com> <469CFF2B.1080702@linux.vnet.ibm.com> <6599ad830707171044u38c0a940r12d2bc80b475ead4@mail.gmail.com> <469D066B.6050606@linux.vnet.ibm.com> <6599ad830707171126o7c431277p84f532d0122a8a98@mail.gmail.com> <469D9728.2080701@linux.vnet.ibm.com> <469DA57F.9050302@linux.vnet.ibm.com>
Reply-To: vatsa@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756099AbXGRFnI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <469DA57F.9050302@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: "Paul (??) Menage" <menage@google.com>, dhaval@linux.vnet.ibm.com, linux kernel mailing list <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@sw.ru>, Paul Jackson <pj@sgi.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Wed, Jul 18, 2007 at 11:00:39AM +0530, Balbir Singh wrote:
> Thinking out loud again, can we add can_destory() callbacks?

I remember suggesting such a callback long before :

	http://marc.info/?l=linux-kernel&m=117576241131788&w=2

-- 
Regards,
vatsa
