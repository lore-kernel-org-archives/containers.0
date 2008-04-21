From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC][-mm] Memory controller hierarchy support (v1)
Date: Mon, 21 Apr 2008 01:33:25 -0500
Message-ID: <20080421013325.03cdd1a8.pj@sgi.com>
References: <20080419053551.10501.44302.sendpatchset@localhost.localdomain>
	<6599ad830804190849u31f13191m4dcca4e471493c2b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756137AbYDUGdj@vger.kernel.org>
In-Reply-To: <6599ad830804190849u31f13191m4dcca4e471493c2b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: balbir@linux.vnet.ibm.com, xemul@openvz.org, yamamoto@valinux.co.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, kamezawa.hiroyu@jp.fujitsu.com
List-Id: containers.vger.kernel.org

Paul M wrote:
> Cpusets could make use of this too, since
> it has to traverse hierarchies sometimes.

Yeah - I suppose cpusets could use it, though
it's not critical.  A fair bit of work already
went into cpusets so that it would not need to
traverse this hierarchy on any critical code path,
or while holding inconvenient locks.

So cpusets shouldn't be the driving motivation
for this, but it will likely be happy to go along
for the ride.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214
