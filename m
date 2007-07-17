From: Paul Jackson <pj@sgi.com>
Subject: Re: Containers: css_put() dilemma
Date: Tue, 17 Jul 2007 10:53:41 -0700
Message-ID: <20070717105341.9e51cc79.pj@sgi.com>
References: <469BBE00.8000709@linux.vnet.ibm.com>
	<6599ad830707161203o7f148c75p52e77d4be3ace487@mail.gmail.com>
	<469C2792.6050009@linux.vnet.ibm.com>
	<6599ad830707161935n69776f1t98292fc9990f4766@mail.gmail.com>
	<20070717070031.GA22410@linux.vnet.ibm.com>
	<6599ad830707170018p180cb7dfr53e609fd0b186e30@mail.gmail.com>
	<469C99D1.7090807@linux.vnet.ibm.com>
	<6599ad830707170849v11fe8cecs6d172cd38d247e09@mail.gmail.com>
	<469CFF2B.1080702@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934534AbXGQRx7@vger.kernel.org>
In-Reply-To: <469CFF2B.1080702@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: menage@google.com, dhaval@linux.vnet.ibm.com, xemul@sw.ru, linux-kernel@vger.kernel.org, containers@lists.osdl.org, akpm@linux-foundation.org
List-Id: containers.vger.kernel.org

> That sounds correct. I wonder now if the solution should be some form
> of delegation for deletion of unreferenced containers (HINT: work queue
> or kernel threads).

At least for cpusets (the mother of all containers), notify on release
is part of the user visible API of cpusets.  The kernel does not remove
cpusets; it runs a user program, /sbin/cpuset_release_agent.  That
program might choose to rmdir the cpuset directory, and/or do other
actions, like notify a batch scheduler that one of its cpusets was
released.

That API is not as sacrosanct as some, but it is working, and I wouldn't
want to break it without good reason.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
