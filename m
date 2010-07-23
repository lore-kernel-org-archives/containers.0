From: Jan Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: create /sys/fs/cgroup to mount cgroupfs on
Date: Fri, 23 Jul 2010 12:32:26 +0200
Message-ID: <4C496FBA.3060009__41101.0757241913$1279881230$gmane$org@redhat.com>
References: <20100722182638.GA12712@kroah.com>
	<AANLkTinRGBksuWAZhdmvr39FNACU18+kc5ut49VUf=mp@mail.gmail.com>
	<20100722183614.GA5443@suse.de> <20100722193741.GA2688@redhat.com>
	<20100722211856.GA1297@suse.de>
	<AANLkTinFQtwrCC82T9KlKskDV8fn-zYgimyH2wguHkqY@mail.gmail.com>
	<20100722231401.GA11538@suse.de>
	<20100723020714.GA11236@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100723020714.GA11236-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ivana Hutarova Varekova <varekova-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/23/2010 04:07 AM, Vivek Goyal wrote:
> On Thu, Jul 22, 2010 at 04:14:01PM -0700, Greg KH wrote:
>> On Fri, Jul 23, 2010 at 01:08:12AM +0200, Kay Sievers wrote:
>>> On Thu, Jul 22, 2010 at 23:18, Greg KH<gregkh-l3A5Bk7waGM@public.gmane.org>  wrote:
>>>>> For my testing I now always use /cgroup/ and create directories under it
>>>>> /cgroup/blkio /cgroup/cpu etc and mount controllers on respective
>>>>> directories.
>>>>
>>>> Lennart and Kay, is this what systemd is doing?  I really don't think we
>>>> should be adding a root /cgroup/ mount point to the system for something
>>>> like this.
>>>
>>> Already solved. Systemd always mounts an empty tmpfs at the 'cgroup'
>>> mountpoint, and stuff is free to create subdirs there. Systemd itself
>>> mount 'systemd' there.
>>
>> Ah, that makes it easier.  Paul and Vivek, any objection to this patch
>> going in now?
>>
>
> This sounds reasonable to me also.
>
> Jan, I know you have been working in this area and raised concenrs about
> cgroup mount point in the past. Does it look good to you?

I would prefer some place where subdirectories can be created for 
individual hierarchies without additional tmpfs there. But as I 
understand /sys, it's not an easy feature to implement it there, so no, 
I am not against /sys/fs/cgroup.

Jan
