From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11] cpuset: export effective masks to userspace
Date: Fri, 23 Aug 2013 15:53:37 +0800
Message-ID: <52171501.8050401@huawei.com>
References: <52148F52.0@huawei.com> <52148FFC.4080701@huawei.com>
	<20130821142001.GK19286@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130821142001.GK19286-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2013/8/21 22:20, Tejun Heo wrote:
> On Wed, Aug 21, 2013 at 06:01:32PM +0800, Li Zefan wrote:
>>  	{
>> +		.name = "effective_cpus",
>> +		.flags = CFTYPE_SANE,
>> +		.read = cpuset_common_file_read,
>> +		.max_write_len = (100U + 6 * NR_CPUS),
>> +		.private = FILE_EFFECTIVE_CPULIST,
> 
> I don't think we need CFTYPE_SANE.  We can just expose these
> unconditionally, right?  It still means the same thing when !sane.
> 

It seems confusing if there're two interaces but they actually mean
the same thing.

Another reason I didn't do this is, they're not always the same. When
!sane, If cpus_allowed is empty, effective_cpus is not empty, and you
are not able to put tasks into this cpuset. So if we want to  expose
it unconditionally, I'll make sure cpus_allowed == effective_cpus
always stand when !sane.
