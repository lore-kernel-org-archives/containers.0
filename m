From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm] [2/2] Simple stats for memory resource controller
Date: Thu, 27 Mar 2008 00:23:36 +0530
Message-ID: <47EA9BB0.3030202@linux.vnet.ibm.com>
References: <200803262348.59785.balajirrao@gmail.com> <6599ad830803261152j1973e3c8oa82181a830f89260@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762199AbYCZS5P@vger.kernel.org>
In-Reply-To: <6599ad830803261152j1973e3c8oa82181a830f89260@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Balaji Rao <balajirrao@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, balbir@in.ibm.com, dhaval@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Wed, Mar 26, 2008 at 11:18 AM, Balaji Rao <balajirrao@gmail.com> wrote:
>>         [MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
>>  +       [MEM_CGROUP_STAT_PGIN_COUNT] = {"page_in_count", 1, },
>>  +       [MEM_CGROUP_STAT_PGOUT_COUNT] = {"page_out_count", 1, },
>>   };
>>
> 
> Should these be called "pgpgin" and "pgpgout" for consistency with /proc/vmstat?
> 
> Paul

Yes, that is a good name. We also want to instantaneous metrics like
page_in_count per second and page_out_count per second to help the administrator
monitor what is going on within the tasks in the cgroup w.r.t. memory.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
