From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: Question for remount
Date: Tue, 24 Feb 2009 09:41:28 +0800
Message-ID: <49A35048.3000304__28333.0316575759$1235439874$gmane$org@cn.fujitsu.com>
References: <20090220190223.e8b4f6a8.kamezawa.hiroyu@jp.fujitsu.com>	<49A20976.2050301@cn.fujitsu.com>	<49A21044.40402@cn.fujitsu.com>
	<20090224103659.069e6b33.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090224103659.069e6b33.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

>>  To change the set of subsystems bound to a mounted hierarchy, just
>>  remount with different options:
>> +# mount -o remount,cpuset,ns hier1 /dev/cgroup
>>  
>> -# mount -o remount,cpuset,ns  /dev/cgroup
>> +Now numtasks is removed from the hierarchy and ns is added.
>> +
>> +Note this will add ns to the hierarchy but won't remove numtasks or
>> +cpuset:
>> +# mount -o remount,ns /dev/cgroup
>>  
> 
> Just a question. What is "numtasks" here ? We have numtasks cgroup ?
> 

No, I guess that's a proposed but not implemented cgroup subsystem. :)
And I can change it to an existing one.
