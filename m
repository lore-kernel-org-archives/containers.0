From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 11/33] task containersv11 make cpusets a client of
 containers
Date: Thu, 4 Oct 2007 10:31:19 -0700
Message-ID: <20071004103119.ac841fb0.pj@sgi.com>
References: <20070917210307.116234000@menage.corp.google.com>
	<20070917210427.888917000@menage.corp.google.com>
	<20071004025355.4a096316.pj@sgi.com>
	<6599ad830710040816p63108ab1vb8547b9600b9e659@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758399AbXJDRbi@vger.kernel.org>
In-Reply-To: <6599ad830710040816p63108ab1vb8547b9600b9e659@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linuxfoundation.org, balbir@linux.vnet.ibm.com, serue@us.ibm.com, clg@fr.ibm.com, ebiederm@xmission.com, xemul@openvz.org, rientjes@google.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Paul M wrote:
> It's two constant-indexed dereferences *in total*, compared to a
> single constant-indexed dereference in the pre-cgroup case.

Ok - the C expression is longer and I didn't realize how
little difference it made in the end (the executing code.)

Good - thanks.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
