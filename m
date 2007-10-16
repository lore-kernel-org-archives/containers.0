From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] cpuset update_cgroup_cpus_allowed
Date: Tue, 16 Oct 2007 16:14:45 -0700
Message-ID: <20071016161445.2f866d42.pj@sgi.com>
References: <20071015071115.16057.72116.sendpatchset@jackhammer.engr.sgi.com>
	<alpine.DEB.0.9999.0710151135150.24837@chino.kir.corp.google.com>
	<20071015230729.53fcbaf7.pj@sgi.com>
	<alpine.DEB.0.9999.0710152311180.22383@chino.kir.corp.google.com>
	<20071016021626.15b94649.pj@sgi.com>
	<alpine.DEB.0.9999.0710161121450.32268@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965782AbXJPXPH@vger.kernel.org>
In-Reply-To: <alpine.DEB.0.9999.0710161121450.32268@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Cc: menage@google.com, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, clg@fr.ibm.com, ebiederm@xmission.com, containers@lists.osdl.org, serue@us.ibm.com, svaidy@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

David wrote:
> Not necessarily because migration only occurs to any online cpu in the 
> mask, it won't attempt to migrate it to some cpu that has been downed.
> ...

... one of David or I is insane ... I can't tell which one yet,
perhaps both of us ;).

I'm going to reply to David without all the CC list above.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
