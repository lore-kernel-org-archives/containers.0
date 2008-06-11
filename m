From: Andrea Righi <righi.andrea@gmail.com>
Subject: Re: [RFC PATCH 3/5] mgmcg VM overcommit interface
Date: Wed, 11 Jun 2008 12:43:03 +0200 (MEST)
Message-ID: <484FAC37.90300@gmail.com>
References: <>  <1213054383-18137-4-git-send-email-righi.andrea@gmail.com> <1213119746.13882.15.camel@nimitz>
Reply-To: righi.andrea@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754296AbYFKKnb@vger.kernel.org>
In-Reply-To: <1213119746.13882.15.camel@nimitz>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Tue, 2008-06-10 at 01:33 +0200, Andrea Righi wrote:
>> +       cgroup_unlock();
>> +
>> +       count = sprintf(page, "CommitLimit:  %8lu kB\n"
>> +                             "Committed_AS: %8lu kB\n",
>> +                             K(allowed), K(committed));
>> +       ret = simple_read_from_buffer(userbuf, nbytes, ppos, page, count);
>> +out:
>> +       free_page((unsigned long)page);
>> +       return ret;
>> +}
> 
> I know you're trying to make this look like meminfo, but it does butcher
> the sysfs rules a bit.  How about breaking it out into a couple of
> files?
> 
> -- Dave

Sounds reasonable.

Anyway, I think this patchset should be simply dropped in favor of the
Balbir's memrlimit controller, as reported by Kamezawa.

The memrlimit controller permits to implement the overcommit policies in
userspace directly setting the cgroup VM limits (well.. I've not read the
memrlimit source yet, but from the documentation it seems so).

-Andrea
