From: Paul Jackson <pj@sgi.com>
Subject: Re: Containers: css_put() dilemma
Date: Tue, 17 Jul 2007 10:23:27 -0700
Message-ID: <20070717102327.dc402025.pj@sgi.com>
References: <469BBE00.8000709@linux.vnet.ibm.com>
	<6599ad830707161203o7f148c75p52e77d4be3ace487@mail.gmail.com>
	<469C2792.6050009@linux.vnet.ibm.com>
	<6599ad830707161935n69776f1t98292fc9990f4766@mail.gmail.com>
	<20070717070031.GA22410@linux.vnet.ibm.com>
	<6599ad830707170018p180cb7dfr53e609fd0b186e30@mail.gmail.com>
	<469C99D1.7090807@linux.vnet.ibm.com>
	<6599ad830707170849v11fe8cecs6d172cd38d247e09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763822AbXGQRXo@vger.kernel.org>
In-Reply-To: <6599ad830707170849v11fe8cecs6d172cd38d247e09@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Paul (=?ISO-8859-1?Q?=5F=5F=5F=5F=5F=5F?=) Menage" <menage@google.com>
Cc: balbir@linux.vnet.ibm.com, dhaval@linux.vnet.ibm.com, xemul@sw.ru, linux-kernel@vger.kernel.org, containers@lists.osdl.org, akpm@linux-foundation.org
List-Id: containers.vger.kernel.org

> Because as soon as you do the atomic_dec_and_test() on css->refcnt and
> the refcnt hits zero, then theoretically someone other thread (that
> already holds container_mutex) could check that the refcount is zero
> and free the container structure.

Not just theory ... I've debugged crashes from live customer systems
that were basically this race.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
