From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 03/33] task containersv11 add tasks file interface
Date: Wed, 3 Oct 2007 19:46:52 -0700
Message-ID: <20071003194652.873b0bcf.pj@sgi.com>
References: <20070917210307.116234000@menage.corp.google.com>
	<20070917210426.579524000@menage.corp.google.com>
	<20071003010923.c606c176.pj@sgi.com>
	<6599ad830710030816m32321b54gbc79c24d0a39941b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756584AbXJDCrT@vger.kernel.org>
In-Reply-To: <6599ad830710030816m32321b54gbc79c24d0a39941b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, serue@us.ibm.com, clg@fr.ibm.com, ebiederm@xmission.com, xemul@openvz.org, rientjes@google.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

> >  - There are many instances of the local variable 'cont', referring
> >    to a struct cgroup pointer.  I presume the spelling 'cont' is a
> >    holdover from the time when we called these containers.
> 
> Yes, and since cgroup is short for "control group", "cont" still
> seemed like a reasonable abbreviation. (And made the automatic
> renaming much simpler).

The following will change all 'cont' words to your choice (I doubt
you want to use 'XXXX' as I did here) in cgroup.c:

    sed -i -r 's/(\W|^)cont(\W|$)/\1XXXX\2/g' kernel/cgroup.c

I can't say for sure, but I suspect that if cgroups had always
been cgroups (short for control groups), then these local 'cont'
variables would have a different name.  One can often, as in this
case, find some justification for most any name.  The question is
which name is most quickly and easily understood.

... yes ... I'm a stickler for names ... sorry.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
